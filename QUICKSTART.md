# Quick Start Guide

Get your NixOS system configured in minutes with this interactive installer.

## Installation Steps

### 1. Get the Repository

```bash
# Clone the repository
git clone https://github.com/clouraLabs/nixos.git
cd nixos

# Or just download the installer script
curl -O https://raw.githubusercontent.com/clouraLabs/nixos/main/install.sh
chmod +x install.sh
```

### 2. Run the Installer

```bash
./install.sh
```

### 3. Answer the Prompts

The installer will ask you about:

- **Username**: Your system username (default: current user)
- **Hostname**: Your computer's name (default: current hostname)
- **Timezone**: Your timezone (default: America/New_York)
- **Locale**: Your language settings (default: en_US.UTF-8)
- **Git Config**: Name and email for git commits
- **Desktop Environment**: Choose from GNOME, KDE, i3, Hyprland, or none
- **Package Options**: Dev tools, Docker, Virtualization
- **Home Manager**: User-level package management

### 4. Review Generated Configuration

The installer creates:

```
nixos/
├── flake.nix                    # Main configuration
├── hosts/
│   └── your-hostname/
│       ├── configuration.nix    # System config
│       └── hardware-configuration.nix
├── modules/                     # Reusable modules
│   ├── system.nix
│   ├── desktop-*.nix
│   ├── development.nix
│   └── ...
└── users/
    └── your-username/
        └── home.nix            # User config
```

### 5. Build and Activate

```bash
cd nixos
sudo nixos-rebuild switch --flake .#your-hostname
```

### 6. Reboot (Optional)

For a clean start with all changes applied:

```bash
sudo reboot
```

## What Gets Installed?

### Minimal (Always)

- Base system utilities (vim, wget, curl, git, htop)
- Network Manager
- PipeWire audio
- Your chosen shell (Zsh with Oh-My-Zsh)

### Desktop Environment (If Selected)

- **GNOME**: Full GNOME desktop + tweaks tools
- **KDE**: Plasma desktop + Kate, Konsole, Dolphin
- **i3**: i3wm + dmenu, i3status, rofi
- **Hyprland**: Hyprland compositor + waybar, rofi-wayland, kitty

### Development Tools (If Selected)

- Editors: vim, neovim, zed-editor
- Version control: git, gh (GitHub CLI)
- Build tools: gcc, make, cmake
- Languages: Python, Node.js, Rust
- Utilities: tmux, ripgrep, fd, bat

### Docker (If Selected)

- Docker daemon
- docker-compose

### Virtualization (If Selected)

- QEMU/KVM
- virt-manager
- libvirt

### Home Manager (If Selected)

- User package management
- Dotfile configuration
- Enhanced Zsh with plugins
- Kitty terminal
- Direnv for project environments

## Daily Usage

### Update System Packages

```bash
nix flake update
sudo nixos-rebuild switch --flake .#your-hostname
```

### Install New Package

**System-wide** (edit `hosts/your-hostname/configuration.nix`):
```nix
environment.systemPackages = with pkgs; [
  firefox
  # your new package
];
```

**User-level** (edit `users/your-username/home.nix`):
```nix
home.packages = with pkgs; [
  discord
  # your new package
];
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Rollback Changes

If something breaks:
```bash
sudo nixos-rebuild switch --rollback
```

### Clean Up Old Generations

```bash
sudo nix-collect-garbage -d
```

## Troubleshooting

### Check for Errors

```bash
nix flake check
```

### View Detailed Build Logs

```bash
sudo nixos-rebuild switch --flake .#your-hostname --show-trace
```

### Test Without Committing

```bash
sudo nixos-rebuild test --flake .#your-hostname
```

## Next Steps

1. **Customize**: Edit configuration files to add your preferred packages
2. **Backup**: Commit your configuration to git
3. **Sync**: Push to GitHub/GitLab for backup and sharing
4. **Learn**: Read the [NixOS manual](https://nixos.org/manual/nixos/stable/)

## Help

- Configuration examples: See `*.example` files
- Full documentation: See `README.md`
- Search packages: https://search.nixos.org/
- Ask questions: https://discourse.nixos.org/

---

**Note**: The first build may take 10-30 minutes as Nix downloads and builds packages. Subsequent builds will be much faster thanks to Nix's caching.
