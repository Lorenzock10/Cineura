
using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Cineura.Models;
using Cineura.Services;

namespace Cineura.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly BuscadorIA _buscadorIA;

        public HomeController(ILogger<HomeController> logger, BuscadorIA buscadorIA)
        {
            _logger = logger;
            _buscadorIA = buscadorIA;
        }

        public IActionResult Index()
        {
            BD bd = new BD();
            List<Peliculas> peliculas = bd.ObtenerPeliculas();

            ViewBag.IdDune = BuscarId(peliculas, "Dune: Part Two");
            ViewBag.IdPoorThings = BuscarId(peliculas, "Poor Things");
            ViewBag.IdSubstance = BuscarId(peliculas, "The Substance");
            ViewBag.IdAnatomy = BuscarId(peliculas, "Anatomy of a Fall");

            return View();
        }

        private int BuscarId(List<Peliculas> peliculas, string titulo)
        {
            Peliculas pelicula = peliculas.FirstOrDefault(p =>
                string.Equals(p.Titulo, titulo, StringComparison.OrdinalIgnoreCase));

            return pelicula?.IdPelicula ?? 0;
        }

        private string Normalizar(string texto)
        {
            string normalizado = texto.ToLower().Trim()
                .Normalize(NormalizationForm.FormD);

            StringBuilder resultado = new StringBuilder();

            foreach (char caracter in normalizado)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(caracter)
                    != UnicodeCategory.NonSpacingMark)
                {
                    resultado.Append(caracter);
                }
            }

            return resultado.ToString().Normalize(NormalizationForm.FormC);
        }

        private string LimpiarJson(string texto)
        {
            texto = texto.Trim();

            if (texto.StartsWith("```"))
            {
                int inicio = texto.IndexOf('\n');

                if (inicio >= 0)
                    texto = texto.Substring(inicio + 1);
            }

            if (texto.EndsWith("```"))
                texto = texto.Substring(0, texto.Length - 3);

            texto = texto.Trim();

            int inicioJson = texto.IndexOf('{');
            int finalJson = texto.LastIndexOf('}');

            if (inicioJson >= 0 && finalJson > inicioJson)
                texto = texto.Substring(inicioJson, finalJson - inicioJson + 1);

            return texto.Trim();
        }

        [HttpPost]
        public async Task<IActionResult> InterpretarBusqueda(string busqueda)
        {
            if (string.IsNullOrWhiteSpace(busqueda))
                return BadRequest("Escribí qué tipo de película querés ver.");

            try
            {
                string respuesta = await _buscadorIA.InterpretarBusquedaAsync(busqueda);
                string json = LimpiarJson(respuesta);

                using JsonDocument documento = JsonDocument.Parse(json);

                return Content(json, "application/json");
            }
            catch (JsonException)
            {
                return StatusCode(502, "Nova no devolvió una respuesta válida.");
            }
            catch (Exception error)
            {
                _logger.LogError(error, "Error al interpretar la búsqueda con IA.");
                return StatusCode(500, "No pudimos comunicarnos con Nova.");
            }
        }

        [HttpPost]
        public async Task<IActionResult> BuscarPeliculas(string busqueda)
        {
            if (string.IsNullOrWhiteSpace(busqueda))
                return BadRequest("Escribí qué película querés ver.");

            try
            {
                string respuesta = await _buscadorIA.InterpretarBusquedaAsync(busqueda);
                string json = LimpiarJson(respuesta);

                FiltrosBusqueda filtros =
                    JsonSerializer.Deserialize<FiltrosBusqueda>(
                        json,
                        new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });

                if (filtros == null)
                    return StatusCode(502, "Nova no pudo interpretar la búsqueda.");

                BD bd = new BD();
                List<Peliculas> peliculas = bd.ObtenerPeliculas();

                if (!string.IsNullOrWhiteSpace(filtros.Genero))
                {
                    string genero = Normalizar(filtros.Genero);

                    peliculas = peliculas.Where(p =>
                        !string.IsNullOrWhiteSpace(p.Genero) &&
                        Normalizar(p.Genero).Contains(genero)).ToList();
                }

                if (filtros.DuracionMaxima.HasValue)
                {
                    peliculas = peliculas.Where(p =>
                        p.DuracionMinutos <= filtros.DuracionMaxima.Value).ToList();
                }

                if (!string.IsNullOrWhiteSpace(filtros.Animo))
                {
                    string animo = Normalizar(filtros.Animo);

                    peliculas = peliculas.Where(p =>
                        !string.IsNullOrWhiteSpace(p.Animo) &&
                        Normalizar(p.Animo).Contains(animo)).ToList();
                }

                var resultados = peliculas.Select(p => new
                {
                    idPelicula = p.IdPelicula,
                    titulo = p.Titulo,
                    sinopsis = p.Sinopsis,
                    genero = p.Genero,
                    animo = p.Animo,
                    duracionMinutos = p.DuracionMinutos,
                    anio = p.Anio,
                    posterUrl = p.PosterUrl ?? ""
                });

                return Json(resultados);
            }
            catch (JsonException error)
            {
                _logger.LogError(error, "Nova devolvió un JSON incorrecto.");
                return StatusCode(502, "Nova no devolvió los filtros correctamente.");
            }
            catch (Exception error)
            {
                _logger.LogError(error, "Error al buscar películas con Nova.");
                return StatusCode(500, "Ocurrió un error al buscar películas.");
            }
        }

        public IActionResult Detalles(int id)
        {
            BD bd = new BD();
            Peliculas pelicula = bd.ObtenerPeliculaPorId(id);

            if (pelicula == null)
                return NotFound();

            ViewBag.Director = pelicula.IdDirector > 0
                ? bd.ObtenerNombreDirector(pelicula.IdDirector)
                : "No disponible";

            ViewBag.Actores = bd.ObtenerActores(id);

            string usuario = HttpContext.Session.GetString("usuario");

            ViewBag.UsuarioConectado = !string.IsNullOrEmpty(usuario);
            ViewBag.EsFavorito = false;
            ViewBag.EstaEnWatchlist = false;

            if (!string.IsNullOrEmpty(usuario))
            {
                int idUsuario = bd.ObtenerIdUsuario(usuario);

                ViewBag.EsFavorito = bd.EsFavorito(idUsuario, id);
                ViewBag.EstaEnWatchlist = bd.EstaEnWatchlist(idUsuario, id);
            }

            return View(pelicula);
        }

        [HttpPost]
        public IActionResult AgregarFavorito(int idPelicula, string returnUrl = "")
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para guardar películas en Favoritas.";
                return RedirectToAction("Login");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            if (idUsuario == 0)
                return RedirectToAction("Login");

            if (bd.EsFavorito(idUsuario, idPelicula))
                TempData["Mensaje"] = "Esta película ya está en Favoritas.";
            else
            {
                bd.AgregarFavorito(idUsuario, idPelicula);
                TempData["Mensaje"] = "¡Película agregada a Favoritas!";
            }

            return VolverA(returnUrl, "Index");
        }

        [HttpPost]
        public IActionResult QuitarFavorito(int idPelicula, string returnUrl = "")
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
                return RedirectToAction("Login");

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            bd.QuitarFavorito(idUsuario, idPelicula);

            TempData["Mensaje"] = "Película quitada de Favoritas.";

            return VolverA(returnUrl, "Favoritas");
        }

        public IActionResult Favoritas()
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para ver tus Favoritas.";
                return RedirectToAction("Login");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            return View(bd.ObtenerFavoritos(idUsuario));
        }

        [HttpPost]
        public IActionResult AgregarWatchlist(int idPelicula, string returnUrl = "")
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para guardar películas en tu Watchlist.";
                return RedirectToAction("Login");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            if (idUsuario == 0)
                return RedirectToAction("Login");

            if (bd.EstaEnWatchlist(idUsuario, idPelicula))
                TempData["Mensaje"] = "Esta película ya está en tu Watchlist.";
            else
            {
                bd.AgregarWatchlist(idUsuario, idPelicula);
                TempData["Mensaje"] = "¡Película agregada a tu Watchlist!";
            }

            return VolverA(returnUrl, "Index");
        }

        [HttpPost]
        public IActionResult QuitarWatchlist(int idPelicula, string returnUrl = "")
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
                return RedirectToAction("Login");

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            bd.QuitarWatchlist(idUsuario, idPelicula);

            TempData["Mensaje"] = "Película quitada de tu Watchlist.";

            return VolverA(returnUrl, "Watchlist");
        }

        public IActionResult Watchlist()
        {
            string usuario = HttpContext.Session.GetString("usuario");

            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para ver tu Watchlist.";
                return RedirectToAction("Login");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            return View(bd.ObtenerWatchlist(idUsuario));
        }

        private IActionResult VolverA(string returnUrl, string accionPredeterminada)
        {
            if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
                return Redirect(returnUrl);

            return RedirectToAction(accionPredeterminada);
        }

        public class FiltrosBusqueda
        {
            public string Genero { get; set; }
            public string Animo { get; set; }
            public int? DuracionMaxima { get; set; }
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel
            {
                RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier
            });
        }

        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Login(string usuario, string contrasena)
        {
            if (usuario == null || usuario.Length < 4 ||
                contrasena == null || contrasena.Length < 6)
            {
                ViewBag.Error = "El usuario debe tener al menos 4 caracteres y la contraseña 6.";
                return View();
            }

            BD bd = new BD();
            Usuarios usuarioEncontrado = bd.ObtenerUsuario(usuario, contrasena);

            if (usuarioEncontrado == null)
            {
                ViewBag.Error = "Usuario o contraseña incorrectos.";
                return View();
            }

            HttpContext.Session.SetString("usuario", usuarioEncontrado.NombreUsuario);
            HttpContext.Session.SetString("nombre", usuarioEncontrado.Nombre);
            HttpContext.Session.SetString("apellido", usuarioEncontrado.Apellido);

            return RedirectToAction("Index");
        }

        public IActionResult Registrarse()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Registrarse(
            string nombre,
            string apellido,
            string usuario,
            string contrasena)
        {
            if (nombre == null || nombre.Length < 2 ||
                apellido == null || apellido.Length < 2 ||
                usuario == null || usuario.Length < 4 ||
                contrasena == null || contrasena.Length < 6)
            {
                ViewBag.Error = "Completá los campos correctamente: nombre y apellido de al menos 2 caracteres, usuario de 4 y contraseña de 6.";
                return View();
            }

            BD bd = new BD();
            Usuarios usuarioExistente = bd.ObtenerUsuarioPorNombre(usuario);

            if (usuarioExistente != null)
            {
                ViewBag.Error = "Ese nombre de usuario ya existe.";
                return View();
            }

            Usuarios nuevoUsuario = new Usuarios
            {
                Nombre = nombre,
                Apellido = apellido,
                NombreUsuario = usuario,
                Contraseña = contrasena
            };

            bd.AgregarUsuario(nuevoUsuario);

            return RedirectToAction("Login");
        }

        public IActionResult CerrarSesion()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Index");
        }
    }
}
