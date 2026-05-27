#!/bin/zsh

# Copy a Tailscale auth key from the system clipboard to Apple Keychain.
# https://login.tailscale.com/admin/settings/keys
#
# NB: The Tailscale auth key will not appear in the Passwords app.
#     Instead use Keychain Access through Spotlight.

echo -n "paste the Tailscale auth key: " && read -rs TEMP_KEY

security add-generic-password                     \
           -a "$USER"                             \
           -s "tailscale-auth-key-dev-server"     \
           -w "$TEMP_KEY"

unset TEMP_KEY
