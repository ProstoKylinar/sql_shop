# InternetShop DB

Database schema and admin scripts for the **InternetShop** project
(MS SQL Server).  
Designed for local development on macOS with Podman + DBeaver /
Azure Data Studio.

## 1. Prerequisites

- Podman with `podman machine` configured (macOS).  
- SQL client: DBeaver or Azure Data Studio.  
- Git.

## 2. Run SQL Server in Podman

```bash
# start podman VM (if not running)
podman machine start

# create local data folder for bulk import
mkdir -p $HOME/sql-data

# run SQL Server 2022 container
podman run -d \
  --name mssql2022 \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=StrongPass#1" \
  -p 1433:1433 \
  -v $HOME/sql-data:/data \
  mcr.microsoft.com/mssql/server:2022-latest
