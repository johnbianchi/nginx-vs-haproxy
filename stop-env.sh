#!/bin/bash
docker ps -aq | xargs docker stop
