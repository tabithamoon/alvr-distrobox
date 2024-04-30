#!/usr/bin/env fish

function check-dependency
    which $argv 2>&1 > /dev/null

    if test $status -ne 0
        echo "Could not find $argv binary."
        exit 1
    end
end