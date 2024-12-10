@description('Required. Name of your Azure Container Registry.')
@minLength(5)
@maxLength(50)
param name string

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = true

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('The name of the App Service')
param appServiceName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'registry-deployment'
  params: {
    name: name
    location: location
    acrAdminUserEnabled: acrAdminUserEnabled
    adminCredentialsKeyVaultResourceId: keyVault.outputs.id
    adminCredentialsKeyVaultSecretUserName: 'acr-admin-username'
    adminCredentialsKeyVaultSecretUserPassword1: 'acr-admin-password1'
    adminCredentialsKeyVaultSecretUserPassword2: 'acr-admin-password2'
  }
}


module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanGuy'
  params: {
    name: 'appServicePlanGuy'
    location: location
    sku: {
      name: 'B1'
      capacity: 1
      tier: 'Basic'
    }
  }
}


module appService 'modules/app-service.bicep' = {
  name: 'appServiceGuy'
  params: {
    name: appServiceName
    location: location
    appServicePlanName: appServicePlan.name
    containerRegistryName: name
    containerRegistryImageName: containerRegistryImageName
    containerRegistryImageVersion: containerRegistryImageVersion
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: '${name}-kv'
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}


output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output appServiceId string = appService.outputs.id
output appServiceName string = appService.outputs.name
output appServiceDefaultHostName string = appService.outputs.defaultHostName
