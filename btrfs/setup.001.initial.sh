#!/bin/bash
set -e

USERNAME="$1"

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

if ! id "$USERNAME" &>/dev/null; then
  echo "User '$USERNAME' does not exist"
  exit 1
fi

# 1. Add /usr/sbin to PATH
if ! grep -q "/usr/sbin" ~/.bashrc; then
  echo 'export PATH="$PATH:/usr/sbin"' >> ~/.bashrc
fi

# 2. Install sudo
apt update
apt install -y sudo htop lm-sensors stress-ng

# 3. Add user to sudo group
/usr/sbin/usermod -aG sudo "$USERNAME"

echo "OK:"
echo "- /usr/sbin added to PATH"
echo "- sudo installed"
echo "- user '$USERNAME' added to sudo group"
echo "Please reboot..."
