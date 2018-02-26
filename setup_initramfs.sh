#!/bin/bash

sed -i 's/^MODULES=most/MODULES=list/' /etc/initramfs-tools/initramfs.conf
cat > /etc/initramfs-tools/modules << __EOF__
virtio
virtio_pci
virtio_ring
virtio_blk
serio_raw
ext4
mbcache
virtio_net
9p
9pnet_virtio
__EOF__
cat > /etc/initramfs-tools/scripts/local-bottom/set_ip_resolv.sh << __EOF__
#!/bin/sh

set -e

PREREQ=""

prereqs()
{
    echo "\$PREREQ"
}

case \$1 in
    prereqs)
        prereqs
        exit 0
        ;;
esac

. /scripts/functions

parse_options()
{
    for x in \$(cat /proc/cmdline); do
        case \$x in
            resolv_nameservers=*)
                RESOLV_NAMESERVERS=\${x#resolv_nameservers=}
                ;;
            resolv_domain=*)
                RESOLV_DOMAIN=\${x#resolv_domain=}
                ;;
            resolv_searches=*)
                RESOLV_SEARCHES=\${x#resolv_searches=}
                ;;
        esac
    done
    export RESOLV_NAMESERVERS RESOLV_DOMAIN RESOLV_SEARCHES
}

set_resolvconf()
{
    if [ -n "\$RESOLV_NAMESERVERS" ]; then
        local IFS=":"
        for x in \$RESOLV_NAMESERVERS; do
            echo "nameserver \$x" >>\${rootmnt}/etc/resolv.conf
        done
    fi
    if [ -n "\$RESOLV_DOMAIN" ]; then
        echo "domain \$RESOLV_DOMAIN" >>\${rootmnt}/etc/resolv.conf
    fi
    if [ -n "\$RESOLV_SEARCHES" ]; then
        local IFS=":"
        resolv_search_str="search"
        for x in \$RESOLV_SEARCHES; do
            resolv_search_str="\$resolv_search_str \$x"
        done
        echo "\$resolv_search_str" >>\${rootmnt}/etc/resolv.conf
    fi
}

configure_networking
parse_options
set_resolvconf
unset RESOLV_NAMESERVERS RESOLV_DOMAIN RESOLV_SEARCHES
__EOF__
chmod +x /etc/initramfs-tools/scripts/local-bottom/set_ip_resolv.sh
update-initramfs -u

