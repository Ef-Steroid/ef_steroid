using CommandLine;

namespace CsprojTool.ArgumentOptions;

public abstract class BaseOption
{
    [Option('c', "csproj-path", HelpText = "The path to the csproj file")]
    public string CsprojPath { get; set; } = null!;
}
