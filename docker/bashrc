. /lib/lsb/init-functions
log_begin_msg 'Mounting docker filesystem'
mkdir -p /var/lib/docker
mount -t ext4 /dev/vda /var/lib/docker
log_end_msg $?
/etc/init.d/cgroupfs-mount start
echo 'Launching dockerd: '
dockerd -H unix:///run/docker.sock &
while [ ! -S /run/docker.sock ]; do
    echo -n "."
done
echo
if [ -e /srv/VMDOCKER_IMG ]; then
    echo 'Launching container'
    . /srv/VMDOCKER_IMG
    docker pull ${VMDOCKER_IMG}
    docker run --net host ${VMDOCKER_ENV} -it ${VMDOCKER_IMG}
fi
