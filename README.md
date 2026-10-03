# Arch Linux Dual Boot & MWM Desktop Installation Guide

A complete, step-by-step installation guide to set up Arch Linux in Dual Boot with Windows 10 (UEFI), clone your dotfiles, and deploy the modular **MWM** desktop environment (**Sway**, **Hyprland**, **i3**, or **BSPWM**) in a fast, automated way.

---

## Table of Contents

1. [Step 1: Install Windows 10 (UEFI Dual Boot Preparation)](#step-1-install-windows-10-uefi-dual-boot-preparation)
2. [Step 2: Base Arch Linux Installation](#step-2-base-arch-linux-installation)
3. [Step 3: Post-Arch Base Setup & Clone Dotfiles](#step-3-post-arch-base-setup--clone-dotfiles)
4. [Step 4: Desktop Environment Setup with `mwm.sh`](#step-4-desktop-environment-setup-with-mwmsh)
5. [Step 5: System Services, Shell & Git Configuration](#step-5-system-services-shell--git-configuration)
6. [Step 6: Hardware & Driver Tweaks](#step-6-hardware--driver-tweaks)

---

## Step 1: Install Windows 10 (UEFI Dual Boot Preparation)

To ensure a seamless dual boot setup, create the EFI partition with sufficient size (500MB–1GB) before installing Windows 10. This avoids partition size limitations when sharing the EFI partition with Arch Linux.

1. Create a bootable Windows 10 installation USB using Microsoft's official Media Creation Tool.
2. *(Optional for Windows 10 Pro)*: To enforce Windows 10 Pro installation, create a file named `ei.cfg` inside the `sources/` folder of the USB drive with the following content:

   ```ini
   [Channel]
   _Default
   [VL]
   0
   ```

3. Boot your PC from the Windows 10 installation media.
4. On the setup screen (before or during the partition selection step):
   - Press `Shift` + `F10` to open Command Prompt.
   - Run the following commands:

   ```cmd
   diskpart
   list disk
   select disk 0
   clean
   convert gpt
   create partition efi size=500
   exit
   ```
   *(Note: Replace `0` with the actual disk number where you intend to install the OS).*

5. Close the Command Prompt. In the Windows partition manager, select the unallocated space and click **New** and **Apply** (Windows will automatically create the MSR and Primary partitions).
6. Select the Primary partition and proceed with the Windows 10 installation.

---

## Step 2: Base Arch Linux Installation

### 2.1 Boot into Arch Linux Live Environment & Connect to Internet
1. Flash the Arch Linux ISO to a USB drive using **Rufus** (GPT/UEFI mode) or `dd`.
2. Boot your machine from the Arch Linux installation USB in UEFI mode.
3. **Connect to Internet**:
   - **Ethernet**: Connected automatically via DHCP.
   - **WiFi (Interactive `iwctl`)**:
     ```bash
     iwctl
     [iwd]# station wlan0 scan
     [iwd]# station wlan0 get-networks
     [iwd]# station wlan0 connect "YOUR_WIFI_SSID"
     # If network SSID is hidden:
     [iwd]# station wlan0 connect-hidden "HIDDEN_SSID"
     [iwd]# exit
     ```
     *(Or as a one-liner: `iwctl --passphrase "PASSWORD" station wlan0 connect "SSID"`)*.
4. Verify connection & synchronize clock:
   ```bash
   ping -c 3 google.com
   timedatectl set-ntp true
   ```

### 2.2 Disk Partitioning

Identify your disk with `lsblk` or `fdisk -l`, then partition:

- **Option A (From Windows)**: Shrink volume in **Disk Management** (`diskmgmt.msc`) to leave unallocated free space.
- **Option B (From Linux CLI)**: Run `cfdisk /dev/nvme0n1` (or `/dev/sda`):
  - **Root (`/`)**: ~50–100GB+ (or all remaining space if not creating a separate `/home`) -> `Linux filesystem`
  - **Swap**: ~4–16GB -> `Linux swap`
  - **Home (`/home`, Optional)**: Remaining space -> `Linux filesystem`
  - *(If standalone without Windows)*: Create `500M` -> `EFI System`
  - Select **[ Write ]** -> `yes` -> **[ Quit ]**.

### 2.3 Format & Mount Partitions

```bash
# Format partitions
mkfs.ext4 /dev/{root_partition}
mkswap /dev/{swap_partition}
swapon /dev/{swap_partition}
mkfs.ext4 /dev/{home_partition}       # Optional (only if you created a separate /home)

# Mount filesystems
mount /dev/{root_partition} /mnt
mkdir -p /mnt/boot
mount /dev/{efi_partition} /mnt/boot  # EFI partition from Step 1 (or Step 2.2)

# Optional: Mount separate home (if created)
mkdir -p /mnt/home
mount /dev/{home_partition} /mnt/home
```

### 2.4 Install the Base System
Bootstrap the Linux kernel, headers, and core utilities:

```bash
pacstrap /mnt linux linux-firmware linux-headers base base-devel nano neovim grub efibootmgr os-prober networkmanager git
```

### 2.5 Generate FSTAB & Chroot
```bash
# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the newly installed system
arch-chroot /mnt
```

### 2.6 Localization and System Configuration
1. **Timezone & Hardware Clock**:
   ```bash
   ln -sf /usr/share/zoneinfo/America/{Your_Timezone} /etc/localtime
   hwclock --systohc
   ```

2. **Locales**:
   Edit `/etc/locale.gen`:
   ```bash
   nvim /etc/locale.gen
   ```
   Uncomment:
   ```text
   en_US.UTF-8 UTF-8
   es_EC.UTF-8 UTF-8
   ```
   Generate locales and configure default language:
   ```bash
   locale-gen
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```

3. **Hostname**:
   ```bash
   echo "my-laptop" > /etc/hostname
   ```
   Edit `/etc/hosts`:
   ```text
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   my-laptop.localdomain my-laptop
   ```

4. **Root Password & Create User**:
   ```bash
   # Set root password
   passwd

   # Create administrative user
   useradd -m -g users -G wheel,power,storage,video,audio -s /bin/bash username
   passwd username

   # Enable sudo privileges for wheel group
   EDITOR=nvim visudo
   # Uncomment: %wheel ALL=(ALL:ALL) ALL
   ```

### 2.7 Configure Bootloader (GRUB with Dual Boot)
```bash
# Install GRUB for UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=ArchLinux

# Enable OS Prober for Windows detection
nvim /etc/default/grub
# Ensure the following line is set or uncommented:
GRUB_DISABLE_OS_PROBER=false

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Rebuild initramfs
mkinitcpio -P
```

### 2.8 Exit and Reboot
```bash
exit
umount -R /mnt
reboot
```

---

## Step 3: Post-Arch Base Setup & Clone Dotfiles

Log in with your normal user account.

### 3.1 Enable Networking & Connect to WiFi
```bash
# Start and enable NetworkManager
sudo systemctl enable --now NetworkManager.service

# If using WiFi (visible network):
nmcli device wifi list
nmcli device wifi connect "YOUR_WIFI_SSID" password "YOUR_PASSWORD"

# If using WiFi (hidden SSID network):
nmcli device wifi connect "HIDDEN_SSID" password "YOUR_PASSWORD" hidden yes
```

### 3.2 Clone Dotfiles into User Home
```bash
cd ~
git init
git remote add origin <your_dotfiles_repository_url>
git pull origin master
```

---

## Step 4: Desktop Environment Setup with `mwm.sh`

Instead of running dozens of manual package commands prone to missing dependencies, the repository provides the modular [`mwm.sh`](mwm.sh) installer.

The installer queries the local database in milliseconds (`pacman -Qq`) and **only installs missing packages**, auto-detecting your package manager (`paru`, `yay`, or `pacman`).

### 4.1 Install Your Preferred Desktop Environment

Run the script with the desired desktop profile:

```bash
# Option A: Sway (Wayland - Recommended)
./mwm.sh --sway

# Option B: Hyprland (Wayland)
./mwm.sh --hyprland

# Option C: i3 (X11)
./mwm.sh --i3

# Option D: BSPWM (X11)
./mwm.sh --bspwm

# Option E: Install all environments and applications
./mwm.sh --all
```

> [!TIP]
> **Check / Dry-Run Mode:**  
> You can inspect which packages are already installed and which ones are missing without making any system changes:
> ```bash
> ./mwm.sh --sway --check
> ```

### 4.2 Modular & Granular Options

Install or check specific modules using `-m` or `--module`:

```bash
# Install core tools and typography only
./mwm.sh -m core -m fonts

# Install user applications (kitty, neovim, vlc, visual-studio-code-bin, etc.)
./mwm.sh -m apps

# Install Nvidia GPU drivers
./mwm.sh -m nvidia

# Run setup hooks only (e.g. fc-cache, compile themes)
./mwm.sh --setup-only
```

### 4.3 Available Modules (`.config/my-wm/scripts/install/modules/`)

- **`core`**: Universal base tools (`jq`, `rofi`, `dunst`, `playerctl`, `pamixer`, `pipewire-pulse`, `brightnessctl`, `cliphist`, `wl-clipboard`, `xclip`, `polkit-gnome`, `gnome-keyring`, `bluez`, etc.).
- **`fonts`**: Nerd fonts & system typography (`ttf-roboto-mono-nerd`, `ttf-firacode-nerd`, `noto-fonts`, `ttf-liberation`, `fontconfig`).
- **`themes`**: GTK & Qt styling engines (`papirus-icon-theme`, `nwg-look`, `qt5ct`, `qt6ct`, `kvantum-qt5`, `breeze`, `adwaita-qt5-git`, `adwaita-qt6-git`).
- **`sway`**: Sway Wayland suite (`sway`, `waybar`, `swaylock`, `swayidle`, `swaybg`, `grim`, `slurp`, `xdg-desktop-portal-wlr`, `kitty`).
- **`hyprland`**: Hyprland Wayland suite (`hyprland`, `waybar`, `hyprpaper`, `qt5-wayland`, `qt6-wayland`, `xdg-desktop-portal-hyprland`).
- **`i3`**: i3 X11 suite (`i3-wm`, `i3lock`, `dex`, `xss-lock`, `nm-applet`, `polybar`, `picom`, `slock`, `sxhkd`, `alacritty`).
- **`bspwm`**: BSPWM X11 suite (`bspwm`, `sxhkd`, `polybar`, `picom`, `feh`, `slock`, `alacritty`).
- **`shell`**: Zsh and shell productivity enhancements (`zsh`, `lsd`, `bat`, `zsh-syntax-highlighting`, `zsh-autosuggestions`, `plocate`).
- **`apps`**: User applications (`kitty`, `alacritty`, `neovim`, `nautilus`, `gnome-disk-utility`, `vlc`, `vlc-plugins-all`, `vlc-gui-skins2`, `google-chrome`, `visual-studio-code-bin`).
- **`nvidia`**: GPU drivers & management tools (`nvidia-open`, `nvidia-utils`, `nvidia-settings`).

---

## Step 5: System Services, Shell & Git Configuration

### 5.1 Enable Essential Services
```bash
# Bluetooth and Display Manager (SDDM)
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now sddm.service

# User keyring daemon
systemctl --user daemon-reexec
systemctl --user enable --now gnome-keyring-daemon.service
```

### 5.2 Configure Zsh & Powerlevel10k
```bash
# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# Set default shell to Zsh
chsh -s /usr/bin/zsh $USER

# Install zsh-sudo plugin
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo
sudo curl -s https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
```

### 5.3 Configure Git SSH Keys
```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github_ed25519

# 2. Configure ~/.ssh/config
cat <<EOF >> ~/.ssh/config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    IdentitiesOnly yes
EOF

chmod 700 ~/.ssh
chmod 600 ~/.ssh/config ~/.ssh/github_ed25519

# 3. Test SSH connection
ssh -T git@github.com
```

---

## Step 6: Hardware & Driver Tweaks

### 6.1 Apple / Keychron Keyboard F1–F12 Keys Fix
Fixes issues where F1–F12 keys act as media controls by default:
```bash
echo "options hid_apple fnmode=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo mkinitcpio -P
```

### 6.2 Nvidia Early Loading & Power Management
In `/etc/default/grub`:
```sh
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash nvidia-drm.modeset=1"
```
Apply GRUB changes and enable power management services:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
```

### 6.3 SDDM Hybrid Graphics Freeze Fix
For laptops with hybrid graphics (Intel/AMD + Nvidia) freezing on login:
1. In `/usr/share/sddm/scripts/Xsetup`:
   ```bash
   xrandr --setprovideroutputsource modesetting NVIDIA-0
   xrandr --auto
   ```
2. In `/etc/X11/xorg.conf.d/10-nvidia.conf`:
   ```conf
   Section "OutputClass"
       Identifier "nvidia"
       MatchDriver "nvidia-drm"
       Driver "nvidia"
       Option "PrimaryGPU" "yes"
   EndSection
   ```

### 6.4 Mouse Acceleration & Cursor Size (X11)
- **Disable Mouse Acceleration**: In `/etc/X11/xorg.conf.d/90-mouse_accel.conf`:
  ```conf
  Section "InputClass"
      Identifier "Mouse With No Acceleration"
      MatchDriver "libinput"
      MatchIsPointer "yes"
      Option "AccelProfile" "flat"
  EndSection
  ```
- **Cursor Size & Theme**: In `/etc/X11/xorg.conf.d/30-cursor.conf`:
  ```conf
  Section "InputClass"
      Identifier "Cursor Settings"
      MatchIsPointer "yes"
      Option "Xcursor.theme" "Adwaita"
      Option "Xcursor.size" "24"
  EndSection
  ```

---

## 🎨 Theme Engine & System Specifications

The desktop appearance is managed by a centralized, contract-driven theme engine in `.config/my-wm/theme/`:

- **Font Contract**: `.config/my-wm/theme/fonts.json`
- **Compiled Artifacts**: `.config/my-wm/theme/generated/`
- **Compile fonts & live reload active session**:
  ```bash
  ~/.config/my-wm/scripts/theme/apply.sh fonts
  ```

For complete architectural specifications, see [`.config/.ai-specs/`](.config/.ai-specs/):
- [`theme-architecture.md`](.config/.ai-specs/docs/theme-architecture.md) — Theme and font compilation engine.
- [`installer-architecture.md`](.config/.ai-specs/docs/installer-architecture.md) — Modular package installer specification.
