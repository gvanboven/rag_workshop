// Azure OpenAI account with the deployments needed by this workshop:
// - chat model (also reused for reranking, per .env-sample)
// - embedding model
// Sized to the smallest available capacity for learning purposes.
param location string
param namePrefix string

var accountName = '${namePrefix}-aoai-${uniqueString(resourceGroup().id)}'

var chatDeploymentName = 'gpt-5-mini'
var embeddingDeploymentName = 'text-embedding-3-small'
var apiVersion = '2024-12-01-preview'

resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: accountName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
  }
}

resource chatDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: account
  name: chatDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5-mini'
      version: '2025-08-07'
    }
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: account
  name: embeddingDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
  }
  dependsOn: [
    chatDeployment
  ]
}

output endpoint string = account.properties.endpoint
output accountName string = account.name
output chatDeploymentName string = chatDeploymentName
output embeddingDeploymentName string = embeddingDeploymentName
output apiVersion string = apiVersion
