##!/usr/bin/env bash

# 1. CHANGED: Switched to userspace-route so it can route exit node traffic
/render/tailscaled --tun=userspace-route --socks5-server=localhost:1055 &
PID=$!

# Allow the daemon a moment to initialize
sleep 2

# 2. CHANGED: Added --advertise-exit-node. 
# Also removed the 'until' loop so it cleanly prints a login link once if TAILSCALE_AUTHKEY is empty.
ADVERTISE_ROUTES=${ADVERTISE_ROUTES:-10.0.0.0/8}
/render/tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${RENDER_SERVICE_NAME}" \
  --advertise-routes="$ADVERTISE_ROUTES" \
  --advertise-exit-node

export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/render/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"

wait ${PID}
