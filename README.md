# Install ARCH Linux with Windows Dual Boot - UEFI

## Install windows 10

We have to install windows 10 with 1GB for UFI partition. This enable to install another linux distros like PopOs. Which requieres more space in this partition. Thats why we need to create a EFI partition before installing Windows 10.

1. Create installation media with Microsoft Tool.
2. To install windows 10 pro we need to create a file inside the instalation media in directory `sources/` with name `ei.cfg` with content:

```batch
[Channel]
_Default
[VL]
0
```

3. Boot on instalation media and before partitioning step or click "Refresh" if do this during this step:
   * Pres `Shift` + `F10` to open Command Line.
   * Type `diskpart` and `Enter`.
   * Type `list disk` and `Enter`.
   * Type `select disk <<number>>` and `Enter`. Number is the disk that we want to clean and install windows.
   * Type `clean` and `Enter`. Clean all content.
   * Type `convert gpt`
   * Type `create partition efi size=500` and `Enter`. 500 is the size in MB of the partition.
   * Type `exit` and `Enter` to close Command Line.
   * Now in partition step, click on empty disk an click `New`. This will crate two partition (MSR and Primary).
   * Click next and then it will install windows 10.

## Install Arch Linux

1. Partition disck in `Disck Management` windows 10 tool. Create an empty partition to install Arch (root, home y swap).

2. Create instalation media with `rufus.exe` and Arch Linux ISO resource.

3. Reboot on Arch instalation media.

4. Test internet connection `ping google.com`.
   * For WIFI connection:
   * `ip link set wlan0 up`

5. Enable NTP

```bash
timedatectl set-ntp true
```
6. Disk partitions:

```bash
fdisk -l # or lsblk

mkfs.ext4 /dev/{partition} # Root partition.

mkfs.ext4 /dev/{partition} # Home partition.

mkswap /dev/{partition} # Swap partition.

swapon /dev/{partition} # Swap partition.

mount /dev/{root partition} /mnt

mkdir /mnt/home

mkdir /mnt/boot

mount /dev/{home partition} /mnt/home

mount /dev/{boot partition} /mnt/boot
```

7. Install BASE

```bash
pacstrap /mnt linux linux-firmware linux-headers base base-devel nano neovim grub efibootmgr os-prober iw wpa_supplicant dialog networkmanager dhcpcd netctl git
```

8. Gen FsTab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

9. Enter to system

```bash
arch-chroot /mnt
```

10. Configure Timezone

```bash
ln -sf /usr/share/zoneinfo/America/{timezone} /etc/localtime
```

11. Sync clock

```bash
hwclock --systohc
```

12. Configure lang

```bash
nvim /etc/locale.gen

# uncoment
en_US.UTF-8 UTF-8
es_EC.UTF-8 UTF-8

# Type :wq and Enter

# Generate configuration
locale-gen

nvim /etc/locale.conf

# Add
LANG=en_US.UTF-8

# Type :wq and Enter
```

13. Configure hostname and hosts
```bash
# Hostname
echo "{hostname}" > /etc/hostname

# Hosts
nvim /etc/hosts

# Add:
127.0.0.1		localhost
::1				localhost
127.0.1.1		{hostname}.localdomain		{hostname}

# Type :wq and Enter
```
14.  Configure user

```bash
# Set admin password
passwd

# Add normal user
useradd -g users -G power,storage,wheel -m {username}

# Set password
passwd {username}
```

15. Configure GRUB

```bash
# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=ArchLinux

# Test windows partition. If not detected, you can do this again when system reboots.
os-prober

# Enable os-prober
nano /etc/default/grub

# Uncomment
GRUB_DISABLE_OS_PROBER=false

# Type :wq and Enter

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

16. Apply Mkinitcpio config

```bash
mkinitcpio -P
```

17. Exit and Reboot

## Post Arch instalation

### Enable Services

```sh
systemctl enable NetworkManager.service

systemctl start NetworkManager.service

systemctl enable sddm.service

systemctl enable bluetooth.service
```

### Clone dotfiles

```bash
cd ~

git init

git remote add origin https://github.com/eduzhizhpon/dotfiles

git pull
```

### Install basics

```bash
pacman -S nvidia nvidia-utils nvidia-settings xorg sddm dmenu feh firefox arandr dunst pavucontrol slock playerctl pipewire-pulse pipewire-alsa gnome-themes-standard wget p7zip unzip gnome-keyring libsecret libgnome-keyring bluez bluez-utils blueman flameshot ibus polkit-gnome gwenview xclip discord
```
### Install PARU

```bash
git clone https://aur.archlinux.org/paru-bin

makepkg -si
```
### BSPWM WM

```bash
paru -S bspwm sxhkd polybar
```

### Install necessary packages

```bash
paru -Sy alacritty picom-git rofi lxappearance redshift alsa-utils ttf-fira-code nautilus gnome-disk-utility vlc dolphin qt5ct gnome-terminal yay google-chrome visual-studio-code-bin ttf-material-design-icons breeze breeze-gtk

paru -S ttf-liberation ttf-dejavu noto-fonts

paru -S ttf-ms-fonts noto-fonts-cjk ttf-baekmuk noto-fonts-emoji

paru -S fontconfig copyq
```

### Install Fira Code Nerd Font

```bash
# Download Fira Code Nerd Font from: https://www.nerdfonts.com/font-downloads

# Create directory
mkdir -p ~/.local/share/fonts/FiraCodeNerdFont

# Unzip fonts
unzip /path/to/downloaded/font.zip -d ~/.local/share/fonts/FiraCodeNerdFont

# Or copy  
cp /path/to/downloaded/fonts/* ~/.local/share/fonts/FiraCodeNerdFont

# Update font cache
fc-cache -fv

# Show installed fonts
fc-list
```

# Installing Fira Code Nerd Font on macOS

```bash
# Download Fira Code Nerd Font from: https://www.nerdfonts.com/font-downloads

# Create the fonts directory (optional on macOS)
mkdir -p ~/Library/Fonts/FiraCodeNerdFont

# Unzip fonts to the fonts directory
unzip /path/to/downloaded/font.zip -d ~/Library/Fonts/FiraCodeNerdFont

# Or copy fonts directly
cp /path/to/downloaded/fonts/* ~/Library/Fonts/FiraCodeNerdFont

# No need to run fc-cache; macOS handles fonts automatically

# Verify installed fonts
system_profiler SPFontsDataType | grep "FiraCode"
```

### Nvidia Config

1. GRUB config

```sh
nvim /etc/default/grub

## Append to GRUB_CMDLINE_LINUX_DEFAULT
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash nvidia-drm.modeset=1"

## Apply GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```
2. Mkinitcpio config (early loading)

```sh
nvim /etc/mkinitcpio.conf

## Append to modules
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

## Apply Mkinitcpio config
mkinitcpio -P
```

## Configs

### Save git credentials

```sh
git config --global credential.helper store
```

### Disable mouse acceleration

1. Access to config folder

```bash
# Access to folder
cd /usr/share/X11/xorg.conf.d/

# Create config file (no matter the name)
nvim 90-mouse_accel.conf
```

2. Add config to file

```bash
Section "InputClass"
        Identifier "Mouse With No Acceleration"
        MatchDriver "libinput"
        MatchIsPointer "yes"
        Option "AccelProfile" "flat"
EndSection
```
### Custom zsh Terminal

```bash

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# simple type zsh to configure or:
p10k configure

pacman -S zsh locate lsd bat
paru -S zsh-syntax-highlighting zsh-autosuggestions

# Do it also with root
usermod --shell /usr/bin/zsh $USER

# Link configs
sudo su
cd
ln -s <USER HOME>/.zshrc .
ln -s <USER HOME>/.p10k.zsh .

# zsh sudo
sudo mkdir /usr/share/zsh/plugins/zsh-sudo && cd $_

sudo curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh --output sudo.plugin.zsh
```

### Fix cursor size

1. Create config file

```
sudo nano /etc/X11/xorg.conf.d/30-cursor.conf

```
2. Add:

```bash
Section "InputClass"
    Identifier "Cursor Settings"
    MatchIsPointer "yes"
    Option "Xcursor.theme" "Adwaita"
    Option "Xcursor.size" "24"
EndSection
```

### Themes

```bash
paru -S papirus-icon-theme xsettingsd adwaita-qt5-git adwaita-qt6-git kvantum-qt5
```

