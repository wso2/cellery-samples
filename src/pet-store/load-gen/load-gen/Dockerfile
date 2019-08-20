FROM ubuntu:16.04

ENV DURATION 2m
ENV CONCURRENCY=40
ENV PET_STOE_BE_CELL_URL=""

RUN apt-get update && apt-get install -y curl wget telnet iputils-ping dnsutils net-tools netcat iptables

RUN wget https://storage.googleapis.com/hey-release/hey_linux_amd64
RUN mv hey_linux_amd64 /usr/local/bin/hey
RUN chmod +x /usr/local/bin/hey

COPY load-test.sh /load-test.sh
RUN chmod +x load-test.sh

ENTRYPOINT ["/bin/bash", "-c", "./load-test.sh"]
