param appServicePlanName string
param location string
param appServiceName string
param containerSpecs string

// var appSettings = [
//   {
//     name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE:'
//     value: false
//   }
// ]

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
    httpsOnly: true
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: containerSpecs
      //appSettings: appSettings
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appService object = appService
