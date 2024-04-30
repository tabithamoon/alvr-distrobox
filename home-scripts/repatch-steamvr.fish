#!/usr/bin/env fish

echo "Entering VR environment..."
echo "Remember to start SteamVR through ALVR!"
echo "Quitting ALVR will exit Steam and shut down the container."

distrobox enter --name "alvr" -- sh -c (realpath ./scripts/start-vr-inner.sh)
distrobox stop "alvr" --yes