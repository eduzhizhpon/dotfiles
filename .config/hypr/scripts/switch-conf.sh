#!/bin/bash
#
# switch-conf.sh
#
# Dynamically sources a configuration file from a specified sub-folder within ~/.config/hypr/conf.
#
# Usage:
#   switch-conf.sh <folder> [value]
#
# Parameters:
#   <folder>: The name of the configuration sub-folder (e.g., 'monitors', 'workspaces').
#   [value]:  Optional. The specific configuration file to use (without the .conf extension).
#             If not provided, it defaults to 'default'.
#             For the 'monitors' folder, it will use the $DEVICE environment variable if 'value' is empty.
#
# Example:
#   switch-conf.sh monitors 1920x1080
#   -> This sources ~/.config/hypr/conf/monitors/1920x1080.conf into ~/.config/hypr/conf/monitor.conf
#
#   switch-conf.sh workspaces starlord
#   -> This sources ~/.config/hypr/conf/workspaces/starlord.conf into ~/.config/hypr/conf/workspace.conf
#

set -e

FOLDER=$1
OUTPUT_NAME=$2

if [ [ -z "$FOLDER" ] || [ -z "$OUTPUT_NAME"] ]; then
    echo "Error: Configuration folder not specified."
    echo "Usage: $0 <folder> [output name]"
    exit 1
fi

CONF_DIR="$HOME/.config/hypr/conf"
SOURCE_DIR="$CONF_DIR/$FOLDER"
TARGET_CONF="$CONF_DIR/$OUTPUT_NAME.conf"
VALUE=$DEVICE

# Determine the source file, defaulting to 'default.conf'
SOURCE_FILE="$SOURCE_DIR/default.conf"
if [ -n "$VALUE" ] && [ -f "$SOURCE_DIR/$VALUE.conf" ]; then
    SOURCE_FILE="$SOURCE_DIR/$VALUE.conf"
fi

# Create the source line in the target configuration file
echo "source = $SOURCE_FILE" > "$TARGET_CONF"
