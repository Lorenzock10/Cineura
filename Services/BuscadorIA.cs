
using System.Net.Http.Headers;
using System.Text.Json;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        private static HttpClient CreateHttpClient()
        {
            return new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(30)
            };
        }

        public async Task<string> InterpretarBusquedaAsync(string busqueda)
        {
            string? apiKey = Environment.GetEnvironmentVariable("GROQ_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "No se encontró la clave de Groq. Configurá GROQ_API_KEY en CMD."
                );
            }

            string prompt = """
                Sos Nova, el buscador inteligente de Cineura.

                Tu tarea es interpretar el mensaje del usuario y convertir
                sus preferencias en filtros para buscar películas.

                Respondé únicamente con un objeto JSON válido.
                No incluyas explicaciones, Markdown ni texto fuera del JSON.

                Usá exactamente estas propiedades:
                - genero: string o null
                - animo: string o null
                - duracionMaxima: número entero o null

                GÉNEROS DISPONIBLES:
                Animacion, Comedia, Drama, Aventura.

                ÁNIMOS DISPONIBLES:
                Alegre, Divertido, Reflexivo, Inspirador, Emotivo,
                Emocionante.

                REGLAS:
                1. Si el usuario pide un género, identificá el más adecuado.
                2. Si describe cómo quiere sentirse o qué tipo de experiencia
                   busca, identificá el ánimo correspondiente.
                3. Si menciona una duración, convertíla a minutos.
                4. "Menos de 2 horas" equivale a una duración máxima de 120 minutos.
                5. "Una hora y media" equivale a 90 minutos.
                6. Si no menciona un criterio, devolvé null para ese campo.
                7. No inventes preferencias que el usuario no expresó.
                8. No devuelvas todos los filtros como null si el usuario
                   expresó alguna preferencia que se pueda identificar.
                9. No agregues propiedades diferentes de las indicadas.

                EJEMPLOS:

                Mensaje: Quiero una comedia graciosa.
                JSON: {"genero":"Comedia","animo":"Divertido","duracionMaxima":null}

                Mensaje: Estoy feliz y quiero algo de menos de dos horas.
                JSON: {"genero":null,"animo":"Alegre","duracionMaxima":120}

                Mensaje: Quiero una película de aventura que me emocione.
                JSON: {"genero":"Aventura","animo":"Emocionante","duracionMaxima":null}

                Mensaje: Quiero un drama profundo de 90 minutos como máximo.
                JSON: {"genero":"Drama","animo":"Reflexivo","duracionMaxima":90}

                Mensaje del usuario:
                """ + "\n" + busqueda;

            using var client = CreateHttpClient();

            var requestBody = new
            {
                model = "openai/gpt-oss-120b",
                messages = new[]
                {
                    new
                    {
                        role = "system",
                        content = "Convertí las preferencias del usuario en filtros. Respondé únicamente con JSON válido."
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

            using var request = new HttpRequestMessage(
                HttpMethod.Post,
                "https://api.groq.com/openai/v1/chat/completions")
            {
                Content = JsonContent.Create(requestBody)
            };

            request.Headers.Authorization =
                new AuthenticationHeaderValue("Bearer", apiKey);

            using var response = await client.SendAsync(request);

            string responseBody =
                await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException(
                    $"Groq API respondió con estado {(int)response.StatusCode}: {responseBody}"
                );
            }

            using JsonDocument document =
                JsonDocument.Parse(responseBody);

            string? contenido = document.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString();

            if (string.IsNullOrWhiteSpace(contenido))
            {
                throw new InvalidOperationException(
                    "Groq no devolvió contenido válido."
                );
            }

            return contenido;
        }
    }
}
