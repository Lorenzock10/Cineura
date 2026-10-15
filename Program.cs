using Microsoft.SemanticKernel; // 👈 1. AGREGADO: Directiva de Semantic Kernel

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSession();

// Add services to the container.
builder.Services.AddControllersWithViews();

// 👈 2. AGREGADO: Registrar Semantic Kernel en los servicios de tu aplicación
builder.Services.AddKernel()
    .AddOpenAIChatCompletion(
        modelId: "gpt-4o-mini", 
        apiKey: "TU_API_KEY_AQUI" // Reemplaza con tu clave de OpenAI
    );

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.UseSession();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();
