#!/bin/sh
# Adapted from Alex Kleissner's post, Running a Phoenix 1.3 project with docker-compose
# https://medium.com/@hex337/running-a-phoenix-1-3-project-with-docker-compose-d82ab55e43cf

set -e

# Potentially Set up the database
mix ecto.reset

#echo "\nTesting the installation..."
# "Proove" that install was successful by running the tests
#mix test


echo "\n Launching Phoenix web server..."
# Start the phoenix web server
mix phx.server
