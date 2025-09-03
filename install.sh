#!/bin/bash
set -e

REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

install_packages(){
    sudo pacman -S --noconfirm rsync git wayland mesa amd-ucode vulkan-radeon hyprland xorg-xwayland xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr openssh\
    qt6-wayland qt5-wayland polkit greetd greetd-tuigreet waybar wofi wl-clipboard alacritty neovim ttf-iosevka-nerd ttc-iosevka ttf-opensans noto-fonts-cjk\
    noto-fonts firefox man telegram-desktop kicad kicad-library kicad-library-3d grim unzip brightnessctl zsh \
    bluez bluez-utils pipewire pipewire-pulse wireplumber hyprshot gnome-themes-extra zed
}

install_yay() {
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
}

enable_service() {
    sudo systemctl enable greetd.service
    sudo systemctl enable bluetooth.service
    sudo systemctl enable pipewire-pulse.service
}

copy_configs(){
    rsync -av "$REPO_DIR/config/" "$CONFIG_DIR/"
    chmod +x "$CONFIG_DIR"/wofi/*.sh
    cp -r "$REPO_DIR/.ssh" "$HOME/"
}

configure_greetd() {
    sudo tee /etc/greetd/config.toml > /dev/null << EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd hyprland"
user = "greeter"
EOF

    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << EOF
[Desktop Entry]
Name=Hyprland
Exec=hyprland
Type=Application
EOF
}

install_shell() {
    chsh -s /usr/bin/zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

main() {
    install_packages
    install_yay
    enable_service
    copy_configs
    configure_greetd
    install_shell
}

main
