#!/bin/bash
# Copyright 2020 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Filter that reads CSV and outputs KML XML to visualize discrete points.
# References:
#     <https://www.gpsvisualizer.com>.
#     "OGC KML 2.3", 2015 <http://docs.opengeospatial.org/is/12-007r2/12-007r2.html>
#     J. Wernecke, "The KML Handbook", Addison-Wesley, 2009

INIT=""

while read NAM NUM FIX SYS SAT CLK TIM LAT LON HAC MSL GEO VAC SOG COG ROL PIT YAW RAC PAC YAC OBS MAC; do

	if [[ "${NUM}" == "NUM," ]]; then
		continue
	fi

	if [[ -z "${INIT}" ]]; then
		NAME=${NAM##\"}
		NAME=${NAME%%\",}
		TIME=${CLK%,}
		TIME=$(date -d "@${TIME}" -u '+%Y%m%dT%H%M%SZ%N')

		echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'
		echo '<kml xmlns="http://www.opengis.net/kml/2.2">'
		echo '  <Document>'
		echo '    <name><![CDATA['${NAME}']]></name>'
		echo '    <visibility>1</visibility>'
		echo '    <open>1</open>'
		echo '    <Snippet><![CDATA[See <a href="https://github.com/coverclock/com-diag-hazer/blob/master/Hazer/bin/csv2kmlpoints.sh">csv2kmlpoints</a>]]></Snippet>'
		echo '    <Folder id="Points">'
		echo '      <name>Points</name>'
		echo '      <visibility>1</visibility>'
		echo '      <open>0</open>'

		INIT=Y
	fi

	LABEL=${NUM%,}
	LATITUDE=${LAT%,}
	LONGITUDE=${LON%,}
	ALTITUDE=${MSL%,}

	echo '      <Placemark>'
	echo '        <name><![CDATA['${LABEL}']]></name>'
	echo '        <Snippet></Snippet>'
	echo '        <description><![CDATA['${SOG}${ROL}${PIT}${YAW}']]></description>'
	echo '        <Point>'
	echo '          <coordinates>'
	echo "            ${LONGITUDE},${LATITUDE},${ALTITUDE} "
	echo '          </coordinates>'
	echo '        </Point>'
	echo '      </Placemark>'

done

echo '    </Folder>'
echo '  </Document>'
echo '</kml>'

exit 0
