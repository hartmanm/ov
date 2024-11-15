#!/bin/bash

# Copyright (c) 2018 Michael Neill Hartman. All rights reserved.
# mnh_license@proton.me
# https://github.com/hartmanm
# ov (previously openrig.net)

UPDATE_SOURCE="$1"
cd /media/ramdisk
UP="/media/ramdisk/update.zip"
if [[ -d $UP ]]
then
sudo rm $UP
fi
FILENAME="update.zip"
wget --no-check-certificate "$UPDATE_SOURCE" -O $FILENAME
sleep 2
unzip $FILENAME
sleep 4
# operations here

# update version
ZNODE="/media/ramdisk/0node*"
znode=$(sed -e 's/\r$//' $ZNODE)
USER_ID=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="USER_ID"{printf("%s ", $4)}' | xargs)
NODE_NUMBER=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="NODE_NUMBER"{printf("%s ", $4)}' | xargs)
CUSTOMER_KEY=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="CUSTOMER_KEY"{printf("%s ", $4)}' | xargs)
OV=$(/usr/bin/curl $znode 2>/dev/null | awk -F'"' '$2=="OV"{printf("%s ", $4)}' | xargs)
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
var=self
out=$(echo $NODE | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $var)
eval b=($out)
SELF=${b[1]}
}
getRigs
sleep 2
MSG='{"VERSION": "1.4"}'
BULLET="${MSG}"
AUTH="${CUSTOMER_KEY}"
OUTPUT_LINE="$OV$SELF"
/usr/bin/curl -X PATCH --output /dev/null $OUTPUT_LINE --header "Authorization: $AUTH" --header "Content-Type: application/json" -d "$BULLET"
