using System.ComponentModel.DataAnnotations.Schema;

namespace EfSteroidSqlite.Entity.EntityBase;

public class EntityDto<TKey>
{
    public TKey Id { get; protected set; } = default!;

    protected EntityDto()
    {
    }

    protected EntityDto(TKey id)
    {
        Id = id;
    }
}
