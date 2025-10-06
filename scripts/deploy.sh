#!/bin/bash
# ==========================================
# DEPLOY ECOAID CHECKPOINT5 - AZURE
# ==========================================

# 1. Configurar variáveis de ambiente
RESOURCE_GROUP_NAME="rg-api-mvc-cp5"
WEBAPP_NAME="ecoaid-mvc-rm557540"
APP_SERVICE_PLAN="ecoaid-mvc"
LOCATION="eastus2"
RUNTIME="JAVA:17-java17"
GITHUB_REPO_NAME="dan25ak1/EcoAidCheckpoint5"
BRANCH="main"
APP_INSIGHTS_NAME="ai-ecoaid-mvc"
SQL_SERVER_NAME="sql-server-cp5-rm557540-eastus2"
SQL_DATABASE_NAME="db-cp5"
SQL_ADMIN_USER="user-fiaper"
SQL_ADMIN_PASSWORD="Fiap@2tdsvms"

echo "==============================================="
echo "Iniciando deploy da aplicação $WEBAPP_NAME"
echo "==============================================="

# 2. Login no Azure
az login

# 3. Registrar providers necessários
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Sql

# 4. Criar grupo de recursos
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# 5. Criar SQL Server
az sql server create \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --admin-user $SQL_ADMIN_USER \
  --admin-password $SQL_ADMIN_PASSWORD \
  --enable-public-network true

# 6. Criar banco de dados SQL
az sql db create \
  --resource-group $RESOURCE_GROUP_NAME \
  --server $SQL_SERVER_NAME \
  --name $SQL_DATABASE_NAME \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

# 7. Configurar firewall do SQL Server
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --server $SQL_SERVER_NAME \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --server $SQL_SERVER_NAME \
  --name AllowAllIPs \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

# 8. Criar Application Insights
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP_NAME \
  --application-type web

# 9. Obter Connection String do Application Insights
CONNECTION_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query connectionString \
  --output tsv)

# 10. Criar App Service Plan
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku F1 \
  --is-linux

# 11. Criar Web App
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --plan $APP_SERVICE_PLAN \
  --runtime $RUNTIME

# 12. Habilitar credenciais de publicação
az resource update \
  --resource-group $RESOURCE_GROUP_NAME \
  --namespace Microsoft.Web \
  --resource-type basicPublishingCredentialsPolicies \
  --name scm \
  --parent sites/$WEBAPP_NAME \
  --set properties.allow=true

# 13. Configurar variáveis de ambiente do App Service
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --settings \
  APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING" \
  ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
  XDT_MicrosoftApplicationInsights_Mode="Recommended" \
  XDT_MicrosoftApplicationInsights_PreemptSdk="1" \
  MSSQL_HOST="$SQL_SERVER_NAME.database.windows.net" \
  MSSQL_PORT="1433" \
  MSSQL_DATABASE="$SQL_DATABASE_NAME" \
  MSSQL_USER="$SQL_ADMIN_USER" \
  MSSQL_PASSWORD="$SQL_ADMIN_PASSWORD"

# 14. Configurar GitHub Actions
az webapp deployment github-actions add \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --repo $GITHUB_REPO_NAME \
  --branch $BRANCH \
  --login-with-github

# 15. Reiniciar Web App
az webapp restart \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME

echo "==============================================="
echo "Deploy concluído com sucesso!"
echo "URL da aplicação: https://$WEBAPP_NAME.azurewebsites.net"
echo "==============================================="
