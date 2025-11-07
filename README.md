# NixOS Interactive Configuration Installer

A comprehensive, interactive shell script for setting up a complete NixOS configuration with flakes, Home Manager, and modular architecture.

## Features

- **Interactive Setup**: Guided installation process with prompts for all configuration options
- **Flakes Support**: Modern NixOS configuration using flakes
- **Home Manager Integration**: User-specific package and dotfile management
- **Modular Architecture**: Organized, reusable configuration modules
- **Multiple Desktop Environments**: Support for GNOME, KDE, i3, Hyprland, or minimal setups
- **Development Tools**: Optional installation of dev tools, Docker, virtualization
- **Auto-generated Files**: Automatically creates all necessary configuration files

## Quick Start

### Prerequisites

- NixOS installed on your system
- Basic familiarity with terminal commands
- Internet connection

### Installation

1. Clone or download this repository:
   ```bash
   git clone https://github.com/clouraLabs/nixos.git
   cd nixos
   ```

2. Run the interactive installer:
   ```bash
   ./install.sh
   ```

   Or download and run directly:
   ```bash
   curl -O https://raw.githubusercontent.com/clouraLabs/nixos/main/install.sh
   chmod +x install.sh
   ./install.sh
   ```

3. Follow the prompts to configure your system:
   - Username and hostname
   - Timezone and locale
   - Git configuration
   - Desktop environment selection
   - Package preferences

4. After the installer completes, activate your configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

## Directory Structure

```
.
├── install.sh                    # Interactive installation script
├── flake.nix                     # Main flake configuration (generated)
├── flake.nix.example             # Example flake template
├── configuration.nix.example     # Example system configuration
├── home.nix.example              # Example home-manager configuration
├── hosts/                        # Host-specific configurations
│   └── <hostname>/
│       ├── configuration.nix     # System configuration
│       └── hardware-configuration.nix  # Hardware config
├── modules/                      # Reusable system modules
│   ├── system.nix               # Base system configuration
│   ├── desktop-*.nix            # Desktop environment modules
│   ├── development.nix          # Development tools
│   ├── docker.nix               # Docker configuration
│   └── virtualization.nix       # Virtualization setup
├── users/                       # User-specific configurations
│   └── <username>/
│       └── home.nix             # Home Manager configuration
└── README.md                    # This file
```

## Configuration Options

### Desktop Environments

The installer supports multiple desktop environments:

1. **GNOME** - Full-featured desktop with Wayland support
2. **KDE Plasma** - Customizable Qt-based desktop
3. **i3** - Lightweight tiling window manager
4. **Hyprland** - Modern Wayland compositor with tiling
5. **None** - Minimal setup for servers or custom setups

### Package Collections

- **Development Tools**: Git, Vim, VSCode, compilers, language runtimes
- **Docker**: Container runtime with docker-compose
- **Virtualization**: QEMU/KVM with virt-manager

### Home Manager

Optional Home Manager integration provides:
- User-specific package management
- Dotfile configuration
- Shell configuration (Zsh with Oh-My-Zsh)
- Terminal emulator setup (Kitty)
- Git configuration
- Development environment tools

## Usage

### Building Your Configuration

After making any changes to configuration files:

```bash
# Switch to new configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Test without switching (temporary)
sudo nixos-rebuild test --flake .#<hostname>

# Build only (don't activate)
sudo nixos-rebuild build --flake .#<hostname>
```

### Updating System

```bash
# Update flake inputs
nix flake update

# Apply updates
sudo nixos-rebuild switch --upgrade --flake .#<hostname>
```

### Managing Generations

```bash
# List all generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Switch to specific generation
sudo nix-env --switch-generation <number> --profile /nix/var/nix/profiles/system
```

### Garbage Collection

```bash
# Delete old generations and clean up
sudo nix-collect-garbage -d

# Delete generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d
```

## Customization

### Adding System Packages

Edit `hosts/<hostname>/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  package-name
];
```

### Adding User Packages

Edit `users/<username>/home.nix`:

```nix
home.packages = with pkgs; [
  # Add your packages here
  package-name
];
```

### Creating Custom Modules

1. Create a new file in `modules/`:
   ```bash
   touch modules/my-module.nix
   ```

2. Add your configuration:
   ```nix
   { config, pkgs, ... }:

   {
     # Your configuration here
   }
   ```

3. Import it in your configuration:
   ```nix
   imports = [
     ../../modules/my-module.nix
   ];
   ```

### Configuring Multiple Hosts

To manage multiple machines:

1. Create a new host directory:
   ```bash
   mkdir -p hosts/new-hostname
   ```

2. Generate hardware config for the new host:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/new-hostname/hardware-configuration.nix
   ```

3. Create `hosts/new-hostname/configuration.nix` (use existing as template)

4. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     new-hostname = nixpkgs.lib.nixosSystem {
       # ... configuration
     };
   };
   ```

## Useful Aliases

If you configured Home Manager with Zsh, these aliases are available:

```bash
ll              # ls -alh
update          # Rebuild and switch configuration
upgrade         # Update and rebuild system
clean           # Run garbage collection
```

## Troubleshooting

### Check Configuration Syntax

```bash
nix flake check
```

### View Detailed Build Output

```bash
sudo nixos-rebuild switch --flake .#<hostname> --show-trace
```

### Debug Evaluation Issues

```bash
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel --show-trace
```

### Common Issues

1. **"error: getting status of '/etc/nixos/flake.nix': No such file or directory"**
   - Make sure you're in the correct directory
   - Use the full flake path: `.#<hostname>`

2. **"error: experimental Nix feature 'nix-command' is disabled"**
   - Add to configuration: `nix.settings.experimental-features = [ "nix-command" "flakes" ];`

3. **Hardware configuration not found**
   - Copy from system: `cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/`

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Contributing

Feel free to customize this configuration to your needs. Common improvements:

- Add more desktop environment options
- Create specialized modules (gaming, multimedia, etc.)
- Add support for different architectures
- Improve hardware detection and configuration

## License

This configuration is provided as-is for educational and practical use.

## Support

For NixOS-specific questions:
- Check the [NixOS Discourse](https://discourse.nixos.org/)
- Join the [NixOS Matrix channel](https://matrix.to/#/#community:nixos.org)
- Read the official documentation

---

**Note**: This installer generates a basic but functional NixOS configuration. You should review and customize the generated files according to your specific needs and security requirements.
