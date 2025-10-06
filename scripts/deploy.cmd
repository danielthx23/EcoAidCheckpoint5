
@echo off
REM ==========================================
REM DEPLOY ECOAID CHECKPOINT5 - AZURE
REM ==========================================

REM 1. Configurar variáveis de ambiente
set RESOURCE_GROUP_NAME=rg-api-mvc-cp5
set WEBAPP_NAME=ecoaid-mvc-rm557540
set APP_SERVICE_PLAN=ecoaid-mvc
set LOCATION=eastus2
set RUNTIME=JAVA:17-java17
set GITHUB_REPO_NAME=dan25ak1/EcoAidCheckpoint5
set BRANCH=main
set APP_INSIGHTS_NAME=ai-ecoaid-mvc
set SQL_SERVER_NAME=sql-server-cp5-rm557540-eastus2
set SQL_DATABASE_NAME=db-cp5
set SQL_ADMIN_USER=user-fiaper
set SQL_ADMIN_PASSWORD=Fiap@2tdsvms

echo ===============================================
echo Iniciando deploy da aplicação %WEBAPP_NAME%
echo ===============================================

REM 2. Login no Azure
az login

REM 3. Registrar providers necessários
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Sql

REM 4. Criar grupo de recursos
az group create --name %RESOURCE_GROUP_NAME% --location %LOCATION%

REM 5. Criar SQL Server
az sql server create ^
  --name %SQL_SERVER_NAME% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --location %LOCATION% ^
  --admin-user %SQL_ADMIN_USER% ^
  --admin-password %SQL_ADMIN_PASSWORD% ^
  --enable-public-network true

REM 6. Criar banco de dados SQL
az sql db create ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --server %SQL_SERVER_NAME% ^
  --name %SQL_DATABASE_NAME% ^
  --service-objective Basic ^
  --backup-storage-redundancy Local ^
  --zone-redundant false

REM 7. Configurar firewall do SQL Server
az sql server firewall-rule create ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --server %SQL_SERVER_NAME% ^
  --name AllowAzureServices ^
  --start-ip-address 0.0.0.0 ^
  --end-ip-address 0.0.0.0

az sql server firewall-rule create ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --server %SQL_SERVER_NAME% ^
  --name AllowAllIPs ^
  --start-ip-address 0.0.0.0 ^
  --end-ip-address 255.255.255.255

REM 8. Criar Application Insights
az monitor app-insights component create ^
  --app %APP_INSIGHTS_NAME% ^
  --location %LOCATION% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --application-type web

REM 9. Obter Connection String do Application Insights
for /f "delims=" %%i in ('az monitor app-insights component show --app %APP_INSIGHTS_NAME% --resource-group %RESOURCE_GROUP_NAME% --query connectionString --output tsv') do set CONNECTION_STRING=%%i

REM 10. Criar App Service Plan
az appservice plan create ^
  --name %APP_SERVICE_PLAN% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --location %LOCATION% ^
  --sku F1 ^
  --is-linux

REM 11. Criar Web App
az webapp create ^
  --name %WEBAPP_NAME% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --plan %APP_SERVICE_PLAN% ^
  --runtime %RUNTIME%

REM 12. Habilitar credenciais de publicação
az resource update ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --namespace Microsoft.Web ^
  --resource-type basicPublishingCredentialsPolicies ^
  --name scm ^
  --parent sites/%WEBAPP_NAME% ^
  --set properties.allow=true

REM 13. Configurar variáveis de ambiente do App Service
az webapp config appsettings set ^
  --name %WEBAPP_NAME% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --settings ^
  APPLICATIONINSIGHTS_CONNECTION_STRING="%CONNECTION_STRING%" ^
  ApplicationInsightsAgent_EXTENSION_VERSION="~3" ^
  XDT_MicrosoftApplicationInsights_Mode="Recommended" ^
  XDT_MicrosoftApplicationInsights_PreemptSdk="1" ^
  MSSQL_HOST="%SQL_SERVER_NAME%.database.windows.net" ^
  MSSQL_PORT="1433" ^
  MSSQL_DATABASE="%SQL_DATABASE_NAME%" ^
  MSSQL_USER="%SQL_ADMIN_USER%" ^
  MSSQL_PASSWORD="%SQL_ADMIN_PASSWORD%"

REM 14. Configurar GitHub Actions
az webapp deployment github-actions add ^
  --name %WEBAPP_NAME% ^
  --resource-group %RESOURCE_GROUP_NAME% ^
  --repo %GITHUB_REPO_NAME% ^
  --branch %BRANCH% ^
  --login-with-github

REM 15. Reiniciar Web App
az webapp restart ^
  --name %WEBAPP_NAME% ^
  --resource-group %RESOURCE_GROUP_NAME%

echo ===============================================
echo Deploy concluído com sucesso!
echo URL da aplicação: https://%WEBAPP_NAME%.azurewebsites.net
echo ===============================================

