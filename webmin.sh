#!/bin/bash
curl -fsSL setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh -o setup-repos.sh
chmod +x setup-repos.sh
sh setup-repos.sh
yum install webmin -y
