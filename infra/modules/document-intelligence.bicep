// Azure Document Intelligence, Free (F0) tier.
// NOTE: F0 is capped at 500 pages/month and limits per-document page
// counts depending on the model used — fine for workshop-scale sample
// PDFs, not for production volumes.
param location string
param namePrefix string

var accountName = '${namePrefix}-docintel-${uniqueString(resourceGroup().id)}'

resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: accountName
  location: location
  kind: 'FormRecognizer'
  sku: {
    name: 'F0'
  }
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
  }
}

output endpoint string = account.properties.endpoint
output accountName string = account.name
