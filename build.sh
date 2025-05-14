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

if [[ "$1" == "-d" ]]; then
    (cd ~/dotfiles && git add . && git commit -m "automat push" && git push origin main --force) >/dev/null 2>&1 &
fi

if [[ "$ID" == "arch" ]]; then
    source /etc/os-release
    sudo pacman -S --needed --noconfirm base-devel openssl zlib readline gnu-netcat openssh pipewire wireplumber xdg-desktop-portal-hyprland xdg-desktop-portal-gtk networkmanager mesa vulkan-icd-loader
    systemctl enable NetworkManager
    systemctl start NetworkManager
    sudo pacman -S hyprland waybar dunst rofi kitty thunar firefox neovim qt5-wayland qt6-wayland
    sudo pacman -S polkit-gnome network-manager-applet blueman pavucontrol brightnessctl wofi swaylock swayidle
    curl https://pyenv.run | bash
    sudo pacman -S zoxide
    exec zsh
fi
