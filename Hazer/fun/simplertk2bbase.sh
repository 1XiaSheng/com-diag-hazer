#!/bin/bash
# Copyright 2019 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer

# This script is specific to the Ardusimple SimpleRTK2B base (stationary) side.

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-9600}

. $(readlink -e $(dirname ${0})/../bin)/setup

# UBX-MON-VER [0]
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-NMEA-PROTVER
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-MODE
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TMODE-MODE SURVEY_IN
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-MODE
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-MIN-DUR
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TMODE-SVIN-MIN-DUR 60 (seconds)
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-MIN-DUR
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-ACC-LIMIT
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TMODE-SVIN-ACC-LIMIT 50000 (x 0.1mm)
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-ACC-LIMIT
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-MODE
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-MIN-DUR
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-TMODE-SVIN-ACC-LIMIT
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-BAUDRATE
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-UART2-BAUDRATE 38400
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-BAUDRATE
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-STOPBITS
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-UART2-STOPBITS 1 (1)
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-STOPBITS
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-DATABITS
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-UART2-DATABITS 0 (8)
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-DATABITS
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-PARITY
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-UART2-PARITY 0 (none)
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-PARITY
#
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-ENABLED
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-UART2-ENABLED 1
# UBX-CFG-VALGET [8] V0 RAM 0 0 CFG-UART2-ENABLED

exec coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -E -t 10 \
    \
    -W '\xb5\x62\x0a\x04\x00\x00' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x01\x00\x93\x20' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x01\x00\x03\x20' \
    -U '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x01\x00\x03\x20\x01' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x01\x00\x03\x20' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x10\x00\x03\x40' \
    -U '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x10\x00\x03\x40\x3c\x00\x00\x00' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x10\x00\x03\x40' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x11\x00\x03\x40' \
    -U '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x11\x00\x03\x40\x50\xc3\x00\x00' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x11\x00\x03\x40' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x01\x00\x53\x40' \
    -U '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x01\x00\x53\x40\x96\x00\x00\x00' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x01\x00\x53\x40' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x02\x00\x53\x20' \
    -U '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x02\x00\x53\x20\x01' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x02\x00\x53\x20' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x03\x00\x53\x20' \
    -U '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x03\x00\x53\x20\x00' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x03\x00\x53\x20' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x04\x00\x53\x20' \
    -U '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x04\x00\x53\x20\x00' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x04\x00\x53\x20' \
    \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x05\x00\x53\x10' \
    -U '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x05\x00\x53\x10\x01' \
    -U '\xb5\x62\x06\x8b\x08\x00\x00\x00\x00\x00\x05\x00\x53\x10' \
    \
	2> >(log -S -N ${PROGRAM})
