
using Microsoft.SemanticKernel;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public async Task<string> InterpretarBusquedaAsync(string busqueda)
        {
            string? apiKey = Environment.GetEnvironmentVariable("GROQ_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "No se encontró la clave de Groq. Configurá GROQ_API_KEY en CMD."
                );
            }

            var builder = Kernel.CreateBuilder();

            #pragma warning disable SKEXP0010
            builder.AddOpenAIChatCompletion(
                modelId: "llama-3.3-70b-versatile",
                endpoint: new Uri("https://api.groq.com/openai/v1"),
                apiKey: apiKey
            );
            #pragma warning restore SKEXP0010

            var kernel = builder.Build();

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

            var resultado = await kernel.InvokePromptAsync(prompt);

            return resultado.ToString();
        }
    }
}
