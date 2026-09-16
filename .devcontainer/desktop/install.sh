#!/bin/sh
set -e
apt-get update
apt-get install --yes --no-install-recommends lxterminal
rm -rf /var/lib/apt/lists/*

# desktop-lite's menu opens Tilix, which crashes on this image (Tilix 1.9.6, VTE 0.80)
# as soon as a shell reports its directory (OSC 7), as oh-my-zsh and bash logins do
for menu in /root/.fluxbox/menu /home/*/.fluxbox/menu; do
    [ -f "$menu" ] || continue
    sed -i -e 's#tilix -w ~ -e $(readlink -f /proc/$$/exe) -il#lxterminal --working-directory=$HOME -e zsh#' \
        -e 's#tilix -t #lxterminal -t #' "$menu"
done
