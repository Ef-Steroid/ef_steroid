// See https://aka.ms/new-console-template for more information

using CommandLine;
using CsprojTool.ArgumentOptions;

await Parser.Default.ParseArguments<AddEf6GeneratedMigrationFilesOption, RemoveEf6GeneratedMigrationFilesOption>(args)
    .MapResult(
        option =>
        {
            try
            {
                return option switch
                {
                    AddEf6GeneratedMigrationFilesOption addEf6GeneratedMigrationFilesOption =>
                        addEf6GeneratedMigrationFilesOption.ExecuteAsync(),
                    RemoveEf6GeneratedMigrationFilesOption removeEf6GeneratedMigrationFilesOption =>
                        removeEf6GeneratedMigrationFilesOption.ExecuteAsync(),
                    _ => throw new NotImplementedException($"{option} is not implemented.")
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                throw;
            }
        },
        errors =>
        {
            foreach (var err in errors)
            {
                Console.WriteLine(err?.ToString());
            }

            return Task.FromResult(1);
        });
