# My NeoVim Profiles!

A modular NeoVim configuration with support for multiple isolated profiles, built on top of LazyVim. Each profile has its own plugins and theme while sharing a common core of options, keymaps, and universal plugins.

---

## Table of Contents

- [How it works](#how-it-works)
- [Directory structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Bash configuration](#bash-configuration)
- [Navigating between profiles](#navigating-between-profiles)
- [Available profiles](#available-profiles)
- [Creating a new profile](#creating-a-new-profile)
- [Adding a theme to a profile](#adding-a-theme-to-a-profile)
- [Adding plugins to the core](#adding-plugins-to-the-core)
- [Adding plugins to a profile](#adding-plugins-to-a-profile)

---

## How it works

NeoVim respects the `NVIM_APPNAME` environment variable. When set, it loads the configuration from `~/.config/$NVIM_APPNAME` instead of `~/.config/nvim`. This means each profile is a completely independent configuration directory.

To avoid code duplication, this project uses the following architecture:

```
~/.config/nvim-industrial  →  symlink to  →  profiles/Industrial/
~/.config/nvim-corporate   →  symlink to  →  profiles/Corporate/
...
```

Each profile loads the `core/` directory by adding it to Lua's `package.path` before initializing lazy.nvim. lazy.nvim then imports core plugins via `dofile` with an absolute path, and profile-specific plugins via `{ import = "plugins" }`.

The full startup flow when opening NeoVim:

```
nvim .
  → bash wrapper reads ~/.config/nvim-active-profile
  → opens with NVIM_APPNAME=nvim-industrial
    → profiles/Industrial/init.lua executes
      → core/ is added to package.path
      → require("config.lazy") loads core/lua/config/lazy.lua
        → lazy.nvim loads core/lua/core_plugins/*.lua
        → lazy.nvim loads profiles/Industrial/lua/plugins/*.lua
        → :Profile command is registered via dofile
```

---

## Directory structure

```
nvim/
├── core/                          <- shared nucleus across all profiles
│   ├── init.lua                   <- core entry point (for direct NVIM_APPNAME use)
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua       <- universal autocmds
│       │   ├── keymaps.lua        <- universal keymaps
│       │   ├── lazy.lua           <- lazy.nvim bootstrap + core loading
│       │   └── options.lua        <- universal NeoVim options
│       ├── core_plugins/
│       │   ├── editor.lua         <- universal editor plugins
│       │   ├── neo-tree.lua       <- neo-tree configuration (position, behavior)
│       │   └── ui.lua             <- universal UI plugins (snacks, etc.)
│       └── profile-switcher.lua   <- :Profile command logic
│
├── profiles/
│   ├── Apostate/
│   │   ├── init.lua               <- profile entry point (identical across all profiles)
│   │   └── lua/plugins/
│   │       └── base.lua           <- profile-specific plugins
│   ├── Corporate/
│   ├── Industrial/
│   │   ├── init.lua
│   │   └── lua/plugins/
│   │       ├── base.lua
│   │       └── theme.lua
│   ├── Playground/
│   ├── Scribe/
│   └── Wired/
│
├── scripts/
│   └── install.sh                 <- creates symlinks under ~/.config/
│
├── README.md
└── stylua.toml                    <- Lua formatter configuration
```

---

## Prerequisites

- NeoVim >= 0.9
- Git
- A [Nerd Font](https://www.nerdfonts.com/) installed and configured in your terminal
- `fzf` (optional, for the interactive profile picker in the terminal)

---

## Installation

### 1. Place the repository

The repository should live at `~/.config/nvim/`:

```bash
git clone <repo-url> ~/.config/nvim
```

If the repository is already elsewhere, the symlinks will point to that location.

`install.sh` uses absolute paths.

### 2. Create the symlinks

```bash
bash ~/.config/nvim/scripts/install.sh
```

The script creates the following symlinks under `~/.config/`:

| Symlink | Target |
|---|---|
| `nvim-apostate` | `profiles/Apostate/` |
| `nvim-corporate` | `profiles/Corporate/` |
| `nvim-industrial` | `profiles/Industrial/` |
| `nvim-playground` | `profiles/Playground/` |
| `nvim-scribe` | `profiles/Scribe/` |
| `nvim-wired` | `profiles/Wired/` |

The script is idempotent: it can be run multiple times without side effects.

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
# /\/\/\/\ nvim profile switcher
NVIM_PROFILE_FILE="$HOME/.config/nvim-active-profile"

[ -f "$NVIM_PROFILE_FILE" ] || echo "nvim-apostate" > "$NVIM_PROFILE_FILE"

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

Apostate()   { echo "nvim-apostate"   > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-apostate"   command nvim "$@"; }
Corporate()  { echo "nvim-corporate"  > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-corporate"  command nvim "$@"; }
Industrial() { echo "nvim-industrial" > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-industrial" command nvim "$@"; }
Playground() { echo "nvim-playground" > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-playground" command nvim "$@"; }
Scribe()     { echo "nvim-scribe"     > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-scribe"     command nvim "$@"; }
Wired()      { echo "nvim-wired"      > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-wired"      command nvim "$@"; }

nvim-profile() {
  echo "active profile: $(cat "$NVIM_PROFILE_FILE")"
}
```

Then reload Bash:

```bash
source ~/.bashrc
```

### The `nvim()` wrapper

The `nvim()` function replaces the standard command. It reads the active profile from `~/.config/nvim-active-profile` and passes `NVIM_APPNAME` automatically. The internal loop detects profile switches made from inside the editor and reopens NeoVim with the new profile without any user input.

### Quick-switch functions

The `Apostate`, `Corporate`, `Industrial`, etc. functions let you open directly into a specific profile from the terminal:

```bash
Industrial file.py    # opens file.py in the Industrial profile
Corporate .           # opens the current directory in the Corporate profile
```

When using these functions, the chosen profile is saved as the active one. The next time `nvim` is called without a prefix, it will use that profile.

### Check the active profile

```bash
nvim-profile
# active profile: nvim-industrial
```

---

## Navigating between profiles

### From inside NeoVim

Use the `:Profile` command to open an interactive picker:

```
:Profile
```

A list of all profiles is displayed. The current profile appears marked as `(active)`. When you select a different profile, NeoVim will:

1. Save all open buffers (`silent! wa`)
2. Write the new profile to `~/.config/nvim-active-profile`
3. Exit (`qa!`)
4. The Bash wrapper detects the change and automatically reopens with the new profile

You can also switch directly by passing the profile name as an argument, with tab completion support:

```
:Profile Industrial
:Profile Corporate
```

### From the terminal

```bash
nvim .              # opens in the last active profile
Industrial .        # opens in the Industrial profile and saves it as active
nvim-profile        # shows which profile is currently active
```

---

## Available profiles

| Profile | NVIM_APPNAME | Theme | Purpose |
|---|---|---|---|
| Apostate | `nvim-apostate` | TBD | default |
| Corporate | `nvim-corporate` | TBD | TBD |
| Industrial | `nvim-industrial` | Monokai Pro | TBD |
| Playground | `nvim-playground` | TBD | TBD |
| Scribe | `nvim-scribe` | TBD | TBD |
| Wired | `nvim-wired` | TBD | TBD |

---

## Creating a new profile

The following steps walk through creating a profile called `Phantom`.

### 1. Create the directory structure

```bash
mkdir -p ~/.config/nvim/profiles/Phantom/lua/plugins
```

### 2. Create the profile `init.lua`

Create `profiles/Phantom/init.lua` with the following content. This is identical for every profile:

```lua
local profile_dir = vim.fn.resolve(vim.fn.stdpath("config"))
local repo_root = vim.fn.fnamemodify(profile_dir, ":h:h")
local core_lua = repo_root .. "/core/lua"

package.path = core_lua .. "/?.lua;" .. core_lua .. "/?/init.lua;" .. package.path
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")
```

### 3. Create the plugins file

Create `profiles/Phantom/lua/plugins/base.lua`:

```lua
return {}
```

This file will hold the profile's specific plugins. While empty, it must return an empty table so lazy.nvim does not complain.

### 4. Register the profile in `install.sh`

Edit `scripts/install.sh` and add the entry to the `PROFILES` array:

```bash
declare -A PROFILES=(
  ...
  [Phantom]="nvim-phantom"   # <- add this line
)
```

### 5. Register the profile in the `:Profile` switcher

Edit `core/lua/profile-switcher.lua` and add the profile to the `profiles` table:

```lua
local profiles = {
  ...
  { name = "Phantom", appname = "nvim-phantom" },  -- <- add this line
}
```

### 6. Add the alias to `~/.bashrc`

```bash
Phantom() { echo "nvim-phantom" > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="nvim-phantom" command nvim "$@"; }
```

Reload: `source ~/.bashrc`

### 7. Create the symlink

```bash
bash ~/.config/nvim/scripts/install.sh
```

The script will create `~/.config/nvim-phantom` pointing to `profiles/Phantom/`.

### 8. Test

```bash
Phantom .
```

---

## Adding a theme to a profile

Themes are isolated per profile. The example below uses Monokai Pro, which is configured in the Industrial profile.

### 1. Create the theme file

Create `profiles/<Profile>/lua/plugins/theme.lua`. Always use a dedicated file for the theme, separate from `base.lua`:

```lua
return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,        -- load before other plugins
    opts = {
      filter = "pro",       -- variants: pro, classic, octagon, machine, ristretto, spectrum
      transparent_background = false,
      terminal_colors = true,
      devicons = true,
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
        type = { italic = true },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-pro",  -- sets it as the active LazyVim colorscheme
    },
  },
}
```

### 2. Swapping for a different theme

Any theme from [lazy.nvim extras](https://lazyvim.org/extras/ui) or [awesome-neovim](https://github.com/rockerBOO/awesome-neovim) can be used. Just replace the repository, plugin name, and colorscheme:

```lua
-- example with Catppuccin
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",    -- latte, frappe, macchiato, mocha
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
```

### 3. Install

On the next launch of the profile, lazy.nvim will install the theme automatically.

---

## Adding plugins to the core

Plugins added to the core are available across all profiles. Edit or create files under `core/lua/core_plugins/`.

Example: adding `nvim-surround` to the core:

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

No additional configuration is needed. `lazy.lua` loads all files from `core_plugins/` automatically via `load_core_specs()`.

---

## Adding plugins to a profile

Profile-specific plugins live in `profiles/<Profile>/lua/plugins/`. They can be spread across as many files as needed.

Example: adding `pyright` to the Apostate profile:

```lua
-- profiles/Apostate/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
      },
    },
  },
}
```

lazy.nvim imports all `.lua` files from `profiles/<Profile>/lua/plugins/` automatically via `{ import = "plugins" }`.



