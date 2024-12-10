@description('The name of the App Service')
param name string

@description('The location of the App Service')
param location string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the container registry')
param containerRegistryName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('The URL of the Docker registry server')
@secure()
param dockerRegistryServerUrl string

@description('The username for the Docker registry')
@secure()
param dockerRegistryServerUserName string

@description('The password for the Docker registry')
@secure()
param dockerRegistryServerPassword string

var appSettings = [
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: dockerRegistryServerUrl
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
    value: dockerRegistryServerUserName
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
    value: dockerRegistryServerPassword
  }
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: 'false'
  }
]

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: appServicePlanName
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: appSettings
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
    }
  }
}

output id string = appService.id
output name string = appService.name
output defaultHostName string = appService.properties.defaultHostName
