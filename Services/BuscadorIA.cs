using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Linq;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public string InterpretarBusqueda(
            string busqueda,
            List<string> tematicas,
            List<string> emociones)
        {
            string apiKey = Environment.GetEnvironmentVariable("GROQ_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
                throw new Exception("No se encontró GROQ_API_KEY.");

            string prompt = $@"
Sos Nova, el recomendador de películas de Cineura.

Interpretá lo que quiere ver el usuario.

Respondé únicamente un objeto JSON con estas propiedades:
- tematica
- emocion
- duracionMaxima

TEMÁTICAS DISPONIBLES:
{string.Join(", ", tematicas)}

EMOCIONES DISPONIBLES:
{string.Join(", ", emociones)}

REGLAS:
1. Elegí únicamente etiquetas de las listas anteriores.
2. Si el usuario menciona un género, elegí su temática equivalente.
3. Si describe un estado de ánimo, elegí su emoción equivalente.
4. Si no menciona temática o emoción, devolvé null en ese campo.
5. Si no menciona duración, devolvé null.
6. Menos de 100 minutos significa un máximo de 99 minutos.
7. Menos de dos horas significa un máximo de 119 minutos.
8. Hasta dos horas significa un máximo de 120 minutos.
9. No inventes preferencias que el usuario no pidió.
10. Si dice animada o dibujos animados, usá Animación.
11. Si dice romántica, usá Romance.
12. Si dice de miedo, usá Terror.
13. Si dice ciencia ficción, usá Ciencia ficción.
14. Copiá exactamente los nombres de las etiquetas disponibles.
15. Si una preferencia no corresponde claramente a ninguna etiqueta,
    devolvé null para esa categoría.

Ejemplo:
{{""tematica"":""Terror"",""emocion"":null,""duracionMaxima"":100}}
";

            using (HttpClient cliente = new HttpClient())
            {
                cliente.Timeout = TimeSpan.FromSeconds(30);

                using (HttpRequestMessage solicitud = new HttpRequestMessage(
                    HttpMethod.Post,
                    "https://api.groq.com/openai/v1/chat/completions"))
                {
                    solicitud.Headers.Authorization =
                        new AuthenticationHeaderValue("Bearer", apiKey);

                    solicitud.Content = JsonContent.Create(new
                    {
                        model = "openai/gpt-oss-120b",
                        messages = new[]
                        {
                            new { role = "system", content = prompt },
                            new { role = "user", content = busqueda }
                        },
                        temperature = 0,
                        response_format = new
                        {
                            type = "json_object"
                        }
                    });

                    using (HttpResponseMessage respuesta =
                        cliente.Send(solicitud))
                    {
                        string texto = respuesta.Content
                            .ReadAsStringAsync().GetAwaiter().GetResult();

                        if (!respuesta.IsSuccessStatusCode)
                            throw new Exception("Error al consultar Groq.");

                        using (JsonDocument documento = JsonDocument.Parse(texto))
                        {
                            string contenido = documento.RootElement
                                .GetProperty("choices")[0]
                                .GetProperty("message")
                                .GetProperty("content")
                                .GetString();

                            if (string.IsNullOrWhiteSpace(contenido))
                                throw new Exception("Nova no devolvió una respuesta válida.");

                            return contenido;
                        }
                    }
                }
            }
        }

        // Conserva compatibilidad con llamadas anteriores.
        public string InterpretarBusqueda(string busqueda)
        {
            var bd = new Cineura.Models.BD();
            var etiquetas = bd.ObtenerTodasLasEtiquetas();

            return InterpretarBusqueda(
                busqueda,
                etiquetas.Where(e => e.Tipo == "Tematica")
                         .Select(e => e.Nombre).ToList(),
                etiquetas.Where(e => e.Tipo == "Emocion")
                         .Select(e => e.Nombre).ToList()
            );
        }
    }
}