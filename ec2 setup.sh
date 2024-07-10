#!/bin/bash

# Update and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce


# Check Docker installation
if ! command -v docker &> /dev/null
then
    echo "Docker installation failed"
    exit 1
fi

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Docker Swarm
docker swarm init

# Install Nginx
sudo apt-get install -y nginx

# Configure Nginx to run on port 80
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Certbot for Let's Encrypt SSL
#sudo apt-get install -y certbot python3-certbot-nginx

# Obtain SSL certificate
#sudo certbot --nginx -d sanyogi.fun --non-interactive --agree-tos -m your-email@example.com

# Check SSL certificate status
#if ! sudo certbot certificates | grep -q "sanyogi.fun"
#then
#    echo "SSL certificate installation failed"
#    exit 1
#fi

# Configure Nginx for proxy resolution from HTTP to HTTPS
#sudo bash -c 'cat > /etc/nginx/sites-available/sanyogi.fun <<EOF
#server {
#    listen 80;
#    server_name sanyogi.fun;
#    return 301 https://$host$request_uri;
#}
#
#server {
#    listen 443 ssl;
#    server_name sanyogi.fun;
#
#    ssl_certificate /etc/letsencrypt/live/sanyogi.fun/fullchain.pem;
#    ssl_certificate_key /etc/letsencrypt/live/sanyogi.fun/privkey.pem;
#
#    location / {
#        proxy_pass http://localhost:80;
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto $scheme;
#    }
#
#    location /jenkins {
#        proxy_pass http://localhost:8080/jenkins;
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto $scheme;
#    }
#}
#EOF'

# Enable the configuration and restart Nginx
#sudo ln -s /etc/nginx/sites-available/sanyogi.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Check Nginx status
if ! systemctl is-active --quiet nginx
then
    echo "Nginx configuration failed"
    exit 1
fi

# Remove existing volume
docker volume rm jenkins_home

# Set up Jenkins in Docker
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts

# Wait for Jenkins to start
#sleep 25
#

# Install Git
sudo apt-get install -y git

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Set up Jenkins admin user
echo "Setting up Jenkins admin user..."
docker exec -it jenkins bash -c "echo -e 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"sandeep\", \"$INITIAL_ADMIN_PASSWORD\");\njenkins.model.Jenkins.instance.save();' | java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080 groovy ="

# Verify Jenkins setup
if ! curl -f -L https://sanyogi.fun/jenkins
then
    echo "Jenkins setup failed"
    exit 1
fi

# Get initial admin password
INITIAL_ADMIN_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)


# Output Jenkins initial admin password
echo "Jenkins initialAdminPassword: $INITIAL_ADMIN_PASSWORD"

sudo apt-get install vim

apt-get update

apt-get install -y openjdk-21-jdk-headless



echo "All tasks completed successfully"
