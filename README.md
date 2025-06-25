# Development Environment Setup with Ansible

This Ansible playbook automatically sets up a complete development environment on Linux or macOS.

## What Gets Installed

- **Docker**: Container platform with Docker Compose
- **VS Code**: Visual Studio Code editor
- **Oh My Zsh**: Enhanced shell with plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- **Neovim**: Modern Vim-based editor with basic configuration
- **Python Virtual Environment**: Python3, pip, virtualenv, and virtualenvwrapper
- **Obsidian**: Note-taking application
- **Pass**: Unix password manager with GPG support

## Requirements

- Ansible installed on your system
- sudo privileges
- Internet connection

## Usage

### Run the entire playbook
```bash
ansible-playbook development-environment-setup.yml -e "user_home='$HOME'"
```

### Run specific roles using tags
```bash
# Install only Docker and VS Code
ansible-playbook development-environment-setup.yml --tags docker,vscode -e "user_home='$HOME'"

# Install everything except Obsidian
ansible-playbook development-environment-setup.yml --skip-tags obsidian -e "user_home='$HOME'"
```

### Skip specific packages
```bash
# Skip Obsidian and Pass installation
ansible-playbook development-environment-setup.yml -e "install_obsidian=false install_pass=false user_home='$HOME'"
```

### Check what would be done (dry run)
```bash
ansible-playbook development-environment-setup.yml --check -e "user_home='$HOME'"
```

## Supported Operating Systems

- **Linux**: Ubuntu/Debian, CentOS/RHEL/Fedora, Arch Linux
- **macOS**: Uses Homebrew for package management

## Customization

### Variables
Edit the variables in `development-environment-setup.yml` to customize the installation:

```yaml
vars:
  install_docker: true
  install_vscode: true
  install_ohmyzsh: true
  install_neovim: true
  install_python_virtualenv: true
  install_obsidian: true
  install_pass: true
```

### Role-specific Configuration
Each role has its own variables file in `roles/<role>/vars/`:

- `roles/docker/vars/default.yml`
- `roles/obsidian/vars/default.yml`
- `roles/python_virtualenv/vars/Debian.yml` (OS-specific)

### Adding VS Code Extensions
Edit `roles/vscode/vars/default.yml` to add extensions:

```yaml
vscode_extensions:
  - ms-python.python
  - ms-vscode.vscode-typescript-next
```

## Post-Installation

### Git Configuration
Don't forget to configure Git:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Pass Setup
Initialize your password store:
```bash
gpg --generate-key
pass init <your-gpg-key-id>
```

### Python Virtual Environments
Create your first virtual environment:
```bash
python3 -m venv _env312
```

### Docker
Add yourself to the docker group (Linux):
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## Directory Structure

```
├── development-environment-setup.yml                    # Main playbook
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── hosts                   # Inventory file
└── roles/
    ├── docker/
    │   ├── tasks/
    │   │   ├── main.yml
    │   │   ├── linux.yml
    │   │   └── macos.yml
    │   └── vars/
    │       └── default.yml
    ├── vscode/
    ├── ohmyzsh/
    ├── neovim/
    ├── python_virtualenv/
    ├── obsidian/
    └── pass/
```

## Troubleshooting

### Permission Issues
If you encounter permission issues, make sure you're not running as root:
```bash
# Don't do this
sudo ansible-playbook development-environment-setup.yml

# Do this instead
ansible-playbook development-environment-setup.yml
```

### macOS Homebrew Issues
If Homebrew installation fails, install it manually first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### AUR Packages on Arch Linux
Some packages require an AUR helper. The playbook will install `yay` automatically.

## Contributing

Feel free to fork this repository and customize it for your needs. Pull requests are welcome!

## License

MIT License - feel free to use and modify as needed.
