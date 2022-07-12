param appServicePlanName string
param location string
param appServiceName string
param containerSpecs string
param appConfigEndpoint string
param appInsightInstrumentationKey string
param tags object

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
  tags: tags
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
      minTlsVersion: '1.2'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
}

resource appServiceAppConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  parent: appService
  properties: {
    AppConfig__Endpoint: appConfigEndpoint
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightInstrumentationKey
  }
}

resource appServiceLogConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'logs'
  parent: appService
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Verbose'
      }
    }
    httpLogs: {
       fileSystem: {
         retentionInMb: 40
         retentionInDays: 7
         enabled: true
       }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}


output principalId string = appService.identity.principalId
