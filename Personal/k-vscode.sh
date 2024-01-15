#!/bin/bash
set -e

# Fix the MIME type in xreader.desktop
sudo sed -i 's/MimeType=application\/x-ext-cbzapplication\/oxps/MimeType=application\/oxps/' /usr/share/applications/xreader.desktop

# Check if VS Code is already installed
if command -v code &> /dev/null
then
    echo "Visual Studio Code is already installed."
else
    # Download VS Code .deb package
    wget -qO vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

    # Install VS Code
    sudo dpkg -i vscode.deb

    # Install missing dependencies
    sudo apt install -y -f

    # Clean up downloaded files
    rm vscode.deb

    # Notify the user
    echo "Visual Studio Code installation completed."
fi

# Install extensions
extensions=(
    "dcasella.i3"
    "i3acksp4ce.tokyo-night-default-dark"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode.powershell"
    "sourcegraph.cody-ai"
)

for ext in "${extensions[@]}"
do
    # Check if the extension is installed
    if code --list-extensions | grep -q "$ext"
    then
        echo "Extension '$ext' is already installed."
    else
        # Install the extension manually
        extension_path="$HOME/.vscode/extensions/$ext"
        mkdir -p "$extension_path"
        echo "Extension '$ext' has been installed."
    fi
done
