#!/bin/bash

# Download files
download_files() {
    local DIR="$1"
    local urls=(
        "https://raw.githubusercontent.com/MechatronicsWhiz/SparkyBot/main/SparkyBotMini/helper.py"
        "https://raw.githubusercontent.com/MechatronicsWhiz/SparkyBot/main/SparkyBotMini/main.py"
        "https://raw.githubusercontent.com/MechatronicsWhiz/SparkyBot/main/SparkyBotMini/styles.py"
        "https://raw.githubusercontent.com/MechatronicsWhiz/SparkyBot/main/SparkyBotMini/sparky_icon.png"
        "https://raw.githubusercontent.com/MechatronicsWhiz/SparkyBot/main/SparkyBotMini/SparkyBotMini.desktop"
    )

    # Create the directory if it doesn't exist
    mkdir -p "$DIR"

    # Download files and adjust permissions
    for url in "${urls[@]}"; do
        filename=$(basename "$url")
        sudo wget -O "$DIR/$filename" "$url"
        sudo chmod a+rw "$DIR/$filename"  # Set read and write permissions for all
    done
}

# Add APP to panel
add_app_to_panel() {
    local app_path="$1"

    # Define the path to panel.conf
    local panel_conf="$HOME/.config/lxqt/panel.conf"

    # Check if panel.conf exists
    if [ ! -f "$panel_conf" ]; then
        echo "Error: panel.conf not found at $panel_conf"
        return 1
    fi

    # Find the current apps size
    local current_size
    current_size=$(grep -oP 'apps\\size=\K[0-9]+' "$panel_conf")

    # Check if the size was found
    if [ -z "$current_size" ]; then
        echo "Error: apps size not found in $panel_conf"
        return 1
    fi

    # Calculate the next index and new size
    local new_size=$((current_size + 1))

    # Define the new entry
    local new_entry="apps\\\\$new_size\\\\desktop=$app_path"

    # Use sed to insert the new entry before the pattern and update the size
    sed -i "/apps\\\\size=$current_size/i $new_entry" "$panel_conf"
    sed -i "s/apps\\\\size=$current_size/apps\\\\size=$new_size/" "$panel_conf"
    
    # Restart the LXQt panel to apply changes
    lxqt-panel --exit
    lxqt-panel & 

    echo "App $new_entry installed"
}

# Main program to download and install apps
download_files "$HOME/SparkyBotMini"
add_app_to_panel "$HOME/SparkyBotMini/SparkyBotMini.desktop"

