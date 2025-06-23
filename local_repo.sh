#!/bin/bash

# Define the output file
REPO_FILE="/etc/yum.repos.d/local.repo"

# Create the file with the required contents
cat <<EOF > "$REPO_FILE"
[BaseOS]
name=BaseOS
baseurl=file:///cd/BaseOS
enabled=1
gpgcheck=0

[AppStream]
name=AppStream
baseurl=file:///cd/AppStream
enabled=1
gpgcheck=0
EOF

mkdir /cd
mount /dev/sr0 /cd
# Confirm completion
echo "Repository file '$REPO_FILE' has been created."
