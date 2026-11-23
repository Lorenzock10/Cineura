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

string usuarioActual = HttpContext.Session.GetString("usuario");

List<Peliculas> peliculas;

if (string.IsNullOrEmpty(usuarioActual))
{
    peliculas = bd.ObtenerPeliculasTendencia();
}
else
{
    List<Peliculas> todas = bd.ObtenerPeliculas();
    Random aleatorio = new Random();
    peliculas = new List<Peliculas>();

    // Elegir hasta cuatro películas sin repetir.
    while (peliculas.Count < 4 && todas.Count > 0)
    {
        int posicion = aleatorio.Next(todas.Count);
        peliculas.Add(todas[posicion]);
        todas.RemoveAt(posicion);
    }
}

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
            if (string.IsNullOrEmpty(usuario))
{
    return View("Index");
}
else
{
    return View("Home");
}
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
        return BadRequest(new { error = "Escribí qué película querés ver." });

    try
    {
        BD bd = new BD();

        List<EtiquetasPelicula> etiquetas = bd.ObtenerTodasLasEtiquetas();
        List<string> tematicas = new List<string>();
        List<string> emociones = new List<string>();

        foreach (EtiquetasPelicula etiqueta in etiquetas)
        {
            if (etiqueta.Tipo == "Tematica")
                tematicas.Add(etiqueta.Nombre);
            else if (etiqueta.Tipo == "Emocion")
                emociones.Add(etiqueta.Nombre);
        }

        string respuestaIA = _buscadorIA.InterpretarBusqueda(
            busqueda, tematicas, emociones);

        using JsonDocument documento = JsonDocument.Parse(respuestaIA);
        JsonElement raiz = documento.RootElement;

        string tematica = null;
        string emocion = null;
        int? duracionMaxima = null;

        if (raiz.TryGetProperty("tematica", out JsonElement t)
            && t.ValueKind == JsonValueKind.String)
            tematica = t.GetString();

        if (raiz.TryGetProperty("emocion", out JsonElement e)
            && e.ValueKind == JsonValueKind.String)
            emocion = e.GetString();

        if (raiz.TryGetProperty("duracionMaxima", out JsonElement d)
            && d.ValueKind == JsonValueKind.Number
            && d.TryGetInt32(out int minutos)
            && minutos > 0)
            duracionMaxima = minutos;

        // Aceptar solamente etiquetas que existan realmente en SQL.
        // Comprobar que Nova devolvió etiquetas existentes.
        string tematicaValida = null;
        string emocionValida = null;

        foreach (string nombre in tematicas)
        {
            if (string.Equals(nombre, tematica, StringComparison.OrdinalIgnoreCase))
            {
                tematicaValida = nombre;
                break;
            }
        }
        foreach (string nombre in emociones)
        {
            if (string.Equals(nombre, emocion, StringComparison.OrdinalIgnoreCase))
            {
                emocionValida = nombre;
                break;
            }
        }
        tematica = tematicaValida;
        emocion = emocionValida;

        List<Peliculas> peliculas = bd.BuscarPeliculasPorEtiquetas(
            tematica, emocion, duracionMaxima);

        List<object> resultados = new List<object>();
        foreach (Peliculas pelicula in peliculas)
        {
            resultados.Add(new
            {
                pelicula.IdPelicula,
                pelicula.Titulo,
                pelicula.Sinopsis,
                pelicula.Genero,
                pelicula.Animo,
                pelicula.DuracionMinutos,
                pelicula.Anio,
                pelicula.PosterUrl
            });
        }

        return Json(resultados);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error al buscar películas con Nova");

        return StatusCode(500, new
        {
            error = "Nova tuvo un problema al buscar. Intentá nuevamente."
        });
    }
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

        public IActionResult Perfil()
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                TempData["Mensaje"] = "Iniciá sesión para ver tu perfil.";
                return RedirectToAction("Login");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);

            // 1. Películas favoritas
            List<Peliculas> misFavoritas = bd.ObtenerFavoritos(idUsuario) ?? new List<Peliculas>();
            ViewBag.MisFavoritas = misFavoritas;
            ViewBag.CantidadFavoritas = misFavoritas.Count;

            // 2. Conteo dinámico de Actores y Directores frecuentes a partir de sus películas favoritas
            Dictionary<string, int> conteoActores = new Dictionary<string, int>();
            Dictionary<string, int> conteoDirectores = new Dictionary<string, int>();

            foreach (Peliculas peli in misFavoritas)
            {
                // Conteo de Directores
                if (peli.IdDirector > 0)
                {
                    string nombreDirector = bd.ObtenerNombreDirector(peli.IdDirector);
                    if (!string.IsNullOrEmpty(nombreDirector) && nombreDirector != "No disponible")
                    {
                        if (conteoDirectores.ContainsKey(nombreDirector))
                            conteoDirectores[nombreDirector]++;
                        else
                            conteoDirectores[nombreDirector] = 1;
                    }
                }

                // Conteo de Actores (usando ObtenerActores de tu clase BD)
                List<string> actoresPeli = bd.ObtenerActores(peli.IdPelicula);
                if (actoresPeli != null)
                {
                    foreach (string nombreActor in actoresPeli)
                    {
                        if (!string.IsNullOrEmpty(nombreActor))
                        {
                            if (conteoActores.ContainsKey(nombreActor))
                                conteoActores[nombreActor]++;
                            else
                                conteoActores[nombreActor] = 1;
                        }
                    }
                }
            }

            ViewBag.ActoresFrecuentes = ObtenerCincoMasFrecuentes(conteoActores);
            ViewBag.DirectoresFrecuentes = ObtenerCincoMasFrecuentes(conteoDirectores);

            string gustosGuardados = bd.ObtenerGustosAdn(idUsuario);
            ViewBag.GustosAdn = gustosGuardados;

            return View();
        }

        // Devolver los cinco nombres con mayor cantidad, sin LINQ.
        private List<KeyValuePair<string, int>> ObtenerCincoMasFrecuentes(Dictionary<string, int> conteos)
        {
            List<KeyValuePair<string, int>> resultado = new List<KeyValuePair<string, int>>();
            Dictionary<string, int> pendientes = new Dictionary<string, int>(conteos);

            while (resultado.Count < 5 && pendientes.Count > 0)
            {
                string nombreMayor = "";
                int cantidadMayor = -1;
                foreach (KeyValuePair<string, int> dato in pendientes)
                {
                    if (dato.Value > cantidadMayor)
                    {
                        nombreMayor = dato.Key;
                        cantidadMayor = dato.Value;
                    }
                }
                resultado.Add(new KeyValuePair<string, int>(nombreMayor, cantidadMayor));
                pendientes.Remove(nombreMayor);
            }
            return resultado;
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult GuardarAdn(string gustosAdn)
        {
            string usuario = HttpContext.Session.GetString("usuario");
            if (string.IsNullOrEmpty(usuario))
            {
                return RedirectToAction("Login");
            }

            if (string.IsNullOrWhiteSpace(gustosAdn))
            {
                TempData["ErrorAdn"] = "Escribí tus gustos antes de guardarlos.";
                return RedirectToAction("Perfil");
            }

            if (gustosAdn.Length > 2000)
            {
                TempData["ErrorAdn"] = "Las preferencias no pueden superar los 2000 caracteres.";
                return RedirectToAction("Perfil");
            }

            BD bd = new BD();
            int idUsuario = bd.ObtenerIdUsuario(usuario);
            if (idUsuario == 0)
            {
                return RedirectToAction("Login");
            }

            bd.GuardarGustosAdn(idUsuario, gustosAdn.Trim());
            TempData["Mensaje"] = "¡ADN cinematográfico actualizado!";
            return RedirectToAction("Perfil");
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
            
            if (!bd.CuestionarioCompletado(usuarioEncontrado.IdUsuario))
            {
                return RedirectToAction("Cuestionario");
            }
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
            nuevoUsuario.Contraseña = BCrypt.Net.BCrypt.HashPassword(contrasena);
            bd.AgregarUsuario(nuevoUsuario);
            return RedirectToAction("Login");
        }

    public IActionResult Cuestionario()
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

        if (bd.CuestionarioCompletado(idUsuario))
        {
            return RedirectToAction("Index");
        }

        return View();
    }

[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult GuardarCuestionario(
    List<string> generos,
    List<string> historias,
    string compania,
    List<string> emociones,
    string descubrimiento)
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

    if (bd.CuestionarioCompletado(idUsuario))
    {
        return RedirectToAction("Index");
    }

    if (generos == null || generos.Count == 0 ||
        historias == null || historias.Count == 0 ||
        string.IsNullOrWhiteSpace(compania) ||
        emociones == null || emociones.Count == 0 ||
        string.IsNullOrWhiteSpace(descubrimiento))
    {
        TempData["Error"] = "Respondé todas las preguntas.";
        return RedirectToAction("Cuestionario");
    }
    foreach (string genero in new HashSet<string>(generos))
    {
        bd.GuardarPreferencia(idUsuario, 1, genero);
    }
    foreach (string historia in new HashSet<string>(historias))
    {
        bd.GuardarPreferencia(idUsuario, 2, historia);
    }
    bd.GuardarPreferencia(idUsuario, 3, compania);
    foreach (string emocion in new HashSet<string>(emociones))
    {
        bd.GuardarPreferencia(idUsuario, 4, emocion);
    }
    bd.GuardarPreferencia(idUsuario, 5, descubrimiento);
    bd.CompletarCuestionario(idUsuario);
    return RedirectToAction("CuestionarioFinal");
}

public IActionResult CuestionarioFinal()
{
    string usuario = HttpContext.Session.GetString("usuario");

    if (string.IsNullOrEmpty(usuario))
    {
        return RedirectToAction("Login");
    }

    BD bd = new BD();
    int idUsuario = bd.ObtenerIdUsuario(usuario);

    if (!bd.CuestionarioCompletado(idUsuario))
    {
        return RedirectToAction("Cuestionario");
    }

    return View();
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
            string mensaje = "Quitada de Favoritas.";
            if (nuevoEstado)
                mensaje = "Añadida a Favoritas.";
            return Json(new
            {
                ok = true,
                esFavorito = nuevoEstado,
                message = mensaje
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
            string mensaje = "Quitada de Watchlist.";
            if (nuevoEstado)
                mensaje = "Añadida a Watchlist.";
            return Json(new
            {
                ok = true,
                estaEnWatchlist = nuevoEstado,
                message = mensaje
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