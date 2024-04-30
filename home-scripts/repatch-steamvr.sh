#!/usr/bin/env sh

echo "Entering VR environment..."

distrobox enter --name "alvr" -- fish -c ./scripts/repatch-steamvr-inner.fish