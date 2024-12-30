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
    git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm
    cd .. && rm -rf yay-bin
}

# Install necessary packages
install_packages() {
    sudo pacman -S --needed --noconfirm linux-headers pacman-contrib i3-wm zsh sshfs ranger atool feh rofi neovim polybar ttf-fira-code ttf-firacode-nerd capitaine-cursors ghostty ueberzug lightdm lightdm-gtk-greeter imagemagick xclip dunst picom polkit-gnome bluez bluez-utils xdotool brightnessctl rsync ffmpegthumbnailer unrar unzip firefox docker pulsemixer vlc python-pillow
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

# Install necessary DNS configuration
configure_dns() {
    sudo tee -a /etc/NetworkManager/NetworkManager.conf > /dev/null <<EOF
[main]
dns=none
EOF

    sudo systemctl restart NetworkManager
    echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
}

# Prompt for additional packages
install_additional_packages() {
    echo "Do you want to install additional packages? (y/n): "
    read -r install_extra

    if [ "$install_extra" == "y" ]; then
        yay -S --noconfirm telegram-desktop-bin
        sudo pacman -S gimp obs-studio obsidian kicad qbittorrent 
    fi
}

# Enable necessary services
enable_services() {
    sudo systemctl enable lightdm.service bluetooth.service
    systemctl enable betterlockscreen@$USER_NAME
}

# Configure system and user settings
configure_system() {
    copy_configs
    make_scripts_executable
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
    mkdir -p "$HOME/Pictures/Screenshots"

    sudo cp -r "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
    install -Dm755 "$REPO_DIR/config/polybar/launch.sh" "$POLYBAR_DIR/launch.sh"
    
    cp -r "$REPO_DIR/.Xresources"* "$HOME"
    cp -r "$REPO_DIR/config/ranger/"* "$HOME/.config/ranger/"
    cp -r "$REPO_DIR/config/firefox/"* "$FIREFOX_PROFILE_DIR"
    
    cp "$REPO_DIR/config/polybar/config.ini" "$POLYBAR_DIR/config.ini"
    
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

# Make all scripts executable
make_scripts_executable() {
    find "$CONFIG_DIR/rofi" -type f -name "*.sh" -exec chmod +x {} \;
    find "$CONFIG_DIR/i3" -type f -name "*.sh" -exec chmod +x {} \;
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
        "/usr/share/applications/com.mitchellh.ghostty.desktop
        "/usr/share/applications/org.kicad.gerbview.desktop"
        "/usr/share/applications/org.kicad.eeschema.desktop"
        "/usr/share/applications/org.kicad.bitmap2component.desktop"
        "/usr/share/applications/org.kicad.pcbcalculator.desktop"
        "/usr/share/applications/org.kicad.pcbnew.desktop"
        "/usr/share/applications/avahi-discover.desktop"
        "/usr/share/applications/lstopo.desktop"
        "/usr/share/applications/jshell-java-openjdk.desktop"
        "/usr/share/applications/jconsole-java-openjdk.desktop"

    )

    for file in "${dmenu_files[@]}"; do
        echo "NoDisplay=true" | sudo tee -a "$file" > /dev/null
    done
}

# Prompt to install Poetry
install_poetry() {
    echo "Do you want to install Poetry? (y/n): "
    read -r install_poetry

    if [ "$install_poetry" == "y" ]; then
        curl -sSL https://install.python-poetry.org | python3 -
    else
        echo "Skipping Poetry installation."
    fi
}

# Install Docker
install_docker() {
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER_NAME"
}

# Clean up repository directory after installation
cleanup() {
    echo "Do you want to remove the repository directory? (y/n): "
    read -r remove_repo

    if [ "$remove_repo" == "y" ]; then
        rm -rf "$REPO_DIR"
        echo "Repository directory removed."
    else
        echo "Repository directory retained."
    fi
}

# Main script execution
main() {
    install_yay
    install_packages
    install_additional_packages
    install_docker
    enable_services
    configure_system
    install_poetry
    configure_dns
    cleanup
}

main
