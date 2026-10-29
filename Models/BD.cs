
using Dapper;
using Microsoft.Data.SqlClient;

namespace Cineura.Models;

public class BD
{
    private string _connectionString =
    @"Server=localhost\SQLEXPRESS;Database=Cineura;Integrated Security=True;TrustServerCertificate=True;";
    public void AgregarUsuario(Usuarios usuario)
    {
        string query = @"
            INSERT INTO Usuarios
                (NombreUsuario, Contraseña, Nombre, Apellido)
            VALUES
                (@pNombreUsuario, @pContraseña, @pNombre, @pApellido)";

        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            connection.Execute(query, new
            {
                pNombreUsuario = usuario.NombreUsuario,
                pContraseña = usuario.Contraseña,
                pNombre = usuario.Nombre,
                pApellido = usuario.Apellido
            });
        }
    }

    public Usuarios ObtenerUsuario(
        string nombreUsuario,
        string contrasena)
    {
        string query = @"
            SELECT TOP 1 *
            FROM Usuarios
            WHERE NombreUsuario = @pNombreUsuario
              AND Contraseña = @pContraseña";

        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            return connection.QueryFirstOrDefault<Usuarios>(
                query,
                new
                {
                    pNombreUsuario = nombreUsuario,
                    pContraseña = contrasena
                });
        }
    }

    public Usuarios ObtenerUsuarioPorNombre(string usuario)
    {
        using (SqlConnection db =
            new SqlConnection(_connectionString))
        {
            string sql = @"
                SELECT *
                FROM Usuarios
                WHERE NombreUsuario = @usuario
                   OR Nombre = @usuario";

            return db.QueryFirstOrDefault<Usuarios>(
                sql,
                new { usuario });
        }
    }

    public List<Peliculas> ObtenerPeliculas()
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT
                    IdPelicula,
                    Titulo,
                    Sinopsis,
                    Genero,
                    DuracionMinutos,
                    Anio,
                    Animo,
                    IdDirector,
                    PosterUrl
                FROM Peliculas";

            return connection.Query<Peliculas>(query).ToList();
        }
    }

    public Peliculas ObtenerPeliculaPorId(int id)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT
                    IdPelicula,
                    Titulo,
                    Sinopsis,
                    Genero,
                    DuracionMinutos,
                    Anio,
                    Animo,
                    IdDirector,
                    PosterUrl
                FROM Peliculas
                WHERE IdPelicula = @id";

            return connection.QueryFirstOrDefault<Peliculas>(
                query,
                new { id });
        }
    }

    public string ObtenerNombreDirector(int idDirector)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT Nombre
                FROM Directores
                WHERE IdDirector = @idDirector";

            return connection.QueryFirstOrDefault<string>(
                query,
                new { idDirector }) ?? "No disponible";
        }
    }

    public List<string> ObtenerActores(int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT A.Nombre
                FROM Actores A
                INNER JOIN PeliculaActor PA
                    ON A.IdActor = PA.IdActor
                WHERE PA.IdPelicula = @idPelicula
                ORDER BY A.Nombre";

            return connection.Query<string>(
                query,
                new { idPelicula }).ToList();
        }
    }

    public int ObtenerIdUsuario(string nombreUsuario)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT IdUsuario
                FROM Usuarios
                WHERE NombreUsuario = @nombreUsuario";

            return connection.QueryFirstOrDefault<int>(
                query,
                new { nombreUsuario });
        }
    }

    public void AgregarFavorito(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                IF NOT EXISTS (
                    SELECT 1
                    FROM Favoritos
                    WHERE IdUsuario = @idUsuario
                      AND IdPelicula = @idPelicula
                )
                BEGIN
                    INSERT INTO Favoritos (IdUsuario, IdPelicula)
                    VALUES (@idUsuario, @idPelicula)
                END";

            connection.Execute(query, new
            {
                idUsuario,
                idPelicula
            });
        }
    }

    public void QuitarFavorito(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                DELETE FROM Favoritos
                WHERE IdUsuario = @idUsuario
                  AND IdPelicula = @idPelicula";

            connection.Execute(query, new
            {
                idUsuario,
                idPelicula
            });
        }
    }

    public List<Peliculas> ObtenerFavoritos(int idUsuario)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT
                    P.IdPelicula,
                    P.Titulo,
                    P.Sinopsis,
                    P.Genero,
                    P.DuracionMinutos,
                    P.Anio,
                    P.Animo,
                    P.IdDirector,
                    P.PosterUrl
                FROM Peliculas P
                INNER JOIN Favoritos F
                    ON P.IdPelicula = F.IdPelicula
                WHERE F.IdUsuario = @idUsuario
                ORDER BY F.Fecha DESC";

            return connection.Query<Peliculas>(
                query,
                new { idUsuario }).ToList();
        }
    }

    public bool EsFavorito(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT COUNT(1)
                FROM Favoritos
                WHERE IdUsuario = @idUsuario
                  AND IdPelicula = @idPelicula";

            return connection.ExecuteScalar<int>(
                query,
                new { idUsuario, idPelicula }) > 0;
        }
    }

    public void AgregarWatchlist(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                IF NOT EXISTS (
                    SELECT 1
                    FROM Watchlist
                    WHERE IdUsuario = @idUsuario
                      AND IdPelicula = @idPelicula
                )
                BEGIN
                    INSERT INTO Watchlist (IdUsuario, IdPelicula)
                    VALUES (@idUsuario, @idPelicula)
                END";

            connection.Execute(query, new
            {
                idUsuario,
                idPelicula
            });
        }
    }

    public void QuitarWatchlist(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                DELETE FROM Watchlist
                WHERE IdUsuario = @idUsuario
                  AND IdPelicula = @idPelicula";

            connection.Execute(query, new
            {
                idUsuario,
                idPelicula
            });
        }
    }

    public List<Peliculas> ObtenerWatchlist(int idUsuario)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT
                    P.IdPelicula,
                    P.Titulo,
                    P.Sinopsis,
                    P.Genero,
                    P.DuracionMinutos,
                    P.Anio,
                    P.Animo,
                    P.IdDirector,
                    P.PosterUrl
                FROM Peliculas P
                INNER JOIN Watchlist W
                    ON P.IdPelicula = W.IdPelicula
                WHERE W.IdUsuario = @idUsuario
                ORDER BY W.FechaAgregado DESC";

            return connection.Query<Peliculas>(
                query,
                new { idUsuario }).ToList();
        }
    }

    public bool EstaEnWatchlist(int idUsuario, int idPelicula)
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT COUNT(1)
                FROM Watchlist
                WHERE IdUsuario = @idUsuario
                  AND IdPelicula = @idPelicula";

            return connection.ExecuteScalar<int>(
                query,
                new { idUsuario, idPelicula }) > 0;
        }
    }
    public List<Peliculas> ObtenerPeliculasTendencia()
    {
        using (SqlConnection connection =
            new SqlConnection(_connectionString))
        {
            string query = @"
                SELECT
                    P.IdPelicula,
                    P.Titulo,
                    P.Sinopsis,
                    P.Genero,
                    P.DuracionMinutos,
                    P.Anio,
                    P.Animo,
                    P.IdDirector,
                    P.PosterUrl
                FROM Peliculas P
                INNER JOIN Tendencias T
                    ON P.IdPelicula = T.IdPelicula
                ORDER BY T.CantidadInteracciones DESC";

            return connection.Query<Peliculas>(query).ToList();
        }
    }
}
