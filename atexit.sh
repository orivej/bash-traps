#!/bin/bash
set -x

function defer {
    declare -ga traps
    traps[${#traps[*]}]=`trap`
    trapcmd="__finally; $(printf "%q " "$@")"
    trap "eval eval \"$(printf '"%q" ' "$trapcmd")\"" EXIT
}

function __finally {
    declare -ga traps
    local cmd
    eval "$@"
    cmd="${traps[${#traps[@]}-1]}"
    unset traps[${#traps[@]}-1]
    eval set -- "${cmd}"
    if [ "$1/$2/$4" = "trap/--/EXIT" ]; then
        eval "$3"
    else
        eval "${cmd}"
    fi
}

(
    set -e
    trap 'echo normal trap' EXIT

    echo mount 1
    defer echo umount 1

    false

    echo mount 2
    defer echo umount 2
)
