# Private OpenVPN profile

The working profile embeds certificates and a private key, so it is never
stored in Git or below a stowed directory.

Run `migrate-from-archpad` after `ssh archpad` works. It copies the profile to:

`~/.local/share/dotfiles-private/openvpn/OpenVPN-Config.ovpn`

The macOS launcher is `run-openvpn-split`. It refuses profiles without
`route-nopull`, keeps the local-LAN health check, and lets OpenVPN own and clean
up the macOS utun routes.
