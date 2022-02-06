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
  kind: 'linux'
  properties: {
    reserved: true
  }

  tags: {
    owner: owner
  }
}

resource api 'Microsoft.Web/sites@2021-02-01' = {
  location: location
  name:  '${divingLogName}-api'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      linuxFxVersion: 'TOMCAT|9.0-java11'
      alwaysOn: true
    }
  }
  tags: {
    owner: owner
  }
}

resource apiConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: api
  properties: {
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    APPINSIGHTS_INSTRUMENTATIONKEY: insight.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: insight.properties.ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: 'disabled'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    SnapshotDebugger_EXTENSION_VERSION: 'disabled'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    APPLICATIONINSIGHTS_CONFIGURATION_CONTENT: ''
  }
}


