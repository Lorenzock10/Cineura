using System.Diagnostics;
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

        public HomeController(
            ILogger<HomeController> logger,
            BuscadorIA buscadorIA)
        {
            _logger = logger;
            _buscadorIA = buscadorIA;
        }

        public IActionResult Index()
        {
            BD bd = new BD();
            List<Peliculas> peliculas = bd.ObtenerPeliculasTendencia();
            ViewBag.PeliculasTendencia = peliculas;

            ViewBag.IdDune = BuscarId(peliculas, "Dune: Part Two");
            ViewBag.IdPoorThings = BuscarId(peliculas, "Poor Things");
            ViewBag.IdSubstance = BuscarId(peliculas, "The Substance");
            ViewBag.IdAnatomy = BuscarId(peliculas, "Anatomy of a Fall");

            string usuario = HttpContext.Session.GetString("usuario");

            ViewBag.EsFavoritoDune = false;
            ViewBag.EstaEnWatchlistDune = false;

            ViewBag.EsFavoritoPoorThings = false;
            ViewBag.EstaEnWatchlistPoorThings = false;

            ViewBag.EsFavoritoSubstance = false;
            ViewBag.EstaEnWatchlistSubstance = false;

            ViewBag.EsFavoritoAnatomy = false;
            ViewBag.EstaEnWatchlistAnatomy = false;

            if (!string.IsNullOrEmpty(usuario))
            {
                int idUsuario = bd.ObtenerIdUsuario(usuario);

                if (idUsuario > 0)
                {
                    int idDune = ViewBag.IdDune;
                    int idPoorThings = ViewBag.IdPoorThings;
                    int idSubstance = ViewBag.IdSubstance;
                    int idAnatomy = ViewBag.IdAnatomy;

                    if (idDune > 0)
                    {
                        ViewBag.EsFavoritoDune = bd.EsFavorito(idUsuario, idDune);
                        ViewBag.EstaEnWatchlistDune = bd.EstaEnWatchlist(idUsuario, idDune);
                    }

                    if (idPoorThings > 0)
                    {
                        ViewBag.EsFavoritoPoorThings = bd.EsFavorito(idUsuario, idPoorThings);
                        ViewBag.EstaEnWatchlistPoorThings = bd.EstaEnWatchlist(idUsuario, idPoorThings);
                    }

                    if (idSubstance > 0)
                    {
                        ViewBag.EsFavoritoSubstance = bd.EsFavorito(idUsuario, idSubstance);
                        ViewBag.EstaEnWatchlistSubstance = bd.EstaEnWatchlist(idUsuario, idSubstance);
                    }

                    if (idAnatomy > 0)
                    {
                        ViewBag.EsFavoritoAnatomy = bd.EsFavorito(idUsuario, idAnatomy);
                        ViewBag.EstaEnWatchlistAnatomy = bd.EstaEnWatchlist(idUsuario, idAnatomy);
                    }
                }
            }
            return View();
        }

        private int BuscarId(List<Peliculas> peliculas, string titulo)
        {
            foreach (Peliculas pelicula in peliculas)
            {
                if (pelicula.Titulo != null)
                {
                    if (pelicula.Titulo.ToLower() == titulo.ToLower())
                    {
                        return pelicula.IdPelicula;
                    }
                }
            }
            return 0;
        }

        private string Normalizar(string texto)
        {
            return texto.Trim().ToLower();
        }

        private string LimpiarJson(string texto)
        {
            texto = texto.Trim();
            if (texto.StartsWith("```"))
            {
                int inicio = texto.IndexOf('\n');

                if (inicio >= 0)
                {
                    texto = texto.Substring(inicio + 1);
                }
            }
            if (texto.EndsWith("```"))
            {
                texto = texto.Substring(0, texto.Length - 3);
            }
            texto = texto.Trim();
            int inicioJson = texto.IndexOf('{');
            int finalJson = texto.LastIndexOf('}');

            if (inicioJson >= 0 && finalJson > inicioJson)
            {
                texto = texto.Substring(
                    inicioJson,
                    finalJson - inicioJson + 1
                );
            }
            return texto.Trim();
        }

        [HttpPost]
        public IActionResult InterpretarBusqueda(string busqueda)
        {
            if (string.IsNullOrWhiteSpace(busqueda))
            {
                return BadRequest("Escribí qué tipo de película querés ver.");
            }
            string respuesta = _buscadorIA.InterpretarBusqueda(busqueda);
            string json = LimpiarJson(respuesta);
            using (JsonDocument documento = JsonDocument.Parse(json))
            {
            }
            return Content(json, "application/json");
        }

        [HttpPost]
        public IActionResult BuscarPeliculas(string busqueda)
        {
            if (string.IsNullOrWhiteSpace(busqueda))
            {
                return BadRequest("Escribí qué tipo de película querés ver.");
            }

            string respuesta = _buscadorIA.InterpretarBusqueda(busqueda);
            string json = LimpiarJson(respuesta);

            string genero = "";
            string animo = "";
            int duracionMaxima = 0;
            bool tieneDuracion = false;

            using (JsonDocument documento = JsonDocument.Parse(json))
            {
                JsonElement datos = documento.RootElement;

                if (datos.TryGetProperty("genero", out JsonElement datoGenero))
                {
                    if (datoGenero.ValueKind == JsonValueKind.String)
                    {
                        genero = datoGenero.GetString();
                    }
                }

                if (datos.TryGetProperty("animo", out JsonElement datoAnimo))
                {
                    if (datoAnimo.ValueKind == JsonValueKind.String)
                    {
                        animo = datoAnimo.GetString();
                    }
                }

                if (datos.TryGetProperty("duracionMaxima", out JsonElement datoDuracion))
                {
                    if (datoDuracion.ValueKind == JsonValueKind.Number)
                    {
                        duracionMaxima = datoDuracion.GetInt32();
                        tieneDuracion = true;
                    }
                }
            }

            if (string.IsNullOrWhiteSpace(genero) &&
                string.IsNullOrWhiteSpace(animo) &&
                !tieneDuracion)
            {
                return Json(new List<object>());
            }
            BD bd = new BD();
            List<Peliculas> peliculas = bd.ObtenerPeliculas();
            List<Peliculas> peliculasFiltradas = new List<Peliculas>();

            foreach (Peliculas pelicula in peliculas)
            {
                bool coincide = true;

                if (!string.IsNullOrWhiteSpace(genero))
                {
                    if (string.IsNullOrWhiteSpace(pelicula.Genero))
                    {
                        coincide = false;
                    }
                    else
                    {
                        if (!Normalizar(pelicula.Genero).Contains(Normalizar(genero)))
                        {
                            coincide = false;
                        }
                    }
                }

                if (tieneDuracion)
                {
                    if (duracionMaxima <= 0)
                    {
                        coincide = false;
                    }
                    else
                    {
                        if (pelicula.DuracionMinutos <= 0 ||
                            pelicula.DuracionMinutos > duracionMaxima)
                        {
                            coincide = false;
                        }
                    }
                }

                if (!string.IsNullOrWhiteSpace(animo))
                {
                    if (string.IsNullOrWhiteSpace(pelicula.Animo))
                    {
                        coincide = false;
                    }
                    else
                    {
                        string animoPelicula = Normalizar(pelicula.Animo);
                        string animoBuscado = Normalizar(animo);

                        if (!animoPelicula.Contains(animoBuscado) &&
                            !animoBuscado.Contains(animoPelicula))
                        {
                            coincide = false;
                        }
                    }
                }

                if (coincide)
                {
                    peliculasFiltradas.Add(pelicula);
                }
            }

            List<object> resultados = new List<object>();
            foreach (Peliculas pelicula in peliculasFiltradas)
            {
                string poster = "";
                if (pelicula.PosterUrl != null)
                {
                    poster = pelicula.PosterUrl;
                }
                object resultado = new
                {
                    idPelicula = pelicula.IdPelicula,
                    titulo = pelicula.Titulo,
                    sinopsis = pelicula.Sinopsis,
                    genero = pelicula.Genero,
                    animo = pelicula.Animo,
                    duracionMinutos = pelicula.DuracionMinutos,
                    anio = pelicula.Anio,
                    posterUrl = poster
                };

                resultados.Add(resultado);
            }
            return Json(resultados);
        }

        public IActionResult Detalles(int id)
        {
            BD bd = new BD();
            Peliculas pelicula = bd.ObtenerPeliculaPorId(id);
            if (pelicula == null)
            {
                return RedirectToAction("Index");
            }
            ViewBag.Director = "No disponible";
            ViewBag.IdUsuario = 0;

            if (pelicula.IdDirector > 0)
            {
                ViewBag.Director = bd.ObtenerNombreDirector(pelicula.IdDirector);
            }
            ViewBag.Actores = bd.ObtenerActores(id);
            ViewBag.Comentarios = bd.ObtenerComentarios(id);

            foreach (Comentarios comentario in ViewBag.Comentarios)
            {
                comentario.NombreUsuario = bd.ObtenerNombreUsuario(comentario.IdUsuario);
            }
            ViewBag.PromedioPuntuacion = bd.ObtenerPromedioPuntuacion(id);
            string usuario = HttpContext.Session.GetString("usuario");
            ViewBag.UsuarioConectado = false;
            ViewBag.EsFavorito = false;
            ViewBag.EstaEnWatchlist = false;
            ViewBag.MiPuntuacion = 0;
            if (!string.IsNullOrEmpty(usuario))
            {
                ViewBag.UsuarioConectado = true;
                int idUsuario = bd.ObtenerIdUsuario(usuario);
                ViewBag.IdUsuario = idUsuario;
                ViewBag.EsFavorito = bd.EsFavorito(idUsuario, id);
                ViewBag.EstaEnWatchlist = bd.EstaEnWatchlist(idUsuario, id);
                ViewBag.MiPuntuacion = bd.ObtenerPuntuacionUsuario(idUsuario, id);
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
            {
                return RedirectToAction("Login");
            }

            if (bd.EsFavorito(idUsuario, idPelicula))
            {
                TempData["Mensaje"] = "Esta película ya está en Favoritas.";
            }
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
            {
                return RedirectToAction("Login");
            }
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

        private IActionResult VolverA(string returnUrl, string accionPredeterminada)
        {
            if (!string.IsNullOrWhiteSpace(returnUrl))
            {
                if (Url.IsLocalUrl(returnUrl))
                {
                    return Redirect(returnUrl);
                }
            }
            return RedirectToAction(accionPredeterminada);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(
            Duration = 0,
            Location = ResponseCacheLocation.None,
            NoStore = true)]
        public IActionResult Error()
        {
            ErrorViewModel modelo = new ErrorViewModel();
            if (Activity.Current != null)
            {
                modelo.RequestId = Activity.Current.Id;
            }
            else
            {
                modelo.RequestId = HttpContext.TraceIdentifier;
            }
            return View(modelo);
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
            Usuarios nuevoUsuario = new Usuarios();
            nuevoUsuario.Nombre = nombre;
            nuevoUsuario.Apellido = apellido;
            nuevoUsuario.NombreUsuario = usuario;
            nuevoUsuario.Contraseña = contrasena;
            bd.AgregarUsuario(nuevoUsuario);
            return RedirectToAction("Login");
        }

        public IActionResult CerrarSesion()
        {
            HttpContext.Session.Clear();

            return RedirectToAction("Index");
        }

        [HttpPost]
        public IActionResult ToggleFavorito(int idPelicula)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return Json(new
                {
                    ok = false,
                    redirectUrl = "/Home/Login",
                    message = "Iniciá sesión para guardar películas en Favoritas."
                });
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return Json(new
                {
                    ok = false,
                    redirectUrl = "/Home/Login",
                    message = "Sesión inválida."
                });
            }
            bool estabaAgregado = bd.EsFavorito(idUsuario, idPelicula);
            if (estabaAgregado)
            {
                bd.QuitarFavorito(idUsuario, idPelicula);
            }
            else
            {
                bd.AgregarFavorito(idUsuario, idPelicula);
            }
            bool nuevoEstado = !estabaAgregado;
            return Json(new
            {
                ok = true,
                esFavorito = nuevoEstado,
                message = nuevoEstado ? "Añadida a Favoritas." : "Quitada de Favoritas."
            });
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
            if (idUsuario == 0)
            {
                return Json(new
                {
                    ok = false,
                    redirectUrl = "/Home/Login",
                    message = "Sesión inválida."
                });
            }
            bool estabaAgregado = bd.EstaEnWatchlist(idUsuario, idPelicula);
            if (estabaAgregado)
            {
                bd.QuitarWatchlist(idUsuario, idPelicula);
            }
            else
            {
                bd.AgregarWatchlist(idUsuario, idPelicula);
            }
            bool nuevoEstado = !estabaAgregado;
            return Json(new
            {
                ok = true,
                estaEnWatchlist = nuevoEstado,
                message = nuevoEstado ? "Añadida a Watchlist." : "Quitada de Watchlist."
            });
        }

        [HttpPost]
        public IActionResult AgregarComentario(int idPelicula, string texto)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return RedirectToAction("Login");
            }
            if (string.IsNullOrWhiteSpace(texto) || texto.Length > 1000)
            {
                return RedirectToAction("Detalles", new { id = idPelicula });
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return RedirectToAction("Login");
            }
            bd.AgregarComentario(idUsuario, idPelicula, texto.Trim());
            return RedirectToAction("Detalles", new { id = idPelicula });
        }

        [HttpPost]
        public IActionResult EditarComentario(int idComentario, int idPelicula, string texto)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return RedirectToAction("Login");
            }
            if (string.IsNullOrWhiteSpace(texto) || texto.Length > 1000)
            {
                return RedirectToAction("Detalles", new { id = idPelicula });
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return RedirectToAction("Login");
            }
            bd.EditarComentario(idComentario, idUsuario, texto.Trim());
            return RedirectToAction("Detalles", new { id = idPelicula });
        }
        [HttpPost]
        public IActionResult EliminarComentario(int idComentario, int idPelicula)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return RedirectToAction("Login");
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return RedirectToAction("Login");
            }
            bd.EliminarComentario(idComentario, idUsuario);
            return RedirectToAction("Detalles", new { id = idPelicula });
        }

        [HttpPost]
        public IActionResult GuardarPuntuacion(int idPelicula, int puntuacion)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return RedirectToAction("Login");
            }
            if (puntuacion < 1 || puntuacion > 5)
            {
                return RedirectToAction("Detalles", new { id = idPelicula });
            }
            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return RedirectToAction("Login");
            }
            bd.GuardarPuntuacion(idUsuario, idPelicula, puntuacion);
            return RedirectToAction("Detalles", new { id = idPelicula });
        }
    }
}