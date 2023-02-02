#!/bin/bash

# Add the PPA for Java 11
sudo add-apt-repository ppa:openjdk-r/ppa -y

# Update the package index
sudo apt-get update

# Install Java 11
sudo apt-get install openjdk-11-jdk -y

# Install Maven
sudo apt-get install maven -y

# Add the Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Update the package index
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
#!/bin/bash

# Add the PPA for Java 11
sudo add-apt-repository ppa:openjdk-r/ppa -y

# Update the package index
sudo apt-get update

# Install Java 11
sudo apt-get install openjdk-11-jdk -y

# Install Maven
sudo apt-get install maven -y

# Add the Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Update the package index
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y

# Start Jenkins
sudo systemctl start jenkins

