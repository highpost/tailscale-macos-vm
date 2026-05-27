#!/bin/zsh

# Use OrbStack and cloud-init to fetch the stable Ubuntu image,
# configure default shells, add users and then install/start
# the Tailscale daemon:

orb create ubuntu:25.10 dev-server -c dev-server.yml
orb -m dev-server cloud-init status --wait
