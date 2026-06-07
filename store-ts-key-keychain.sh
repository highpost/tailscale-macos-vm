#!/bin/zsh

# Copy a Tailscale auth key from the system clipboard to Apple Keychain.
# https://login.tailscale.com/admin/settings/keys
#
# NB: Due to constraints imposed by Apple's Security Framework, this script
#     must be run directly from a Mac-based terminal and not remotely through
#     SSH.
#
# NB: The Tailscale auth key will not appear in the Passwords app.
#     Instead use Keychain Access through Spotlight.

echo -n "paste the Tailscale auth key: " && read -rs TEMP_KEY

security add-generic-password                     \
           -a "$USER"                             \
           -s "tailscale-auth-key-dev-server"     \
           -w "$TEMP_KEY"

unset TEMP_KEY
