@description('List of key value configuration pairs ')
param keyValues array

@description('Name of the app configuration resource')
param configStoreName string

@description('The environment that is depoyed')
@allowed([
  'dev'
  'prod'
])  
param environmentType string

var environmentLabel = environmentType == 'prod' ? 'Production' : 'Development'

resource appconfigStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: configStoreName
}

resource keyValueConfigPairs 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for keyValue in keyValues: {
  name: '${keyValue.Key}$${environmentLabel}'
  parent: appconfigStore
  properties: {
    value: keyValue.Value
  }
}]
