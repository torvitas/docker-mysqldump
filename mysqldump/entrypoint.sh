#!/bin/bash

DATABASE_HOST=${DATABASE_HOST:-}
DATABASE_NAME=${DATABASE_NAME:-}
DATABASE_USER=${DATABASE_USER:-}
DATABASE_PASSWORD=${DATABASE_PASSWORD:-}
MYSQLDUMP_BINARY=${MYSQLDUMP_BINARY:mysqldump}
SSH_HOST=${SSH_HOST:-}
SSH_USER=${SSH_USER:-}

if [[ -z ${DATABASE_HOST} ]] || [[ -z ${DATABASE_NAME} ]] || [[ -z ${DATABASE_USER} ]] || [[ -z ${DATABASE_PASSWORD} ]]; then
  echo "ERROR: "
  echo "  Please configure the database connection."
  exit 1
fi
if [[ -z ${SSH_USER} ]] || [[ -z ${SSH_HOST} ]]; then
  echo "ERROR: "
  echo "  Please configure the ssh connection."
  exit 1
fi
if [ ! -f /root/.ssh/id_rsa ]; then
  mkdir -p /root/.ssh
  chmod 600 -R /root/.ssh
  ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
  ssh-keyscan -H live.spectra.de >> /root/.ssh/known_hosts
  ssh-copy-id ${SSH_USER}@${SSH_HOST}
fi

ssh ${SSH_USER}@${SSH_HOST} \
    "${MYSQLDUMP_BINARY} -u${DATABASE_USER} -h${DATABASE_HOST} ${DATABASE_NAME} -p${DATABASE_PASSWORD} \
        --skip-opt \
        --add-drop-table \
        --add-locks \
        --create-options \
        --disable-keys \
        --extended-insert \
        --default-character-set=utf8 \
        --set-charset | gzip -9" > /var/dumps/dump.$(date +%s).${DATABASE_NAME}.sql.gz
chown 1000 /var/dumps/dump.*
exec "$@"
