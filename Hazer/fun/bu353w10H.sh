#!/bin/bash
# Copyright 2019-2020 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Like the bu353w10 script except this one runs headless.

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-9600}

. $(readlink -e $(dirname ${0})/../bin)/setup

. $(readlink -e $(dirname ${0})/../fun)/ubx8

LOG=$(readlink -e $(dirname ${0})/..)/log
mkdir -p ${LOG}

OPTIONS=""
for OPTION in ${COMMANDS}; do
    OPTIONS="${OPTIONS} ${OPTION}"
done

eval coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -H ${LOG}/${PROGRAM}.out -t 10 ${OPTIONS} 2> ${LOG}/${PROGRAM}.err
