@description('Location to use for the resources')
param location string = resourceGroup().location

@description('Environment to deploy')
@allowed([
  'prod'
  'dev'
])
param environmentType string

@description('Name of the container registry instance')
param containerRegistryName string

@description('The name:tag of the image to use')
param containerImageAndTag string

var sharedInfrastructureRg = 'rg-blinkey-shared-norwayeast-001'
var appServicePlanName = 'plan-blinkey-${environmentType}'
var appServiceName = 'app-blinkey-${environmentType}'
var containerSpecs = 'DOCKER|${containerRegistry.properties.loginServer}/${containerImageAndTag}'
var acrPullRoleDefinitionID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(sharedInfrastructureRg)
}

module appService 'modules/AppService.bicep' = {
  name: 'appServiceDeploy'
  params: {
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    containerSpecs: containerSpecs
    location: location
  }
}

module roleAssignment 'modules/roleDefinitionAssignment.bicep' = {
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
