param principalId string
param containerRegistryName string

var acrPullRoleDefinitionID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: containerRegistryName
}

resource appServiceAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(containerRegistry.id, principalId, acrPullRoleDefinitionID)
  scope: containerRegistry
  properties: {
    principalId: principalId
    roleDefinitionId: acrPullRoleDefinitionID
    principalType: 'ServicePrincipal'
  }
}
