using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using SmartAiPos.Api.Data;
using SmartAiPos.Api.Repositories;
using SmartAiPos.Api.Services;
using System.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

// ---------------- CONTROLLERS ----------------
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

// ---------------- SWAGGER ----------------
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Smart AI POS API",
        Version = "v1"
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// ---------------- DB ----------------
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ---------------- JWT ----------------
var jwtKey = Encoding.UTF8.GetBytes(
    builder.Configuration["Jwt:Key"] ?? "dev-secret-change-me-minimum-32-chars"
);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,

            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(jwtKey),

            ClockSkew = TimeSpan.FromMinutes(2),

            // 🔥 KLJUČ FIX (ROLE + USER ID)
            RoleClaimType = ClaimTypes.Role,
            NameClaimType = ClaimTypes.NameIdentifier
        };
    });

builder.Services.AddAuthorization();

// ---------------- CORS ----------------
builder.Services.AddCors(options =>
    options.AddPolicy("app", policy =>
        policy.AllowAnyHeader()
              .AllowAnyMethod()
              .AllowAnyOrigin()));

// ---------------- SERVICES ----------------
builder.Services.AddScoped<IAppRepository, EfAppRepository>();
builder.Services.AddScoped<JwtTokenService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<ProductService>();
builder.Services.AddScoped<SaleService>();
builder.Services.AddScoped<InventoryService>();
builder.Services.AddScoped<DashboardService>();
builder.Services.AddScoped<AiService>();
builder.Services.AddScoped<OrderService>();
builder.Services.AddScoped<PublicProductService>();
builder.Services.AddScoped<CartService>();
builder.Services.AddScoped<OrderService>();

// ---------------- APP ----------------
var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("app");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// ---------------- SEED ----------------
using (var scope = app.Services.CreateScope())
{
    await SeedData.InitializeAsync(
        scope.ServiceProvider.GetRequiredService<AppDbContext>()
    );
}

app.Run();
