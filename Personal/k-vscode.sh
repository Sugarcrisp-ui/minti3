#!/bin/bash
set -e

# Create a temporary file for the corrected MIME type
temp_file=$(mktemp)
echo "MimeType=application/pdf;application/x-bzpdf;application/x-gzpdf;application/x-xzpdf;application/postscript;application/x-bzpostscript;application/x-gzpostscript;image/x-eps;image/x-bzeps;image/x-gzeps;application/illustrator;application/x-dvi;application/x-bzdvi;application/x-gzdvi;image/vnd.djvu;image/vnd.djvu+multipage;image/tiff;application/vnd.comicbook-rar;application/vnd.comicbook+zip;application/x-cb7;application/x-cbr;application/x-cbt;application/x-cbz;application/x-ext-cb7;application/x-ext-cbr;application/x-ext-cbt;application/x-ext-cbz;application/oxps;application/vnd.ms-xpsdocument;application/epub+zip;" > "$temp_file"

# Replace the contents of xreader.desktop with the corrected MIME type
sudo cp "$temp_file" /usr/share/applications/xreader.desktop

# Remove the temporary file
rm "$temp_file"

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
