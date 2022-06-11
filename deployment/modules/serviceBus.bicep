@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the message queue')
param serviceBusQueueName string

@description('Location for all resources.')
param location string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  parent: serviceBus
  name: serviceBusQueueName
  properties: {
    maxMessageSizeInKilobytes: 256
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    deadLetteringOnMessageExpiration: true
    enableExpress: false
    enablePartitioning: false
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    defaultMessageTimeToLive: 'P1D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    lockDuration: 'PT30S'
    status: 'Active'
    enableBatchedOperations: true
  }
}

output serviceBusPrincipalId string = serviceBus.identity.principalId
output sbUrl string = 'sb://${serviceBusQueue.name}.servicebus.windows.net'

