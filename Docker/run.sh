#!/bin/bash

if [ -f "/.env" ]; then
  echo "Loading environment variables from /.env"
  set -a
  source /.env
  set +a
else
  echo "No /.env file found"
fi


ROOT_PASSWORD=${ROOT_PASSWORD:-"root"}
TZ=${TZ:-"America/New_York"}
DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"}
LANG=${LANG:-"en_US.UTF-8"}
LANGUAGE=${LANGUAGE:-"en_US:en"}
LC_ALL=${LC_ALL:-"en_US.UTF-8"}

export ROOT_PASSWORD TZ DEBIAN_FRONTEND LANG LANGUAGE LC_ALL

echo "Using timezone: ${TZ}"
echo "Using language: ${LANG}"

start_xrdp_services() {
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid
    xrdp-sesman && exec xrdp -n
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
    echo "Timezone set to $TZ"
fi

if [ -n "$LANG" ]; then
    echo "Setting up locale: $LANG"
    update-locale LANG=$LANG LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL 2>/dev/null || true
fi

# Set up user and password
if id "root" &>/dev/null; then
    echo "root:${ROOT_PASSWORD}" | chpasswd || { echo "Failed to update password."; exit 1; }
else
    if ! getent group root >/dev/null; then
        addgroup root
    fi
    useradd -m -s /bin/bash -g root root || { echo "Failed to create user."; exit 1; }
    echo "root:${ROOT_PASSWORD}" | chpasswd || { echo "Failed to set password."; exit 1; }
    usermod -aG sudo root || { echo "Failed to add user to sudo."; exit 1; }
fi

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services
