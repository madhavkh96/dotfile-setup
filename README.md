# Dotfile Setup

A modern Neovim configuration setup featuring the "Valerian" configuration theme with lazy loading plugin management.

## Overview

This repository contains a comprehensive Neovim configuration that provides a modern development environment with carefully curated plugins and optimized settings.

## Structure

```
nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
└── lua/valerian/           # Core configuration module
    ├── core/               # Core Neovim settings
    │   ├── init.lua       # Core module loader
    │   ├── keymaps.lua    # Key mappings
    │   └── options.lua    # Neovim options
    ├── lazy.lua           # Lazy.nvim plugin manager setup
    └── plugins/           # Plugin configurations
        ├── bufferline.lua
        ├── colors.lua
        ├── comment.lua
        ├── conform.lua
        ├── dressing.lua
        ├── init.lua
        ├── lsp/           # LSP configurations
        │   ├── lspconfig.lua
        │   └── mason.lua
        ├── lualine.lua
        ├── nvim-cmp.lua
        ├── nvim-tree.lua
        ├── startify.lua
        ├── telescope.lua
        ├── venv-selector.lua
        └── vim-maximizer.lua
```

## Features

- **Lazy Loading**: Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for efficient plugin management
- **LSP Support**: Full Language Server Protocol integration with Mason
- **File Navigation**: Telescope fuzzy finder and nvim-tree file explorer
- **Code Completion**: Advanced completion with nvim-cmp
- **Status Line**: Beautiful status line with lualine
- **Buffer Management**: Enhanced buffer navigation with bufferline
- **Python Support**: Virtual environment selection for Python development
- **Code Formatting**: Automatic code formatting with conform.nvim
- **UI Enhancements**: Improved UI with dressing.nvim

## Installation

1. **Backup existing Neovim configuration**:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this repository**:
   ```bash
   git clone <repository-url> ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```

   Lazy.nvim will automatically install all plugins on first launch.

## Key Features

### Plugin Management
- Uses lazy.nvim for fast startup and automatic plugin management
- Automatic plugin updates with health checking
- Version locking via `lazy-lock.json`

### Leader Key
- **Leader**: `<Space>`
- **Local Leader**: `\`

### LSP Integration
- Mason for automatic LSP server installation
- Full LSP features: diagnostics, code actions, hover, etc.
- Language-specific configurations

### File Navigation
- **Telescope**: Fuzzy finder for files, buffers, and more
- **nvim-tree**: File explorer sidebar

### Development Tools
- **Comment.nvim**: Easy code commenting
- **vim-maximizer**: Window maximization
- **venv-selector**: Python virtual environment management

## Customization

The configuration is modular and easy to customize:

1. **Core settings**: Modify files in `lua/valerian/core/`
2. **Plugin configs**: Add/modify files in `lua/valerian/plugins/`
3. **LSP settings**: Customize `lua/valerian/plugins/lsp/`

## Requirements

- Neovim 0.8+ (recommended: latest stable)
- Git (for plugin management)
- A Nerd Font (for icons)
- ripgrep (for Telescope)
- Node.js (for some LSP servers)

## Troubleshooting

If you encounter issues:

1. Check Neovim version: `:version`
2. Check plugin status: `:Lazy`
3. Check LSP status: `:LspInfo`
4. Check Mason installations: `:Mason`

## Contributing

Feel free to customize this configuration to your needs. The modular structure makes it easy to add or remove plugins and modify settings.