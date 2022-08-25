@description('This is an environment param')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('Solution name param, which takes takes the prefix-uniquestrong-followed by rg.id')
@minLength(5)
@maxLength(30)
param solutionName string = 'jagslabhr${uniqueString( resourceGroup().id)}'

@description('App Service Instance Count - Integer only')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@secure()
@description('')
param sqlServerAdministratorLogin string

@secure()
@description('Test')
param sqlServerAdministratorPassword string

@description('sqlSku')
param sqlDatabaseSku object

@description('Sku')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}
param location string = resourceGroup().location



var appServicePlanName = '${environmentName}-${solutionName}'
var appServiceAppName = '${environmentName}-${solutionName}'
var sqlServerName = '${environmentName}-${solutionName}'
var sqlDatabaseName = 'Employees'

//module keyvault 'modules/keyvault.bicep' = {
  // name: 'keyvault'
   //params: {
    
   //}
//}

//output keyvaultname string = keyvault.outputs.keyvaultname
//output keyvaultid string = keyvault.outputs.keyvaultid

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
name: appServicePlanName
location: location
sku: {
   name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
   name: appServiceAppName
    location: location
     properties: {
        httpsOnly: true
         serverFarmId: appServicePlan.id
     }
}

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
 name: sqlServerName
  location: location
   properties: {
      administratorLogin: sqlServerAdministratorLogin
       administratorLoginPassword: sqlServerAdministratorPassword 
   }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
    location: location 
      sku: {
         name: sqlDatabaseSku.name
          tier: sqlDatabaseSku.tier
        }
}
