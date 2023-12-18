# I. Exploration locale en solo
## 1. Affichage d'informations sur la pile TCP/IP locale

### 🌞 Affichez les infos des cartes réseau de votre PC

- nom, adresse MAC et adresse IP de l'interface WiFi
```
3: wlo1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 24:41:8c:0d:50:bb brd ff:ff:ff:ff:ff:ff
    altname wlp0s20f3
    inet 10.33.50.251/22 brd 10.33.51.255 scope global dynamic noprefixroute wlo1
       valid_lft 84716sec preferred_lft 84716sec
    inet6 fe80::fc5e:72a6:e52e:61e3/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

```
- nom, adresse MAC et adresse IP de l'interface Ethernet
```
2: enp3s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:d8:61:8a:6e:78 brd ff:ff:ff:ff:ff:ff
```

### 🌞 Affichez votre gateway
```
aube@MakOS:~/Desktop/Ynov/FonctionRéseau$ ip route show
default via 10.33.51.254 dev wlo1 proto dhcp metric 600 
10.33.48.0/22 dev wlo1 proto kernel scope link src 10.33.50.251 metric 600 
```

### 🌞 Déterminer la MAC de la passerelle

```
aube@MakOS:~/Desktop/Ynov/FonctionRéseau$ arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
10.33.51.254             ether   7c:5a:1c:cb:fd:a4   C                     wlo1
```

### 🌞 Trouvez comment afficher les informations sur une carte IP (change selon l'OS)

**SOUS UBUNTU**:
- Cliquer sur icône Wifi
- Agrandir informations sur le Wifi connecté
- Et cliquer sur le volet Détails


## 2. Modifications des informations

## A. Modification d'adresse IP (part 1)

### 🌞 Utilisez l'interface graphique de votre OS pour changer d'adresse IP :
**SOUS UBUNTU**:
- System Settings
- Connections
- WIFI@YNOV
- IPv4
- Add Adress
- Compléter les textbox:
  - Adress: `10.33.50.250`
  - Netmask: `255.255.252.0`
  - Gateway: `10.33.51.254`
- Apply
- Reload le Wifi

```
aube@MakOS:~/Desktop/Ynov/FonctionRéseau$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp3s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:d8:61:8a:6e:78 brd ff:ff:ff:ff:ff:ff
3: wlo1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 24:41:8c:0d:50:bb brd ff:ff:ff:ff:ff:ff
    altname wlp0s20f3
    inet 10.33.50.250/22 brd 10.33.51.255 scope global noprefixroute wlo1
       valid_lft forever preferred_lft forever
    inet6 fe80::fc5e:72a6:e52e:61e3/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

### 🌞 Il est possible que vous perdiez l'accès internet.
Il est possible de perdre son accès car l'IP que nous avons rentré manuellement est peut être déjà occupée. Ou bien parce que l'attribution d'une adresse IP statique est désactivée par l'admin réseau.

# II. Exploration locale en duo

### 🌞 Modifiez l'IP des deux machines pour qu'elles soient dans le même réseau

`aube@MakOS:~/Desktop/Ynov/FonctionRéseau$ sudo ifconfig enp3s0 10.10.10.2 netmask 255.255.255.0
`

### 🌞 Vérifier à l'aide d'une commande que votre IP a bien été changée

```
aube@MakOS:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:d8:61:8a:6e:78 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.2/24 brd 10.10.10.255 scope global enp3s0
       valid_lft forever preferred_lft forever
    inet6 fe80::473a:96ee:5a31:944a/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: wlo1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 24:41:8c:0d:50:bb brd ff:ff:ff:ff:ff:ff
    altname wlp0s20f3
    inet 10.33.50.251/22 brd 10.33.51.255 scope global dynamic noprefixroute wlo1
       valid_lft 81078sec preferred_lft 81078sec
    inet6 fe80::fc5e:72a6:e52e:61e3/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

### 🌞 Vérifier que les deux machines se joignent

```
aube@MakOS:~$ ping -I enp3s0 10.10.10.3
PING 10.10.10.3 (10.10.10.3) from 10.10.10.1 enp3s0: 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=128 time=0.793 ms
64 bytes from 10.10.10.3: icmp_seq=2 ttl=128 time=0.858 ms
64 bytes from 10.10.10.3: icmp_seq=3 ttl=128 time=0.682 ms
64 bytes from 10.10.10.3: icmp_seq=4 ttl=128 time=0.742 ms
64 bytes from 10.10.10.3: icmp_seq=5 ttl=128 time=0.717 ms
64 bytes from 10.10.10.3: icmp_seq=6 ttl=128 time=0.715 ms
^C
--- 10.10.10.3 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5079ms
rtt min/avg/max/mdev = 0.682/0.751/0.858/0.058 ms
```

### 🌞 Déterminer l'adresse MAC de votre correspondant
```
aube@MakOS:~$ arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
10.10.10.3               ether   58:11:22:e7:ed:25   C                     enp3s0
10.33.51.254             ether   7c:5a:1c:cb:fd:a4   C                     wlo1
10.10.10.2                       (incomplete)                              enp3s0
```
Donc: `58:11:22:e7:ed:25`

## 4. Petit chat privé

🌞 sur le PC serveur avec par exemple l'IP 10.10.10.1
```
aube@MakOS:~$ nc -l -p 8888
salut
test 
est ce encrypt� ?
je ne sais pas
```
🌞 sur le PC client avec par exemple l'IP 192.168.1.2
```
PS E:\Téléchargements\netcat-win32-1.11\netcat-1.11> .\nc.exe 10.10.10.1 8888
salut
test
est ce encrypté ?
je ne sais pas
```

### 🌞 Visualiser la connexion en cours
```
aube@MakOS:~$ ss -atnp
State         Recv-Q     Send-Q         Local Address:Port             Peer Address:Port     Process                                         
LISTEN        0          151                127.0.0.1:3306                  0.0.0.0:*                                                        
LISTEN        0          70                 127.0.0.1:33060                 0.0.0.0:*                                                        
LISTEN        0          10                   0.0.0.0:7070                  0.0.0.0:*                                                        
LISTEN        0          4096           127.0.0.53%lo:53                    0.0.0.0:*                                                        
LISTEN        0          511                127.0.0.1:6463                  0.0.0.0:*         users:(("Discord",pid=2957,fd=193))            
LISTEN        0          1                    0.0.0.0:8888                  0.0.0.0:*         users:(("nc",pid=14198,fd=3))                  
ESTAB         0          0                 10.33.51.2:52980            20.190.181.5:443       users:(("teams",pid=12869,fd=36))              
ESTAB         0          0                 10.33.51.2:36150           52.97.232.210:443       users:(("teams",pid=12869,fd=37))              
ESTAB         0          0                 10.33.51.2:54812         162.159.136.234:443       users:(("Discord",pid=2906,fd=30))             
ESTAB         0          0                 10.33.51.2:56206           52.178.17.233:443       users:(("teams",pid=12869,fd=35))              
ESTAB         0          0               10.33.50.251:40859          52.113.194.132:443       users:(("teams",pid=12974,fd=70))              
CLOSE-WAIT    74         0               10.33.50.251:52464            151.101.2.49:443       users:(("kio_http_cache_",pid=10506,fd=78))    
ESTAB         0          0                 10.33.51.2:53104            52.114.77.97:443       users:(("teams",pid=12869,fd=28))              
ESTAB         0          0                 10.33.51.2:55764          162.19.171.173:443                                                      
ESTAB         0          0               10.33.50.251:58452           140.82.112.26:443       users:(("brave",pid=2368,fd=24))               
ESTAB         0          1978            10.33.50.251:56214          34.111.115.192:443       users:(("Discord",pid=2906,fd=32))             
ESTAB         0          0                 10.10.10.1:8888               10.10.10.3:57745     users:(("nc",pid=14198,fd=4))                  
ESTAB         0          0                 10.33.51.2:57528             13.249.9.85:443       users:(("brave",pid=2368,fd=27))               
ESTAB         0          0                 10.33.51.2:51310           52.123.144.77:443       users:(("teams",pid=12869,fd=25))              
ESTAB         0          0                 10.33.51.2:34311            52.114.77.97:443       users:(("teams",pid=12974,fd=67))              
ESTAB         0          0                 10.33.51.2:38396           52.123.128.14:443       users:(("teams",pid=12869,fd=33))              
LISTEN        0          50                         *:1716                        *:*         users:(("kdeconnectd",pid=1932,fd=15))         
LISTEN        0          511                        *:80                          *:*                                                                                                            
```

## 5. Firewall
### 🌞 Activez et configurez votre firewall
```
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
```
```
iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
```

## 6. Utilisation d'un des deux comme gateway

### 🌞 Tester l'accès internet

```
PS C:\Users\antre> ping 1.1.1.1

Envoi d’une requête 'Ping'  1.1.1.1 avec 32 octets de données :
Réponse de 1.1.1.1 : octets=32 temps=10 ms TTL=56
Réponse de 1.1.1.1 : octets=32 temps=10 ms TTL=56
Réponse de 1.1.1.1 : octets=32 temps=13 ms TTL=56
Réponse de 1.1.1.1 : octets=32 temps=11 ms TTL=56

Statistiques Ping pour 1.1.1.1:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 10ms, Maximum = 13ms, Moyenne = 11ms
```

### 🌞 Prouver que la connexion Internet passe bien par l'autre PC

```
PS C:\Users\antre> tracert 1.1.1.1

Détermination de l’itinéraire vers one.one.one.one [1.1.1.1]
avec un maximum de 30 sauts :

  1    <1 ms    <1 ms    <1 ms  MakOS [10.42.0.1]
  2    17 ms    40 ms    15 ms  _gateway [192.168.184.14]
  3     *        *        *     Délai d’attente de la demande dépassé.
  4    62 ms    30 ms    74 ms  10.4.1.12
  5    57 ms    95 ms    78 ms  10.231.23.252
  6   159 ms   162 ms   147 ms  93.8.130.77.rev.sfr.net [77.130.8.93]
  7   210 ms   234 ms   178 ms  12.148.6.194.rev.sfr.net [194.6.148.12]
  8   599 ms   648 ms   354 ms  12.148.6.194.rev.sfr.net [194.6.148.12]
  9   195 ms   130 ms   129 ms  141.101.67.48
 10   339 ms   327 ms   297 ms  141.101.67.54
 11    44 ms    54 ms    54 ms  one.one.one.one [1.1.1.1]

Itinéraire déterminé.
```

# III. Manipulations d'autres outils/protocoles côté client
## 1. DHCP
### 🌞 Exploration du DHCP, depuis votre PC

```
aube@MakOS:/var/lib/dhcp$ ip r
default via 192.168.184.14 dev wlo1 proto dhcp metric 600 
192.168.184.0/24 dev wlo1 proto kernel scope link src 192.168.184.9 metric 600 
```
Ici l'IP du serveur DHCP est `192.168.184.14`

# 2. DNS
### 🌞 Trouver l'adresse IP du serveur DNS que connaît votre ordinateur

```
aube@MakOS:/var/lib/dhcp$ cat /etc/resolv.conf
# This is /run/systemd/resolve/stub-resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 127.0.0.53
options edns0 trust-ad
search .
```
### 🌞 Utiliser, en ligne de commande l'outil nslookup (Windows, MacOS) ou dig (GNU/Linux, MacOS) pour faire des requêtes DNS à la main
```
aube@MakOS:~$ nslookup google.com
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 216.58.214.174
Name:   google.com
Address: 2a00:1450:4007:80e::200e

aube@MakOS:~$ nslookup ynov.com
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   ynov.com
Address: 104.26.11.233
Name:   ynov.com
Address: 172.67.74.226
Name:   ynov.com
Address: 104.26.10.233
Name:   ynov.com
Address: 2606:4700:20::681a:ae9
Name:   ynov.com
Address: 2606:4700:20::ac43:4ae2
Name:   ynov.com
Address: 2606:4700:20::681a:be9
```
Adresse IP du serveur google.com : `216.58.214.174`

Adresses IP du serveur ynov.com : 
   - `104.26.11.233`
   - `172.67.74.226`
   - `104.26.10.233`

**Reverse lookup**
```
aube@MakOS:~$ dig -x 231.34.113.12

; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>> -x 231.34.113.12
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 60559
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;12.113.34.231.in-addr.arpa.    IN      PTR

;; Query time: 187 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Mon Oct 16 17:53:15 CEST 2023
;; MSG SIZE  rcvd: 55
```

```
aube@MakOS:~$ dig -x 78.34.2.17

; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>> -x 78.34.2.17
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24946
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;17.2.34.78.in-addr.arpa.       IN      PTR

;; ANSWER SECTION:
17.2.34.78.in-addr.arpa. 3600   IN      PTR     cable-78-34-2-17.nc.de.

;; Query time: 91 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Mon Oct 16 17:53:53 CEST 2023
;; MSG SIZE  rcvd: 88
```

le reverse lookup de l'adresse IP `78.34.2.17` a permi de retrouver son nom de domain associé, autrement dit: `cable-78-34-2-17.nc.de`

# IV. Wireshark

Voir fichier `enregistrement.pcap`