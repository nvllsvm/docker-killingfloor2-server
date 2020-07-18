FROM ubuntu:18.04
LABEL url="https://github.com/nvllsvm/docker-killingfloor2-server"

RUN apt-get -y update \
 && apt-get -y install wget lib32gcc1 libcurl4 \
 && apt-get clean \
 && find /var/lib/apt/lists -type f | xargs rm -vf

# Query - used to communicate with the master server
EXPOSE 27015/udp

# Game - primary comms with players
EXPOSE 7777/udp

# Web Admin
EXPOSE 8080/tcp

ENV KF_PORT=7777 \
    KF_QUERY_PORT=27015 \
    KF_WEBADMIN_PORT=8080

VOLUME /data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
