#!/bin/bash
# Script: 8BitDo Firmware Updater Setup
# Author: Luciano Soares
# Version: 1.1.0
# Based on: https://gist.github.com/archeYR/d687de5e484ce7b45d6a94415a04f3dc
set -e

# === SCRIPT CONFIGURATION ===
WINE_PREFIX_DIR="$HOME"
WINE_PREFIX_NAME=".wine-8bitdo"
TOOL_DIR="$HOME/.local/share/8bitdo-updater"
UDEV_RULES_DIR="/etc/udev/rules.d"
APPS_DIR="$HOME/.local/share/applications"
#=== END SCRIPT CONFIGURATION ===

#urls
SEGOE_UI_URL="https://github.com/mrbvrz/segoe-ui-linux/archive/refs/heads/master.zip"
UPDATER_URL="https://download.8bitdo.com/Tools/FirmwareUpdater/8BitDo_Firmware_Updater_Win.zip?00"

if [ "$1" == "debug" ]; then
    echo "Running in debug mode"
    DEBUG=true

    echo "Debug mode: Using local directories"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DEBUG_BASE_DIR="$SCRIPT_DIR/DEBUG"
    
    TEMP_DIR="$DEBUG_BASE_DIR/temp"
    WINE_PREFIX_DIR="$DEBUG_BASE_DIR/.prefixes"
    WINE_PREFIX_NAME=".wine-8bitdo"
    TOOL_DIR="$DEBUG_BASE_DIR/8bitdo-updater"
    UDEV_RULES_DIR="$DEBUG_BASE_DIR/udev-rules.d"
    APPS_DIR="$DEBUG_BASE_DIR/applications"

    # Create debug directory structure
    rm -rf "$DEBUG_BASE_DIR"
    mkdir -p "$TEMP_DIR" "$UDEV_RULES_DIR" "$APPS_DIR"
else
    DEBUG=false

    # Create temp dir     
    TEMP_DIR=$(mktemp -d)
fi

WINE_PREFIX="$WINE_PREFIX_DIR/$WINE_PREFIX_NAME"

# Colors for output
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Support functions

header() {
    local description="$1"
    echo -e "🟣 ${MAGENTA}${description}${NC}"
}

error() {
    local description="$1"
    echo -e "❌ ${RED}${description}${NC}\n"
}

warning() {
    local description="$1"
    echo -e "⚠️  ${YELLOW}${description}${NC}\n"
}

success() {
    local description="$1"
    echo -e "✅ ${GREEN}${description}${NC}\n"
}

prompt_overwrite() {
    local resource_name="$1"
    
    echo "$resource_name already exists."
    read -p "Do you want to overwrite it? (y/N)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "The $resource_name will be overwritten."
        return 0  # user wants to overwrite
    else
        echo "Using existing $resource_name."
        return 1  # user doesn't want to overwrite
    fi
}


# Execution steps functions

root_check() {
    if [[ $EUID -eq 0 ]]; then
        warning "This script should not be run as root"
        echo "It will prompt for sudo when needed."
    fi
}

check_dependencies() {
    local required_packages=("$@")
    local missing_packages=()

    header "Checking dependencies..."
    for pkg in "${required_packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        warning "Missing packages: ${missing_packages[*]}"
        error "The script cannot continue without these packages."
        echo "Please install them and re-run the script."
        exit 1
    fi

    success "All dependencies are installed"
}

install_udev_rule() {
    header "Adding udev rule"

    local rule_path="$UDEV_RULES_DIR/71-8bitdo-boot.rules"

    local should_create_rule=true
    if [ -f "$rule_path" ]; then
        if ! prompt_overwrite "Udev rule at $rule_path"; then
            should_create_rule=false
        fi
    fi

    if [ "$should_create_rule" = true ]; then
        sudo cp assets/71-8bitdo-boot.rules "$rule_path"
        success "Udev rule created successfully"

        echo "Reloading udev rules..."
        sudo udevadm control --reload-rules && sudo udevadm trigger
        success "Udev rules reloaded"
    fi
}

install_segoe_ui_font() {
    header "Installing Segoe UI Symbol font"

    cd "$TEMP_DIR"
    wget -O segoe-ui-linux.zip "$SEGOE_UI_URL"
    unzip segoe-ui-linux.zip
    mkdir -p "$WINE_PREFIX/drive_c/windows/Fonts"
    cp segoe-ui-linux-master/font/*.ttf "$WINE_PREFIX/drive_c/windows/Fonts/"
    cd -
    success "Font setup complete"
}

download_and_install_updater() {
    header "Downloading 8BitDo Firmware Updater"

    mkdir -p "$TOOL_DIR"

    cd "$TEMP_DIR"

    if [ -f "8BitDo_Firmware_Updater_Win.zip" ]; then
        echo "Installer already downloaded."
    else
        wget -O "8BitDo_Firmware_Updater_Win.zip" "$UPDATER_URL"
    fi

    echo "Extracting files..."
    unzip -o "8BitDo_Firmware_Updater_Win.zip"
    mv "8BitDo_Firmware_Updater_Win"/* "$TOOL_DIR/"

    cd -
    success "Download and extraction complete"
}

create_desktop_entry() {
    header "Creating desktop entry"
    
    local desktop_file_path="$APPS_DIR/8bitdo-updater.desktop"
    
    local should_create_desktop=true
    if [ -f "$desktop_file_path" ]; then
        if ! prompt_overwrite "Desktop entry at $desktop_file_path"; then
            should_create_desktop=false
        fi
    fi

    if [ "$should_create_desktop" = true ]; then
        # Define the executable path (escaped for desktop file)
        local exe_path="$TOOL_DIR/8BitDo\ Firmware\ Updater.exe"
        
        # Build the complete exec command using env to set WINEPREFIX
        local exec_command="env WINEPREFIX='$WINE_PREFIX' wine '$exe_path'"

        # Use the template file and replace the exec command placeholder
        sed "s|%EXEC_COMMAND%|$exec_command|g" assets/8bitdo-updater.desktop > "$desktop_file_path"

        # Make the desktop file executable
        chmod +x "$desktop_file_path"
        
        # Update the desktop database
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$APPS_DIR/"
        fi

        success "Desktop entry created"
    fi
}

configure_wine_registry() {
    header "Configuring Wine registry"

    # Add registry value to disable SDL for winebus service
    WINEPREFIX="$WINE_PREFIX" wine reg add "HKLM\\System\\CurrentControlSet\\Services\\winebus" /v "Enable SDL" /t REG_DWORD /d 0 /f
    success "Registry value added"
    
    # Shutdown wine server to save and apply registry changes
    echo "Shutting down wine server to apply changes..."
    WINEPREFIX="$WINE_PREFIX" wineserver -k
    success "Wine server shutdown complete"
}

setup_wine_prefix() {
    mkdir -p "$WINE_PREFIX_DIR"

    local should_create_prefix=true
    if [ -d "$WINE_PREFIX" ]; then
        if ! prompt_overwrite "Wine prefix"; then
            should_create_prefix=false
        else
            rm -rf "$WINE_PREFIX"
        fi
    fi

    if [ "$should_create_prefix" = true ]; then
        WINEPREFIX="$WINE_PREFIX" WINEARCH=win64 wineboot -u
        success "Wine prefix created"

        configure_wine_registry
    fi
}

setup_prefix()  {
    header "Setting up Wine prefix at $WINE_PREFIX"

    if [ "$DEBUG" = true ]; then
        mkdir -p "$WINE_PREFIX"
        echo "Debug mode: Created Wine prefix directory at $WINE_PREFIX"
    else
        setup_wine_prefix
    fi
}

final_message() {
    success "=== Setup Complete! ==="
    echo -e "You can now run the 8BitDo Firmware Updater by:"
    echo -e "  • Searching for '8BitDo Firmware Updater' in your application menu"
}

cleanup() {
    if [ "$DEBUG" = true ]; then
        echo -e "\n${BLUE}Debug mode: Files preserved in $TEMP_DIR${NC}"
    else
        rm -rf "$TEMP_DIR"
    fi
}

# Main script execution

echo -e "${MAGENTA}=== 8BitDo Firmware Updater Setup Script ===${NC}\n"

echo "Using the following directories:"
echo "  • Wine Prefix: $WINE_PREFIX"
echo "  • Tool Directory: $TOOL_DIR"
echo "  • Udev Rules Directory: $UDEV_RULES_DIR"
echo "  • Applications Directory: $APPS_DIR"

root_check
check_dependencies "wine" "unzip" "wget"
install_udev_rule
setup_prefix
install_segoe_ui_font
download_and_install_updater
create_desktop_entry
final_message

# Cleanup function
trap cleanup EXIT
