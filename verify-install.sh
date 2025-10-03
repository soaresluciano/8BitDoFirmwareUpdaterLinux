#!/bin/bash

# Script: 8BitDo Firmware Updater Linux - Installation Validation Script
# Author: Luciano Soares
# Version: 1.0.0
# Description: This script checks if the 8BitDo Firmware Updater is installed correctly

# Colors for output
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# === SCRIPT CONFIGURATION ===
WINE_PREFIX="$HOME/.wine-8bitdo"
TOOL_DIR="$HOME/.local/share/8bitdo-updater"
UDEV_RULES_FILE="/etc/udev/rules.d/71-8bitdo-boot.rules"
DESKTOP_FILE="$HOME/.local/share/applications/8bitdo-updater.desktop"
#=== END SCRIPT CONFIGURATION ===

# Check counters
CHECKS_PASSED=0
CHECKS_TOTAL=0

check_item() {
    local description="$1"
    local check_command="$2"
    local fix_suggestion="$3"
    
    ((CHECKS_TOTAL++))
    
    echo -n "🔍 Checking $description... "
    
    if eval "$check_command" &>/dev/null; then
        echo -e "${GREEN}✓ OK${NC}"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        if [ -n "$fix_suggestion" ]; then
            echo -e "   ${YELLOW}💡 Fix: $fix_suggestion${NC}"
        fi
        return 1
    fi
}

header() {
    echo -e "${MAGENTA}$1${NC}"
}

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     8BitDo Firmware Updater Verification     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo

echo -e "${YELLOW}🎮 Connect your controller in boot mode and press any key to continue...${NC}"
read -n 1 -s -r
echo

header "🔍 System Information"
echo "🔍 Collecting system information..."

# Linux distribution and version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${GREEN}📋 Linux Distribution:${NC} $PRETTY_NAME"
    echo -e "${GREEN}📋 Distribution ID:${NC} $ID"
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    echo -e "${GREEN}📋 Linux Distribution:${NC} $DISTRIB_DESCRIPTION"
    echo -e "${GREEN}📋 Distribution ID:${NC} $DISTRIB_ID"
else
    echo -e "${YELLOW}⚠ Linux Distribution:${NC} Unable to detect"
fi

# Kernel version
KERNEL_VERSION=$(uname -r)
echo -e "${GREEN}📋 Kernel Version:${NC} $KERNEL_VERSION"

# Architecture
ARCH=$(uname -m)
echo -e "${GREEN}📋 Architecture:${NC} $ARCH"

# Desktop environment detection
DESKTOP_ENV="Unknown"
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    DESKTOP_ENV="$XDG_CURRENT_DESKTOP"
elif [ -n "$DESKTOP_SESSION" ]; then
    DESKTOP_ENV="$DESKTOP_SESSION"
elif [ -n "$GDMSESSION" ]; then
    DESKTOP_ENV="$GDMSESSION"
elif pgrep -x "gnome-session" > /dev/null; then
    DESKTOP_ENV="GNOME"
elif pgrep -x "startkde" > /dev/null; then
    DESKTOP_ENV="KDE"
elif pgrep -x "xfce4-session" > /dev/null; then
    DESKTOP_ENV="XFCE"
elif pgrep -x "lxsession" > /dev/null; then
    DESKTOP_ENV="LXDE"
elif pgrep -x "mate-session" > /dev/null; then
    DESKTOP_ENV="MATE"
elif pgrep -x "cinnamon-session" > /dev/null; then
    DESKTOP_ENV="Cinnamon"
fi
echo -e "${GREEN}📋 Desktop Environment:${NC} $DESKTOP_ENV"

# Wine version
if command -v wine &>/dev/null; then
    WINE_VERSION=$(wine --version 2>/dev/null | head -n1)
    echo -e "${GREEN}📋 Wine Version:${NC} $WINE_VERSION"
else
    echo -e "${YELLOW}⚠ Wine Version:${NC} Not installed"
fi

# Display server info
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo -e "${GREEN}📋 Display Server:${NC} Wayland"
elif [ -n "$DISPLAY" ]; then
    echo -e "${GREEN}📋 Display Server:${NC} X11"
else
    echo -e "${YELLOW}⚠ Display Server:${NC} Unknown"
fi

echo

header "�🔧 Checking System Dependencies"
check_item "Wine installation" "command -v wine" "Install Wine"
check_item "Wget availability" "command -v wget" "Install wget"
check_item "Unzip availability" "command -v unzip" "Install unzip"
echo

header "📁 Checking Installation Directories"
check_item "Wine prefix directory" "[ -d '$WINE_PREFIX' ]" "Run setup.sh again to create Wine prefix"
check_item "Tool installation directory" "[ -d '$TOOL_DIR' ]" "Run setup.sh again to download the updater"
check_item "Main executable file" "[ -f '$TOOL_DIR/8BitDo Firmware Updater.exe' ]" "Run setup.sh again to download the updater"
check_item "Launcher script file" "[ -f '$TOOL_DIR/launch-8bitdo-updater.sh' ]" "Run setup.sh again to create launcher script"
echo

header "⚙️  Checking System Integration"
check_item "Udev rules file" "[ -f '$UDEV_RULES_FILE' ]" "Run setup.sh again with sudo privileges"
check_item "Desktop entry file" "[ -f '$DESKTOP_FILE' ]" "Run setup.sh again to create desktop entry"
echo

header "🍷 Checking Wine Configuration"
check_item "Wine prefix accessibility" "WINEPREFIX='$WINE_PREFIX' wine --version" "Run setup.sh again to recreate Wine prefix"
check_item "Required fonts directory" "[ -d '$WINE_PREFIX/drive_c/windows/Fonts' ]" "Run setup.sh again to install fonts"
check_item "Segoe UI font files" "ls '$WINE_PREFIX/drive_c/windows/Fonts/segoe'*.ttf" "Run setup.sh again to install fonts"
echo

header "🎮 Checking Device Configuration"
echo "🔍 Checking current udev rules configuration..."
if [ -f "$UDEV_RULES_FILE" ]; then
    echo -e "${GREEN}✓ Udev rules file exists${NC}"
    echo "📋 Current rules content:"
    cat "$UDEV_RULES_FILE" | sed 's/^/   /'
    echo
    echo -e "${YELLOW}💡 Verify these match your controller's IDs from 'lsusb'${NC}"
else
    echo -e "${RED}✗ Udev rules file not found${NC}"
    echo -e "   ${YELLOW}💡 Run setup.sh with sudo privileges${NC}"
fi
echo

#checks the laucher script
header "🔍 Checking launcher script configuration..."
if [ -f "$TOOL_DIR/launch-8bitdo-updater.sh" ]; then
    echo -e "${GREEN}✓ Launcher script exists${NC}"
    echo "📋 Launcher script key execution lines:"
    grep -E "^cd.*TOOL_DIR|^WINEPREFIX.*wine" "$TOOL_DIR/launch-8bitdo-updater.sh" | sed 's/^/   /'
    echo
    echo "📋 Expected lines:"
    echo "   cd \"$TOOL_DIR\""
    echo "   WINEPREFIX=\"$WINE_PREFIX\" wine \"8BitDo Firmware Updater.exe\""
else
    echo -e "${RED}✗ Launcher script not found${NC}"
    echo -e "   ${YELLOW}💡 Run setup.sh again to create launcher script${NC}"
fi

header "🖥️  Checking Desktop Integration"
if [ -f "$DESKTOP_FILE" ]; then
    echo -e "${GREEN}✓ Desktop entry exists${NC}"
    echo "📋 Desktop entry details:"
    grep -E "^(Name|Exec|Terminal|StartupNotify)=" "$DESKTOP_FILE" | sed 's/^/   /'
else
    echo -e "${RED}✗ Desktop entry not found${NC}"
    echo -e "   ${YELLOW}💡 Run setup.sh again${NC}"
fi
echo

header "🔐 Checking File Permissions and Ownership"
echo "🔍 Checking critical file permissions..."

# Check launcher script permissions
if [ -f "$TOOL_DIR/launch-8bitdo-updater.sh" ]; then
    LAUNCHER_PERMS=$(stat -c "%a" "$TOOL_DIR/launch-8bitdo-updater.sh" 2>/dev/null)
    LAUNCHER_OWNER=$(stat -c "%U" "$TOOL_DIR/launch-8bitdo-updater.sh" 2>/dev/null)
    echo -e "${GREEN}✓ Launcher script permissions:${NC} $LAUNCHER_PERMS (owner: $LAUNCHER_OWNER)"
    if [ "$LAUNCHER_PERMS" -lt 700 ]; then
        echo -e "   ${YELLOW}⚠ Warning: Launcher script may not be executable${NC}"
        echo -e "   ${YELLOW}💡 Run: chmod +x '$TOOL_DIR/launch-8bitdo-updater.sh'${NC}"
    fi
else
    echo -e "${RED}✗ Launcher script not found for permission check${NC}"
fi

# Check desktop file permissions
if [ -f "$DESKTOP_FILE" ]; then
    DESKTOP_PERMS=$(stat -c "%a" "$DESKTOP_FILE" 2>/dev/null)
    DESKTOP_OWNER=$(stat -c "%U" "$DESKTOP_FILE" 2>/dev/null)
    echo -e "${GREEN}✓ Desktop entry permissions:${NC} $DESKTOP_PERMS (owner: $DESKTOP_OWNER)"
    if [ "$DESKTOP_PERMS" -lt 644 ]; then
        echo -e "   ${YELLOW}⚠ Warning: Desktop entry may not be readable${NC}"
        echo -e "   ${YELLOW}💡 Run: chmod 644 '$DESKTOP_FILE'${NC}"
    fi
else
    echo -e "${RED}✗ Desktop entry not found for permission check${NC}"
fi

# Check udev rules permissions (should be owned by root)
if [ -f "$UDEV_RULES_FILE" ]; then
    UDEV_PERMS=$(stat -c "%a" "$UDEV_RULES_FILE" 2>/dev/null)
    UDEV_OWNER=$(stat -c "%U" "$UDEV_RULES_FILE" 2>/dev/null)
    echo -e "${GREEN}✓ Udev rules permissions:${NC} $UDEV_PERMS (owner: $UDEV_OWNER)"
    if [ "$UDEV_OWNER" != "root" ]; then
        echo -e "   ${RED}✗ Warning: Udev rules should be owned by root${NC}"
        echo -e "   ${YELLOW}💡 Run setup.sh with sudo privileges${NC}"
    fi
    if [ "$UDEV_PERMS" != "644" ]; then
        echo -e "   ${YELLOW}⚠ Warning: Udev rules should have 644 permissions${NC}"
        echo -e "   ${YELLOW}💡 Run: sudo chmod 644 '$UDEV_RULES_FILE'${NC}"
    fi
else
    echo -e "${RED}✗ Udev rules not found for permission check${NC}"
fi

# Check Wine prefix directory permissions
if [ -d "$WINE_PREFIX" ]; then
    WINE_PERMS=$(stat -c "%a" "$WINE_PREFIX" 2>/dev/null)
    WINE_OWNER=$(stat -c "%U" "$WINE_PREFIX" 2>/dev/null)
    echo -e "${GREEN}✓ Wine prefix permissions:${NC} $WINE_PERMS (owner: $WINE_OWNER)"
    if [ "$WINE_OWNER" != "$(whoami)" ]; then
        echo -e "   ${RED}✗ Warning: Wine prefix should be owned by current user${NC}"
        echo -e "   ${YELLOW}💡 Run: sudo chown -R $(whoami):$(whoami) '$WINE_PREFIX'${NC}"
    fi
else
    echo -e "${RED}✗ Wine prefix not found for permission check${NC}"
fi

# Check tool directory permissions
if [ -d "$TOOL_DIR" ]; then
    TOOL_PERMS=$(stat -c "%a" "$TOOL_DIR" 2>/dev/null)
    TOOL_OWNER=$(stat -c "%U" "$TOOL_DIR" 2>/dev/null)
    echo -e "${GREEN}✓ Tool directory permissions:${NC} $TOOL_PERMS (owner: $TOOL_OWNER)"
    if [ "$TOOL_OWNER" != "$(whoami)" ]; then
        echo -e "   ${RED}✗ Warning: Tool directory should be owned by current user${NC}"
        echo -e "   ${YELLOW}💡 Run: sudo chown -R $(whoami):$(whoami) '$TOOL_DIR'${NC}"
    fi
else
    echo -e "${RED}✗ Tool directory not found for permission check${NC}"
fi
echo

header "🎯 Connected 8BitDo Devices"
echo "🔍 Scanning for connected 8BitDo devices..."
DEVICES=$(lsusb | grep -i "8bitdo\|2dc8")
if [ -n "$DEVICES" ]; then
    echo -e "${GREEN}✓ Found 8BitDo device(s):${NC}"
    echo "$DEVICES" | sed 's/^/   /'
    echo
    echo -e "${YELLOW}💡 Make sure your udev rules match these device IDs${NC}"
else
    echo -e "${YELLOW}ℹ No 8BitDo devices currently connected${NC}"
    echo -e "   ${YELLOW}💡 Connect your controller to test device detection${NC}"
fi
echo

# Summary
header "📊 Verification Summary"
echo "════════════════════════════════════════════"
echo -e "Checks passed: ${GREEN}$CHECKS_PASSED${NC}/${CHECKS_TOTAL}"

if [ "$CHECKS_PASSED" -eq "$CHECKS_TOTAL" ]; then
    echo -e "${GREEN}🎉 All checks passed! Installation appears to be complete.${NC}"
    echo
    echo -e "${GREEN}✨ You can now:${NC}"
    echo -e "   • Search for '8BitDo Firmware Updater' in your application menu"
    echo -e "   • Put your controller in update mode and connect via USB"
    echo -e "   • Launch the updater and follow the on-screen instructions"
elif [ "$CHECKS_PASSED" -gt $((CHECKS_TOTAL / 2)) ]; then
    echo -e "${YELLOW}⚠ Partial installation detected. Some components may need attention.${NC}"
    echo -e "   ${YELLOW}💡 Try running ./setup.sh again${NC}"
else
    echo -e "${RED}❌ Installation appears incomplete or failed.${NC}"
    echo -e "   ${RED}💡 Run ./setup.sh to install or repair the installation${NC}"
fi

echo
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}For more help, see the README.md or report issues on GitHub${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"