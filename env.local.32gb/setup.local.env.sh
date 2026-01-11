#!/bin/bash
set -euo pipefail

DOWNLOAD_PATH="downloads.d"

CHROME_DEB="$DOWNLOAD_PATH/chrome.deb"
VSCODE_DEB="$DOWNLOAD_PATH/vscode.deb"

# Target user (works with and without sudo)
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
USER_BIN_PATH="$TARGET_HOME/.local/bin"

add_USER_BIN_PATH_to_bashrc() {
    local bashrc="$TARGET_HOME/.bashrc"

    if ! grep -q "$USER_BIN_PATH" "$bashrc" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$USER_BIN_PATH\"" >> "$bashrc"
    fi
}

download_lazygit() {
    local version

    version=$(curl -Ls -o /dev/null -w '%{url_effective}' \
        https://github.com/jesseduffield/lazygit/releases/latest |
        sed -E 's#.*/tag/v##')

    curl -L \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_linux_x86_64.tar.gz" \
        -o "$DOWNLOAD_PATH/lazygit.tar.gz"
}

extract_lazygit() {
    mkdir -p "$USER_BIN_PATH"

    tar -xzf "$DOWNLOAD_PATH/lazygit.tar.gz" \
        -C "$USER_BIN_PATH" \
        lazygit

    chmod +x "$USER_BIN_PATH/lazygit"
    chown "$TARGET_USER:$TARGET_USER" "$USER_BIN_PATH/lazygit"
}

install_debs() {
    sudo apt install -y \
        "./$CHROME_DEB" \
        "./$VSCODE_DEB"
}

cleanup() {
    rm -rf "$DOWNLOAD_PATH"
}

main() {
    echo "=== Environment ==="
    echo "Invoking user : $TARGET_USER"
    echo "User home     : $TARGET_HOME"
    echo "User bin path : $USER_BIN_PATH"
    echo "Download path : $DOWNLOAD_PATH"
    echo "==================="

    mkdir -p "$DOWNLOAD_PATH"

    sudo apt update
    sudo apt install -y curl

    download_lazygit
    extract_lazygit
    add_USER_BIN_PATH_to_bashrc

    curl -L \
        'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' \
        -o "$CHROME_DEB"

    curl -L \
        'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
        -o "$VSCODE_DEB"

    install_debs
    cleanup
}

main "$@"
