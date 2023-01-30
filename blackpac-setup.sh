#!/bin/bash

# Download script.
cd
wget http://downloads.sourceforge.net/project/ig-scripts/blackpac-1.0.1.sh

# Make script executable.
chmod +x blackpac-1.0.1.sh

# Install script.
install blackpac-1.0.1.sh /usr/local/bin/
mv /usr/local/bin/blackpac-1.0.1.sh /usr/local/bin/blackpac

# Blacklist packages.
blackpac --blacklist qt5-tools v4l-utils
