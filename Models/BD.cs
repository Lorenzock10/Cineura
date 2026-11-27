using Dapper;
using Microsoft.Data.SqlClient;

namespace Cineura.Models
{
    public class BD
    {
        private string _connectionString =
            @"Server=localhost\SQLEXPRESS;Database=Cineura;Integrated Security=True;TrustServerCertificate=True;";

        public void AgregarUsuario(Usuarios usuario)
        {
            string query = @"
                INSERT INTO Usuarios (NombreUsuario, Contraseña, Nombre, Apellido)
                VALUES (@NombreUsuario, @Contraseña, @Nombre, @Apellido)";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, usuario);
            }
        }

        
        // Busca un usuario y comprueba su contraseña.
        // Si todavía tiene una contraseña antigua, la convierte a BCrypt.
        public Usuarios ObtenerUsuario(string nombreUsuario, string contrasena)
        {
            string query = @"SELECT TOP 1 * FROM Usuarios WHERE NombreUsuario = @nombreUsuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                Usuarios usuario = connection.QueryFirstOrDefault<Usuarios>(query, new { nombreUsuario });

                if (usuario == null || usuario.Contraseña == null)
                {
                    return null;
                }

                bool estaEncriptada = usuario.Contraseña.StartsWith("$2a$") ||
                                     usuario.Contraseña.StartsWith("$2b$") ||
                                     usuario.Contraseña.StartsWith("$2y$");

                if (estaEncriptada)
                {
                    if (BCrypt.Net.BCrypt.Verify(contrasena, usuario.Contraseña))
                    {
                        return usuario;
                    }
                }
                else
                {
                    if (usuario.Contraseña == contrasena)
                    {
                        string contraseñaEncriptada = BCrypt.Net.BCrypt.HashPassword(contrasena);
                        string actualizar = @"UPDATE Usuarios
                                              SET Contraseña = @contraseñaEncriptada
                                              WHERE IdUsuario = @id";

                        connection.Execute(actualizar, new { contraseñaEncriptada, id = usuario.IdUsuario });
                        return usuario;
                    }
                }

                return null;
            }
        }

        public Usuarios ObtenerUsuarioPorNombre(string usuario)
        {
            string query = @"
                SELECT *
                FROM Usuarios
                WHERE NombreUsuario = @usuario
                OR Nombre = @usuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<Usuarios>(query, new { usuario });
            }
        }

        public List<Peliculas> ObtenerPeliculas()
        {
            string query = @"
                SELECT IdPelicula, Titulo, Sinopsis, Genero,
                       DuracionMinutos, Anio, Animo, IdDirector, PosterUrl
                FROM Peliculas";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<Peliculas>(query).ToList();
            }
        }

        public Peliculas ObtenerPeliculaPorId(int id)
        {
            string query = @"
                SELECT IdPelicula, Titulo, Sinopsis, Genero,
                       DuracionMinutos, Anio, Animo, IdDirector, PosterUrl
                FROM Peliculas
                WHERE IdPelicula = @id";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<Peliculas>(query, new { id });
            }
        }

        public string ObtenerNombreDirector(int idDirector)
        {
            string query = @"
                SELECT Nombre
                FROM Directores
                WHERE IdDirector = @idDirector";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<string>(
                    query, new { idDirector }) ?? "No disponible";
            }
        }

        public List<string> ObtenerActores(int idPelicula)
        {
            string query = @"
                SELECT A.Nombre
                FROM Actores A
                INNER JOIN PeliculaActor PA ON A.IdActor = PA.IdActor
                WHERE PA.IdPelicula = @idPelicula
                ORDER BY A.Nombre";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<string>(query, new { idPelicula }).ToList();
            }
        }

        public int ObtenerIdUsuario(string nombreUsuario)
        {
            string query = @"
                SELECT IdUsuario
                FROM Usuarios
                WHERE NombreUsuario = @nombreUsuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<int>(query, new { nombreUsuario });
            }
        }

        public void AgregarFavorito(int idUsuario, int idPelicula)
        {
            string query = @"
                IF NOT EXISTS (
                    SELECT 1 FROM Favoritos
                    WHERE IdUsuario = @idUsuario
                    AND IdPelicula = @idPelicula
                )
                BEGIN
                    INSERT INTO Favoritos (IdUsuario, IdPelicula)
                    VALUES (@idUsuario, @idPelicula)
                END";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula });
            }
        }

        public void QuitarFavorito(int idUsuario, int idPelicula)
        {
            string query = @"
                DELETE FROM Favoritos
                WHERE IdUsuario = @idUsuario
                AND IdPelicula = @idPelicula";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula });
            }
        }

        public List<Peliculas> ObtenerFavoritos(int idUsuario)
        {
            string query = @"
                SELECT P.IdPelicula, P.Titulo, P.Sinopsis, P.Genero,
                       P.DuracionMinutos, P.Anio, P.Animo,
                       P.IdDirector, P.PosterUrl
                FROM Peliculas P
                INNER JOIN Favoritos F ON P.IdPelicula = F.IdPelicula
                WHERE F.IdUsuario = @idUsuario
                ORDER BY F.Fecha DESC";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<Peliculas>(query, new { idUsuario }).ToList();
            }
        }

        public bool EsFavorito(int idUsuario, int idPelicula)
        {
            string query = @"
                SELECT COUNT(1)
                FROM Favoritos
                WHERE IdUsuario = @idUsuario
                AND IdPelicula = @idPelicula";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                int cantidad = connection.QueryFirstOrDefault<int>(
                    query, new { idUsuario, idPelicula });

                return cantidad > 0;
            }
        }

        public void AgregarWatchlist(int idUsuario, int idPelicula)
        {
            string query = @"
                IF NOT EXISTS (
                    SELECT 1 FROM Watchlist
                    WHERE IdUsuario = @idUsuario
                    AND IdPelicula = @idPelicula
                )
                BEGIN
                    INSERT INTO Watchlist (IdUsuario, IdPelicula)
                    VALUES (@idUsuario, @idPelicula)
                END";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula });
            }
        }

        public void QuitarWatchlist(int idUsuario, int idPelicula)
        {
            string query = @"
                DELETE FROM Watchlist
                WHERE IdUsuario = @idUsuario
                AND IdPelicula = @idPelicula";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula });
            }
        }

        public List<Peliculas> ObtenerWatchlist(int idUsuario)
        {
            string query = @"
                SELECT P.IdPelicula, P.Titulo, P.Sinopsis, P.Genero,
                       P.DuracionMinutos, P.Anio, P.Animo,
                       P.IdDirector, P.PosterUrl
                FROM Peliculas P
                INNER JOIN Watchlist W ON P.IdPelicula = W.IdPelicula
                WHERE W.IdUsuario = @idUsuario
                ORDER BY W.FechaAgregado DESC";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<Peliculas>(query, new { idUsuario }).ToList();
            }
        }

        public bool EstaEnWatchlist(int idUsuario, int idPelicula)
        {
            string query = @"
                SELECT COUNT(1)
                FROM Watchlist
                WHERE IdUsuario = @idUsuario
                AND IdPelicula = @idPelicula";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                int cantidad = connection.QueryFirstOrDefault<int>(
                    query, new { idUsuario, idPelicula });

                return cantidad > 0;
            }
        }

        public List<Peliculas> ObtenerPeliculasTendencia()
        {
            string query = @"
                SELECT P.IdPelicula, P.Titulo, P.Sinopsis, P.Genero,
                       P.DuracionMinutos, P.Anio, P.Animo,
                       P.IdDirector, P.PosterUrl
                FROM Peliculas P
                INNER JOIN Tendencias T ON P.IdPelicula = T.IdPelicula
                ORDER BY T.CantidadInteracciones DESC";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<Peliculas>(query).ToList();
            }
        }

        public void GuardarPuntuacion(int idUsuario, int idPelicula, int puntuacion)
        {
            string query = @"
                IF EXISTS (
                    SELECT 1 FROM Valoraciones
                    WHERE IdUsuario = @idUsuario
                    AND IdPelicula = @idPelicula
                )
                BEGIN
                    UPDATE Valoraciones
                    SET Puntuacion = @puntuacion
                    WHERE IdUsuario = @idUsuario
                    AND IdPelicula = @idPelicula
                END
                ELSE
                BEGIN
                    INSERT INTO Valoraciones (IdUsuario, IdPelicula, Puntuacion)
                    VALUES (@idUsuario, @idPelicula, @puntuacion)
                END";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula, puntuacion });
            }
        }

        public List<Comentarios> ObtenerComentarios(int idPelicula)
        {
            string query = @"
                SELECT IdComentario, IdUsuario, IdPelicula, Texto, Fecha
                FROM Comentarios
                WHERE IdPelicula = @idPelicula
                ORDER BY Fecha DESC";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.Query<Comentarios>(query, new { idPelicula }).ToList();
            }
        }

        public void AgregarComentario(int idUsuario, int idPelicula, string texto)
        {
            string query = @"
                INSERT INTO Comentarios (IdUsuario, IdPelicula, Texto)
                VALUES (@idUsuario, @idPelicula, @texto)";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, idPelicula, texto });
            }
        }

        public bool EditarComentario(int idComentario, int idUsuario, string texto)
        {
            string query = @"
                UPDATE Comentarios
                SET Texto = @texto
                WHERE IdComentario = @idComentario
                AND IdUsuario = @idUsuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                int filas = connection.Execute(
                    query, new { idComentario, idUsuario, texto });

                return filas > 0;
            }
        }

        public bool EliminarComentario(int idComentario, int idUsuario)
        {
            string query = @"
                DELETE FROM Comentarios
                WHERE IdComentario = @idComentario
                AND IdUsuario = @idUsuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                int filas = connection.Execute(
                    query, new { idComentario, idUsuario });

                return filas > 0;
            }
        }

        public int ObtenerPuntuacionUsuario(int idUsuario, int idPelicula)
        {
            string query = @"
                SELECT ISNULL(
                    (SELECT Puntuacion
                     FROM Valoraciones
                     WHERE IdUsuario = @idUsuario
                     AND IdPelicula = @idPelicula),
                    0
                )";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<int>(
                    query, new { idUsuario, idPelicula });
            }
        }

        public double ObtenerPromedioPuntuacion(int idPelicula)
        {
            string query = @"
                SELECT ISNULL(AVG(CAST(Puntuacion AS FLOAT)), 0)
                FROM Valoraciones
                WHERE IdPelicula = @idPelicula";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<double>(
                    query, new { idPelicula });
            }
        }

        public string ObtenerNombreUsuario(int idUsuario)
        {
            string query = @"
                SELECT NombreUsuario
                FROM Usuarios
                WHERE IdUsuario = @idUsuario";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<string>(
                    query, new { idUsuario });
            }
        }


public List<EtiquetasPelicula> ObtenerEtiquetasPelicula(int idPelicula)
{
    string query = @"
        SELECT E.Nombre, E.Tipo
        FROM Etiquetas E
        INNER JOIN PeliculaEtiquetas PE
            ON E.IdEtiqueta = PE.IdEtiqueta
        WHERE PE.IdPelicula = @idPelicula
        ORDER BY E.Tipo, E.Nombre";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.Query<EtiquetasPelicula>(
            query,
            new { idPelicula }
        ).ToList();
    }
}

public List<EtiquetasPelicula> ObtenerTodasLasEtiquetas()
{
    string query = @"
        SELECT Nombre, Tipo
        FROM Etiquetas
        ORDER BY Tipo, Nombre";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.Query<EtiquetasPelicula>(query).ToList();
    }
}
public List<Peliculas> BuscarPeliculasPorEtiquetas(
    string tematica,
    string emocion,
    int? duracionMaxima)
{
    string query = @"
        SELECT P.IdPelicula, P.Titulo, P.Sinopsis,
               P.Genero, P.DuracionMinutos, P.Anio,
               P.Animo, P.IdDirector, P.PosterUrl
        FROM Peliculas P
        WHERE
            (@duracionMaxima IS NULL
                OR P.DuracionMinutos <= @duracionMaxima)

            AND (@tematica IS NULL OR EXISTS (
                SELECT 1
                FROM PeliculaEtiquetas PE
                INNER JOIN Etiquetas E
                    ON PE.IdEtiqueta = E.IdEtiqueta
                WHERE PE.IdPelicula = P.IdPelicula
                  AND E.Tipo = 'Tematica'
                  AND E.Nombre = @tematica
            ))

            AND (@emocion IS NULL OR EXISTS (
                SELECT 1
                FROM PeliculaEtiquetas PE
                INNER JOIN Etiquetas E
                    ON PE.IdEtiqueta = E.IdEtiqueta
                WHERE PE.IdPelicula = P.IdPelicula
                  AND E.Tipo = 'Emocion'
                  AND E.Nombre = @emocion
            ))

        ORDER BY P.IdPelicula";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.Query<Peliculas>(
            query,
            new { tematica, emocion, duracionMaxima }
        ).ToList();
    }
}


public bool AgregarPeliculaTMDB(
    int idTMDB,
    string titulo,
    string sinopsis,
    string genero,
    int duracion,
    int anio,
    string animo,
    int idDirector,
    string posterUrl)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1
            FROM Peliculas
            WHERE IdTMDB = @idTMDB
               OR (Titulo = @titulo AND Anio = @anio)
        )
        BEGIN
            INSERT INTO Peliculas
            (IdTMDB, Titulo, Sinopsis, Genero,
             DuracionMinutos, Anio, Animo, IdDirector, PosterUrl)
            VALUES
            (@idTMDB, @titulo, @sinopsis, @genero,
             @duracion, @anio, @animo, @idDirector, @posterUrl)
        END";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        int filas = connection.Execute(query, new
        {
            idTMDB,
            titulo,
            sinopsis,
            genero,
            duracion,
            anio,
            animo,
            idDirector,
            posterUrl
        });

        return filas > 0;
    }
}

public int ObtenerOCrearDirector(string nombre)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1 FROM Directores
            WHERE Nombre = @nombre
        )
        BEGIN
            INSERT INTO Directores (Nombre)
            VALUES (@nombre)
        END

        SELECT TOP 1 IdDirector
        FROM Directores
        WHERE Nombre = @nombre";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.QueryFirst<int>(query, new { nombre });
    }
}

public int ObtenerOCrearActor(string nombre)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1 FROM Actores
            WHERE Nombre = @nombre
        )
        BEGIN
            INSERT INTO Actores (Nombre)
            VALUES (@nombre)
        END

        SELECT TOP 1 IdActor
        FROM Actores
        WHERE Nombre = @nombre";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.QueryFirst<int>(query, new { nombre });
    }
}

public void AgregarActorAPelicula(int idPelicula, int idActor)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1 FROM PeliculaActor
            WHERE IdPelicula = @idPelicula
              AND IdActor = @idActor
        )
        BEGIN
            INSERT INTO PeliculaActor (IdPelicula, IdActor)
            VALUES (@idPelicula, @idActor)
        END";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        connection.Execute(query, new { idPelicula, idActor });
    }
}

public void AgregarEtiquetaAPelicula(
    int idPelicula,
    string nombre,
    string tipo)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1
            FROM Etiquetas
            WHERE Nombre = @nombre
              AND Tipo = @tipo
        )
        BEGIN
            INSERT INTO Etiquetas (Nombre, Tipo)
            VALUES (@nombre, @tipo)
        END

        DECLARE @idEtiqueta INT;

        SELECT @idEtiqueta = IdEtiqueta
        FROM Etiquetas
        WHERE Nombre = @nombre
          AND Tipo = @tipo;

        IF NOT EXISTS (
            SELECT 1
            FROM PeliculaEtiquetas
            WHERE IdPelicula = @idPelicula
              AND IdEtiqueta = @idEtiqueta
        )
        BEGIN
            INSERT INTO PeliculaEtiquetas
                (IdPelicula, IdEtiqueta)
            VALUES
                (@idPelicula, @idEtiqueta)
        END";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        connection.Execute(query, new
        {
            idPelicula,
            nombre,
            tipo
        });
    }
}

public int ObtenerIdPeliculaTMDB(int idTMDB, string titulo, int anio)
{
    string query = @"
        SELECT TOP 1 IdPelicula
        FROM Peliculas
        WHERE IdTMDB = @idTMDB
           OR (Titulo = @titulo AND Anio = @anio)";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.QueryFirstOrDefault<int>(query, new
        {
            idTMDB,
            titulo,
            anio
        });
    }
}


public void GuardarPreferencia(int idUsuario, int numeroPregunta, string respuesta)
{
    string query = @"
        INSERT INTO PreferenciasUsuario
        (IdUsuario, NumeroPregunta, Respuesta)
        VALUES (@idUsuario, @numeroPregunta, @respuesta)";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        connection.Execute(query, new
        {
            idUsuario,
            numeroPregunta,
            respuesta
        });
    }
}

public List<string> ObtenerPreferencias(int idUsuario, int numeroPregunta)
{
    string query = @"
        SELECT Respuesta
        FROM PreferenciasUsuario
        WHERE IdUsuario = @idUsuario
        AND NumeroPregunta = @numeroPregunta";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.Query<string>(query, new
        {
            idUsuario,
            numeroPregunta
        }).ToList();
    }
}

public bool CuestionarioCompletado(int idUsuario)
{
    string query = @"
        SELECT Completado
        FROM CuestionariosUsuario
        WHERE IdUsuario = @idUsuario";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        return connection.QueryFirstOrDefault<bool>(
            query, new { idUsuario });
    }
}

public void CompletarCuestionario(int idUsuario)
{
    string query = @"
        IF NOT EXISTS (
            SELECT 1 FROM CuestionariosUsuario
            WHERE IdUsuario = @idUsuario
        )
        BEGIN
            INSERT INTO CuestionariosUsuario
            (IdUsuario, Completado)
            VALUES (@idUsuario, 1)
        END
        ELSE
        BEGIN
            UPDATE CuestionariosUsuario
            SET Completado = 1
            WHERE IdUsuario = @idUsuario
        END";

    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        connection.Execute(query, new { idUsuario });
    }
}


        public string ObtenerGustosAdn(int idUsuario)
        {
            string query = "SELECT GustosAdn FROM Usuarios WHERE IdUsuario = @idUsuario";
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<string>(query, new { idUsuario }) ?? "";
            }
        }

        public void GuardarGustosAdn(int idUsuario, string gustosAdn)
        {
            string query = "UPDATE Usuarios SET GustosAdn = @gustosAdn WHERE IdUsuario = @idUsuario";
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Execute(query, new { idUsuario, gustosAdn });
            }
        }
        public List<Peliculas> ObtenerRecomendacionesPerfil(int idUsuario)
{
    List<string> generos = ObtenerPreferencias(idUsuario, 1);
    List<string> historias = ObtenerPreferencias(idUsuario, 2);
    List<string> emociones = ObtenerPreferencias(idUsuario, 4);

    List<Peliculas> peliculas = ObtenerPeliculas();
    List<Peliculas> recomendadas = new List<Peliculas>();

    Dictionary<Peliculas, int> puntuaciones =
        new Dictionary<Peliculas, int>();

    foreach (Peliculas pelicula in peliculas)
    {
        int puntos = 0;

        string genero = pelicula.Genero ?? "";
        string animo = pelicula.Animo ?? "";

        foreach (string preferencia in generos)
        {
            if (genero.ToLower().Contains(preferencia.ToLower()))
            {
                puntos += 3;
            }
        }

        foreach (string historia in historias)
        {
            if (historia == "Que me hagan pensar" && animo == "Reflexivo")
                puntos += 2;

            if (historia == "Que me emocionen" && animo == "Emotivo")
                puntos += 2;

            if (historia == "Que me hagan reír" && animo == "Divertido")
                puntos += 2;

            if (historia == "Con misterio" && animo == "Intrigante")
                puntos += 2;

            if (historia == "Que me sorprendan" && animo == "Emocionante")
                puntos += 2;

            if (historia == "Con mucha tensión" && animo == "Intenso")
                puntos += 2;
        }

        foreach (string emocion in emociones)
        {
            if (emocion == "Adrenalina" && animo == "Intenso")
                puntos += 2;

            if (emocion == "Tranquilidad" && animo == "Reflexivo")
                puntos += 2;

            if (emocion == "Emoción" && animo == "Emotivo")
                puntos += 2;

            if (emocion == "Intriga" && animo == "Intrigante")
                puntos += 2;

            if (emocion == "Inspiración" && animo == "Inspirador")
                puntos += 2;

            if (emocion == "Desconectar" && animo == "Divertido")
                puntos += 2;
        }

        if (puntos > 0)
        {
            puntuaciones.Add(pelicula, puntos);
        }
    }

    while (recomendadas.Count < 5 && puntuaciones.Count > 0)
    {
        Peliculas mejorPelicula = null;
        int mayorPuntuacion = -1;

        foreach (KeyValuePair<Peliculas, int> dato in puntuaciones)
        {
            if (dato.Value > mayorPuntuacion)
            {
                mejorPelicula = dato.Key;
                mayorPuntuacion = dato.Value;
            }
        }

        recomendadas.Add(mejorPelicula);
        puntuaciones.Remove(mejorPelicula);
    }

    return recomendadas;
}
    }
}
