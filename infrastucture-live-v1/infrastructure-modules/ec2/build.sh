#!/bin/bash
apt update
echo "install dotnet 8"
sudo apt install -y aspnetcore-runtime-8.0  # for run only
#apt install -y dotnet-sdk-8.0         # for build and run
#apt install unzip -y

# Change to a safe temp directory
cd /tmp

# Install required packages
sudo apt install -y ruby-full wget

# Download the CodeDeploy agent installer for eu-north-1
wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

# Make the installer executable
sudo chmod +x ./install

# Run the installer in automatic mode
./install auto

# Start the CodeDeploy agent service
sudo service codedeploy-agent start