#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d
echo created /docker-entrypoint-initdb.d

chmod +x /docker-entrypoint-initdb.d/initdb.sh
echo added execution rights to initdb.sh

/usr/local/bin/docker-entrypoint.sh postgres