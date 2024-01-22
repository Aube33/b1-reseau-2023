# ARP

## 1. Echange ARP
### 🌞Générer des requêtes ARP

Marcel:
```
[antoine@marcel ~]$ ping 10.3.1.11
PING 10.3.1.11 (10.3.1.11) 56(84) bytes of data.
64 bytes from 10.3.1.11: icmp_seq=1 ttl=64 time=1.18 ms
64 bytes from 10.3.1.11: icmp_seq=2 ttl=64 time=1.03 ms
64 bytes from 10.3.1.11: icmp_seq=3 ttl=64 time=1.03 ms
^C
--- 10.3.1.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 1.026/1.076/1.175/0.069 ms
```

John:
```
[antoine@john ~]$ ping 10.3.1.12
PING 10.3.1.12 (10.3.1.12) 56(84) bytes of data.
64 bytes from 10.3.1.12: icmp_seq=1 ttl=64 time=1.04 ms
64 bytes from 10.3.1.12: icmp_seq=2 ttl=64 time=1.11 ms
64 bytes from 10.3.1.12: icmp_seq=3 ttl=64 time=0.985 ms
^C
--- 10.3.1.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 0.985/1.042/1.106/0.049 ms
```

Marcel:
```
[antoine@marcel ~]$ ip n show
10.3.1.11 dev enp0s3 lladdr 08:00:27:b6:a3:98 STALE 
10.3.1.0 dev enp0s3 lladdr 0a:00:27:00:00:00 DELAY
```
MAC de John: `08:00:27:b6:a3:98`

John
```
[antoine@john ~]$ ip n show
10.3.1.12 dev enp0s3 lladdr 08:00:27:46:42:2b STALE 
10.3.1.0 dev enp0s3 lladdr 0a:00:27:00:00:00 DELAY
```
MAC de Marcel: `08:00:27:46:42:2b`

Preuve que Marcel est Marcel depuis John: 
```
[antoine@john ~]$ ip n show 10.3.1.12
10.3.1.12 dev enp0s3 lladdr 08:00:27:46:42:2b STALE
```

Preuve que Marcel est Marcel depuis Marcel:
```
[antoine@marcel ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b6:a3:98 brd ff:ff:ff:ff:ff:ff
    inet 10.3.1.11/24 brd 10.3.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feb6:a398/64 scope link 
       valid_lft forever preferred_lft forever
```

## 2. Analyse de trames
### 🌞Analyse de trames
John
```
[antoine@john ~]$ sudo tcpdump
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
15:47:58.195543 IP localhost.localdomain.ssh > 10.3.1.0.51116: Flags [P.], seq 2813052836:2813052896, ack 2196922044, win 501, options [nop,nop,TS val 2276877256 ecr 3676946911], length 60
15:47:58.195637 IP localhost.localdomain.ssh > 10.3.1.0.51116: Flags [P.], seq 60:204, ack 1, win 501, options [nop,nop,TS val 2276877256 ecr 3676946911], length 144
15:47:58.195791 IP 10.3.1.0.51116 > localhost.localdomain.ssh: Flags [.], ack 60, win 501, options [nop,nop,TS val 3676946960 ecr 2276877256], length 0
15:47:58.195792 IP 10.3.1.0.51116 > localhost.localdomain.ssh: Flags [.], ack 204, win 501, options [nop,nop,TS val 3676946960 ecr 2276877256], length 0
15:47:58.195851 IP localhost.localdomain.ssh > 10.3.1.0.51116: Flags [P.], seq 204:240, ack 1, win 501, options [nop,nop,TS val 2276877256 ecr 3676946960], length 36
15:47:58.195884 IP localhost.localdomain.ssh > 10.3.1.0.51116: Flags [P.], seq 240:300, ack 1, win 501, options [nop,nop,TS val 2276877256 ecr 3676946960], length 60
15:47:58.195982 IP 10.3.1.0.51116 > localhost.localdomain.ssh: Flags [.], ack 240, win 501, options [nop,nop,TS val 3676946960 ecr 2276877256], length 0
15:47:58.195983 IP 10.3.1.0.51116 > localhost.localdomain.ssh: Flags [.], ack 300, win 501, options [nop,nop,TS val 3676946960 ecr 2276877256], length 0
```

# Routage
## 1. Mise en place du routage
### 🌞Ajouter les routes statiques nécessaires pour que john et marcel puissent se ping
Chez Marcel:
```
[antoine@marcel ~]$ ip route show
10.3.1.0/24 via 10.3.2.254 dev enp0s3 proto static metric 100 
10.3.2.0/24 dev enp0s3 proto kernel scope link src 10.3.2.12 metric 100 
```
Chez John:
```
[antoine@john ~]$ ip route show
10.3.1.0/24 dev enp0s3 proto kernel scope link src 10.3.1.11 metric 100 
10.3.2.0/24 via 10.3.1.254 dev enp0s3 proto static metric 100
```

Pings:
```
[antoine@marcel ~]$ ping 10.3.1.11
PING 10.3.1.11 (10.3.1.11) 56(84) bytes of data.
64 bytes from 10.3.1.11: icmp_seq=1 ttl=63 time=1.99 ms
64 bytes from 10.3.1.11: icmp_seq=2 ttl=63 time=2.03 ms
^C
--- 10.3.1.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 1.991/2.012/2.034/0.021 ms

```
```
[antoine@john ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=63 time=1.90 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=63 time=2.03 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=63 time=2.13 ms
^C
--- 10.3.2.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.901/2.020/2.132/0.094 ms
```
## 2. Analyse de trames
### 🌞Analyse des échanges ARP
Essayez de déduire les échanges ARP qui ont eu lieu lors du ping John vers Marcel:
- Échange ARP entre John et le routeur
- Échange ARP entre le routeur et Marcel

Sur notre routeur:
```
[antoine@localhost ~]$ sudo tcpdump not port 22
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
10:57:51.448156 ARP, Request who-has localhost.localdomain tell 10.3.2.254, length 46
10:57:51.448167 ARP, Reply localhost.localdomain is-at 08:00:27:46:42:2b (oui Unknown), length 28
10:57:51.448433 IP 10.3.1.11 > localhost.localdomain: ICMP echo request, id 5, seq 1, length 64
10:57:51.448464 IP localhost.localdomain > 10.3.1.11: ICMP echo reply, id 5, seq 1, length 64
10:57:52.450219 IP 10.3.1.11 > localhost.localdomain: ICMP echo request, id 5, seq 2, length 64
10:57:52.450326 IP localhost.localdomain > 10.3.1.11: ICMP echo reply, id 5, seq 2, length 64
10:57:53.452002 IP 10.3.1.11 > localhost.localdomain: ICMP echo request, id 5, seq 3, length 64
10:57:53.452115 IP localhost.localdomain > 10.3.1.11: ICMP echo reply, id 5, seq 3, length 64
10:57:56.553711 ARP, Request who-has 10.3.2.254 tell localhost.localdomain, length 28
10:57:56.554556 ARP, Reply 10.3.2.254 is-at 08:00:27:ca:bb:5c (oui Unknown), length 46
^C
10 packets captured
11 packets received by filter
0 packets dropped by kernel
```

| ordre | type trame | IP source | MAC source | IP destination | MAC destination
| :----: |:------:| :-----:| :-----:| :-----:| :-----:|
| 1 | Requête ARP | x | `marcel 08:00:27:46:42:2b`|x|Broadcast `FF:FF:FF:FF:FF`
| 2 | Réponse ARP | x | `routeur 08:00:27:ca:bb:5c`|x|`marcel 08:00:27:46:42:2b`
| 3 | Ping | 10.3.1.11 | `routeur 08:00:27:ca:bb:5c`|10.3.2.12|`marcel 08:00:27:46:42:2b`
| 4 | Pong | 10.3.2.12 | `marcel 08:00:27:46:42:2b`|10.3.1.11|`routeur 08:00:27:ca:bb:5c`

## 3. Accès internet
### 🌞Donnez un accès internet à vos machines - config routeur
Sur notre routeur:
```
[antoine@localhost ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:af:1e:c0 brd ff:ff:ff:ff:ff:ff
    inet 10.3.1.254/24 brd 10.3.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feaf:1ec0/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ca:bb:5c brd ff:ff:ff:ff:ff:ff
    inet 10.3.2.254/24 brd 10.3.2.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feca:bb5c/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:89:45:ff brd ff:ff:ff:ff:ff:ff
    inet 10.0.4.15/24 brd 10.0.4.255 scope global dynamic noprefixroute enp0s9
       valid_lft 86052sec preferred_lft 86052sec
    inet6 fe80::ec99:972e:b216:48a4/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

```
### 🌞Donnez un accès internet à vos machines - config clients
Vérification accès internet:
```
[antoine@localhost ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=63 time=68.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=63 time=69.7 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 68.393/69.060/69.727/0.667 ms
```

__Ajoutez une route par défaut à john et marcel:__

John:
```
[antoine@localhost ~]$ cat /etc/sysconfig/network
# Created by anaconda
GATEWAY=10.3.2.254
```
Marcel:
```
[antoine@localhost ~]$ cat /etc/sysconfig/network
# Created by anaconda
GATEWAY=10.3.1.254
```

__Vérification d'accès à internet:__

John:
```
[antoine@localhost ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=95.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=56.9 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 56.925/76.221/95.517/19.296 ms
```
Marcel:
```
[antoine@localhost ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=71.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=47.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=61 time=84.6 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 47.050/67.739/84.573/15.559 ms

```

__Donnez leur aussi l'adresse d'un serveur DNS qu'ils peuvent utiliser:__

Chez John et Marcel
```
[antoine@localhost ~]$ cat /etc/resolv.conf 
# Generated by NetworkManager
nameserver 8.8.8.8
```

```
[antoine@localhost ~]$ ping gitlab.com
PING gitlab.com (172.65.251.78) 56(84) bytes of data.
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=1 ttl=61 time=20.9 ms
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=2 ttl=61 time=117 ms
^C
--- gitlab.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 20.897/68.794/116.691/47.897 ms
```

### 🌞Analyse de trames
LAN1:
| ordre | type trame | IP source | MAC source | IP destination | MAC destination
| :----: |:------:| :-----:| :-----:| :-----:| :-----:|
| 1 | ping | 10.3.1.11 | `john 08:00:27:b6:a3:98`|10.3.2.12|`routeur 08:00:27:ca:bb:5c`
| 2 | pong | 10.3.2.12 | `marcel 08:00:27:46:42:2b`|10.3.1.11|`john 08:00:27:b6:a3:98`

LAN2:
| ordre | type trame | IP source | MAC source | IP destination | MAC destination
| :----: |:------:| :-----:| :-----:| :-----:| :-----:|
| 1 | ping | 10.3.2.254 | `routeur 08:00:27:ca:bb:5c`|10.3.2.12|`marcel 08:00:27:46:42:2b`
| 2 | pong | 10.3.2.12 | `marcel 08:00:27:46:42:2b`|10.3.2.254|`routeur 08:00:27:ca:bb:5c`