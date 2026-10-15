
using Microsoft.SemanticKernel;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public async Task<string> InterpretarBusquedaAsync(string busqueda)
        {
            string? apiKey = Environment.GetEnvironmentVariable("OLLAMA_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "No se encontró la clave de Ollama."
                );
            }

            var builder = Kernel.CreateBuilder();

            #pragma warning disable SKEXP0010
            builder.AddOpenAIChatCompletion(
                modelId: "gemma4:31b",
                endpoint: new Uri("https://ollama.com/v1"),
                apiKey: apiKey
            );
            #pragma warning restore SKEXP0010

            var kernel = builder.Build();

            string prompt =
                "Sos Nova, el buscador inteligente de Cineura. " +
                "Interpretá lo que quiere ver el usuario. " +
                "Devolvé solamente un JSON con los campos genero, animo " +
                "y duracionMaxima, expresada en minutos. " +
                "Si un dato no está especificado, usá null. " +
                "Mensaje del usuario: " + busqueda;

            var resultado = await kernel.InvokePromptAsync(prompt);

            return resultado.ToString();
        }
    }
}
