#!/bin/bash
set -euo pipefail

# =====================
# CONFIG
# =====================

DOWNLOAD_PATH="downloads.d"

CHROME_DEB="$DOWNLOAD_PATH/chrome.deb"
VSCODE_DEB="$DOWNLOAD_PATH/vscode.deb"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
USER_BIN_PATH="$TARGET_HOME/.local/bin"

# =====================
# GUARDS
# =====================

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Run this script as root"
        exit 1
    fi
}

# =====================
# CLEANUP
# =====================

cleanup() {
    rm -rf "$DOWNLOAD_PATH"
}

trap cleanup EXIT

# =====================
# ENV
# =====================

print_env() {
    echo "=== Environment ==="
    echo "Invoking user     : $TARGET_USER"
    echo "User home         : $TARGET_HOME"
    echo "User bin path     : $USER_BIN_PATH"
    echo "Download path     : $DOWNLOAD_PATH"
    echo "DEBIAN_FRONTEND   : $DEBIAN_FRONTEND"
    echo "==================="
}

add_USER_BIN_PATH_to_bashrc() {
    local bashrc="$TARGET_HOME/.bashrc"

    if ! grep -q "$USER_BIN_PATH" "$bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# User local binaries"
            echo "export PATH=\"\$PATH:$USER_BIN_PATH\""
        } >> "$bashrc"
    fi
}

# =====================
# LAZYGIT
# =====================

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

# =====================
# CHROME
# =====================

download_chrome() {
    curl -L \
        'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' \
        -o "$CHROME_DEB"
}

install_chrome() {
    apt install -y "./$CHROME_DEB"
}

# =====================
# VSCODE
# =====================

download_vscode() {
    curl -L \
        'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
        -o "$VSCODE_DEB"
}

install_vscode() {
    apt install -y "./$VSCODE_DEB"
}

# =====================
# VIRTUALIZATION
# =====================

install_virtualization() {
    apt install -y \
        qemu-system \
        libvirt-daemon-system \
        virt-manager
}

add_user_to_libvirt_group() {
    usermod -aG libvirt "$TARGET_USER"
}

setEnvs(){
    export DEBIAN_FRONTEND=noninteractive
}

# =====================
# MAIN
# =====================

main() {
    require_root
    setEnvs
    print_env

    mkdir -p "$DOWNLOAD_PATH"

    apt update
    apt install -y curl

    download_lazygit
    extract_lazygit
    add_USER_BIN_PATH_to_bashrc

    download_chrome
    install_chrome

    download_vscode
    install_vscode

    # virtualization
    install_virtualization
    add_user_to_libvirt_group

    echo "Done."
    echo "NOTE: Re-login required for libvirt group to take effect."
}

main "$@"