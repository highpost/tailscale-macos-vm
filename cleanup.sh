#!/bin/zsh

# manual removal:
#   * remove the VM node from your tailnet:
#     https://login.tailscale.com/admin/machines
#   * remove the auth key
#     https://login.tailscale.com/admin/settings/keys

# revoke the Tailscale node's identity
orb -m dev-server sudo tailscale logout || true

# remove the container images
orb delete dev-server

# remove the Tailscale auth key from Keychain
security delete-generic-password                   \
           -s "tailscale-auth-key-dev-server"
