# 🚀 Advanced End-to-End DevSecOps Kubernetes Three-Tier Project

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%232C5263.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

## 📝 Project Overview
This project is an advanced, end-to-end guide for deploying, securing, and monitoring a scalable three-tier application (Database, Backend, Frontend) on AWS using Kubernetes. It emphasizes DevSecOps best practices by integrating security scanning into CI/CD pipelines, automating infrastructure with Terraform, and using GitOps principles for continuous delivery.

## 🛠️ Tools & Technologies Used
* **Cloud Provider:** Amazon Web Services (AWS)
* **Infrastructure as Code (IaC):** Terraform & AWS CLI
* **Containerization:** Docker & Amazon Elastic Container Registry (ECR)
* **Orchestration:** Amazon EKS (Elastic Kubernetes Service), `eksctl`, Helm
* **Continuous Integration (CI):** Jenkins
* **Continuous Delivery/GitOps (CD):** ArgoCD
* **Security & Code Quality (DevSecOps):** SonarQube (Code analysis), Trivy (Vulnerability scanning)
* **Monitoring & Observability:** Prometheus & Grafana

## 🏗️ Architecture & High-Level Flow
1. **Infrastructure Provisioning:** Terraform provisions an EC2 instance to serve as the Jenkins CI Server.
2. **Cluster Creation:** `eksctl` spins up a managed Kubernetes cluster on AWS (EKS).
3. **CI Pipeline (Jenkins):** Code commits trigger Jenkins pipelines. The code is pulled, scanned with SonarQube, built into Docker images, scanned again using Trivy, and pushed securely to Amazon ECR.
4. **GitOps CD (ArgoCD):** ArgoCD syncs the manifest changes from the repository and deploys the frontend, backend, and MongoDB database to the EKS cluster.
5. **Traffic Routing:** An AWS Application Load Balancer (ALB) is configured to route external traffic efficiently.
6. **Observability:** Prometheus scrapes cluster metrics, which are visualized via Grafana Dashboards.

## ⚙️ Prerequisites
Before getting started, ensure you have the following:
* An AWS Account with permissions to create resources (IAM, VPC, EKS, EC2, ECR).
* Terraform installed on your local machine.
* AWS CLI installed and configured.
* Basic understanding of Kubernetes, Jenkins, and Linux command-line operations.

---

## 🚀 Step-by-Step Execution Guide

### Step 1: IAM User Setup
1. Navigate to the AWS IAM console.
2. Create an IAM User with `AdministratorAccess`.
3. Generate AWS Access Keys and download the CSV. Configure them locally using `aws configure`.

### Step 2: Infrastructure Provisioning (Terraform)
Navigate to the Terraform directory in this repository to launch the Jenkins server.
```bash
cd terraform
terraform init
terraform plan
terraform apply --auto-approve

```

### Step 3: Jenkins Server Configuration

SSH into your newly provisioned EC2 instance and install the required utilities:

* Jenkins, Docker, SonarQube, Terraform, `kubectl`, AWS CLI, and Trivy.
* Access Jenkins at `http://<EC2-PUBLIC-IP>:8080`.

### Step 4: EKS Cluster Deployment

Use `eksctl` on your Jenkins server to spin up the Kubernetes cluster:

```bash
eksctl create cluster --name three-tier-cluster --region us-east-1 --node-type t3.medium --nodes 2

```

### Step 5: AWS Load Balancer Controller Setup

1. Create an IAM policy and attach it to an OIDC provider.
2. Deploy the AWS Application Load Balancer (ALB) Controller to your EKS cluster to handle ingress traffic automatically.

### Step 6: Amazon ECR Repositories

Create private Elastic Container Registry (ECR) repositories for your application images.

```bash
aws ecr create-repository --repository-name frontend-app --region us-east-1
aws ecr create-repository --repository-name backend-app --region us-east-1

```

### Step 7: Security & Code Quality (SonarQube & Trivy)

1. Access SonarQube via `http://<EC2-PUBLIC-IP>:9000`.
2. Generate a Webhook and Security Token.
3. Integrate SonarQube and Trivy into your Jenkins credentials store for pipeline execution.

### Step 8: Jenkins CI/CD Pipelines

Set up multi-branch pipelines in Jenkins to completely automate the following tasks:

* Code checkout
* SonarQube Analysis & Quality Gate check
* Docker Build
* Trivy File & Image Scanning
* Push Docker Image to ECR
* Update Kubernetes manifests with the new image tag.

### Step 9: ArgoCD Installation (GitOps)

Install ArgoCD onto your EKS cluster:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

```

Expose ArgoCD via LoadBalancer, retrieve the admin password, and connect your repository to sync application deployment manifests.

### Step 10: Deploy the Three-Tier Application

Using ArgoCD, deploy the application components:

* **Database Layer:** Persistent Volumes (PV), Claims (PVC), and MongoDB deployment.
* **Backend Layer:** NodeJS API deployments and services.
* **Frontend Layer:** ReactJS user interface and ingress configurations mapping to your domain.

### Step 11: Monitoring (Prometheus & Grafana)

Deploy the Kube-Prometheus stack via Helm:

```bash
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

```

Access Grafana using Port-Forwarding or LoadBalancer to build customized dashboards tracking pod health, CPU/memory usage, and application metrics.

---

## 🧹 Clean Up

To avoid unexpected AWS charges, destroy all resources when the project is finished.

```bash
# Delete ArgoCD Applications
kubectl delete -f application.yaml

# Delete EKS Cluster
eksctl delete cluster --name three-tier-cluster --region us-east-1

# Destroy EC2 Infrastructure via Terraform
cd terraform
terraform destroy --auto-approve

```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://www.google.com/search?q=../../issues).

## 📄 License

This project is [MIT](https://www.google.com/search?q=LICENSE) licensed.