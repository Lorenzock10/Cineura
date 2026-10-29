
using Dapper;
using Microsoft.Data.SqlClient;

namespace Cineura.Models;

public class BD
{
    private string _connectionString =
    @"Server=localhost;Database=Cineura;Integrated Security=True;TrustServerCertificate=True;";
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
public void GuardarPuntuacion(int idUsuario, int idPelicula, int puntuacion)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            IF EXISTS (
                SELECT 1
                FROM Valoraciones
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

        connection.Execute(query, new
        {
            idUsuario,
            idPelicula,
            puntuacion
        });
    }
}

public List<Comentarios> ObtenerComentarios(int idPelicula)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            SELECT IdComentario, IdUsuario, IdPelicula, Texto, Fecha
            FROM Comentarios
            WHERE IdPelicula = @idPelicula
            ORDER BY Fecha DESC";

        return connection.Query<Comentarios>(
            query, new { idPelicula }).ToList();
    }
}

public void AgregarComentario(int idUsuario, int idPelicula, string texto)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            INSERT INTO Comentarios (IdUsuario, IdPelicula, Texto)
            VALUES (@idUsuario, @idPelicula, @texto)";

        connection.Execute(query, new { idUsuario, idPelicula, texto });
    }
}

public bool EditarComentario(int idComentario, int idUsuario, string texto)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            UPDATE Comentarios
            SET Texto = @texto
            WHERE IdComentario = @idComentario
              AND IdUsuario = @idUsuario";

        int filas = connection.Execute(
            query, new { idComentario, idUsuario, texto });

        if (filas > 0)
        {
            return true;
        }

        return false;
    }
}

public bool EliminarComentario(int idComentario, int idUsuario)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            DELETE FROM Comentarios
            WHERE IdComentario = @idComentario
              AND IdUsuario = @idUsuario";

        int filas = connection.Execute(
            query, new { idComentario, idUsuario });

        if (filas > 0)
        {
            return true;
        }

        return false;
    }
}

public int ObtenerPuntuacionUsuario(int idUsuario, int idPelicula)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            SELECT ISNULL(
                (SELECT Puntuacion
                 FROM Valoraciones
                 WHERE IdUsuario = @idUsuario
                   AND IdPelicula = @idPelicula),
                0
            )";

        int puntuacion = connection.QueryFirstOrDefault<int>(
            query,
            new { idUsuario, idPelicula }
        );

        return puntuacion;
    }
}

public double ObtenerPromedioPuntuacion(int idPelicula)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            SELECT ISNULL(AVG(CAST(Puntuacion AS FLOAT)), 0)
            FROM Valoraciones
            WHERE IdPelicula = @idPelicula";

        double promedio = connection.QueryFirstOrDefault<double>(
            query,
            new { idPelicula }
        );

        return promedio;
    }
}

public string ObtenerNombreUsuario(int idUsuario)
{
    using (SqlConnection connection = new SqlConnection(_connectionString))
    {
        string query = @"
            SELECT NombreUsuario
            FROM Usuarios
            WHERE IdUsuario = @idUsuario";

        string nombreUsuario = connection.QueryFirstOrDefault<string>(
            query,
            new { idUsuario }
        );

        return nombreUsuario;
    }
}

}
