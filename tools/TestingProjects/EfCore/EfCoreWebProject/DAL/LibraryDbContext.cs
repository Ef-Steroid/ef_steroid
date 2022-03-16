using EfCoreWebProject.Models;
using Microsoft.EntityFrameworkCore;

namespace EfCoreWebProject.DAL;

public class LibraryDbContext : DbContext
{
    public DbSet<Library> Libraries { get; set; } = null!;

    public LibraryDbContext(DbContextOptions<LibraryDbContext> options) : base(options)
    {
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
#if DEBUG
            .AddJsonFile("appsettings.Development.json")
#else
            .AddJsonFile("appsettings.json")
#endif
            .Build();

        var connectionString = configuration.GetConnectionString("LibraryDatabase");
        optionsBuilder.UseSqlServer(connectionString);
    }
}
