## Debug Slave and ensure nothing missed.

Check slave config file whether `my.cnf` file copied to the slave config file properly.
```shell
cat /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
server-id=2
port=3306
log_bin=/var/log/mysql/mysql-bin.log
relay-log=/var/log/mysql/mysql-relay-bin.log
binlog_do_db=test_db1
binlog_do_db=test_db2
bind-address=0.0.0.0
```

Check replica user got created in slave db server.

Login to mysql with root user and check `mysql.user` table.
```
mysql> SELECT user, host, plugin FROM mysql.user;
+------------------+-----------+-----------------------+
| user             | host      | plugin                |
+------------------+-----------+-----------------------+
| replica_write    | %         | mysql_native_password |
| root             | %         | mysql_native_password |
| debian-sys-maint | localhost | caching_sha2_password |
| mysql.infoschema | localhost | caching_sha2_password |
| mysql.session    | localhost | caching_sha2_password |
| mysql.sys        | localhost | caching_sha2_password |
| root             | localhost | mysql_native_password |
+------------------+-----------+-----------------------+
```

Login to mysql with replica user and check databases are copied and table has data.
```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| test_db1           |
| test_db2           |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

### Access Master Database from Slave terminal

Test connectivity from the container to the master server:

```bash
mysql -h <master_ip> -u replica_write -p
```

> **Note:** You can check ip by executing `ip a` command in terminal.

### Access Slave Database from Master terminal

Log in to the slave database:

```bash
docker exec -it mysql-slave mysql -u replica_write -p
```

Password: `Welcome@123`

### Check Master and Slave status

Run the following command on the master database to get the binlog file and position:

```sql
SHOW MASTER STATUS\G;
```

Run the following command on the slave database to get the slave status:

```sql
SHOW SLAVE STATUS\G;
```

## Logging into the Database

Log in with the credentials:

```bash
mysql -u replica_write -pWelcome@123
```
