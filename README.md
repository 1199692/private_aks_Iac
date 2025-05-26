#  Private Azure AKS with Infrastructure as Code (Bicep)

This repository contains a complete setup to deploy a **private Azure Kubernetes Service (AKS)** cluster using **Infrastructure as Code (Bicep)**, integrated with **CI/CD pipelines**, and supporting resources such as Azure Firewall, Bastion, and ACR.

---

## 📁 Project Structure

### 1. `infrastructure/` – Core Azure Resources in Bicep

This folder contains Bicep modules to provision and configure all necessary Azure infrastructure components:

#### 🔹 Modules:
- `acr.bicep` – Azure Container Registry
- `aks-cluster.bicep` – Private AKS cluster
- `aks-vnet.bicep` – Virtual network and subnets
- `azfw.bicep` – Azure Firewall configuration
- `bastion.bicep` – Bastion host setup
- `jump-box.bicep` – Jumpbox server (for private access)
- `main.bicep` – Main orchestrating Bicep file that ties all modules together
- `parameters.json` – Parameters file to pass the parameters


#### 📂 `aksComponents/`
This subfolder includes Kubernetes component definitions as Bicep resources:
- `roleBinding.bicep` – Role-based access control
- `secret.bicep` – Kubernetes secrets
- `serviceAccount.bicep` – Service account definition

---

### 2. `pipeline/` – CI/CD and Application Deployment

This folder handles containerization and Kubernetes workload deployment through pipelines.

#### 📂 `Docker/`
Contains Dockerfiles for application containerization.

#### 📂 `aks-manifests/`
Includes Kubernetes YAML manifests (Deployments, Services, etc.)

#### 🛠️ CI/CD Pipelines:
- `build-pipeline.yml` – Builds and pushes Docker images to ACR
- `deploy-infra-pipeline.yml` – Deploys infrastructure using Bicep
- `deploy-app-pipeline.yml` – Deploys apps to AKS using manifests

---

## ✅ Features

- End-to-end **private AKS cluster** deployment
- Modular **IaC using Bicep**
- Secure network topology with Azure Firewall and Bastion
- CI/CD pipelines using **Azure DevOps** or **GitHub Actions**
- Kubernetes access configured with service accounts and RBAC
- Dockerized workloads for AKS

---

## 📌 Prerequisites

- Azure CLI & Bicep CLI
- Azure subscription with required permissions
- Azure DevOps or GitHub Actions (for pipelines)
- Docker (for local builds if needed)

---
## 🚀 Deployment

To deploy the infrastructure using the main Bicep file and a parameters file, run the following command:

### 📍 At the **subscription level**:

```bash
az deployment sub create \
  --location <location> \
  --template-file ./infrastructure/main.bicep \
  --parameters @./infrastructure/parameters.json
```
### 📍 At the resource group level:

```bash
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file ./infrastructure/main.bicep \
  --parameters @./infrastructure/parameters.json
```
## 🚧 Work in Progress

This setup can be extended with:
- Monitoring (Azure Monitor, Prometheus/Grafana)
- Ingress controller & cert-manager
- Secret management with Azure Key Vault

---

## 📬 Feedback / Contributions

Feel free to open issues or submit pull requests to improve or extend this repo.
