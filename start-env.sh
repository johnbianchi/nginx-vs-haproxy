#!/bin/bash

function info () {
  info "\e[32mINFO:\e[0m $1"
}

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NETWORK_NAME="test-lan"
if [[ $(docker network ls | grep ${NETWORK_NAME}) ]]; then
  info "found docker network: ${NETWORK_NAME}"
else
  info "did not find docker network, creating docker network: ${NETWORK_NAME}"
  docker network create ${NETWORK_NAME}
fi

echo 'stand up three httpd hosts, httpd-01 - httpd-03'
for host in 01 02 03; do
  info "creating httpd-${host}"
  docker run -dit --name=httpd-${host} --net=${NETWORK_NAME} --log-driver=json-file -v "$CWD/html/":/usr/local/apache2/htdocs/:rw httpd:2.4.34-alpine
done

info 'stand up haproxy'
docker run -dit --name=haproxy --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/haproxy/":/usr/local/etc/haproxy/:rw -p 9001:80 haproxy:1.8-alpine

info 'stand up nginx'
docker run -dit --name=nginx --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/nginx/":/etc/nginx/:rw -p 9002:80 nginx:1.15.2-alpine
