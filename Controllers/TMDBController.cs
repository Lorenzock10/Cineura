
using Microsoft.AspNetCore.Mvc;
using Cineura.Services;
using System.Net;

namespace Cineura.Controllers
{
    public class TMDBController : Controller
    {
        public IActionResult Index()
        {
            IPAddress direccion = HttpContext.Connection.RemoteIpAddress;

            if (direccion == null || !IPAddress.IsLoopback(direccion))
            {
                return Forbid();
            }

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Importar(int idTMDB)
        {
            IPAddress direccion = HttpContext.Connection.RemoteIpAddress;

            if (direccion == null || !IPAddress.IsLoopback(direccion))
            {
                return Forbid();
            }

            TMDBService tmdb = new TMDBService();

            string resultado = await tmdb.ImportarPelicula(idTMDB);

            return Content(resultado, "text/plain; charset=utf-8");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ImportarPagina(int pagina)
        {
            IPAddress direccion = HttpContext.Connection.RemoteIpAddress;

            if (direccion == null || !IPAddress.IsLoopback(direccion))
            {
                return Forbid();
            }

            if (pagina < 1 || pagina > 40)
            {
                return BadRequest("La página debe estar entre 1 y 40.");
            }

            TMDBService tmdb = new TMDBService();

            string resultado = await tmdb.ImportarPagina(pagina);

            return Content(resultado, "text/plain; charset=utf-8");
        }
    }
}
