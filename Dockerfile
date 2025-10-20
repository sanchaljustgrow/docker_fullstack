# Base image
FROM ubuntu:22.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get upgrade -y

# Install basic dependencies
RUN apt-get install -y curl wget gnupg2 software-properties-common lsb-release vim

# ----------------------------
# 1. Install Java 11
# ----------------------------
RUN apt-get install -y openjdk-11-jdk
RUN java -version

# ----------------------------
# 2. Install MySQL client & server (do not start)
# ----------------------------
RUN apt-get install -y mysql-server mysql-client
# Set root password (for future use)
RUN echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;" > /root/mysql-init.sql

# ----------------------------
# 3. Install Nginx (do not start)
# ----------------------------
RUN apt-get install -y nginx

# ----------------------------
# 4. Install Node.js v20 via latest NVM
# ----------------------------
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20
RUN . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    node -v && npm -v
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# ----------------------------
# 5. Install Certbot for Nginx SSL
# ----------------------------
RUN apt-get install -y certbot python3-certbot-nginx

# ----------------------------
# Expose ports (optional)
# ----------------------------
EXPOSE 80 443 3306 8080

# ----------------------------
# Default command: keep container alive
# ----------------------------
CMD [ "bash" ]
