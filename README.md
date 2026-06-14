# Minimalist Neovim

A minimal, intentional Neovim configuration that just works. Windows-first (PowerShell, GCC) with cross-platform support for macOS and Linux. Built around [lazy.nvim](https://github.com/folke/lazy.nvim), Neovim 0.11+, and a small set of well-chosen plugins.

**Minimal. Intentional. Fast.**

## Features

- **Lazy-loaded plugins** — fast startup; only load what you need
- **LSP + Mason** — language servers and formatters auto-installed from a single declarative config
- **Telescope** — fuzzy find files, live grep, buffers, LSP references, and more
- **Harpoon** — pin and jump between your most-used files
- **Koda theme** — dark/light variants with transparent background and OS theme sync
- **Treesitter** — syntax highlighting and indentation for common languages
- **blink.cmp** — fast LSP-first completion
- **conform.nvim** — format-on-save with per-language formatters
- **nvim-tree** — file explorer (replaces netrw)
- **Floating terminal** — OS-aware shell (pwsh on Windows, zsh/bash on Unix)
- **Quality-of-life defaults** — relative line numbers, clipboard sync, persistent undo, yank highlight, cursor restore, trailing whitespace trim

## Requirements

| Tool | Purpose |
|------|---------|
| [Neovim](https://neovim.io/) **0.11+** | Editor (0.12 features used when available) |
| [Git](https://git-scm.com/) | Plugin management |
| [GCC](https://gcc.gnu.org/) (Windows) or **clang/gcc** (Unix) | Treesitter parser compilation |
| [Nerd Font](https://www.nerdfonts.com/) | Icons in dashboard, lualine, nvim-tree |

**Optional but recommended:** [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) for Telescope live grep.

On first launch, Mason installs language servers and formatters automatically based on the languages configured in `init.lua`.

## Installation

### Windows

```powershell
# Back up existing config (if any)
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak -ErrorAction SilentlyContinue

# Clone this repo
git clone https://github.com/yoshithraajaalla/minimalist_neovim.git $env:LOCALAPPDATA\nvim

# Open Neovim — lazy.nvim bootstraps on first run
nvim
```

Inside Neovim, run `:Lazy sync` to install all plugins, then restart.

### macOS / Linux

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
git clone https://github.com/yoshithraajaalla/minimalist_neovim.git ~/.config/nvim
nvim
```

Then run `:Lazy sync` and restart.

## Project Structure

```
nvim/
├── init.lua                 # Entry point: bootstrap, theme, languages, autocmds
├── lazy-lock.json           # Pinned plugin versions
└── lua/yoshith/
    ├── core/
    │   ├── env.lua          # OS detection, shell selection, Windows quirks
    │   ├── keymaps.lua      # Global keymaps
    │   ├── language.lua     # LSP, Mason, and conform setup
    │   ├── options.lua      # Pure Vim options (no plugin config)
    │   └── theme.lua        # Koda theme cycling, OS sync, :Theme commands
    ├── plugins/             # One file per plugin (auto-imported by lazy.nvim)
    └── tools/
        └── terminal.lua     # Floating terminal toggle
```

## Plugins

| Plugin | Role |
|--------|------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [koda.nvim](https://github.com/oskarnurm/koda.nvim) | Colorscheme |
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | Startup dashboard |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP + tool installer |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [harpoon](https://github.com/ThePrimeagen/harpoon) | File marks |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File tree |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter signs |
| [comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-pair brackets |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | Markdown preview |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Smooth cursor |
| [cinnamon.nvim](https://github.com/declancm/cinnamon.nvim) | Smooth scrolling |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Lua LSP library hints |

## Language Support

Configured in `init.lua` via `require("yoshith.core.language").setup({ ... })`:

| Language | LSP | Formatters | Tools |
|----------|-----|------------|-------|
| Python | pyright | black | isort |
| Go | gopls | gofmt | — |
| Lua | lua_ls | stylua | — |
| JSON | jsonls | prettier | — |
| YAML | yamlls | prettier | — |
| Rust | rust_analyzer | — | — |

Format-on-save is enabled (2s timeout). Use `<leader>w` to format and save manually, or `<leader>lf` in LSP buffers.

To add a language, add an entry to the `language.setup()` table in `init.lua` and restart (Mason will install the new tools).

## Keymaps

Leader key is **Space**.

### General

| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlights |
| `<leader>w` | Format and save |
| `<leader>W` | Save without formatting |
| `<leader>q` / `<leader>Q` | Quit / force quit |
| `<leader>rc` | Edit `init.lua` |
| `<leader>/` | Search current buffer |
| `<leader>cc` | Copy entire file |
| `<leader>d` / `<leader>dd` | Cut (delete with yank) |
| `d` / `dd` / `dw` … | Delete without yank |
| `<leader>p` (visual) | Paste without yank |
| `<leader>t` | Toggle floating terminal |
| `<leader>T` | Cycle theme |
| `<leader>R` | Restart Neovim (0.12+) |

### Windows & Buffers

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-Up/Down/Left/Right>` | Resize splits |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Delete buffer |

### Telescope

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |

### Harpoon

| Key | Action |
|-----|--------|
| `<leader>a` | Add current file |
| `<C-e>` | Open Harpoon menu |
| `<leader>1`–`<leader>4` | Jump to mark 1–4 |

### File Tree

| Key | Action |
|-----|--------|
| `<C-n>` | Toggle nvim-tree |

### LSP (buffer-local)

| Key | Action |
|-----|--------|
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `gt` | Implementations / type definitions (Telescope) |
| `gR` | References (Telescope) |
| `K` | Hover documentation |
| `<C-s>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | Format buffer |
| `<leader>l` | Show line diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>ci` / `<leader>co` | Incoming / outgoing calls |

### Git (buffer-local, via gitsigns)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / previous hunk |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this file |

### Markdown (buffer-local)

| Key | Action |
|-----|--------|
| `<leader>mv` | Toggle markview |
| `<leader>mp` | Split preview |

Press `?` on the dashboard or run `:Telescope keymaps` to browse all mappings.

## Theme

Two schemes: **koda-dark** and **koda-light**, with transparent background.

| Command | Action |
|---------|--------|
| `:Theme` | Pick a theme |
| `:Theme koda-dark` | Set theme directly |
| `:ThemeNext` / `:ThemePrev` | Cycle themes |
| `<leader>T` | Cycle theme (same as ThemeNext) |

By default, the theme syncs with your OS light/dark setting (Windows registry, macOS `defaults`, Linux gsettings/dbus). Disable with:

```lua
require("yoshith.core.theme").setup({ sync_with_os = false })
```

## Customization

- **Options** — edit `lua/yoshith/core/options.lua`
- **Keymaps** — edit `lua/yoshith/core/keymaps.lua`
- **Languages** — edit the `language.setup()` block in `init.lua`
- **Plugins** — add or modify files under `lua/yoshith/plugins/`
- **Theme** — edit `lua/yoshith/core/theme.lua`

After changes to `init.lua` or plugin files, run `:Lazy reload` or restart Neovim. On Neovim 0.12+, `<leader>R` restarts in place.

## License

[MIT](LICENSE) — Copyright (c) 2026 Yoshith Raaj Aalla
