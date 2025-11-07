{ config, pkgs, ... }:

{
  # Data Science and Analysis Environment
  # Based on omarchy's profile: R, SQL, Data Science focus

  environment.systemPackages = with pkgs; [
    # R Programming Environment
    R
    rstudio
    rPackages.tidyverse
    rPackages.ggplot2
    rPackages.dplyr
    rPackages.shiny
    rPackages.readr
    rPackages.tidyr
    rPackages.purrr
    rPackages.stringr
    rPackages.forcats
    rPackages.lubridate
    rPackages.knitr
    rPackages.rmarkdown
    rPackages.plotly
    rPackages.DT
    rPackages.devtools

    # Python Data Science Stack
    python3
    python3Packages.pip
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.matplotlib
    python3Packages.seaborn
    python3Packages.scikit-learn
    python3Packages.jupyter
    python3Packages.ipython
    python3Packages.notebook
    python3Packages.jupyterlab

    # Database Tools and SQL
    postgresql
    pgcli                      # PostgreSQL CLI with autocomplete
    dbeaver                    # Universal database tool
    sqlite
    sqlitebrowser              # SQLite database browser
    mysql80

    # Data Visualization and Analysis
    visidata                   # Terminal spreadsheet tool

    # Statistical Tools
    gnumeric                   # Spreadsheet application
    libreoffice               # Office suite with Calc

    # Version Control and Collaboration
    git
    gh                        # GitHub CLI

    # Text Editors and IDEs
    zed-editor                # Modern collaborative code editor
    vim
    neovim

    # Document Creation
    pandoc                    # Universal document converter
    texlive.combined.scheme-full  # LaTeX for R Markdown

    # Utilities
    curl
    wget
    htop
    tree
    ripgrep
    fd
    jq                        # JSON processor

    # Data Format Tools
    csvkit                    # CSV utilities
  ];

  # PostgreSQL service configuration
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  # MySQL service configuration
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
  };

  # Jupyter configuration
  services.jupyter = {
    enable = false;  # Set to true if you want Jupyter as a service
    # To start manually: jupyter lab
  };
}
