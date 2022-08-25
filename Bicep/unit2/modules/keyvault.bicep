resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
 name: 'kv-jagslab-neu-001'
  location: 'north europe'
  properties: {
      enableRbacAuthorization: true
      enabledForTemplateDeployment: true
      tenantId: subscription().tenantId
      sku: {
        family: 'A'
        name: 'standard'
     }
      
  }
  
}
 
//output keyvaultname string = keyvault.name
//output keyvaultid string = keyvault.id
