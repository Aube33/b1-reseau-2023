#!/bin/bash

#=== VERIF DU LIEN ===
if [[ $# -eq 0 ]]; then
    echo "Aucun lien youtube trouvé !"
    exit 1
fi

#=== CONSTANT ===
DOWNLOAD_FOLDER_NAME="downloads"
LOG_FOLDER_PATH="/var/log/yt"
LOG_DOWNLOAD_FILE_NAME="download.log"
LOG_DESCRIPTION_FILE_NAME="description"

localDirectory=$(dirname $(realpath "$0"))
downloadDirectory="${localDirectory}/${DOWNLOAD_FOLDER_NAME}"

#=== RÉCUPÉRATION DE LA VIDÉO ===
videoName=$(youtube-dl --skip-download --get-title --no-warnings $1)
videoDescription=$(youtube-dl --skip-download --get-description --no-warnings $1)

futureVideoDirectory="${downloadDirectory}/${videoName}"
mkdir -p "${futureVideoDirectory}"
echo $videoDescription > "${futureVideoDirectory}/${LOG_DESCRIPTION_FILE_NAME}"

youtube-dl -f mp4 -o "${futureVideoDirectory}/%(title)s-%(id)s.%(ext)s" --no-warnings $1 > /dev/null

#=== AFFICHAGE DES MESSAGES ===
echo "Video ${1} was downloaded."
echo "File path : ${futureVideoDirectory}"

#=== AJOUT AUX LOGS ===
if [ ! -d "${LOG_FOLDER_PATH}" ]; then
    exit
fi

currentDate=$(date +"%y/%m/%d %H:%M:%S")
echo "[${currentDate}] Video ${1} was downloaded. File path : ${futureVideoDirectory}" >> "${LOG_FOLDER_PATH}/${LOG_DOWNLOAD_FILE_NAME}"