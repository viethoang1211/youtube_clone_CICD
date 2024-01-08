#!/bin/bash
sudo apt update -y
# Tải và cài đặt khóa GPG từ Adoptium để xác minh các gói phần mềm.
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc

echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y

# Cài đặt JDK 17 từ Adoptium.
sudo apt install temurin-17-jdk -y

/usr/bin/java --version
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
# Install jenkins
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins

##Install Docker and Run SonarQube as Container
sudo apt-get update
sudo apt-get install docker.io -y
# Thêm người dùng Ubuntu và Jenkins vào nhóm docker để có quyền thực thi Docker mà không cần sudo.
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins  
newgrp docker
# Cấp quyền truy cập vào socket của Docker cho tất cả mọi người.
sudo chmod 777 /var/run/docker.sock
# Chạy container SonarQube với tên "sonar" và mở cổng 9000 trên máy host để truy cập.
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

#install trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y