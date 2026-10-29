namespace Cineura.Models;

public class Comentarios
{
    public int IdComentario { get; set; }
    public int IdUsuario { get; set; }
    public int IdPelicula { get; set; }
    public string Texto { get; set; }
    public DateTime Fecha { get; set; }
    public string NombreUsuario { get; set; }
}
