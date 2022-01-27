using FastDotnetEfSqlite.Entity.EntityBase;
using FastDotnetEfSqlite.Shared;

namespace FastDotnetEfSqlite.Entity;

public class EfPanel : EntityDto<int>
{
    public Uri DirectoryUri { get; set; } = null!;

    public Uri? ConfigFileUri { get; set; }

    public ProjectEfType? ProjectEfType { get; set; }

    protected EfPanel() : base()
    {
    }

    protected EfPanel(int id) : base(id)
    {
    }
}
