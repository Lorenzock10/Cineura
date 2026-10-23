
using Cineura.Models;
using Microsoft.AspNetCore.Mvc;

namespace Cineura.Controllers
{
    public class WatchlistController : Controller
    {
        public IActionResult Index()
        {
            string nombreUsuario =
                HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(nombreUsuario))
            {
                TempData["Mensaje"] =
                    "Iniciá sesión para ver tu Watchlist.";

                return RedirectToAction("Login", "Home");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

            List<Peliculas> peliculas =
                bd.ObtenerWatchlist(idUsuario);

            return View("~/Views/Home/Watchlist.cshtml", peliculas);
        }

        public IActionResult Watchlist()
        {
            return Index();
        }

        [HttpPost]
        public IActionResult AgregarWatchlist(int idPelicula)
        {
            string nombreUsuario =
                HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(nombreUsuario))
            {
                TempData["Mensaje"] =
                    "Iniciá sesión para guardar películas en tu Watchlist.";

                return RedirectToAction("Login", "Home");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

            if (idUsuario <= 0)
            {
                return RedirectToAction("Login", "Home");
            }

            if (!bd.EstaEnWatchlist(idUsuario, idPelicula))
            {
                bd.AgregarWatchlist(idUsuario, idPelicula);
                TempData["Mensaje"] =
                    "Película agregada a tu Watchlist.";
            }
            else
            {
                TempData["Mensaje"] =
                    "Esta película ya está en tu Watchlist.";
            }

            return RedirectToAction(
                "Detalles",
                "Home",
                new { id = idPelicula });
        }

        [HttpPost]
        public IActionResult QuitarWatchlist(int idPelicula)
        {
            string nombreUsuario =
                HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(nombreUsuario))
            {
                TempData["Mensaje"] =
                    "Iniciá sesión para modificar tu Watchlist.";

                return RedirectToAction("Login", "Home");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

            if (idUsuario <= 0)
            {
                return RedirectToAction("Login", "Home");
            }

            bd.QuitarWatchlist(idUsuario, idPelicula);

            TempData["Mensaje"] =
                "Película quitada de tu Watchlist.";

            return RedirectToAction(
                "Detalles",
                "Home",
                new { id = idPelicula });
        }
    }
}
