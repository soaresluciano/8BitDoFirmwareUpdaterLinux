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

- **wine** (for running windows apps)
- **wget** (for downloading files)
- **unzip** (for extracting archives)
- **sudo access** (for installing udev rules)

## ⚠️ Known Issues
These are known issues that I'm working on. They do not affect the usage of the app or the update process: 
- A dialog with a lengthy error message (Fatal Error code: 0x80041002 str: ...) may appear behind the main application window. 
**Do not close this dialog** - simply leave it running in the background, as closing it will shut down the main application.

## 🎮 Device Boot Mode

To update your controller's firmware, you need to put it into boot/update mode:

1. Connect the controller via USB while holding `L + R` buttons to enter **boot mode**.
2. The orange LED will start blinking, indicating the controller is in boot mode and ready for firmware updates.

**Note:** Different controller models may have different button combinations for entering boot mode. Always check your specific controller's manual for the correct procedure.

## 🚀 Quick Start

1. **Clone this repository:**
   ```sh
   git clone https://github.com/soaresluciano/8BitDoFirmwareUpdaterLinux.git
   cd 8BitDoFirmwareUpdaterLinux
   ```

2. **Identify your device (important!):**
   Connect your device in **boot mode** and check if it is detected by using:
   ```sh
   lsusb
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

4. **Script configuration (optional):**
   Review and customize the default paths used by the script if needed.
   You can find these variables at the top of the `setup.sh` file.
   _See [Script Configuration](#script-configuration) section for details._

5. **Run the setup script:**
   Execute the script using:
   ```sh
   ./setup.sh
   ```
   - During execution, you may be prompted to install Mono. Accept the installation when prompted.

## ⚙️ Script Configuration

The setup script uses configurable paths that you can customize at the top of `setup.sh`. Most users can run the script with default settings, but you may need to adjust these if your system uses non-standard locations:

 - `WINE_PREFIX_DIR`: Base directory for Wine prefixes (default: `$HOME`).
 - `WINE_PREFIX_NAME`: Name (and directory) of the Wine prefix (default: `.wine-8bitdo`).
 - `TOOL_DIR`: Installation directory for the Windows 8BitDo application files (default: `$HOME/.local/share/8bitdo-updater`).
 - `UDEV_RULES_DIR`: System directory for udev rules (default: `/etc/udev/rules.d`).
 - `APPS_DIR`: Directory for desktop application entries (default: `$HOME/.local/share/applications`).

## 💡 Usage

### Launching the Application

After successful installation, you can launch the firmware updater via:

1. **App Launcher:** You will find a new item named "8BitDo Firmware Updater"
2. **Launch Script:** `$HOME/.local/share/8bitdo-updater/launch-8bitdo-updater.sh`
3. **Command Line:**
   ```sh
   WINEPREFIX="$HOME/.wine-8bitdo" wine "$HOME/.local/share/8bitdo-updater/8BitDo Firmware Updater.exe"
   ```

### Updating Controller Firmware

Here are the steps I follow to update my SN30 PRO controller:

1. Launch the 8BitDo Firmware Updater.
2. Connect the controller via USB in **update mode**.
3. The application will automatically load the list of available devices.
   - If the list does not load, most probably, your device was not detected or is not in boot mode. You can still try the "Update Manually" option in the app's main menu (the icon on the title bar).
4. Select your device from the list.
5. Choose the firmware version you want to install, then click the "Update" button.
6. The "Update" button will transform into a progress bar as the update begins.
   - You can monitor the progress in the terminal output as well.
7. When the update completes, the progress bar will turn into a green button displaying "Update complete".
8. You can now close the application. 

## 🔧 Troubleshoot

Here are some helpful commands for troubleshooting:

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

4. **Check the USB connectivity of your device:**
   ```sh
   sudo dmesg | tail -20
   ```
   or

   ```sh
   sudo dmesg -w
   ```

5. **Detail information of USB devices**
   
   all devices
   ```
   lsusb -v
   ```

   Vendor ID `2dc8` Product ID `5750`
   ```
   lsusb -v -d 2dc8:6001
   ```

## 🛠️ Development

For development, you can run the script in debug mode:
```sh
./setup.sh debug
```
This creates a local test environment in the `DEBUG/` directory without modifying system files.

## 🙏 Acknowledgments

- [archeYR](https://gist.github.com/archeYR/d687de5e484ce7b45d6a94415a04f3dc) for creating and sharing the original guide.
- [mrbvrz](https://github.com/mrbvrz/segoe-ui-linux) for sharing the segoe fonts pack.
- [Wine project](https://www.winehq.org/) for enabling Windows applications on Linux.
- [8BitDo](https://www.8bitdo.com/) for creating excellent controllers and providing firmware update tools. We're waiting for Linux support though ;)

## ⚖️ License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

**Note:** This project provides a setup script for the official 8BitDo Firmware Updater, which remains the property of 8BitDo and is subject to their own terms and conditions.


**Enjoy gaming with your updated 8BitDo controllers on Linux! 🎮🐧**
