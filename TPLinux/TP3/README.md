# TP3 : Appréhender l'environnement Linux 
# 0. Setup
# I. Service SSH
## 1. Analyse du service
### 🌞 S'assurer que le service sshd est démarré
```
[antoine@node1 ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
     Active: active (running) since Tue 2024-01-23 14:54:27 CET; 1min 46s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 694 (sshd)
      Tasks: 1 (limit: 4673)
     Memory: 6.2M
        CPU: 186ms
     CGroup: /system.slice/sshd.service
             └─694 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Jan 23 14:54:27 node1.tp3.b1 systemd[1]: Starting OpenSSH server daemon...
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: main: sshd: ssh-rsa algorithm is disabled
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: Server listening on 0.0.0.0 port 22.
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: Server listening on :: port 22.
Jan 23 14:54:27 node1.tp3.b1 systemd[1]: Started OpenSSH server daemon.
Jan 23 14:54:51 node1.tp3.b1 sshd[1288]: main: sshd: ssh-rsa algorithm is disabled
Jan 23 14:54:52 node1.tp3.b1 sshd[1288]: Accepted password for antoine from 10.2.1.0 port 55196 ssh2
Jan 23 14:54:52 node1.tp3.b1 sshd[1288]: pam_unix(sshd:session): session opened for user antoine(uid=1000) by (uid=0)
```

### 🌞 Analyser les processus liés au service SSH
```
[antoine@node1 ~]$ ps aux | grep sshd
root         694  0.0  1.1  15836  9208 ?        Ss   14:54   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1288  0.0  1.4  18828 11308 ?        Ss   14:54   0:00 sshd: antoine [priv]
antoine     1303  0.0  0.8  19012  7068 ?        S    14:54   0:00 sshd: antoine@pts/0
```

### 🌞 Déterminer le port sur lequel écoute le service SSH
```
[antoine@node1 ~]$ sudo ss -antp | grep ssh
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*     users:(("sshd",pid=694,fd=3))                        
ESTAB  0      0          10.2.1.11:22       10.2.1.0:55196 users:(("sshd",pid=1303,fd=4),("sshd",pid=1288,fd=4))
LISTEN 0      128             [::]:22           [::]:*     users:(("sshd",pid=694,fd=4))
```

### 🌞 Consulter les logs du service SSH
```
[antoine@node1 ~]$ journalctl | grep sshd
Jan 23 14:54:25 node1.tp3.b1 systemd[1]: Created slice Slice /system/sshd-keygen.
Jan 23 14:54:26 node1.tp3.b1 systemd[1]: Reached target sshd-keygen.target.
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: main: sshd: ssh-rsa algorithm is disabled
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: Server listening on 0.0.0.0 port 22.
Jan 23 14:54:27 node1.tp3.b1 sshd[694]: Server listening on :: port 22.
Jan 23 14:54:51 node1.tp3.b1 sshd[1288]: main: sshd: ssh-rsa algorithm is disabled
Jan 23 14:54:52 node1.tp3.b1 sshd[1288]: Accepted password for antoine from 10.2.1.0 port 55196 ssh2
Jan 23 14:54:52 node1.tp3.b1 sshd[1288]: pam_unix(sshd:session): session opened for user antoine(uid=1000) by (uid=0)
```

```
[antoine@node1 ~]$ sudo grep "ssh" /var/log/secure | tail -n 10
Jan 23 14:49:22 localhost sshd[688]: Server listening on 0.0.0.0 port 22.
Jan 23 14:49:22 localhost sshd[688]: Server listening on :: port 22.
Jan 23 14:52:48 localhost sshd[1442]: Accepted password for antoine from 10.2.1.0 port 48404 ssh2
Jan 23 14:52:48 localhost sshd[1442]: pam_unix(sshd:session): session opened for user antoine(uid=1000) by (uid=0)
Jan 23 14:54:27 node1 sshd[694]: Server listening on 0.0.0.0 port 22.
Jan 23 14:54:27 node1 sshd[694]: Server listening on :: port 22.
Jan 23 14:54:52 node1 sshd[1288]: Accepted password for antoine from 10.2.1.0 port 55196 ssh2
Jan 23 14:54:52 node1 sshd[1288]: pam_unix(sshd:session): session opened for user antoine(uid=1000) by (uid=0)
Jan 23 15:08:36 node1 sudo[1535]: antoine : TTY=pts/0 ; PWD=/home/antoine ; USER=root ; COMMAND=/bin/grep ssh /var/log/secure
Jan 23 15:08:42 node1 sudo[1539]: antoine : TTY=pts/0 ; PWD=/home/antoine ; USER=root ; COMMAND=/bin/grep ssh /var/log/secure
```

```
[antoine@node1 ~]$ sudo tail -n 10 /var/log/secure
Jan 23 15:08:42 node1 sudo[1539]: pam_unix(sudo:session): session closed for user root
Jan 23 15:08:48 node1 sudo[1545]: antoine : TTY=pts/0 ; PWD=/home/antoine ; USER=root ; COMMAND=/bin/grep ssh /var/log/secure
Jan 23 15:08:48 node1 sudo[1545]: pam_unix(sudo:session): session opened for user root(uid=0) by antoine(uid=1000)
Jan 23 15:08:48 node1 sudo[1545]: pam_unix(sudo:session): session closed for user root
Jan 23 15:10:05 node1 sudo[1559]: antoine : TTY=pts/0 ; PWD=/home/antoine ; USER=root ; COMMAND=/bin/tail /var/log/secure
Jan 23 15:10:05 node1 sudo[1559]: pam_unix(sudo:session): session opened for user root(uid=0) by antoine(uid=1000)
Jan 23 15:10:05 node1 sudo[1559]: pam_unix(sudo:session): session closed for user root
Jan 23 15:10:10 node1 sudo[1562]: antoine : TTY=pts/0 ; PWD=/home/antoine ; USER=root ; COMMAND=/bin/tail 10 /var/log/secure
Jan 23 15:10:10 node1 sudo[1562]: pam_unix(sudo:session): session opened for user root(uid=0) by antoine(uid=1000)
Jan 23 15:10:10 node1 sudo[1562]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service
### 🌞 Identifier le fichier de configuration du serveur SSH
`/etc/ssh/sshd_config`
### 🌞 Modifier le fichier de conf
```
[antoine@node1 ~]$ echo $RANDOM
18529
[antoine@node1 ~]$ sudo grep "Port" /etc/ssh/sshd_config
Port 18529
#GatewayPorts no
```

```
[antoine@node1 ~]$ sudo firewall-cmd --remove-service=ssh --permanent
success
[antoine@node1 ~]$ sudo firewall-cmd --add-port=18529/tcp --permanent
success
[antoine@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client
  ports: 18529/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
### 🌞 Redémarrer le service
```
[antoine@node1 ~]$ sudo systemctl restart sshd
```
### 🌞 Effectuer une connexion SSH sur le nouveau port
```
aube@MakOS:~$ ssh antoine@10.2.1.11 -p 18529
antoine@10.2.1.11's password: 
Last login: Tue Jan 23 14:54:52 2024 from 10.2.1.0
[antoine@node1 ~]$ 
```

### ✨ Bonus : affiner la conf du serveur SSH
```
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
```

# II. Service HTTP
## 1. Mise en place
### 🌞 Installer le serveur NGINX
```
[antoine@node1 ~]$ sudo dnf install nginx
```

### 🌞 Démarrer le service NGINX
```
[antoine@node1 ~]$ sudo systemctl start nginx
[antoine@node1 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Mon 2024-01-29 13:48:23 CET; 29s ago
    Process: 11280 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 11281 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 11282 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 11283 (nginx)
      Tasks: 2 (limit: 4673)
     Memory: 1.9M
        CPU: 19ms
     CGroup: /system.slice/nginx.service
             ├─11283 "nginx: master process /usr/sbin/nginx"
             └─11284 "nginx: worker process"

Jan 29 13:48:23 node1.tp3.b1 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 29 13:48:23 node1.tp3.b1 nginx[11281]: nginx: the configuration file /etc/nginx/nginx.conf synt>
Jan 29 13:48:23 node1.tp3.b1 nginx[11281]: nginx: configuration file /etc/nginx/nginx.conf test is >
Jan 29 13:48:23 node1.tp3.b1 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

### 🌞 Déterminer sur quel port tourne NGINX
```
[antoine@node1 ~]$ sudo ss -antp  | grep nginx
LISTEN 0      511          0.0.0.0:80         0.0.0.0:*     users:(("nginx",pid=11284,fd=6),("nginx",pid=11283,fd=6))
LISTEN 0      511             [::]:80            [::]:*     users:(("nginx",pid=11284,fd=7),("nginx",pid=11283,fd=7))
```

### 🌞 Déterminer le nom de l'utilisateur qui lance NGINX
```
[antoine@node1 ~]$ cat /etc/passwd | grep nginx
nginx:x:991:991:Nginx web server:/var/lib/nginx:/sbin/nologin
```

### 🌞 Test !
```
[antoine@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[antoine@node1 ~]$ sudo firewall-cmd --reload
success
```

```
aube@MakOS:~$ curl http://10.2.1.11:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  <!doctype html>    0      0      0 --:--:-- --:--:-- --:--:--     0
10<html>
0  <head>
      <meta charset='utf-8'>
76    <meta name='viewport' content='width=device-width, initial-scale=1'>
20    <title>HTTP Server Test Page powered by: Rocky Linux</title>
      <style type="text/css">
  0     0  7266k      0 --:--:-- --:--:-- --:--:-- 7441k
curl: (23) Failed writing body
```

## 2. Analyser la conf de NGINX
### 🌞 Déterminer le path du fichier de configuration de NGINX
```
[antoine@node1 ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 16 20:00 /etc/nginx/nginx.conf
```

### 🌞 Trouver dans le fichier de conf
```
[antoine@node1 ~]$ cat /etc/nginx/nginx.conf | grep server -A 10
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

[antoine@node1 ~]$ cat /etc/nginx/nginx.conf | grep "^include"
include /usr/share/nginx/modules/*.conf;
```

## 3. Déployer un nouveau site web
### 🌞 Créer un site web
```
[antoine@node1 ~]$ sudo mkdir -p /var/www/tp2_linux
echo "<h1>MEOW mon premier serveur web</h1>" | sudo tee /var/www/tp2_linux/index.html
```

### 🌞 Gérer les permissions
```
[antoine@node1 ~]$ sudo chown -R nginx /var/www/tp2_linux/
[antoine@node1 ~]$ ls -al /var/www/tp2_linux/
total 4
drwxr-xr-x. 2 nginx root 24 Jan 29 14:12 .
drwxr-xr-x. 3 root  root 23 Jan 29 14:07 ..
-rw-r--r--. 1 nginx root 38 Jan 29 14:12 index.html
```

### 🌞 Adapter la conf NGINX
```
[antoine@node1 ~]$ cat /etc/nginx/nginx.conf | grep server -A 10
# Settings for a TLS enabled server.
#
#    server {
...


[antoine@node1 ~]$ echo $RANDOM
18004
[antoine@node1 ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf 
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 18004;

  root /var/www/tp2_linux;
}

[antoine@node1 ~]$ sudo firewall-cmd --add-port=18004/tcp --permanent
success
[antoine@node1 ~]$ sudo firewall-cmd --reload
```

### 🌞 Visitez votre super site web
```
aube@MakOS:~$ curl http://10.2.1.11:18004
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services
## 2. Analyse des services existants
### 🌞 Afficher le fichier de service SSH
```
[antoine@node1 ~]$ cat /usr/lib/systemd/system/sshd.service | grep "^ExecStart="
ExecStart=/usr/sbin/sshd -D $OPTIONS

[antoine@node1 ~]$ sudo systemctl start sshd
```

### 🌞 Afficher le fichier de service NGINX
```
[antoine@node1 ~]$ cat /usr/lib/systemd/system/nginx.service | grep "^ExecStart="
ExecStart=/usr/sbin/nginx
```

# 3. Création de service
### 🌞 Créez le fichier /etc/systemd/system/tp3_nc.service
```
[antoine@node1 ~]$ echo $RANDOM
7368

[antoine@node1 ~]$ cat /etc/systemd/system/tp3_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 7368 -k
```

### 🌞 Indiquer au système qu'on a modifié les fichiers de service
```
[antoine@node1 ~]$ sudo systemctl daemon-reload
```

### 🌞 Démarrer notre service de ouf
```
[antoine@node1 ~]$ sudo systemctl start tp3_nc
```

### 🌞 Vérifier que ça fonctionne
```
[antoine@node1 ~]$ sudo systemctl status tp3_nc
● tp3_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp3_nc.service; static)
     Active: active (running) since Mon 2024-01-29 14:38:33 CET; 17s ago
   Main PID: 11808 (nc)
      Tasks: 1 (limit: 4673)
     Memory: 792.0K
        CPU: 2ms
     CGroup: /system.slice/tp3_nc.service
             └─11808 /usr/bin/nc -l 7368 -k

Jan 29 14:38:33 node1.tp3.b1 systemd[1]: Started Super netcat tout fou.

[antoine@node1 ~]$ sudo ss -antp | grep nc
LISTEN 0      10           0.0.0.0:7368       0.0.0.0:*     users:(("nc",pid=11808,fd=4))                            
LISTEN 0      10              [::]:7368          [::]:*     users:(("nc",pid=11808,fd=3))                            
```

### 🌞 Les logs de votre service
```
[antoine@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep Started
Jan 29 15:29:58 node1.tp3.b1 systemd[1]: Started Super netcat tout fou.

[antoine@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep -E "nc[[*]"
Jan 29 15:30:44 node1.tp3.b1 nc[12242]: test
Jan 29 15:30:54 node1.tp3.b1 nc[12242]: salut
Jan 29 15:30:58 node1.tp3.b1 nc[12242]: salut

[antoine@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep Stopped
Jan 29 15:29:58 node1.tp3.b1 systemd[1]: Stopped Super netcat tout fou.
```

### 🌞 Affiner la définition du service
```
[antoine@node1 ~]$ sudo cat /etc/systemd/system/tp3_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 7368 -k
Restart=always

[antoine@node1 ~]$ sudo systemctl daemon-reload
[antoine@node1 ~]$ sudo systemctl restart tp3_nc
[antoine@node1 ~]$ sudo systemctl status tp3_nc
● tp3_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp3_nc.service; static)
     Active: active (running) since Mon 2024-01-29 15:37:06 CET; 1min 9s ago
   Main PID: 12352 (nc)
      Tasks: 1 (limit: 4673)
     Memory: 780.0K
        CPU: 1ms
     CGroup: /system.slice/tp3_nc.service
             └─12352 /usr/bin/nc -l 7368 -k

Jan 29 15:37:06 node1.tp3.b1 systemd[1]: Started Super netcat tout fou.
```