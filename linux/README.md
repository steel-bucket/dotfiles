# Linux dotfiles

Detected target system:

- Linux Mint 22.3 "zena"
- Cinnamon 6.6.7 on X11
- Shell: bash installed as login shell
- Cinnamon native tiling/workspace keybindings available
- gTile is not currently installed

This folder mirrors the useful macOS dotfiles without applying anything to the
live home directory.

## Layout

- `wezterm/wezterm.lua` - Linux WezTerm config adapted from the macOS config.
- `cinnamon/keybindings.dconf` - Cinnamon/Muffin workspace and tiling bindings
  that replace the AeroSpace workflow on this machine.
- `gtile/README.md` - notes for using gTile if you install it later.
- `statusbar/status.sh` - small Linux status line helper replacing the
  SketchyBar-only scripts.
- `bash/.bashrc` - Linux Mint flavored shell config with macOS paths, secrets,
  and repo-cloning helpers removed.
- `zed/settings.json`, `waveterm/settings.json`, `gh/config.yml`,
  `gedit/accels`, `configstore/*.json` - app configs copied or adapted where
  they are portable.

## Manual use

Nothing here is linked or loaded automatically.

Example targets:

```sh
mkdir -p ~/.config/wezterm ~/.config/zed ~/.config/waveterm ~/.config/gh
cp linux/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
cp linux/zed/settings.json ~/.config/zed/settings.json
cp linux/waveterm/settings.json ~/.config/waveterm/settings.json
cp linux/gh/config.yml ~/.config/gh/config.yml
```

To apply Cinnamon keybindings manually:

```sh
dconf dump /org/cinnamon/ > /tmp/cinnamon-before-dotfiles.dconf
dconf load / < linux/cinnamon/keybindings.dconf
```

That `dconf load` command changes live Cinnamon settings, so review the file
first.

## AeroSpace replacement

AeroSpace is macOS-only. On this Cinnamon system, the closest no-extra-install
replacement is Muffin's built-in workspace and tiling keybindings:

- `Alt+1..9` switches workspaces.
- `Alt+Shift+1..9` moves the focused window to a workspace.
- `Alt+Shift+h/j/k/l` tiles the focused window left/down/up/right.
- `Ctrl+Alt+Left/Right` keeps Cinnamon's default workspace navigation.

gTile is not installed on this system right now, so this folder does not ship
blind gTile gsettings writes.
