# NeoVim Profile Manager

A modular NeoVim configuration system that lets you maintain multiple isolated profiles, each with its own theme, plugins and purpose, while sharing a common core of settings and keymaps across all of them.

Built on top of [LazyVim](https://lazyvim.org).

---

## Table of Contents

- [How it works](#how-it-works)
- [Directory structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Installation on Linux](#installation-on-linux)
- [Installation on Windows](#installation-on-windows)
- [Bash configuration (Linux)](#bash-configuration-linux)
- [PowerShell configuration (Windows)](#powershell-configuration-windows)
- [Managing profiles](#managing-profiles)
- [The Default profile](#the-default-profile)
- [Customizing a profile](#customizing-a-profile)
- [Adding plugins to the core](#adding-plugins-to-the-core)

---

## How it works

NeoVim respects the `NVIM_APPNAME` environment variable. When set, it loads its configuration from `~/.config/$NVIM_APPNAME` (Linux) or `%LOCALAPPDATA%\$NVIM_APPNAME` (Windows) instead of the default config directory. This means each profile is a completely independent configuration directory.

To avoid duplicating shared settings across every profile, this project uses the following architecture:

```
# Linux
~/.config/nvim-default  →  symlink to  →  profiles/Default/

# Windows
%LOCALAPPDATA%\nvim-default  →  junction to  →  profiles\Default\
```

Each profile loads the `core/` directory by adding it to Lua's module path before initializing lazy.nvim. lazy.nvim then loads the core plugins and the profile-specific plugins separately.

The full startup flow when opening NeoVim:

```
nvim .
  → shell wrapper reads the active profile file
  → opens with NVIM_APPNAME=nvim-default
    → profiles/Default/init.lua executes
      → core/ is added to the module path
      → require("config.lazy") loads core/lua/config/lazy.lua
        → lazy.nvim loads core/lua/core_plugins/*.lua   (shared plugins)
        → lazy.nvim loads profiles/Default/lua/plugins/*.lua   (profile plugins)
        → profile management commands are registered
```

---

## Directory structure

```
NeoVim_Profile_Manager/
├── core/                              <- shared nucleus across all profiles
│   ├── init.lua                       <- core entry point
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua           <- universal autocmds
│       │   ├── keymaps.lua            <- universal keymaps
│       │   ├── lazy.lua               <- lazy.nvim bootstrap + core loading
│       │   └── options.lua            <- universal NeoVim options
│       ├── core_plugins/
│       │   ├── editor.lua             <- universal editor plugins
│       │   ├── neo-tree.lua           <- file explorer configuration
│       │   └── ui.lua                 <- universal UI plugins
│       └── profile-switcher/
│           ├── init.lua               <- entry point for the profile manager
│           ├── data.lua               <- profile list and shared paths
│           ├── fs.lua                 <- filesystem operations (cross-platform)
│           ├── switcher.lua           <- :Profile command logic
│           └── manager.lua            <- :NewProfile, :EditProfile, :DeleteProfile
│
├── profiles/
│   └── Default/                       <- starting point and example profile
│       ├── init.lua                   <- profile entry point (identical across all profiles)
│       └── lua/plugins/
│           ├── base.lua               <- shell alias instructions
│           ├── theme.lua              <- active theme + examples of other themes
│           ├── tools.lua              <- LSP, formatters and linters
│           └── extra_plugins.lua      <- extra plugins with usage examples
│
├── scripts/
│   └── install.sh                     <- creates symlinks for existing profiles (Linux)
│
├── README.md
└── stylua.toml                        <- Lua formatter configuration
```

---

## Prerequisites

### Linux

- NeoVim >= 0.9
- Git
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your terminal font

### Windows

- NeoVim >= 0.9 (install via `winget install Neovim.Neovim` or `scoop install neovim`)
- Git (`winget install Git.Git`)
- A [Nerd Font](https://www.nerdfonts.com/) installed and set in Windows Terminal settings
- A C compiler for Treesitter (`winget install llvm`)
- ripgrep (`winget install BurntSushi.ripgrep.MSVC`)
- PowerShell 7+ recommended (comes pre-installed on Windows 11)

---

## Installation on Linux

### 1. Clone the repository

The repository should live at `~/.config/nvim/`:

```bash
git clone https://github.com/lannaanjos/NeoVim_Profile_Manager ~/.config/nvim
```

### 2. Create the symlinks

The `install.sh` script creates the symlinks for the profiles that already exist in the `profiles/` directory:

```bash
bash ~/.config/nvim/scripts/install.sh
```

### 3. Configure Bash

See [Bash configuration (Linux)](#bash-configuration-linux) below.

### 4. Open NeoVim for the first time

On the first launch, lazy.nvim will install all plugins automatically:

```bash
nvim
```

---

## Installation on Windows

### 1. Clone the repository

The repository should live at `%LOCALAPPDATA%\nvim`:

```powershell
git clone https://github.com/lannaanjos/NeoVim_Profile_Manager $env:LOCALAPPDATA\nvim
```

### 2. Create the .config directory

The profile manager stores the active profile in a `.config` folder inside your home directory. This folder does not exist by default on Windows:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config"
```

### 3. Create the junctions

On Windows, symlinks are replaced by **junctions**, which are directory links that NeoVim follows transparently. Run the following for each profile that already exists in the `profiles/` folder:

```powershell
New-Item -ItemType Junction `
  -Path "$env:LOCALAPPDATA\nvim-default" `
  -Target "$env:LOCALAPPDATA\nvim\profiles\Default"

New-Item -ItemType Junction `
  -Path "$env:LOCALAPPDATA\nvim-misc" `
  -Target "$env:LOCALAPPDATA\nvim\profiles\Misc"
```

Verify the result:

```powershell
ls $env:LOCALAPPDATA | Where-Object { $_.Name -like "nvim*" }
```

You should see `nvim`, `nvim-default` and `nvim-misc` in the output.

> New profiles created with `:NewProfile` will have their junction created automatically.

### 4. Configure PowerShell

See [PowerShell configuration (Windows)](#powershell-configuration-windows) below.

### 5. Open NeoVim for the first time

On the first launch, lazy.nvim will install all plugins automatically:

```powershell
nvim
```

---

## Bash configuration (Linux)

Add the following block to the end of your `~/.bashrc`:

```bash
# /\/\/\/\ nvim profile manager
NVIM_PROFILE_FILE="$HOME/.config/nvim-active-profile"

[ -f "$NVIM_PROFILE_FILE" ] || echo "nvim-default" > "$NVIM_PROFILE_FILE"

nvim() {
  local profile
  profile=$(cat "$NVIM_PROFILE_FILE")
  while true; do
    NVIM_APPNAME="$profile" command nvim "$@"
    local new_profile
    new_profile=$(cat "$NVIM_PROFILE_FILE")
    [ "$new_profile" = "$profile" ] && break
    profile="$new_profile"
  done
}

nvim-profile() {
  echo "active profile: $(cat "$NVIM_PROFILE_FILE")"
}
```

Then reload Bash:

```bash
source ~/.bashrc
```

### The `nvim()` wrapper

The `nvim()` function replaces the standard `nvim` command. Every time you run `nvim`, it reads the active profile from `~/.config/nvim-active-profile` and passes `NVIM_APPNAME` automatically. The internal loop also detects profile switches made from inside the editor and reopens NeoVim with the new profile without any extra input from you.

### Profile aliases

Each profile you create needs its own alias in `~/.bashrc` so you can open NeoVim directly into that profile from the terminal. The alias is generated automatically when you run `:NewProfile` and shown inside the profile's `base.lua` file.

For example, a profile called `Work` would need:

```bash
Work() { echo "nvim-work" > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-work" command nvim "$@"; }
```

With this alias set up, you can open NeoVim directly into that profile:

```bash
Work .           # opens the current directory in the Work profile
Work file.py     # opens file.py in the Work profile
```

When using a profile alias, that profile is also saved as the active one. The next time you run `nvim` without a prefix, it will use that profile.

### Check the active profile

```bash
nvim-profile
# active profile: nvim-default
```

---

## PowerShell configuration (Windows)

### 1. Open your PowerShell profile

First, ensure the profile directory exists:

```powershell
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE)
```

Then open the file:

```powershell
nvim $PROFILE
```

### 2. Add the following block to the end of the file

```powershell
# /\/\/\/\ nvim profile manager
$env:NVIM_PROFILE_FILE = "$env:USERPROFILE\.config\nvim-active-profile"

if (-not (Test-Path $env:NVIM_PROFILE_FILE)) {
    New-Item -Force -Path $env:NVIM_PROFILE_FILE | Out-Null
    "nvim-default" | Set-Content $env:NVIM_PROFILE_FILE
}

function nvim {
    $profile = Get-Content $env:NVIM_PROFILE_FILE
    while ($true) {
        $env:NVIM_APPNAME = $profile
        & "nvim.exe" @args
        $newProfile = Get-Content $env:NVIM_PROFILE_FILE
        if ($newProfile -eq $profile) { break }
        $profile = $newProfile
    }
}

function nvim-profile { Write-Host "active profile: $(Get-Content $env:NVIM_PROFILE_FILE)" }
```

### 3. Reload PowerShell

```powershell
. $PROFILE
```

### The `nvim` wrapper

The `nvim` function works the same way as on Linux: it reads the active profile and passes `NVIM_APPNAME` automatically. The loop detects profile switches made from inside the editor and reopens NeoVim with the new profile automatically.

### Profile functions

Each profile you create needs its own function added to your `$PROFILE` file. The function is shown in the profile's `base.lua` as a Bash alias -- adapt it to PowerShell format:

```powershell
function Work {
    "nvim-work" | Set-Content $env:NVIM_PROFILE_FILE
    $env:NVIM_APPNAME = "nvim-work"
    & "nvim.exe" @args
}
```

With this function set up, you can open NeoVim directly into that profile:

```powershell
Work .           # opens the current directory in the Work profile
Work file.py     # opens file.py in the Work profile
```

### Check the active profile

```powershell
nvim-profile
# active profile: nvim-default
```

---

## Managing profiles

All profile management happens from inside NeoVim through three commands. All of them support tab completion.

### Creating a profile

```
:NewProfile <name>
```

This command does everything automatically:

1. Creates the profile directory structure under `profiles/<name>/`
2. Creates the `init.lua` entry point
3. Creates a `base.lua` file with the shell alias already written in a comment
4. Creates the symlink (Linux) or junction (Windows) pointing to the new profile
5. Registers the profile in the profile list

After running the command, open `profiles/<name>/lua/plugins/base.lua` and copy the alias into your `~/.bashrc` (Linux) or `$PROFILE` (Windows), adapting the syntax as shown in the [PowerShell configuration](#powershell-configuration-windows) section if needed.

### Switching profiles

```
:Profile
```

Opens an interactive picker listing all available profiles. The currently active one is marked as `(active)`. Selecting a different profile will:

1. Save all open buffers
2. Write the new profile to the active profile file
3. Exit NeoVim
4. The shell wrapper detects the change and reopens NeoVim with the new profile automatically

You can also switch directly by passing the profile name:

```
:Profile Work
:Profile Default
```

### Editing a profile

```
:EditProfile <name>
```

Opens a terminal window inside NeoVim with the working directory set to the profile's folder. From there you can edit any file in the profile.

### Deleting a profile

```
:DeleteProfile <name>
```

Shows a confirmation prompt. If confirmed, it will:

1. Remove the profile directory from `profiles/`
2. Remove the symlink or junction from the config directory
3. Unregister the profile from the profile list

You will also be reminded to remove the profile function from your shell config manually, since the manager does not edit that file.

---

## The Default profile

The `Default` profile is included in the repository as a starting point and a reference. It comes with:

- **Gruvbox** as the active theme, with examples of other popular themes commented out
- **LSP** configured for Lua, with examples for Python, TypeScript, Rust and others commented out
- **Formatters and linters** via conform.nvim and nvim-lint, with examples commented out
- **Extra plugins** including nvim-surround active, and vim-fugitive, todo-comments and harpoon commented out as examples

Each file has comments explaining what every option does and how to adapt it to your needs.

To use the Default profile as a base for a new one, simply run `:NewProfile <name>` and customize the generated files.

---

## Customizing a profile

Each profile lives in `profiles/<name>/lua/plugins/`. You can create as many `.lua` files there as you want. lazy.nvim loads all of them automatically.

### Adding a theme

Create a `theme.lua` file inside the profile's plugins folder:

```lua
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      contrast = "hard",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
```

The `priority = 1000` ensures the theme loads before any other plugin, avoiding color flickering on startup. The `LazyVim/LazyVim` entry tells LazyVim which colorscheme to activate.

### Adding language servers

Create or edit a `tools.lua` file inside the profile's plugins folder:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},        -- Python
        ts_ls = {},          -- TypeScript / JavaScript
        rust_analyzer = {},  -- Rust
      },
    },
  },
}
```

Mason will install the listed servers automatically on the next NeoVim launch.

### Adding any other plugin

```lua
return {
  {
    "author/plugin-name",
    event = "VeryLazy",
    opts = {},
  },
}
```

Refer to the [lazy.nvim documentation](https://lazy.folke.io/spec) for the full plugin spec.

---

## Adding plugins to the core

Plugins added to the core are available across all profiles. Create or edit any `.lua` file under `core/lua/core_plugins/`. lazy.nvim loads all files from that directory automatically.

Example: adding `nvim-surround` to the core so it is available in every profile:

```lua
-- core/lua/core_plugins/editor.lua
return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
}
```

If a plugin only makes sense for a specific profile, add it to that profile's `lua/plugins/` folder instead.