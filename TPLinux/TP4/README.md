# TP4 : Real services
## Partie 1 : Partitionnement du serveur de stockage

#### 🌞 Partitionner le disque à l'aide de LVM
- créer un physical volume (PV) :
```
[antoine@storage ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[antoine@storage ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
```

- créer un nouveau volume group (VG) : 
```
[antoine@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[antoine@storage ~]$ sudo vgextend storage /dev/sdc
  Volume group "storage" successfully extended
[antoine@storage ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_VBOX_HARDDISK_VBdce7a290-e010d717 PVID YB2YhebO4R14QiYbzEJqgU4xHYOvfwcq last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize VFree
  storage   2   0   0 wz--n- 3.99g 3.99g
```

- créer un nouveau logical volume (LV) : ce sera la partition utilisable :
```
[antoine@storage ~]$ sudo lvcreate -l 100%FREE storage -n storage_data
  Logical volume "storage_data" created.
[antoine@storage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_VBOX_HARDDISK_VBdce7a290-e010d717 PVID YB2YhebO4R14QiYbzEJqgU4xHYOvfwcq last seen on /dev/sda2 not found.
  LV           VG      Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  storage_data storage -wi-a----- 3.99g    
```

### 🌞 Formater la partition
```
[antoine@storage ~]$ sudo mkfs -t ext4 /dev/storage/storage_data
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1046528 4k blocks and 261632 inodes
Filesystem UUID: a8a9af32-07e0-46d6-8935-1ab57c589260
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 
```

### 🌞 Monter la partition
```
[antoine@storage ~]$ sudo mkdir /mnt/storage
[antoine@storage ~]$ sudo mount /dev/storage/storage_data /mnt/storage/
[antoine@storage ~]$ df -h | grep /mnt/storage
/dev/mapper/storage-storage_data  3.9G   24K  3.7G   1% /mnt/storage

[antoine@storage ~]$ echo test | sudo tee  /mnt/storage/toto
test
[antoine@storage ~]$ cat /mnt/storage/toto 
test
```

```
[antoine@storage ~]$ sudo nano /etc/fstab
[antoine@storage ~]$ sudo umount /mnt/storage/
[antoine@storage ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
/mnt/storage             : successfully mounted
[antoine@storage ~]$ cat /etc/fstab | grep /dev/storage
/dev/storage/storage_data /mnt/storage ext4 defaults 0 0
```

### ⭐BONUS
- utilisez une commande dd pour remplir complètement la nouvelle partition
```
[antoine@storage ~]$ sudo dd if=/dev/zero of=/dev/storage/storage_data bs=4M status=progress
4043309056 bytes (4.0 GB, 3.8 GiB) copied, 4 s, 1.0 GB/s
dd: error writing '/dev/storage/storage_data': No space left on device
1023+0 records in
1022+0 records out
4286578688 bytes (4.3 GB, 4.0 GiB) copied, 4.2442 s, 1.0 GB/s
[antoine@storage ~]$ 
```

- prouvez que la partition est remplie avec une commande df
```
[antoine@storage ~]$ df -h | grep storage
/dev/mapper/storage-storage_data   64Z   64Z  3.9G 100% /mnt/storage
```

- ajoutez un nouveau disque dur de 2G à la machine
```
[antoine@storage ~]$ lsblk
NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                      8:0    0    8G  0 disk 
├─sda1                   8:1    0    1G  0 part /boot
└─sda2                   8:2    0    7G  0 part 
  ├─rl-root            253:0    0  6.2G  0 lvm  /
  └─rl-swap            253:1    0  820M  0 lvm  [SWAP]
sdb                      8:16   0    2G  0 disk 
└─storage-storage_data 253:2    0    4G  0 lvm  
sdc                      8:32   0    2G  0 disk 
└─storage-storage_data 253:2    0    4G  0 lvm  
sdd                      8:48   0    2G  0 disk 
sr0                     11:0    1 1024M  0 rom  
```

- ajoutez ce new disque dur à la conf LVM
```
[antoine@storage ~]$ sudo vgextend storage /dev/sdd
  Physical volume "/dev/sdd" successfully created.
  Volume group "storage" successfully extended
```

- agrandissez la partition pleine à l'aide du nouveau disque
```
[antoine@storage ~]$ sudo lvextend -l 100%FREE /dev/storage/storage_data 
  New size given (511 extents) not larger than existing size (1022 extents)

[antoine@storage ~]$ sudo resize2fs /dev/storage/storage_data
resize2fs 1.46.5 (30-Dec-2021)
The filesystem is already 1046528 (4k) blocks long.  Nothing to do!
```

- prouvez avec un df que la partition a bien été agrandie
```
[antoine@storage ~]$ df -h | grep storage
/dev/mapper/storage-storage_data  3.9G   24K  3.7G   1% /mnt/storage
```

J'ai tout pété faut que je refasse tout je m'en occupe plus tard si j'oublie pas


# Partie 2 : Serveur de partage de fichiers
### 🌞 Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux
```
[antoine@storage storage]$ sudo dnf install nfs-utils
[antoine@storage ~]$ sudo mkdir storage
[antoine@storage ~]$ sudo mkdir storage/site_web_1
[antoine@storage ~]$ sudo mkdir storage/site_web_2
[antoine@storage ~]$ sudo chown -R nobody storage/
[antoine@storage ~]$ cat /etc/exports
/home/antoine/storage/site_web_1 10.2.1.11(rw,sync,no_subtree_check)
/home/antoine/storage/site_web_2 10.2.1.11(rw,sync,no_subtree_check)

[antoine@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[antoine@storage ~]$ sudo systemctl start nfs-server
[antoine@storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2024-02-20 14:02:09 CET; 41s ago
    Process: 15104 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 15105 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 15124 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (co>
   Main PID: 15124 (code=exited, status=0/SUCCESS)
        CPU: 31ms

Feb 20 14:02:08 localhost.localdomain systemd[1]: Starting NFS server and services...
Feb 20 14:02:09 localhost.localdomain systemd[1]: Finished NFS server and services.

[antoine@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[antoine@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[antoine@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[antoine@storage ~]$ sudo firewall-cmd --reload
success
[antoine@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

### 🌞 Donnez les commandes réalisées sur le client NFS web.tp4.linux
```
[antoine@web ~]$ sudo dnf install nfs-utils
[antoine@web ~]$ sudo mkdir -p /var/www/site_web_1
[antoine@web ~]$ sudo mkdir -p /var/www/site_web_2
[antoine@web ~]$ sudo mount 10.2.1.10:/home/antoine/storage/site_web_1 /var/www/site_web_1
[antoine@web ~]$ sudo mount 10.2.1.10:/home/antoine/storage/site_web_2 /var/www/site_web_2

[antoine@web ~]$ df -h
Filesystem                                  Size  Used Avail Use% Mounted on
devtmpfs                                    4.0M     0  4.0M   0% /dev
tmpfs                                       386M     0  386M   0% /dev/shm
tmpfs                                       155M  3.7M  151M   3% /run
/dev/mapper/rl-root                         6.2G  1.2G  5.0G  20% /
/dev/sda1                                  1014M  220M  795M  22% /boot
tmpfs                                        78M     0   78M   0% /run/user/1000
10.2.1.10:/home/antoine/storage/site_web_1  6.2G  1.2G  5.0G  20% /var/www/site_web_1
10.2.1.10:/home/antoine/storage/site_web_2  6.2G  1.2G  5.0G  20% /var/www/site_web_2

[antoine@web ~]$ sudo cat /etc/fstab | grep storage
10.2.1.10:/home/antoine/storage/site_web_1 /var/www/site_web_1 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.2.1.10:/home/antoine/storage/site_web_2 /var/www/site_web_2 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

```
[antoine@web ~]$ sudo touch /var/www/site_web_1/index.html
[antoine@web ~]$ 

----------------------------

[antoine@storage ~]$ ls storage/site_web_1
index.html
```

# Partie 3 : Serveur web
## 2. Install
### 🌞 Installez NGINX
```
[antoine@web ~]$ sudo dnf install nginx
```

## 3. Analyse
```
[antoine@web ~]$ sudo systemctl start nginx
[antoine@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2024-02-20 14:19:39 CET; 3s ago
    Process: 3089 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 3090 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 3091 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 3092 (nginx)
      Tasks: 2 (limit: 4673)
     Memory: 2.0M
        CPU: 20ms
     CGroup: /system.slice/nginx.service
             ├─3092 "nginx: master process /usr/sbin/nginx"
             └─3093 "nginx: worker process"

Feb 20 14:19:39 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Feb 20 14:19:39 web.tp4.linux nginx[3090]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Feb 20 14:19:39 web.tp4.linux nginx[3090]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Feb 20 14:19:39 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

### 🌞 Analysez le service NGINX
```
[antoine@web ~]$ sudo ps aux | grep nginx
root        3092  0.0  0.1  10108   956 ?        Ss   14:19   0:00 nginx: master process /usr/sbin/nginx
nginx       3093  0.0  0.6  13908  4788 ?        S    14:19   0:00 nginx: worker process
antoine     3138  0.0  0.2   6408  2164 pts/0    S+   14:22   0:00 grep --color=auto nginx

[antoine@web ~]$ sudo ss -antpl | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=3093,fd=6),("nginx",pid=3092,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=3093,fd=7),("nginx",pid=3092,fd=7))

[antoine@web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;

[antoine@web ~]$ ls -ld /usr/share/nginx/html
drwxr-xr-x. 3 root root 143 Feb 20 14:19 /usr/share/nginx/html
```

## 4. Visite du service web
### 🌞 Configurez le firewall pour autoriser le trafic vers le service NGINX
```
[antoine@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --reload
success
[antoine@web ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp
```

### 🌞 Accéder au site web
```
aube@MakOS:~$ curl 10.2.1.11
<!doctype html>
<html>
  <head>
....
```

### 🌞 Vérifier les logs d'accès
```
[antoine@web ~]$ sudo tail -n 3 /var/log/nginx/access.log
10.2.1.0 - - [20/Feb/2024:14:31:30 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.2.1.11/" "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" "-"
10.2.1.0 - - [20/Feb/2024:14:31:30 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://10.2.1.11/" "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" "-"
10.2.1.0 - - [20/Feb/2024:14:31:46 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.88.1" "-"
[antoine@web ~]$ sudo tail -n 3 /var/log/nginx/access.log
10.2.1.0 - - [20/Feb/2024:14:31:30 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.2.1.11/" "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" "-"
10.2.1.0 - - [20/Feb/2024:14:31:30 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://10.2.1.11/" "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" "-"
10.2.1.0 - - [20/Feb/2024:14:31:46 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.88.1" "-"
```

## 5. Modif de la conf du serveur web
### 🌞 Changer le port d'écoute
```
[antoine@web ~]$ cat /etc/nginx/nginx.conf | grep listen
        listen       8080;
        listen       [::]:8080;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;

[antoine@web ~]$ sudo systemctl restart nginx
[antoine@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2024-02-20 14:37:24 CET; 4s ago
    Process: 3256 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 3257 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 3258 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 3259 (nginx)
      Tasks: 2 (limit: 4673)
     Memory: 1.9M
        CPU: 20ms
     CGroup: /system.slice/nginx.service
             ├─3259 "nginx: master process /usr/sbin/nginx"
             └─3260 "nginx: worker process"

Feb 20 14:37:24 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Feb 20 14:37:24 web.tp4.linux nginx[3257]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Feb 20 14:37:24 web.tp4.linux nginx[3257]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Feb 20 14:37:24 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.

[antoine@web ~]$ sudo ss -antpl | grep nginx
^[[6~LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=3260,fd=6),("nginx",pid=3259,fd=6))
LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=3260,fd=7),("nginx",pid=3259,fd=7))

[antoine@web ~]$ sudo firewall-cmd --remove-port=80/tcp
success
[antoine@web ~]$ sudo firewall-cmd --add-port=8080/tcp
success
[antoine@web ~]$ sudo firewall-cmd --reload
success
[antoine@web ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 8080/tcp
  forward-ports: 
  source-ports: 
```

```
aube@MakOS:~$ curl 10.2.1.11:8080
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
```

### 🌞 Changer l'utilisateur qui lance le service
```
[antoine@web ~]$ sudo useradd web -m
[antoine@web ~]$ sudo passwd web
Changing password for user web.
New password: 
BAD PASSWORD: The password is shorter than 8 characters
Retype new password: 
passwd: all authentication tokens updated successfully.

[antoine@web ~]$ cat /etc/nginx/nginx.conf | grep user
user web;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

[antoine@web ~]$ sudo systemctl restart nginx
[antoine@web ~]$ sudo ps aux | grep web
web         3389  0.0  0.6  13908  4824 ?        S    14:46   0:00 nginx: worker process
```

### 🌞 Changer l'emplacement de la racine Web
```
[antoine@web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1;
#        root         /usr/share/nginx/html;
```

```
aube@MakOS:~$ curl 10.2.1.11:8080
<h1>Salut les jeunes</h1>
```

## 6. Deux sites web sur un seul serveur
### 🌞 Repérez dans le fichier de conf
```
[antoine@web ~]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

### 🌞 Créez le fichier de configuration pour le premier site
```
[antoine@web ~]$ cat /etc/nginx/conf.d/site_web_1.conf 
server {
    listen       8080;
    listen       [::]:8080;
    server_name  _;
    root         /var/www/site_web_1;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
    error_page 404 /404.html;
    location = /404.html {
    }
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
```

### 🌞 Créez le fichier de configuration pour le deuxième site
```
[antoine@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf 
server {
    listen       8888;
    listen       [::]:8888;
    server_name  _;
    root         /var/www/site_web_2;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
    error_page 404 /404.html;
    location = /404.html {
    }
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}

[antoine@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --reload
success
```

### 🌞 Prouvez que les deux sites sont disponibles
```
aube@MakOS:~$ curl 10.2.1.11:8080
<h1>Salut les jeunes</h1>
```
```
aube@MakOS:~$ curl 10.2.1.11:8888
<h1>test 2</h1>
```