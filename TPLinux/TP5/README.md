# TP 5 : We do a little scripting
### Partie 1 : Script carte d'identité

#### 🌞 Vous fournirez dans le compte-rendu Markdown
```
Machine name : MakOS
OS Debian GNU/Linux and kernel version is #1 SMP PREEMPT_DYNAMIC Debian 6.1.69-1 (2023-12-30)
IP : 10.33.49.221 
RAM : 15Gi memory available on 8.5Gi total memory
Disk : 5.6G space left
Top 5 processes by RAM usage :
 - 2166
 - 2411
 - 1619
 - 1508
 - 3031
Listening ports :
udp 3535 : avahi-daemon
udp 99194 : avahi-daemon
udp 136 : cups-browsed
tcp 136 : cupsd
tcp 08 : nginx
tcp 3345 : postgres
PATH directories :
 - /usr/local/sbin
 - /usr/local/bin
 - /usr/sbin
 - /usr/bin
 - /sbin
 - /bin
Here is your random cat (jpg file) : https://cdn2.thecatapi.com/images/ase.jpg
```

## II. Script youtube-dl
### 1. Premier script youtube-dl
#### 🌞 Vous fournirez dans le compte-rendu, en plus du fichier, un exemple d'exécution avec une sortie
```
aube@MakOS:~/Desktop/Ynov/CoursLeo/b1-reseau-2023-tp1/TPLinux/TP5/srv$ ./yt/yt.sh https://www.youtube.com/watch?v=fn3KWM1kuAw
Video https://www.youtube.com/watch?v=fn3KWM1kuAw was downloaded.
File path : /home/aube/Desktop/Ynov/CoursLeo/b1-reseau-2023-tp1/TPLinux/TP5/srv/yt/downloads/Do You Love Me?
```

### 2. MAKE IT A SERVICE
#### 🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

```
aube@MakOS:~$ systemctl status yt
○ yt.service - Service permettant de télécharger les vidéos youtubes listées dans le fichier toDownload
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; preset: enabled)
     Active: inactive (dead)
TriggeredBy: ● yt.timer
```

```
aube@MakOS:~/Desktop/Ynov/CoursLeo/b1-reseau-2023-tp1/TPLinux/TP5/srv/yt$ sudo journalctl -xe -u yt -f 
Mar 04 17:03:01 MakOS systemd[1]: Started yt.service - Service permettant de télécharger les vidéos youtubes listées dans le fichier toDownload.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░ 
░░ A start job for unit yt.service has finished successfully.
░░ 
░░ The job identifier is 6064.
Mar 04 17:03:15 MakOS yt-v2.sh[29848]: Video https://www.youtube.com/watch?v=RbkmGDaH0xc was downloaded.
Mar 04 17:03:15 MakOS yt-v2.sh[29848]: File path : /srv/yt/downloads/Je réponds aux questions !!
Mar 04 17:03:15 MakOS systemd[1]: yt.service: Deactivated successfully.
░░ Subject: Unit succeeded
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░ 
░░ The unit yt.service has successfully entered the 'dead' state.
```