#!/bin/bash

export PATH=${PATH}:${HOME}/src/com-diag-diminuto/Diminuto/out/host/bin/../sym:${HOME}/src/com-diag-diminuto/Diminuto/out/host/bin/../bin:${HOME}/src/com-diag-diminuto/Diminuto/out/host/bin/../tst:${HOME}/src/com-diag-hazer/Hazer/out/host/bin/../sym:${HOME}/src/com-diag-hazer/Hazer/out/host/bin/../bin:${HOME}/src/com-diag-hazer/Hazer/out/host/bin/../tst
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HOME}/src/com-diag-diminuto/Diminuto/out/host/bin/../lib:${HOME}/src/com-diag-hazer/Hazer/out/host/bin/../lib

DEVICE=${1:-"/dev/ttyUSB0"}
SPEED=${2:-"115200"}

stty sane
clear

gpstool -D ${DEVICE} -b ${SPEED} -8 -n -1 -E
