param appServicePlanName string
param location string
param appServiceName string
param containerSpecs string

resource appservicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appservicePlan.id
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: containerSpecs
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appService object = appService
