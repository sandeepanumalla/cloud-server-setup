# Use the official lightweight Ubuntu base image
FROM ubuntu:latest

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary tools
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    wget \
    curl \
    nano \
    vim \
    sudo \
    unzip \
    gnupg2 \
    software-properties-common && \
    apt-get clean

# Remove any existing JDKs
RUN apt-get remove -y openjdk* && \
    apt-get autoremove -y && \
    apt-get clean

# Install OpenJDK 21 Headless
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk-headless

# Add Jenkins repository and install Jenkins
RUN wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key && \
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null && \
    apt-get update && \
    apt-get install -y jenkins

# Expose Jenkins port
EXPOSE 8080
EXPOSE 50000

# Set Jenkins prefix
ENV JENKINS_OPTS="--prefix=/jenkins"

# Set the working directory
WORKDIR /var/jenkins_home

# Copy users and jobs folders from the host machine to the container
# Uncomment these lines if you have users and jobs directories to copy
# COPY users /var/jenkins_home/users
# COPY jobs /var/jenkins_home/jobs

# Start Jenkins and display the initial admin password
CMD service jenkins start && \
    sleep 10 && \
    echo "Initial Admin Password:" && \
    cat /var/jenkins_home/secrets/initialAdminPassword && \
    tail -f /var/log/jenkins/jenkins.log
