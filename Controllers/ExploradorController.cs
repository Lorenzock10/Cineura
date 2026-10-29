
using Microsoft.AspNetCore.Mvc;
using Cineura.Models;
using System.Collections.Generic;
using System.Linq;

namespace Cineura.Controllers
{
    public class ExploradorController : Controller
    {
        public IActionResult Index(
            string busqueda,
            string genero,
            int? anio,
            int? duracionMaxima,
            string ordenar)
        {
            BD bd = new BD();

            List<Peliculas> peliculas = bd.ObtenerPeliculas();
            List<Peliculas> peliculasEncontradas = new List<Peliculas>();

            foreach (Peliculas pelicula in peliculas)
            {
                bool coincide = true;

                if (!string.IsNullOrWhiteSpace(busqueda))
                {
                    if (pelicula.Titulo == null ||
                        !pelicula.Titulo.Contains(
                            busqueda,
                            System.StringComparison.OrdinalIgnoreCase))
                    {
                        coincide = false;
                    }
                }

                if (!string.IsNullOrWhiteSpace(genero))
                {
                    if (pelicula.Genero == null ||
                        !pelicula.Genero.Contains(
                            genero,
                            System.StringComparison.OrdinalIgnoreCase))
                    {
                        coincide = false;
                    }
                }

                if (anio.HasValue && pelicula.Anio != anio.Value)
                {
                    coincide = false;
                }

                if (duracionMaxima.HasValue &&
                    pelicula.DuracionMinutos > duracionMaxima.Value)
                {
                    coincide = false;
                }

                if (coincide)
                {
                    peliculasEncontradas.Add(pelicula);
                }
            }

            // Si el título coincide exactamente y no hay otros filtros,
            // abrir directamente la ficha de la película.
            if (!string.IsNullOrWhiteSpace(busqueda) &&
                string.IsNullOrWhiteSpace(genero) &&
                !anio.HasValue &&
                !duracionMaxima.HasValue)
            {
                Peliculas peliculaExacta = peliculasEncontradas
                    .FirstOrDefault(pelicula =>
                        pelicula.Titulo != null &&
                        pelicula.Titulo.Equals(
                            busqueda.Trim(),
                            System.StringComparison.OrdinalIgnoreCase));

                if (peliculaExacta != null)
                {
                    return RedirectToAction(
                        "Detalles",
                        "Home",
                        new { id = peliculaExacta.IdPelicula });
                }
            }

            if (ordenar == "anio")
            {
                peliculasEncontradas = peliculasEncontradas
                    .OrderByDescending(pelicula => pelicula.Anio)
                    .ToList();
            }
            else
            {
                peliculasEncontradas = peliculasEncontradas
                    .OrderBy(pelicula => pelicula.Titulo)
                    .ToList();
            }

            ViewBag.Busqueda = busqueda;
            ViewBag.Genero = genero;
            ViewBag.Anio = anio;
            ViewBag.DuracionMaxima = duracionMaxima;
            ViewBag.Ordenar = ordenar;

            return View(
                "~/Views/Home/Explorador.cshtml",
                peliculasEncontradas);
        }
    }
}
