# Dotfiles

My personal configuration files managed with GNU Stow.

## Structure

```
dotfiles/
├── i3/          # i3 window manager config
├── nvim/        # Neovim configuration
├── polybar/     # Polybar status bar config
├── rofi/        # Rofi application launcher
└── wezterm/     # WezTerm terminal emulator
```

## Quick Start

### Install Dotfiles on a New Machine

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Install all configs at once
stow */

# Or install specific configs
stow nvim rofi i3 polybar wezterm
```

### Uninstall Configs

```bash
cd ~/dotfiles

# Uninstall all
stow -D */

# Uninstall specific
stow -D nvim rofi
```

## Managing Configs

### Add a New Config Package

```bash
# Example: adding tmux config
cd ~/dotfiles
mkdir -p tmux/.config/tmux

# Copy your existing config
cp ~/.config/tmux/tmux.conf tmux/.config/tmux/

# Remove original and stow
rm -rf ~/.config/tmux
stow tmux
```

### Update Configs

Just edit files directly in `~/dotfiles/package-name/` - changes apply immediately since they're symlinked!

### Restow After Changes

If you add new files to a package:

```bash
cd ~/dotfiles
stow -R package-name  # -R restows (unlinks then relinks)
```

## Current Configs

### i3
- **Location**: `~/.config/i3/config`
- **Keybindings**:
  - `Mod4 + Space`: Rofi launcher
  - `Alt + Enter`: WezTerm terminal
  - `Alt + h/j/k/l`: Navigate windows (vim-style)

### Rofi
- **Location**: `~/.config/rofi/`
- **Features**:
  - Simple app launcher (drun mode)
  - Custom Catppuccin-inspired theme
  - Fuzzy matching enabled
  - Icon support with Papirus theme

### Polybar
- **Location**: `~/.config/polybar/`
- **Launch**: `~/.config/polybar/launch.sh`

### Neovim
- **Location**: `~/.config/nvim/`

### WezTerm
- **Location**: `~/.wezterm.lua`

## Troubleshooting

### Stow conflicts
If stow complains about existing files:

```bash
# Backup existing config
mv ~/.config/package-name ~/.config/package-name.backup

# Then stow
cd ~/dotfiles && stow package-name
```

### Broken symlinks
```bash
# Find broken symlinks
find ~/.config -xtype l

# Restow everything
cd ~/dotfiles && stow -R */
```

## Tips

- Always work in `~/dotfiles/` to keep changes version controlled
- Use `stow -n package` to simulate (dry-run) before applying
- Use `stow -v package` for verbose output
- Commit and push changes regularly to back them up

## Dependencies

- **GNU Stow**: `sudo dnf install stow` (Fedora)
- **i3**: Window manager
- **Rofi**: Application launcher
- **Polybar**: Status bar
- **WezTerm**: Terminal emulator
- **Neovim**: Text editor
