#!/usr/bin/env -S just --justfile
# just reference  : https://just.systems/man/en/

jstl_config := "" \
    + "--no-tagArrayExpression " \
    + "--no-index0to1 " \
    + "--no-debug "


@default:
    just --list

build:
    #!/bin/bash
    ls src/ | grep -e ".*\.js" | sed "s/\..*//" | while read line
    do
        echo "--- Compiling $line.js ---"
        js2lua {{jstl_config}} "src/$line.js" > "lua/context-menu/$line.lua"
    done
