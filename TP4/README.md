# DHCP
## I. DHCP Client
### 🌞 Déterminer
```
aube@MakOS:~$ cat /var/lib/dhcp/dhclient.leases
lease {
  interface "wlo1";
  fixed-address 192.168.21.10;
  option subnet-mask 255.255.255.0;
  option dhcp-lease-time 3599;
  option routers 192.168.21.117;
  option dhcp-message-type 5;
  option dhcp-server-identifier 192.168.21.117;
  option domain-name-servers 192.168.21.117;
  option dhcp-renewal-time 1799;
  option dhcp-rebinding-time 3149;
  option broadcast-address 192.168.21.255;
  option host-name "MakOS";
  option vendor-encapsulated-options "ANDROID_METERED";
  renew 4 2023/10/19 14:52:06;
  rebind 4 2023/10/19 14:52:06;
  expire 4 2023/10/19 14:52:06;
}
lease {
  interface "wlo1";
  fixed-address 10.33.72.69;
  option subnet-mask 255.255.240.0;
  option routers 10.33.79.254;
  option dhcp-lease-time 86400;
  option dhcp-message-type 5;
  option domain-name-servers 8.8.8.8,1.1.1.1;
  option dhcp-server-identifier 10.33.79.254;
  renew 5 2023/10/20 02:17:57;
  rebind 5 2023/10/20 11:52:14;
  expire 5 2023/10/20 14:52:14;
}
```

l'adresse du serveur DHCP: `192.168.21.117`

l'heure exacte à laquelle vous avez obtenu votre bail DHCP: `2023/10/19 14:52:06`

l'heure exacte à laquelle il va expirer: `2023/10/19 14:52:06`

## 🌞 Capturer un échange DHCP
```
sudo dhclient -r
sudo dhclient
```

## 🌞 Analyser la capture Wireshark
La deuxième trame, Offer
Voir `tp4_dhcp_client.pcapng`

## II. Serveur DHCP
## 🌞 Preuve de mise en place

depuis dhcp.tp4.b1
```
[antoine@dhcp.tp4.b1 ~]$ ping google.com
PING google.com (172.217.20.174) 56(84) bytes of data.
64 bytes from waw02s07-in-f14.1e100.net (172.217.20.174): icmp_seq=1 ttl=61 time=19.4 ms
64 bytes from par10s49-in-f14.1e100.net (172.217.20.174): icmp_seq=2 ttl=61 time=18.4 ms
^C
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 18.377/18.889/19.402/0.512 ms
```

depuis node2.tp4.b1
```
[antoine@node2.tp4.b1 ~]$ ping google.com
PING google.com (172.217.20.174) 56(84) bytes of data.
64 bytes from waw02s07-in-f14.1e100.net (172.217.20.174): icmp_seq=1 ttl=61 time=18.5 ms
64 bytes from par10s49-in-f14.1e100.net (172.217.20.174): icmp_seq=2 ttl=61 time=22.2 ms
^C
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 18.484/20.327/22.170/1.843 ms
```

```
[antoine@node2.tp4.b1 ~]$ traceroute 172.217.20.174
traceroute to 172.217.20.174 (172.217.20.174), 30 hops max, 60 byte packets
 1  _gateway (10.4.1.254)  1.256 ms  1.145 ms  1.037 ms
 2  10.0.3.2 (10.0.3.2)  1.147 ms  1.041 ms  1.506 ms
 3  * * *
 4  145.117.7.195.rev.sfr.net (195.7.117.145)  29.749 ms  29.622 ms  29.303 ms
 5  * * *
 6  196.224.65.86.rev.sfr.net (86.65.224.196)  28.526 ms  5.947 ms  5.834 ms
 7  164.147.6.194.rev.sfr.net (194.6.147.164)  14.397 ms  14.301 ms  13.852 ms
 8  * * *
 9  108.170.252.242 (108.170.252.242)  19.439 ms 74.125.244.211 (74.125.244.211)  19.338 ms 74.125.244.232 (74.125.244.232)  26.156 ms
10  216.239.35.201 (216.239.35.201)  18.589 ms * *
11  209.85.251.58 (209.85.251.58)  16.964 ms 209.85.253.216 (209.85.253.216)  18.102 ms 108.170.235.98 (108.170.235.98)  17.978 ms
12  108.170.244.225 (108.170.244.225)  19.404 ms 108.170.244.161 (108.170.244.161)  18.202 ms  18.079 ms
13  142.251.253.35 (142.251.253.35)  21.468 ms  21.343 ms 142.251.253.33 (142.251.253.33)  16.432 ms
14  waw02s07-in-f174.1e100.net (172.217.20.174)  18.536 ms  18.412 ms  18.671 ms
```

## 4. Serveur DHCP
### 🌞 Rendu
`dnf -y install dhcp-server`

`sudo nano /etc/dhcp/dhcpd.conf`
```
option domain-name     "srv.world";
option domain-name-servers     dlp.srv.world;
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 10.4.1.0 netmask 255.255.255.0 {
    range dynamic-bootp 10.4.1.200 10.4.1.254;
    option broadcast-address 10.4.1.255;
    option routers 10.4.1.254;
}
```
`systemctl enable --now dhcpd`

`firewall-cmd --add-service=dhcp`

`firewall-cmd --runtime-to-permanent`

```
[antoine@dhcp.tp4.b1 ~]$ systemctl status dhcpd | cat
● dhcpd.service - DHCPv4 Server Daemon
     Loaded: loaded (/usr/lib/systemd/system/dhcpd.service; enabled; preset: disabled)
     Active: active (running) since Fri 2023-10-27 15:41:52 CEST; 4min 4s ago
       Docs: man:dhcpd(8)
             man:dhcpd.conf(5)
   Main PID: 2114 (dhcpd)
     Status: "Dispatching packets..."
      Tasks: 1 (limit: 4673)
     Memory: 5.2M
        CPU: 9ms
     CGroup: /system.slice/dhcpd.service
             └─2114 /usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid

Oct 27 15:41:52 localhost.localdomain dhcpd[2114]: Sending on   LPF/enp0s3/08:00:27:c6:9c:80/10.4.1.0/24
Oct 27 15:41:52 localhost.localdomain dhcpd[2114]: Sending on   Socket/fallback/fallback-net
Oct 27 15:41:52 localhost.localdomain dhcpd[2114]: Server starting service.
Oct 27 15:41:52 localhost.localdomain systemd[1]: Started DHCPv4 Server Daemon.
Oct 27 15:42:10 localhost.localdomain dhcpd[2114]: DHCPREQUEST for 192.168.56.101 from 08:00:27:4e:01:23 via enp0s3: wrong network.
Oct 27 15:42:10 localhost.localdomain dhcpd[2114]: DHCPNAK on 192.168.56.101 to 08:00:27:4e:01:23 via enp0s3
Oct 27 15:42:10 localhost.localdomain dhcpd[2114]: DHCPDISCOVER from 08:00:27:4e:01:23 via enp0s3
Oct 27 15:42:12 localhost.localdomain dhcpd[2114]: DHCPOFFER on 10.4.1.200 to 08:00:27:4e:01:23 via enp0s3
Oct 27 15:42:12 localhost.localdomain dhcpd[2114]: DHCPREQUEST for 10.4.1.200 (10.4.1.253) from 08:00:27:4e:01:23 via enp0s3
Oct 27 15:42:12 localhost.localdomain dhcpd[2114]: DHCPACK on 10.4.1.200 to 08:00:27:4e:01:23 via enp0s3
```

```
[antoine@dhcp.tp4.b1 ~]$ sudo cat /etc/dhcp/dhcpd.conf
option domain-name     "srv.world";
option domain-name-servers     dlp.srv.world;
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 10.4.1.0 netmask 255.255.255.0 {
    range dynamic-bootp 10.4.1.137 10.4.1.237;
    option broadcast-address 10.4.1.255;
    option routers 10.4.1.254;
}
```

## 5. Client DHCP
### 🌞 Test !
### 🌞 Prouvez que
node1.tp4.b1 a bien récupéré une IP dynamiquement:
```
Oct 29 12:29:34 localhost.localdomain dhcpd[780]: DHCPDISCOVER from 08:00:27:4e:01:23 via enp0s3
Oct 29 12:29:34 localhost.localdomain dhcpd[780]: DHCPOFFER on 10.4.1.137 to 08:00:27:4e:01:23 via enp0s3
Oct 29 12:29:34 localhost.localdomain dhcpd[780]: DHCPREQUEST for 10.4.1.137 (10.4.1.253) from 08:00:27:4e:01:23 via enp0s3
Oct 29 12:29:34 localhost.localdomain dhcpd[780]: DHCPACK on 10.4.1.137 to 08:00:27:4e:01:23 via enp0s3
```
```
[antoine@node1.tp4.b1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:4e:01:23 brd ff:ff:ff:ff:ff:ff
    inet 10.4.1.137/24 brd 10.4.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 545sec preferred_lft 545sec
    inet6 fe80::9f76:9531:8d64:6e7f/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

node1.tp4.b1 a enregistré un bail DHCP:
```
[root@node1.tp4.b1 NetworkManager]# cat /var/lib/dhclient/dhclient.leases 
lease {
  interface "enp0s3";
  fixed-address 10.4.1.137;
  option subnet-mask 255.255.255.0;
  option routers 10.4.1.254;
  option dhcp-lease-time 600;
  option dhcp-message-type 5;
  option domain-name-servers 180.43.145.38;
  option dhcp-server-identifier 10.4.1.253;
  option broadcast-address 10.4.1.255;
  option domain-name "srv.world";
  renew 5 2023/10/27 14:18:22;
  rebind 5 2023/10/27 14:18:22;
  expire 5 2023/10/27 14:18:22;
}
```
déterminer la date exacte de création du bail:
- `2023/10/27 14:18:22`
  
déterminer la date exacte d'expiration:
- `2023/10/27 14:18:22`
  
déterminer l'adresse IP du serveur DHCP (depuis node1.tp4.b1 : il a enregistré l'adresse IP du serveur DHCP):
- `10.4.1.253`

vous pouvez ping router.tp4.b1 et node2.tp4.b1 grâce à cette nouvelle IP récupérée
```
[antoine@node1.tp4.b1 ~]$ ping 10.4.1.254
PING 10.4.1.254 (10.4.1.254) 56(84) bytes of data.
64 bytes from 10.4.1.254: icmp_seq=1 ttl=64 time=1.15 ms
64 bytes from 10.4.1.254: icmp_seq=2 ttl=64 time=1.02 ms
^C
--- 10.4.1.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 1.023/1.088/1.153/0.065 ms

[antoine@node1.tp4.b1 ~]$ ping 10.4.1.12
PING 10.4.1.12 (10.4.1.12) 56(84) bytes of data.
64 bytes from 10.4.1.12: icmp_seq=1 ttl=64 time=1.74 ms
64 bytes from 10.4.1.12: icmp_seq=2 ttl=64 time=0.986 ms
^C
--- 10.4.1.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.986/1.361/1.737/0.375 ms
```

## 🌞 Bail DHCP serveur

```
[antoine@dhcp.tp4.b1 ~]$ cat /var/lib/dhcpd/dhcpd.leases
# The format of this file is documented in the dhcpd.leases(5) manual page.
# This lease file was written by isc-dhcp-4.4.2b1

# authoring-byte-order entry is generated, DO NOT DELETE
authoring-byte-order little-endian;

server-duid "\000\001\000\001,\316\206Z\010\000'\306\234\200";

lease 10.4.1.137 {
  starts 0 2023/10/29 11:39:06;
  ends 0 2023/10/29 11:49:06;
  cltt 0 2023/10/29 11:39:06;
  binding state active;
  next binding state free;
  rewind binding state free;
  hardware ethernet 08:00:27:4e:01:23;
  uid "\001\010\000'N\001#";
}
```

## 6. Options DHCP
## 🌞 Nouvelle conf !
```
[root@dhcp.tp4.b1 antoine]# cat /etc/dhcp/dhcpd.conf 
option domain-name     "srv.world";
option domain-name-servers     1.1.1.1;
default-lease-time 21600;
max-lease-time 21600;
authoritative;
subnet 10.4.1.0 netmask 255.255.255.0 {
    range dynamic-bootp 10.4.1.137 10.4.1.237;
    option broadcast-address 10.4.1.255;
    option routers 10.4.1.254;
}
```

## 🌞 Test !
```
[antoine@node1.tp4.b1 ~]$ sudo dhclient -r
Removed stale PID file

[antoine@node1.tp4.b1 ~]$ sudo dhclient

[antoine@node1.tp4.b1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:4e:01:23 brd ff:ff:ff:ff:ff:ff
    inet 10.4.1.137/24 brd 10.4.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 411sec preferred_lft 411sec
    inet 10.4.1.138/24 brd 10.4.1.255 scope global secondary dynamic enp0s3
       valid_lft 21660sec preferred_lft 21660sec
    inet6 fe80::9f76:9531:8d64:6e7f/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

```

prouvez que vous avez enregistré l'adresse d'un serveur DNS:
```
[antoine@node1.tp4.b1 ~]$ cat /etc/resolv.conf 
; generated by /usr/sbin/dhclient-script
search srv.world
nameserver 1.1.1.1
```

prouvez que vous avez une nouvelle route par défaut qui a été récupérée dynamiquement:
```
[antoine@node1.tp4.b1 ~]$ ip route show
default via 10.4.1.254 dev enp0s3 
default via 10.4.1.254 dev enp0s3 proto dhcp src 10.4.1.137 metric 100 
10.4.1.0/24 dev enp0s3 proto kernel scope link src 10.4.1.137 metric 100 
```

prouvez que la durée de votre bail DHCP est bien de 6 heures:
```
[root@node1.tp4.b1 antoine]# cat /var/lib/dhclient/dhclient.leases
lease {
  interface "enp0s3";
  fixed-address 10.4.1.138;
  option subnet-mask 255.255.255.0;
  option routers 10.4.1.254;
  option dhcp-lease-time 21600;
  option dhcp-message-type 5;
  option domain-name-servers 1.1.1.1;
  option dhcp-server-identifier 10.4.1.253;
  option broadcast-address 10.4.1.255;
  option domain-name "srv.world";
  renew 0 2023/10/29 14:32:53;
  rebind 0 2023/10/29 17:02:12;
  expire 0 2023/10/29 17:47:12; 🌞
}
```

prouvez que vous avez internet:
```
[root@node1.tp4.b1 antoine]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=22.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=22.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=61 time=21.9 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 21.896/22.260/22.620/0.295 ms
```

## 🌞 Capture Wireshark