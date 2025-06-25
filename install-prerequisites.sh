#!/bin/bash

# Cross-Platform Ansible & Git Installation Script
# Automatically detects Linux or macOS and installs Ansible and Git
# Checks if packages are already installed before proceeding

set -e  # Exit on any error

echo "=== Cross-Platform Ansible & Git Installation Script ==="
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif type lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get version of installed package
get_version() {
    local cmd="$1"
    case $cmd in
        "git")
            git --version 2>/dev/null | head -n1
            ;;
        "ansible")
            ansible --version 2>/dev/null | head -n1
            ;;
        *)
            echo "Unknown command: $cmd"
            ;;
    esac
}

# Function to check installation status
check_installation_status() {
    echo "Checking current installation status..."
    echo
    
    # Check Git
    if command_exists git; then
        GIT_INSTALLED=true
        GIT_VERSION=$(get_version git)
        print_status "Git is already installed: $GIT_VERSION"
    else
        GIT_INSTALLED=false
        print_warning "Git is not installed"
    fi
    
    # Check Ansible
    if command_exists ansible; then
        ANSIBLE_INSTALLED=true
        ANSIBLE_VERSION=$(get_version ansible)
        print_status "Ansible is already installed: $ANSIBLE_VERSION"
    else
        ANSIBLE_INSTALLED=false
        print_warning "Ansible is not installed"
    fi
    
    echo
}

# Function to install Git on Ubuntu/Debian
install_git_ubuntu_debian() {
    print_info "Installing Git on Ubuntu/Debian..."
    sudo apt update
    sudo apt install -y git curl wget
    print_status "Git installed successfully"
}

# Function to install Git on Red Hat-based systems
install_git_redhat() {
    print_info "Installing Git on Red Hat-based system..."
    
    if command_exists dnf; then
        sudo dnf install -y git curl wget
    elif command_exists yum; then
        sudo yum install -y git curl wget
    else
        print_error "No suitable package manager found (dnf/yum)"
        exit 1
    fi
    print_status "Git installed successfully"
}

# Function to install Git on Arch Linux
install_git_arch() {
    print_info "Installing Git on Arch Linux..."
    sudo pacman -Sy --noconfirm git curl wget
    print_status "Git installed successfully"
}

# Function to install Git on macOS
install_git_macos() {
    print_info "Installing Git on macOS..."
    
    if command_exists brew; then
        brew install git
    else
        print_info "Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        brew install git
    fi
    print_status "Git installed successfully"
}

# Function to install Ansible on Ubuntu/Debian
install_ansible_ubuntu_debian() {
    print_info "Installing Ansible on Ubuntu/Debian..."
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
    print_status "Ansible installed successfully"
}

# Function to install Ansible on Red Hat-based systems
install_ansible_redhat() {
    print_info "Installing Ansible on Red Hat-based system..."
    
    if command_exists dnf; then
        sudo dnf install -y epel-release
        sudo dnf install -y ansible
    elif command_exists yum; then
        sudo yum install -y epel-release
        sudo yum install -y ansible
    else
        print_error "No suitable package manager found (dnf/yum)"
        exit 1
    fi
    print_status "Ansible installed successfully"
}

# Function to install Ansible on Arch Linux
install_ansible_arch() {
    print_info "Installing Ansible on Arch Linux..."
    sudo pacman -S --noconfirm ansible
    print_status "Ansible installed successfully"
}

# Function to install Ansible on macOS
install_ansible_macos() {
    print_info "Installing Ansible on macOS..."
    
    if command_exists brew; then
        brew install ansible
    else
        print_info "Using pip3 to install Ansible..."
        if ! command_exists python3; then
            print_error "Python3 not found. Please install Python3 first."
            exit 1
        fi
        
        if ! command_exists pip3; then
            python3 -m ensurepip --upgrade
        fi
        
        pip3 install --user ansible
        
        # Add pip user bin to PATH
        USER_BIN_PATH="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin"
        if [[ ":$PATH:" != *":$USER_BIN_PATH:"* ]]; then
            echo "export PATH=\"$USER_BIN_PATH:\$PATH\"" >> ~/.zshrc
            export PATH="$USER_BIN_PATH:$PATH"
        fi
    fi
    print_status "Ansible installed successfully"
}

# Function to setup Ansible configuration
setup_ansible_config() {
    print_info "Setting up Ansible configuration..."
    
    mkdir -p ~/.ansible
    
    if [ ! -f ~/.ansible/ansible.cfg ]; then
        cat > ~/.ansible/ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = ~/.ansible/hosts
remote_user = ansible
private_key_file = ~/.ssh/id_rsa
interpreter_python = auto_silent

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml
EOF
        print_status "Created ansible.cfg in ~/.ansible/"
    fi
    
    if [ ! -f ~/.ansible/hosts ]; then
        cat > ~/.ansible/hosts << 'EOF'
# Ansible inventory file
[local]
localhost ansible_connection=local

[webservers]
# web1.example.com
# web2.example.com

[databases]
# db1.example.com
EOF
        print_status "Created sample inventory file in ~/.ansible/hosts"
    fi
}

# Function to configure Git
configure_git() {
    echo
    print_info "Git Configuration"
    
    # Check if Git is already configured
    if git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1; then
        local current_name=$(git config --global user.name)
        local current_email=$(git config --global user.email)
        print_status "Git is already configured:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        
        read -p "Would you like to reconfigure Git? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    read -p "Enter your full name: " git_name
    read -p "Enter your email address: " git_email
    
    if [[ -n "$git_name" && -n "$git_email" ]]; then
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        git config --global core.autocrlf input
        
        print_status "Git configured successfully!"
        echo "  Name: $git_name"
        echo "  Email: $git_email"
    else
        print_warning "Invalid input. Skipping Git configuration."
    fi
}

# Function to install packages based on OS and distribution
install_packages() {
    local os="$1"
    local distro="$2"
    
    case $os in
        "linux")
            case $distro in
                "ubuntu"|"debian"|"pop"|"mint")
                    [ "$GIT_INSTALLED" = false ] && install_git_ubuntu_debian
                    [ "$ANSIBLE_INSTALLED" = false ] && install_ansible_ubuntu_debian
                    ;;
                "fedora"|"rhel"|"centos"|"rocky"|"almalinux")
                    [ "$GIT_INSTALLED" = false ] && install_git_redhat
                    [ "$ANSIBLE_INSTALLED" = false ] && install_ansible_redhat
                    ;;
                "arch"|"manjaro"|"endeavouros")
                    [ "$GIT_INSTALLED" = false ] && install_git_arch
                    [ "$ANSIBLE_INSTALLED" = false ] && install_ansible_arch
                    ;;
                *)
                    print_error "Unsupported Linux distribution: $distro"
                    exit 1
                    ;;
            esac
            ;;
        "macos")
            [ "$GIT_INSTALLED" = false ] && install_git_macos
            [ "$ANSIBLE_INSTALLED" = false ] && install_ansible_macos
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
}

# Function to verify installations
verify_installations() {
    echo
    print_info "Verifying installations..."
    
    # Verify Git
    if command_exists git; then
        local git_version=$(get_version git)
        print_status "Git: $git_version"
    else
        print_error "Git installation failed"
        exit 1
    fi
    
    # Verify Ansible
    if command_exists ansible; then
        local ansible_version=$(get_version ansible)
        print_status "Ansible: $ansible_version"
    else
        print_error "Ansible installation failed"
        exit 1
    fi
}

# Function to show next steps
show_next_steps() {
    echo
    echo "=== Installation Complete! ==="
    echo
    print_status "Both Git and Ansible have been successfully installed."
    echo
    echo "Next steps:"
    echo
    echo "Git:"
    echo "  1. Test: git --version"
    echo "  2. Create repository: git init"
    echo "  3. Check config: git config --list"
    echo
    echo "Ansible:"
    echo "  1. Test: ansible localhost -m ping"
    echo "  2. Check modules: ansible-doc -l"
    echo "  3. Edit inventory: nano ~/.ansible/hosts"
    echo "  4. Run playbook: ansible-playbook playbook.yml"
    echo
    echo "Configuration files:"
    echo "  - ~/.ansible/ansible.cfg"
    echo "  - ~/.ansible/hosts"
    echo
}

# Main function
main() {
    # Check if running as root
    if [[ $EUID -eq 0 && "$OSTYPE" != "darwin"* ]]; then
        print_warning "Running as root. This script should typically be run as a regular user with sudo privileges."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Detect OS and distribution
    OS=$(detect_os)
    print_info "Detected operating system: $OS"
    
    if [ "$OS" = "linux" ]; then
        DISTRO=$(detect_linux_distro)
        print_info "Detected Linux distribution: $DISTRO"
    fi
    
    echo
    
    # Check current installation status
    check_installation_status
    
    # Ask user what to install if both are already installed
    if [ "$GIT_INSTALLED" = true ] && [ "$ANSIBLE_INSTALLED" = true ]; then
        print_status "Both Git and Ansible are already installed!"
        read -p "Would you like to reconfigure them? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            configure_git
            exit 0
        fi
    fi
    
    # Install packages if needed
    if [ "$GIT_INSTALLED" = false ] || [ "$ANSIBLE_INSTALLED" = false ]; then
        echo "Installing missing packages..."
        install_packages "$OS" "$DISTRO"
    fi
    
    # Setup Ansible configuration
    setup_ansible_config
    
    # Verify installations
    verify_installations
    
    # Configure Git
    configure_git
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
