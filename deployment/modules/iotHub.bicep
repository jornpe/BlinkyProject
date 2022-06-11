param iotHubName string

param location string

param sbQueueEndpointUri string

param sbQueueName string

param environmentType string


var sbqEndpointName = 'ep-sbq-${environmentType}-${location}'
var routeName = 'deviceroute-${environmentType}-${location}'

resource iotHub 'Microsoft.Devices/IotHubs@2021-07-02' = {
  name: iotHubName
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    routing: {
      endpoints: {
        serviceBusQueues: [
          {
            endpointUri: sbQueueEndpointUri
            entityPath: sbQueueName
            authenticationType: 'identityBased'
            name: sbqEndpointName
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
    }
  }
}

output iotHubPrincipalId string = iotHub.identity.principalId
