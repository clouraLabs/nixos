{ config, pkgs, inputs, ... }:

{
  imports = [
    # ./hardware-configuration.nix  # Generated during installation
    ../../modules/data-science.nix
  ];

  # Networking
  networking.hostName = "omarchy-workstation";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.omarchy = {
    isNormalUser = true;
    description = "Data Science User";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # Enable flakes and optimize download performance
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    
    # Maximum download buffer and connection settings
    download-buffer-size = 268435456;  # 256MB download buffer (default: 64MB)
    http-connections = 128;            # Maximum parallel HTTP connections (default: 25)
    download-attempts = 5;             # Number of download retry attempts (default: 5)
    connect-timeout = 300;             # Connection timeout in seconds (default: 0)
    stalled-download-timeout = 300;    # Timeout for stalled downloads in seconds (default: 300)
    
    # Enable parallel building for faster builds
    max-jobs = "auto";                 # Maximum build jobs (auto = number of CPU cores)
    cores = 0;                         # Build cores per job (0 = all available)
  };
  # Enable flakes and optimize download performance
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    
    # Maximum download buffer and connection settings
    download-buffer-size = 268435456;  # 256MB download buffer (default: 64MB)
    http-connections = 128;            # Maximum parallel HTTP connections (default: 25)
    download-attempts = 5;             # Number of download retry attempts (default: 5)
    connect-timeout = 300;             # Connection timeout in seconds (default: 0)
    stalled-download-timeout = 300;    # Timeout for stalled downloads in seconds (default: 300)
    
    # Enable parallel building for faster builds
    max-jobs = "auto";                 # Maximum build jobs (auto = number of CPU cores)
    cores = 0;                         # Build cores per job (0 = all available)
  };

  # Allow unfree packages (for RStudio, VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    btop
    firefox
    chromium
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

  # Enable X11 and Desktop Environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable Docker for containerized data science workflows
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = true;
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8787  # RStudio Server
      8888  # Jupyter
      3838  # Shiny Server
      5432  # PostgreSQL
      3306  # MySQL
    ];
  };

  system.stateVersion = "25.05";
}
