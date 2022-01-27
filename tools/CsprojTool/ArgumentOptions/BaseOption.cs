using CommandLine;
using CsprojTool.Model;
using Microsoft.Build.Construction;

namespace CsprojTool.ArgumentOptions;

public abstract class BaseOption
{
    [Option('c', "csproj-path", HelpText = "The path to the csproj file")]
    public string CsprojPath { get; set; } = null!;

    public abstract Task ExecuteAsync();


    public (string migrationName, string migrationFileName, string migrationDesigner, string migrationResources,
        ProjectRootElement projectRootElement) ParseItems(Ef6MigrationDto ef6MigrationDto)
    {
        var csprojDirectory = Path.GetDirectoryName(CsprojPath)!;
        var migrationName = Path.GetRelativePath(csprojDirectory, ef6MigrationDto.Migration);
        var migrationFileName = Path.GetFileName(migrationName);

        var migrationDesigner = Path.GetRelativePath(csprojDirectory, ef6MigrationDto.MigrationDesigner);
        var migrationResources = Path.GetRelativePath(csprojDirectory, ef6MigrationDto.MigrationResources);

        var projectRootElement = ProjectRootElement.Open(CsprojPath)!;

        return (migrationName, migrationFileName, migrationDesigner, migrationResources, projectRootElement);
    }
}
