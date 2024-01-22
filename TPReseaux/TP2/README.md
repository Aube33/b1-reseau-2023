# I. Setup IP
### 🌞 Mettez en place une configuration réseau fonctionnelle entre les deux machines

IPs:
- 192.168.1.1/30
- 192.168.1.2/30

Adresse réseau:
- 192.168.1.0
  
Adresse Broadcast:
- 192.168.1.3

Commande utilisée:
```
sudo ip addr add 192.168.1.1/30 dev enp3s0
```

### 🌞 Prouvez que la connexion est fonctionnelle entre les deux machines
```
aube@MakOS:~$ ping -I enp3s0 192.168.1.2
PING 192.168.1.2 (192.168.1.2) from 192.168.1.1 enp3s0: 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=128 time=6.01 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=128 time=2.95 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=128 time=4.01 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=128 time=2.92 ms
^C
--- 192.168.1.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 2.923/3.973/6.010/1.254 ms
```

### 🌞 Wireshark it

Voir fichier pings.pcap

# II. ARP my bro

### 🌞 Check the ARP table
```
aube@MakOS:~$ arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.1.2              ether   bc:ec:a0:11:ad:7b   C                     enp3s0
```
MAC de mon binôme: `bc:ec:a0:11:ad:7b`

```
aube@MakOS:~$ arp
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.1.2              ether   bc:ec:a0:11:ad:7b   C                     enp3s0
_gateway                 ether   7c:5a:1c:d3:d8:76   C                     wlo1
```
MAC de mon gateway: `7c:5a:1c:d3:d8:76`

### 🌞 Manipuler la table ARP

Pour clear la table ARP: `sudo ip neigh flush all`

```
aube@MakOS:~$ arp
```
Cette commande ne retourne aucun résultat, donc le clear a 

### 🌞 Wireshark it

Voir fichier arp.pcap

# III. DHCP

Voir fichier dhcp.pcap

- 1: `10.33.72.69`
- 2: `10.33.72.254`
- 3: `1.1.1.1`