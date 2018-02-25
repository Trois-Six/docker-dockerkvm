FROM debian:buster

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-kvm iproute2 ovmf curl apt-transport-https ca-certificates cgroupfs-mount gnupg linux-image-amd64 linux-headers-amd64

RUN curl -qs https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce && \
    mkdir -p /etc/docker && \
    echo "{\n    \"bridge\": \"none\",\n    \"iptables\": false\n}" > /etc/docker/daemon.json

RUN apt-get clean && \
    find /var/lib/apt/lists /tmp -maxdepth 1 -mindepth 1 -print0 2>/dev/null | xargs -r0 rm -rf
    
VOLUME /var/lib/kvm
COPY kvm.initrd /var/lib/kvm/kvm.initrd
COPY kvm.vmlinuz /var/lib/kvm/kvm.vmlinuz
COPY kvm.qcow2 /var/lib/kvm/kvm.qcow2
COPY startvm /usr/local/bin/startvm
RUN chmod u+x /usr/local/bin/startvm
COPY bashrc /.bashrc
COPY Dockerfile /root/Dockerfile

ENV VM_CPU ${VM_CPU:-1}
ENV VM_RAM ${VM_RAM:-1024}

ENTRYPOINT ["/usr/local/bin/startvm"]
