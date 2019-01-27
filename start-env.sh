#!/bin/bash

# OPTIONS
# DRYRUN
# Running with DRYRUN will not run the commands, but print them.
# VERBOSE
# Running with VERBOSE will add addition output you may want for debugging or extra verbage.

function info() {
  echo -e "\e[32mINFO: $@\e[0m"
}

[[ $VERBOSE ]] && info "move into directory where the script is"
CWD="$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )"
[[ $VERBOSE ]] && info "CWD: ${CWD}"


[[ $VERBOSE ]] && info "define NETWORK_NAME"
NETWORK_NAME="test-lan"
[[ $VERBOSE ]] && info "NETWORK_NAME: ${NETWORK_NAME}"
if [[ $(docker network ls | grep ${NETWORK_NAME}) ]]; then
  info "found docker network: ${NETWORK_NAME}"
else
  info "did not find docker network, creating docker network: ${NETWORK_NAME}"
  ${DRYRUN:+echo} docker network create ${NETWORK_NAME}
fi

info 'stand up three httpd hosts, httpd-01 - httpd-03'
for host in 01 02 03; do
  info "creating httpd-${host}"
  ${DRYRUN:+echo} docker run -dit --name=httpd-${host} --net=${NETWORK_NAME} --log-driver=json-file --user=root -v "$CWD/html/":/usr/local/apache2/htdocs/:rw httpd:2.4-alpine
done

info 'stand up haproxy'
${DRYRUN:+echo} docker run -dit --name=haproxy --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/haproxy/":/usr/local/etc/haproxy/:rw -p 9001:80 haproxy:1.8-alpine

info 'stand up nginx'
${DRYRUN:+echo} docker run -dit --name=nginx --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/nginx/":/etc/nginx/:rw -p 9002:80 nginx:1.15-alpine
