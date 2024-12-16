# Setting Up a Docker Container with MySQL as a Slave Server

This guide provides detailed instructions for setting up a Docker container with MySQL configured as a slave server. The container will connect to a master MySQL database running on your local machine and include a dummy Nginx server to keep the container running.

## Prerequisites

**Install Docker** 

Follow the instructions [here](https://docs.docker.com/engine/install/ubuntu/) to install Docker on your local machine.


## Master Configuration

**Create Mysql replica user**

Both master and slave servers should have the same user and password. Run the following commands on the master:

```
CREATE USER 'replica_write'@'%' IDENTIFIED BY 'Welcome@123';
GRANT REPLICATION SLAVE ON *.* TO 'replica_write'@'%';
FLUSH PRIVILEGES;
```

Both master and slave should have same user and password make sure to create this first in master.
For slave replica_write user will get added while running docker container.
Also grant permission for all database to the user.


**Master mysql config file changes**

Configured master MySQL server with the following settings in `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```shell
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
server-id=1
port=3306
log_bin=/var/log/mysql/mysql-bin.log
bind-address=0.0.0.0
binlog_do_db=test_db1
binlog_do_db=test_db2
```

Restart mysql server to apply the changes.
```shell
sudo systemctl restart mysql
```

**Check master binlog and position**

Login to master server db check binlog and position by entering below command
```
mysql> SHOW MASTER STATUS\G;
*************************** 1. row ***************************
             File: mysql-bin.001828
         Position: 3072
     Binlog_Do_DB: db_test1
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 
1 row in set (0.00 sec)
```

**Create master db dump**

Run the following command to create the database dump:
```shell
mysqldump --single-transaction=TRUE -u replica_write -pWelcome@123 --databases test_db1 test_db2 > db_dump.sql
```

Place the latest database dump file in `slave-server/db_dump.sql`.


## Preparing the Slave Server

### Build the Docker Image

Run the following commands in the directory containing the `Dockerfile`, `my.cnf`, and `entrypoint.sh`:

```bash
docker build -t mysql-slave .
```

### Run the Docker Container

Start the container, mapping ports for MySQL (3306) and Nginx (80):

```bash
docker run --name mysql-slave -p 3307:3306 -p 8085:80 mysql-slave
```

### SSH into the Slave server

Access the container’s terminal:

```bash
docker exec -it mysql-slave bash
```



