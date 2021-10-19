#!/bin/bash
# Copyright 2021 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# This script tests the Bad Elf GPS Pro+ via its USB connection.
# The Pro+ supports Bluetooth connectivity to the Bad Elf iPhone
# application, but alas the device refuses to pair with the
# Raspberry Pi.

SELF=$$

SAVDIR=${COM_DIAG_HAZER_SAVDIR:-$(readlink -e $(dirname ${0})/..)/tmp}
mkdir -p ${SAVDIR}

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-9600}
ERRFIL=${3-"${SAVDIR}/${PROGRAM}.err"}
CATFIL=${3-"${SAVDIR}/${PROGRAM}.cat"}

mkdir -p $(dirname ${ERRFIL})
mkdir -p $(dirname ${CATFIL})

cp /dev/null ${ERRFIL}
cp /dev/null ${CATFIL}

exec 2>>${ERRFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

export COM_DIAG_DIMINUTO_LOG_MASK=0xff

#exec coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -t 10 -F 1 -E -C ${CATFIL} -v -d
exec coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -t 10 -F 1 -E -C ${CATFIL} -v
