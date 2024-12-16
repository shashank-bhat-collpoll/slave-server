#!/bin/bash

echo "[SCRIPT] Overwrite the MySQL configuration file"
cp my.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

echo "[SCRIPT] Restart MySQL to apply new configuration"
service mysql restart

echo "[SCRIPT] Add replica user with required privileges"
mysql -u root -p${MYSQL_ROOT_USER_PASSWORD} <<EOF
CREATE USER '${MYSQL_REPLICA_USER}'@'localhost' IDENTIFIED BY '${MYSQL_REPLICA_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_REPLICA_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "[SCRIPT] Create database in slave server"
mysql -u root -p${MYSQL_ROOT_USER_PASSWORD} <<EOF
CREATE DATABASE test_db1;
CREATE DATABASE test_db2;
EOF

# Check if the master dump has already been imported else dump.
if [ ! -f /var/lib/mysql/slave_initialized.flag ]; then
    echo "[SCRIPT] Initializing slave database with master dump..."
    mysql -u${MYSQL_REPLICA_USER} -p${MYSQL_REPLICA_USER_PASSWORD} < db_dump.sql
    touch /var/lib/mysql/slave_initialized.flag
fi

echo "[SCRIPT] Restart MySQL to ensure new configuration is loaded"
service mysql restart


echo "[SCRIPT] Configure slave replication"
mysql -u root -p{MYSQL_ROOT_USER_PASSWORD} <<EOF
STOP SLAVE;
STOP REPLICA IO_THREAD FOR CHANNEL '';
CHANGE MASTER TO
    MASTER_HOST='host.docker.internal',
    MASTER_USER='root',
    MASTER_PASSWORD='${MYSQL_ROOT_USER_PASSWORD}',
    MASTER_LOG_FILE='${DB_BINLOG}',
    MASTER_LOG_POS=${DB_POSITION};
START REPLICA IO_THREAD FOR CHANNEL '';
START SLAVE;
EOF

echo "[SCRIPT] Start Nginx in the background"
service nginx start

echo "[SCRIPT] Keep the container running"
tail -f /dev/null

