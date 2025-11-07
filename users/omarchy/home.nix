{ config, pkgs, ... }:

{
  home.username = "omarchy";
  home.homeDirectory = "/home/omarchy";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # User packages for data science
  home.packages = with pkgs; [
    # Additional R packages
    rPackages.data_table
    rPackages.caret
    rPackages.randomForest
    rPackages.xgboost

    # Python packages
    python3Packages.statsmodels
    python3Packages.bokeh
    python3Packages.dash
    python3Packages.streamlit

    # Data tools
    csvtool
    miller  # CSV/JSON processor

    # Productivity
    obsidian  # Note-taking for research
    discord   # Collaboration
    slack
    zoom-us
  ];

  # Git configuration for data science projects
  programs.git = {
    enable = true;
    userName = "omarchy";
    userEmail = "your.email@example.com";  # Update with actual email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "store";
    };
    ignores = [
      # R
      ".Rhistory"
      ".RData"
      ".Rproj.user/"
      "*.Rproj"

      # Python
      "__pycache__/"
      "*.py[cod]"
      ".ipynb_checkpoints/"
      ".pytest_cache/"
      "venv/"
      "env/"

      # Data files
      "*.csv"
      "*.xlsx"
      "*.db"
      "*.sqlite"
      "*.parquet"

      # OS
      ".DS_Store"
      "Thumbs.db"
    ];
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alh";
      la = "ls -A";
      l = "ls -CF";

      # R shortcuts
      r = "R --quiet --no-save";
      rmd = "R -e 'rmarkdown::render'";

      # Python shortcuts
      py = "python3";
      ipy = "ipython";
      jl = "jupyter lab";
      jn = "jupyter notebook";

      # Database shortcuts
      pg = "psql";
      my = "mysql";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";

      # System shortcuts
      update = "sudo nixos-rebuild switch --flake .#omarchy-workstation";
      upgrade = "sudo nixos-rebuild switch --upgrade --flake .#omarchy-workstation";
      clean = "sudo nix-collect-garbage -d";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        "docker"
        "python"
        "web-search"
      ];
    };

    initExtra = ''
      # R environment
      export R_LIBS_USER="$HOME/R/library"

      # Python environment
      export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"

      # Jupyter config
      export JUPYTER_CONFIG_DIR="$HOME/.jupyter"

      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };



  # Terminal emulator
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    settings = {
      font_size = 12;
      font_family = "FiraCode Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      background_opacity = "0.95";
      enable_audio_bell = false;

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };
  };

  # Direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Tmux for terminal multiplexing
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    shortcut = "a";
    terminal = "screen-256color";

    extraConfig = ''
      # Better split panes
      bind | split-window -h
      bind - split-window -v

      # Mouse support
      set -g mouse on

      # Don't rename windows automatically
      set-option -g allow-rename off
    '';
  };

  # Zed editor configuration
  programs.zed-editor = {
    enable = true;
    extensions = [ "r" "python" "sql" "nix" ];
    userSettings = {
      theme = "Dracula";
      buffer_font_size = 14;
      buffer_font_family = "FiraCode Nerd Font";
      ui_font_size = 14;
      terminal = {
        font_size = 13;
        font_family = "FiraCode Nerd Font";
      };
      vim_mode = true;  # Enable vim keybindings
      autosave = "on_focus_change";
      format_on_save = "off";
    };
  };

  # File manager
  programs.nnn = {
    enable = true;
    bookmarks = {
      d = "~/Documents";
      D = "~/Downloads";
      p = "~/Projects";
      c = "~/Code";
    };
  };
}
