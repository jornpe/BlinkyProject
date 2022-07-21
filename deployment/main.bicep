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
param infrastructureRgName string = 'rg-${application}-shared-${location}-001'
param environmentRgName string = 'rg-${application}-${environmentType}-${location}-001'
param appConfigName string = 'appc-${application}-${location}-001'

@description('Date and time in this format: ')
param dateTime string = dateTimeAdd(utcNow('F'), 'PT2H') // Could not find a solution to get correct time zone so added 2 hours. 

@description('Tags to add the all resources that is being deployed')
param tags object = {
  environment: environmentType == 'prod' ? 'Production' : 'Development'
  CreationDate: dateTime
  Application: application
}
resource infrastructureRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: infrastructureRgName
  location: location
  tags: tags
}

resource environmentRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: environmentRgName
  location: location
  tags: tags
}

module infrastructureDeployment 'modules/infrastructure.bicep' = {
  scope: infrastructureRg
  name: '${application}-Shared-${environmentType == 'prod' ? 'production' : 'development'}'
  params: {
    acrName: containerRegistryName
    location: location
    tags: tags
    appConfigName: appConfigName
  }
} 

module blinkeyDeployment 'modules/blinkey.bicep' = {
  scope: environmentRg
  name: '${application}-${environmentType == 'prod' ? 'production' : 'development'}'
  dependsOn:[
    infrastructureDeployment
  ]
  params: {
    location: location
    tags: tags
    containerImageAndTag: containerNameandTag
    containerRegistryName: containerRegistryName
    infrastructureRgName: infrastructureRgName
    environmentType: environmentType
    application:application
    appConfigName: appConfigName
  }
}


