#!/usr/bin/dumb-init /bin/sh

# Determine command line flags

# Default SSH_REMOTE_HOST when not provided
SSH_REMOTE_HOST=${SSH_REMOTE_HOST:-i.jatus.top}

# Log to stdout
echo "[INFO ] Using $(autossh -V)"
echo "[INFO ] Tunneling ${SSH_BIND_IP:=127.0.0.1}:${SSH_TUNNEL_PORT:=${DEFAULT_PORT}}" \
    " on ${SSH_REMOTE_USER:=root}@${SSH_REMOTE_HOST:=localhost}:${SSH_REMOTE_PORT}" \
    " to ${SSH_TARGET_HOST=localhost}:${SSH_TARGET_PORT:=22}"

COMMAND="autossh \
     -M 0 \
     -N  \
     -o StrictHostKeyChecking= no \
     -o ServerAliveInterval= 10 \
     -o ServerAliveCountMax=3 \
     -o ExitOnForwardFailure=yes \
     -R ${SUBDOMAIN}:${SSH_TARGET_PORT}:localhost:${SSH_TARGET_PORT} \
     -p 8888 \
     ${SSH_REMOTE_HOST} \
"

echo "[INFO ] # ${COMMAND}"

# Run command
exec ${COMMAND}
