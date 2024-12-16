# Base image
FROM ubuntu:22.04

# Update the system and install required packages
RUN apt-get update && apt-get install -y \
    mysql-server \
    nginx \
    curl \
    nano \
    net-tools \
    && apt-get clean

# Set environment variables for MySQL
ENV MYSQL_ROOT_USER_PASSWORD=Welcome@123
ENV MYSQL_REPLICA_USER=replica_write
ENV MYSQL_REPLICA_USER_PASSWORD=Welcome@123
ENV DB_BINLOG=mysql-bin.001835
ENV DB_POSITION=488

# Expose ports for MySQL and Nginx
EXPOSE 3306 80

# Copy MySQL configuration files
COPY my.cnf /my.cnf

# Copy the master SQL dump (to initialize the slave)
COPY db_dump.sql /db_dump.sql

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command to run Nginx in the background
CMD ["/entrypoint.sh"]

