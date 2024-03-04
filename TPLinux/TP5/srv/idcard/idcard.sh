#!/bin/bash
# Aube
# 23/02/2024

machineName=$(hostname)
echo "Machine name : ${machineName}"

source /etc/os-release
echo "OS ${NAME} and kernel version is $(uname -v)"

echo "IP : $(hostname -I)"

totalRam=$(free -h | grep Mem |tr -s ' ' | cut -d ' ' -f2)
currentRam=$(free -h | grep Mem |tr -s ' ' | cut -d ' ' -f7)
echo "RAM : ${currentRam} memory available on ${totalRam} total memory"

diskSpaceAvailable=$(df -h | grep -E '/$' | tr -s ' '  | cut -d ' ' -f4)
echo "Disk : ${diskSpaceAvailable} space left"

worstPID=$(ps aux --sort -rss |head -n 6 |tr -s ' ' | awk '{print $11}' | tail -n 5)
echo "Top 5 processes by RAM usage :"
for i in $worstPID
do
  echo " - ${i}"
done

echo "Listening ports :"
listenings=$(ss -aplntu4 |tr -s ' ' |tail -n +2)
while read line; do

  #port="$(echo $line | cut -d' ' -f1)"
  port="$(cut -d' ' -f1 <<< ${line})"
  protocol="$(cut -d' ' -f5 <<< ${line} | cut -d ':' -f2 |rev)"
  process=$(cut -d '"' -f2 <<< ${line})

  echo "${port} ${protocol} : ${process}"

done <<< $listenings

echo "PATH directories :"
OLDIFS="${IFS}"
IFS=":"
for p in ${PATH[@]};
do 
    echo " - ${p}"
done
IFS="${OLDIFS}"


if [[ $# -ge 1 ]]
then
  catURL=$(curl -s https://api.thecatapi.com/v1/images/search?api_key=${1} | cut -d',' -f2 | cut -d'"' -f4)
  echo "Here is your random cat (jpg file) : ${catURL}"
else
  catURL=$(curl -s https://api.thecatapi.com/v1/images/search?api_key=live_rdQyqZtzNlHqqpUGc9rBaszlpPhib4COcQ94Bl7gzs82jYGOU5f7k91xPvNr1uXa | cut -d',' -f3 | cut -d'"' -f4)
  echo "Here is your random cat (jpg file) : ${catURL} (using default token)"
fi