// Minimal, cheapest-tier Azure infra for the RAG workshop.
// Deploys at subscription scope: creates a resource group and the four
// services listed in the README prerequisites, sized for learning
// (not production).
targetScope = 'subscription'

@description('Name of the resource group to create.')
param resourceGroupName string = 'rg-rag-workshop'

@description('Azure region for all resources.')
param location string = 'swedencentral'

@description('Short prefix used to build resource names (lowercase alphanumeric).')
@minLength(3)
@maxLength(12)
param namePrefix string = 'ragws'

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
}

module openAi 'modules/openai.bicep' = {
  name: 'openai-deployment'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

module search 'modules/search.bicep' = {
  name: 'search-deployment'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

module docIntel 'modules/document-intelligence.bicep' = {
  name: 'docintel-deployment'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_DEPLOYMENT_NAME string = openAi.outputs.chatDeploymentName
output AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME string = openAi.outputs.embeddingDeploymentName
output AZURE_OPENAI_RERANK_DEPLOYMENT_NAME string = openAi.outputs.chatDeploymentName
output AZURE_OPENAI_API_VERSION string = openAi.outputs.apiVersion

output SEARCH_SERVICE_ENDPOINT string = search.outputs.endpoint

output DOC_INTEL_ENDPOINT string = docIntel.outputs.endpoint

output STORAGE_ACCOUNT_NAME string = storage.outputs.accountName
