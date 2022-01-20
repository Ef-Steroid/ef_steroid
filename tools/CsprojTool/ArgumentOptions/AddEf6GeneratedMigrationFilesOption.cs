using System.Text.Json;
using CommandLine;
using CsprojTool.Data;
using CsprojTool.Model;

namespace CsprojTool.ArgumentOptions;

[Verb("add-ef6-generated-migration-files", HelpText = "Add Entity Framework 6 generated migration files to csproj")]
public class AddEf6GeneratedMigrationFilesOption : BaseOption
{
    [Option("add-migration-dto",
        HelpText = "The json string of the \"ef6.exe migrations add\" output in base64 format.")]
    public string AddMigrationDto { get; set; } = null!;

    public override Task ExecuteAsync()
    {
        var ef6MigrationDto =
            JsonSerializer.Deserialize(Convert.FromBase64String(AddMigrationDto),
                Ef6MigrationDtoJsonContext.Default.Ef6MigrationDto);
        if (!File.Exists(CsprojPath))
        {
            throw new Exception("Csproj file does not exist");
        }

        var migrationTuple = ParseItems(ef6MigrationDto);
        if (migrationTuple.projectRootElement.Items.All(x =>
                x.ItemType == CsprojItemTypes.Compile && x.Include != migrationTuple.migrationName))
        {
            migrationTuple.projectRootElement.AddItem(CsprojItemTypes.Compile, migrationTuple.migrationName);
        }

        if (migrationTuple.projectRootElement.Items.All(x =>
                x.ItemType == CsprojItemTypes.Compile && x.Include != migrationTuple.migrationDesigner))
        {
            migrationTuple.projectRootElement.AddItem(CsprojItemTypes.Compile, migrationTuple.migrationDesigner, new[]
            {
                new KeyValuePair<string, string>(CsprojItemTypes.DependentUpon, migrationTuple.migrationFileName)
            });
        }

        if (migrationTuple.projectRootElement.Items.All(x =>
                x.ItemType == CsprojItemTypes.EmbeddedResource && x.Include != migrationTuple.migrationResources))
        {
            migrationTuple.projectRootElement.AddItem(CsprojItemTypes.EmbeddedResource,
                migrationTuple.migrationResources, new[]
                {
                    new KeyValuePair<string, string>(CsprojItemTypes.DependentUpon, migrationTuple.migrationFileName)
                });
        }

        migrationTuple.projectRootElement.Save();

        return Task.CompletedTask;
    }
}
