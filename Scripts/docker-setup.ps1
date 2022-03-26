# Check if first argument is empty
if ( [string]::IsNullOrEmpty($args[0]))
{
    Write-Output "Error: Please provide SA Password..."
    exit 1
}

$SA_PASSWORD = $args[0]

docker pull mcr.microsoft.com/azure-sql-edge
docker run --cap-add SYS_PTRACE -e 'ACCEPT_EULA=1' -e "MSSQL_SA_PASSWORD=$SA_PASSWORD" -p 1433:1433 --name ef_steroid_mssql_db -d mcr.microsoft.com/azure-sql-edge
