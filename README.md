# macOS Installation Automation

Automated macOS setup and configuration using Ansible and shell scripts. This repository provides a complete, reproducible macOS environment setup with dotfiles, applications, system preferences, and development tools.

## Features

### 🔒 Secure Configuration Management

- **Ansible Vault integration** for encrypted credentials and sensitive configuration files
- Automatic decryption during installation with password prompt
- Secure file permissions (e.g., `0600` for private keys)

### 📦 Package Management

- **Homebrew** formula and cask installation from a curated package list
- Smart update behavior: skips `brew update` if local modifications detected
- Incremental installation (only installs missing packages)

### ⚙️ Configuration Deployment

- **Dotfiles** deployment from `vault/config/` to `~/`
- **Application configs** deployment from `vault/apps/` to `~/.config/`
- Automatic parent directory creation for nested paths
- Preserves file permissions and directory structure

### 🛠️ Development Environment

- **NVM** (Node Version Manager) v0.39.7
- **Node.js** v24.10 (set as default)
- **pnpm** latest version
- **Neovim** configuration from custom repository

### 🔄 File Synchronization

- **Syncthing** installation and configuration
- Automatic deployment of syncthing config files from vault

### 🖥️ System Preferences

- macOS Dock customization (autohide, icon size, specific apps)
- Finder settings (show hidden files, extensions, status bar)
- Trackpad configuration
- Display and screen saver settings
- Menu bar customization
- Login items configuration
- And much more...

## Repository Structure

```
.
├── install.sh              # Main installation script
├── test.sh                 # Testing and validation script
├── playbooks/
│   ├── main.yml           # Main Ansible playbook
│   ├── macos.yml          # macOS system preferences
│   └── packages.txt       # Homebrew packages list
└── vault/
    ├── config/            # Dotfiles (deployed to ~/)
    │   ├── .zshrc
    │   ├── .gitconfig
    │   └── .config/       # Nested configs
    ├── apps/              # Application configs (deployed to ~/.config/)
    │   └── ghostty/
    └── Library/
        └── Application Support/
            └── Syncthing/ # Syncthing configuration
```

## Prerequisites

- macOS (tested on macOS 13+)
- Internet connection
- Administrator access (for `sudo` commands)
- Vault password (if using encrypted files)

## Installation

### Quick Start

```bash
git clone <repository-url>
cd macos-install
./install.sh
```

The script will:

1. Install Homebrew (if not present)
2. Install Python3 and pip3 (if not present)
3. Install Ansible (if not present)
4. Prompt for vault password
5. Decrypt vault files
6. Install packages from `playbooks/packages.txt`
7. Deploy configuration files
8. Set up development environment (NVM, Node, pnpm)
9. Configure Syncthing
10. Apply macOS system preferences

### Testing (Dry Run)

Test the installation without making changes:

```bash
./test.sh
# Select option 1: Run Ansible in CHECK mode
```

## Customization

### Adding Packages

Edit `playbooks/packages.txt`:

```txt
# Homebrew formulas (no prefix)
neovim
ripgrep
fd

# Homebrew casks (prefix with 'cask-')
cask-arc
cask-visual-studio-code
```

### Adding Dotfiles

1. Place files in `vault/config/` with the same structure as your home directory:

   - `vault/config/.zshrc` → `~/.zshrc`
   - `vault/config/.config/git/config` → `~/.config/git/config`

2. (Optional) Encrypt with Ansible Vault:
   ```bash
   ansible-vault encrypt vault/config/.secret-file
   ```

### Adding Application Configs

Place application configs in `vault/apps/`:

- `vault/apps/ghostty/config` → `~/.config/ghostty/config`

### Modifying macOS Settings

Edit `playbooks/macos.yml` to add or modify macOS system preferences.

## Security Features

### Homebrew Local Modifications Protection

The script checks for local modifications in Homebrew's git repository before updating:

- If modifications are detected, `brew update` is skipped
- Warning message displayed with repository location
- Prevents accidental overwriting of custom changes

### Vault File Encryption

Sensitive files can be encrypted using Ansible Vault:

```bash
# Encrypt a file
ansible-vault encrypt vault/config/.gitconfig

# Decrypt a file (for manual editing)
ansible-vault decrypt vault/config/.gitconfig

# Edit encrypted file
ansible-vault edit vault/config/.gitconfig
```

During installation, the script automatically:

- Prompts for vault password (hidden input)
- Detects encrypted files
- Decrypts only encrypted files
- Handles already-decrypted files gracefully

## Post-Installation

### Verify Installation

```bash
# Check development tools
source ~/.zshrc
nvm --version
node --version  # Should show v24.10.x
pnpm --version

# Check deployed configs
ls -la ~/.zshrc ~/.gitconfig
ls -la ~/.config/

# Check Syncthing
ls -la ~/Library/Application\ Support/Syncthing/

# Validate macOS settings
./test.sh
# Select option 3: Validate settings after installation
```

### Manual Steps

Some configurations may require manual steps:

- Launch Raycast and set up preferences
- Configure Arc browser sync
- Set up Bitwarden
- Configure application-specific settings

## Troubleshooting

### Ansible Not Found

If Ansible is installed via pip but not in PATH:

```bash
export PATH="$(python3 -m site --user-base)/bin:$PATH"
```

### Vault Decryption Failed

- Ensure you have the correct vault password
- Check if files are actually encrypted: `head -n1 vault/config/.gitconfig`
- Should start with `$ANSIBLE_VAULT;1.1;AES256`

### Directory Creation Issues

The script now automatically creates all parent directories. If issues persist:

```bash
# Manually create a directory
mkdir -p ~/.config/some/nested/path
```

### Homebrew Update Skipped

If you see warnings about local modifications:

```bash
# Check modifications
git -C $(brew --repository) status

# Discard modifications (if safe)
git -C $(brew --repository) reset --hard
```

## Installed Applications

See `playbooks/packages.txt` for the full list. Notable applications include:

- **Browsers**: Arc
- **Terminals**: Ghostty
- **Development**: Visual Studio Code, Docker Desktop, TablePlus
- **Productivity**: Raycast, Obsidian, CleanShot
- **Utilities**: Bitwarden, Stats, AltTab, AlDente
- **CLI Tools**: neovim, lazygit, ripgrep, fd, gh, git-delta

## License

This is a personal configuration repository. Feel free to fork and adapt for your own use.

## Contributing

This is a personal setup repository, but feel free to:

- Report issues
- Suggest improvements
- Use as inspiration for your own setup

## Acknowledgments

- [Homebrew](https://brew.sh/) - Package manager for macOS
- [Ansible](https://www.ansible.com/) - Automation tool
- [NVM](https://github.com/nvm-sh/nvm) - Node version manager
- [Syncthing](https://syncthing.net/) - File synchronization
