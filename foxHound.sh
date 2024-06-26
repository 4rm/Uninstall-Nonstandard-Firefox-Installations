#!/bin/bash

catchOrRelease () {
        if [[ $1 == "/Applications/Firefox.app" ]]; then
                echo "$1 - keeping valid install location"
        else
                echo "$1 - removing invalid install location"
                rm -rf "$1"
        fi
}
export -f catchOrRelease

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Warning! Not running as root. All files may not be found"
fi

mdfind "kMDItemCFBundleIdentifier = org.mozilla.firefox" -0 | xargs -0 bash -c 'for arg; do catchOrRelease "$arg"; done' _

find /Users/*/.Trash -name Firefox.app -exec rm -rf "{}" +
