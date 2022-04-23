param location string = resourceGroup().location

param divingLogName string = 'divinglog'

var owner = 'anderas'
var logRetentionInDays = 30
var serverFarmSku = 'B1'

resource divingLogStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${divingLogName}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  tags: {
    type: 'hot'
    owner: owner
  } 
}

resource userContentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${divingLogStorage.name}/default/usercontnet'
  properties: {  }
  
} 

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  location: location
  name: divingLogName
  properties: {
    retentionInDays: logRetentionInDays   
  }
  tags: {
    owner: owner
  }
}

resource insight 'Microsoft.Insights/components@2020-02-02' = {
  kind: 'java'
  location: location
  name: divingLogName
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: workspace.id
  }
  tags: {
    owner: owner
  }
}

resource serverFarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  location: location
  name: '${divingLogName}-server'
  sku: {
    name: serverFarmSku
  }
  kind: 'app'
  properties: {
    reserved: false
  }

  tags: {
    owner: owner
  }
}

resource api 'Microsoft.Web/sites@2021-02-01' = {
  location: location
  name:  '${divingLogName}-api'
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      alwaysOn: true
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    owner: owner
  }
}

resource apiConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: api
  properties: {
    javaVersion: '17'
    javaContainer: 'JAVA'
    javaContainerVersion: 'SE'
    APPINSIGHTS_INSTRUMENTATIONKEY: insight.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: insight.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    XDT_MicrosoftApplicationInsights_Java: '1'
    XDT_MicrosoftApplicationInsights_Mode: 'default'
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: '${divingLogName}-cosmos'
  kind: 'GlobalDocumentDB' 
  location: location
  properties: {
    isVirtualNetworkFilterEnabled: false
    capabilities: [
      {
          name: 'EnableServerless'
      }
    ]
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        failoverPriority: 0
        locationName: 'North Europe'
      }
    ]
  }
  tags: {
    owner: owner
  }
}

