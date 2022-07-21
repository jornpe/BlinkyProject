@description('Location to use for the resources')
param location string

@description('Name of the container registry instance')
param containerRegistryName string

@description('The name:tag of the image to use')
param containerImageAndTag string

@description('Name of the app config resource')
param appConfigName string

@description('Reference to the instrastructure resource group')
param infrastructureRgName string

@description('The environment that is depoyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string

@description('Name of the application to be deployed')
param application string

@description('Tags to add the all resources that is being deployed')
param tags object

var appInsightName = 'appi-${application}-${environmentType}'
var appServiceName = 'apps-${application}-${environmentType}'
var appServicePlanName = 'plan-${application}-${environmentType}'
var serviceBusName = 'sb-${application}-${environmentType}'
var serviceBusQueueName = 'sbq-${application}Queue'
var sbQueueEndpointUri = 'sb://${serviceBusName}.servicebus.windows.net'
var containerSpec = 'DOCKER|${containerRegistry.properties.loginServer}/${containerImageAndTag}'
var iotHubName = 'iot-${application}-${environmentType}'
var appConfigEndpoint = 'https://${appConfigName}.azconfig.io'


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(infrastructureRgName)
}

resource appConfigStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: appConfigName
  scope: resourceGroup(infrastructureRgName)
}

module appInsight 'resources/applicationInsight.bicep' = {
  name: 'applicationInsight'
  params: {
    appInsightName: appInsightName
    location: location
    tags: tags
  }
}

module serviceBus 'resources/serviceBus.bicep' = {
  name: 'ServiceBusAndQueue-${environmentType}'
  params: {
    serviceBusNamespaceName: serviceBusName
    serviceBusQueueName: serviceBusQueueName
    location: location
    tags: tags
  }
}

module IotHub 'resources/iotHub.bicep' = {
  name: 'IotHub-${environmentType}'
  params: {
    environmentType: environmentType
    iotHubName: iotHubName
    location: location
    tags: tags
    sbQueueEndpointUri: sbQueueEndpointUri
    sbQueueName: serviceBusQueueName
    serviceBusName: serviceBusName
  }
  dependsOn: [
    serviceBus
  ]
}

module appService 'resources/website.bicep' = {
  name: 'AppService-${environmentType}'
  params: {
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    containerSpecs: containerSpec
    location: location
    tags: tags
    appConfigEndpoint: appConfigEndpoint
    appInsightInstrumentationKey: appInsight.outputs.instrumentationKey
    environmentType: environmentType
  }
  dependsOn: [
    serviceBus
    IotHub
    appInsight
  ]
}

var keyValues = [
  {
    Key: 'Blinkey:IotHubOptions:HostName'
    Value: IotHub.outputs.iotHubHostName
  }
]

module appConfigConfiguration 'resources/appConfigValues.bicep' = {
  name: 'appConfigConfiguration'
  scope: resourceGroup(infrastructureRgName)
  params: {
    configStoreName: appConfigName
    keyValues: keyValues
    environmentType: environmentType
  }
}

module appConfigRoleAssignment 'roleAssignments/appConfigRoleAssignment.bicep' = {
  name: 'appCofigRoleAssignment'
  scope: resourceGroup(infrastructureRgName)
  params: {
    configStoreName: appConfigName
    principalIds: [
      appService.outputs.principalId
    ]
  }
}

module acrRoleAssignment 'roleAssignments/contianerRegistryRoleAssignment.bicep' = {
  name: 'acrRoleAssignment'
  scope: resourceGroup(infrastructureRgName)
  params: {
    principalId: appService.outputs.principalId
    containerRegistryName: containerRegistryName
  }
  dependsOn: [
    appService
  ]
}

module iotHubRoleAssignment 'roleAssignments/iotHubRoleAssignment.bicep' = {
  name: 'iotHubRoleAssignment'
  params: {
    principalId: appService.outputs.principalId
    iotHubName: iotHubName
  }
  dependsOn: [
    IotHub
    appService
  ]
}

