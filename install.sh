#!/bin/zsh

# Update Homebrew and install Python3 if it's not already installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

if ! command -v python3 &> /dev/null; then
  echo "Python3 not found. Installing Python3..."
  brew install python
fi

# Install pip3 if it's not already installed
if ! command -v pip3 &> /dev/null; then
  echo "pip3 not found. Installing pip3..."
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  rm get-pip.py
fi

# Install Ansible using pip3
echo "Installing Ansible..."
pip3 install ansible

# Ensure ansible-playbook is available
if ! command -v $(python3 -m site --user-base)/bin/ansible-playbook &> /dev/null; then
    echo "$(python3 -m site --user-base)/bin/ansible-playbook command not found. There was an issue with the Ansible installation."
    exit 1
fi

# URL of the remote Ansible playbook
PLAYBOOK_URL="https://gist.githubusercontent.com/W-Kanzashi/b63114d17bad66f6c795b2d1fef6380f/raw/aae1932e0a5170c0f5416940dccd2e2cd0220069/macos-ansible.yml"

# Temporary file to store the downloaded playbook
PLAYBOOK_PATH="/tmp/install_packages.yml"

# Download the playbook from the remote URL
echo "Downloading Ansible playbook from GitHub Gist..."
curl -fsSL $PLAYBOOK_URL -o $PLAYBOOK_PATH

# Ensure the playbook was downloaded successfully
if [ ! -f $PLAYBOOK_PATH ]; then
  echo "Failed to download the Ansible playbook."
  exit 1
fi

# Run the Ansible playbook
echo "Running Ansible playbook..."
$(python3 -m site --user-base)/bin/ansible-playbook -vvv $PLAYBOOK_PATH --ask-become-pass

# Clean files
rm $PLAYBOOK_PATH
