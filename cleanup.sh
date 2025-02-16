#!/bin/bash

echo "░   ▒  ▓▐Cleaning up..."

sudo docker-compose down

sudo rm -rf couchdb-data couchdb-etc setupuri.txt 