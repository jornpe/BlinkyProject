param principalIds array
param messageBusName string

// Role name: "Azure Service Bus Data Sender" https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-sender
var roleDefenitionId = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'

resource messageBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: messageBusName
}

resource appServiceAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [ for assigneeId in principalIds: {
  name: guid(messageBus.id, assigneeId, roleDefenitionId)
  scope: messageBus
  properties: {
    principalId: assigneeId
    roleDefinitionId: roleDefenitionId
    principalType: 'ServicePrincipal'
  }
}]
