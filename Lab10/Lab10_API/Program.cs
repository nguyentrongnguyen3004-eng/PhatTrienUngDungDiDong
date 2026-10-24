using Lab10_API.Entities;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// 1. Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 2. Khai báo dependencies cho DbContext kết nối SQL Server
builder.Services.AddDbContext<QuanLyDeTaiContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("QuanLyDeTaiDB")));

// 3. Khai báo CORS cho phép ứng dụng Flutter truy xuất vào API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();
