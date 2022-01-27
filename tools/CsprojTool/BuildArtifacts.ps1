dotnet publish -r win-x64 --self-contained false -c Release
echo "Done building artifacts..."

echo "Start moving artifact to Flutter Windows"
$ArtifactDirectory = "..\..\windows\artifacts\CsprojTool\win-x64\"

# Create target directory
New-Item $ArtifactDirectory -ItemType Directory -Force
mv bin\Release\net6.0\win-x64\publish\ $ArtifactDirectory -Force
echo "Done moving artifact to Flutter Windows"

echo "Done..."
