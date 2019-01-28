#!/bin/bash

# OPTIONS
# DRYRUN
# Running with DRYRUN will not run the commands, but print them.
# VERBOSE
# Running with VERBOSE will add addition output you may want for debugging or extra verbage.

function info() {
  echo -e "\e[32mINFO: $@\e[0m"
}

[[ -n ${VERBOSE} ]] && info "get directory where the script is running from" # caveats
CWD="$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )"
[[ -n ${VERBOSE} ]] && info "CWD: ${CWD}"


[[ -n ${VERBOSE} ]] && info "define NETWORK_NAME"
NETWORK_NAME="test-lan"
[[ -n ${VERBOSE} ]] && info "NETWORK_NAME: ${NETWORK_NAME}"
if [[ $(docker network ls | grep ${NETWORK_NAME}) ]]; then
  info "found docker network: ${NETWORK_NAME}"
else
  info "did not find docker network, creating docker network: ${NETWORK_NAME}"
  ${DRYRUN:+echo} docker network create ${NETWORK_NAME}
fi

info 'stand up three httpd nodes, httpd-01 - httpd-03'
for node in 01 02 03; do
  info "creating httpd-${node}"
  ${DRYRUN:+echo} mkdir -p ${VERBOSE+ -v} html/${node}
  # if not dryrun, write to the node file
  [[ -n ${VERBOSE} ]] && info "creating node index.html"
  [[ -z ${DRYRUN} ]] && echo -e "Hello from httpd-${node}" > html/${node}/index.html
  ${DRYRUN:+echo} docker run -dit --name=httpd-${node} --net=${NETWORK_NAME} --log-driver=json-file --user=root -v "${CWD}/html/${node}/":/usr/local/apache2/htdocs/:rw httpd:2.4-alpine
done

info 'stand up haproxy'
${DRYRUN:+echo} docker run -dit --name=haproxy --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/haproxy/":/usr/local/etc/haproxy/:rw -v /var/run/haproxy:/var/run/haproxy -p 9001:80 haproxy:1.8-alpine

info 'stand up nginx'
${DRYRUN:+echo} docker run -dit --name=nginx --log-driver=json-file --net=${NETWORK_NAME} -v "${CWD}/nginx/":/etc/nginx/:rw -p 9002:80 nginx:1.15-alpine
