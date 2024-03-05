# TP6 : Self-hosted cloud
## Partie 1 : Mise en place et maîtrise du serveur Web
### 1. Installation
#### 🌞 Installer le serveur Apache
```
[antoine@web ~]$ cat /etc/httpd/conf/httpd.conf 
ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache


ServerAdmin root@localhost


<Directory />
    AllowOverride none
    Require all denied
</Directory>


DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks

    AllowOverride None

    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"

LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>


    CustomLog "logs/access_log" combined
</IfModule>

<IfModule alias_module>


    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz



    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>


EnableSendfile on

IncludeOptional conf.d/*.conf
```

#### 🌞 Démarrer le service Apache
```
[antoine@web ~]$ sudo systemctl start httpd
[antoine@web ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: active (running) since Tue 2024-03-05 15:03:14 CET; 4s ago
       Docs: man:httpd.service(8)
   Main PID: 4468 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 4592)
     Memory: 23.3M
        CPU: 99ms
     CGroup: /system.slice/httpd.service
             ├─4468 /usr/sbin/httpd -DFOREGROUND
             ├─4469 /usr/sbin/httpd -DFOREGROUND
             ├─4470 /usr/sbin/httpd -DFOREGROUND
             ├─4471 /usr/sbin/httpd -DFOREGROUND
             └─4472 /usr/sbin/httpd -DFOREGROUND

Mar 05 15:03:14 web.tp6.linux systemd[1]: Starting The Apache HTTP Server...
Mar 05 15:03:14 web.tp6.linux systemd[1]: Started The Apache HTTP Server.
Mar 05 15:03:14 web.tp6.linux httpd[4468]: Server configured, listening on: port 80
[antoine@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```
```
[antoine@web ~]$ sudo ss -antpl | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=4472,fd=4),("httpd",pid=4471,fd=4),("httpd",pid=4470,fd=4),("httpd",pid=4468,fd=4))
```
```
[antoine@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --reload
success
[antoine@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

#### 🌞 TEST
```
[antoine@web ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
     Active: active (running) since Tue 2024-03-05 15:03:14 CET; 8min ago
       Docs: man:httpd.service(8)
   Main PID: 4468 (httpd)
     Status: "Total requests: 5; Idle/Busy workers 100/0;Requests/sec: 0.0104; Bytes served/sec:  82 B/sec"
      Tasks: 213 (limit: 4592)
     Memory: 23.7M
        CPU: 458ms
     CGroup: /system.slice/httpd.service
             ├─4468 /usr/sbin/httpd -DFOREGROUND
             ├─4469 /usr/sbin/httpd -DFOREGROUND
             ├─4470 /usr/sbin/httpd -DFOREGROUND
             ├─4471 /usr/sbin/httpd -DFOREGROUND
             └─4472 /usr/sbin/httpd -DFOREGROUND

Mar 05 15:03:14 web.tp6.linux systemd[1]: Starting The Apache HTTP Server...
Mar 05 15:03:14 web.tp6.linux systemd[1]: Started The Apache HTTP Server.
Mar 05 15:03:14 web.tp6.linux httpd[4468]: Server configured, listening on: port 80

[antoine@web ~]$ curl localhost
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
    ...
```
```
aube@MakOS:~$ curl 10.6.1.11
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
    ...
```

### 2. Avancer vers la maîtrise du service
#### 🌞 Le service Apache...
```
[antoine@web ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

#### 🌞 Déterminer sous quel utilisateur tourne le processus Apache
```
[antoine@web ~]$ cat /etc/httpd/conf/httpd.conf | grep User
User apache
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio

[antoine@web ~]$ ps -ef | grep apache
apache      4469    4468  0 15:03 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      4470    4468  0 15:03 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      4471    4468  0 15:03 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      4472    4468  0 15:03 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
antoine     4789    4104  0 15:22 pts/0    00:00:00 grep --color=auto apache

[antoine@web ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Mar  5 14:32 .
drwxr-xr-x. 83 root root 4096 Mar  5 14:32 ..
-rw-r--r--.  1 root root 7620 Feb 21 14:12 index.html
```

#### 🌞 Changer l'utilisateur utilisé par Apache
```
[antoine@web ~]$ sudo useradd apache2 -M -s /sbin/nologin

[antoine@web ~]$ cat /etc/httpd/conf/httpd.conf | grep User
User apache2
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio

[antoine@web ~]$ sudo systemctl restart httpd

[antoine@web ~]$ ps -ef | grep apache
apache2     4826    4825  0 15:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     4827    4825  0 15:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     4828    4825  0 15:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     4829    4825  0 15:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

#### 🌞 Faites en sorte que Apache tourne sur un autre port
```
[antoine@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 81

[antoine@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --add-port=81/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --reload
success

[antoine@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 81/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:

[antoine@web ~]$ sudo ss -antpl | grep httpd
LISTEN 0      511                *:81              *:*    users:(("httpd",pid=5079,fd=4),("httpd",pid=5078,fd=4),("httpd",pid=5077,fd=4),("httpd",pid=5074,fd=4))

[antoine@web ~]$ curl localhost:81
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
    ...


aube@MakOS:~$ curl 10.6.1.11:81
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
    ...
```

## Partie 2 : Mise en place et maîtrise du serveur de base de données
#### 🌞 Install de MariaDB sur db.tp6.linux
```
[antoine@db ~]$ sudo dnf install mariadb-server

[antoine@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

[antoine@db ~]$ sudo systemctl start mariadb

[antoine@db ~]$ sudo mysql_secure_installation

[antoine@db ~]$ systemctl status mysql
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: disabled)
     Active: active (running) since Tue 2024-03-05 15:48:42 CET; 7min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 4036 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCESS)
    Process: 4058 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
    Process: 4152 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCCESS)
   Main PID: 4139 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 9 (limit: 4673)
     Memory: 87.4M
        CPU: 793ms
     CGroup: /system.slice/mariadb.service
             └─4139 /usr/libexec/mariadbd --basedir=/usr

Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: The second is mysql@localhost, it has no password either>
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: you need to be the system 'mysql' user to connect.
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: After connecting you can set the password, if you would >
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: able to connect as any of these users with a password an>
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: See the MariaDB Knowledgebase at https://mariadb.com/kb
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: Please report any problems at https://mariadb.org/jira
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: The latest information about MariaDB is available at htt>
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: Consider joining MariaDB's strong and vibrant community:
Mar 05 15:48:42 db.tp6.linux mariadb-prepare-db-dir[4097]: https://mariadb.org/get-involved/
Mar 05 15:48:42 db.tp6.linux systemd[1]: Started MariaDB 10.5 database server.
```

#### 🌞 Port utilisé par MariaDB
```
[antoine@db ~]$ sudo ss -alntp | grep mariadb
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=4139,fd=19))

[antoine@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[antoine@db ~]$ sudo firewall-cmd --reload
success
[antoine@db ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 3306/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

#### 🌞 Processus liés à MariaDB
```
[antoine@db ~]$ ps -aux | grep maria
mysql       4139  0.0 12.9 1085472 102012 ?      Ssl  15:48   0:00 /usr/libexec/mariadbd --basedir=/usr
```

## Partie 3 : Configuration et mise en place de NextCloud
### 1. Base de données
#### 🌞 Préparation de la base pour NextCloud
```
[antoine@db ~]$ sudo mysql -u root -p
[sudo] password for antoine: 
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 40
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.6.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.6.1.11';
Query OK, 0 rows affected (0.016 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.002 sec)
```

#### 🌞 Exploration de la base de données
```
[antoine@web ~]$ mysql -u nextcloud -h 10.6.1.12 -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 53
Server version: 5.5.5-10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.


mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed

mysql> SHOW TABLES;
Empty set (0.01 sec)

mysql> 

```

#### 🌞 Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données
```
MariaDB [(none)]> SELECT User FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.004 sec)
```

### 2. Serveur Web et NextCloud
#### 🌞 Install de PHP
```
[antoine@web ~]$ sudo dnf install php
```

#### 🌞 Récupérer NextCloud
```
[antoine@web ~]$ sudo mkdir -p /var/www/tp6_nextcloud/

[antoine@web ~]$ curl https://download.nextcloud.com/server/releases/latest.zip --output ./nextcloud.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  210M  100  210M    0     0  20.6M      0  0:00:10  0:00:10 --:--:-- 19.9M

[antoine@web ~]$ sudo dnf install unzip

[antoine@web ~]$ unzip nextcloud.zip

[antoine@web ~]$ sudo mv nextcloud/* /var/www/tp6_nextcloud/

[antoine@web tp6_nextcloud]$ sudo chown -R apache tp6_nextcloud/
[antoine@web www]$ ls -al
total 8
drwxr-xr-x.  5 root   root   54 Mar  5 16:18 .
drwxr-xr-x. 20 root   root 4096 Mar  5 14:32 ..
drwxr-xr-x.  2 root   root    6 Oct 28 11:35 cgi-bin
drwxr-xr-x.  2 root   root    6 Oct 28 11:35 html
drwxr-xr-x. 13 apache root 4096 Mar  5 16:23 tp6_nextcloud
```

#### 🌞 Adapter la configuration d'Apache
```
[antoine@web conf.d]$ cat /etc/httpd/conf.d/tp6_nextcloud.conf 
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp6_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp6.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp6_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

#### 🌞 Redémarrer le service Apache pour qu'il prenne en compte le nouveau fichier de conf
```
[antoine@web conf.d]$ sudo systemctl restart httpd
[antoine@web conf.d]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/httpd.service.d
             └─php-fpm.conf
     Active: active (running) since Tue 2024-03-05 16:27:04 CET; 29s ago
       Docs: man:httpd.service(8)
   Main PID: 6203 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 4592)
     Memory: 23.6M
        CPU: 100ms
     CGroup: /system.slice/httpd.service
             ├─6203 /usr/sbin/httpd -DFOREGROUND
             ├─6205 /usr/sbin/httpd -DFOREGROUND
             ├─6206 /usr/sbin/httpd -DFOREGROUND
             ├─6207 /usr/sbin/httpd -DFOREGROUND
             └─6208 /usr/sbin/httpd -DFOREGROUND

Mar 05 16:27:04 web.tp6.linux systemd[1]: Starting The Apache HTTP Server...
Mar 05 16:27:04 web.tp6.linux systemd[1]: Started The Apache HTTP Server.
Mar 05 16:27:04 web.tp6.linux httpd[6203]: Server configured, listening on: port 80
```

## 3. Finaliser l'installation de NextCloud
#### 🌞 Installez les deux modules PHP dont NextCloud vous parle
```
[antoine@web conf.d]$ sudo dnf install php-zip
[antoine@web conf.d]$ sudo dnf install php-gd
```

#### 🌞 Pour que NextCloud utilise la base de données, ajoutez aussi
```
[antoine@web conf.d]$ sudo dnf install php-pdo
[antoine@web conf.d]$ sudo dnf install php-mysqlnd
```

#### 🌞 Exploration de la base de données
```
MariaDB [(none)]> select count(*) from information_schema.tables where table_schema = 'nextcloud' ;
+----------+
| count(*) |
+----------+
|      139 |
+----------+
1 row in set (0.002 sec)
```