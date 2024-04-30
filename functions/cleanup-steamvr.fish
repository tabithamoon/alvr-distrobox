#!/usr/bin/env fish
set steamvr_processes vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup

function cleanup-steamvr
    echo "Cleaning up SteamVR..."
    for proc in $steamvr_processes
        pkill -f $proc
    end

    sleep 3

    for proc in $steamvr_processes
        pkill -f -9 $proc
    end
end
