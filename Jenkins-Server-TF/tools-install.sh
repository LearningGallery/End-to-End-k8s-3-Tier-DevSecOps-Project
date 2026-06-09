#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e 

# ==========================================
# CONFIGURATION & VERSION PINNING
# ==========================================
KUBECTL_VERSION="v1.28.4"
EKSCTL_VERSION="latest" 
LOG_FILE="devops_install_$(date +%Y%m%d_%H%M%S).log"

# ==========================================
# LOGGING SETUP
# ==========================================
# Redirect all stdout and stderr to both the console and the log file automatically
exec > >(tee -a "$LOG_FILE") 2>&1

# Custom logging function for readable milestones
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n[$timestamp] === $1 ==="
}

log "Starting Installation of DevOps Tools"
log "Log file created at: $LOG_FILE"

# Update System
log "Updating system package index..."
sudo apt-get update -y

# 1. Installing Java
log "Installing Java..."
sudo apt-get install openjdk-21-jre openjdk-21-jdk -y

# 2. Installing Jenkins (LTS)
log "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

# 3. Installing Docker
log "Installing Docker..."
sudo apt-get install docker.io -y
sudo usermod -aG docker jenkins || true
sudo usermod -aG docker ubuntu || true
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock

# 4. Run Docker Container of Sonarqube (LTS)
log "Starting SonarQube Container..."
docker run -d --restart=always --name sonar -p 9000:9000 sonarqube:lts-community

# 5. Installing AWS CLI
log "Installing AWS CLI..."
sudo apt-get update -y
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# 6. Installing Kubectl (Pinned Version)
log "Installing Kubectl ($KUBECTL_VERSION)..."
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# 7. Installing eksctl
log "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# 8. Installing Terraform
log "Installing Terraform..."
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update -y
sudo apt-get install terraform -y

# 9. Installing Trivy
log "Installing Trivy..."
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor --yes -o /usr/share/keyrings/trivy-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy-keyring.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
sudo apt-get update -y
sudo apt-get install trivy -y

# 10. Installing Helm
log "Installing Helm..."
sudo snap install helm --classic


# ==========================================
# VERIFICATION SUMMARY
# ==========================================
log "Generating Installation Summary..."
echo "========================================"
echo "         INSTALLED TOOL VERSIONS        "
echo "========================================"

echo "[Java]"
java -version 2>&1 | head -n 1

echo -e "\n[Jenkins]"
jenkins --version

echo -e "\n[Docker]"
docker --version

echo -e "\n[SonarQube Container]"
docker ps --filter "name=sonar" --format "{{.Names}} is running | Image: {{.Image}}"

echo -e "\n[AWS CLI]"
aws --version

echo -e "\n[Kubectl]"
kubectl version --client

echo -e "\n[eksctl]"
eksctl version

echo -e "\n[Terraform]"
terraform --version | head -n 1

echo -e "\n[Trivy]"
trivy --version | head -n 1

echo -e "\n[Helm]"
helm version

echo "========================================"
log "Installation Complete! Review $LOG_FILE for full details."