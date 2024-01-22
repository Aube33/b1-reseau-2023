# I. First steps

### 🌞 Déterminez, pour ces 5 applications, si c'est du TCP ou de l'UDP
### Apps choisis:
- **Spotify**:
  - IP et Port serveur: `35.186.224.25:443`
  - Port local ouvert: `44922`
  - ```
    aube@MakOS:~$ sudo ss -antp | grep brave                                                        
    ESTAB     0      0       192.168.88.9:44922 35.186.224.25:443  users:(("brave",pid=1343,fd=54)) 
    ```
  - **Voir tp5_service_1.pcapng**
  
- **Discord**:
  - IP et Port serveur: `162.159.138.232:443`
  - Port local ouvert: `41004`
  - ```
    aube@MakOS:~$ sudo ss -antp | grep Discord
    LISTEN     0      511            127.0.0.1:6463          0.0.0.0:*    users:(("Discord",pid=7537,fd=202))                                                                                                                                
    ESTAB      0      0           192.168.88.9:41004 162.159.128.233:443  users:(("Discord",pid=7484,fd=43))                                                                
    ```
  - **Voir tp5_service_2.pcapng**
- **Teams**:
  - IP et Port serveur: `20.42.73.24:443`
  - Port local ouvert: `59026`
  - ```
    aube@MakOS:~$ sudo ss -antp | grep teams
    ESTAB     0      0       192.168.88.9:59026 20.42.73.24:443  users:(("teams",pid=8517,fd=40))                                                               
    ```
  - **Voir tp5_service_3.pcapng**
- **Steam**:
  - IP et Port serveur: `23.54.132.227:443`
  - Port local ouvert: `45497`
  - ```
    aube@MakOS:~$ sudo ss -antp | grep steam
    ESTAB     0      0           192.168.88.9:45497  23.54.132.227:443  users:(("steam",pid=9986,fd=113))                                                           
    ```
  - **Voir tp5_service_4.pcapng**
- **AnyDesk**:
  - IP et Port serveur: `208.115.231.146:443`
  - Port local ouvert: `59112`
  - ```
    aube@MakOS:~$ sudo ss -antp | grep anydesk
    LISTEN    0      10           0.0.0.0:7070          0.0.0.0:*    users:(("anydesk",pid=7018,fd=34))                                                                                                                                 
    ESTAB     0      0       192.168.88.9:59112 208.115.231.146:443  users:(("anydesk",pid=7018,fd=44)) 
    ```
  - **Voir tp5_service_5.pcapng**

## 🌞 Demandez l'avis à votre OS
`sudo ss -antp`



# II. Setup Virtuel
## 1. SSH
## 🌞 Examinez le trafic dans Wireshark
#### déterminez si SSH utilise TCP ou UDP:
TCP car y'a un moment faut sécuriser le bail, on s'occupe d'administrer des systèmes pas de trier des paquerettes. Trop risqué si on perd des paquets en chemin.
### 🌞 Demandez aux OS
**Depuis ma machine:**

`ESTAB                  0                      0                                             10.5.1.1:56594                                        10.5.1.11:22                    users:(("ssh",pid=6921,fd=3))                             `

**Depuis la VM:**

`ESTAB                 0                     0                                        10.5.1.11:22                                       10.5.1.1:56594                 users:(("sshd",pid=1494,fd=4),("sshd",pid=1490,fd=4))                `

## 2. Routage
### 🌞 Prouvez que

**node1.tp5.b1 a un accès internet:**
```
[antoine@node1 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=83.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=64.2 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 64.161/73.918/83.676/9.757 ms
```

**node1.tp5.b1 peut résoudre des noms de domaine publics (comme www.ynov.com):**
```
[antoine@node1 ~]$ ping www.ynov.com
PING www.ynov.com (104.26.10.233) 56(84) bytes of data.
64 bytes from 104.26.10.233 (104.26.10.233): icmp_seq=1 ttl=61 time=31.6 ms
64 bytes from 104.26.10.233 (104.26.10.233): icmp_seq=2 ttl=61 time=70.2 ms
^C
--- www.ynov.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 31.621/50.893/70.166/19.272 ms
```

## 3. Serveur Web

### 🌞 Installez le paquet nginx

`sudo dnf install nginx`

### 🌞 Créer le site web
`sudo mkdir /var/www/site_web_nul`

`sudo nano /var/www/site_web_nul/index.html`

### 🌞 Donner les bonnes permissions

`sudo chown -R nginx:nginx /var/www/site_web_nul`

### 🌞 Créer un fichier de configuration NGINX pour notre site web
```
[antoine@web conf.d]$ cat /etc/nginx/conf.d/site_web_nul.conf 
server {
  # le port sur lequel on veut écouter
  listen 80;

  # le nom de la page d'accueil si le client de la précise pas
  index index.html;

  # un nom pour notre serveur (pas vraiment utile ici, mais bonne pratique)
  server_name www.site_web_nul.b1;

  # le dossier qui contient notre site web
  root /var/www/site_web_nul;
}
```

### 🌞 Démarrer le serveur web !
```
[antoine@web conf.d]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Thu 2023-11-09 21:40:05 CET; 18s ago
    Process: 1752 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1753 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1754 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1755 (nginx)
      Tasks: 2 (limit: 4673)
     Memory: 2.0M
        CPU: 20ms
     CGroup: /system.slice/nginx.service
             ├─1755 "nginx: master process /usr/sbin/nginx"
             └─1756 "nginx: worker process"

Nov 09 21:40:05 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Nov 09 21:40:05 localhost.localdomain nginx[1753]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Nov 09 21:40:05 localhost.localdomain nginx[1753]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 09 21:40:05 localhost.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.
```

### 🌞 Ouvrir le port firewall
```
[antoine@web conf.d]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[antoine@web conf.d]$ sudo firewall-cmd --reload
success
[antoine@web conf.d]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3
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

### 🌞 Visitez le serveur web !
```
[antoine@node1 ~]$ curl 10.5.1.12
<h1>MEOW</h1>
```

### 🌞 Visualiser le port en écoute
`[antoine@web ~]$ sudo ss -antp`

`LISTEN                0                     511                                        0.0.0.0:80                                      0.0.0.0:*                     users:(("nginx",pid=1756,fd=6),("nginx",pid=1755,fd=6))                `

### 🌞 Analyse trafic
**Voir tp5_web.pcapng**