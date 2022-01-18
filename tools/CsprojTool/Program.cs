// See https://aka.ms/new-console-template for more information

using System.Text.Json;
using CommandLine;
using CsprojTool.ArgumentOptions;
using CsprojTool.Model;
using Microsoft.Build.Construction;

await Parser.Default.ParseArguments<AddEf6GeneratedMigrationFilesOption>(args)
    .MapResult(option =>
    {
        try
        {
            var addMigrationDto =
                JsonSerializer.Deserialize(Convert.FromBase64String(option.AddMigrationDto), AddMigrationDtoJsonContext.Default.AddMigrationDto);
            AddEf6GeneratedMigrationFilesToCsproj(option.CsprojPath, addMigrationDto);

            return Task.CompletedTask;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex);
            throw;
        }
    }, errors =>
    {
        foreach (var err in errors)
        {
            Console.WriteLine(err?.ToString());
        }

        return Task.FromResult(1);
    });


void AddEf6GeneratedMigrationFilesToCsproj(string csprojPath, AddMigrationDto addMigrationDto)
{
    if (!File.Exists(csprojPath))
    {
        throw new Exception("Csproj file does not exist");
    }
    var csprojDirectory = Path.GetDirectoryName(csprojPath)!;
    var migrationName = Path.GetRelativePath(csprojDirectory, addMigrationDto.Migration);
    var migrationFileName = Path.GetFileName(migrationName);

    var migrationDesigner = Path.GetRelativePath(csprojDirectory, addMigrationDto.MigrationDesigner);
    var migrationResources = Path.GetRelativePath(csprojDirectory, addMigrationDto.MigrationResources);

    var projectRootElement = ProjectRootElement.Open(csprojPath)!;
    if (projectRootElement.Items.All(x => x.Include != migrationName))
    {
        projectRootElement.AddItem("Compile", migrationName);
    }

    if (projectRootElement.Items.All(x => x.Include != migrationDesigner))
    {
        projectRootElement.AddItem("Compile", migrationDesigner, new[]
        {
            new KeyValuePair<string, string>("DependentUpon", migrationFileName)
        });
    }

    if (projectRootElement.Items.All(x => x.Include != migrationResources))
    {
        projectRootElement.AddItem("EmbeddedResource", migrationResources, new[]
        {
            new KeyValuePair<string, string>("DependentUpon", migrationFileName)
        });
    }

    projectRootElement.Save();
}
