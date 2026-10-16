using Dapper;
using Microsoft.Data.SqlClient;
using Cineura.Models;

namespace Cineura.Models;

public class BD{
    
  
  private string _connectionString = @"Server=localhost;Database=Cineura;
    Integrated Security=True;TrustServerCertificate=True;";





    public void AgregarUsuario(Usuarios usuario){
        string query = "INSERT INTO Usuarios (NombreUsuario, Contraseña, Nombre, Apellido) VALUES (@pNombreUsuario, @pContraseña, @pNombre, @pApellido)";
        using(SqlConnection connection = new SqlConnection(_connectionString)){
            connection.Execute(query, new { pNombreUsuario = usuario.NombreUsuario, pContraseña = usuario.Contraseña, pNombre = usuario.Nombre, pApellido = usuario.Apellido});
        }
    }
    public Usuarios ObtenerUsuario(string nombreUsuario, string contrasena){
        Usuarios usuario = null;
        string query = "SELECT TOP 1 * FROM Usuarios WHERE NombreUsuario = @pNombreUsuario AND Contraseña = @pContraseña";
        using(SqlConnection connection = new SqlConnection(_connectionString)){
            usuario = connection.QueryFirstOrDefault<Usuarios>(query, new { pNombreUsuario = nombreUsuario, pContraseña = contrasena });
        }
        return usuario;
    }
        public Usuarios ObtenerUsuarioPorNombre(string usuario)
    {
        using (SqlConnection db = new SqlConnection(_connectionString))
        {
            string sql = "SELECT * FROM Usuarios WHERE NombreUsuario = @usuario OR Nombre = @usuario";
            return db.QueryFirstOrDefault<Usuarios>(sql, new { usuario });
        }
    }


    public List<Peliculas> ObtenerPeliculas()
    {
        using (SqlConnection connection = new SqlConnection(_connectionString))
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
                    PosterUrl
                FROM Peliculas";

            return connection.Query<Peliculas>(query).ToList();
        }
    }




}