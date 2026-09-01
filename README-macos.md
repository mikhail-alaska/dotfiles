# macOS setup

This branch adds an Apple Silicon macOS layer without removing or renaming the
existing Arch Linux packages. GNU Stow packages remain independent, so the
Linux machine can keep stowing `hypr`, `waybar`, `wofi`, and the other Linux
packages while macOS stows only the shared and macOS-specific packages.

## Layout

- Shared: `zsh`, `starship`, `kitty`, `nvim`, `tmux`, `git`, `ssh`, `scripts`.
- macOS: `yabai`, `skhd`, `sketchybar`, `borders`, `launchd`, `openvpn`.
- Linux-only and unchanged: `hypr`, `waybar`, `wofi`, `ags`, `gtk`, `Thunar`.
- Packages and applications: `Brewfile`.
- Entry point: `bootstrap-macos.sh`.

No private key, embedded-key OpenVPN profile, machine-specific SSH host list,
`known_hosts`, or Codex/GitHub authentication state belongs in this repository.
The bootstrap creates private directories before Stow runs so those directories
cannot accidentally become symlinks into the worktree.

## Install

Clone or add this branch as a worktree, then run:

```sh
cd ~/dotfiles-macos
./bootstrap-macos.sh
```

The bootstrap is limited to Apple Silicon macOS. It downloads the official
Homebrew installer from a commit-pinned `raw.githubusercontent.com` URL and
checks all three of the following before execution:

1. The URL is exactly the reviewed Homebrew organization/repository path and
   remains unchanged after HTTPS redirects.
2. TLS, HTTP status, and the pinned SHA-256 digest all pass.
3. Bash syntax and Homebrew identity/prefix markers match the reviewed script.

It first installs GNU Stow and performs a non-mutating conflict check, then
installs `Brewfile`, stows only the packages listed above, installs TPM,
optionally imports private material from Archpad, optionally enables Touch ID
for `sudo`, applies small macOS defaults, and starts the window-management
services. The two external Homebrew taps are trusted only for the named Yabai,
skhd, SketchyBar, and JankyBorders formulae, not as whole repositories.

Touch ID is installed through Apple's `/etc/pam.d/sudo_local` mechanism. The
script checks Apple's template and PAM module first, backs up an existing file,
and retains the normal password rule as a fallback. PAM and `/etc/hosts`
backups are stored with mode 0600 under
`~/.local/share/dotfiles-private/backups`, not in system configuration folders.

## Keyboard workflow

Hyprland `SUPER` maps to macOS Option/Alt:

| Action | Binding |
| --- | --- |
| Focus west/south/north/east | `Option+H/J/K/L` |
| Swap west/south/north/east | `Option+Shift+H/J/K/L` |
| Focus Space 1–10 | `Option+1…0` |
| Move window to Space 1–10 and follow | `Option+Shift+1…0` |
| Toggle float | `Option+V` |
| Close window | `Option+Q` |
| Kitty | `Option+Return` |
| Spotlight | `Option+R` |
| Mission Control | `Option+G` |
| Lock screen | `Option+X` |

Yabai uses BSP layout, five-pixel outer/inner gaps, floating rules for system
dialogs, and focus-follows-mouse. SketchyBar mirrors the useful Waybar status:
Spaces, focused application, volume, Wi-Fi, battery, and clock. The bootstrap
also disables automatic Space reordering and hides the native menu bar so the
numeric workspace mapping and SketchyBar position stay stable.

With SIP enabled, create ten Desktops once in Mission Control and enable the
native Control+1…0 Mission Control shortcuts. The focus helper uses Yabai first
and those native shortcuts as its fallback. This branch does not install the
Yabai scripting addition, add Yabai to sudoers, or alter SIP.

## SSH and private migration

The public SSH config defines:

```sshconfig
Host archpad
    HostName 192.168.0.22
    User alaska
```

`migrate-from-archpad` performs the private part interactively:

1. Generates new, passphrase-capable Ed25519 keys on the Mac. Old private keys
   are never copied from Linux.
2. Reads Archpad's host key and refuses to connect unless its SHA-256 fingerprint
   matches the value audited on the current ThinkPad.
3. Installs only the Mac's `archpad_ed25519.pub` on Archpad and verifies key login.
4. Uses SCP over that verified connection to copy the embedded-key OpenVPN
   profile, host-specific SSH config, and selected custom `/etc/hosts` entries.
   The SSH config is accepted only when every directive is on a narrow,
   non-executable allowlist.
5. Stores them outside Git under `~/.local/share/dotfiles-private` and
   `~/.ssh/private.d`, with restrictive modes.
6. Offers to authorize the newly generated public keys on `vpn-spb`, `vpn-ger`,
   and `archpc` through Archpad. Only public keys traverse this step.

The imported `/etc/hosts` entries are placed in a marked block, and the previous
file is backed up before replacement. The copied OpenVPN profile is consumed by
`run-openvpn-split`, which requires `route-nopull`, rejects command hooks,
plugins, and indirect config loading, and leaves Linux policy-routing logic on
the Linux machine. It skips VPN startup only when both the pinned-key SSH check
to Archpad and the ArchPC health check succeed; an unauthenticated HTTP response
alone is not treated as proof of the home network. No NOPASSWD rule is created
for this user-writable launcher.

To re-run only the private migration later:

```sh
~/.local/bin/migrate-from-archpad
```

To start the split OpenVPN profile:

```sh
run-openvpn-split
```

To wake ArchPC while the Mac is connected to the home LAN:

```sh
wake-archpc
```

By default the command sends six Wake-on-LAN bursts to the local broadcast on
UDP ports 9 and 7, two seconds apart. Tune this with `--bursts` and `--interval`.
The source command's `--raw-interface` fallback relies on Linux `AF_PACKET` and
is intentionally rejected on macOS, where the command uses UDP broadcast.
Direct Wake-on-LAN broadcast forwarding through the router's OpenVPN connection
is not assumed; use a permanently online LAN host as a relay for reliable
wake-up from outside the home network.

## Post-install checks

- Approve Yabai, skhd, and Kitty/Terminal in Privacy & Security → Accessibility.
- Confirm ten Spaces and the Option-based bindings above.
- Press `prefix + I` in tmux if TPM plugins have not yet installed.
- Run `gh auth login` and `codex` to create fresh device-local authentication.
- Keep `~/.local/share/dotfiles-private`, `~/.ssh/private.d`, and SSH private keys
  out of backups or repositories that are not explicitly encrypted.
