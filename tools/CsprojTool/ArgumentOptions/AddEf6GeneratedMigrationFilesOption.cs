using CommandLine;

namespace CsprojTool.ArgumentOptions;

[Verb("add-ef6-generated-migration-files", HelpText = "Add Entity Framework 6 generated migration files to csproj")]
public class AddEf6GeneratedMigrationFilesOption : BaseOption
{
    [Option("add-migration-dto", HelpText = "The json string of the \"ef6.exe migrations add\" output in base64 format.")]
    public string AddMigrationDto { get; set; } = null!;
}
