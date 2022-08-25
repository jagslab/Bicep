param location string 
param appServiceAppName string

@allowed( [
  'dev'
  'prod'
])
param environmentType string

var appServicePlanName = 'jagslab-product-launch-plan'
var appServicePlanSKuName = (environmentType == 'prod') ? 'F1' : 'F1'
var appServicePlanTierName = (environmentType == 'prod') ? 'Free' : 'Free'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSKuName
    tier: appServicePlanTierName
  }

}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
