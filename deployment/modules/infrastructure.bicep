param acrName string
param location string
param tags object
param appConfigName string


module containerRegistry 'resources/containerRegistry.bicep' = {
  name: 'container-registry'
  params: {
    registryName: acrName
    location: location
    tags: tags
  }
} 

module appConfigStore 'resources/appConfig.bicep' = {
  name: 'AppConfigStore'
  params: {
    configStoreName: appConfigName
    location: location
    tags: tags
  }
} 
