resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-test-jag-03'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
       '10.4.1.0/24'
      ]
      
    }
    subnets: [
       {
          name: 'snet-jagtest'
          properties: {
             addressPrefix: '10.4.1.0/27'
          }
       }
    ]
  }
}