# Data Science NixOS Configuration (omarchy-style)

This configuration is based on omarchy's tech stack and interests: **R, SQL, and Data Science**.

## What's Included

### Programming Languages & Environments

#### R Ecosystem
- **R** - Statistical computing language
- **RStudio** - Premier R IDE
- **R Packages**:
  - tidyverse (dplyr, ggplot2, tidyr, readr, purrr, stringr, forcats, lubridate)
  - shiny (web applications)
  - knitr, rmarkdown (document generation)
  - plotly, DT (interactive visualizations)
  - data.table, caret, randomForest, xgboost (machine learning)
  - devtools (package development)

#### Python Data Science Stack
- **Python 3** with pip
- **Jupyter Lab/Notebook** - Interactive computing
- **Core Libraries**:
  - pandas (data manipulation)
  - numpy (numerical computing)
  - scipy (scientific computing)
  - matplotlib, seaborn (visualization)
  - scikit-learn (machine learning)
  - statsmodels, bokeh, dash, streamlit (additional tools)

### Database Tools

#### Databases Installed
- **PostgreSQL** (version 15) with pgcli
- **MySQL** (version 8.0)
- **SQLite** with GUI browser

#### Database Management
- **DBeaver** - Universal database tool (supports PostgreSQL, MySQL, SQLite, and more)
- **pgcli** - PostgreSQL CLI with autocomplete
- **SQLite Browser** - Visual SQLite database manager

### Development Tools

- **Git** + GitHub CLI (gh)
- **Zed Editor** - Modern collaborative code editor
  - R, Python, SQL, Nix support
  - GPU-accelerated performance
  - Real-time collaboration
  - Vim mode enabled
- **Vim/Neovim** - Terminal editors
- **Tmux** - Terminal multiplexer

### Data Tools

- **Pandoc** - Universal document converter
- **LaTeX** (full TeXLive) - For R Markdown PDF output
- **csvkit** - CSV command-line tools
- **miller** - CSV/JSON processor
- **visidata** - Terminal spreadsheet tool
- **jq** - JSON processor

### Productivity Apps

- **LibreOffice** - Office suite with Calc spreadsheet
- **Obsidian** - Note-taking for research
- **Firefox & Chromium** - Web browsers
- **Discord, Slack, Zoom** - Collaboration tools

### Desktop Environment

- **GNOME Desktop** - User-friendly desktop environment
- **Kitty Terminal** - Modern GPU-accelerated terminal with Dracula theme

## Installation

### 1. Prepare Hardware Configuration

Generate or copy your hardware configuration:

```bash
cd /home/clouralabs/Documents/nixos
sudo nixos-generate-config --show-hardware-config > hosts/omarchy-workstation/hardware-configuration.nix
```

### 2. Review Configuration

Edit the files to customize:

- `hosts/omarchy-workstation/configuration.nix` - System settings
- `users/omarchy/home.nix` - User preferences and packages
- `modules/data-science.nix` - Data science packages

**Important**: Update the git email in `users/omarchy/home.nix`:
```nix
programs.git = {
  userEmail = "your.email@example.com";  # <-- Change this
};
```

### 3. Build and Switch

```bash
sudo nixos-rebuild switch --flake .#omarchy-workstation
```

### 4. Post-Installation Setup

#### PostgreSQL Setup
```bash
# PostgreSQL should auto-start, create your database:
sudo -u postgres createuser -s $USER
createdb mydata
psql mydata
```

#### MySQL Setup
```bash
# Start MySQL
sudo systemctl start mysql
sudo mysql
```

#### Jupyter Lab
```bash
# Start Jupyter Lab
jupyter lab
# Access at http://localhost:8888
```

#### RStudio
```bash
# Launch from applications menu or:
rstudio
```

## Usage

### R Development

```bash
# Start R console
R

# Render R Markdown
R -e 'rmarkdown::render("analysis.Rmd")'

# Install additional R packages
R -e 'install.packages("package_name")'
```

### Python Data Science

```bash
# Jupyter Lab
jupyter lab

# Jupyter Notebook
jupyter notebook

# IPython
ipython

# Run Python script
python3 script.py
```

### Database Operations

```bash
# PostgreSQL
psql mydata

# MySQL
mysql -u root

# SQLite
sqlite3 mydata.db
```

### Shiny Apps

Create a Shiny app and run:
```bash
R -e 'shiny::runApp("app.R")'
# Access at http://localhost:3838
```

## Project Structure for Data Science

Recommended folder structure:

```
~/Projects/
├── analysis-project/
│   ├── data/
│   │   ├── raw/
│   │   └── processed/
│   ├── notebooks/
│   │   ├── exploration.ipynb
│   │   └── analysis.Rmd
│   ├── scripts/
│   │   ├── clean_data.R
│   │   └── model.py
│   ├── output/
│   │   ├── figures/
│   │   └── reports/
│   └── README.md
```

## Useful Aliases

These are pre-configured in your shell:

```bash
# R
r              # Start R
rmd            # Render R Markdown

# Python
py             # Python 3
ipy            # IPython
jl             # Jupyter Lab
jn             # Jupyter Notebook

# Database
pg             # psql
my             # mysql

# Git
gs             # git status
ga             # git add
gc             # git commit
gp             # git push
gl             # git log graph

# System
update         # Rebuild NixOS
upgrade        # Update and rebuild
clean          # Garbage collection
```

## Database Ports (Firewall Opened)

- PostgreSQL: 5432
- MySQL: 3306
- RStudio Server: 8787
- Jupyter: 8888
- Shiny: 3838

## Docker for Data Science

Docker is enabled for containerized workflows:

```bash
# Pull data science images
docker pull jupyter/datascience-notebook
docker pull rocker/tidyverse

# Run Jupyter in container
docker run -p 8888:8888 jupyter/datascience-notebook

# Run RStudio Server in container
docker run -p 8787:8787 -e PASSWORD=yourpassword rocker/rstudio
```

## Adding More Packages

### System-wide R Packages

Edit `modules/data-science.nix`:
```nix
rPackages.package_name
```

### User-specific Packages

Edit `users/omarchy/home.nix`:
```nix
home.packages = with pkgs; [
  rPackages.new_package
  python3Packages.new_package
];
```

Then rebuild:
```bash
update  # or: sudo nixos-rebuild switch --flake .#omarchy-workstation
```

## Troubleshooting

### R Package Installation Issues

If R packages fail to install via nix, install directly in R:
```r
install.packages("package_name", lib="~/R/library")
```

### Python Package Installation

Use pip for packages not in nixpkgs:
```bash
pip install --user package_name
```

### Database Connection Issues

Check services are running:
```bash
systemctl status postgresql
systemctl status mysql
```

## Resources for Data Science with R & SQL

- [R for Data Science](https://r4ds.had.co.nz/)
- [Advanced R](https://adv-r.hadley.nz/)
- [Tidy Modeling with R](https://www.tmwr.org/)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)
- [SQL for Data Analysis](https://mode.com/sql-tutorial/)
- [Jupyter Documentation](https://jupyter.org/documentation)

## Version Control Best Practices

Pre-configured `.gitignore` for data science:
- R history and project files
- Python cache and virtual environments
- Jupyter checkpoints
- Large data files (*.csv, *.xlsx, *.db)

Remember to **never commit sensitive data or credentials** to git!

---

**Happy Data Science!** 🔬📊📈
