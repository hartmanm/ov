#!/bin/bash

# Copyright (c) 2018 Michael Neill Hartman. All rights reserved.
# mnh_license@proton.me
# https://github.com/hartmanm
# ov (previously openrig.net)

BASH_VERSION="1.5"
WATCHDOG="YES"
sudo ufw enable

[[ `which ifconfig` == "" ]] && {
IPW=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
MAC=$(ifconfig -a | grep -Po 'HWaddr \K.*$')
}
[[ $IPW == "" ]] && IPW=$(ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
[[ $MAC == "" ]] && {
MAC=$(ip link show | grep -Po 'ether \K.*$')
MAC=${MAC:0:17}
}

# [[ $WATCHDOG == "YES" ]] && cp /media/m1/2274EEAA26420CBD/0node* /media/ramdisk/0node.txt

ZNODE="/media/ramdisk/0node.txt"
znode=$(sed -e 's/\r$//' $ZNODE)
USER_ID=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="USER_ID"{printf("%s ", $4)}' | xargs)
NODE_NUMBER=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="NODE_NUMBER"{printf("%s ", $4)}' | xargs)
CUSTOMER_KEY=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="CUSTOMER_KEY"{printf("%s ", $4)}' | xargs)
OV=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="OV"{printf("%s ", $4)}' | xargs)
IP_AS_WORKER=$(echo -n $IPW | tail -c -3 | sed 'y/./0/')
MAC_AS_WORKER=$(echo -n $MAC | tail -c -4 | sed 's|[:,]||g')

email_update()
{
if [[ $EMAIL_UPDATES == "YES" || $DEV_WATCH == "YES" ]]
then
sleep 2
GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | tail -1)
MSG="
NODE#: $NODE_NUMBER
MAC: $MAC_AS_WORKER
GPU_COUNT: $GPU_COUNT
IP: $IPW
COIN: $COIN
VERSION: $VERSION
"
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
R_LENGTH=${#SELF}
NODE_ID=${SELF:6:$R_LENGTH}
OUTPUT_LINE="$OV/email_alert/$NODE_ID"
/usr/bin/curl -X POST --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
sleep 2
fi
}

POWERLIMIT_WATTS="107"
CORE_OVERCLOCK="101"
MEMORY_OVERCLOCK="501"
FAN_SPEED="48"
EXPECTED_HASHRATE="2"
INDIVIDUAL_POWERLIMITS="0"

getRigs()
{
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
var=NODE_MAC
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
NODE_MAC=${b[1]}
var=NODE_IP
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
NODE_IP=${b[1]}
var=BASE_VERSION
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
BASE_VERSION=${b[1]}
var=EMAIL_UPDATES
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
EMAIL_UPDATES=${b[1]}

var=UPDATE
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
UPDATE=${b[1]}

var=self
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
SELF=${b[1]}
var=VERSION
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
VERSION=${b[1]}

var=COIN
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
COIN=${b[1]}
var=NODE_NUMBER
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
NODE_NUMBER=${b[1]}

INDEX=$(echo $NODE | grep -aob "CLIENT" | grep -oE '[0-9]+' | tail -n1)
CLIENT=${NODE:$INDEX:250}
INDEX2=$(echo $CLIENT | grep -aob "," | grep -oE '[0-9]+' | head -n1)
CLIENT=${NODE:$INDEX:INDEX2}
CLIENT=${CLIENT:11:INDEX2}
CLIENT='"'$CLIENT

INDEX=$(echo $NODE | grep -aob "CLIENT_ARGS" | grep -oE '[0-9]+' | tail -n1)
CLIENT_ARGS=${NODE:$INDEX:250}
INDEX2=$(echo $CLIENT_ARGS | grep -aob "," | grep -oE '[0-9]+' | head -n1)
CLIENT_ARGS=${NODE:$INDEX:INDEX2}
CLIENT_ARGS=${CLIENT_ARGS:16:INDEX2}
CLIENT_ARGS='"'$CLIENT_ARGS

INDEX=$(echo $NODE | grep -aob "CLIENT_OC" | grep -oE '[0-9]+' | tail -n1)
CLIENT_OC=${NODE:$INDEX:38}
INDEX2=$(echo $CLIENT_OC | grep -aob "," | grep -oE '[0-9]+' | tail -n1)
CLIENT_OC=${NODE:$INDEX:INDEX2}
CLIENT_OC=${CLIENT_OC:14:INDEX2}
CLIENT_OC='"'$CLIENT_OC
}
getRigs

# kill 3watchdog if re2unix == "YES"
if [[ $RE2UNIX == "YES" ]]
then
pkill -e 3watchdog
pkill -f 3watchdog
sleep 2
MSG='{"RE2UNIX": "1"}'
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
OUTPUT_LINE="$OV$SELF"
/usr/bin/curl -X PATCH --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
fi
sleep 2
URL="$OV/3watchdog.sh"
DL=$(/usr/bin/curl $URL)
