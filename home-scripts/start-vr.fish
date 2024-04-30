#!/usr/bin/env fish

echo "Starting VR environment..."
distrobox enter --name "alvr" -- fish -c (realpath ./scripts/start-vr-inner.fish)