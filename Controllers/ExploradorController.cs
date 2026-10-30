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
            string ordenar = "")
        {
            BD bd = new BD();

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

            // Buscar una coincidencia exacta del título.
            if (busqueda != null && busqueda.Trim() != "" &&
                (genero == null || genero == "") &&
                !anio.HasValue &&
                !duracionMaxima.HasValue)
            {
                string tituloBuscado = busqueda.Trim().ToLower();

                foreach (Peliculas pelicula in peliculas)
                {
                    if (pelicula.Titulo != null)
                    {
                        string tituloPelicula = pelicula.Titulo.Trim().ToLower();

                        if (tituloPelicula == tituloBuscado)
                        {
                            return RedirectToAction(
                                "Detalles",
                                "Home",
                                new { id = pelicula.IdPelicula }
                            );
                        }
                    }
                }
            }

            // Ordenar las películas.
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

            return View("../Home/Explorador", peliculasEncontradas);
        }
    }
}