#!/usr/bin/env fish

echo "Patching SteamVR..."
set patchfile "$HOME/.steam/steam/steamapps/common/SteamVR/resources/webinterface/dashboard/vrwebui_shared.js"

sed -i 's/m=n(1380),g=n(9809);/m=n(1380),g=n(9809),refresh_counter=0,refresh_counter_max=75;/g w /dev/stdout' $patchfile
sed -i 's/case"action_bindings_reloaded":this.OnActionBindingsReloaded(n);break;/case"action_bindings_reloaded":if(refresh_counter%refresh_counter_max==0){this.OnActionBindingsReloaded(n);}refresh_counter++;break;/g w /dev/stdout' $patchfile
sed -i 's/l=n(3568),c=n(1569);/l=n(3568),c=n(1569),refresh_counter_v2=0,refresh_counter_max_v2=75;/g w /dev/stdout' $patchfile
sed -i 's/OnActionBindingsReloaded(){this.GetInputState()}/OnActionBindingsReloaded(){if(refresh_counter_v2%refresh_counter_max_v2==0){this.GetInputState();}refresh_counter_v2++;}/g w /dev/stdout' $patchfile
echo "SteamVR patched."