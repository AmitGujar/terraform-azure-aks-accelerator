#!/bin/bash

sudo apt-get update -y

sudo apt-get upgrade -y

sleep 10

echo "Installing Azure CLI......"

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo az aks install-cli

docker_install() {
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker $USER
}

self_hosted_agent() {
    cd /home/amitgujar || exit 1
    rm -rf sha
    wget https://vstsagentpackage.azureedge.net/agent/4.248.0/vsts-agent-linux-x64-4.248.0.tar.gz
    mkdir sha
    mv vsts-agent-linux-x64-4.248.0.tar.gz sha/
    cd sha || exit 1
    tar -xzvf vsts-agent-linux-x64-4.248.0.tar.gz
    ./config.sh --unattended --url https://dev.azure.com/$YOUR_ORGANIZATION --auth pat --token $PAT_TOKEN --pool $AGENT_POOL --agent $AGENT_NAME --replace --acceptTeeEula
    sudo ./svc.sh install
    sudo ./svc.sh start
}

self_hosted_agent
docker_install
