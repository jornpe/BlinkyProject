@description('Location to use for the resources')
param location string
@description('Name of the container registry instance')
param containerRegistryName string
@description('The name:tag of the image to use')
param containerImageAndTag string
@description('Reference to the instrastructure resource group')
param sharedInfrastructureRgName string
@description('The environment that is depoyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string

var appServiceName = 'app-blinkey-${environmentType}'
var appServicePlanName = 'plan-blinkey-${environmentType}'
var serviceBusName = 'sb-blinkey-${environmentType}'
var serviceBusQueueName = 'sbq-blinkeyQueue'
var sbQueueEndpointUri = 'sb://${serviceBusName}.servicebus.windows.net'
var containerSpec = 'DOCKER|${containerRegistry.properties.loginServer}/${containerImageAndTag}'
var iotHubName = 'iot-blinkey-${environmentType}'


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(sharedInfrastructureRgName)
}

module serviceBus 'serviceBus.bicep' = {
  name: 'ServiceBusAndQueue-${environmentType}'
  params: {
    serviceBusNamespaceName: serviceBusName
    serviceBusQueueName: serviceBusQueueName
    location: location
  }
}

module appService 'website.bicep' = {
  name: 'AppService-${environmentType}'
  params: {
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    containerSpecs: containerSpec
    location: location
  }
  dependsOn: [
    serviceBus
  ]
}

module IotHub 'iotHub.bicep' = {
  name: 'IotHub-${environmentType}'
  params: {
    environmentType: environmentType
    iotHubName: iotHubName
    location: location
    sbQueueEndpointUri: sbQueueEndpointUri
    sbQueueName: serviceBusQueueName
    serviceBusName: serviceBusName
  }
  dependsOn: [
    serviceBus
  ]
}

module acrRoleAssignment 'roleAssignments/assignContainerPullRole.bicep' = {
  name: 'ACRpullRoleAssignmentForAppService'
  scope: resourceGroup(sharedInfrastructureRgName)
  dependsOn: [
    appService
  ]
  params: {
    principalId: appService.outputs.appService.identity.principalId
    containerRegistryName: containerRegistryName
  }
}

// module appServiceSbSenderRoleAssignment 'roleAssignments/assignMessageQueueRole.bicep' = {
//   name: 'appServicesbSenderRoleAssignment'
//   dependsOn: [
//     serviceBus
//     IotHub
//     appService
//   ]
//   params: {
//     messageBusName: serviceBusName
//     principalIds: [
//       serviceBus.outputs.serviceBusPrincipalId
//       IotHub.outputs.iotHubPrincipalId
//     ]
//   }
// }
