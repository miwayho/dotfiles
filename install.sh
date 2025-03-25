#!/bin/bash
set -e

REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"

install_yay() { 
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
}

install_packages(){
    sudo pacman -S --noconfirm rsync git wayland mesa xorg-xwayland sway swaybg polkit greetd greetd-tuigreet \
    waybar fuzzel mako wl-clipboard wezterm ranger neovim ttf-iosevka ttf-iosevka-nerd \
    ttf-jetbrains-mono ttf-roboto firefox man telegram-desktop kicad grim unzip brightnessctl \
    bluez bluez-utils pulseaudio-bluetooth
    
    yay -S --noconfirm bluetuith
}

enable_service() {
    sudo systemctl enable greetd.service
    sudo systemctl enable bluetooth.service
}

install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

copy_configs(){
    mkdir -p "$HOME/.config/ranger/"
    mkdir -p "$HOME/Pictures/Screenshots"
    
    rsync -av "$REPO_DIR/config/" "$CONFIG_DIR/"
    chmod +x "$CONFIG_DIR"/fuzzel/*.sh
    cp -r "$REPO_DIR/firefox/"* "$FIREFOX_PROFILE_DIR"
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

configure_dmenu() {
    local dmenu_files=(
        "/usr/share/applications/avahi-discover.desktop"
        "/usr/share/applications/electron34.desktop"
        "/usr/share/applications/org.gnupg.pinentry-qt5.desktop"
        "/usr/share/applications/org.gnupg.pinentry-qt.desktop"
        "/usr/share/applications/org.kicad.bitmap2component.desktop"
        "/usr/share/applications/org.kicad.eeschema.desktop"
        "/usr/share/applications/org.kicad.gerbview.desktop"
        "/usr/share/applications/org.kicad.pcbcalculator.desktop"
        "/usr/share/applications/ranger.desktop"
        "/usr/share/applications/qv4l2.desktop"
    )

    for file in "${dmenu_files[@]}"; do
        echo "NoDisplay=true" | sudo tee -a "$file"
    done
}

main() {
    install_yay
    install_packages
    enable_service
    install_oh_my_zsh
    copy_configs
    configure_greetd
    configure_greetd
    configure_dmenu
}

main