# Partie 1 : Files and users
# I. Fichiers
## 1. Find me
### 🌞 Trouver le chemin vers le répertoire personnel de votre utilisateur
`/home/aube/`
### 🌞 Trouver le chemin du fichier de logs SSH
`cat /var/log/secure`
### 🌞 Trouver le chemin du fichier de configuration du serveur SSH
`/etc/ssh/ssh_config`

# II. Users
## 1. Nouveau user
### 🌞 Créer un nouvel utilisateur
```
[antoine@localhost home]$ sudo useradd -m -d /home/papier_alu marmotte
[antoine@localhost home]$ sudo passwd marmotte
```
## 2. Infos enregistrées par le système
### 🌞 Prouver que cet utilisateur a été créé
```
[antoine@localhost home]$ cat /etc/passwd | grep marmotte
marmotte:x:1001:1001::/home/papier_alu:/bin/bash
```
### 🌞 Déterminer le hash du password de l'utilisateur marmotte
```
[antoine@localhost home]$ cat /etc/shadow | grep marmotte
marmotte:$6$iRJARuuCS1Rp3JFb$GI65OUlYD8ZkBXGKkMVluCb4XP5757LGHIL31wsm3mPoCIVtQq5MOnV4e/7FrXe7JexCt5LPr16J86iAV1U1//:19744:0:99999:7:::
```
## 3. Hint sur la ligne de commande
## 4. Connexion sur le nouvel utilisateur
### 🌞 Tapez une commande pour vous déconnecter : fermer votre session utilisateur
```
[antoine@localhost home]$ exit
```
```
aube@MakOS:~$ ssh marmotte@192.168.56.101
marmotte@192.168.56.101's password: 
[marmotte@localhost ~]$ ls
[marmotte@localhost ~]$ ls -al
total 12
drwx------. 2 marmotte marmotte  62 Jan 22 15:30 .
drwxr-xr-x. 4 root     root      39 Jan 22 15:30 ..
-rw-r--r--. 1 marmotte marmotte  18 Jan 23  2023 .bash_logout
-rw-r--r--. 1 marmotte marmotte 141 Jan 23  2023 .bash_profile
-rw-r--r--. 1 marmotte marmotte 492 Jan 23  2023 .bashrc
```


# Partie 2 : Programmes et paquets
# I. Programmes et processus
## 1. Run then kill
### 🌞 Lancer un processus sleep
```
[antoine@localhost ~]$ ps aux | grep sleep
antoine       13856  0.0  0.0   5464   924 pts/1    S+   15:52   0:00 sleep 1000
```
### 🌞 Terminez le processus sleep depuis le deuxième terminal
```
[antoine@localhost ~]$ kill 13856
```
## 2. Tâche de fond
### 
🌞 Lancer un nouveau processus sleep, mais en tâche de fond
```
[antoine@localhost ~]$ sleep 1000&
[1] 14177
```
### 🌞 Visualisez la commande en tâche de fond
```
[antoine@localhost ~]$ jobs -l
[1]+ 14177 Running                 sleep 1000 &
```
## 3. Find paths
### 🌞 Trouver le chemin où est stocké le programme sleep
```
[antoine@localhost ~]$ which sleep   
/usr/bin/sleep
[antoine@localhost ~]$ ls -al /usr/bin | grep sleep
-rwxr-xr-x  1 root root        43888 Sep 20  2022 sleep
```
### 🌞 Tant qu'on est à chercher des chemins : trouver les chemins vers tous les fichiers qui s'appellent .bashrc
```
[antoine@localhost ~]$ sudo find / -name .bashrc
[sudo] password for antoine: 
/etc/skel/.bashrc
/root/.bashrc
/home/antoine/.bashrc
/home/papier_alu/.bashrc
```
## 4. La variable PATH
### 🌞 Vérifier que
```
[antoine@localhost ~]$ echo $PATH
/home/antoine/.local/bin:/home/antoine/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
[antoine@localhost ~]$ which sleep
/usr/bin/sleep
[antoine@localhost ~]$ which ssh
/usr/bin/ssh
[antoine@localhost ~]$ which ping
/usr/bin/ping
```
# II. Paquets
### 🌞 Installer le paquet git
```
[antoine@localhost ~]$ sudo dnf install git
```
### 🌞 Utiliser une commande pour lancer git
```
[antoine@localhost ~]$ which git
/usr/bin/git
```
### 🌞 Installer le paquet nginx
```
[antoine@localhost ~]$ sudo dnf install nginx
```
### 🌞 Déterminer
- le chemin vers le dossier de logs de NGINX:
    `/var/log/nginx`

- le chemin vers le dossier qui contient la configuration de NGINX
    `/etc/nginx`

### 🌞 Mais aussi déterminer...
```
[antoine@localhost yum.repos.d]$ cd /etc/yum.repos.d/
[antoine@localhost yum.repos.d]$ grep -nri http
```


# Partie 3 : Poupée russe
### 🌞 Récupérer le fichier meow
```
[antoine@localhost ~]$ wget https://gitlab.com/it4lik/b1-linux-2023/-/raw/master/tp/2/meow
```
### 🌞 Trouver le dossier dawa/
```
[antoine@localhost ~]$ ls -al | grep dawa
drwxr-xr-x. 52 antoine antoine      4096 Jan 21 14:45 dawa
```

### 🌞 Dans le dossier dawa/, déterminer le chemin vers
- le seul fichier de 15Mo
```
[antoine@localhost ~]$ find dawa/ -type f -size 15M
dawa/folder31/19/file39
```
- le seul fichier qui ne contient que des 7
```
[antoine@localhost ~]$ grep -rl '^7*$' dawa/
dawa/folder31/19/file39
dawa/folder43/38/file41
[antoine@localhost ~]$ cat dawa/folder43/38/file41
77777777777
```
- le seul fichier qui est nommé cookie
```
[antoine@localhost ~]$ find dawa/ -type f -name "cookie"
dawa/folder14/25/cookie
```
- le seul fichier caché (un fichier caché c'est juste un fichier dont le nom commence par un .)
```
[antoine@localhost ~]$ find dawa/ -type f -name ".*"
dawa/folder32/14/.hidden_file
```
- le seul fichier qui date de 2014
```
[antoine@localhost ~]$ find dawa/ -type f -newermt 2014-01-01 ! -newermt 2015-01-01
dawa/folder36/40/file43
```
- le seul fichier qui a 5 dossiers-parents
```
[antoine@localhost ~]$ find dawa/ -mindepth 5 -maxdepth 6 -type f
dawa/folder37/45/23/43/54/file43
```