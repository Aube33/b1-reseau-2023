#!/bin/bash

#=== CONSTANT ===
DOWNLOAD_FOLDER_NAME="downloads"
LOG_FOLDER_PATH="/var/log/yt"
LOG_DOWNLOAD_FILE_NAME="download.log"
LOG_DESCRIPTION_FILE_NAME="description"

TO_DOWNLOAD_LIST_FILE_NAME="toDownload"

localDirectory=$(dirname $(realpath "$0"))
downloadDirectory="${localDirectory}/${DOWNLOAD_FOLDER_NAME}"

regex="^(https\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/watch\?v=.+$"

#=== VERIF SI LA LISTE À TÉLÉCHARGER EXISTE ===
if [ ! -f "${localDirectory}/${TO_DOWNLOAD_LIST_FILE_NAME}" ]; then
    echo "Le fichier ${TO_DOWNLOAD_LIST_FILE_NAME} n'existe pas."
    touch "${localDirectory}/${TO_DOWNLOAD_LIST_FILE_NAME}"
    exit 1
fi


#=== LECTURE DE LA LISTE ===
while read line; do
    sed -i '1d' "${localDirectory}/${TO_DOWNLOAD_LIST_FILE_NAME}"

    if [[ $line =~ $regex ]]; then
        #=== RÉCUPÉRATION DE LA VIDÉO ===
        videoName=$(youtube-dl --skip-download --get-title --no-warnings $line)
        videoDescription=$(youtube-dl --skip-download --get-description --no-warnings $line)

        futureVideoDirectory="${downloadDirectory}/${videoName}"
        mkdir -p "${futureVideoDirectory}"
        echo $videoDescription > "${futureVideoDirectory}/${LOG_DESCRIPTION_FILE_NAME}"

        youtube-dl -f mp4 -o "${futureVideoDirectory}/%(title)s-%(id)s.%(ext)s" --no-warnings $line > /dev/null

        #=== AFFICHAGE DES MESSAGES ===
        echo "Video ${line} was downloaded."
        echo "File path : ${futureVideoDirectory}"

        #=== AJOUT AUX LOGS ===
        if [ ! -d "${LOG_FOLDER_PATH}" ]; then
            exit
        fi

        currentDate=$(date +"%y/%m/%d %H:%M:%S")
        echo "[${currentDate}] Video ${line} was downloaded. File path : ${futureVideoDirectory}" >> "${LOG_FOLDER_PATH}/${LOG_DOWNLOAD_FILE_NAME}"
    fi

done <<< "$(cat ${localDirectory}/${TO_DOWNLOAD_LIST_FILE_NAME})"
