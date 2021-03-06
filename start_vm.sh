#!/bin/bash

cdr2mask () {
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

IFACE=eth0
DEFAULT_ROUTE=$(ip route | grep default | awk '{print $3}')
IP=$(ip address show dev ${IFACE} | grep inet | awk '/inet / { print $2 }' | cut -f1 -d/)
CIDR=$(ip address show dev ${IFACE} | awk "/inet ${IP}/ { print \$2 }" | cut -f2 -d/)
MASK=$(cdr2mask $CIDR)
MAC=$(cat /sys/class/net/${IFACE}/address)
RESOLV_NAMESERVERS=$(cat /etc/resolv.conf | awk 'BEGIN { i = 0 }; /^nameserver/ { ns[i] = $2; i++ } END { sep = ""; for ( idx in ns ) { printf "%s%s", sep, ns[idx]; sep = ":" }; printf "\n" }')
RESOLV_DOMAIN=$(cat /etc/resolv.conf | awk '/^domain/ { print $2 }')
RESOLV_SEARCHES=$(cat /etc/resolv.conf | awk 'BEGIN { i = 0 }; /^search/ { for ( j = 2; j <= NF; j++ ) { ns[i] = $j; i++ } } END { sep = ""; for ( idx in ns ) { printf "%s%s", sep, ns[idx]; sep = ":" }; printf "\n" }')
RESOLV_STR=""
for RESOLV_ARG in NAMESERVERS DOMAIN SEARCHES; do
    VARNAME=RESOLV_${RESOLV_ARG}
    if [ x"${!VARNAME}" != "x" ]; then
        RESOLV_STR="${RESOLV_STR} resolv_${RESOLV_ARG,,}=${!VARNAME}"
    fi
done
RANDOM_ID="$(printf '%02x%02x%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"
MACVTAP_NAME="macvtap${RANDOM_ID}"
IPCMD=${IP}::${DEFAULT_ROUTE}:${MASK}:kvm::

ip link set ${IFACE} down
ip addr del ${IP}/${CIDR} dev $IFACE
ip link set ${IFACE} address $(printf '52:54:00:%02X:%02X:%02X' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
ip link set ${IFACE} up
until $(ip link add link ${IFACE} name ${MACVTAP_NAME} type macvtap mode bridge); do
    sleep 1
done
ip link set ${MACVTAP_NAME} address $MAC
ip link set ${MACVTAP_NAME} up
IFS=: read MAJOR MINOR < <(cat /sys/devices/virtual/net/${MACVTAP_NAME}/tap*/dev)
mknod "/dev/${MACVTAP_NAME}" c $MAJOR $MINOR

if [ ! -z ${VMDOCKER_IMG+x} ]; then
    cat > /srv/VMDOCKER_IMG << __EOF__
VMDOCKER_IMG="${VMDOCKER_IMG}"
__EOF__
fi
if [ ! -z ${VMDOCKER_ENV+x} ]; then
    cat >> /srv/VMDOCKER_IMG << __EOF__
VMDOCKER_ENV="${VMDOCKER_ENV}"
__EOF__
fi

exec /usr/bin/qemu-system-x86_64 \
    -m ${VM_RAM} -smp ${VM_CPU},sockets=1,cores=1,threads=1 \
    -name kvm \
    -msg timestamp=on \
    -enable-kvm \
    -nodefaults \
    -no-hpet \
    -nographic \
    -global kvm-pit.lost_tick_policy=discard \
    -machine q35,accel=kvm,vmport=off,dump-guest-core=off,kernel_irqchip,nousb,nosmm \
    -global ICH9-LPC.disable_s3=1 \
    -global ICH9-LPC.disable_s4=1 \
    -bios /usr/share/OVMF/OVMF_CODE.fd \
    -device virtio-blk-pci,drive=drive-virtio-disk0,scsi=off \
    -device virtio-net-pci,netdev=net0,mac=${MAC} \
    -device virtio-rng-pci,rng=objrng0 \
    -device virtio-9p-pci,fsdev=fsdev0,mount_tag=root9p \
    -device virtio-serial-pci,id=virtio-serial0 \
    -chardev pty,id=charconsole0 \
    -device virtconsole,chardev=charconsole0 \
    -serial mon:stdio \
    -drive file=/var/lib/kvm/kvm.qcow2,format=qcow2,if=none,id=drive-virtio-disk0 \
    -fsdev local,security_model=passthrough,id=fsdev0,path=/ \
    -netdev tap,id=net0,vhost=on,fd=3 \
    -object rng-random,id=objrng0,filename=/dev/urandom \
    -realtime mlock=off \
    -rtc base=utc,driftfix=slew \
    -kernel /vmlinuz \
    -initrd /initrd.img \
    -append "init=/bin/bash root=root9p rootfstype=9p rootflags=trans=virtio rw console=ttyS0 quiet fsck.mode=skip cgroup_enable=memory swapaccount=1 vsyscall=emulate tsc=reliable no_timer_check noreplace-smp rcupdate.rcu_expedited=1 clocksource=kvm-clock iommu=false pci=lastbus=0 noresume ip=${IPCMD}${RESOLV_STR}" \
    3<>/dev/macvtap${RANDOM_ID}

