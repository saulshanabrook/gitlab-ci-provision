#!/bin/sh
set -o xtrace

docker rm -v $(docker ps -a --filter status=exited --filter status=created -q) || true
docker volume rm $(docker volume ls -f dangling=true -q) || true
