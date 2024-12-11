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
    echo "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm xorg xorg-xinit i3-wm hsetroot kitty ueberzug zsh ranger feh rofi neovim polybar nerd-fonts feh lightdm lightdm-gtk-greeter maim xclip dunst ttf-fira-code picom polkit-gnome bluez bluez-utils xdotool brightnessctl hsetroot
}

install_aur_packages() {
    echo "Installing AUR packages..."
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

enable_services() {
    echo "Enabling services..."
    sudo systemctl enable lightdm.service
    systemctl enable betterlockscreen@$CURRENT_USER
    sudo systemctl enable bluetooth.service
}

ask_user_device_type() {
    echo "Please select your device type:"
    echo "1) Desktop"
    echo "2) Laptop"
    read -p "Enter your choice (1 or 2): " device_choice

    case $device_choice in
        1)
            echo "Desktop selected."
            DEVICE_TYPE="desktop"
            ;;
        2)
            echo "Laptop selected."
            DEVICE_TYPE="notebook"
            ;;
        *)
            echo "Invalid choice. Defaulting to desktop."
            DEVICE_TYPE="desktop"
            ;;
    esac
}

copy_configs() {
    echo "Copying config files for $DEVICE_TYPE..."

    CONFIG_SOURCE="$REPO_DIR/config/$DEVICE_TYPE"
    i
    f [ ! -d "$CONFIG_SOURCE" ]; then
        echo "Error: Directory $CONFIG_SOURCE does not exist."
        exit 1
    fi

    for dir in "$CONFIG_SOURCE"/*; do
        if [ -d "$dir" ]; then
            dest="$HOME/.config/$(basename "$dir")"
            echo "Copying $(basename "$dir") to $dest..."
            mkdir -p "$dest"
            cp -r "$dir/"* "$dest/"
        fi
    done

    echo "Configs for $DEVICE_TYPE copied successfully."
}

compile_polybar_modules() {
    echo "Compiling polybar modules..."

    gcc -o "$HOME/.config/polybar/modules/network" "$REPO_DIR/config/$DEVICE_TYPE/polybar/modules/network.c"

    if [ "$DEVICE_TYPE" == "notebook" ]; then
        echo "Compiling battery module for laptop..."
        gcc -o "$HOME/.config/polybar/modules/battery" "$REPO_DIR/config/$DEVICE_TYPE/polybar/modules/battery.c"
    else
        echo "Skipping battery module compilation for desktop."
    fi
}

configure_lightdm() {
    echo "Configuring LightDM..."
    sudo cp -f "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/
    sudo chmod 644 /etc/lightdm/lightdm-gtk-greeter.conf
    sudo chown root:root /etc/lightdm/lightdm-gtk-greeter.conf
}

configure_sleep_settings() {
    echo "Configuring sleep settings..."
    sudo sed -i '/^#IdleAction=/c\IdleAction=suspend' /etc/systemd/logind.conf
    sudo sed -i '/^#IdleActionSec=/c\IdleActionSec=15min' /etc/systemd/logind.conf
}

make_scripts_executable() {
    echo "Making scripts executable..."
    chmod +x "$HOME/.config/polybar/"*.sh "$HOME/.config/rofi/"*.sh
}

install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        echo "Error: Could not install Oh My Zsh."
        exit 1
    fi
    cp "$REPO_DIR/.zshrc" "$HOME/"
}

install_zsh_plugins() {
    echo "Installing Zsh plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

install_yay
install_pacman_packages
install_aur_packages
enable_services
ask_user_device_type
copy_configs
compile_polybar_modules
configure_lightdm
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