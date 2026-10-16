
using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Cineura.Models;
using Cineura.Services;

namespace Cineura.Controllers;

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

    public IActionResult Index()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> InterpretarBusqueda(string busqueda)
    {
        if (string.IsNullOrWhiteSpace(busqueda))
        {
            return BadRequest("Escribí qué tipo de película querés ver.");
        }

        try
        {
            string resultado =
                await _buscadorIA.InterpretarBusquedaAsync(busqueda);

            _logger.LogInformation(
                "Respuesta de Nova: {Respuesta}", resultado);

            string jsonLimpio = LimpiarJson(resultado);

            try
            {
                using JsonDocument documento =
                    JsonDocument.Parse(jsonLimpio);
            }
            catch (JsonException)
            {
                return StatusCode(
                    502,
                    "Nova no devolvió una respuesta válida. Probá de nuevo."
                );
            }

            return Content(jsonLimpio, "application/json");
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex, "Error al interpretar la búsqueda con IA.");

            return StatusCode(
                500,
                "No pudimos comunicarnos con Nova."
            );
        }
    }

    [HttpPost]
    public async Task<IActionResult> BuscarPeliculas(string busqueda)
    {
        if (string.IsNullOrWhiteSpace(busqueda))
        {
            return BadRequest("Escribí qué película querés ver.");
        }

        try
        {
            string respuestaIA =
                await _buscadorIA.InterpretarBusquedaAsync(busqueda);

            _logger.LogInformation(
                "Respuesta de Nova: {Respuesta}", respuestaIA);

            string jsonLimpio = LimpiarJson(respuestaIA);

            FiltrosBusqueda? filtros;

            try
            {
                filtros = JsonSerializer.Deserialize<FiltrosBusqueda>(
                    jsonLimpio,
                    new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    }
                );
            }
            catch (JsonException ex)
            {
                _logger.LogWarning(
                    ex,
                    "Nova devolvió una respuesta que no se pudo convertir a JSON."
                );

                return StatusCode(
                    502,
                    "Nova no devolvió los filtros correctamente. Probá de nuevo."
                );
            }

            if (filtros == null)
            {
                return StatusCode(
                    502,
                    "Nova no pudo interpretar la búsqueda."
                );
            }

            BD bd = new BD();
            List<Peliculas> peliculas = bd.ObtenerPeliculas();

            if (!string.IsNullOrWhiteSpace(filtros.Genero))
            {
                string genero = Normalizar(filtros.Genero);

                peliculas = peliculas.Where(p =>
                    !string.IsNullOrWhiteSpace(p.Genero) &&
                    (
                        Normalizar(p.Genero).Contains(genero) ||
                        genero.Contains(Normalizar(p.Genero))
                    )
                ).ToList();
            }

            if (filtros.DuracionMaxima.HasValue)
            {
                peliculas = peliculas.Where(p =>
                    p.DuracionMinutos <= filtros.DuracionMaxima.Value
                ).ToList();
            }

            if (!string.IsNullOrWhiteSpace(filtros.Animo))
            {
                string animo = Normalizar(filtros.Animo);

                peliculas = peliculas.Where(p =>
                    !string.IsNullOrWhiteSpace(p.Animo) &&
                    (
                        Normalizar(p.Animo).Contains(animo) ||
                        animo.Contains(Normalizar(p.Animo))
                    )
                ).ToList();
            }

            var peliculasConPoster = peliculas.Select(p => new
            {
                idPelicula = p.IdPelicula,
                titulo = p.Titulo,
                sinopsis = p.Sinopsis,
                genero = p.Genero,
                animo = p.Animo,
                duracionMinutos = p.DuracionMinutos,
                anio = p.Anio,

                posterUrl = !string.IsNullOrWhiteSpace(p.PosterUrl)
                    ? p.PosterUrl
                    : p.Titulo switch
                    {
                        "Toy Story" =>
                            "https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg",

                        "Shrek" =>
                            "https://image.tmdb.org/t/p/w500/iB64vpL3dIObOtMZgX3RqdVdQDc.jpg",

                        "The Truman Show" =>
                            "https://image.tmdb.org/t/p/w500/vuza0WqY239yBXOadKlGwJsZJFE.jpg",

                        "En busca de la felicidad" =>
                            "https://image.tmdb.org/t/p/w500/7lZ3h8L4bV6fP4dY8gYxL0fV6w.jpg",

                        "Superbad" =>
                            "https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg",

                        "Coco" =>
                            "https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg",

                        "Intensamente" =>
                            "https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4Tl5A.jpg",

                        "Jumanji" =>
                            "https://image.tmdb.org/t/p/w500/bXrZ5iHBEjH7WMidbUDQ0U2xbmr.jpg",

                        _ => ""
                    }
            });

            return Json(peliculasConPoster);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex, "Error al buscar películas con Nova.");

            return StatusCode(
                500,
                "Ocurrió un error al buscar películas."
            );
        }
    }

    // Página de detalles de una película.
    public IActionResult Detalles(int id)
    {
        BD bd = new BD();

        Peliculas pelicula = bd.ObtenerPeliculaPorId(id);

        if (pelicula == null)
        {
            return NotFound();
        }

        ViewBag.Director = pelicula.IdDirector > 0
            ? bd.ObtenerNombreDirector(pelicula.IdDirector)
            : "No disponible";

        ViewBag.Actores = bd.ObtenerActores(id);

        string nombreUsuario = HttpContext.Session.GetString("usuario");

        ViewBag.UsuarioConectado = !string.IsNullOrEmpty(nombreUsuario);
        ViewBag.EsFavorito = false;
        ViewBag.EstaEnWatchlist = false;

        if (!string.IsNullOrEmpty(nombreUsuario))
        {
            int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

            ViewBag.EsFavorito = bd.EsFavorito(idUsuario, id);
            ViewBag.EstaEnWatchlist = bd.EstaEnWatchlist(idUsuario, id);
        }

        return View(pelicula);
    }

    [HttpPost]
    public IActionResult AgregarFavorito(int idPelicula)
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            TempData["Mensaje"] = "Iniciá sesión para guardar películas en Favoritas.";
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        bd.AgregarFavorito(idUsuario, idPelicula);

        TempData["Mensaje"] = "Película agregada a Favoritas.";

        return RedirectToAction("Detalles", new { id = idPelicula });
    }

    [HttpPost]
    public IActionResult QuitarFavorito(int idPelicula)
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        bd.QuitarFavorito(idUsuario, idPelicula);

        TempData["Mensaje"] = "Película quitada de Favoritas.";

        return RedirectToAction("Detalles", new { id = idPelicula });
    }

    [HttpPost]
    public IActionResult AgregarWatchlist(int idPelicula)
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            TempData["Mensaje"] = "Iniciá sesión para guardar películas en tu Watchlist.";
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        bd.AgregarWatchlist(idUsuario, idPelicula);

        TempData["Mensaje"] = "Película agregada a tu Watchlist.";

        return RedirectToAction("Detalles", new { id = idPelicula });
    }

    [HttpPost]
    public IActionResult QuitarWatchlist(int idPelicula)
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        bd.QuitarWatchlist(idUsuario, idPelicula);

        TempData["Mensaje"] = "Película quitada de tu Watchlist.";

        return RedirectToAction("Detalles", new { id = idPelicula });
    }

    // Página con las películas favoritas del usuario conectado.
    public IActionResult Favoritas()
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            TempData["Mensaje"] = "Iniciá sesión para ver tus Favoritas.";
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        List<Peliculas> peliculas = bd.ObtenerFavoritos(idUsuario);

        return View(peliculas);
    }

    // Página con las películas pendientes del usuario conectado.
    public IActionResult Watchlist()
    {
        string nombreUsuario = HttpContext.Session.GetString("usuario");

        if (string.IsNullOrEmpty(nombreUsuario))
        {
            TempData["Mensaje"] = "Iniciá sesión para ver tu Watchlist.";
            return RedirectToAction("Login");
        }

        BD bd = new BD();
        int idUsuario = bd.ObtenerIdUsuario(nombreUsuario);

        List<Peliculas> peliculas = bd.ObtenerWatchlist(idUsuario);

        return View(peliculas);
    }

    public class FiltrosBusqueda
    {
        public string? Genero { get; set; }
        public string? Animo { get; set; }
        public int? DuracionMaxima { get; set; }
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
        return View(new ErrorViewModel
        {
            RequestId = Activity.Current?.Id
                ?? HttpContext.TraceIdentifier
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
            ViewBag.Error =
                "El usuario debe tener al menos 4 caracteres y la contraseña 6.";

            return View();
        }

        BD bd = new BD();
        Usuarios usuarioEncontrado =
            bd.ObtenerUsuario(usuario, contrasena);

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
            ViewBag.Error =
                "Completá los campos correctamente: nombre y apellido de al menos 2 caracteres, usuario de 4 y contraseña de 6.";

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
