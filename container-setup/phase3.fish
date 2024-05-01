#!/usr/bin/env fish

source ./functions/setup-proton-rtsp.fish
source ./functions/cleanup-steamvr.fish
source ./functions/stop-steam.fish

clear
echo "Installing more required packages..."
sudo pacman -q --noprogressbar -Syu git vim base-devel noto-fonts xdg-user-dirs fuse libx264 sdl2 libva-utils xorg-server --noconfirm

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

# Wait for SteamVR to exit
for process in vrmonitor vrserver
    while not pidof $process &>/dev/null
        sleep 1
    end
end

cleanup-steamvr

echo "Installing SteamPlay-None for SteamVR..."
mkdir -p "$HOME/.steam/steam/compatibilitytools.d"
wget https://github.com/Scrumplex/Steam-Play-None/archive/refs/heads/main.tar.gz
tar xzf main.tar.gz -C "$HOME/.steam/steam/compatibilitytools.d"
rm main.tar.gz

clear
echo "We're rebooting Steam to make it recognize SteamPlay-None, a 'compatibility tool' that disables the Steam Runtime."
echo "Please force enable compatiblity tools for SteamVR and set it to SteamPlay-None."

stop-steam

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
cd $HOME
echo "Downloading ALVR..."
wget "https://github.com/alvr-org/ALVR/releases/latest/download/alvr_streamer_linux.tar.gz"
tar xvf alvr_streamer_linux.tar.gz

alvr_streamer_linux/bin/alvr_dashboard &>/dev/null &
echo "ALVR is now being launched! Please proceed with first time setup."
echo "When prompted, install the script to handle switching audio devices with PipeWire."
echo "Do not connect your headset yet! Once you're in the main ALVR dashboard, click 'Launch SteamVR' on the bottom left."
echo "Once you do that, keep the ALVR dashboard open, and"
read -l -P "Press enter to continue..." > /dev/null

sleep 2

cleanup-steamvr

echo "Patching SteamVR to work around a bug which stops the dashboard from working..."

set patchfile "$HOME/.steam/steam/steamapps/common/SteamVR/resources/webinterface/dashboard/vrwebui_shared.js"

for patch in 's/m=n(1380),g=n(9809);/m=n(1380),g=n(9809),refresh_counter=0,refresh_counter_max=75;/g w /dev/stdout' 's/case"action_bindings_reloaded":this.OnActionBindingsReloaded(n);break;/case"action_bindings_reloaded":if(refresh_counter%refresh_counter_max==0){this.OnActionBindingsReloaded(n);}refresh_counter++;break;/g w /dev/stdout' 's/l=n(3568),c=n(1569);/l=n(3568),c=n(1569),refresh_counter_v2=0,refresh_counter_max_v2=75;/g w /dev/stdout' 's/OnActionBindingsReloaded(){this.GetInputState()}/OnActionBindingsReloaded(){if(refresh_counter_v2%refresh_counter_max_v2==0){this.GetInputState();}refresh_counter_v2++;}/g w /dev/stdout'
    sed -i "$patch" $patchfile > /dev/null

    if test $status -ne 0
        echo "Patch failed!"
        exit 1
    end
end

clear
stop-steam
echo "Will you be playing VRChat?"
echo "If yes, we will install a custom patched version of Proton that (tries to) fix video players."
set confirm (read -l -P "(Y/n): ")

if test (echo $confirm | string lower) = "y"
    clear
    setup-proton-rtsp
    stop-steam
else if test -z $confirm
    clear
    setup-proton-rtsp
    stop-steam
else
    echo "Skipping proton-rtsp installation."
end
