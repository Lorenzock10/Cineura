
using Cineura.Models;
using Microsoft.AspNetCore.Mvc;

namespace Cineura.Controllers
{
    public class WatchlistController : Controller
    {
        public IActionResult Index()
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para ver tu Watchlist.";
                return RedirectToAction("Login", "Home");
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            List<Peliculas> peliculas = bd.ObtenerWatchlist(idUsuario);
            return View("~/Views/Home/Watchlist.cshtml", peliculas);
        }

        public IActionResult Watchlist()
        {
            return Index();
        }

        [HttpPost]
        public IActionResult AgregarWatchlist(int idPelicula)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para guardar películas.";
                return RedirectToAction("Login", "Home");
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario <= 0)
            {
                return RedirectToAction("Login", "Home");
            }

            if (bd.EstaEnWatchlist(idUsuario, idPelicula))
            {
                TempData["Mensaje"] = "Esta película ya está en tu Watchlist.";
            }
            else
            {
                bd.AgregarWatchlist(idUsuario, idPelicula);
                TempData["Mensaje"] = "Película agregada a tu Watchlist.";
            }
            return RedirectToAction("Detalles", "Home", new { id = idPelicula });
        }

        [HttpPost]
        public IActionResult QuitarWatchlist(int idPelicula)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para modificar tu Watchlist.";
                return RedirectToAction("Login", "Home");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario <= 0)
            {
                return RedirectToAction("Login", "Home");
            }
            bd.QuitarWatchlist(idUsuario, idPelicula);
            TempData["Mensaje"] = "Película quitada de tu Watchlist.";
            return RedirectToAction("Detalles", "Home", new { id = idPelicula });
        }

        [HttpPost]
        public IActionResult ToggleWatchlist(int idPelicula)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return Json(new
                {
                    ok = false,
                    redirectUrl = "/Home/Login",
                    message = "Iniciá sesión para guardar películas en tu Watchlist."
                });
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario <= 0)
            {
                return Json(new
                {
                    ok = false,
                    redirectUrl = "/Home/Login",
                    message = "Sesión inválida."
                });
            }

            bool estaAgregada = bd.EstaEnWatchlist(idUsuario, idPelicula);

            if (estaAgregada)
            {
                bd.QuitarWatchlist(idUsuario, idPelicula);
            }
            else
            {
                bd.AgregarWatchlist(idUsuario, idPelicula);
            }

            return Json(new
            {
                ok = true,
                estaEnWatchlist = !estaAgregada,
                message = estaAgregada ? "Quitada de Watchlist." : "Añadida a Watchlist."
            });
        }
    }
}
