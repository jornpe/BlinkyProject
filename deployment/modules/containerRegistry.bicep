@description('Location to use for the resources')
param location string

@description('Name of the container registry instance')
param registryName string

param tags object

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
  tags: tags
}
