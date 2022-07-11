targetScope = 'subscription'

@description('The environment that is deloyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string
param containerNameandTag string
param containerRegistryName string
param location string = 'norwayeast'
param shardRgName string = 'rg-blinkey-shared-${location}-001'
param environmentRgName string = 'rg-blinkey-${environmentType}-${location}-001'

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: shardRgName
  location: location
}

resource environmentRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: environmentRgName
  location: location
}

module sharedInfrastructureDeployment 'modules/containerRegistry.bicep' = {
  scope: sharedResourceGroup
  name: 'Blinkey-Shared-${environmentType == 'prod' ? 'production' : 'development'}'
  params: {
    registryName: containerRegistryName
    location: location
  }
}

module blinkeyDeployment 'modules/blinkey.bicep' = {
  scope: environmentRg
  name: 'Blinkey-${environmentType == 'prod' ? 'production' : 'development'}'
  dependsOn:[
    sharedInfrastructureDeployment
  ]
  params: {
    location: location
    containerImageAndTag: containerNameandTag
    containerRegistryName: containerRegistryName
    sharedInfrastructureRgName: sharedResourceGroup.name
    environmentType: environmentType
  }
}


