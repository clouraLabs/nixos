# Complete Application List - omarchy Data Science Setup

## Programming Languages

### R Ecosystem
- **R** - Statistical programming language
- **RStudio** - Integrated development environment for R

### Python
- **Python 3** - General programming language
- **IPython** - Interactive Python shell
- **Jupyter Lab** - Web-based interactive computing
- **Jupyter Notebook** - Classic notebook interface

## R Packages (Pre-installed)

### Core tidyverse
- dplyr - Data manipulation
- ggplot2 - Data visualization
- tidyr - Data tidying
- readr - Reading data files
- purrr - Functional programming
- stringr - String manipulation
- forcats - Factor handling
- lubridate - Date/time handling

### Shiny & Web
- shiny - Interactive web applications
- plotly - Interactive plots
- DT - Interactive tables

### Document Generation
- knitr - Dynamic report generation
- rmarkdown - R Markdown documents

### Machine Learning
- caret - Machine learning framework
- randomForest - Random forest algorithm
- xgboost - Gradient boosting
- data.table - Fast data manipulation

### Development
- devtools - Package development tools

## Python Packages (Pre-installed)

### Data Manipulation
- pandas - DataFrame operations
- numpy - Numerical arrays
- scipy - Scientific computing

### Visualization
- matplotlib - Plotting library
- seaborn - Statistical visualization
- bokeh - Interactive visualizations

### Machine Learning
- scikit-learn - ML algorithms
- statsmodels - Statistical models

### Web Applications
- dash - Interactive dashboards
- streamlit - Data app framework

## Databases

### Database Servers
- **PostgreSQL 15** - Relational database
- **MySQL 8.0** - Relational database
- **SQLite** - Embedded database

### Database Tools
- **DBeaver** - Universal database GUI
- **pgcli** - PostgreSQL CLI with autocomplete
- **SQLite Browser** - SQLite GUI
- **psql** - PostgreSQL command-line
- **mysql** - MySQL command-line

## Development Tools

### Editors & IDEs
- **Zed Editor** - Modern collaborative code editor
  - R, Python, SQL, Nix extensions
  - Fast, GPU-accelerated
  - Real-time collaboration
  - Vim mode enabled
  - Dracula theme
- **Vim** - Terminal text editor
- **Neovim** - Modern Vim fork

### Version Control
- **Git** - Version control system
- **GitHub CLI (gh)** - GitHub from command line

### Terminal Tools
- **Tmux** - Terminal multiplexer
- **Kitty** - GPU-accelerated terminal
- **Zsh** - Shell with Oh-My-Zsh
- **Direnv** - Directory-based environments

## Data Processing Tools

### Command-line Data Tools
- **csvkit** - CSV utilities (csvcut, csvgrep, csvsql, etc.)
- **miller** - CSV/JSON/TSV processing
- **visidata** - Terminal spreadsheet viewer
- **jq** - JSON processor
- **csvtool** - CSV manipulation

### Document Processing
- **Pandoc** - Universal document converter
- **LaTeX (TeXLive Full)** - Document typesetting

## Office & Productivity

### Office Suite
- **LibreOffice** - Full office suite
  - Writer (word processor)
  - Calc (spreadsheet)
  - Impress (presentations)
- **Gnumeric** - Lightweight spreadsheet

### Note-taking & Knowledge
- **Obsidian** - Markdown-based notes

## Browsers
- **Firefox** - Web browser
- **Chromium** - Open-source browser

## Communication & Collaboration
- **Discord** - Team chat
- **Slack** - Workplace communication
- **Zoom** - Video conferencing

## System Utilities

### Monitoring
- **htop** - Interactive process viewer
- **btop** - Modern resource monitor

### File Management
- **nnn** - Terminal file manager

### Command-line Utilities
- **curl** - Data transfer tool
- **wget** - File downloader
- **ripgrep (rg)** - Fast text search
- **fd** - Fast file finder
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls replacement
- **tree** - Directory tree viewer
- **fzf** - Fuzzy finder

## Containerization
- **Docker** - Container runtime
- **Docker Compose** - Multi-container orchestration

## Desktop Environment
- **GNOME** - Desktop environment
  - GDM - Display manager
  - GNOME Tweaks - Desktop customization
  - Nautilus - File manager
  - GNOME Terminal - Terminal emulator

## Additional System Features

### Audio
- **PipeWire** - Audio server
- **ALSA** - Audio drivers
- PulseAudio compatibility layer

### Network
- **NetworkManager** - Network management
- SSH server (OpenSSH)

### Fonts
- FiraCode Nerd Font (with ligatures)

## Service Ports (Opened in Firewall)
- 5432 - PostgreSQL
- 3306 - MySQL
- 8787 - RStudio Server
- 8888 - Jupyter Lab/Notebook
- 3838 - Shiny Server

## Total Package Count: 100+

### Breakdown
- R packages: 20+
- Python packages: 15+
- Database tools: 6
- Development tools: 10+
- Data processing: 8+
- Productivity apps: 10+
- System utilities: 15+
- Desktop environment: Full GNOME stack

---

## Quick Installation Commands

### After Setup, Install Additional Packages

**R packages:**
```r
install.packages("package_name")
```

**Python packages:**
```bash
pip install --user package_name
```

**System packages:**
Edit `modules/data-science.nix` or `users/omarchy/home.nix` and rebuild:
```bash
sudo nixos-rebuild switch --flake .#omarchy-workstation
```

---

This configuration provides a complete data science workstation with everything needed for R, Python, SQL, and data analysis workflows.
