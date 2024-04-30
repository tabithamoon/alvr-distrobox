#!/usr/bin/env bash
clear
echo Executing phase 1...
echo Updating all packages...
sudo pacman -Syu --noconfirm

echo
echo Installing fish...
sudo pacman -S fish --noconfirm

exit