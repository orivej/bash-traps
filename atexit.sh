#!/bin/bash
set -e -o pipefail

_atexit=()

function push_atexit {
    _atexit=($# "$@" "${_atexit[@]}")
}

function pop_atexit {
    local nargs=${_atexit[0]}
    "${_atexit[@]:1:$nargs}"
    _atexit=("${_atexit[@]:$((1+$nargs))}")
}

function atexit {
    push_atexit "$@"
    local cmd="$(trap -p EXIT)"
    cmd="$(sed "s/-- /-- 'pop_atexit;'/" <<< "$cmd")"
    eval "$cmd"
}

(
    set -e
    trap 'echo normal trap' EXIT

    echo touch "f  1"
    atexit echo rm "f  1"

    echo touch "f  2"
    atexit echo rm "f  2"

    false
)
