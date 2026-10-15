namespace Cineura.Models;

public class Tendencias
{
    public int IdTendencia { get; set; }
    public int IdPelicula { get; set; }
    public int CantidadInteracciones { get; set; }
    public DateTime FechaActualizacion { get; set; }
}
