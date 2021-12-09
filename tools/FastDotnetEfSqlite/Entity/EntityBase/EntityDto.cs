namespace FastDotnetEfSqlite.Entity.EntityBase;

public class EntityDto<TKey>
{
    public TKey Id { get; protected set; }

    protected EntityDto()
    {
    }

    protected EntityDto(TKey id)
    {
        Id = id;
    }
}
