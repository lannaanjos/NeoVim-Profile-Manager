# NeoVim Profile Manager

A modular NeoVim configuration system that lets you maintain multiple isolated profiles, each with its own theme, plugins and purpose, while sharing a common core of settings and keymaps across all of them.

Built on top of [LazyVim](https://lazyvim.org).

---

## Table of Contents

- [How it works](#how-it-works)
- [Directory structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Bash configuration](#bash-configuration)
- [Managing profiles](#managing-profiles)
- [The Default profile](#the-default-profile)
- [Customizing a profile](#customizing-a-profile)
- [Adding plugins to the core](#adding-plugins-to-the-core)

---

## How it works

NeoVim respects the `NVIM_APPNAME` environment variable. When set, it loads its configuration from `~/.config/$NVIM_APPNAME` instead of `~/.config/nvim`. This means each profile is a completely independent configuration directory.

To avoid duplicating shared settings across every profile, this project uses the following architecture:

```
~/.config/nvim-default  →  symlink to  →  profiles/Default/
~/.config/nvim-work     →  symlink to  →  profiles/Work/
...
```

Each profile loads the `core/` directory by adding it to Lua's module path before initializing lazy.nvim. lazy.nvim then loads the core plugins and the profile-specific plugins separately.

The full startup flow when opening NeoVim:

```
nvim .
  → bash wrapper reads ~/.config/nvim-active-profile
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
│           ├── fs.lua                 <- filesystem operations
│           ├── switcher.lua           <- :Profile command logic
│           └── manager.lua            <- :NewProfile, :EditProfile, :DeleteProfile
│
├── profiles/
│   └── Default/                       <- starting point and example profile
│       ├── init.lua                   <- profile entry point (identical across all profiles)
│       └── lua/plugins/
│           ├── base.lua               <- bashrc alias instructions
│           ├── theme.lua              <- active theme + examples of other themes
│           ├── tools.lua              <- LSP, formatters and linters
│           └── extra_plugins.lua      <- extra plugins with usage examples
│
├── scripts/
│   └── install.sh                     <- creates symlinks for existing profiles
│
├── README.md
└── stylua.toml                        <- Lua formatter configuration
```

---

## Prerequisites

- NeoVim >= 0.9
- Git
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your terminal font

---

## Installation

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

See [Bash configuration](#bash-configuration) below.

### 4. Open NeoVim for the first time

On the first launch, lazy.nvim will install all plugins automatically:

```bash
nvim
```

---

## Bash configuration

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

## Managing profiles

All profile management happens from inside NeoVim through three commands. All of them support tab completion.

### Creating a profile

```
:NewProfile <name>
```

This command does everything automatically:

1. Creates the profile directory structure under `profiles/<name>/`
2. Creates the `init.lua` entry point
3. Creates a `base.lua` file with the bashrc alias already written in a comment
4. Creates the symlink at `~/.config/nvim-<name>`
5. Registers the profile in the profile list

After running the command, open `profiles/<name>/lua/plugins/base.lua` and copy the alias into your `~/.bashrc`.

### Switching profiles

```
:Profile
```

Opens an interactive picker listing all available profiles. The currently active one is marked as `(active)`. Selecting a different profile will:

1. Save all open buffers
2. Write the new profile to `~/.config/nvim-active-profile`
3. Exit NeoVim
4. The Bash wrapper detects the change and reopens NeoVim with the new profile automatically

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
2. Remove the symlink from `~/.config/`
3. Unregister the profile from the profile list

You will also be reminded to remove the profile alias from your `~/.bashrc` manually, since the manager does not edit that file.

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
        pyright = {},      -- Python
        ts_ls = {},        -- TypeScript / JavaScript
        rust_analyzer = {}, -- Rust
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
