// Azure AI Search, Free (F1) tier — cheapest option (no cost).
// NOTE: F1 does not support the Semantic ranker add-on used by this
// workshop's hybrid search + semantic ranking module. Upgrade to
// Basic or higher if you need that feature.
param location string
param namePrefix string

var serviceName = '${namePrefix}-search-${uniqueString(resourceGroup().id)}'

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: serviceName
  location: location
  sku: {
    name: 'free'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
  }
}

output endpoint string = 'https://${searchService.name}.search.windows.net'
output serviceName string = searchService.name
