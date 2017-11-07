#!/bin/bash

# See http://misc.flogisoft.com/bash/tip_colors_and_formatting
# for colour formatting

function pad () {
	CONTENT="${1}"; LENGTH="${2}"; TRG_EDGE="${3}";
	#trim input to length
	CONTENT=${CONTENT:0:$LENGTH}
	case "${TRG_EDGE}" in
		left) echo ${CONTENT} | sed -e :a -e 's/^.\{1,'${LENGTH}'\}$/& /;ta'; ;;
		right) echo ${CONTENT} | sed -e :a -e 's/^.\{1,'${LENGTH}'\}$/\ &/;ta'; ;;
		center) echo ${CONTENT} | sed -e :a -e 's/^.\{1,'${LENGTH}'\}$/ & /;ta'
	esac
#	return ${RET__DONE};
}

function aping () {
	SITE="${1}"

	COLOR=$CYAN
	STATUS="ONLINE"

	REPLY=$(ping -W 3 -c 1 $SITE 2>/dev/null)

	TMS=$(echo $REPLY | sed 's/.*time=\([0-9]*.[0-9]\).*ms.*/\1/')
	IP=$(echo $REPLY | sed 's/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/')
	LOSS=$(echo $REPLY | grep 100%)
	
	if [[ $LOSS != "" ]]; then
        	#IP=$SITE
        	TMS=$NATIME
        	STATUS=$OFFLINE
        	COLOR=$RED
	fi

	if [[ $IP == "" ]]; then
        	IP=$NODNS
        	TMS=$NATIME
        	STATUS=$OFFLINE
        	COLOR=$RED
	fi

# BASH doesn't handle floating point numbers
	if [ "$COLOR" != "$RED" ]; then
        	if [[ $(echo "$TMS < 100" | bc) -eq 1 ]]; then
                	COLOR=$GREEN
        	else
                	if [[ $(echo "$TMS > 1000" | bc) -eq 1 ]]; then
                        	COLOR=$YELLOW
                	fi
        	fi
	fi

	TMS=$(pad $TMS 5 "right")
	SITE=$(pad $SITE 24 "right")
	NAME=$(pad "$NAME" 24 "left")
	IP=$(pad $IP 14 "right")
	STATUS=$(pad $STATUS 7 "right")
	printf "${COLOR}${BOLD}$NAME${NORMAL}$SITE$TMS"ms"$IP${BOLD}$STATUS${NORMAL}${NC}\n"
}


RED='\e[41m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
BOLD='\e[1m'
NORMAL='\e[21m'
NC='\e[0m' # No Colour

OFFLINE="OFFLINE"
NODNS="NO-DNS"
NATIME="N/A"

## Main loop/body

while read -r line || [[ -n "$line" ]]; do

	#echo "Text read from file: $line"
	IFS='='
	read -ra ADDR <<< "$line"
	ADDRESS=${ADDR[0]}
	NAME=${ADDR[1]}
	unset IFS
	aping $ADDRESS

done < "$1"


