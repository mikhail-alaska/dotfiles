# Private OpenVPN profile

The working profile embeds certificates and a private key, so it is never
stored in Git or below a stowed directory.

Run `migrate-from-archpad` after `ssh archpad` works. It copies the profile to:

`~/.local/share/dotfiles-private/openvpn/OpenVPN-Config.ovpn`

The macOS launcher is `run-openvpn-split`. It refuses profiles without
`route-nopull` and rejects executable hooks, plugins, additional config files,
and arbitrary OpenVPN command-line arguments before the profile crosses the
sudo boundary. The local-LAN shortcut requires a pinned-key SSH connection to
Archpad before consulting the ArchPC HTTP health endpoint. OpenVPN owns and
cleans up the macOS utun routes.
