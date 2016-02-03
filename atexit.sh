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

function prepend_trap {
    local new_cmd="$1" event="$2"
    local cmd="$(trap -p $event)"
    if [ "$cmd" ]; then
        cmd="${cmd:0:8}$(printf %q "${new_cmd}")';'${cmd:8}"
    else
        cmd="trap -- $(printf %q "${new_cmd}") $event"
    fi
    eval "$cmd"
}

function atexit {
    push_atexit "$@"
    prepend_trap pop_atexit EXIT
}

(
    trap 'echo normal trap' EXIT
    prepend_trap 'echo second trap' EXIT

    echo touch "f  1"
    atexit echo rm "f  1"

    echo touch "f  2"
    atexit echo rm "f  2"

    false
)
