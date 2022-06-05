targetScope = 'subscription'

@description('The environment that is deloyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string
param deploymentId string
param location string = 'norwayeast'
param shardRgName string = 'rg-blinkey-shared-${location}-001'
param environmentRgName string = 'rg-blinkey-${environmentType}-${location}-001'

var containerNameandTag = 'blinkey:${deploymentId}'
var containerRegistryName = 'crblinkeyshared001'
var appServiceName = 'app-blinkey-${environmentType}'
var appServicePlanName = 'plan-blinkey-${environmentType}'

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: shardRgName
  location: location
}

resource environmentRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: environmentRgName
  location: location
}

module sharedInfrastructureDeployment 'modules/sharedinfratructure.bicep' = {
  scope: sharedResourceGroup
  name: 'Deployment_for_shared_infrastructure'
  params: {
    registryName: containerRegistryName
    location: location
  }
}

module blinkeyDeployment 'modules/blinkey.bicep' = {
  scope: environmentRg
  name: 'Deployment_for_blinkey_in_${environmentType == 'prod' ? 'production' : 'development'}_environment'
  dependsOn:[
    sharedInfrastructureDeployment
  ]
  params: {
    location: location
    containerImageAndTag: containerNameandTag
    containerRegistryName: containerRegistryName
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    sharedInfrastructureRg:sharedResourceGroup.name
  }
}

