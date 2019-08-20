FROM python:3.7.4-slim@sha256:4b0cd7cc8a201bd8098adbb2f2ffef55eec1364297b0c1c6630cc4dee41739e3

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/ \
    PORT=8888

EXPOSE $PORT

# add a non-privileged user for installing and running
# the application
RUN mkdir /app && \
    chown 10001:10001 /app && \
    groupadd --gid 10001 app && \
    useradd --no-create-home --uid 10001 --gid 10001 --home-dir /app app

COPY requirements/default.txt .
COPY requirements/prod.txt .
COPY requirements/constraints.txt .
COPY bin/docker-install.sh .
RUN ./docker-install.sh

COPY . /app

# Switch back to home directory
WORKDIR /app

# Drop down to unprivileged user
RUN chown -R 10001:10001 /app

# Make sure the kinto user can write into the mail directory for
# when it debugs email sending.
#RUN chown kinto: /app/mail

USER 10001


# Run uwsgi by default
ENTRYPOINT ["/bin/bash", "/app/bin/run.sh"]
CMD ["uwsgi", "--ini", "/etc/kinto.ini"]
