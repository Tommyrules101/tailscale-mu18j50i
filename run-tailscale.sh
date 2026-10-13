#!/usr/bin/env bash

# 1. FIXED: Changed back to userspace-networking so Render won't crash on /dev/net/tun.
# Added --snat-subnet-routes=false to cleanly pass exit-node network states over the proxy layer.
/render/tailscaled \
  --tun=userspace-networking \
  --socks5-server=localhost:1055 \
  --snat-subnet-routes=false &
PID=$!

# Allow the daemon a moment to initialize safely
sleep 2

# 2. Authenticate the node and advertise the exit node capabilities
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
