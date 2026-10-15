using Microsoft.SemanticKernel;

namespace Cineura.Services
{
    public class BuscadorIA
    {
        public async Task<string> InterpretarBusquedaAsync(string busqueda)
        {
            string? apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY");

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "No se encontró la clave de OpenAI. Configurala antes de usar el buscador inteligente."
                );
            }

            var builder = Kernel.CreateBuilder();

            builder.AddOpenAIChatCompletion(
                modelId: "gpt-4o-mini",
                apiKey: apiKey
            );

            var kernel = builder.Build();

            string prompt =
                "Sos el buscador inteligente de Cineura. " +
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