docker-dockerkvm
===============

Heavily based on https://github.com/BBVA/kvm.
Packages needed to build : debootstrap, coreutils, qemu-utils, e2fsprogs

## Build vm
    cd vm
    sudo ./create_img.sh
    sudo mv kvm.* ../docker/

## Build
    cd ../docker
    docker build -t dockerkvm:buster .

## Run
    docker run -it -e VM_CPU=1 -e VM_RAM=256 -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster

