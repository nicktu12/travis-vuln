# Create the base stage
FROM python:3.7-buster as base

COPY requirements.txt /opt/app/
COPY vuln_django/ /opt/app/vuln_django/vuln_django
COPY static/ /opt/app/vuln_django/static
COPY templates/ /opt/app/vuln_django/templates
COPY polls/ /opt/app/vuln_django/polls
COPY manage.py /opt/app/vuln_django/

RUN pip install -r /opt/app/requirements.txt

# Create the micro stage to run as a gunicorn container
FROM base as micro
ARG SERVER_PORT=8010
ENV SERVER_PORT=${SERVER_PORT}
EXPOSE ${SERVER_PORT}:${SERVER_PORT}
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    netcat
WORKDIR /opt/app/vuln_django
CMD exec gunicorn vuln_django.wsgi --bind 0.0.0.0:${SERVER_PORT} --workers 3

