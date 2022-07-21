@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the message queue')
param serviceBusQueueName string

@description('Location for all resources.')
param location string

param tags object

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
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
    defaultMessageTimeToLive: 'P1D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    lockDuration: 'PT30S'
    status: 'Active'
    enableBatchedOperations: true
  }
}

output principalId string = serviceBus.identity.principalId

