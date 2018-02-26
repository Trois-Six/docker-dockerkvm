docker-dockerkvm
===============

Heavily based on https://github.com/BBVA/kvm.

## Build
    git clone https://github.com/Trois-Six/docker-dockerkvm.git
    cd docker-dockerkvm
    docker build -t dockerkvm:buster .

## Run
    docker run -it -e VM_CPU=1 -e VM_RAM=256 -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -p 8080:80 --privileged dockerkvm:buster
    docker run -dt -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster

## Create asciicast gif
    LANG=C
    script -ttimings
    git clone https://github.com/Trois-Six/docker-dockerkvm.git
    cd docker-dockerkvm
    docker build -t dockerkvm:buster .
    docker run -it -e VM_CPU=1 -e VM_RAM=256 -e VMDOCKER_IMG=httpd -e VMDOCKER_ENV="-e VIRTUALHOST=test" -p 8080:80 --privileged dockerkvm:buster
    exit
    cd ..
    teseq -ttimings typescript > docker-dockerkvm/asciinema/session.tsq
    # modify docker-dockerkvm/asciinema/session.tsq to prettify video
    # test results with `reseq docker-dockerkvm/asciinema/session.tsq --replay`
    rm -f timings typescript docker-dockerkvm/asciinema/session.json
    asciinema rec -c 'reseq docker-dockerkvm/asciinema/session.tsq --replay' docker-dockerkvm/asciinema/session.json
    docker pull asciinema/asciicast2gif
    docker run --rm -v $PWD:/data asciinema/asciicast2gif -t monokai docker-dockerkvm/asciinema/session.json docker-dockerkvm/asciinema/session.gif
