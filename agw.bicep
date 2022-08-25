targetScope = 'resourceGroup'

/*
------------------------------------------------
NSG NAMES
------------------------------------------------
*/
//var nsgAppgwSubnetName = 'nsg-appgw-subnet'
var nsgWebappSubnetName = 'nsg-webapp-subnet'
//var nsgApiSubnetName = 'nsg-api-subnet'
var nsgDbSubnetName = 'nsg-db-subnet'
var nsgIntegrationSubnetName = 'nsg-integration-subnet'
var nsgVmSubnetName = 'nsg-vm-subnet'
var nsgMonitorSubnetName = 'nsg-monitor-subnet'
var nsgStorageSubnetName = 'nsg-storage-subnet'
var nsgKvSubnetName = 'nsg-kv-subnet'
var kvName = 'kv-jagslab-shared-neu-01'
var keyVaultURL = environment().suffixes.keyvaultDns
var kvID ='https://${kv.name}${keyVaultURL}/secrets/wildcard-jagslab-net/'
var sharedKvRgName = 'rg-shared-neu-01'
var userId = 'id-shared'
var appGatewayName = 'agw-jagslab-test-neu-01'
var appgwId = resourceId('Microsoft.Network/applicationGateways',appGatewayName)
var sqlServerName = 'sql-jag-test-neu-01'  
var sqlDbName = 'sqldb-jag-test-neu-01'
var webappName = 'app-jagstest-neu-01'
var tags = {
  Location: 'Europe'
  Service: 'SQL'
}
var aadSqlAdmin = 'SQL-Admins'
var aadSqlAdminObjectId = 'afe77b0c-4b65-46b3-9745-801dde489124'

/*
------------------------------------------------
KV Instance
------------------------------------------------
*/
resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
   name: kvName
   scope: resourceGroup(subscription().subscriptionId,  sharedKvRgName)
}

/*
------------------------------------------------
UserID Instance
------------------------------------------------
*/

resource uid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userId
  scope: resourceGroup(subscription().subscriptionId,  sharedKvRgName)
}

output ouserIdResource string = uid.properties.principalId
/*
------------------------------------------------
SQL Server
------------------------------------------------
*/

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: sqlServerName
    dependsOn: [
    uid
  ]
  location: resourceGroup().location  
  tags: tags
   identity: {
    type: 'SystemAssigned'
  }
  properties: {  
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion:'1.2'    
    administratorLogin: 'jag_mstr'
    administratorLoginPassword:'Laptop99!'
    administrators: {
       administratorType: 'ActiveDirectory'
       azureADOnlyAuthentication: false
       login: aadSqlAdmin
       principalType: 'Group'
       sid: aadSqlAdminObjectId
       tenantId: tenant().tenantId
    }
  }
}
output osqlServerName string = sqlServer.name
output osqlServerNameFQDN string = sqlServer.properties.fullyQualifiedDomainName
output osqlServerIdentity string = sqlServer.identity.principalId



/*
------------------------------------------------
SQL DB
------------------------------------------------
*/

resource sqlDb 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: resourceGroup().location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }  
  properties: {    
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    isLedgerOn: false
  }
  dependsOn: [
    //sqlServer
  ]
}
output osqlServerDbName string = sqlDb.name

resource sqlFirewallRule 'Microsoft.Sql/servers/firewallrules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}



/*
------------------------------------------------
Public IP
------------------------------------------------
*/
resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01'={
  name: 'pip-agw-test-neu-01'
  location: resourceGroup().location
  sku: {
    tier: 'Regional'
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
   
  }


/*
------------------------------------------------
CREATING NSG WEB APP FOR SUBNET
------------------------------------------------
*/
resource nsgWebappSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgWebappSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG API APP FOR SUBNET
------------------------------------------------
*/
resource nsgApiSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-api-subnet'
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG DB FOR SUBNET
------------------------------------------------
*/
resource nsgDbSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgDbSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG INTEGRATION FOR SUBNET
------------------------------------------------
*/
resource nsgIntegrationSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgIntegrationSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG VM FOR SUBNET
------------------------------------------------
*/
resource nsgVmSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgVmSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG MONITOR FOR SUBNET
------------------------------------------------
*/
resource nsgMonitorSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgMonitorSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG STORAGE FOR SUBNET
------------------------------------------------
*/
resource nsgStorageSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgStorageSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
CREATING NSG KV FOR SUBNET
------------------------------------------------
*/
resource nsgKvSubnet 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgKvSubnetName
  location: resourceGroup().location
  tags: tags
}

/*
------------------------------------------------
Create VNET
------------------------------------------------
*/

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-bicep-test-neu-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.16.0/20'
      ]
    }
    subnets: [
      {
        name: 'snet-appgw'
        properties: {
          addressPrefix: '10.20.16.0/26'
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
            }
          ]
        }
      }
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.20.16.64/26'
        }
      }
    ]
  }
}

output ovnet string = vnet.name

/*
------------------------------------------------
Create User ID
------------------------------------------------


resource userid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' ={
  location: resourceGroup().location
  name: 'id-appgw'
  }

/*

/*
------------------------------------------------
Create APPGW
------------------------------------------------
*/

resource appgw 'Microsoft.Network/applicationGateways@2021-05-01' ={
  name: 'agw-jagslab-test-neu-01'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uid.id}' : {}
    }
  }

  
  properties: {
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    frontendIPConfigurations: [
      {
        name: 'appgwfrontendip'
        properties:{
           publicIPAddress: {
             id: pip.id
           }
        } 
      }
    ]
gatewayIPConfigurations: [
  {
    name: 'appgwIPconfig'
    properties: {
      subnet: {
        id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-appgw' )
      }
    }
  }
]

    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    webApplicationFirewallConfiguration: {
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      enabled: true
      ruleSetVersion: '3.2'
    }
    frontendPorts: [
      {
        name: 'appgwfrontendport'
        properties: {
          port: 443
        }
      }
    ]
    httpListeners: [
      {
        name: 'appgwhttplisteners'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'agw-jagslab-test-neu-01', 'appgwfrontendip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'agw-jagslab-test-neu-01', 'appgwfrontendport')
          }
          protocol: 'Https'
          requireServerNameIndication: false
          sslCertificate: {
            id: '${appgwId}/sslCertificates/wildcard-jagslab-net'   
          
          }
          
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appgwbackendpools'
        properties: {
          backendAddresses: [
            {
              fqdn: 'app-jagstest-neu-01.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appgwbackendcollections'
        properties: {
          cookieBasedAffinity: 'Enabled'
          port: 80
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'appgwreoutingrules'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'agw-jagslab-test-neu-01', 'appgwhttplisteners')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agw-jagslab-test-neu-01', 'appgwbackendpools')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agw-jagslab-test-neu-01', 'appgwbackendcollections')
          }
        }
      }
    ]
   /* authenticationCertificates: [
      {
        id: keyVaultURL
      }
    ]
    */
    sslCertificates: [
      {
        name: 'wildcard-jagslab-net'
        properties: {
          keyVaultSecretId: kvID
        }
      }
    ]
  }
}



/*
------------------------------------------------
App
------------------------------------------------
*/

resource app 'Microsoft.Web/sites@2021-02-01' = {
  location: resourceGroup().location
  name: webappName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    
  }
}

output oappidentity string = app.identity.principalId
output oappname string = app.name
output oppappdns string = app.properties.defaultHostName
