#!/bin/bash
set -e

# Directories and User Variables
REPO_DIR=$(pwd)
USER_NAME=$(whoami)
CONFIG_DIR="$HOME/.config"
POLYBAR_DIR="$CONFIG_DIR/polybar"
MODULES_DIR="$POLYBAR_DIR/modules"
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"

# Install YAY package manager
install_yay() { 
    git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd .. && rm -rf yay
}

# Install necessary packages
install_packages() {
    sudo pacman -S --needed --noconfirm linux-headers pacman-contrib i3-wm zsh ranger atool feh rofi neovim polybar ttf-firacode-nerd kitty lightdm lightdm-gtk-greeter maim xclip dunst picom polkit-gnome bluez bluez-utils xdotool brightnessctl rsync ffmpegthumbnailer unrar unzip firefox
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

# Enable necessary services
enable_services() {
    sudo systemctl enable lightdm.service bluetooth.service
    systemctl enable betterlockscreen@$USER_NAME
}

# Configure system and user settings
configure_system() {
    copy_configs
    notify_zsh_installation
    install_oh_my_zsh
    configure_dmenu
}

# Notify about Zsh installation
notify_zsh_installation() {
    echo "\n=== Attention ==="
    echo "The shell will be changed to Zsh."
    echo "After installation, type 'exit' to continue the script."
    sleep 5
}

# Copy configuration files and setup Polybar
copy_configs() {
    rsync -av --exclude polybar --exclude firefox "$REPO_DIR/config/" "$CONFIG_DIR/"
    mkdir -p "$MODULES_DIR"
    mkdir -p "$HOME/.config/ranger/"
    mkdir -p "$FIREFOX_PROFILE_DIR"

    install -Dm755 "$REPO_DIR/config/polybar/launch.sh" "$POLYBAR_DIR/launch.sh"
    sudo cp -r "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
    
    cp -r "$REPO_DIR/.Xresources"* "$HOME"
    cp -r "$REPO_DIR/config/ranger/"* "$HOME/.config/ranger/"
    cp -r "$REPO_DIR/config/firefox/"* "$FIREFOX_PROFILE_DIR"
    cp "$REPO_DIR/config/polybar/config.ini" "$POLYBAR_DIR/config.ini"
    
    chmod +x $CONFIG_DIR/i3/battery.sh
    chmod +x $CONFIG_DIR/i3/volume.sh

    echo "Select device type (1 - Laptop, 2 - Desktop): "
    read -r device_type

    if [ "$device_type" -eq 1 ]; then
        cp "$REPO_DIR/config/polybar/modules/battery.ini" "$MODULES_DIR/battery.ini"
        sed -i '1iinclude-file = ~/.config/polybar/modules/battery.ini' "$POLYBAR_DIR/config.ini"
        setup_touchpad
    fi

    echo "Select internet type (1 - Wireless, 2 - Wired): "
    read -r internet_type

    if [ "$internet_type" -eq 1 ]; then
        cp "$REPO_DIR/config/polybar/modules/wireless.ini" "$MODULES_DIR/network.ini"
    else
        cp "$REPO_DIR/config/polybar/modules/wired.ini" "$MODULES_DIR/network.ini"
    fi

    cp "$REPO_DIR/config/polybar/modules/date.ini" "$MODULES_DIR/date.ini"
    cp "$REPO_DIR/config/polybar/modules/volume.ini" "$MODULES_DIR/volume.ini"
}

# Setup touchpad for laptops
setup_touchpad() {
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo tee /etc/X11/xorg.conf.d/90-touchpad.conf > /dev/null <<'EOF'
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOF
}

# Install Oh-My-Zsh
install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    install -Dm644 "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

# Configure DMenu entries
configure_dmenu() {
    local dmenu_files=(
        "/usr/share/applications/rofi-theme-selector.desktop"
        "/usr/share/applications/qv4l2.desktop"
        "/usr/share/applications/qvidcap.desktop"
        "/usr/share/applications/electron32.desktop"
        "/usr/share/applications/bssh.desktop"
        "/usr/share/applications/bvnc.desktop"
        "/usr/share/applications/rofi.desktop"
        "/usr/share/applications/picom.desktop"
        "/usr/share/applications/ranger.desktop"
        "/usr/share/applications/kitty.desktop"
    )

    for file in "${dmenu_files[@]}"; do
        echo "NoDisplay=true" | sudo tee -a "$file" > /dev/null
    done
}

# Main script execution
main() {
    install_yay
    install_packages
    enable_services
    configure_system
}

main