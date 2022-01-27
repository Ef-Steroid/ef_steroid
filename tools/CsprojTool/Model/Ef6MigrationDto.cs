using System.Text.Json.Serialization;

namespace CsprojTool.Model;

public record struct Ef6MigrationDto
{
    /// <summary>
    /// The migration Id (a.k.a the migration name provided by the user).
    /// <br />
    /// E.g. 202201150842177_InitialMigration.cs
    /// </summary>
    public string Migration { get; set; }

    /// <summary>
    /// The migration resource file.
    /// <br />
    /// E.g. 202201150842177_InitialMigration.resx
    /// </summary>
    public string MigrationResources { get; set; }

    /// <summary>
    /// The migration designer file.
    /// <br />
    /// E.g. 202201150842177_InitialMigration.Designer.cs
    /// </summary>
    public string MigrationDesigner { get; set; }
}

[JsonSerializable(typeof(Ef6MigrationDto))]
[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
public partial class Ef6MigrationDtoJsonContext : JsonSerializerContext
{
}
