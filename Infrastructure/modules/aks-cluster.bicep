param aksClusterName string
param subnetId string
param adminUsername string = 'azureuser'
param adminPublicKey string

param aksSettings object = {
  kubernetesVersion: null
  identity: 'SystemAssigned'
  networkPlugin: 'azure'
  networkPolicy: 'calico'
  serviceCidr: '172.16.0.0/22' // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
  dnsServiceIP: '172.16.0.10' // Ip Address for K8s DNS
  outboundType: 'UDR'
  loadBalancerSku: 'standard'
  sku_tier: 'Free'				
  enableRBAC: true 
  aadProfileManaged: true
  adminGroupObjectIDs: [] 
}
//Default Node Pool
param defaultNodePool object = {
  name: 'systempool01'
  count: 1
  vmSize: 'Standard_D2s_v3'
  osDiskSizeGB: 5
  osDiskType: 'Ephemeral'
  vnetSubnetID: subnetId
  osType: 'Linux'
  maxCount: 2
  minCount: 1
  enableAutoScaling: true
  type: 'VirtualMachineScaleSets'
  mode: 'System'
  orchestratorVersion: null
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/2020-03-01-preview/workspaces?tabs=json
//Log analytics workspace resource
resource aksAzureMonitor 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${aksClusterName}-logA'
  tags: {}
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 30
    }
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=json#ManagedClusterAgentPoolProfile
resource aks 'Microsoft.ContainerService/managedClusters@2024-06-02-preview' = {
  name: aksClusterName
  location: resourceGroup().location
  identity: {
    type: aksSettings.identity
  }
  sku: {
    name: 'Base'
    tier: aksSettings.sku_tier
  }
  properties: {
    kubernetesVersion: aksSettings.kubernetesVersion
    dnsPrefix: aksSettings.clusterName
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: adminPublicKey
          }
        ]
      }
    }
    
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: aksAzureMonitor.id
        }
      }
    }
    
    enableRBAC: aksSettings.enableRBAC

    enablePodSecurityPolicy: false // setting to false since PSPs will be deprecated in favour of Gatekeeper/OPA

    networkProfile: {
      networkPlugin: aksSettings.networkPlugin 
      networkPolicy: aksSettings.networkPolicy 
      serviceCidr: aksSettings.serviceCidr  // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: aksSettings.dnsServiceIP // Ip Address for K8s DNS
      outboundType: aksSettings.outboundType 
      loadBalancerSku: aksSettings.loadBalancerSku 
    }

    aadProfile: {
      managed: aksSettings.aadProfileManaged
      // enableAzureRBAC: true // Cross-Tenant Azure RBAC doesn't work - must be same tenant as the cluster subscription
      adminGroupObjectIDs: aksSettings.adminGroupObjectIDs
    }

    autoUpgradeProfile: {}

    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: 'none'
      enablePrivateClusterPublicFQDN: true
      
    }
    
    agentPoolProfiles: [
      defaultNodePool
    ]
  }
}


output identity string = aks.identity.principalId
