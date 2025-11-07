#!/usr/bin/env bash

# NixOS Interactive Installation Script
# Based on modern NixOS configuration patterns

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi

    [[ "$response" =~ ^[Yy]$ ]]
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    local response

    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -p "$prompt: " response
        echo "$response"
    fi
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Main installation flow
print_header "NixOS Configuration Installer"

echo "This script will help you set up a NixOS configuration with:"
echo "  • Flakes support"
echo "  • Home Manager integration"
echo "  • Modular configuration structure"
echo "  • User-specific settings"
echo ""

if ! prompt_yes_no "Continue with installation?"; then
    print_info "Installation cancelled"
    exit 0
fi

# Gather user information
print_header "User Configuration"

USERNAME=$(prompt_input "Enter your username" "$USER")
HOSTNAME=$(prompt_input "Enter hostname for this machine" "$(hostname)")
TIMEZONE=$(prompt_input "Enter timezone" "America/New_York")
LOCALE=$(prompt_input "Enter locale" "en_US.UTF-8")

# Git configuration for flakes
print_header "Git Configuration"
if prompt_yes_no "Configure git for NixOS flakes?"; then
    GIT_NAME=$(prompt_input "Enter your git name" "$(git config --get user.name 2>/dev/null || echo '')")
    GIT_EMAIL=$(prompt_input "Enter your git email" "$(git config --get user.email 2>/dev/null || echo '')")
    USE_GIT=true
else
    USE_GIT=false
fi

# Desktop environment
print_header "Desktop Environment"
echo "Select desktop environment:"
echo "  1) GNOME"
echo "  2) KDE Plasma"
echo "  3) i3 (tiling)"
echo "  4) Hyprland (Wayland tiling)"
echo "  5) None (minimal/server)"

DE_CHOICE=$(prompt_input "Choose desktop environment [1-5]" "1")

case $DE_CHOICE in
    1) DESKTOP="gnome" ;;
    2) DESKTOP="kde" ;;
    3) DESKTOP="i3" ;;
    4) DESKTOP="hyprland" ;;
    5) DESKTOP="none" ;;
    *) DESKTOP="gnome" ;;
esac

# Package selection
print_header "Package Selection"
INSTALL_DEV_TOOLS=$(prompt_yes_no "Install development tools (git, vim, vscode, etc)?")
INSTALL_DOCKER=$(prompt_yes_no "Install Docker?")
INSTALL_VIRTUALIZATION=$(prompt_yes_no "Install virtualization (QEMU/KVM)?")

# Home Manager
print_header "Home Manager"
INSTALL_HOME_MANAGER=$(prompt_yes_no "Install and configure Home Manager?")

# Confirm configuration
print_header "Configuration Summary"
echo "Username:         $USERNAME"
echo "Hostname:         $HOSTNAME"
echo "Timezone:         $TIMEZONE"
echo "Locale:           $LOCALE"
echo "Desktop:          $DESKTOP"
echo "Dev Tools:        $([ "$INSTALL_DEV_TOOLS" = true ] && echo "Yes" || echo "No")"
echo "Docker:           $([ "$INSTALL_DOCKER" = true ] && echo "Yes" || echo "No")"
echo "Virtualization:   $([ "$INSTALL_VIRTUALIZATION" = true ] && echo "Yes" || echo "No")"
echo "Home Manager:     $([ "$INSTALL_HOME_MANAGER" = true ] && echo "Yes" || echo "No")"
echo ""

if ! prompt_yes_no "Proceed with this configuration?"; then
    print_info "Installation cancelled"
    exit 0
fi

# Create directory structure
print_header "Creating Directory Structure"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

mkdir -p "$CONFIG_DIR"/{modules,hosts,users,overlays}
mkdir -p "$CONFIG_DIR/hosts/$HOSTNAME"
mkdir -p "$CONFIG_DIR/users/$USERNAME"
print_success "Directory structure created"

# Generate hardware configuration
print_header "Hardware Configuration"
if prompt_yes_no "Generate hardware configuration now? (requires sudo)"; then
    sudo nixos-generate-config --show-hardware-config > "$CONFIG_DIR/hosts/$HOSTNAME/hardware-configuration.nix"
    print_success "Hardware configuration generated"
else
    print_warning "Skipping hardware configuration generation"
    print_info "You'll need to copy /etc/nixos/hardware-configuration.nix manually"
fi

# Create flake.nix
print_header "Generating Configuration Files"

cat > "$CONFIG_DIR/flake.nix" <<EOF
{
  description = "NixOS configuration for $HOSTNAME";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      $HOSTNAME = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/$HOSTNAME/configuration.nix
          ./hosts/$HOSTNAME/hardware-configuration.nix
$([ "$INSTALL_HOME_MANAGER" = true ] && cat <<INNER
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.$USERNAME = import ./users/$USERNAME/home.nix;
          }
INNER
)
        ];
      };
    };
  };
}
EOF
print_success "Created flake.nix"

# Create host configuration
cat > "$CONFIG_DIR/hosts/$HOSTNAME/configuration.nix" <<EOF
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
$([ "$DESKTOP" != "none" ] && echo "    ../../modules/desktop-$DESKTOP.nix")
$([ "$INSTALL_DEV_TOOLS" = true ] && echo "    ../../modules/development.nix")
$([ "$INSTALL_DOCKER" = true ] && echo "    ../../modules/docker.nix")
$([ "$INSTALL_VIRTUALIZATION" = true ] && echo "    ../../modules/virtualization.nix")
  ];

  # Networking
  networking.hostName = "$HOSTNAME";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "$TIMEZONE";
  i18n.defaultLocale = "$LOCALE";

  # User account
  users.users.$USERNAME = {
    isNormalUser = true;
    description = "$USERNAME";
    extraGroups = [ "wheel" "networkmanager" $([ "$INSTALL_DOCKER" = true ] && echo '"docker"') $([ "$INSTALL_VIRTUALIZATION" = true ] && echo '"libvirtd"') ];
    shell = pkgs.zsh;
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
  ];

  # Enable sound with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.05";
}
EOF
print_success "Created configuration.nix"

# Create system module
cat > "$CONFIG_DIR/modules/system.nix" <<EOF
{ config, pkgs, ... }:

{
  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = true;

  # Firewall
  networking.firewall.enable = true;
}
EOF
print_success "Created system.nix"

# Create desktop modules
if [ "$DESKTOP" = "gnome" ]; then
cat > "$CONFIG_DIR/modules/desktop-gnome.nix" <<EOF
{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
  ];
}
EOF
print_success "Created desktop-gnome.nix"
fi

if [ "$DESKTOP" = "kde" ]; then
cat > "$CONFIG_DIR/modules/desktop-kde.nix" <<EOF
{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kate
    konsole
    dolphin
  ];
}
EOF
print_success "Created desktop-kde.nix"
fi

if [ "$DESKTOP" = "i3" ]; then
cat > "$CONFIG_DIR/modules/desktop-i3.nix" <<EOF
{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dmenu
    i3status
    i3lock
    feh
    rofi
  ];
}
EOF
print_success "Created desktop-i3.nix"
fi

if [ "$DESKTOP" = "hyprland" ]; then
cat > "$CONFIG_DIR/modules/desktop-hyprland.nix" <<EOF
{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    kitty
    swww
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
EOF
print_success "Created desktop-hyprland.nix"
fi

# Create development module
if [ "$INSTALL_DEV_TOOLS" = true ]; then
cat > "$CONFIG_DIR/modules/development.nix" <<EOF
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim
    vscode

    # Version control
    git
    gh

    # Build tools
    gcc
    gnumake
    cmake

    # Languages
    python3
    nodejs
    rustc
    cargo

    # Utilities
    tmux
    tree
    ripgrep
    fd
    bat
  ];

$([ "$USE_GIT" = true ] && cat <<INNER
  programs.git = {
    enable = true;
    config = {
      user.name = "$GIT_NAME";
      user.email = "$GIT_EMAIL";
      init.defaultBranch = "main";
    };
  };
INNER
)
}
EOF
print_success "Created development.nix"
fi

# Create docker module
if [ "$INSTALL_DOCKER" = true ]; then
cat > "$CONFIG_DIR/modules/docker.nix" <<EOF
{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
EOF
print_success "Created docker.nix"
fi

# Create virtualization module
if [ "$INSTALL_VIRTUALIZATION" = true ]; then
cat > "$CONFIG_DIR/modules/virtualization.nix" <<EOF
{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    qemu
    OVMF
  ];
}
EOF
print_success "Created virtualization.nix"
fi

# Create home manager configuration
if [ "$INSTALL_HOME_MANAGER" = true ]; then
cat > "$CONFIG_DIR/users/$USERNAME/home.nix" <<EOF
{ config, pkgs, ... }:

{
  home.username = "$USERNAME";
  home.homeDirectory = "/home/$USERNAME";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Git configuration
$([ "$USE_GIT" = true ] && cat <<INNER
  programs.git = {
    enable = true;
    userName = "$GIT_NAME";
    userEmail = "$GIT_EMAIL";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
INNER
)

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alh";
      update = "sudo nixos-rebuild switch --flake .#$HOSTNAME";
      upgrade = "sudo nixos-rebuild switch --upgrade --flake .#$HOSTNAME";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" "docker" ];
    };
  };

  # Terminal
  programs.kitty = {
    enable = true;
    theme = "Tokyo Night";
  };

  # Additional programs
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
EOF
print_success "Created home.nix"
fi

# Create README
cat > "$CONFIG_DIR/README.md" <<EOF
# NixOS Configuration

This is a NixOS configuration generated by the interactive installer.

## Structure

\`\`\`
.
├── flake.nix                 # Main flake configuration
├── hosts/
│   └── $HOSTNAME/
│       ├── configuration.nix # Host-specific configuration
│       └── hardware-configuration.nix
├── modules/                  # Reusable system modules
├── users/
│   └── $USERNAME/
│       └── home.nix         # Home Manager configuration
└── install.sh               # This installer script
\`\`\`

## Usage

### Initial Installation

1. Run the installer:
   \`\`\`bash
   ./install.sh
   \`\`\`

2. After configuration generation, build and switch:
   \`\`\`bash
   sudo nixos-rebuild switch --flake .#$HOSTNAME
   \`\`\`

### Updating Configuration

After making changes to any configuration files:

\`\`\`bash
sudo nixos-rebuild switch --flake .#$HOSTNAME
\`\`\`

### Updating System

To update all packages:

\`\`\`bash
nix flake update
sudo nixos-rebuild switch --upgrade --flake .#$HOSTNAME
\`\`\`

## Configuration Details

- **Hostname**: $HOSTNAME
- **User**: $USERNAME
- **Desktop**: $DESKTOP
- **Timezone**: $TIMEZONE
- **Locale**: $LOCALE

## Customization

### Adding Packages

Edit \`hosts/$HOSTNAME/configuration.nix\` and add packages to \`environment.systemPackages\`.

### User Packages

Edit \`users/$USERNAME/home.nix\` and add packages to \`home.packages\`.

### Creating Modules

Add new modules in \`modules/\` and import them in your configuration.

## Useful Commands

\`\`\`bash
# Rebuild and switch
sudo nixos-rebuild switch --flake .#$HOSTNAME

# Test configuration without switching
sudo nixos-rebuild test --flake .#$HOSTNAME

# Build only (no activation)
sudo nixos-rebuild build --flake .#$HOSTNAME

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Garbage collection
sudo nix-collect-garbage -d
\`\`\`

## Troubleshooting

If you encounter issues:

1. Check syntax: \`nix flake check\`
2. View detailed errors: \`sudo nixos-rebuild switch --flake .#$HOSTNAME --show-trace\`
3. Rollback if needed: \`sudo nixos-rebuild switch --rollback\`

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)
EOF
print_success "Created README.md"

# Create .gitignore
cat > "$CONFIG_DIR/.gitignore" <<EOF
# Hardware configuration (machine-specific)
# Uncomment if you don't want to track hardware config
# hardware-configuration.nix

# Result symlinks
result
result-*

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~
EOF
print_success "Created .gitignore"

# Final steps
print_header "Installation Complete!"

echo "Configuration files have been generated in: $CONFIG_DIR"
echo ""
print_info "Next steps:"
echo ""
echo "1. Review the generated configuration files"
echo "2. If you haven't generated hardware-configuration.nix, copy it:"
echo "   cp /etc/nixos/hardware-configuration.nix $CONFIG_DIR/hosts/$HOSTNAME/"
echo ""
echo "3. Build and activate your configuration:"
echo "   cd $CONFIG_DIR"
echo "   sudo nixos-rebuild switch --flake .#$HOSTNAME"
echo ""
echo "4. (Optional) Initialize git repository:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial NixOS configuration'"
echo ""

if [ "$INSTALL_HOME_MANAGER" = true ]; then
    print_warning "Home Manager is configured as a NixOS module"
    print_info "User configurations will be activated with system rebuild"
fi

echo ""
print_success "Happy NixOS-ing!"
