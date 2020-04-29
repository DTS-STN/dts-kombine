FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y ca-certificates
WORKDIR /usr/share/ca-certificates/letsencrypt.org
ADD https://letsencrypt.org/certs/isrgrootx1.pem ./
RUN update-ca-certificates
WORKDIR /home/heartbeat
ADD https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.6.2-amd64.deb ./heartbeat.deb
RUN dpkg -i ./heartbeat.deb
COPY ./config/heartbeat.yml /etc/heartbeat/heartbeat.yml
ADD VERSION ./VERSION
WORKDIR /usr/bin
CMD ["heartbeat"]