#!bin/bash
cat <<EOF > /etc/yum.repos.d/local.repo
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
mount /dev/sr0 /cd/