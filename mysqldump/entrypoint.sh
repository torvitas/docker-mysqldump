#!/bin/bash

DATABASE_HOST=${DATABASE_HOST:-}
DATABASE_NAME=${DATABASE_NAME:-}
DATABASE_USER=${DATABASE_USER:-}
DATABASE_PASSWORD=${DATABASE_PASSWORD:-}
DATABASE_PORT=${DATABASE_PORT:-3306}
MYSQLDUMP_BINARY=${MYSQLDUMP_BINARY:-mysqldump}
SSH_HOST=${SSH_HOST:-}
SSH_USER=${SSH_USER:-root}
SSH_FLAGS=${SSH_FLAGS:-}

LOCAL_USER_UID=${LOCAL_USER_UID:-0}
LOCAL_USER=${LOCAL_USER:-root}
if [ "${LOCAL_USER}" != "root" ]; then
    echo "Creating user ${LOCAL_USER} with uid ${LOCAL_USER_UID}... "
    useradd ${LOCAL_USER} -mu ${LOCAL_USER_UID}
    chown -R ${LOCAL_USER}.${LOCAL_USER} /home/${LOCAL_USER}
    echo "done"
else
    ln -s /root /home/root
fi

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
if [ ! -f /home/${LOCAL_USER}/.ssh/id_rsa ]; then
  mkdir -p /home/${LOCAL_USER}/.ssh
  chmod 700 -R /home/${LOCAL_USER}/.ssh
  ssh-keygen -b 2048 -t rsa -f /home/${LOCAL_USER}/.ssh/id_rsa -q -N ""
  ssh-keyscan -H ${SSH_HOST} >> /home/${LOCAL_USER}/.ssh/known_hosts
  ssh-copy-id ${SSH_USER}@${SSH_HOST}
fi

chmod 700 -R /home/${LOCAL_USER}/.ssh
chown ${LOCAL_USER}.${LOCAL_USER} -R /home/${LOCAL_USER}/.ssh

HOME="/home/${LOCAL_USER}" sudo -u ${LOCAL_USER} -i -- ssh ${SSH_FLAGS} ${SSH_USER}@${SSH_HOST} \
    "${MYSQLDUMP_BINARY} -P${DATABASE_PORT} -u${DATABASE_USER} -h${DATABASE_HOST} ${DATABASE_NAME} -p'${DATABASE_PASSWORD}' \
        --skip-opt \
        --add-drop-table \
        --add-locks \
        --create-options \
        --disable-keys \
        --extended-insert \
        --default-character-set=utf8 \
        --set-charset \
        | gzip -9" > /var/dumps/dump.$(date +%s).${DATABASE_NAME}.sql.gz
chown ${LOCAL_USER} /var/dumps/dump.*
exec "$@"
