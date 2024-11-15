#!/bin/bash

# Copynodeht (c) 2018 Michael Neill Hartman. All nodehts reserved.
# mnh_license@proton.me
# https://github.com/hartmanm
# ov (previously opennode.net)

ZNODE="/media/ramdisk/0node*"
znode=$(sed -e 's/\r$//' $ZNODE)
USER_ID=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="USER_ID"{printf("%s ", $4)}' | xargs)
NODE_NUMBER=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="NODE_NUMBER"{printf("%s ", $4)}' | xargs)
CUSTOMER_KEY=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="CUSTOMER_KEY"{printf("%s ", $4)}' | xargs)
OV=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="OV"{printf("%s ", $4)}' | xargs)
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
echo $last_edit > /media/ramdisk/last_edit
echo $LAST_EDIT > /media/ramdisk/LAST_EDIT
if [[ $LAST_EDIT > $last_edit ]]
then
last_edit=$LAST_EDIT
TIME=$(date +%H%M%S)
echo $TIME > /media/ramdisk/inLAST_EDIT
AUTH="${CUSTOMER_KEY}"
NODES=$(/usr/bin/curl --header "Authorization: $AUTH" $OV/user/$USER_ID/nodes)
sleep 2
t=$NODES
t=${t// /}
t=${t//,/ }
t=${t##[}
t=${t%]}
eval a=($t)
target=$(($NODE_NUMBER - 1))
NODE=$(/usr/bin/curl --header "Authorization: $AUTH" $OV${a[target]})
var=RE2UNIX
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
RE2UNIX=${b[1]}
var=DEV_WATCH
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
DEV_WATCH=${b[1]}
var=VERSION
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
VERSION=${b[1]}
var=EMAIL_UPDATES
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
EMAIL_UPDATES=${b[1]}
var=COIN
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
COIN=${b[1]}
var=REBOOT
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
REBOOT=${b[1]}
var=UPDATE
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
UPDATE=${b[1]}
var=self
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
SELF=${b[1]}

INDEX=$(echo $NODE | grep -aob "CLIENT_ARGS" | grep -oE '[0-9]+' | tail -n1)
CLIENT_ARGS=${NODE:$INDEX:250}
INDEX2=$(echo $CLIENT_ARGS | grep -aob "," | grep -oE '[0-9]+' | head -n1)
CLIENT_ARGS=${NODE:$INDEX:INDEX2}
CLIENT_ARGS=${CLIENT_ARGS:16:INDEX2}
CLIENT_ARGS='"'$CLIENT_ARGS

INDEX=$(echo $NODE | grep -aob "CLIENT" | grep -oE '[0-9]+' | tail -n1)
CLIENT=${NODE:$INDEX:250}
INDEX2=$(echo $CLIENT | grep -aob "," | grep -oE '[0-9]+' | head -n1)
CLIENT=${NODE:$INDEX:INDEX2}
CLIENT=${CLIENT:11:INDEX2}
CLIENT='"'$CLIENT

INDEX=$(echo $NODE | grep -aob "CLIENT_OC" | grep -oE '[0-9]+' | tail -n1)
CLIENT_OC=${NODE:$INDEX:38}
INDEX2=$(echo $CLIENT_OC | grep -aob "," | grep -oE '[0-9]+' | tail -n1)
CLIENT_OC=${NODE:$INDEX:INDEX2}
CLIENT_OC=${CLIENT_OC:14:INDEX2}
CLIENT_OC='"'$CLIENT_OC
fi ## if [[ $LAST_EDIT > $last_edit ]]
fi ## if [[ $LOGGED_IN == "1" || $itr == 0 ]]
}
getRigs
itr=1
min_count=0

sendDataInit()
{
TIME=$(date +%H%M%S)
OUT=$(tail -10 /media/ramdisk/screenlog.0)
if [[ $COIN == "CLIENT" && $CLIENT == '"xmrstak"' ]]
then
OUT=$(tail -10 /media/ramdisk/xmrstak/screenlog.0)
fi
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
echo ${node_log} > /media/ramdisk/node_log
MSG='{"HASHRATE": "0", "CYCLE": "'$TIME'", "NODE_LOG": "'${node_log}'"}'
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
OUTPUT_LINE="$OV$SELF"
/usr/bin/curl -X PATCH --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
}

sendDataCur()
{
HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", $HASHRATE}")
echo $HASHRATE > /media/ramdisk/HASHRATE
sleep 1
TIME=$(date +%H%M%S)
OUT=$(tail -10 /media/ramdisk/screenlog.0)
if [[ $COIN == "CLIENT" && $CLIENT == '"xmrstak"' ]]
then
OUT=$(tail -10 /media/ramdisk/xmrstak/screenlog.0)
fi
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
echo ${node_log} > /media/ramdisk/node_log
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
target=$(ps -ef | awk '$NF~"1bash" {print $2}')
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

echo "$(date) - new settings detected: restart 1bash"
LOG+="$(date) - new settings detected: restart 1bash"
LOG+=$'\n'
pkill -e miner
pkill -f miner
send_post
target=$(ps -ef | awk '$NF~"1bash" {print $2}')
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

if [[ -d "/media/m1/2274EEAA26420CBD" ]]
then
IPW=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
MAC=$(ifconfig -a | grep -Po 'HWaddr \K.*$')
fi
if [[ -d "/media/oros/0node_here" ]]
then
IPW=$(ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
MAC=$(ip link show | grep -Po 'ether \K.*$')
MAC=${MAC:0:17}
fi
IP_AS_WORKER=$(echo -n $IPW | tail -c -3 | sed 'y/./0/')
MAC_AS_WORKER=$(echo -n $MAC | tail -c -4 | sed 's|[:,]||g')
LOG+="$(date) - Watchdog Started"
LOG+=$'\n'
sleep 2

sleep 10
sendDataInit
echo "$(date) - waiting 20 seconds before going 'on watch'"
sleep 20
#sleep 30
THRESHOLD=90
RESTART=0
GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | tail -1)
COUNT=$((6 * $GPU_COUNT))
while true
do
sleep 10
TOP=0
GPU=0
REBOOTRESET=$(($REBOOTRESET + 1))
echo ""
echo "      GPU_COUNT: " $GPU_COUNT
UTILIZATIONS=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
echo ""
echo "GPU UTILIZATION: " $UTILIZATIONS
echo ""
numtest='^[0-9]+$'
for UTIL in $UTILIZATIONS
do
if ! [[ $UTIL =~ $numtest ]]
then
LOG+="$(date) - GPU FAIL - restarting system"
LOG+=$'\n'
echo "$(date) - GPU FAIL - restarting system"
echo ""
echo "current GPU activity:"
LOG+="current GPU activity:"
LOG+=$(nvidia-smi --query-gpu=gpu_bus_id --format=csv)
sendDataCur
echo "$(date) - reboot in 10 seconds"
echo ""
send_post
sleep 10
sudo reboot
fi
if [ $UTIL -lt $THRESHOLD ]
then
echo "$(date) - GPU under threshold found - GPU UTILIZATION: " $UTILIZATIONS
echo ""
COUNT=$(($COUNT - 1))
TOP=$(($TOP + 1))
fi
GPU=$(($GPU + 1))
done ## for UTIL in $UTILIZATIONS
if [ $TOP -gt 0 ]
then
if [ $COUNT -le 0 ]
then
INTERNET_IS_GO=0
if nc -vzw1 google.com 443;
then
INTERNET_IS_GO=1
fi
echo ""
if [[ $RESTART -gt 2 && $INTERNET_IS_GO == 1 ]]
then
echo "$(date) - Utilization is too low: reviving did not work so restarting system in 10 seconds"
LOG+="$(date) - Utilization is too low: reviving did not work so restarting system in 10 seconds"
LOG+=$'\n'
echo ""
sendDataCur
send_post
sleep 2
pkill -e miner
pkill -f miner
sleep 10
sudo reboot
fi
echo "$(date) - Utilization is too low: restart 1bash"
LOG+="$(date) - Low GPU Utilization Detected: restart 1bash"
LOG+=$'\n'
pkill -e miner
pkill -f miner
sendDataCur
send_post
target=$(ps -ef | awk '$NF~"1bash" {print $2}')
kill $target
echo ""
RESTART=$(($RESTART + 1))
REBOOTRESET=0
COUNT=$GPU_COUNT
sleep 70
else
echo "$(date) - Low GPU Utilization Detected"
echo ""
fi ##[ $COUNT -le 0 ]
else
min_count=$(($min_count + 1))
ten=$(($min_count % 5))
if [[ $ten == 0 ]]
then
updateINIT
sleep 2
fi
COUNT=$((6 * $GPU_COUNT))

echo $CLIENT > /media/ramdisk/CLIENT
echo $COIN > /media/ramdisk/COIN

# ensure hashrate is an int
isnum='^[0-9]+$'
HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", 1 * $HASHRATE}")
if ! [[ $HASHRATE =~ $isnum ]]
then
if [[ $OLD_HASH == "" ]]
then
OLD_HASH=0
fi
HASHRATE=$OLD_HASH
fi

# EXPECTED_HASHRATE CHECK
echo "       HASHRATE: $HASHRATE"
echo ""
NODE_LOG+=$(tail /media/ramdisk/screenlog.0)
NODE_LOG+=$'\n\n'
if [[ $EXPECTED_HASHRATE != "for_advanced_use_only" && $EXPECTED_HASHRATE != "" ]]
then
MIN_HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", 92/100 * $EXPECTED_HASHRATE}")
if [[ $COIN == "RVN" ]]
then
MIN_HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", 85/100 * $EXPECTED_HASHRATE}")
fi
CUR_HASHRATE=$(awk "BEGIN {printf \"%.0f\n\", $HASHRATE - $MIN_HASHRATE}")
if [ $CUR_HASHRATE -lt 0 ]
then
HASH_COUNT=$(($HASH_COUNT + 2))
fi
if [ $HASH_COUNT != 0 ]
then
HASH_COUNT=$(($HASH_COUNT -1))
fi
if [ $HASH_COUNT -gt 21 ]
then
echo "$(date) - hashrate below minimum detected: $CUR_HASHRATE rebooting"
LOG+="$(date) - hashrate below minimum detected: $CUR_HASHRATE rebooting"
LOG+=$'\n'
pkill -e miner
pkill -f miner
sendDataCur
send_post
sleep 10
sudo reboot
fi
echo "     FAIL_COUNT:  $HASH_COUNT"
echo ""
fi

fi ## [ $TOP -gt 0 ]
if [ $REBOOTRESET -gt 5 ]
then
RESTART=0
REBOOTRESET=0
fi
done ## while true
