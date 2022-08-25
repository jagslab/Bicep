resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-bicep-test-neu-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.20.0/20'
      ]
    }
    subnets: [
      {
        name: 'snet-appgw'
        properties: {
          addressPrefix: '10.20.20.0/26'
          delegations: [
            {
              name: 'Microsoft.Web'
            }
          ]
        }
      }
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.20.20.64/26'
        }
      }
    ]
  }
}
