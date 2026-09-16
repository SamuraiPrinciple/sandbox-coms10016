#!/bin/sh
# Cmd+Shift+B: builds the open C file (see make-current-file.sh),
# or runs the open Haskell file with runghc, in the file's folder
case $1 in
*.hs)
    cd "$(dirname "$1")"
    exec runghc "$(basename "$1")"
    ;;
*)
    exec sh .vscode/make-current-file.sh "$1"
    ;;
esac
