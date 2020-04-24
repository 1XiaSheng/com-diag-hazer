#!/bin/bash
# Copyright 2020 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
#
# 12835, 1587753687.036326445, 1587753687.000000000, 39.794262451, -105.153361514, 10.7277, 1705.2760, 1683.7761, 13.5318
# 12836, 1587753688.036376364, 1587753688.000000000, 39.794264493, -105.153361858, 10.7360, 1705.0828, 1683.5829, 13.5288
# 12837, 1587753689.034452883, 1587753688.000000000, 39.794271819, -105.153362386, 10.7524, 1704.5394, 1683.0395, 13.5299
#
# $GNRMC,184127.00,A,3947.013237,N,10509.002556,W,0,0,240420,,,A,V*25\r\n
# $GNRMC,184128.00,A,3947.013237,N,10509.002556,W,0,0,240420,,,A,V*2A\r\n
# $GNRMC,184128.00,A,3947.013237,N,10509.002556,W,0,0,240420,,,A,V*2A\r\n

while read NUM CLK TIM LAT LON HOR MSL WGS VER; do
	if [[ "${NUM}" != "OBSERVATION" ]]; then

		DAT=${TIM%,}
		TIME=$(date -d "@${DAT}" -u '+%H%M%S.00')
		DATE=$(date -d "@${DAT}" -u '+%d%m%y')

		DAT=${LAT%,}
		NUM=${DAT%.*}
		DEG=${NUM#-}
		if [[ "${DEG}" == "${NUM}" ]]; then
			NS="N"
		else
			NS="S"
		fi
		NAN=${DAT#*.}
		MIN=$((${NAN} * 60 / 1000000000))
		MIL=$((${NAN} / 60000))
		printf -v LATITUDE "%d%02d.%06d" ${DEG} ${MIN} ${MIL}
		
		DAT=${LON%,}
		NUM=${DAT%.*}
		DEG=${NUM#-}
		if [[ "${DEG}" == "${NUM}" ]]; then
			EW="E"
		else
			EW="W"
		fi
		NAN=${DAT#*.}
		MIN=$((${NAN} * 60 / 1000000000))
		MIL=$((${NAN} / 60000))
		printf -v LONGITUDE "%d%02d.%06d" ${DEG} ${MIN} ${MIL}

		BUF="\$GNRMC,${TIME},A,${LATITUDE},${NS},${LONGITUDE},${EW},0,0,${DATE},,,A,V"
		RMC=$(checksum ${BUF})
		echo -n -e ${RMC}

	fi
done

exit 0
