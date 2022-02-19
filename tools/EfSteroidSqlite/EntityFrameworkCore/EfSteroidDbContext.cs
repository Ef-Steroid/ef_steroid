using EfSteroidSqlite.Entity;
using Microsoft.EntityFrameworkCore;

namespace EfSteroidSqlite.EntityFrameworkCore;

public class EfSteroidDbContext : DbContext
{
    public DbSet<EfPanel> EfPanels { get; set; } = null!;

    public string DbPath { get; set; }

    public EfSteroidDbContext()
    {
        const Environment.SpecialFolder folder = Environment.SpecialFolder.LocalApplicationData;
        var path = Environment.GetFolderPath(folder);
        DbPath = Path.Join(path, "EfSteroidSqlite", "EfSteroidSqlite.db");
        Directory.CreateDirectory(Directory.GetParent(DbPath)!.ToString());
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlite($"Data Source={DbPath}");
    }
}
