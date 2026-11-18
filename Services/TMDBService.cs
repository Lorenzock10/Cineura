
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Cineura.Models;

namespace Cineura.Services
{
    public class TMDBService
    {
        public async Task<string> ObtenerPeliculas()
        {
            string apiKey = Environment.GetEnvironmentVariable("TMDB_API_KEY");

            if (string.IsNullOrEmpty(apiKey))
            {
                return "No se encontró la clave de TMDB.";
            }

            string url = "https://api.themoviedb.org/3/movie/popular"
                       + "?api_key=" + apiKey
                       + "&language=es-ES&page=1";

            using HttpClient cliente = new HttpClient();

            HttpResponseMessage respuesta = await cliente.GetAsync(url);

            if (!respuesta.IsSuccessStatusCode)
            {
                return "Error al consultar TMDB: " + respuesta.StatusCode;
            }

            string json = await respuesta.Content.ReadAsStringAsync();

            using JsonDocument documento = JsonDocument.Parse(json);

            JsonElement peliculas = documento.RootElement.GetProperty("results");

            string resultado = "";

            int cantidad = Math.Min(5, peliculas.GetArrayLength());

            for (int i = 0; i < cantidad; i++)
            {
                JsonElement pelicula = peliculas[i];

                string titulo = pelicula.GetProperty("title").GetString() ?? "";
                string fecha = pelicula.GetProperty("release_date").GetString() ?? "";

                resultado += "Película: " + titulo
                           + " | Estreno: " + fecha
                           + "\n";
            }

            return resultado;
        }

        public async Task<string> ObtenerDetallePelicula(int idTMDB)
        {
            string apiKey = Environment.GetEnvironmentVariable("TMDB_API_KEY");

            if (string.IsNullOrEmpty(apiKey))
            {
                return "No se encontró la clave de TMDB.";
            }

            string url = "https://api.themoviedb.org/3/movie/"
                       + idTMDB
                       + "?api_key=" + apiKey
                       + "&language=es-ES"
                       + "&append_to_response=credits";

            using HttpClient cliente = new HttpClient();

            HttpResponseMessage respuesta = await cliente.GetAsync(url);

            if (!respuesta.IsSuccessStatusCode)
            {
                return "Error al consultar TMDB: " + respuesta.StatusCode;
            }

            string json = await respuesta.Content.ReadAsStringAsync();

            return json;
        }

        public async Task<string> ImportarPelicula(int idTMDB)
        {
            // OBTENER LA INFORMACIÓN DE TMDB

            string json = await ObtenerDetallePelicula(idTMDB);

            if (!json.TrimStart().StartsWith("{"))
            {
                return json;
            }

            using JsonDocument documento = JsonDocument.Parse(json);

            JsonElement pelicula = documento.RootElement;

            string titulo = pelicula.GetProperty("title").GetString() ?? "";
            string sinopsis = pelicula.GetProperty("overview").GetString() ?? "";
            string fecha = pelicula.GetProperty("release_date").GetString() ?? "";
            string poster = pelicula.GetProperty("poster_path").GetString() ?? "";

            int duracion = 0;
            int anio = 0;

            if (pelicula.GetProperty("runtime").ValueKind == JsonValueKind.Number)
            {
                duracion = pelicula.GetProperty("runtime").GetInt32();
            }

            if (fecha.Length >= 4)
            {
                int.TryParse(fecha.Substring(0, 4), out anio);
            }

            // OBTENER LOS GÉNEROS

            JsonElement generos = pelicula.GetProperty("genres");

            string genero = "";

            if (generos.GetArrayLength() > 0)
            {
                genero = generos[0].GetProperty("name").GetString() ?? "";
            }

            // OBTENER EL DIRECTOR

            string director = "Desconocido";

            JsonElement equipo = pelicula
                .GetProperty("credits")
                .GetProperty("crew");

            foreach (JsonElement persona in equipo.EnumerateArray())
            {
                if (persona.GetProperty("job").GetString() == "Director")
                {
                    director = persona.GetProperty("name").GetString() ?? "Desconocido";
                    break;
                }
            }

            // COMPROBAR SI LA PELÍCULA YA EXISTE

            BD bd = new BD();

            int idExistente = bd.ObtenerIdPeliculaTMDB(
                idTMDB,
                titulo,
                anio
            );

            if (idExistente != 0)
            {
                return "La película ya existe en Cineura: " + titulo;
            }

            if (titulo == "" || anio == 0 || duracion == 0)
            {
                return "Faltan datos para importar la película.";
            }

            // OBTENER LAS EMOCIONES DISPONIBLES EN CINEURA

            List<EtiquetasPelicula> etiquetas = bd.ObtenerTodasLasEtiquetas();

            List<string> emociones = etiquetas
                .Where(e => e.Tipo == "Emocion")
                .Select(e => e.Nombre)
                .ToList();

            // PEDIRLE A GROQ QUE ANALICE LA PELÍCULA

            BuscadorIA buscadorIA = new BuscadorIA();

            string emocion = "";

            if (!string.IsNullOrWhiteSpace(sinopsis) && emociones.Count > 0)
            {
                emocion = buscadorIA.ObtenerEmocionPelicula(
                    titulo,
                    sinopsis,
                    genero,
                    emociones
                );
            }

            // PREPARAR EL PÓSTER

            string posterUrl = "";

            if (poster != "")
            {
                posterUrl = "https://image.tmdb.org/t/p/w500" + poster;
            }

            // GUARDAR EL DIRECTOR

            int idDirector = bd.ObtenerOCrearDirector(director);

            // GUARDAR LA PELÍCULA

            bool agregada = bd.AgregarPeliculaTMDB(
                idTMDB,
                titulo,
                sinopsis,
                genero,
                duracion,
                anio,
                emocion,
                idDirector,
                posterUrl
            );

            if (agregada)
            {
                int idPelicula = bd.ObtenerIdPeliculaTMDB(
                    idTMDB,
                    titulo,
                    anio
                );

                if (idPelicula == 0)
                {
                    return "La película se guardó, pero no se encontró su ID.";
                }

                // GUARDAR LOS 5 ACTORES PRINCIPALES

                JsonElement actores = pelicula
                    .GetProperty("credits")
                    .GetProperty("cast");

                int cantidadActores = 0;

                foreach (JsonElement actor in actores.EnumerateArray())
                {
                    if (cantidadActores == 5)
                    {
                        break;
                    }

                    string nombreActor = actor.GetProperty("name").GetString() ?? "";

                    if (!string.IsNullOrEmpty(nombreActor))
                    {
                        int idActor = bd.ObtenerOCrearActor(nombreActor);

                        bd.AgregarActorAPelicula(idPelicula, idActor);

                        cantidadActores++;
                    }
                }

                // GUARDAR LOS GÉNEROS COMO ETIQUETAS

                foreach (JsonElement elemento in generos.EnumerateArray())
                {
                    string nombreGenero = elemento
                        .GetProperty("name")
                        .GetString() ?? "";

                    if (nombreGenero != "")
                    {
                        bd.AgregarEtiquetaAPelicula(
                            idPelicula,
                            nombreGenero,
                            "Tematica"
                        );
                    }
                }

                // GUARDAR LA EMOCIÓN COMO ETIQUETA

                if (emocion != "")
                {
                    bd.AgregarEtiquetaAPelicula(
                        idPelicula,
                        emocion,
                        "Emocion"
                    );
                }

                return "Película importada correctamente: " + titulo
                     + " | ID en Cineura: " + idPelicula
                     + " | Actores agregados: " + cantidadActores
                     + " | Emoción: " + emocion;
            }

            return "No se pudo importar la película.";
        }


public async Task<List<int>> ObtenerIdsPeliculas(int pagina)
{
    List<int> ids = new List<int>();

    string apiKey = Environment.GetEnvironmentVariable("TMDB_API_KEY");

    if (string.IsNullOrEmpty(apiKey))
    {
        return ids;
    }

    string url = "https://api.themoviedb.org/3/movie/popular"
               + "?api_key=" + apiKey
               + "&language=es-ES"
               + "&page=" + pagina;

    using HttpClient cliente = new HttpClient();

    HttpResponseMessage respuesta = await cliente.GetAsync(url);

    if (!respuesta.IsSuccessStatusCode)
    {
        return ids;
    }

    string json = await respuesta.Content.ReadAsStringAsync();

    using JsonDocument documento = JsonDocument.Parse(json);

    JsonElement peliculas = documento.RootElement.GetProperty("results");

    foreach (JsonElement pelicula in peliculas.EnumerateArray())
    {
        int id = pelicula.GetProperty("id").GetInt32();

        ids.Add(id);
    }

    return ids;
}

public async Task<string> ImportarPagina(int pagina)
{
    if (pagina < 1 || pagina > 40)
    {
        return "La página debe estar entre 1 y 40.";
    }

    List<int> ids = await ObtenerIdsPeliculas(pagina);

    int importadas = 0;
    int omitidas = 0;
    int errores = 0;

    foreach (int id in ids)
    {
        try
        {
            string resultado = await ImportarPelicula(id);

            if (resultado.StartsWith("Película importada correctamente"))
            {
                importadas++;
            }
            else
            {
                omitidas++;
            }
        }
        catch (Exception)
        {
            errores++;
        }

        // Esperar entre consultas para no saturar las API.
        await Task.Delay(1500);
    }

    return "Página " + pagina
         + " | Importadas: " + importadas
         + " | Omitidas: " + omitidas
         + " | Errores: " + errores;
}

    }
}
