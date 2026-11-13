using System.Text;
using internetapi.Data;
using internetapi.Models;
using internetapi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// CORS: em desenvolvimento aceita qualquer origem (Live Server, arquivo aberto etc.).
// Em producao, liste apenas o endereco real do site. O app mobile nao usa CORS.
builder.Services.AddCors(o => o.AddPolicy("Front", p =>
{
    if (builder.Environment.IsDevelopment())
        p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
    else
        p.WithOrigins("https://SEU-SITE.exemplo.com").AllowAnyHeader().AllowAnyMethod();
}));

builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddSingleton<TokenService>();

var jwtKey = builder.Configuration["Jwt:Key"];
if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException("Configure Jwt:Key com pelo menos 32 caracteres (use dotnet user-secrets).");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o => o.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    });
builder.Services.AddAuthorization();

var app = builder.Build();

// Cria o usuario administrador na primeira execucao (senha vem da configuracao)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var senhaAdmin = builder.Configuration["Admin:Senha"];
    if (!string.IsNullOrWhiteSpace(senhaAdmin) && !await db.Usuarios.AnyAsync(u => u.Perfil == "Admin"))
    {
        db.Usuarios.Add(new Usuario
        {
            Nome = "Administrador EDUNET",
            Email = "admin@edunet.com.br",
            SenhaHash = SenhaHasher.Gerar(senhaAdmin),
            Perfil = "Admin"
        });
        await db.SaveChangesAsync();
    }
}

app.UseCors("Front");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
