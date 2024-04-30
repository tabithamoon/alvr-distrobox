#!/usr/bin/env fish

function stop-steam
    pkill steam
    sleep 3
    pkill -9 steam
    sleep 5
end
