
using Microsoft.SemanticKernel;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public async Task<string> InterpretarBusquedaAsync(string busqueda)
        {
            string? apiKey = Environment.GetEnvironmentVariable("OPENROUTER_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "No se encontró la clave de OpenRouter."
                );
            }

            var builder = Kernel.CreateBuilder();

            #pragma warning disable SKEXP0010
            builder.AddOpenAIChatCompletion(
                modelId: "openrouter/free",
                endpoint: new Uri("https://openrouter.ai/api/v1"),
                apiKey: apiKey
            );
            #pragma warning restore SKEXP0010

            var kernel = builder.Build();

            string prompt =
                "Sos Nova, el buscador inteligente de Cineura. " +
                "Interpretá qué película quiere ver el usuario. " +
                "Respondé únicamente con un JSON válido. " +
                "Usá exactamente estos campos: genero, animo, duracionMaxima. " +
                "No cambies ni escribas mal los nombres de los campos. " +
                "Los géneros disponibles son Animacion, Comedia, Drama y Aventura. " +
                "Los ánimos disponibles son Alegre, Divertido, Reflexivo, Inspirador, Emotivo y Emocionante. " +
                "Si el usuario no indica género, usá null. " +
                "Si el usuario no indica ánimo, usá null. " +
                "Si el usuario no indica duración máxima, usá null. " +
                "No inventes preferencias. " +
                "Ejemplo: {\"genero\":\"Aventura\",\"animo\":\"Emocionante\",\"duracionMaxima\":null}. " +
                "Mensaje del usuario: " + busqueda;

            var resultado = await kernel.InvokePromptAsync(prompt);

            return resultado.ToString();
        }
    }
}
