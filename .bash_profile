#
# ~/.bash_profile
#

# ==================================================
# Default PATHs
# ==================================================

[[ -f ~/.bashrc ]] && . ~/.bashrc

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# ==================================================
# User environment variables
# ==================================================

# Java JDK
export JAVA_HOME="/opt/jvm/jdk-11.0.13"
export JBOSS_HOME="/opt/wildfly-26"

# Android studio
export ANDROID_SDK_ROOT="/media/data/linux/apps/android/sdk"
export ANDROID_HOME="/media/data/linux/apps/android/sdk"
export ANDROID_STUDIO_HOME="/media/data/linux/apps/android/android-studio"

# NodeJS
export NODE_HOME="/opt/node-v14"

# Docker
export DOCKER_HOME="/opt/docker-20.10.9"

# QTILE (Disabled)
#export QTILE_HOME="/home/eddzhizhpon/.config/qtile"

# ==================================================
# Export binaries
# ==================================================

# Binaries list
path_list=(
    "$ANDROID_STUDIO_HOME/bin"
    "$ANDROID_SDK_ROOT/tools/bin"
    "$ANDROID_SDK_ROOT/platform-tools"
    "$ANDROID_SDK_ROOT/emulator"

    "$NODE_HOME/bin"
    "$JAVA_HOME/bin"
    "$DOCKER_HOME"

    "$HOME/.config/scripts"
    
)

# Function to export $path_list binaries
for path_bin in "${path_list[@]}"; do
    if [ -d "$path_bin" ] ; then
        PATH="$PATH:$path_bin";
    fi
done

# ==================================================
# Config environment variables
# ==================================================

# IBus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# LS Colors Fix
export LS_COLORS="ow=1;30;104"

# GTK and Qt compatibility
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SELECT="5"
#export QT_STYLE_OVERRIDE="gtk2"
#export QT_STYLE_OVERRIDE=adwaita-dark

# Crontab Editor
export EDITOR='nvim'

# Wallpaper
export WALLPAPER="/media/data/images/wallpaper/w-4.jpg"

# VS Code LiveShare "Couldn't find a valid ICU package installed 
# on the system" solution
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Gnome dark theme
export GTK_THEME=Adwaita:dark
