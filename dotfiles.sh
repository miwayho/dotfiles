#!/bin/bash
set -e

REPO_DIR=$(pwd)
CURRENT_USER=$(whoami)
CONFIG_DIR="$HOME/.config"
POLYBAR_DIR="$CONFIG_DIR/polybar"
MODULES_DIR="$POLYBAR_DIR/modules"
PROFILE_DIR="$HOME/.mozilla/firefox"
CHROME_CSS="config/firefox/userChrome.css"
CONTENT_CSS="config/firefox/userContent.css"

install_yay() { 
    git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd .. && rm -rf yay
}

install_packages() {
    sudo pacman -S --needed --noconfirm xorg xorg-xinit i3-wm hsetroot kitty ueberzug zsh ranger unrar unzip feh rofi neovim polybar ttf-firacode-nerd lightdm lightdm-gtk-greeter maim xclip dunst ttf-fira-code picom polkit-gnome bluez bluez-utils xdotool brightnessctl rsync firefox
    yay -S --needed --noconfirm bluetuith betterlockscreen visual-studio-code-bin
}

enable_services() {
    sudo systemctl enable lightdm.service bluetooth.service
    systemctl enable betterlockscreen@$CURRENT_USER
}

copy_configs() {
    rsync -av --exclude polybar --exclude firefox "$REPO_DIR/config/" "$CONFIG_DIR/"
    mkdir -p "$POLYBAR_DIR" "$MODULES_DIR"
    install -Dm755 "$REPO_DIR/config/polybar/launch.sh" "$POLYBAR_DIR/launch.sh"
    install -Dm644 "$REPO_DIR/config/polybar/config.ini" "$POLYBAR_DIR/config.ini"
    sudo install -Dm644 "$REPO_DIR/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
}

setup_polybar_modules() {
    echo "Select device type:"
    echo "1 - Laptop | 2 - Desktop"
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

setup_firefox_userChrome() {
    PROFILE_DIR="$HOME/.mozilla/firefox"
    PROFILE=$(grep 'Path=' "$PROFILE_DIR/profiles.ini" | sed 's/^Path=//' | grep '.default-release')

    if [[ -z "$PROFILE" ]]; then
        echo "Firefox profile not found. Skipping userChrome.css setup."
        return
    fi

    FULL_PROFILE_PATH="$PROFILE_DIR/$PROFILE"
    CHROME_DIR="$FULL_PROFILE_PATH/chrome"
    USER_JS="$FULL_PROFILE_PATH/user.js"
    PREFS_JS="$FULL_PROFILE_PATH/prefs.js"
    EXTENSIONS_DIR="$FULL_PROFILE_PATH/extensions"
    EXTENSION_FILE="$REPO_DIR/config/firefox/{2f0596eb-26b7-45bb-addb-ab56eb7c97dc}.xpi"

    mkdir -p "$CHROME_DIR"
    mkdir -p "$EXTENSIONS_DIR"

    echo "Copying $REPO_DIR/$CHROME_CSS to $CHROME_DIR/"
    if [[ -f "$REPO_DIR/$CHROME_CSS" ]]; then
        cp "$REPO_DIR/$CHROME_CSS" "$CHROME_DIR/"
    else
        echo "Error: $REPO_DIR/$CHROME_CSS not found"
    fi

    echo "Copying $REPO_DIR/$CONTENT_CSS to $CHROME_DIR/"
    if [[ -f "$REPO_DIR/$CONTENT_CSS" ]]; then
        cp "$REPO_DIR/$CONTENT_CSS" "$CHROME_DIR/"
    else
        echo "Error: $REPO_DIR/$CONTENT_CSS not found"
    fi

    [[ ! -f "$USER_JS" ]] && touch "$USER_JS" && echo "// user.js created to enable custom stylesheets" >> "$USER_JS"
    grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$USER_JS" || \
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$USER_JS"

    echo "Copying $REPO_DIR/config/firefox/prefs.js to $PREFS_JS"
    if [[ -f "$REPO_DIR/config/firefox/prefs.js" ]]; then
        cp "$REPO_DIR/config/firefox/prefs.js" "$PREFS_JS"
    else
        echo "Error: $REPO_DIR/config/firefox/prefs.js not found"
    fi

    if [[ -f "$EXTENSION_FILE" ]]; then
        echo "Copying $EXTENSION_FILE to $EXTENSIONS_DIR/"
        cp "$EXTENSION_FILE" "$EXTENSIONS_DIR/"
    else
        echo "Error: Extension file $EXTENSION_FILE not found"
    fi
}

enable_tap() {
sudo mkdir -p /etc/X11/xorg.conf.d && sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection

EOF
}

main() {
    install_yay
    install_packages
    enable_services
    copy_configs
    setup_polybar_modules
    install_oh_my_zsh
    setup_firefox_userChrome
    enable_tap
    read -p "Install additional packages? (1-Yes, 2-No): " install_choice
    [[ "$install_choice" == "1" ]] && sudo pacman -S --noconfirm telegram-desktop obsidian keepassxc
    rm -rf "$REPO_DIR"
    echo "Installation complete!"
}

main
