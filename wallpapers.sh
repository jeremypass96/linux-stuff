#!/bin/bash

# Checking if the script is running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this setup script as root via 'sudo' or 'su'. Thanks."
    exit 1
fi

# Define an array of wallpaper URLs.
wallpaper_urls=(
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0004.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0011.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0023.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0036.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0037.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0042.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0057.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0058.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0065.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0076.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0188.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0230.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0252.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0256.jpg"
    "https://gitlab.com/dwt1/wallpapers/-/raw/master/0257.jpg"
    "https://raw.githubusercontent.com/ghostbsd/ghostbsd-wallpapers/master/Field_Of_Lightning.jpg"
    "https://raw.githubusercontent.com/ghostbsd/ghostbsd-wallpapers/master/Lake_View.jpg"
    "https://raw.githubusercontent.com/ghostbsd/ghostbsd-wallpapers/master/Mountain_View.jpg"
)

# Destination directory for wallpapers.
wallpaper_dir="/usr/share/wallpapers"

# Download wallpapers using the defined URLs.
for url in "${wallpaper_urls[@]}"; do
    curl -L "$url" -o "$wallpaper_dir/$(basename $url)"
done

echo "Wallpapers downloaded and saved to $wallpaper_dir."