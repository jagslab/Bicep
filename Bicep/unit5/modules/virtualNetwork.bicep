param virtualNetworkName string
param virtualNetworkAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
   name: virtualNetworkName
    location: resourceGroup().location
     properties: {
        addressSpace: {
           addressPrefixes: [
              virtualNetworkAddressPrefix 
           ]
        }
     }
}
