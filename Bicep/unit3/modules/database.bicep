@description('The Azure locaiton to which resources willbe dployed')
param location string

@secure()
@description('The administrator username for the SQL server')
param sqlServerAdministratorLogin string

@secure()
@description('The sqlAdministratorLoginPassword')
param sqlServerAdministratorLoginPassword string

@description('Storage Account')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Development'

@description('The name of the audit storagea account')
param auditStorageAccountSkuName string = 'Standard_LRS'

@description('The name and tier of SQL database SKU')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

var auditEnabled = environmentName == 'Production'
var auditStorageAccountName = '${take('bearaudit${uniqueString(resourceGroup().id)}', 24)}'

var sqlServerName = 'jagstar${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'TeddyBear'


resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
   name: sqlServerName
    location: location
     identity: {
        type: 'SystemAssigned' 
         }
       properties: {
          administratorLogin: sqlServerAdministratorLogin
           administratorLoginPassword: sqlServerAdministratorLoginPassword
            administrators: {
            }
       }
     }
  
  resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
    parent: sqlServer 
    name: sqlDatabaseName
      location: location
       sku: sqlDatabaseSku
      }

 resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = if (auditEnabled) {
    location: location
     kind: 'StorageV2'
      name: auditStorageAccountName
       sku: {
         name:  auditStorageAccountSkuName
      }
       properties: {
           accessTier: 'Cool'
       }
 }

 resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2021-02-01-preview' = if ( auditEnabled) {
    parent: sqlServer
     name: 'default'
      properties: {
        state:  'Enabled'
         storageEndpoint: environmentName == 'Production' ? auditStorageAccount.properties.primaryEndpoints.blob: ''
          storageAccountAccessKey: environmentName == 'Production' ? listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value : ''

        
      }
 }

 output serverName string = sqlServer.name
 output location string = location
 output FQDN string = sqlServer.properties.fullyQualifiedDomainName
