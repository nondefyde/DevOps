#! /bin/bash

while [ "$(hostname -I)" = "" ]; do
  echo -e "\e[1A\e[KNo network: $(date)"
  sleep 1
done
echo "I have network";

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# The following command is to set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable"

# Update the apt package index, and install the latest version of Docker Engine and contained, or go to the next step to install a specific version
sudo apt update
sudo apt install -y docker-ce

#Install Docker compose
sudo mkdir -p /home/adminuser/.docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o /home/adminuser/.docker/cli-plugins/docker-compose
sudo chmod +x /home/adminuser/.docker/cli-plugins/docker-compose
sudo docker compose version


sudo docker pull jwilder/nginx-proxy:latest
sudo docker network create nginx-proxy
sudo docker volume create app-volume

sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt-get install jq --yes

