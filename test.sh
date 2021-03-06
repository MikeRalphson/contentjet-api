#!/bin/bash

set -e

function finish {
  docker stop contentjet-api-test > /dev/null
}
trap finish EXIT

tsc=./node_modules/.bin/tsc
knex=./node_modules/.bin/knex
mocha=./node_modules/.bin/mocha

export NODE_ENV=test
export SECRET_KEY=%%%%TEST%%%%
export MAIL_FROM=noreply@example.com
export MAIL_BACKEND=mailgun
export MAILGUN_API_KEY=not-a-real-key
export MAILGUN_DOMAIN=example.com
export DEBUG=0
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5431
export POSTGRES_DB=contentjet-api-test
export POSTGRES_PASSWORD=testpassword

if ! bash -c "docker start contentjet-api-test" 2> /dev/null;
then
  echo "Test database container doesn't exist, creating."
  docker run --name contentjet-api-test -p $POSTGRES_PORT:5432 -d -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD postgres:9.6.2
else
  echo "Test database container found!"
fi

$tsc

until $knex --knexfile dist/knexfile.js migrate:latest; do
  >&2 echo "**********************************"
  >&2 echo "Postgres is unavailable - sleeping"
  >&2 echo "**********************************"
  sleep 1
done

node dist/scripts/create-permissions.js

$mocha dist/**/*.test.js
