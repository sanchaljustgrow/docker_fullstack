# --------------------------
# Base OS
# --------------------------
FROM ubuntu:22.04

# --------------------------
# Install Required Packages
# --------------------------
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    nodejs \
    npm \
    nginx \
    mysql-server \
    curl \
    vim \
    net-tools \
    git \
    && apt-get clean

# --------------------------
# Set Working Directory
# --------------------------
WORKDIR /app

# --------------------------
# Copy Spring Boot Backend
# --------------------------
COPY backend/task-backend.jar /app/backend.jar

# --------------------------
# Copy Angular Frontend
# --------------------------
COPY frontend/ /app/frontend/

# --------------------------
# Copy Nginx Config
# --------------------------
COPY nginx.conf /etc/nginx/sites-enabled/default

# --------------------------
# Copy MySQL Initialization Script
# --------------------------
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# --------------------------
# Build Angular UI
# --------------------------
WORKDIR /app/frontend
RUN npm install && npm run build --prod

# Move Angular dist to Nginx web root
RUN rm -rf /var/www/html/* && cp -r dist/* /var/www/html/

# --------------------------
# Configure MySQL
# --------------------------
RUN service mysql start && \
    mysql -e "CREATE DATABASE IF NOT EXISTS taskdb;" && \
    mysql -e "CREATE USER IF NOT EXISTS 'taskuser'@'%' IDENTIFIED BY 'taskpass';" && \
    mysql -e "GRANT ALL PRIVILEGES ON taskdb.* TO 'taskuser'@'%';" && \
    mysql -e "FLUSH PRIVILEGES;"

# --------------------------
# Expose Ports
# --------------------------
EXPOSE 80 8080 3306

# --------------------------
# Start All Services
# --------------------------
WORKDIR /app
CMD service mysql start && \
    echo "✅ MySQL started" && \
    java -jar /app/backend.jar & \
    echo "✅ Spring Boot started" && \
    nginx -g "daemon off;"
