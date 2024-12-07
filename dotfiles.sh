#!/bin/bash
set -e

REPO_DIR=$(pwd)
CURRENT_USER=$(whoami)

install_yay() {
    echo "Cloning yay repository..."
    if git clone https://aur.archlinux.org/yay.git; then
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "Error: Could not clone yay repository."
        exit 1
    fi
}

install_pacman_packages() {
    sudo pacman -S --needed --noconfirm xorg xorg-xinit i3-wm hsetroot kitty ueberzug zsh ranger feh rofi neovim polybar nerd-fonts feh lightdm lightdm-gtk-greeter maim xclip dunst ttf-fira-code picom polkit-gnome bluez bluez-utils xdotool brightnessctl hsetroot
}

install_aur_packages() {
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

enable_services() {
    sudo systemctl enable lightdm.service
    systemctl enable betterlockscreen@$CURRENT_USER
    sudo systemctl enable bluetooth.service
}

copy_configs() {
    ranger --copy-config=all
    mkdir -p "$HOME/Pictures/Screenshots"

    for dir in "$REPO_DIR/config/"*; do
        if [ -d "$dir" ] && [ "$(basename "$dir")" != "polybar" ]; then
            cp -r "$dir" "$HOME/.config/"
        fi
    done

    mkdir -p "$HOME/.config/polybar/modules"
    find "$REPO_DIR/config/polybar" -maxdepth 1 ! -name "modules" -type f -exec cp {} "$HOME/.config/polybar/" \;

    if [ -f "$REPO_DIR/config/polybar/modules/battery.c" ]; then
        gcc -o "$HOME/.config/polybar/modules/battery" "$REPO_DIR/config/polybar/modules/battery.c"
    fi

    if [ -f "$REPO_DIR/config/polybar/modules/network.c" ]; then
        gcc -o "$HOME/.config/polybar/modules/network" "$REPO_DIR/config/polybar/modules/network.c"
    fi

    if [ -f "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
        sudo cp -f "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/
        sudo chmod 644 /etc/lightdm/lightdm-gtk-greeter.conf
        sudo chown root:root /etc/lightdm/lightdm-gtk-greeter.conf
    fi
}

configure_sleep_settings() {
    sudo sed -i '/^#IdleAction=/c\IdleAction=suspend' /etc/systemd/logind.conf
    sudo sed -i '/^#IdleActionSec=/c\IdleActionSec=15min' /etc/systemd/logind.conf
}

make_scripts_executable() {
    chmod +x "$HOME/.config/polybar/"*.sh "$HOME/.config/rofi/"*.sh
}

install_oh_my_zsh() {
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        echo "Error: Could not install oh-my-zsh."
        exit 1
    fi
    cp "$REPO_DIR/.zshrc" "$HOME/"
}

install_zsh_plugins() {
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}


install_yay
install_pacman_packages
install_aur_packages
enable_services
copy_configs
configure_sleep_settings
make_scripts_executable
install_oh_my_zsh
install_zsh_plugins

read -p "Do you want to install additional packages? (y/n): " install_extra
if [[ "$install_extra" =~ ^[Yy]$ ]]; then
    sudo pacman -S --noconfirm telegram-desktop firefox obsidian keepassxc
fi


echo "Cleaning up..."
rm -rf "$REPO_DIR"

echo "Installation complete!"
