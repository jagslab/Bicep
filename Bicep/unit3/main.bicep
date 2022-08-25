@description('')
param locations array = [
  'westeurope'
  'northeurope'
  'eastasia'
]

@secure()
param sqlServerAdministratorLogin string

@secure()
param sqlServerAdministratorLoginPassword string

@description ('Vnet Ip Addresses')
param VnetNetAddressPrefix string = '10.10.0.0/16'

@description ('The name and IP address range of each subnet')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
     addressPrefix: subnet.ipAddressRange
  }
} ]

module databases 'modules/database.bicep' = [ for location in locations: {
   name: 'database-${location}'
   params: {
      location: location
      sqlServerAdministratorLogin: sqlServerAdministratorLogin
      sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
   }
}]

resource vnets 'Microsoft.Network/virtualNetworks@2021-02-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties: {
     addressSpace: {
        addressPrefixes: [
           VnetNetAddressPrefix
        ]
     }
  subnets: subnetProperties
  }
}]

output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location:databases[i].outputs.location
  FQDN: databases[i].outputs.FQDN
}]
