@description('Location to use for the resources')
param location string

@description('Name of the container registry instance')
param containerRegistryName string

@description('The name:tag of the image to use')
param containerImageAndTag string

param sharedInfrastructureRg string
param appServicePlanName string
param appServiceName string

var containerSpec = 'DOCKER|${containerRegistry.properties.loginServer}/${containerImageAndTag}'
var acrPullRoleDefinitionID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(sharedInfrastructureRg)
}


module appService 'Website.bicep' = {
  name: 'Deploy_${appServiceName}'
  params: {
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    containerSpecs: containerSpec
    location: location
  }
}

module roleAssignment 'roleDefinitionAssignment.bicep' = {
  name: 'appServiceAcrPullRoleAssignment'
  scope: resourceGroup(sharedInfrastructureRg)
  dependsOn: [
    appService
  ]
  params: {
    principalId: appService.outputs.appService.identity.principalId
    roleDefinitionId: acrPullRoleDefinitionID
    containerRegistryName: containerRegistryName
  }
}
