#!/usr/bin/env sh

echo "Starting VR environment..."
echo "Remember to start SteamVR through ALVR!"
echo "Quitting ALVR will exit Steam and shut down the container."

sleep 3
distrobox enter --name "alvr" -- sh -c ./scripts/start-vr-inner.sh
distrobox stop "alvr" --yes