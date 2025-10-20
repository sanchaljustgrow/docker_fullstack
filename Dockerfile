# Base image
FROM ubuntu:22.04

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get upgrade -y

# Install basic dependencies
RUN apt-get install -y curl wget gnupg2 software-properties-common lsb-release vim supervisor lsb-release

# ----------------------------
# 1. Install Java 11
# ----------------------------
RUN apt-get install -y openjdk-11-jdk
RUN java -version

# ----------------------------
# 2. Install MySQL Server
# ----------------------------
RUN apt-get install -y mysql-server && \
    systemctl enable mysql || true

# Secure MySQL and set root password
RUN service mysql start && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"

# ----------------------------
# 3. Install Nginx
# ----------------------------
RUN apt-get install -y nginx && \
    systemctl enable nginx || true

# ----------------------------
# 4. Install Node.js (v20 via latest NVM)
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
# 6. Setup supervisord to run all services
# ----------------------------
RUN mkdir -p /var/log/supervisor

# Copy your supervisord config (define commands to start MySQL, Nginx, Java app, Node app)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose necessary ports
EXPOSE 80 443 3306 8080

# Start supervisord
CMD ["/usr/bin/supervisord", "-n"]
