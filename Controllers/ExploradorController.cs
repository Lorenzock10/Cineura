using Microsoft.AspNetCore.Mvc;
using Cineura.Models;
using System.Collections.Generic;

namespace Cineura.Controllers
{
    public class ExploradorController : Controller
    {
        public IActionResult Index(
            string busqueda,
            string genero,
            int? anio,
            int? duracionMaxima,
            string ordenar = "")
        {
            BD bd = new BD();
            bool esFetch = Request.Headers["X-Requested-With"] == "XMLHttpRequest";
            List<Peliculas> peliculas = bd.ObtenerPeliculas();
            List<Peliculas> peliculasEncontradas = new List<Peliculas>();

            foreach (Peliculas pelicula in peliculas)
            {
                bool coincide = true;

                if (busqueda != null && busqueda != "")
                {
                    if (pelicula.Titulo == null ||
                        !pelicula.Titulo.ToLower().Contains(busqueda.Trim().ToLower()))
                    {
                        coincide = false;
                    }
                }

                if (genero != null && genero != "")
                {
                    if (pelicula.Genero == null ||
                        !pelicula.Genero.ToLower().Contains(genero.ToLower()))
                    {
                        coincide = false;
                    }
                }

                if (anio.HasValue)
                {
                    if (pelicula.Anio != anio.Value)
                    {
                        coincide = false;
                    }
                }

                if (duracionMaxima.HasValue)
                {
                    if (pelicula.DuracionMinutos > duracionMaxima.Value)
                    {
                        coincide = false;
                    }
                }

                if (coincide)
                {
                    peliculasEncontradas.Add(pelicula);
                }
            }

            // Si se escribe un título exacto sin otros filtros, abrir sus detalles.
            if (busqueda != null && busqueda.Trim() != "" &&
                (genero == null || genero == "") &&
                !anio.HasValue && !duracionMaxima.HasValue)
            {
                string tituloBuscado = busqueda.Trim().ToLower();

                foreach (Peliculas pelicula in peliculas)
                {
                    if (pelicula.Titulo != null)
                    {
                        string tituloPelicula = pelicula.Titulo.Trim().ToLower();

                        if (tituloPelicula == tituloBuscado)
                        {
                            if (esFetch)
                            {
                                return Json(new
                                {
                                    redirectUrl = Url.Action(
                                        "Detalles", "Home", new { id = pelicula.IdPelicula })
                                });
                            }

                            return RedirectToAction(
                                "Detalles", "Home", new { id = pelicula.IdPelicula });
                        }
                    }
                }
            }

            // Ordenar con ciclos for, sin LINQ.
            for (int i = 0; i < peliculasEncontradas.Count - 1; i++)
            {
                for (int j = i + 1; j < peliculasEncontradas.Count; j++)
                {
                    bool intercambiar = false;

                    if (ordenar == "anio")
                    {
                        if (peliculasEncontradas[i].Anio < peliculasEncontradas[j].Anio)
                        {
                            intercambiar = true;
                        }
                    }
                    else
                    {
                        string titulo1 = peliculasEncontradas[i].Titulo ?? "";
                        string titulo2 = peliculasEncontradas[j].Titulo ?? "";

                        if (string.Compare(titulo1, titulo2, System.StringComparison.CurrentCulture) > 0)
                        {
                            intercambiar = true;
                        }
                    }

                    if (intercambiar)
                    {
                        Peliculas auxiliar = peliculasEncontradas[i];
                        peliculasEncontradas[i] = peliculasEncontradas[j];
                        peliculasEncontradas[j] = auxiliar;
                    }
                }
            }

            ViewBag.Busqueda = busqueda;
            ViewBag.Genero = genero;
            ViewBag.Anio = anio;
            ViewBag.DuracionMaxima = duracionMaxima;
            ViewBag.Ordenar = ordenar;

            List<int> idsFavoritos = new List<int>();
            List<int> idsWatchlist = new List<int>();

            string usuario = HttpContext.Session.GetString("usuario");

            if (!string.IsNullOrEmpty(usuario))
            {
                int idUsuario = bd.ObtenerIdUsuario(usuario);

                if (idUsuario > 0)
                {
                    foreach (Peliculas pelicula in peliculasEncontradas)
                    {
                        if (bd.EsFavorito(idUsuario, pelicula.IdPelicula))
                        {
                            idsFavoritos.Add(pelicula.IdPelicula);
                        }

                        if (bd.EstaEnWatchlist(idUsuario, pelicula.IdPelicula))
                        {
                            idsWatchlist.Add(pelicula.IdPelicula);
                        }
                    }
                }
            }

            ViewBag.IdsFavoritos = idsFavoritos;
            ViewBag.IdsWatchlist = idsWatchlist;

            if (esFetch)
            {
                return PartialView("_ResultadosExplorador", peliculasEncontradas);
            }

            return View("../Home/Explorador", peliculasEncontradas);
        }
    }
}
