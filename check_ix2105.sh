#!/bin/sh
cd "$(dirname "$0")"
HOSTID=`cat secret | grep HOSTID | cut -d"=" -f2 | sed -e "s/'//g"`
API_KEY=`cat secret | grep API_KEY | cut -d"=" -f2 | sed -e "s/'//g"`
METADATA_POINT="https://mackerel.io/api/v0/hosts/${HOSTID}/metadata/info"
METRIC_POINT="https://mackerel.io/api/v0/tsdb"
public_ip=`snmpwalk -v 2c -c localreader 192.168.1.1 RFC1213-MIB::ipAdEntAddr | grep -v 192 | awk '{print
 $NF}'`

before_public_ip=`curl -s ${METADATA_POINT} -H "X-Api-Key:${API_KEY}" | jq .[].ipaddress -r`
if [ ${public_ip} != ${before_public_ip} ]; then
    data=$(jo ipaddress=$public_ip | jo -a)
    data2=$(jo hostId=${HOSTID} name=custom.info.globalip time=$(date +%s) value=1 | jo -a)
    curl -s -X PUT ${METADATA_POINT} -H "X-Api-Key:${API_KEY}" -H 'Content-Type: application/json' -d $da
ta
else
    data2=$(jo hostId=${HOSTID} name=custom.info.globalip time=$(date +%s) value=0 | jo -a)
fi
curl -s -X POST ${METRIC_POINT} -H "X-Api-Key:${API_KEY}" -H 'Content-Type: application/json' -d $data2

