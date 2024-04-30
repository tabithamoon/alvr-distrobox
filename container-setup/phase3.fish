#!/usr/bin/env fish

# Variables
set steamvr_processes vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup

clear
echo "Installing more required packages..."
sudo pacman -q --noprogressbar -Syu git vim base-devel noto-fonts xdg-user-dirs fuse libx264 sdl2 libva-utils xorg-server --noconfirm

echo "Installing paru..."
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg --noprogressbar -si --noconfirm
cd ..

echo
echo "Installing Steam and audio packages..."
sudo pacman -q --noprogressbar -Syu lib32-pipewire pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber libva-mesa-driver vulkan-radeon lib32-vulkan-radeon lib32-libva-mesa-driver --noconfirm
sudo pacman -q --noprogressbar -Syu steam --noconfirm --assume-installed vulkan-driver --assume-installed lib32-vulkan-driver

mkdir ~/.config
xdg-mime default steam.desktop x-scheme-handler/steam
steam steam://install/250820 &>/dev/null &

clear
echo "We are now launching Steam! Please log in and install SteamVR when requested."
echo "Installation will automatically continue when SteamVR is detected as installed."

while not test -e "$HOME/.steam/steam/steamapps/common/SteamVR/bin/vrwebhelper/linux64/vrwebhelper.sh"
    sleep 5
end

echo
echo "Waiting 10 seconds so Steam can finish up..."
sleep 10

echo "You will be prompted for superuser access to set a permission bit for a specific SteamVR binary."
echo "This prevents an annoying nag that stops SteamVR from launching directly."
read -l -P "Press enter to continue..." > /dev/null

distrobox-host-exec pkexec setcap CAP_SYS_NICE+ep "$HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher"

clear
echo "Running SteamVR once to generate files..."
steam steam://run/250820 &>/dev/null &

for process in vrmonitor vrserver
    while not pidof $process &>/dev/null
        sleep 1
    end
end

echo "Cleaning up SteamVR..."
for proc in $steamvr_processes
    pkill -f $proc
end
sleep 3
for proc in $steamvr_processes
    pkill -f -9 $proc
end

echo "Installing SteamPlay-None for SteamVR..."
mkdir -p "$HOME/.steam/steam/compatibilitytools.d"
wget https://github.com/Scrumplex/Steam-Play-None/archive/refs/heads/main.tar.gz
tar xzf main.tar.gz -C "$HOME/.steam/steam/compatibilitytools.d"

clear
echo "We're rebooting Steam to make it recognize SteamPlay-None, a 'compatibility tool' that disables the Steam Runtime."
echo "Please force enable compatiblity tools for SteamVR and set it to SteamPlay-None."
pkill steam
sleep 3
pkill -9 steam
sleep 5
steam &>/dev/null &
sleep 5

if not test -z $WAYLAND_DISPLAY
    echo
    echo "And put"
    echo "WAYLAND_DISPLAY='' %command%"
    echo "into SteamVR commandline options."
end

echo "When ready,"
read -l -P "Press enter to continue..." > /dev/null

clear
echo "Downloading ALVR..."
wget "https://github.com/alvr-org/ALVR/releases/latest/download/alvr_streamer_linux.tar.gz"
tar xvf alvr_streamer_linux.tar.gz
