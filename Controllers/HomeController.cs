
using System.Diagnostics;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Cineura.Models;
using Cineura.Services;

namespace Cineura.Controllers;

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
            string resultado = await _buscadorIA.InterpretarBusquedaAsync(busqueda);
            return Content(resultado, "application/json");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al interpretar la búsqueda con IA.");
            return StatusCode(500, ex.Message);
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
            // Nova interpreta la búsqueda
            string respuestaIA = await _buscadorIA.InterpretarBusquedaAsync(busqueda);

            // Convertimos la respuesta de Nova en filtros
            FiltrosBusqueda? filtros = JsonSerializer.Deserialize<FiltrosBusqueda>(
                respuestaIA,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                }
            );

            if (filtros == null)
            {
                return StatusCode(500, "Nova no pudo interpretar la búsqueda.");
            }

            // Obtenemos las películas de SQL Server
            BD bd = new BD();
            List<Peliculas> peliculas = bd.ObtenerPeliculas();

            // Filtramos por género
            if (!string.IsNullOrWhiteSpace(filtros.Genero))
            {
                string genero = filtros.Genero.ToLower();

                peliculas = peliculas.Where(p =>
                    p.Genero != null &&
                    (
                        p.Genero.ToLower().Contains(genero) ||
                        (genero.Contains("terror") &&
                         p.Genero.ToLower().Contains("horror")) ||
                        (genero.Contains("horror") &&
                         p.Genero.ToLower().Contains("terror"))
                    )
                ).ToList();
            }

            // Filtramos por duración máxima
            if (filtros.DuracionMaxima.HasValue)
            {
                peliculas = peliculas.Where(p =>
                    p.DuracionMinutos <= filtros.DuracionMaxima.Value
                ).ToList();
            }

            // Filtramos por ánimo
            if (!string.IsNullOrWhiteSpace(filtros.Animo))
            {
                string animo = filtros.Animo.ToLower();

                peliculas = peliculas.Where(p =>
                    p.Animo != null &&
                    p.Animo.ToLower().Contains(animo)
                ).ToList();
            }

            return Json(peliculas);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al buscar películas con Nova.");
            string mensaje = ex.ToString();
return StatusCode(500, mensaje);
        }
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

    public IActionResult Home()
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

        return RedirectToAction("Home");
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
            ViewBag.Error = "Complete los campos con datos válidos: nombre y apellido de al menos 2 caracteres, usuario de 4 y contraseña de 6.";
            return View();
        }

        BD bd = new BD();
        Usuarios usuarioExistente = bd.ObtenerUsuarioPorNombre(usuario);

        if (usuarioExistente != null)
        {
            ViewBag.Error = "El nombre de usuario ya existe.";
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

        HttpContext.Session.SetString("usuario", nuevoUsuario.NombreUsuario);
        HttpContext.Session.SetString("nombre", nuevoUsuario.Nombre);
        HttpContext.Session.SetString("apellido", nuevoUsuario.Apellido);

        return RedirectToAction("Home");
    }
}
