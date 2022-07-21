@description('Name of the app configuration resource')
param configStoreName string

@description('Pricipal IDs to resources that recuire read access')
param principalIds array

resource appconfigStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: configStoreName
}


// Role name: "App Configuration Data Reader" - Allows read access to App Configuration data. https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#app-configuration-data-reader
var appConfigurationDataReaderId = '516239f1-63e1-4d78-a4de-a74fb236a071'
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
