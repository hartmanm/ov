#!/bin/bash

# Copyright (c) 2018 Michael Neill Hartman. All rights reserved.
# mnh_license@proton.me
# https://github.com/hartmanm
# ov (previously openrig.net)

ZNODE="/tmp/0node*"
znode=$(sed -e 's/\r$//' $ZNODE)
USER_ID=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="USER_ID"{printf("%s ", $4)}' | xargs)
NODE_NUMBER=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="NODE_NUMBER"{printf("%s ", $4)}' | xargs)
CUSTOMER_KEY=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="CUSTOMER_KEY"{printf("%s ", $4)}' | xargs)
OV=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="OV"{printf("%s ", $4)}' | xargs)

[[ `which ifconfig` == "" ]] && {
IPW=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
MAC=$(ifconfig -a | grep -Po 'HWaddr \K.*$')
}
[[ $IPW == "" ]] && IPW=$(ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
[[ $MAC == "" ]] && {
MAC=$(ip link show | grep -Po 'ether \K.*$')
MAC=${MAC:0:17}
}

HASH_COUNT="1"
LOG=""
TIME="FIRST"
COINCHANGE=1
HASHRATE=0
itr=0
NODE_LOG=""
last_edit=000000
LAST_EDIT=000001
AUTH=$CUSTOMER_KEY
getRigs()
{
LOGGED_IN=$(/usr/bin/curl --header "Authorization: $AUTH" $OV/loggedin/$USER_ID)
LOGGED_IN=${LOGGED_IN:1:1}
if [[ $LOGGED_IN == "1" || $itr == 0 ]]
then
LAST_EDIT=$(/usr/bin/curl --header "Authorization: $AUTH" $OV/last_edit/$USER_ID)
LAST_EDIT=${LAST_EDIT:1:6}
echo $last_edit > /tmp/last_edit
echo $LAST_EDIT > /tmp/LAST_EDIT
if [[ $LAST_EDIT > $last_edit ]]
then
last_edit=$LAST_EDIT
TIME=$(date +%H%M%S)
echo $TIME > /tmp/inLAST_EDIT
AUTH="${CUSTOMER_KEY}"
NODES=$(/usr/bin/curl --header "Authorization: $AUTH" $OV/user/$USER_ID/nodes)
fi
fi
}
getRigs
itr=1
min_count=0

sendDataInit()
{
TIME=$(date +%H%M%S)
OUT=$(tail -10 /tmp/screenlog.0)

sendDataCur()
{
HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", $HASHRATE}")
echo $HASHRATE > /tmp/HASHRATE
sleep 1
TIME=$(date +%H%M%S)
OUT=$(tail -10 /tmp/screenlog.0)
node_log="${OUT//$'\n'/<br />}"
node_log="${node_log//$'[39m'/ }"
node_log="${node_log//$'[0m'/ }"
node_log="${node_log//$'[32m'/ }"
node_log="${node_log//$'[0;97m'/ }"
node_log="${node_log//$'[0;36m'/ }"
node_log="${node_log//$'[0;93m'/ }"
node_log="${node_log//$'[0;91m'/ }"
node_log="${node_log//$'[49m'/ }"
node_log="${node_log//$'[33m'/ }"
node_log="${node_log//$'[1;'/ }"
node_log="${node_log//$'[36m'/ }"
node_log="${node_log//$'[37m'/ }"
node_log="${node_log//$'[97m'/ }"
node_log="${node_log//$'[30m'/ }"
node_log="${node_log//$'[35m'/ }"
node_log="${node_log//$'[94m'/ }"
node_log="${node_log//$'[31m'/ }"
node_log="${node_log//$'[36m'/ }"
node_log=$(echo $node_log | sed 's/[^[:print:]\r\t]/ /g' | tr -d '\r')
echo ${node_log} > /tmp/node_log
MSG='{"HASHRATE": "'$HASHRATE'", "CYCLE": "'$TIME'", "NODE_LOG": "'${node_log}'"}'
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
OUTPUT_LINE="$OV$SELF"
/usr/bin/curl -X PATCH --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
}

updateCHECK()
{
echo "updateCHECK"
HASH=1
last_COIN=$COIN
last_REBOOT=$REBOOT
last_CLIENT=$CLIENT
last_UPDATE=$UPDATE
last_EMAIL_UPDATES=$EMAIL_UPDATES
last_RE2UNIX=$RE2UNIX
last_CLIENT=$CLIENT
last_CLIENT_OC=$CLIENT_OC
last_CLIENT_ARGS=$CLIENT_ARGS
getRigs

if [[ $last_REBOOT != $REBOOT ]]
then
echo "$(date) - going down for reboot"
LOG+="$(date) - going down for reboot"
LOG+=$'\n'
pkill -e miner
pkill -f miner
send_post
sleep 10
sudo reboot
fi

if [[ $last_UPDATE != $UPDATE ]]
then
echo "$(date) - going down for update"
LOG+="$(date) - going down for update"
LOG+=$'\n'
pkill -e miner
pkill -f miner
send_post
sleep 10
sudo reboot
fi

if [[ $RE2UNIX == "YES" ]]
then
echo "$(date) - re2unix: restarting mining process"
LOG+="$(date) - re2unix: restarting mining process"
LOG+=$'\n'
pkill -e miner
pkill -f miner
send_post
target=$(ps -ef | awk '$NF~"run.sh" {print $2}')
kill $target
echo ""
fi

if [[ $last_COIN != $COIN ]]
then
HASH=0
COINCHANGE=1
fi
if [[ $last_CLIENT != $CLIENT ]]
then
HASH=0
fi

# HASH == 0
echo ""
echo "HASH:" $HASH
echo ""
if [[ $HASH == 0 ]]
then

# COINCHANGE
if [[ $COINCHANGE == 1 ]]
then
sleep 1
HASHRATE="0"
sendDataCur
sleep 1
echo ""
COINCHANGE=0
fi ## COINCHANGE

echo "$(date) - new settings detected: restart run.sh"
LOG+="$(date) - new settings detected: restart run.sh"
LOG+=$'\n'
pkill -e miner
pkill -f miner
send_post
target=$(ps -ef | awk '$NF~"run.sh" {print $2}')
kill $target
echo ""
if [[ $GPU_COUNT < 7 ]]
then
sleep 35
fi
if [[ $GPU_COUNT > 6 ]]
then
sleep 80
fi

fi ## HASH == 0
}

send_post()
{
if [[ $EMAIL_UPDATES == "YES" || $DEV_WATCH == "YES" ]]
then
MSG="
NODE#: $NODE_NUMBER
MAC: $MAC_AS_WORKER
GPU_COUNT: $GPU_COUNT
IP: $IP_AS_WORKER
VERSION: $VERSION
LOG: $LOG
"
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
ID_BOX=$SELF
R_LENGTH=${#ID_BOX}
NODE_ID=${ID_BOX:6:$R_LENGTH}
OUTPUT_LINE="$OV/email_alert/$NODE_ID"
/usr/bin/curl -X POST --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
sleep 5
fi
}

updateINIT()
{
itr=$(($itr + 1))
#updateNOW=$(($itr % 2))
updateNOW=0
# doubles update frequency
if [[ $updateNOW == 0 ]]
then
updateCHECK
sendDataCur
sleep 1
echo ""
fi
}

fi ## [ $TOP -gt 0 ]
if [ $REBOOTRESET -gt 5 ]
then
RESTART=0
REBOOTRESET=0
fi
done ## while true
