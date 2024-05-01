#!/usr/bin/env fish

function setup-proton-rtsp
    set release (curl -s "https://api.github.com/repos/SpookySkeletons/proton-ge-rtsp/releases?per_page=1")
    set release_url (echo $release | jq -r '.[0].assets[0].browser_download_url')
    set release_name (echo $release | jq -r '.[0].name')

    echo "Downloading $release_name..."
    wget $release_url

    echo "Extracting..."
    tar xzf "$release_name.tar.gz" -C "$HOME/.steam/steam/compatibilitytools.d"

    # Delete extracted package
    rm "$release_name.tar.gz"

    steam &>/dev/null &
    echo "We're starting Steam back up, you'll have to go into VRChat's properties and force the use of the new $release_name Proton version."
    echo "Also, add '--enable-avpro-in-proton' to the command line flags to re-enable video players."
    echo "When you're done with that and ready,"
    read -l -P "Press enter to continue..." > /dev/null
end