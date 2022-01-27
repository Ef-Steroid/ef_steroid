using FastDotnetEfSqlite.Entity;
using Microsoft.EntityFrameworkCore;

namespace FastDotnetEfSqlite.EntityFrameworkCore;

public class FastDotnetEfDbContext : DbContext
{
    public DbSet<EfPanel> EfPanels { get; set; }

    public string DbPath { get; set; }

    public FastDotnetEfDbContext()
    {
        const Environment.SpecialFolder folder = Environment.SpecialFolder.LocalApplicationData;
        var path = Environment.GetFolderPath(folder);
        DbPath = Path.Join(path, "FastDotnetEfSqlite", "FastDotnetEf.db");
        Directory.CreateDirectory(Directory.GetParent(DbPath)!.ToString());
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlite($"Data Source={DbPath}");
    }
}
