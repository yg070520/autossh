#!/usr/bin/dumb-init /bin/sh

# Determine command line flags

# Default SSH_REMOTE_HOST when not provided
SSH_REMOTE_HOST=${SSH_REMOTE_HOST:-i.jatus.top}

# Default SSH_TARGET_HOST: prefer host.docker.internal, fallback to gateway
if [ -z "${SSH_TARGET_HOST}" ]; then
    # Prefer Docker's host.docker.internal when available
    if getent hosts host.docker.internal >/dev/null 2>&1; then
        SSH_TARGET_HOST=host.docker.internal
    else
        # Fall back to the default route gateway IP, then to common bridge gateway
        SSH_TARGET_HOST=$(ip route 2>/dev/null | awk '/default/ {print $3}')
        SSH_TARGET_HOST=${SSH_TARGET_HOST:-172.17.0.1}
    fi
fi

# Log to stdout
echo "[INFO ] Using $(autossh -V)"
echo "[INFO ] Tunneling ${SSH_BIND_IP:=127.0.0.1}:${SSH_TUNNEL_PORT:=${DEFAULT_PORT}}" \
    " on ${SSH_REMOTE_USER:=root}@${SSH_REMOTE_HOST:=localhost}:${SSH_REMOTE_PORT}" \
    " to ${SSH_TARGET_HOST=localhost}:${SSH_TARGET_PORT:=22}"

COMMAND="autossh \
     -M 0 \
     -N  \
     -o StrictHostKeyChecking=no \
     -o ServerAliveInterval=10 \
     -o ServerAliveCountMax=3 \
    -o ExitOnForwardFailure=yes \
    -R ${SUBDOMAIN}:${SSH_TARGET_PORT}:${SSH_TARGET_HOST}:${SSH_TARGET_PORT} \
     -p 8888 \
     ${SSH_REMOTE_HOST} \
"

echo "[INFO ] # ${COMMAND}"

# Run command
exec ${COMMAND}
