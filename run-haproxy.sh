#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ $(docker network ls | grep network) ]]; then
  echo 'found network'
else
  echo 'did not find network, creating network'
  docker network create network
fi

docker run -dit --name=apache-01 --net=network --log-driver=json-file -v "$CWD/html/":/usr/local/apache2/htdocs/:ro httpd:2.4-alpine
docker run -dit --name=apache-02 --net=network --log-driver=json-file -v "$CWD/html/":/usr/local/apache2/htdocs/:ro httpd:2.4-alpine
docker run -dit --name=haproxy --log-driver=json-file --net=network -v "${CWD}/haproxy/haproxy.cfg":/usr/local/etc/haproxy/haproxy.cfg:ro -p 8080:80 haproxy:1.8-alpine
