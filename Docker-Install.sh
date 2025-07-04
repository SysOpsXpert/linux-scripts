#!/bin/bash
#docker-script install
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

#docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
