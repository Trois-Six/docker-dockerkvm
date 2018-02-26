FROM debian:buster

COPY setup_initramfs.sh /usr/local/bin/setup_initramfs.sh
RUN chmod u+x /usr/local/bin/setup_initramfs.sh

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-kvm iproute2 ovmf curl apt-transport-https ca-certificates cgroupfs-mount gnupg initramfs-tools linux-image-amd64 linux-headers-amd64 qemu-utils e2fsprogs && \
    /usr/local/bin/setup_initramfs.sh && \
    update-initramfs -k all -u && \
    curl -qs https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce && \
    mkdir -p /etc/docker && \
    echo "{\n    \"bridge\": \"none\",\n    \"iptables\": false\n}" > /etc/docker/daemon.json && \
    apt-get clean && \
    find /var/lib/apt/lists /tmp -maxdepth 1 -mindepth 1 -print0 2>/dev/null | xargs -r0 rm -rf
    
RUN mkdir -p /var/lib/kvm && \
    qemu-img create -f raw /var/lib/kvm/kvm.img 10000000000 && \
    mkfs -t ext4 /var/lib/kvm/kvm.img && \
    qemu-img convert -O qcow2 -c /var/lib/kvm/kvm.img /var/lib/kvm/kvm.qcow2 && \
    rm -f /var/lib/kvm/kvm.img

COPY start_vm.sh /usr/local/bin/start_vm.sh
RUN chmod u+x /usr/local/bin/start_vm.sh
COPY bashrc /.bashrc

COPY Dockerfile /root/Dockerfile

ENV VM_CPU ${VM_CPU:-1}
ENV VM_RAM ${VM_RAM:-1024}

ENTRYPOINT ["/usr/local/bin/start_vm.sh"]
