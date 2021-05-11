#!/bin/bash
# Copyright 2021 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Run a GNSS receiver, saving its data, and forwarding JSON datagrams via a
# serial-connected radio.
# The NETDEVICE and NETRATE default to the Digi XBIB-CU-TH board or the
# Digi XBIB-U-DEV board, either with a Digi XBEE3 LTE-M radio module.
# The GPSDEVICE and GPSRATE default to the Digi XBIB-C-GPS daughter board.
# In the case of the XBIB-C-GPS daughter board, the defaults in the script
# assume that the FTDI USB-to-serial cable is plugged in *second* so that it
# enumerates as /dev/ttyUSB1 while the radio enumerates as /dev/ttyUSB0.
# usage: wheatstone [ GPSDEVICE [ NETDEVICE [ GPSRATE [ NETRATE [ ERRFIL [ OUTFIL [ CSVFIL [ PIDFIL [ LIMIT ] ] ] ] ] ] ] ] ]
# example: wheatstone /dev/ttyUSB1 /dev/ttyUSB0

##
## SETUP
##

SELF=$$

CSVDIR=${COM_DIAG_HAZER_SAVDIR:-${HOME:-"/var/tmp"}/csv}
SAVDIR=${COM_DIAG_HAZER_SAVDIR:-$(readlink -e $(dirname ${0})/..)/tmp}

PROGRAM=$(basename ${0})
GPSDEVICE=${1:-"/dev/ttyUSB1"}
NETDEVICE=${2:-"/dev/ttyUSB0"}
UPDATE=${3:-5}
GPSRATE=${4:-9600}
NETRATE=${5:-9600}
ERRFIL=${6-"${SAVDIR}/${PROGRAM}.err"}
OUTFIL=${7-"${SAVDIR}/${PROGRAM}.out"}
CSVFIL=${8-"${CSVDIR}/${PROGRAM}.csv"}
PIDFIL=${9-"${SAVDIR}/${PROGRAM}.pid"}
LIMIT=${10:-$(($(stty size | cut -d ' ' -f 1) - 2))}

TIMEOUT=10

mkdir -p $(dirname ${ERRFIL})
mkdir -p $(dirname ${OUTFIL})
mkdir -p $(dirname ${CSVFIL})
mkdir -p $(dirname ${PIDFIL})

cp /dev/null ${ERRFIL}
cp /dev/null ${OUTFIL}
touch ${CSVFIL}

exec 2>>${ERRFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

trap "trap '' SIGINT SIGQUIT SIGTERM; kill -TERM -- -${SELF} 2> /dev/null; exit 0" SIGINT SIGQUIT SIGTERM

##
## FORWARD JSON DATAGRAMS
##

tail -n 0 -f ${CSVFIL} | csv2dgm -D ${NETDEVICE} -b ${NETRATE} -8 -1 -n -j &

##
## CAPTURE CSV GEOLOCATION
##

gpstool -D ${GPSDEVICE} -b ${GPSRATE} -8 -n -1 -H ${OUTFIL} -f ${UPDATE} -t ${TIMEOUT} -T ${CSVFIL} -O ${PIDFIL} < /dev/null 1> /dev/null &

sleep 5

##
## OUTPUT DISPLAY
##

cat ${ERRFIL}

DIRECTORY=$(dirname ${CSVFIL})
FILENAME=$(basename ${CSVFIL})
TASK=${FILENAME%%.*}
FILE=${FILENAME#*.}

peruse ${TASK} ${FILE} ${LIMIT} ${DIRECTORY} < /dev/null &

##
## INPUT KEYBOARD
##

hups $(cat ${PIDFIL})
