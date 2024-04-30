#!/usr/bin/env fish
echo "Welcome to the ALVR Distrobox setup script!"

# Import external functions
source ./functions/check-dependency.fish

# Check dependencies
check-dependency vulkaninfo

echo "Dependencies checked successfully!"