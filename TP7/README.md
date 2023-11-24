# I. Setup LAN
# II. SSH
## 1. Fingerprint
### B. Manips

```
aube@MakOS:~$ ssh antoine@john
The authenticity of host 'john (10.7.1.11)' can't be established.
ED25519 key fingerprint is SHA256:FXOJYkTn1aFi+QXuo0m1vfs57vtFy/Nw3X3P1NxUVJ0.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'john' (ED25519) to the list of known hosts.
```

```
[antoine@john ~]$ ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
256 SHA256:FXOJYkTn1aFi+QXuo0m1vfs57vtFy/Nw3X3P1NxUVJ0 no comment (ED25519)
```
## 2. Conf serveur SSH
### 🌞 Consulter l'état actuel

```
[antoine@router ~]$ ss -antplu
Netid                   State                    Recv-Q                   Send-Q                                     Local Address:Port                                       Peer Address:Port                   Process 
tcp                     LISTEN                   0                        128                                              0.0.0.0:22                                              0.0.0.0:*                                                
tcp                     LISTEN                   0                        128                                                 [::]:22                                                                                            
```

### 🌞 Modifier la configuration du serveur SSH
Dans `/etc/ssh/sshd_config`:
    - rajout de la ligne `Port 22000`
    - rajout de la ligne `Listen Adress 10.7.1.254`

### 🌞 Prouvez que le changement a pris effet
```
[antoine@routeur ~]$ ss -antplu
Netid      State       Recv-Q      Send-Q           Local Address:Port            Peer Address:Port     Process
tcp        LISTEN      0           128                 10.7.1.254:22000                0.0.0.0:*
```

### 🌞 Effectuer une connexion SSH sur le nouveau port
```
aube@MakOS:~$ ssh antoine@10.7.1.254
ssh: connect to host 10.7.1.254 port 22: Connection refused
```

**Avec nouveau port + ajout d'une règle sur notre firewall sur le port 22000/TCP:**
```
aube@MakOS:~$ ssh antoine@router -p 22000
The authenticity of host '[router]:22000 ([10.7.1.254]:22000)' can't be established.
ED25519 key fingerprint is SHA256:FXOJYkTn1aFi+QXuo0m1vfs57vtFy/Nw3X3P1NxUVJ0.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[router]:22000' (ED25519) to the list of known hosts.
```

## 3. Connexion par clé
### B. Manips
### 🌞 Générer une paire de clés
```
aube@MakOS:~$ ls .ssh/
id_rsa  id_rsa.pub  known_hosts  known_hosts.old
```

### 🌞 Déposer la clé publique sur une VM
```
aube@MakOS:~$ ssh-copy-id antoine@john
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/aube/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
antoine@john's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'antoine@john'"
and check to make sure that only the key(s) you wanted were added.
```

### 🌞 Connectez-vous en SSH à la machine
```
aube@MakOS:~$ ssh antoine@john
Last login: Thu Nov 23 14:40:44 2023 from 10.7.1.1
[antoine@john ~]$ 
```

## C. Changement de fingerprint
### 🌞 Supprimer les clés sur la machine router.tp7.b1
```
[antoine@routeur ssh]$ sudo rm ssh_host_**
```

### 🌞 Regénérez les clés sur la machine router.tp7.b1
```
[antoine@routeur ssh]$ sudo ssh-keygen -A
ssh-keygen: generating new host keys: RSA DSA ECDSA ED25519 
```
### 🌞 Tentez une nouvelle connexion au serveur
```
aube@MakOS:~$ ssh antoine@router -p 22000
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:CFqfdgi3dIDGxcBL91zVM239GOBZCEFCghJOLr4pXYM.
Please contact your system administrator.
Add correct host key in /home/aube/.ssh/known_hosts to get rid of this message.
Offending ED25519 key in /home/aube/.ssh/known_hosts:4
  remove with:
  ssh-keygen -f "/home/aube/.ssh/known_hosts" -R "[router]:22000"
Host key for [router]:22000 has changed and you have requested strict checking.
Host key verification failed.
```

# III. Web
## 0. Setup
### 🌞 Montrer sur quel port est disponible le serveur web

```
[antoine@web ~]$ sudo ss -antp
State  Recv-Q Send-Q Local Address:Port Peer Address:Port  Process                                                  
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*      users:(("nginx",pid=1736,fd=6),("nginx",pid=1735,fd=6)) 
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*      users:(("sshd",pid=693,fd=3))                           
ESTAB  0      0          10.7.1.12:80       10.7.1.1:37998  users:(("nginx",pid=1736,fd=3))                         
ESTAB  0      0          10.7.1.12:22       10.7.1.1:48574  users:(("sshd",pid=1643,fd=4),("sshd",pid=1639,fd=4))   
LISTEN 0      511             [::]:80           [::]:*      users:(("nginx",pid=1736,fd=7),("nginx",pid=1735,fd=7)) 
LISTEN 0      128             [::]:22           [::]:*      users:(("sshd",pid=693,fd=4))                           
```

## 1. Setup HTTPS
### 🌞 Générer une clé et un certificat sur web.tp7.b1
### 🌞 Modification de la conf de NGINX
```
[antoine@web ~]$ sudo cat /etc/nginx/conf.d/web.tp6.b1.conf 
server {
    # on change la ligne listen
    listen 10.7.1.12:443 ssl;

    # et on ajoute deux nouvelles lignes
    ssl_certificate /etc/pki/tls/certs/web.tp7.b1.crt;
    ssl_certificate_key /etc/pki/tls/private/web.tp7.b1.key;

    server_name www.site_web.b1;
    root /var/www/site_web
}
```

### 🌞 Conf firewall
```
[antoine@web ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[antoine@web ~]$ sudo firewall-cmd --reload
success
```

### 🌞 Redémarrez NGINX
```
[antoine@web ~]$ sudo systemctl restart nginx
```

### 🌞 Prouvez que NGINX écoute sur le port 443/tcp
```
[antoine@web ~]$ sudo ss -antplu
Netid              State               Recv-Q              Send-Q                           Local Address:Port                           Peer Address:Port             Process                                                              
udp                UNCONN              0                   0                                    127.0.0.1:323                                 0.0.0.0:*                 users:(("chronyd",pid=672,fd=5))                                    
udp                UNCONN              0                   0                                        [::1]:323                                    [::]:*                 users:(("chronyd",pid=672,fd=6))                                    
tcp                LISTEN              0                   511                                    0.0.0.0:80                                  0.0.0.0:*                 users:(("nginx",pid=2010,fd=6),("nginx",pid=2009,fd=6))             
tcp                LISTEN              0                   128                                    0.0.0.0:22                                  0.0.0.0:*                 users:(("sshd",pid=693,fd=3))                                       
tcp                LISTEN              0                   511                                  10.7.1.12:443                                 0.0.0.0:*                 users:(("nginx",pid=2010,fd=7),("nginx",pid=2009,fd=7))             
tcp                LISTEN              0                   511                                       [::]:80                                     [::]:*                 users:(("nginx",pid=2010,fd=8),("nginx",pid=2009,fd=8))             
tcp                LISTEN              0                   128                                       [::]:22                                     [::]:*                 users:(("sshd",pid=693,fd=4)) 
```

### 🌞 Visitez le site web en https
```
[antoine@john ~]$ curl -k 10.7.1.12
<h1>test</h1>
```

# IV. VPN
## 3. On y va ou bien
### A. Setup serveur
### 🌞 Installer le serveur Wireguard sur vpn.tp7.b1
### 🌞 Générer la paire de clé du serveur sur vpn.tp7.b1
```
[antoine@vpn ~]$ wg genkey | sudo tee /etc/wireguard/server.key
yNY3LAsx4kTbrOe8PhPQ8z6kq4mapudWGlk6Kad953E=
[antoine@vpn ~]$ sudo chmod 0400 /etc/wireguard/server.key
[antoine@vpn ~]$ sudo cat /etc/wireguard/server.key | wg pubkey | sudo tee /etc/wireguard/server.pub
LQw0+JKdsvGjF3w7CTsSOUfPvOWHENzcT+JAYyPc/XY=
[antoine@vpn ~]$ 
```

### 🌞 Générer la paire de clé du client sur vpn.tp7.b1
### 🌞 Création du fichier de config du serveur sur vpn.tp7.b1
```
[antoine@vpn ~]$ sudo cat /etc/wireguard/wg0.conf
sudo cat /etc/wireguard/wg0.conf
[Interface]
Address = 10.107.1.0/24
SaveConfig = false
PostUp = firewall-cmd --zone=public --add-masquerade
PostUp = firewall-cmd --add-interface=wg0 --zone=public
PostDown = firewall-cmd --zone=public --remove-masquerade
PostDown = firewall-cmd --remove-interface=wg0 --zone=public
ListenPort = 13337
PrivateKey = yNY3LAsx4kTbrOe8PhPQ8z6kq4mapudWGlk6Kad953E=

[Peer]
PublicKey = eWKdAU6PwhX/qHAPt1GpD7Fwl00UhN4dXh0H78wWT0Q=
AllowedIPs = 10.107.1.11/32
```

### 🌞 Démarrez le serveur VPN sur vpn.tp7.b1
```
[antoine@vpn ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ef:a9:82 brd ff:ff:ff:ff:ff:ff
    inet 10.7.1.101/24 brd 10.7.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feef:a982/64 scope link 
       valid_lft forever preferred_lft forever
8: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none 
    inet 10.107.1.0/24 scope global wg0
       valid_lft forever preferred_lft forever
[antoine@vpn ~]$ sudo wg show
interface: wg0
  public key: LQw0+JKdsvGjF3w7CTsSOUfPvOWHENzcT+JAYyPc/XY=
  private key: (hidden)
  listening port: 13337

peer: eWKdAU6PwhX/qHAPt1GpD7Fwl00UhN4dXh0H78wWT0Q=
  allowed ips: 10.107.1.11/32
```

### 🌞 Ouvrir le bon port firewall
```
[antoine@vpn ~]$ sudo firewall-cmd --add-port=13337/udp --permanent
success
[antoine@vpn ~]$ sudo firewall-cmd --reload
success
```
## B. Setup client
### 🌞 On installe les outils Wireguard sur john.tp7.b1
### 🌞 Supprimez votre route par défaut
`sudo rm /etc/sysconfig/network-scripts/route-enp0s3`
### 🌞 Configurer un fichier de conf sur john.tp7.b1
```
[antoine@john ~]$ sudo cat wireguard/john.conf 
[Interface]
Address = 10.107.1.11/24
PrivateKey = eWKdAU6PwhX/qHAPt1GpD7Fwl00UhN4dXh0H78wWT0Q= 

[Peer]
PublicKey = LQw0+JKdsvGjF3w7CTsSOUfPvOWHENzcT+JAYyPc/XY=
AllowedIPs = 0.0.0.0/0
Endpoint = 10.7.1.101:13337
```

### 🌞 Lancer la connexion VPN
```
[antoine@john wireguard]$ wg-quick up ./john.conf
Warning: `/home/antoine/wireguard/john.conf' is world accessible
[#] ip link add john type wireguard
[#] wg setconf john /dev/fd/63
[#] ip -4 address add 10.107.1.11/24 dev john
[#] ip link set mtu 1420 up dev john
[#] wg set john fwmark 51820
[#] ip -4 route add 0.0.0.0/0 dev john table 51820
[#] ip -4 rule add not fwmark 51820 table 51820
[#] ip -4 rule add table main suppress_prefixlength 0
[#] sysctl -q net.ipv4.conf.all.src_valid_mark=1
[#] nft -f /dev/fd/63
```

### 🌞 Vérifier la connexion
```
[antoine@john wireguard]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=59 time=66.9 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=59 time=75.5 ms
^C
--- 1.1.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 66.927/71.189/75.451/4.262 ms
[antoine@john wireguard]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=59 time=86.2 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=59 time=25.4 ms
^C
--- 1.1.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 25.364/55.787/86.210/30.423 ms
[antoine@john wireguard]$ ping www.ynov.com
PING www.ynov.com (172.67.74.226) 56(84) bytes of data.
64 bytes from 172.67.74.226 (172.67.74.226): icmp_seq=1 ttl=59 time=52.4 ms
64 bytes from 172.67.74.226 (172.67.74.226): icmp_seq=2 ttl=59 time=75.5 ms
^C
--- www.ynov.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 52.434/63.978/75.523/11.544 ms
[antoine@john wireguard]$ traceroute 1.1.1.1
traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
 1  10.107.1.0 (10.107.1.0)  1.940 ms  1.782 ms  1.733 ms
 2  * * *
 3  10.0.3.2 (10.0.3.2)  3.797 ms  3.329 ms  3.367 ms
 4  * * *
 5  * * *
 6  * station13.multimania.isdnet.net (194.149.174.110)  16.414 ms  16.007 ms
 7  * * *
 8  prs-b3-link.ip.twelve99.net (62.115.46.68)  17.880 ms  51.827 ms  51.248 ms
 9  prs-bb1-link.ip.twelve99.net (62.115.118.58)  51.127 ms  50.517 ms *
10  prs-b1-link.ip.twelve99.net (62.115.125.167)  48.266 ms prs-b1-link.ip.twelve99.net (62.115.125.171)  18.852 ms  20.360 ms
11  cloudflare-ic-375100.ip.twelve99-cust.net (80.239.194.103)  24.277 ms cloudflare-ic-363840.ip.twelve99-cust.net (213.248.73.69)  23.550 ms cloudflare-ic-375100.ip.twelve99-cust.net (80.239.194.103)  23.480 ms
12  172.71.132.4 (172.71.132.4)  18.395 ms 172.71.128.2 (172.71.128.2)  20.004 ms 172.69.186.3 (172.69.186.3)  17.796 ms
13  one.one.one.one (1.1.1.1)  15.580 ms  16.913 ms  18.040 ms
```

```
[antoine@john wireguard]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ed:c0:5c brd ff:ff:ff:ff:ff:ff
    inet 10.7.1.11/24 brd 10.7.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feed:c05c/64 scope link 
       valid_lft forever preferred_lft forever
3: john: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none 
    inet 10.107.1.11/24 scope global john
       valid_lft forever preferred_lft forever
```

```
[antoine@john wireguard]$ sudo wg show
interface: john
  public key: eWKdAU6PwhX/qHAPt1GpD7Fwl00UhN4dXh0H78wWT0Q=
  private key: (hidden)
  listening port: 36421
  fwmark: 0xca6c

peer: LQw0+JKdsvGjF3w7CTsSOUfPvOWHENzcT+JAYyPc/XY=
  endpoint: 10.7.1.101:13337
  allowed ips: 0.0.0.0/0
  latest handshake: 2 minutes, 24 seconds ago
  transfer: 9.56 KiB received, 12.73 KiB sent
```

```
[antoine@vpn ~]$ sudo wg show
interface: wg0
  public key: LQw0+JKdsvGjF3w7CTsSOUfPvOWHENzcT+JAYyPc/XY=
  private key: (hidden)
  listening port: 13337

peer: eWKdAU6PwhX/qHAPt1GpD7Fwl00UhN4dXh0H78wWT0Q=
  endpoint: 10.7.1.11:36421
  allowed ips: 10.107.1.11/32
  latest handshake: 15 seconds ago
  transfer: 12.20 KiB received, 12.18 KiB sent
```