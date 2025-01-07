#!/bin/bash

if [[ "$1" == "-s" ]]; then
    cmd="echo simulating copying"
else
    cmd="cp -rv"
fi
dirs=$(find . -mindepth 1 -maxdepth 1 -type d | awk '!/git/')
mkdir -p "$HOME/.config/"

for dir in $dirs; do
    $cmd "$dir" "$HOME/.config/testovanie"
done

files=$(find . -mindepth 1 -maxdepth 1 -type f | grep rc)
mkdir -p "$HOME/testovanie"
for file in $files; do
    $cmd "$file" "$HOME/testovanie"
done
