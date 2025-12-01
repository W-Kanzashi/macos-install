#!/bin/zsh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "  macOS 26 Installation Script Tester"
echo "=========================================="
echo ""

# Test 1: Check macOS version
print_status "Checking macOS version..."
MACOS_VERSION=$(sw_vers -productVersion)
echo "  macOS Version: $MACOS_VERSION"

# Test 2: Check if System Settings app exists
print_status "Testing System Settings application..."
if osascript -e 'tell application "System Settings" to quit' 2>/dev/null; then
    print_success "System Settings command works correctly"
else
    print_error "System Settings command failed"
    print_warning "This might be expected if macOS version is older than 13.0"
fi

# Test 3: Check if Homebrew is installed
print_status "Checking Homebrew installation..."
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -n 1)
    print_success "Homebrew is installed: $BREW_VERSION"
else
    print_warning "Homebrew is not installed (will be installed by script)"
fi

# Test 4: Check if Python3 is installed
print_status "Checking Python3 installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_success "$PYTHON_VERSION is installed"
else
    print_warning "Python3 is not installed (will be installed by script)"
fi

# Test 5: Check if Ansible is installed
print_status "Checking Ansible installation..."
# Check if ansible-playbook is in PATH (e.g., Homebrew install)
if command -v ansible-playbook &> /dev/null; then
    ANSIBLE_PATH="ansible-playbook"
    ANSIBLE_VERSION=$(ansible-playbook --version | head -n 1)
    print_success "$ANSIBLE_VERSION is installed"
else
    # Fall back to checking user-site path (pip --user install)
    ANSIBLE_PATH="$(python3 -m site --user-base)/bin/ansible-playbook"
    if [ -x "$ANSIBLE_PATH" ]; then
        ANSIBLE_VERSION=$($ANSIBLE_PATH --version | head -n 1)
        print_success "$ANSIBLE_VERSION is installed"
    else
        ANSIBLE_PATH=""
        print_warning "Ansible is not installed (will be installed by script)"
    fi
fi

# Test 6: Verify playbook files exist
print_status "Checking playbook files..."
if [ -f "./playbooks/main.yml" ]; then
    print_success "main.yml exists"
else
    print_error "main.yml not found"
    exit 1
fi

if [ -f "./playbooks/macos.yml" ]; then
    print_success "macos.yml exists"
else
    print_error "macos.yml not found"
    exit 1
fi

if [ -f "./playbooks/packages.txt" ]; then
    print_success "packages.txt exists"
else
    print_error "packages.txt not found"
    exit 1
fi

# Test 7: Validate YAML syntax
print_status "Validating YAML syntax..."
if [ -n "$ANSIBLE_PATH" ]; then
    if $ANSIBLE_PATH --syntax-check ./playbooks/main.yml &> /dev/null; then
        print_success "YAML syntax is valid"
    else
        print_error "YAML syntax check failed"
        $ANSIBLE_PATH --syntax-check ./playbooks/main.yml
        exit 1
    fi
else
    print_warning "Skipping YAML validation (Ansible not installed)"
fi

echo ""
echo "=========================================="
echo "  Test Options"
echo "=========================================="
echo ""
echo "What would you like to do?"
echo ""
echo "  1) Run Ansible in CHECK mode (dry run - no changes)"
echo "  2) Run FULL installation script"
echo "  3) Validate settings after installation"
echo "  4) Exit"
echo ""
read -r "choice?Enter your choice (1-4): "

case $choice in
    1)
        print_status "Running Ansible in CHECK mode..."
        echo ""
        if [ -n "$ANSIBLE_PATH" ]; then
            $ANSIBLE_PATH -vvv ./playbooks/main.yml --ask-become-pass --check
        else
            print_error "Ansible is not installed. Please run the installation script first."
            exit 1
        fi
        ;;
    2)
        print_warning "This will make ACTUAL changes to your system!"
        read -r "confirm?Are you sure you want to proceed? (yes/no): "
        if [ "$confirm" = "yes" ]; then
            print_status "Running full installation script..."
            echo ""
            ./install.sh
        else
            print_status "Installation cancelled"
        fi
        ;;
    3)
        print_status "Validating macOS settings..."
        echo ""
        
        # Check Dock settings
        echo "Dock Settings:"
        echo "  Autohide: $(defaults read com.apple.dock autohide 2>/dev/null || echo 'Not set')"
        echo "  Tile size: $(defaults read com.apple.dock tilesize 2>/dev/null || echo 'Not set')"
        echo ""
        
        # Check Finder settings
        echo "Finder Settings:"
        echo "  Show all files: $(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || echo 'Not set')"
        echo "  Show extensions: $(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || echo 'Not set')"
        echo "  Show status bar: $(defaults read com.apple.finder ShowStatusBar 2>/dev/null || echo 'Not set')"
        echo "  Show path bar: $(defaults read com.apple.finder ShowPathbar 2>/dev/null || echo 'Not set')"
        echo ""
        
        # Check Trackpad settings
        echo "Trackpad Settings:"
        echo "  Tap to click: $(defaults read com.apple.AppleMultitouchTrackpad Clicking 2>/dev/null || echo 'Not set')"
        echo ""
        
        # Check Screen saver settings
        echo "Screen Saver Settings:"
        echo "  Idle time: $(defaults -currentHost read com.apple.screensaver idleTime 2>/dev/null || echo 'Not set')"
        echo "  Ask for password: $(defaults read com.apple.screensaver askForPassword 2>/dev/null || echo 'Not set')"
        echo ""
        
        # Check Display settings
        echo "Display Settings:"
        echo "  Reduce motion: $(defaults read com.apple.universalaccess reduceMotion 2>/dev/null || echo 'Not set')"
        echo ""
        
        # Check installed applications
        echo "Installed Applications:"
        [ -d "/Applications/Arc.app" ] && echo "  ✓ Arc" || echo "  ✗ Arc"
        [ -d "/Applications/Warp.app" ] && echo "  ✓ Warp" || echo "  ✗ Warp"
        [ -d "/Applications/Raycast.app" ] && echo "  ✓ Raycast" || echo "  ✗ Raycast"
        echo ""
        
        print_success "Validation complete"
        ;;
    4)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Test script completed successfully!"
