#!/usr/bin/env bash
# Build and run vuln-django with Nginx and PostgreSQL
set -ex

# We’ll use this `docker-compose exec` command a lot...
EXEC_CMD='docker-compose --file docker-micro.yml exec vuln-django'

# Build docker images, in particular the vuln-django container
docker-compose -f docker-micro.yml build

# Launch the app, PostgreSQL and Nginx
docker-compose -f docker-micro.yml up --detach

# Wait for the database, using netcat to ping it
echo Wait for database to become available...
while ! ${EXEC_CMD} bash -c 'nc -z "${SQL_HOST}" "${SQL_PORT}"'; do
  sleep 0.5
done
echo Database ready!

# Run database migrations to build tables
${EXEC_CMD} python manage.py migrate

# Create Django admin user from DJANGO_SUPERUSER_ environment variables
${EXEC_CMD} python manage.py createsuperuser --no-input

# Seed database with test data
${EXEC_CMD} python manage.py seed polls --number=5

# Run unit tests
${EXEC_CMD} python manage.py test

