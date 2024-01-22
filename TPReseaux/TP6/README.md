# TP6 : Un LAN maîtrisé meo ?

## 0. Prérequis
## I. Setup routeur

### 🖥️ Machine john.tp6.b1
Preuve accès internet:
```
[antoine@john ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=14.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=14.6 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 14.307/14.430/14.553/0.123 ms
```

## II. Serveur DNS
## 1. Présentation
## 2. Setup
### 🌞 Dans le rendu, je veux
```
[antoine@dns var]$ sudo cat /etc/named.conf 
options {
        listen-on port 53 { 127.0.0.1; any;};
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost; any; };
        allow-query-cache { localhost; any; };

        recursion yes;

        dnssec-validation yes;

        managed-keys-directory "/var/named/dynamic";
        geoip-directory "/usr/share/GeoIP";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";

        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "tp6.b1" IN {
     type master;
     file "tp6.b1.db";
     allow-update { none; };
     allow-query {any; };
};

zone "1.4.10.in-addr.arpa" IN {
     type master;
     file "tp6.b1.rev";
     allow-update { none; };
     allow-query { any; };
};
```

```
[antoine@dns var]$ sudo cat /var/named/tp6.b1.db
$TTL 86400
@ IN SOA dns.tp6.b1. admin.tp6.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns.tp6.b1.

; Enregistrements DNS pour faire correspondre des noms à des IPs
dns       IN A 10.6.1.101
john      IN A 10.6.1.11
```

```
[antoine@dns var]$ sudo cat /var/named/tp6.b1.rev
$TTL 86400
@ IN SOA dns.tp6.b1. admin.tp6.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns.tp6.b1.

; Reverse lookup
101 IN PTR dns.tp6.b1.
11 IN PTR john.tp6.b1.
```

```
[antoine@dns var]$ sudo systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: disabled)
     Active: active (running) since Fri 2023-11-17 15:57:35 CET; 3min 24s ago
    Process: 2064 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=0/SUCCESS)
    Process: 2066 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} $OPTIONS (code=exited, status=0/SUCCESS)
   Main PID: 2068 (named)
      Tasks: 5 (limit: 4673)
     Memory: 17.9M
        CPU: 57ms
     CGroup: /system.slice/named.service
             └─2068 /usr/sbin/named -u named -c /etc/named.conf

Nov 17 15:57:35 dns.tp6.b1 named[2068]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa/IN: loaded serial 0
Nov 17 15:57:35 dns.tp6.b1 named[2068]: zone 1.0.0.127.in-addr.arpa/IN: loaded serial 0
Nov 17 15:57:35 dns.tp6.b1 named[2068]: zone localhost.localdomain/IN: loaded serial 0
Nov 17 15:57:35 dns.tp6.b1 named[2068]: zone localhost/IN: loaded serial 0
Nov 17 15:57:35 dns.tp6.b1 named[2068]: zone tp6.b1/IN: loaded serial 2019061800
Nov 17 15:57:35 dns.tp6.b1 named[2068]: all zones loaded
Nov 17 15:57:35 dns.tp6.b1 systemd[1]: Started Berkeley Internet Name Domain (DNS).
Nov 17 15:57:35 dns.tp6.b1 named[2068]: running
Nov 17 15:57:35 dns.tp6.b1 named[2068]: managed-keys-zone: Key 20326 for zone . is now trusted (acceptance timer complete)
Nov 17 15:57:35 dns.tp6.b1 named[2068]: resolver priming query complete
```

```
[antoine@dns var]$ sudo ss -alnptu | grep named
udp   UNCONN 0      0         10.6.1.101:53        0.0.0.0:*    users:(("named",pid=2136,fd=19))
udp   UNCONN 0      0          127.0.0.1:53        0.0.0.0:*    users:(("named",pid=2136,fd=16))
udp   UNCONN 0      0              [::1]:53           [::]:*    users:(("named",pid=2136,fd=22))
tcp   LISTEN 0      4096       127.0.0.1:953       0.0.0.0:*    users:(("named",pid=2136,fd=24))
tcp   LISTEN 0      10         127.0.0.1:53        0.0.0.0:*    users:(("named",pid=2136,fd=17))
tcp   LISTEN 0      10        10.6.1.101:53        0.0.0.0:*    users:(("named",pid=2136,fd=21))
tcp   LISTEN 0      4096           [::1]:953          [::]:*    users:(("named",pid=2136,fd=25))
tcp   LISTEN 0      10             [::1]:53           [::]:*    users:(("named",pid=2136,fd=23))
```

### 🌞 Ouvrez le bon port dans le firewall
```
[antoine@dns var]$ sudo firewall-cmd --add-port=53/tcp --permanent
success
```

## 3. Test
### 🌞 Sur la machine john.tp6.b1
```
[antoine@john ~]$ dig john.tp6.b1

; <<>> DiG 9.16.23-RH <<>> john.tp6.b1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16614
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: fd723a36adca1c2c01000000655787b592a489ab1705b23f (good)
;; QUESTION SECTION:
;john.tp6.b1.                   IN      A

;; ANSWER SECTION:
john.tp6.b1.            86400   IN      A       10.6.1.11

;; Query time: 13 msec
;; SERVER: 10.6.1.101#53(10.6.1.101)
;; WHEN: Fri Nov 17 16:33:09 CET 2023
;; MSG SIZE  rcvd: 84


[antoine@john ~]$ dig dns.tp6.b1

; <<>> DiG 9.16.23-RH <<>> dns.tp6.b1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54427
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 66495d0abdef124b01000000655787bd997effbcbc3c46b8 (good)
;; QUESTION SECTION:
;dns.tp6.b1.                    IN      A

;; ANSWER SECTION:
dns.tp6.b1.             86400   IN      A       10.6.1.101

;; Query time: 12 msec
;; SERVER: 10.6.1.101#53(10.6.1.101)
;; WHEN: Fri Nov 17 16:33:17 CET 2023
;; MSG SIZE  rcvd: 83


[antoine@john ~]$ dig www.ynov.com

; <<>> DiG 9.16.23-RH <<>> www.ynov.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46710
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8a6a035119c3b40001000000655787dd43b26ae908d26ad8 (good)
;; QUESTION SECTION:
;www.ynov.com.                  IN      A

;; ANSWER SECTION:
www.ynov.com.           300     IN      A       172.67.74.226
www.ynov.com.           300     IN      A       104.26.11.233
www.ynov.com.           300     IN      A       104.26.10.233

;; Query time: 162 msec
;; SERVER: 10.6.1.101#53(10.6.1.101)
;; WHEN: Fri Nov 17 16:33:49 CET 2023
;; MSG SIZE  rcvd: 117
```

### 🌞 Sur votre PC
Voir tp6_dns.pcapng

## III. Serveur DHCP

### 🌞 Installer un serveur DHCP
```
[antoine@dhcp ~]$ sudo cat /etc/dhcp/dhcpd.conf
option domain-name     "srv.world";
option domain-name-servers     dns.tp6.b1;
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 10.6.1.0 netmask 255.255.255.0 {
    range dynamic-bootp 10.6.1.13 10.6.1.37;
    option broadcast-address 10.6.1.255;
    option routers 10.6.1.254;
}
```

### 🌞 Test avec john.tp6.b1
**prouvez-que vous avez une IP dans la bonne range**

**prouvez que vous avez votre routeur configuré automatiquement comme passerelle**
```
[antoine@john ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:5f:82:bc brd ff:ff:ff:ff:ff:ff
    inet 10.6.1.13/24 brd 10.6.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 404sec preferred_lft 404sec
    inet6 fe80::a00:27ff:fe5f:82bc/64 scope link 
       valid_lft forever preferred_lft forever
```

**prouvez que vous avez votre serveur DNS automatiquement configuré**
```
[antoine@john ~]$ cat /etc/resolv.conf 
# Generated by NetworkManager
search srv.world tp6.b1
nameserver 10.6.1.101
```

**prouvez que vous avez un accès internet**
```
[antoine@john ~]$ ping www.ynov.com
PING www.ynov.com (172.67.74.226) 56(84) bytes of data.
64 bytes from 172.67.74.226 (172.67.74.226): icmp_seq=1 ttl=61 time=18.4 ms
^C
--- www.ynov.com ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 18.376/18.376/18.376/0.000 ms
```

### 🌞 Requête web avec john.tp6.b1
`[antoine@john ~]$ curl www.ynov.com`

Voir tp6_web.pcapng