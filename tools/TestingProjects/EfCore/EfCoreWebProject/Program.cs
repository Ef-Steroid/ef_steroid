using EfCoreWebProject.DAL;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var studentConnectionString = builder.Configuration.GetConnectionString("StudentDatabase");
builder.Services.AddDbContext<SchoolDbContext>(options =>
    options.UseSqlServer(studentConnectionString));
var libraryConnectionString = builder.Configuration.GetConnectionString("LibraryDatabase");
builder.Services.AddDbContext<LibraryDbContext>(options =>
    options.UseSqlServer(libraryConnectionString));
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
