@description('Location to use for the resources')
param location string

@description('Name of the app configuration resource')
param configStoreName string

@description('List of key value configuration pairs ')
param keyValues array

@description('Pricipal IDs to resources that recuire read access')
param principalIds array

resource appconfigStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: configStoreName
  location: location
  sku: {
    name: 'S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource keyValueConfigPairs 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for keyValue in keyValues: {
  name: '${keyValue.Key}'
  parent: appconfigStore
  properties: {
    value: keyValue.Value
  }
}]

// Role name: "IoT Hub Data Contributor" - Allows for full access to IoT Hub data plane operations. https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#iot-hub-data-contributor
var appConfigurationDataReaderId = '4fc6c259-987e-4a07-842e-c321cc9d413f'
resource appConfigurationDataReader 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: appConfigurationDataReaderId
}

resource appConfigurationDataReaderAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for principalId in principalIds: {
  name: guid(appConfigurationDataReader.id, principalId, appconfigStore.id)
  scope: appconfigStore
  properties: {
    principalId: principalId
    roleDefinitionId: appConfigurationDataReader.id
    principalType: 'ServicePrincipal'
  }
}]
