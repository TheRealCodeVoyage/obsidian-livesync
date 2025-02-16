#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "░   ▒  ▓▐Preparing environment variables..."

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "!!! ERROR: .env file not found!"
  exit 1
fi

# Create CouchDB data and config directories
mkdir -p couchdb-data couchdb-etc
sudo chmod -R 770 couchdb-data couchdb-etc
sudo chown -R 5984:5984 couchdb-data couchdb-etc

echo "░   ▒  ▓▐Initiatalizing CouchDB..."

sudo docker-compose up -d

for i in {5..0}; do
  echo "░   ▒  ▓▐CouchDB Container is Being Started! Waiting ${i} seconds..."
  sleep 1
  if [ $i -eq 0 ]; then
    echo "░   ▒  ▓▐CouchDB Container is 100% Running! Configuring it now..."
    sleep 1
    fi
done

echo "░   ▒  ▓▐Configuring CouchDB..."

# Generate the setup URI and passphrase
export hostname="http://obsidian.c0d3v0y463.com:5984"
export username=${COUCHDB_USER}
export password=${COUCHDB_PASSWORD}
export database=${COUCHDB_DB_NAME}

# Run CouchDB initialization script
curl -s https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh | bash

echo "░   ▒  ▓▐CouchDB initialization complete."

echo "░   ▒  ▓▐Generating setup URI and passphrase..."

export hostname="https://obsidian.c0d3v0y463.com"

for i in {10..0}; do
  echo "░   ▒  ▓▐Waiting for SSL/TLS Certificate to Be Generated in...${i}"
  sleep 1
  if [ $i -eq 0 ]; then
    echo "░   ▒  ▓▐Assuming SSL/TLS Certificate is Generated Now..."
    sleep 1
    fi
done

echo "░   ▒  ▓▐Checking if Deno is installed..."
# Check if Deno is installed  
if [ -x "$(command -v deno)" ]; then
  echo "░   ▒  ▓▐Deno is installed."  
else  
  echo "!!! ERROR: Deno is not installed!"
  echo "░   ▒  ▓▐Installing Deno..."
  curl -fsSL https://deno.land/install.sh | sudo sh
fi

deno=$(which deno)

deno run -A https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/flyio/generate_setupuri.ts > setupuri.txt

echo "░   ▒  ▓▐Setup URI and passphrase generated!"
echo "$(cat setupuri.txt)"

read -p '░   ▒  ▓▐Do Want to Observe Docker logs? (y/n) ' input
if [ "$input" = "y" -o "$input" = "Y" ]; then
  echo "░   ▒  ▓▐Starting docker logs..."
  sudo docker logs -f obsidian-livesync
fi

echo "░   ▒  ▓▐Done!"

exit 0