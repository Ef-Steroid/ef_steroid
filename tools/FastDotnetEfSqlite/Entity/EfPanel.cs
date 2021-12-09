using FastDotnetEfSqlite.Entity.EntityBase;

namespace FastDotnetEfSqlite.Entity;

public class EfPanel : EntityDto<Guid>
{
    public string DirectoryUrl { get; set; }

    protected EfPanel() : base()
    {
    }

    protected EfPanel(Guid id) : base(id)
    {
    }
}
