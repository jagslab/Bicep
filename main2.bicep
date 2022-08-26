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
//var kvID ='https://${kv.name}${keyVaultURL}/secrets/cert-jagslab-net/e330be19902540a1815492b80321ae7c'
var sharedKvRgName = 'rg-shared-neu-01'
var userId = 'id-shared'
var sqlServerName = 'sql-jag-test-neu-01'  
var sqlDbName = 'sqldb-jag-test-neu-01'
//var webappName = 'jags-test-lab-neu-01'
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

/*
------------------------------------------------
Create User ID
------------------------------------------------
*/

resource userid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' ={
  location: resourceGroup().location
  name: 'id-appgw'
  }

/*
------------------------------------------------
Create APPGW
------------------------------------------------


resource appgw 'Microsoft.Network/applicationGateways@2021-05-01' ={
  name: 'agw-jagslab-test-neu-01'
   dependsOn: [
    vnet
  ]
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uid.id}' : {}
    }
  }

  
  properties: {
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
    authenticationCertificates: [
      {
        id: kvID
      }
    ]
    sslCertificates: [
      {
        name: 'cert-jagslab-net'
        properties: {
          keyVaultSecretId: kvID
        }
      }
    ]
  }
}

*/

/*
------------------------------------------------
App
------------------------------------------------
*/

resource app 'Microsoft.Web/sites@2021-02-01' = {
  location: resourceGroup().location
  name: 'app-jagstest-neu-01'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    
  }
}

output oappidentity string = app.identity.principalId
output oappname string = app.name
