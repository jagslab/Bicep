
param appServiceAppName string = 'jagslab-product-1'
param location string = resourceGroup().location
param storageaccountname string = 'strjagslab'
@allowed([
  'prod'
  'dev'
  ])

  param environmentType string

  var storageaccountSkuName = (environmentType == 'dev' ? 'Standard_LRS' : 'Standard_LRS')

resource storageaccount  'Microsoft.Storage/storageAccounts@2019-06-01' = {
     name:  storageaccountname
    location: 'North Europe'
      sku: {
        name:   storageaccountSkuName
 
 }
properties: {
   accessTier: 'Cool'
  }
 kind: 'StorageV2'
}

module appservice 'modules/appService.bicep' ={
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

//output appServiceAppHostName string = appService.outputs.appServiceAppHostName
