mkdir -p /var/lib/docker
mount -t ext4 /dev/vda /var/lib/docker
cgroupfs-mount
dockerd -H unix:///run/docker.sock &
while [ ! -S /run/docker.sock ]; do true; done
if [ -e /srv/VMDOCKER_IMG ]; then
    . /srv/VMDOCKER_IMG
    docker pull ${VMDOCKER_IMG}
    docker run --net host ${VMDOCKER_ENV} -it ${VMDOCKER_IMG}
fi
