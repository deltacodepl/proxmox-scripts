if [[ ! -z $2 ]]; 
    then
if ! [[ $2 =~ ^[0-9]+$ ]]; 
   then echo "error: Target ID is Not a number" >&2; exit 1 
fi
else
    echo  "Set target id "
fi

SOURCEID=$1
TARGETID=$2

if [[ -f '/etc/pve/lxc/112.conf' ]]; then
target_status=$(/usr/sbin/pct status $TARGETID | cut -d ':' -f 2 | tr -d ' ')
if [ $target_status = 'running' ]; then
echo "$TARGETID is running, stopping ..."
/usr/sbin/pct stop $TARGETID
fi
/usr/sbin/pct destroy $TARGETID
fi

# pct delsnapshot $SOURCEID daily
# pct snapshot $SOURCEID daily
# pct clone $SOURCEID $TARGETID --hostname sandbox --snapname daily
firebird=$(ls -alh /mnt/pve/syno/dump/*.zst | grep $SOURCEID | tail -1 | awk '{ print $9 }')
echo "restoring ${firebird} ..."
/usr/sbin/pct restore $TARGETID $firebird --storage local-lvm --hostname sandbox
/usr/sbin/pct set $TARGETID --net0 name=eth0,ip=192.168.2.6/24,bridge=vmbr0,gw=192.168.2.1,firewall=1
/usr/sbin/pct start $TARGETID