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

# Copy permanent scripts to container home
cp -R ./home-scripts/* $homepath/

# Shut down container
distrobox stop "alvr" --yes

# We're done! Infodump a little...
clear
echo "Installation is ready!"
echo "To play VR games, go to the container's home folder ($homepath in your setup) and run ./start_vr.fish to start Steam and ALVR."
echo
echo "Some tips:"
echo "- AMD GPUs don't automatically go into their VR power profile on Linux, leading to poor performance and stutters."
echo "  - To fix this, use an app like CoreCtrl, or manually set the PowerPlay profile (probably just use CoreCtrl >.>)"
echo "- Loading videos in VRChat can sometimes freeze the client for a few seconds at a time"
echo "  - This is unfortunately a known bug that cannot be worked around"
echo "- The SteamVR patches will be cleared when it gets updated"
echo "  - You can try just running it as-is"
echo "    - If you run into issues, run ./repatch_steamvr.fish also located in the container home (again, you put it at $homepath)"
echo "- ALVR's default settings are pretty bad"
echo "  - I recommend using the HEVC encoder always if you have hardware encoding support for it"
echo "    - AMD's H.264 encoder is notoriously bad and leads to pretty crap quality without huge bitrates"
echo "  - If you have good Wi-Fi, set the bitrate between 100 and 150 Mbps"
echo "    - Greater than that without foveated encoding seems to overwhelm Quest 2 (I don't have a Quest 3 to test qwq)"
echo "  - And really, just play around with the sliders!"
echo "    - If you break something horribly, you can delete the container's home folder, and delete the container with:"
echo "      - distrobox stop alvr --yes && distrobox rm alvr"
echo
echo "The fish shell is no longer required outside the container if you wish to uninstall it."
echo "You can now run the startup script and pair your headset to ALVR and start playing. Have fun!"