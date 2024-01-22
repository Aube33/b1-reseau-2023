# TP1 : Casser avant de construire
# I. Setup
OS utilisé: Rocky Linux
# II. Casser 
## 1. Objectif
## 2. Fichier
### 🌞 Supprimer des fichiers
`rm -r /bin/sh && rm -r /bin/bash`

## 3. Utilisateurs
### 🌞 Mots de passe
Dans `/etc/passwd`
On cherche root et notre utilisateur et on rajoute une lettre dans le mot de passe hash pour rendre celui-ci inutilisable
### 🌞 Another way ?
On enlève chaque fin de ligne de `/etc/passwd` pour chaque utilisateur par `sleep`. En gros on remplace leur commande d'exécution du shell.

## 4. Disques
### 🌞 Effacer le contenu du disque dur
`dd if=/dev/zero of=/dev/sda bs=1M`

## 5. Malware
### 🌞 Reboot automatique
`nano /etc/bashrc`
Rajout de la ligne `sudo reboot` au début

## 6. You own way
### 🌞 Trouvez 4 autres façons de détuire la machine
- `rm /boot/loader/entries/*` pour faire oublier les noyaux disponibles au bootloader
- `rm -r /boot/grub2` pour atterir sur grub-rescue au démarrage
- `rm /bin/login` pour supprimer le programme de login
- `cat /dev/urandom > /dev/sda` écrire des données random sur notre disque
