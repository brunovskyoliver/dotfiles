#!/bin/bash

if [[ "$1" == "-s" ]]; then
    cmd="echo simulating copying"
else
    cmd="cp -rf"
fi
dirs=$(find "$HOME/dotfiles" -mindepth 1 -maxdepth 1 -type d | awk '!/git/')
mkdir -p "$HOME/.config"

for dir in $dirs; do
    $cmd "$dir" "$HOME/.config"
done

files=$(find "$HOME/dotfiles" -mindepth 1 -maxdepth 1 -type f | grep rc)
for file in $files; do
    $cmd "$file" "$HOME"
done

files=$(find "$HOME/dotfiles" -mindepth 1 -maxdepth 1 -type f | grep tmux)
for file in $files; do
    $cmd "$file" "$HOME"
done

(cd ~/dotfiles && git add . && git commit -m "automat push" && git push origin main --force) >/dev/null 2>&1 &
