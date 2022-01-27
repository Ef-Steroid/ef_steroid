using System.Text.Json;
using CommandLine;
using CsprojTool.Data;
using CsprojTool.Model;
using Microsoft.Build.Construction;

namespace CsprojTool.ArgumentOptions;

[Verb("remove-ef6-generated-migration-files",
    HelpText = "Remove Entity Framework 6 generated migration files to csproj")]
public class RemoveEf6GeneratedMigrationFilesOption : BaseOption
{
    [Option("remove-migration-dto", HelpText = "The json string of EfMigrationDto in base64 format.")]
    public string RemoveMigrationDto { get; set; } = null!;

    public override Task ExecuteAsync()
    {
        var ef6MigrationDto =
            JsonSerializer.Deserialize(Convert.FromBase64String(RemoveMigrationDto),
                Ef6MigrationDtoJsonContext.Default.Ef6MigrationDto);

        if (!File.Exists(CsprojPath))
        {
            throw new Exception("Csproj file does not exist");
        }

        var migrationTuple = ParseItems(ef6MigrationDto);

        migrationTuple.projectRootElement.Items.RemoveWhere(x =>
            x.ItemType == CsprojItemTypes.Compile && x.Include == migrationTuple.migrationName);
        migrationTuple.projectRootElement.Items.RemoveWhere(x =>
            x.ItemType == CsprojItemTypes.Compile && x.Include == migrationTuple.migrationDesigner);
        migrationTuple.projectRootElement.Items.RemoveWhere(x =>
            x.ItemType == CsprojItemTypes.EmbeddedResource && x.Include == migrationTuple.migrationResources);

        migrationTuple.projectRootElement.Save();

        return Task.CompletedTask;
    }
}

internal static class ProjectItemElementExtensions
{
    /// <summary>
    /// Remove item that satisfies <see cref="predicate"/>.
    ///
    /// Do nothing if none of the items satisfies <see cref="predicate"/>.
    /// </summary>
    /// <param name="projectItemElements">The ProjectItemElements.</param>
    /// <param name="predicate">A function to test each element for a condition.</param>
    internal static void RemoveWhere(
        this ICollection<ProjectItemElement> projectItemElements, Func<ProjectItemElement, bool> predicate
    )
    {
        var projectItemElement = projectItemElements.FirstOrDefault(predicate);
        if (projectItemElement == null) return;

        projectItemElements.Remove(projectItemElement);
    }
}
