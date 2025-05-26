This cluster is private. 
Following are the integrated components:
aks-vnet.bicep : This is vnet for aks cluster and for all the services integrated with AKS. As the cluster is private so if any azure services needs to be integrated with other Azure resources having different vnet then VNET peering has to be done.
azfw.bicep: This is firewall to handle the traffic or to route the traffic
bastion.bicep: This is Azure Bstion componenets for RDP or SSH connectivity to vm directly from the Azure portal over ssl.
jump-box.bicep : This component is to create vm which can be used to connect to Private cluster and provision it using kubectl
acr.bicep: This is azure container repository to store the build image and this acr is attached to kubernetes for CICD.
aks-cluster.bicep: This component is for AKS cluster creation. Inside this cluster itself the LA workspace is getting created also to store diagnostic information.
main.bicep : This is main bicep template
parameters.json : This is parameters file which can be used to pass the parameter 

az deployment group create 