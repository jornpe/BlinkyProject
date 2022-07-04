param iotHubName string

param location string

param sbQueueEndpointUri string

param sbQueueName string

param serviceBusName string

param environmentType string

var sbqEndpointName = 'ep-sbq-${environmentType}-${location}'
var routeName = 'deviceroute-${environmentType}-${location}'
var iotHubIdentityName = 'id-iothub-${environmentType}-${location}-001'
// Role name: "Azure Service Bus Data Sender" https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-sender
var roleDefenitionId = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'

resource messageBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

resource azureServiceBusDataSenderRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' existing = {
  name: roleDefenitionId
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: iotHubIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(messageBus.id, identity.id, azureServiceBusDataSenderRole.id)
  scope: messageBus
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: azureServiceBusDataSenderRole.id
    principalType: 'ServicePrincipal'
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2021-07-02' = {
  name: iotHubName
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}' : {}
    }
  }
  dependsOn: [
    roleAssignment
  ]
  properties: {
    routing: {
      endpoints: {
        serviceBusQueues: [
          {
            name: sbqEndpointName
            endpointUri: sbQueueEndpointUri
            entityPath: sbQueueName
            authenticationType: 'identityBased'
            identity: {
              userAssignedIdentity: identity.id
            }
          }
        ]
      }
      routes: [
        {
          name: routeName
          source: 'DeviceMessages'
          condition: 'true'
          endpointNames: [
            sbqEndpointName
          ]
          isEnabled: true
        }
      ]
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
    }
  }
}

output iotHubHostName string = iotHub.properties.hostName
output principalId string = iotHub.identity.principalId
