#!/bin/bash

# Copyright (c) 2018 Michael Neill Hartman. All rights reserved.
# mnh_license@proton.me
# https://github.com/hartmanm
# ov (previously openrig.net)

DL=$(/usr/bin/curl "https://hartmanm.github.io/ov/1bash.sh")
cat <<EOF >/media/ramdisk/1bash.sh
$DL
EOF
pkill -e 1bash
pkill -f 1bash
pkill -e runner
pkill -f runner
sleep 4
bash '/media/ramdisk/1bash.sh'
