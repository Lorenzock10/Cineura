
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

        public Usuarios ObtenerUsuario(string nombreUsuario, string contrasena)
        {
            string query = @"
                SELECT TOP 1 *
                FROM Usuarios
                WHERE NombreUsuario = @nombreUsuario
                AND Contraseña = @contrasena";

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                return connection.QueryFirstOrDefault<Usuarios>(
                    query,
                    new { nombreUsuario, contrasena });
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
    }
}
