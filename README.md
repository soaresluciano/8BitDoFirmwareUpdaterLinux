# 8BitDo Firmware Updater Linux

This automated script sets up the official 8BitDo Firmware Updater Tool to operate on Linux systems through Wine. It allows Linux users to easily upgrade their 8BitDo controller firmware without the need for Windows.

I made this script to document and automate my steps, hoping others find it useful too.

**Based on the excellent work shared at:** https://gist.github.com/archeYR/d687de5e484ce7b45d6a94415a04f3dc

## 🎮 What This Does

1. ✅ Check for required dependencies
2. 🔧 Install udev rules for device access
3. 🍷 Create and configure a Wine prefix
4. 📦 Download the official 8BitDo Firmware Updater
5. 🎨 Install required fonts (Segoe UI)
6. 🖥️ Create a desktop application entry

## 🔧 Prerequisites

Before running the setup script, ensure you have the following installed:

- **Wine** (for running windows apps)
- **wget** (for downloading files)
- **unzip** (for extracting archives)
- **sudo access** (for installing udev rules)

## 🚀 Quick Start

1. **Clone this repository:**
   ```sh
   git clone https://github.com/soaresluciano/8BitDoFirmwareUpdaterLinux.git
   cd 8BitDoFirmwareUpdaterLinux
   ```

2. **Identify your device (important!):**
   ```sh
   lsusb
   ```
   or the detailed version
   ```sh
   lsusb -v
   ```
   Look for a line containing "8BitDo" or your device's model. It will show something like:
    ```
    Bus 001 Device 005: ID 2dc8:5750 8BitDo SN30 Pro
    ```

    In this example:
    - Vendor ID (idVendor): `2dc8`
    - Product ID (idProduct): `5750`

3. **Update device configuration:**
   Edit `assets/71-8bitdo-boot.rules` with your device's Vendor ID and Product ID

4. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

5. **Launch the updater:**
   Search for "8BitDo Firmware Updater" in your application menu

6. **Verify installation (optional):**
   ```bash
   ./verify-install.sh
   ```

## 💡 Usage

### Launching the Application

After successful installation, you can launch the firmware updater in several ways:

1. **Application Menu:** Search for "8BitDo Firmware Updater"
2. **Command Line:**
   ```sh
   WINEPREFIX="$HOME/.wine-8bitdo" wine "$HOME/.local/share/8bitdo-updater/8BitDo Firmware Updater.exe"
   ```

### Updating Controller Firmware

1. Put your controller into **update mode** (refer to your controller's manual)
2. Connect the controller via USB
3. Launch the 8BitDo Firmware Updater
4. Follow the on-screen instructions in the updater

### Debug Information

If you need to troubleshoot:

1. **Check Wine configuration:**
   ```sh
   WINEPREFIX="$HOME/.wine-8bitdo" winecfg
   ```

2. **View Wine logs:**
   ```sh
   WINEPREFIX="$HOME/.wine-8bitdo" WINEDEBUG=+all wine "$HOME/.local/share/8bitdo-updater/8BitDo Firmware Updater.exe" 2>&1 | less
   ```

3. **Check udev rules:**
   ```sh
   sudo udevadm info --attribute-walk --name=/dev/hidraw0
   ```

4. **Check the usb connectivity of you device:**
   ```sh
   sudo dmesg | tail -20
   ```

For development, you can run the script in debug mode:
```sh
./setup.sh debug
```
This creates a local test environment in the `DEBUG/` directory without modifying system files.

## 🙏 Acknowledgments

- Original guide created by [archeYR](https://gist.github.com/archeYR/d687de5e484ce7b45d6a94415a04f3dc)
- 8BitDo for creating excellent controllers and providing firmware update tools
- The Wine project for enabling Windows applications on Linux

## ⚖️ License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

**Note:** This project provides a setup script for the official 8BitDo Firmware Updater, which remains the property of 8BitDo and is subject to their own terms and conditions.


**Enjoy gaming with your updated 8BitDo controllers on Linux! 🎮🐧**
