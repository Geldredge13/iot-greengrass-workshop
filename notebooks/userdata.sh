#!/bin/bash -v

echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.UTF-8 >> /etc/environment

if ! uname -r |grep amzn ; then
    exit 1
fi

cd /tmp/
# - "wget http://greengrass-bootcamp.s3-website.eu-central-1.amazonaws.com/cfn/ggc-user-data150.tar
wget https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/1.7.0/greengrass-linux-x86-64-1.7.0.tar.gz

# - "tar xf ggc-user-data150.tar
tar zxf /tmp/greengrass-linux-x86-64-1.7.0.tar.gz -C /

# - "cp /tmp/root.ca.pem /greengrass/certs/
useradd -r ggc_user
groupadd -r ggc_group

echo 'fs.protected_hardlinks = 1' >> /etc/sysctl.d/00-defaults.conf
echo 'fs.protected_symlinks = 1' >> /etc/sysctl.d/00-defaults.conf

sysctl -p
sysctl -p /etc/sysctl.d/00-defaults.conf

echo '# AWS Greengrass' >> /etc/fstab
echo 'cgroup /sys/fs/cgroup cgroup defaults 0 0' >> /etc/fstab
mount -a


cd /tmp/
wget https://s3.amazonaws.com/edgeworkshop18/edgeworkshop.zip

unzip edgeworkshop.zip
yum -y install sqlite telnet jq strace git tree

PATH=$PATH:/usr/local/bin
pip install --upgrade pip
hash -r
pip install AWSIoTPythonSDK
pip install urllib3
pip install --upgrade awscli
pip install boto3
pip install fire
pip install gg-group-setup

mkdir -p /home/ec2-user/car1
mkdir -p /home/ec2-user/car2
mkdir -p /home/ec2-user/iotanalytics
cp /tmp/edgeworkshop/p*.sh /tmp/edgeworkshop/c*.sh /home/ec2-user/
cp /tmp/edgeworkshop/u*.sh /home/ec2-user/
cp /tmp/edgeworkshop/*.json /home/ec2-user/
cp /tmp/edgeworkshop/*.py /tmp/edgeworkshop/start*.sh /home/ec2-user/car1/
cp /tmp/edgeworkshop/*.py /tmp/edgeworkshop/start*.sh /home/ec2-user/car2/
cp /tmp/edgeworkshop/iotanalytics/* /home/ec2-user/iotanalytics/
chown -R ec2-user:ec2-user /home/ec2-user/*
chmod 755 /home/ec2-user/*.sh
chmod 755 /home/ec2-user/car1/*.sh
chmod 755 /home/ec2-user/car2/*.sh
REGION=<CHOOSE REGION>
mkdir /home/ec2-user/.aws
echo '[default]' > /home/ec2-user/.aws/config
echo 'output = json' >> /home/ec2-user/.aws/config
echo \"region = $REGION\" >> /home/ec2-user/.aws/config
chown -R ec2-user:ec2-user /home/ec2-user/.aws
chmod 400 /home/ec2-user/.aws/config
mkdir /root/.aws
echo '[default]' > /root/.aws/config
echo 'output = json' >> /root/.aws/config
echo \"region = $REGION\" >> /root/.aws/config
chmod 400 /root/.aws/config
exit 0