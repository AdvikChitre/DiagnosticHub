#!/bin/bash
set -e

# get DB_PASSWORD
source .env

# Start database
echo "Initializing database..."
brew install mariadb
brew services start mariadb
# TODO: replace 'root' and 'password' with .env variables
mysql -u root -p < database/schema.sql

# Wait to let database initialise
sleep 5

# Start server
echo "Starting the Node.js server..."
node server/server.js