param location string
param appInsightName string
param tags object


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: tags
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
