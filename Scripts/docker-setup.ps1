docker pull mcr.microsoft.com/azure-sql-edge
docker run --cap-add SYS_PTRACE -e 'ACCEPT_EULA=1' -e 'MSSQL_SA_PASSWORD=fdkngx4tak7vka8JNT' -p 1433:1433 --name ef_steroid_mssql_db -d mcr.microsoft.com/azure-sql-edge
