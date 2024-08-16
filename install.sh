#!/bin/zsh

# Update Homebrew and install Python3 if it's not already installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to the .zprofile file
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$USER/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check if brew	is up to date
if brew outdated; then
  echo "Homebrew is outdated. Updating Homebrew..."
  brew update
fi

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

# Ensure ansible-playbook is available
if ! command -v $(python3 -m site --user-base)/bin/ansible-playbook &> /dev/null; then
    # Install Ansible using pip3
    echo "Installing Ansible..."
    pip3 install ansible

    if ! command -v $(python3 -m site --user-base)/bin/ansible-playbook &> /dev/null; then
	echo "$(python3 -m site --user-base)/bin/ansible-playbook command not found. There was an issue with the Ansible installation."
    exit 1
    fi
fi

# Playbook file
PLAYBOOK_PATH="./playbooks/main.yml"

# Ensure the playbook exist
if [ ! -f $PLAYBOOK_PATH ]; then
  echo "Failed to download the Ansible playbook."
  exit 1
fi

# Run the Ansible playbook
echo "Running Ansible playbook..."
$(python3 -m site --user-base)/bin/ansible-playbook -vvv $PLAYBOOK_PATH --ask-become-pass
