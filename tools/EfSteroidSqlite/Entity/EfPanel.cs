using EfSteroidSqlite.Entity.EntityBase;
using EfSteroidSqlite.Shared;

namespace EfSteroidSqlite.Entity;

public class EfPanel : EntityDto<int>
{
    public Uri DirectoryUri { get; set; } = null!;

    public Uri? ConfigFileUri { get; set; }

    public ProjectEfType? ProjectEfType { get; set; }

    public string? DbContextName { get; set; }

    protected EfPanel() : base()
    {
    }

    protected EfPanel(int id) : base(id)
    {
    }
}
