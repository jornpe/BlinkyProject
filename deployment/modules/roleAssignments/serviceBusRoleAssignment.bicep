param principalId string
param serviceBusName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

// Role name: "Azure Service Bus Data Receiver" - Allows for receive access to Azure Service Bus resources. https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver
var serviceBusDataReceiverid = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
resource serviceBusDataReceiver 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: serviceBusDataReceiverid
}

resource iotHubDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(serviceBusDataReceiver.id, principalId, serviceBus.id)
  scope: serviceBus
  properties: {
    principalId: principalId
    roleDefinitionId: serviceBusDataReceiver.id
    principalType: 'ServicePrincipal'
  }
}
