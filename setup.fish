#!/usr/bin/env fish
clear
echo "Welcome to the ALVR Distrobox setup script!"

# Import external functions
source ./functions/check-dependency.fish

# Check dependencies
check-dependency jq
check-dependency wget
check-dependency curl
check-dependency xhost
check-dependency pkexec
check-dependency pw-cli
check-dependency podman
check-dependency distrobox

echo "Dependencies checked successfully!"

# AMD GPU only reminder
echo
echo "As a reminder: This script is designed for AMD GPUs only!"
read -l -P "Press enter to continue..." > /dev/null

# Pay attention!!
clear
echo "Another friendly reminder, please read carefully each instruction!"
echo "Using this script incorrectly will probably result in a broken container."
read -l -P "Press enter to continue..." > /dev/null

# Get the home path for the container
clear
echo "Please specify the container's home folder!"
echo "Arch Linux itself and Steam's dependencies will be installed to your home folder."
echo "While it is impossible to change this, specifying the container's home folder will determine where Steam itself and its apps will be stored."
echo "Warning: This path must contain no spaces! This is due to a bug in SteamVR."
read -P "Please enter an absolute path (e.g. '/mnt/Games/ALVR'): " homepath

# Creating container
clear
echo "Creating container..."
distrobox create --pull --image docker.io/archlinux/archlinux:latest \
    --name "alvr" --home $homepath

# Phase 1
distrobox enter --name "alvr" -- bash -c (realpath ./container-setup/phase1.bash)

# Phase 2
distrobox enter --name "alvr" -- fish -c (realpath ./container-setup/phase2.fish)

echo
echo "Rebooting container..."
distrobox stop "alvr" --yes

# Phase 3
distrobox enter --name "alvr" -- fish -c (realpath ./container-setup/phase3.fish)
