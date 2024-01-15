#!/bin/bash

# Correct xreader.desktop
XREADER_DESKTOP_PATH="/usr/share/applications/xreader.desktop"
CORRECTED_XREADER_CONTENT="[Desktop Entry]\nName=Document Viewer\nComment=View multi-page documents\nTryExec=xreader\nExec=xreader %U\nStartupNotify=true\nTerminal=false\nType=Application\nIcon=xreader\nCategories=GTK;Utility;Viewer;\nKeywords=document;viewer;pdf;dvi;ps;xps;tiff;djvu;comics;\nMimeType=application/pdf;application/x-bzpdf;application/x-gzpdf;application/x-xzpdf;application/postscript;application/x-bzpostscript;application/x-gzpostscript;image/x-eps;image/x-bzeps;image/x-gzeps;application/illustrator;application/x-dvi;application/x-bzdvi;application/x-gzdvi;image/vnd.djvu;image/vnd.djvu+multipage;image/tiff;application/vnd.comicbook-rar;application/vnd.comicbook+zip;application/x-cb7;application/x-cbr;application/x-cbt;application/x-cbz;application/x-ext-cb7;application/x-ext-cbr;application/x-ext-cbt;application/x-ext-cbz;application/oxps;application/vnd.ms-xpsdocument;application/epub+zip;"

# Replace xreader.desktop with corrected content
echo -e "$CORRECTED_XREADER_CONTENT" | sudo tee "$XREADER_DESKTOP_PATH" >/dev/null

# Add flathub remote if not exists
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Define flatpak applications
flatpaks=(
    "net.nokyan.Resources"
    "com.bitwarden.desktop"
    "com.authy.Authy"
    "org.cryptomator.Cryptomator"
    "io.github.shiftey.Desktop"
    "net.cozic.joplin_desktop"
    "com.google.Chrome"
)

# Install or check and echo
for app in "${flatpaks[@]}"; do
    if flatpak list | grep -q "$app"; then
        echo "$app is already installed."
    else
        flatpak install --noninteractive --assumeyes flathub "$app" >/dev/null 2>&1
    fi
done

echo "Flatpak installation and xreader.desktop correction completed."
