var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
var storageBlobContainerName = 'config'
var userAssignedIdentityName = 'configDeployer'
var roleAssignmentName = guid(resourceGroup().id, 'contributor')
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var deploymentScriptName = 'CopyConfigScript'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
   location: resourceGroup().location
   tags: {
    displayName: storageAccountName
   }
    kind: 'StorageV2'
     sku: {
        name: 'Standard_LRS'
     }
      properties: {
         accessTier: 'Cool'
          encryption: {
             services: {
                blob: {
                   enabled: true
                }
             }
      keySource: 'Microsoft.Storage'
          }
    supportsHttpsTrafficOnly: true
      }
  
      resource blobService 'blobServices' existing = {
        name: 'default'
      }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
   parent: storageAccount::blobService
   name: storageBlobContainerName
    properties: {
       publicAccess: 'Blob'
    }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
   name: userAssignedIdentityName
   location: resourceGroup().location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
   name: roleAssignmentName
    properties: {
      principalId:  userAssignedIdentity.properties.principalId
      roleDefinitionId: contributorRoleDefinitionId
       principalType: 'ServicePrincipal'
      
    }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
   kind: 'AzurePowerShell'
    name: deploymentScriptName
    location: resourceGroup().location
     identity: {
        type: 'UserAssigned' 
         userAssignedIdentities: {
            '${userAssignedIdentity}': {}
         }
     }
      dependsOn: [
         roleAssignment
          blobContainer
      ]
     properties: {
       azPowerShellVersion: '3.0'
       retentionInterval: 'P1D'
       scriptContent: '''
    Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/mslearn-arm-deploymentscripts-sample/appsettings.json' -OutFile 'appsettings.json'
    $storageAccount = Get-AzStorageAccount -ResourceGroupName 'learndeploymentscript_exercise_1' | Where-Object { $_.StorageAccountName -like 'storage*' }
    $blob = Set-AzStorageBlobContent -File 'appsettings.json' -Container 'config' -Blob 'appsettings.json' -Context $storageAccount.Context
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['Uri'] = $blob.ICloudBlob.Uri
    $DeploymentScriptOutputs['StorageUri'] = $blob.ICloudBlob.StorageUri
    '''
       
     }
}
