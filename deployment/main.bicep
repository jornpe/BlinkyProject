targetScope = 'subscription'

@description('The environment that is deloyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string
param containerNameandTag string
param containerRegistryName string
param application string = 'blinkey'
param location string = 'norwayeast'
param shardRgName string = 'rg-${application}-shared-${location}-001'
param environmentRgName string = 'rg-${application}-${environmentType}-${location}-001'

@description('Date and time in this format: ')
param dateTime string = utcNow('F')

@description('Tags to add the all resources that is being deployed')
param tags object = {
  environment: environmentType == 'prod' ? 'Production' : 'Development'
  deploymentDate: dateTime
  CreationDate: dateTime
  Application: application
}
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
  name: '${application}-Shared-${environmentType == 'prod' ? 'production' : 'development'}'
  params: {
    registryName: containerRegistryName
    location: location
    tags: tags
  }
} 

module blinkeyDeployment 'modules/blinkey.bicep' = {
  scope: environmentRg
  name: '${application}-${environmentType == 'prod' ? 'production' : 'development'}'
  dependsOn:[
    sharedInfrastructureDeployment
  ]
  params: {
    location: location
    tags: tags
    containerImageAndTag: containerNameandTag
    containerRegistryName: containerRegistryName
    sharedInfrastructureRgName: sharedResourceGroup.name
    environmentType: environmentType
    application:application
  }
}


