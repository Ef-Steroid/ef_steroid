using FastDotnetEfSqlite.Entity.EntityBase;

namespace FastDotnetEfSqlite.Entity;

public class EfPanel : EntityDto<int>
{
    public string DirectoryUrl { get; set; } = null!;

    public string ConfigFileUrl { get; set; } = null!;

    protected EfPanel() : base()
    {
    }

    protected EfPanel(int id) : base(id)
    {
    }
}
