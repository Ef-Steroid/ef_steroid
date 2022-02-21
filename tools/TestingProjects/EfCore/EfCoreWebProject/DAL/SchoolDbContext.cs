using EfCoreWebProject.Models;
using Microsoft.EntityFrameworkCore;

namespace EfCoreWebProject.DAL;

public class SchoolDbContext : DbContext
{
    public DbSet<Student> Students { get; set; } = null!;

    public SchoolDbContext(DbContextOptions<SchoolDbContext> options) : base(options)
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

        var connectionString = configuration.GetConnectionString("StudentDatabase");
        optionsBuilder.UseSqlServer(connectionString);
    }
}
