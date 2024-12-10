@description('The name of the Azure Container Registry')
param name string

@description('The location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool = true

@description('The resource ID of the key vault to store credentials')
param adminCredentialsKeyVaultResourceId string

@description('The name of the key vault secret for the admin username')
@secure()
param adminCredentialsKeyVaultSecretUserName string

@description('The name of the key vault secret for the first admin password')
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('The name of the key vault secret for the second admin password')
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: split(adminCredentialsKeyVaultResourceId, '/')[8]
}

resource adminUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: adminCredentialsKeyVaultSecretUserName
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

resource adminPassword1Secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: adminCredentialsKeyVaultSecretUserPassword1
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

resource adminPassword2Secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: adminCredentialsKeyVaultSecretUserPassword2
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

output loginServer string = containerRegistry.properties.loginServer
