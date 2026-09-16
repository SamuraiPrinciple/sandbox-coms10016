#!/bin/sh
# Builds the program for the open C file (VS Code: Cmd+Shift+B and F5; Zed: tasks.json and debug.json):
#   c/src/NAME.c    make NAME in c/, and the program runs in c/
#   c/DIR/NAME.c    make NAME in c/DIR (e.g. c/projects/sketch), and it runs in c/DIR
# Then points c/build/debug/NAME at the program and c/build/debug/NAME.cwd at the
# folder it runs in, so one debug configuration in launch.json covers both.
set -e
case $1 in
c/*) ;;
*)
    echo "Only C files in c/ can be built and debugged. For a Haskell file, Cmd+Shift+B runs it" >&2
    exit 1
    ;;
esac
cd c
path=${1#c/}
dir=$(dirname "$path")
name=$(basename "$path")
name=${name%.*}
if [ "$dir" = src ]; then
    make "$name"
    program=$PWD/build/$name
    cwd=$PWD
else
    make -C "$dir" "$name"
    program=$PWD/$dir/$name
    cwd=$PWD/$dir
fi
mkdir -p build/debug
ln -sfn "$program" "build/debug/$name"
ln -sfn "$cwd" "build/debug/$name.cwd"
