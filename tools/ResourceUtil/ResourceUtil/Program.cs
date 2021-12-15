using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using CommandLine;
using DocumentFormat.OpenXml.Spreadsheet;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using ShellProgressBar;
using SpreadsheetLight;

namespace ResourceUtil
{
    class Options
    {
        [Option('o', "output", Required = false, HelpText = "The location to convert this AppResource.json to excel.")]
        public string? OutputPath { get; set; }

        [Option('i', "input", Required = false,
            HelpText = "The location to convert an excel file to AppResource.json.")]
        public string? InputPath { get; set; }

        [Option('r', "remove", Required = false, HelpText = "The resource to be removed. e.g. zh_HK en_US")]
        public IEnumerable<string> ResourcesToRemove { get; set; }
    }

    class Program
    {
        const string ResourceRelativePath = @"localization/AppResource.json";
        const string I18NPath = @"i18n/";

        const string Key = "key";
        const string En = "en";
        const string ZhHans = "zh_Hans";

        const string ExcelWorkSheetName = "Localization";

        static async Task Main(string[] args)
        {
            try
            {
                await Parser.Default.ParseArguments<Options>(args).MapResult(async o =>
                {
                    try
                    {
                        if (!string.IsNullOrWhiteSpace(o.InputPath))
                            await WriteExcelResourceToJsonAsync(o.InputPath!);
                        (HashSet<string> definedCultures, List<TextTranslation> translations) =
                            await ReadResourcesAsync(o.ResourcesToRemove.ToList());
                        await PopulateFilesAsync(translations);

                        var orderedDefinedCultures = definedCultures.OrderBy(x => x).ToList();
                        await RewriteResourcesAsync(orderedDefinedCultures, translations);
                        await PopulateResourceToi18NAsync(orderedDefinedCultures, translations);

                        if (!string.IsNullOrWhiteSpace(o.OutputPath))
                            WriteResourceToExcel(translations, o.OutputPath!);

                        Console.WriteLine("Done");
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
                        Console.WriteLine(err.ToString());
                    }

                    return Task.FromResult(1);
                });
            }
            catch
            {
                // Do nothing
            }
        }

        private static Task WriteExcelResourceToJsonAsync(string inputPath)
        {
            Console.WriteLine("Start parsing excel to json");

            var translations = new List<TextTranslation>();
            List<string> definedCultures;
            using (var slDocument = new SLDocument(inputPath, ExcelWorkSheetName))
            {
                var keyExcelColumn = TextTranslation.ExcelColumnByLocalizations[Key];
                var excelColumnByLocalizationsWithoutTitle = TextTranslation
                    .ExcelColumnByLocalizations
                    .Where((x, i) => i != 0)
                    .ToDictionary(x => x.Key, x => x.Value);
                for (int i = 0; i < slDocument.GetWorksheetStatistics().NumberOfRows - 1; i++)
                {
                    // Reason of + 2:
                    // - Excel starts with 1 instead of 0
                    // - Skip the title

                    var translationRow = i + 2;
                    var translation =
                        new TextTranslation(
                            slDocument.GetCellValueAsString(GetExcelIndex(keyExcelColumn, translationRow)));
                    translations.Add(translation);
                    foreach (var entry in excelColumnByLocalizationsWithoutTitle)
                    {
                        var localizedTranslation = slDocument.GetCellValueAsString(GetExcelIndex(entry.Value,
                            translationRow));
                        translation.Translations[entry.Key] = string.IsNullOrWhiteSpace(localizedTranslation)
                            ? null
                            : localizedTranslation;
                    }
                }

                definedCultures = excelColumnByLocalizationsWithoutTitle
                    .Keys
                    .ToList();
            }

            return RewriteResourcesAsync(definedCultures,
                translations,
                skipReferenceCheckingLog: true);
        }

        private static string GetExcelIndex(string column, int row)
        {
            return $"{column}{row}";
        }

        private static void WriteResourceToExcel(List<TextTranslation> translations, string outputPath)
        {
            Console.WriteLine("Start writing json to excel");
            using var slDocument = new SLDocument();
            slDocument.AddWorksheet(ExcelWorkSheetName);
            var titleRow = 1;

            for (int i = 0; i < translations.Count; i++)
            {
                var translation = translations[i];
                for (int j = 0; j < translation.Translations.Count; j++)
                {
                    var localization = translation.Translations.Keys.Cast<string>().ToList()[j];
                    var excelColumn = translation.GetExcelColumnFromLocalization(localization);
                    var keyExcelColumn = translation.GetExcelColumnFromLocalization(Key);
                    if (i == 0)
                    {
                        slDocument.SetCellValue(GetExcelIndex(keyExcelColumn, titleRow),
                            translation.GetDisplayName(Key));

                        slDocument.SetCellValue(GetExcelIndex(excelColumn, titleRow),
                            translation.GetDisplayName(localization));
                    }

                    // Reason of + 2:
                    // - Excel starts with 1 instead of 0
                    // - Skip the title

                    var translationRow = i + 2;
                    if (j == 0)
                    {
                        slDocument.SetCellValue(GetExcelIndex(keyExcelColumn, translationRow), translation.Name);
                    }

                    slDocument.SetCellValue(GetExcelIndex(excelColumn, translationRow),
                        translation.Translations[localization]?.ToString());
                }
            }

            var titleStyle = new SLStyle();
            titleStyle.SetFontBold(true);
            titleStyle.Border.BottomBorder.Color = System.Drawing.Color.Green;
            titleStyle.Border.BottomBorder.BorderStyle = BorderStyleValues.Thin;
            slDocument.SetRowStyle(titleRow, titleStyle);

            var tmpPath = "tmp";
            var excelFileName = "AppResource.xlsx";
            var pathToExcel = Path.Combine(tmpPath, excelFileName);
            Directory.CreateDirectory(tmpPath);
            slDocument.SaveAs(pathToExcel);
            if (!outputPath.EndsWith('/'))
                outputPath += "/";

            File.Move(pathToExcel, Path.Combine(outputPath, excelFileName), true);
            Directory.Delete(tmpPath, true);
        }

        private static async Task PopulateResourceToi18NAsync(List<string> orderedDefinedCultures,
            List<TextTranslation> translations)
        {
            var resourceObjs = new Dictionary<string, JObject>();
            foreach (var culture in orderedDefinedCultures)
                resourceObjs.Add(culture, new JObject());

            foreach (var resource in translations)
            foreach (DictionaryEntry trans in resource.Translations)
                resourceObjs[trans.Key as string ?? ""].Add(new JProperty(resource.Name, trans.Value));
            Console.WriteLine("Preparing to write i18n");
            foreach (var resourceObj in resourceObjs)
            {
                var resourceFileName = $"{I18NPath}{resourceObj.Key}.json";
                Console.WriteLine($"Writing {resourceFileName}");
                await File.WriteAllTextAsync(resourceFileName, resourceObj.Value.ToString());
            }
        }

        private static async Task RewriteResourcesAsync(
            List<string> definedCultures,
            List<TextTranslation> translations,
            bool skipReferenceCheckingLog = false)
        {
            var textArray = new JArray();

            var noReferences = new List<string>();
            foreach (var resource in translations)
            {
                var resourceObj = new JObject(
                    new JProperty("name", resource.Name),
                    new JProperty("values", new JObject(
                        definedCultures.Select(x =>
                        {
                            var value = resource.Translations.Contains(x)
                                ? (string)resource.Translations[x]
                                : null;
                            return new JProperty(x, value);
                        }))));

                var hasNoReference = resource.Files.Count == 0;
                if (hasNoReference)
                {
                    resourceObj.Add(new JProperty("isReferenced", false));
                    noReferences.Add(resource.Name);
                }

                textArray.Add(resourceObj);
            }

            if (!skipReferenceCheckingLog && noReferences.Count > 0)
                Console.WriteLine($"{noReferences.Count} texts are not referenced: {string.Join(", ", noReferences)}");

            var root = new JObject(new JProperty("texts", textArray));

            var oldContents = File.ReadAllText(ResourceRelativePath);
            var newContents = root.ToString();
            if (oldContents != newContents)
            {
                Console.WriteLine($"Updating {ResourceRelativePath}");
                await File.WriteAllTextAsync(ResourceRelativePath, newContents);
            }
            else
            {
                Console.WriteLine("No update needed");
            }
        }

        /// <summary>
        /// Scan through all the files and check all the localization to see if they are referenced in code.
        /// </summary>
        /// <param name="translations"></param>
        private static async Task PopulateFilesAsync(List<TextTranslation> translations)
        {
            Console.WriteLine("Checking texts for references");
            Console.WriteLine();

            var ignoredFolders = new[] { "i18n", "localization" };
            var files = new List<string>();
            files.AddRange(Directory.GetFiles(".", "*.dart"));
            foreach (var folder in Directory.GetDirectories("."))
            {
                var folderRelPath = Path.GetRelativePath(".", folder);
                if (ignoredFolders.Contains(folderRelPath))
                    continue;

                files.AddRange(Directory.GetFiles(folder, "*.dart", SearchOption.AllDirectories));
            }

            using (var progressBar = new ProgressBar(files.Count * translations.Count,
                "Scanning files",
                new ProgressBarOptions
                {
                    ForegroundColor = ConsoleColor.Yellow,
                    ForegroundColorDone = ConsoleColor.DarkGreen,
                    BackgroundColor = ConsoleColor.DarkGray,
                    BackgroundCharacter = '\u2593'
                }))
            {
                foreach (var file in files)
                {
                    var contents = File.ReadAllText(file);
                    var relPath = Path.GetRelativePath(".", file);

                    await Task.WhenAll(translations.Select(resource =>
                    {
                        return Task.Run(() =>
                        {
                            if (resource.IsReferenced(contents))
                                resource.Files.Add(relPath);
                            progressBar.Tick($"Scanning For {resource.Name}...");
                        });
                    }).ToList());

                    progressBar.Tick($"Done scanning file: {file}");
                }
            }
        }

        private static async Task<(HashSet<string> definedCultures, List<TextTranslation> translations)>
            ReadResourcesAsync(List<string> resourcesToRemove)
        {
            Console.WriteLine($"Reading {ResourceRelativePath}");

            var contents = await File.ReadAllTextAsync(ResourceRelativePath);
            var root = JsonConvert.DeserializeObject<JObject>(contents);

            var resources = new OrderedDictionary();
            var definedCultures = new HashSet<string>();

            var texts = (JArray)root.Property("texts").Value;
            foreach (JObject item in texts)
            {
                var name = item.Property("name").Value.Value<string>();

                if (!_validTextName.IsMatch(name))
                    throw new Exception(
                        $"{name} is invalid. Name must contains letters, digits and/or underscore only.");

                if (resources.Contains(name))
                    throw new Exception($"{name} is duplicated");

                var nameDict = new TextTranslation(name);
                resources[name] = nameDict;

                var values = (JObject)item.Property("values").Value;
                foreach (JProperty cultureValue in values.Properties())
                {
                    var culture = cultureValue.Name;
                    if (resourcesToRemove.Contains(culture)) continue;

                    var value = cultureValue.Value.Value<string>();
                    nameDict.Translations[culture] = value;
                    definedCultures.Add(culture);
                }

                // Check that en is defined

                if (
                    !nameDict.Translations.Contains(En)
                    || ((string)nameDict.Translations[En] == null))
                {
                    throw new Exception($"Missing en value for {name}");
                }
            }

            Console.WriteLine($"{definedCultures.Count} languages defined: {string.Join(", ", definedCultures)}");
            Console.WriteLine($"{resources.Count} texts defined");

            return (definedCultures, resources.Values.Cast<TextTranslation>().ToList());
        }

        private static readonly Regex _validTextName = new Regex(@"^[A-Za-z0-9_]+$", RegexOptions.Compiled);


        private sealed class TextTranslation
        {
            public static readonly Dictionary<string, string> ExcelColumnByLocalizations =
                new Dictionary<string, string>
                {
                    { Key, "A" },
                    { En, "B" },
                    { ZhHans, "C" },
                };

            private readonly IEnumerable<Regex> _regexes;

            public TextTranslation(string name)
            {
                Name = name;
                Translations = new ListDictionary();
                Files = new List<string>();

                _regexes = BuildRegexes();
            }

            private List<Regex> BuildRegexes()
            {
                return new List<Regex>
                {
                    new Regex($"'{Name}'", RegexOptions.Compiled),
                };
            }

            public string GetExcelColumnFromLocalization(string localization)
            {
                if (!ExcelColumnByLocalizations.ContainsKey(localization))
                    throw new NotImplementedException(
                        $"The Name: {Name} of localization has not defined any excel column.");

                return ExcelColumnByLocalizations[localization];
            }

            public string GetDisplayName(string localization)
            {
                return localization switch
                {
                    Key => "Key",
                    En => "English",
                    ZhHans => "Chinese Simplified",
                    _ => throw new NotImplementedException(
                        $"The Name: {Name} of localization has not defined any display name."),
                };
            }

            /// <summary>
            /// The key of this translations, refer to 'name' in json
            /// </summary>
            public string Name { get; }

            /// <summary>
            /// The values of the json
            /// </summary>
            public ListDictionary Translations { get; }

            /// <summary>
            /// Files referencing this translation
            /// </summary>
            public List<string> Files { get; }

            /// <summary>
            /// Is this translation being referred
            /// </summary>
            /// <param name="content"></param>
            /// <returns></returns>
            public bool IsReferenced(string content) =>
                _regexes.Any(x => x.IsMatch(content));

            public string GetTranslation(string culture)
            {
                return Translations.Contains(culture)
                    ? (string)Translations[culture]
                    : null;
            }
        }
    }
}
