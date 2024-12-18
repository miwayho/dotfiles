#!/bin/bash
set -e

REPO_DIR=$(pwd)
CURRENT_USER=$(whoami)
CONFIG_DIR="$HOME/.config"
POLYBAR_DIR="$CONFIG_DIR/polybar"
MODULES_DIR="$POLYBAR_DIR/modules"

install_yay() { git clone https://aur.archlinux.org/yay-bin.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay; }

install_packages() {
    sudo pacman -S --needed --noconfirm xorg xorg-xinit i3-wm hsetroot kitty ueberzug zsh ranger unrar unzip feh rofi neovim polybar ttf-firacode-nerd lightdm lightdm-gtk-greeter maim xclip dunst ttf-fira-code picom polkit-gnome bluez bluez-utils xdotool brightnessctl rsync
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

enable_services() {
    sudo systemctl enable lightdm.service bluetooth.service
    systemctl enable betterlockscreen@$CURRENT_USER
}

copy_configs() {
    rsync -av --exclude polybar "$REPO_DIR/config/" "$CONFIG_DIR/"
    mkdir -p "$POLYBAR_DIR" "$MODULES_DIR"
    install -Dm755 "$REPO_DIR/config/polybar/launch.sh" "$POLYBAR_DIR/launch.sh"
    install -Dm644 "$REPO_DIR/config/polybar/config.ini" "$POLYBAR_DIR/config.ini"
    sudo install -Dm644 "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
}

setup_polybar_modules() {
    echo "Select device type:"
    echo "1 - Laptop | 2 -Desktop"
    read -p "Enter the number [1-2]: " device_choice

    echo "Select internet type:"
    echo "1 - Wireless | 2 - Wired"
    read -p "Enter the number [1-2]: " internet_choice

    MODULE_FILES=(date.ini volume.ini)

    if [[ "$device_choice" == "1" ]]; then
        echo "Setting up Polybar for a laptop..."
        cp "$REPO_DIR/config/polybar/modules/"*.ini "$MODULES_DIR/"
        sed -i '1s;^;include-file = ~/.config/polybar/modules/battery.ini\n;' "$POLYBAR_DIR/config.ini"
    elif [[ "$device_choice" == "2" ]]; then
        echo "Setting up Polybar for a desktop..."
        for file in "${MODULE_FILES[@]}"; do
            cp "$REPO_DIR/config/polybar/modules/$file" "$MODULES_DIR/"
        done
    else
        echo "Invalid choice for device type."
        exit 1
    fi

    case "$internet_choice" in
        1)
            echo "Configuring network module for wireless connection..."
            cp "$REPO_DIR/config/polybar/modules/wireless.ini" "$MODULES_DIR/network.ini"
            ;;
        2)
            echo "Configuring network module for wired connection..."
            cp "$REPO_DIR/config/polybar/modules/wired.ini" "$MODULES_DIR/network.ini"
            ;;
        *)
            echo "Invalid choice for internet type."
            exit 1
            ;;
    esac
}

install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    install -Dm644 "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

main() {
    install_yay
    install_packages
    enable_services
    copy_configs
    setup_polybar_modules
    install_oh_my_zsh
    read -p "Install additional packages? (1-Yes, 2-No): " install_choice
    [[ "$install_choice" == "1" ]] && sudo pacman -S --noconfirm telegram-desktop firefox obsidian keepassxc
    rm -rf "$REPO_DIR"
    echo "Installation complete!"
}

main
