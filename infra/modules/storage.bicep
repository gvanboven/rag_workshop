// Storage account for blob storage (BLOB_CONNECTION_STRING), cheapest
// redundancy tier. Used by the CMS/blob-content notebooks.
param location string
param namePrefix string

var accountName = toLower('${namePrefix}st${uniqueString(resourceGroup().id)}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

output accountName string = storageAccount.name
