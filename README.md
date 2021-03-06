docker-dockerkvm
===============

![Logo](https://raw.githubusercontent.com/Trois-Six/docker-dockerkvm/master/logo.png)

Heavily based on https://github.com/BBVA/kvm.

## Build
    git clone https://github.com/Trois-Six/docker-dockerkvm.git
    docker build -t dockerkvm:buster docker-dockerkvm

## Run
    docker run -it -e VM_CPU=1 -e VM_RAM=256 -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster

[![asciicast](https://asciinema.org/a/25kxINRaLYyS7Uys2tT8eH9U4.png)](https://asciinema.org/a/25kxINRaLYyS7Uys2tT8eH9U4)

## Create asciicast gif
    LANG=C
    script -ttimings
    git clone https://github.com/Trois-Six/docker-dockerkvm.git
    docker build -t dockerkvm:buster docker-dockerkvm
    docker run -it -e VM_CPU=1 -e VM_RAM=256 -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster
    exit
    teseq -ttimings typescript > docker-dockerkvm/asciinema/session.tsq
    # modify docker-dockerkvm/asciinema/session.tsq to prettify video
    # test results with `reseq docker-dockerkvm/asciinema/session.tsq --replay`
    rm -f timings typescript docker-dockerkvm/asciinema/session.json
    asciinema rec -c 'reseq docker-dockerkvm/asciinema/session.tsq --replay' -t "docker in kvm in docker"
    #asciinema rec -c 'reseq docker-dockerkvm/asciinema/session.tsq --replay' docker-dockerkvm/asciinema/session.json
    #docker pull asciinema/asciicast2gif
    #docker run --rm -v $PWD:/data asciinema/asciicast2gif -t monokai docker-dockerkvm/asciinema/session.json docker-dockerkvm/asciinema/session.gif
