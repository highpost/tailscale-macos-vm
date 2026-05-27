#!/bin/zsh

# VM launch script

# Fetch the Tailscale auth key from Apple Keychain
# and store it in a local variable.
TS_KEY_VAL="$(
  security find-generic-password                        \
             -s "tailscale-auth-key-dev-server"         \
             -w
)"

# launch the VM
ORBENV=TS_KEY_VAL orb -m dev-server sudo tailscale up                      \
                                           --ssh                           \
                                           --advertise-tags=tag:myservers  \
                                           --authkey="$TS_KEY_VAL"

# cleanup
unset TS_KEY_VAL
