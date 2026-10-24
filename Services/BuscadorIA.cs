using System.Net.Http.Headers;
using System.Text.Json;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public string InterpretarBusqueda(string busqueda)
        {
            string apiKey = Environment.GetEnvironmentVariable("GROQ_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new Exception(
                    "No se encontro la clave de Groq. Configura GROQ_API_KEY en CMD."
                );
            }

            string prompt =
                "Sos Nova, el buscador inteligente de Cineura. " +
                "Interpreta las preferencias del usuario para buscar peliculas. " +
                "Responde solamente con un objeto JSON valido. " +
                "Usa exactamente estas propiedades: genero, animo y duracionMaxima. " +
                "Los generos disponibles son Animacion, Comedia, Drama y Aventura. " +
                "Los animos disponibles son Alegre, Divertido, Reflexivo, Inspirador, Emotivo y Emocionante. " +
                "Si el usuario no menciona un genero, usa null. " +
                "Si no menciona un animo, usa null. " +
                "Si no menciona una duracion, usa null. " +
                "Menos de dos horas equivale a 119 minutos. " +
                "Hasta dos horas equivale a 120 minutos. " +
                "Una hora y media equivale a 90 minutos. " +
                "No inventes preferencias. " +
                "Ejemplo: {\"genero\":\"Comedia\",\"animo\":\"Divertido\",\"duracionMaxima\":90}. " +
                "Mensaje del usuario: " + busqueda;

            HttpClient cliente = new HttpClient();
            cliente.Timeout = TimeSpan.FromSeconds(30);

            HttpRequestMessage solicitud = new HttpRequestMessage(
                HttpMethod.Post,
                "https://api.groq.com/openai/v1/chat/completions"
            );

            solicitud.Headers.Authorization =
                new AuthenticationHeaderValue("Bearer", apiKey);

            object datos = new
            {
                model = "openai/gpt-oss-120b",
                messages = new[]
                {
                    new
                    {
                        role = "system",
                        content = "Responde solamente con JSON valido."
                    },
                    new
                    {
                        role = "user",
                        content = prompt
                    }
                },
                temperature = 0.1,
                response_format = new
                {
                    type = "json_object"
                }
            };

            solicitud.Content = JsonContent.Create(datos);

            HttpResponseMessage respuesta = cliente.Send(solicitud);

            string respuestaTexto =
                respuesta.Content.ReadAsStringAsync().Result;

            if (!respuesta.IsSuccessStatusCode)
            {
                throw new Exception("Error de Groq: " + respuestaTexto);
            }

            JsonDocument documento = JsonDocument.Parse(respuestaTexto);

            string contenido = documento.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString();

            if (string.IsNullOrWhiteSpace(contenido))
            {
                throw new Exception("Groq no devolvio una respuesta valida.");
            }

            documento.Dispose();
            respuesta.Dispose();
            solicitud.Dispose();
            cliente.Dispose();

            return contenido;
        }
    }
}