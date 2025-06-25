#!/bin/bash
set -e

REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

install_yay() { 
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
}

install_packages(){
    sudo pacman -S --noconfirm rsync git wayland mesa amd-ucode vulkan-radeon xorg-xwayland xdg-desktop-portal xdg-desktop-portal-gtk openssh\
    sway swaybg polkit greetd greetd-tuigreet waybar fuzzel mako wl-clipboard wezterm neovim ttf-iosevka-nerd ttc-iosevka ttf-opensans noto-fonts-cjk\
    noto-fonts firefox man telegram-desktop kicad grim unzip brightnessctl fish \
    bluez bluez-utils pipewire-pulse
    
    yay -S --noconfirm bluetuith 
}

enable_service() {
    sudo systemctl enable greetd.service
    sudo systemctl enable bluetooth.service 
    sudo systemctl enable pipewire-pulse.service
}

copy_configs(){
    mkdir -p "$HOME/Pictures/Screenshots"
    rsync -av "$REPO_DIR/config/" "$CONFIG_DIR/"
    chmod +x "$CONFIG_DIR"/fuzzel/*.sh

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

configure_greetd() {
    sudo tee /etc/greetd/config.toml > /dev/null << EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd sway"
user = "greeter"
EOF

    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/sway.desktop > /dev/null << EOF
[Desktop Entry]
Name=Sway
Exec=sway
Type=Application
EOF
}

install_fish() {
    chsh -s /usr/bin/fish
}

main() {
    install_yay
    install_packages
    enable_service
    copy_configs
    configure_greetd
    install_fish
}

main