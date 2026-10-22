using System.Net.Http.Headers;
using System.Text.Json;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        private static HttpClient CreateHttpClient()
        {
            var handler = new HttpClientHandler();

            handler.ServerCertificateCustomValidationCallback =
                (request, certificate, chain, errors) =>
                    errors == System.Net.Security.SslPolicyErrors.None ||
                    errors == System.Net.Security.SslPolicyErrors.RemoteCertificateChainErrors;

            return new HttpClient(handler)
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

            string prompt =
                "Sos Nova, el buscador inteligente de Cineura. " +
                "Interpretá qué película quiere ver el usuario. " +
                "Respondé únicamente con un JSON válido, sin Markdown ni explicaciones. " +
                "Usá exactamente estos campos: genero, animo, duracionMaxima. " +
                "Los géneros disponibles son Animacion, Comedia, Drama y Aventura. " +
                "Los ánimos disponibles son Alegre, Divertido, Reflexivo, Inspirador, Emotivo y Emocionante. " +
                "Si el usuario no indica género, usá null. " +
                "Si el usuario no indica ánimo, usá null. " +
                "Si el usuario no indica duración máxima, usá null. " +
                "No inventes preferencias. " +
                "La duración máxima debe ser un número entero o null. " +
                "Ejemplo: {\"genero\":\"Aventura\",\"animo\":\"Emocionante\",\"duracionMaxima\":null}. " +
                "Mensaje del usuario: " + busqueda;

            using var client = CreateHttpClient();

            var requestBody = new
            {
                model = "openai/gpt-oss-120b",
                messages = new[]
                {
                    new { role = "system", content = "Respondé solo con JSON válido y sin texto extra." },
                    new { role = "user", content = prompt }
                },
                temperature = 0.2,
                response_format = new { type = "json_object" }
            };

            using var request = new HttpRequestMessage(HttpMethod.Post, "https://api.groq.com/openai/v1/chat/completions")
            {
                Content = JsonContent.Create(requestBody)
            };

            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

            using var response = await client.SendAsync(request);
            string responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException(
                    $"Groq API respondió con estado {(int)response.StatusCode}: {responseBody}"
                );
            }

            using JsonDocument document = JsonDocument.Parse(responseBody);
            string? contenido = document.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString();

            if (string.IsNullOrWhiteSpace(contenido))
            {
                throw new InvalidOperationException("Groq no devolvió contenido válido.");
            }

            return contenido;
        }
    }
}
