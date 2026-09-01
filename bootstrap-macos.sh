#!/usr/bin/env bash
set -Eeuo pipefail

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly BREW_PREFIX="/opt/homebrew"
readonly HOMEBREW_INSTALL_COMMIT="26f8b07461e85fad16afd83797ad5846fae7a471"
readonly HOMEBREW_INSTALL_SHA256="12479a24be3f5307eecac7cde670fad7118640f031229e964f544b1367b52a41"
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALL_COMMIT}/install.sh"

info() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

prompt_yes_no() {
    local prompt="$1"
    local reply
    read -r -p "${prompt} [y/N] " reply
    [[ "$reply" == "y" || "$reply" == "Y" ]]
}

verify_platform() {
    [[ "$(uname -s)" == "Darwin" ]] || die "This bootstrap only supports macOS"
    [[ "$(uname -m)" == "arm64" ]] || die "This bootstrap is pinned to Apple Silicon"
}

install_homebrew() {
    local temporary_dir installer metadata effective_url http_code
    if [[ -x "${BREW_PREFIX}/bin/brew" ]]; then
        eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
        info "Homebrew is already installed"
        return
    fi

    temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/homebrew-installer.XXXXXX")"
    installer="${temporary_dir}/install.sh"
    trap 'rm -rf "$temporary_dir"' RETURN

    # Check 1: only the reviewed, commit-pinned HTTPS URL is accepted.
    [[ "$HOMEBREW_INSTALL_URL" == \
        "https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALL_COMMIT}/install.sh" ]] || \
        die "Unexpected Homebrew installer URL"

    info "Downloading the reviewed Homebrew installer"
    # Check 2: curl verifies TLS; redirects are accepted only if the effective
    # URL remains the exact pinned raw.githubusercontent.com URL.
    metadata="$(curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
        --output "$installer" --write-out '%{url_effective}\n%{http_code}\n' \
        "$HOMEBREW_INSTALL_URL")"
    effective_url="$(printf '%s\n' "$metadata" | sed -n '1p')"
    http_code="$(printf '%s\n' "$metadata" | sed -n '2p')"
    [[ "$effective_url" == "$HOMEBREW_INSTALL_URL" ]] || die "Homebrew installer redirected to ${effective_url}"
    [[ "$http_code" == "200" ]] || die "Homebrew installer returned HTTP ${http_code}"

    # Check 3: verify the reviewed bytes, shell syntax, and installer identity.
    printf '%s  %s\n' "$HOMEBREW_INSTALL_SHA256" "$installer" | shasum -a 256 -c -
    /bin/bash -n "$installer"
    grep -q 'HOMEBREW_BREW_DEFAULT_GIT_REMOTE="https://github.com/Homebrew/brew"' "$installer" || \
        die "Homebrew installer identity marker is missing"
    grep -q 'HOMEBREW_PREFIX="/opt/homebrew"' "$installer" || \
        die "Apple Silicon Homebrew prefix marker is missing"

    info "Running verified Homebrew installer ${HOMEBREW_INSTALL_COMMIT}"
    /bin/bash "$installer"
    [[ -x "${BREW_PREFIX}/bin/brew" ]] || die "Homebrew installation did not create ${BREW_PREFIX}/bin/brew"
    eval "$("${BREW_PREFIX}/bin/brew" shellenv)"

    trap - RETURN
    rm -rf "$temporary_dir"
}

install_packages() {
    info "Installing packages and applications from Brewfile"
    brew update
    brew bundle install --file="${DOTFILES_DIR}/Brewfile"
}

prepare_private_directories() {
    install -d -m 700 \
        "${HOME}/.ssh" \
        "${HOME}/.ssh/private.d" \
        "${HOME}/.config" \
        "${HOME}/.local" \
        "${HOME}/.local/bin" \
        "${HOME}/.local/share" \
        "${HOME}/.local/share/dotfiles-private" \
        "${HOME}/Library" \
        "${HOME}/Library/LaunchAgents"
}

stow_dotfiles() {
    local packages
    packages=(zsh starship kitty nvim tmux git ssh scripts openvpn yabai skhd sketchybar borders launchd)
    info "Stowing macOS and shared packages"
    stow --restow --dir="$DOTFILES_DIR" --target="$HOME" "${packages[@]}"
}

install_tpm() {
    local tpm_dir="${HOME}/.tmux/plugins/tpm"
    if [[ ! -d "${tpm_dir}/.git" ]]; then
        info "Installing tmux plugin manager"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
}

enable_touch_id_sudo() {
    local target="/etc/pam.d/sudo_local"
    local template="/etc/pam.d/sudo_local.template"
    local pam_module="/usr/lib/pam/pam_tid.so.2"
    local temporary_file backup

    [[ -e "$pam_module" ]] || { warn "Touch ID PAM module is unavailable; skipping"; return; }
    [[ -r "$template" ]] || { warn "Apple sudo_local.template is unavailable; skipping"; return; }
    grep -Eq '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_opendirectory\.so' /etc/pam.d/sudo || {
        warn "Password fallback was not recognized in /etc/pam.d/sudo; refusing to edit PAM"
        return
    }

    if sudo grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]|$)' "$target" 2>/dev/null; then
        info "Touch ID for sudo is already enabled"
        return
    fi

    grep -Eq '^#[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]|$)' "$template" || {
        warn "Apple Touch ID template has an unexpected format; refusing to edit PAM"
        return
    }

    sudo -v
    temporary_file="$(mktemp "${TMPDIR:-/tmp}/sudo_local.XXXXXX")"
    if sudo test -r "$target"; then
        sudo cat "$target" >"$temporary_file"
        backup="${target}.dotfiles-backup.$(date +%Y%m%d%H%M%S)"
        sudo cp "$target" "$backup"
    else
        cp "$template" "$temporary_file"
        backup="not-needed"
    fi

    if grep -Eq '^#[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]|$)' "$temporary_file"; then
        sed -E 's/^#[[:space:]]*(auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so.*)$/\1/' \
            "$temporary_file" >"${temporary_file}.new"
        mv "${temporary_file}.new" "$temporary_file"
    else
        printf '%s\n' 'auth       sufficient     pam_tid.so' >>"$temporary_file"
    fi

    sudo install -o root -g wheel -m 0444 "$temporary_file" "$target"
    rm -f "$temporary_file"
    sudo grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]|$)' "$target" || \
        die "Touch ID PAM rule failed post-install verification"
    info "Touch ID for sudo enabled; password fallback remains active (backup: ${backup})"
}

configure_macos_defaults() {
    info "Applying small keyboard-driven macOS defaults"
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock expose-animation-duration -float 0.12
    defaults write com.apple.dock mru-spaces -bool false
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write NSGlobalDomain _HIHideMenuBar -bool true
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    killall Dock >/dev/null 2>&1 || true
    killall SystemUIServer >/dev/null 2>&1 || true
}

start_services() {
    info "Starting window-management services"
    yabai --start-service || warn "yabai service needs Accessibility approval"
    skhd --start-service || warn "skhd service needs Accessibility approval"
    brew services restart sketchybar
    brew services restart borders

    launchctl bootout "gui/${UID}/com.alaska.macos-session" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/${UID}" "${HOME}/Library/LaunchAgents/com.alaska.macos-session.plist" || \
        warn "Could not bootstrap the login session agent"
}

print_manual_steps() {
    cat <<'EOF'

Manual steps that macOS intentionally does not allow this script to bypass:
  1. Privacy & Security → Accessibility: enable yabai, skhd, and Kitty/Terminal.
  2. Create ten Desktops in Mission Control.
  3. Keyboard → Keyboard Shortcuts → Mission Control: enable Control+1…0.
  4. Run `codex` and `gh auth login` for fresh, device-local authentication.
  5. Test: Option+H/J/K/L, Option+Shift+H/J/K/L, Option+1…0.

SIP has not been changed and no yabai scripting addition was installed.
EOF
    open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility' >/dev/null 2>&1 || true
}

verify_platform
install_homebrew
install_packages
prepare_private_directories
stow_dotfiles
install_tpm

if prompt_yes_no "Generate Mac SSH keys, authorize archpad, and import private material via SCP?"; then
    "${HOME}/.local/bin/migrate-from-archpad"
else
    warn "Private SSH hosts, /etc/hosts entries, and the OpenVPN profile were not imported"
fi

if prompt_yes_no "Enable Touch ID for sudo using Apple's sudo_local template?"; then
    enable_touch_id_sudo
fi

configure_macos_defaults
start_services
print_manual_steps
