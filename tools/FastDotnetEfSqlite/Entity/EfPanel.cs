using FastDotnetEfSqlite.Entity.EntityBase;

namespace FastDotnetEfSqlite.Entity;

public class EfPanel : EntityDto<int>
{
    public string DirectoryUrl { get; set; }

    protected EfPanel() : base()
    {
    }

    protected EfPanel(int id) : base(id)
    {
    }
}