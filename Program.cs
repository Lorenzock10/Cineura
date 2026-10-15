using Cineura.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSession();

// Add services to the container.
builder.Services.AddControllersWithViews();

// Registrar el buscador inteligente de Cineura.
builder.Services.AddScoped<BuscadorIA>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
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