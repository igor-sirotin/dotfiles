#!/bin/sh
#
# Bootstrap these dotfiles on a new machine: install chezmoi if it is missing,
# then apply the repo. A later run pulls and re-applies; chezmoi asks before it
# overwrites a file edited on the machine, which needs a terminal.
#
# Run it without a clone (see usage below for the options):
#   curl -fsSL https://raw.githubusercontent.com/igor-sirotin/dotfiles/main/install.sh | sh -s -- --zsh

set -eu

owner=igor-sirotin

# To bump: https://github.com/twpayne/chezmoi/releases, chezmoi_<ver>_checksums.txt
chezmoi_version=2.74.1
chezmoi_sha256_amd64=ae01c66b1a6dbf563667c63fbbd9986b3cfa3c98dd266ddee732f63e8af2e9d1
chezmoi_sha256_arm64=8c62619c4303770342e7c7e75d168b6cc6efee4ad5e4b994980de7cf794d68e2

usage() {
    cat <<'EOF'
Usage: install.sh [--zsh]
  --zsh   Linux only: install zsh and make it the login shell first, so the
          full zsh config is applied instead of the bash one.
EOF
}

die() {
    echo "install.sh: $*" >&2
    exit 1
}

as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

install_chezmoi_linux() {
    case "$(uname -m)" in
        x86_64) arch=amd64 sha256=$chezmoi_sha256_amd64 ;;
        aarch64 | arm64) arch=arm64 sha256=$chezmoi_sha256_arm64 ;;
        *) die "no pinned chezmoi build for $(uname -m); install chezmoi by hand and re-run" ;;
    esac
    command -v curl >/dev/null 2>&1 || die "curl is needed to download chezmoi"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp/chezmoi.tar.gz" \
        "https://github.com/twpayne/chezmoi/releases/download/v$chezmoi_version/chezmoi_${chezmoi_version}_linux_$arch.tar.gz"
    echo "$sha256  $tmp/chezmoi.tar.gz" | sha256sum -c - >/dev/null
    tar -xzf "$tmp/chezmoi.tar.gz" -C "$tmp" chezmoi
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$tmp/chezmoi" "$HOME/.local/bin/chezmoi"
}

install_chezmoi_darwin() {
    for dir in /opt/homebrew/bin /usr/local/bin; do
        if [ -x "$dir/brew" ]; then
            PATH="$dir:$PATH"
        fi
    done
    command -v brew >/dev/null 2>&1 || die "install Homebrew first: https://brew.sh"
    brew install chezmoi </dev/null
}

use_zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        command -v apt-get >/dev/null 2>&1 || die "--zsh needs apt-get; install zsh by hand and re-run"
        as_root apt-get update </dev/null
        as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends zsh </dev/null
    fi
    zsh_path=$(command -v zsh) || die "zsh is still not on PATH"
    user=$(id -un)
    case "$(getent passwd "$user" 2>/dev/null || true)" in
        *:"$zsh_path") ;;
        *)
            as_root chsh -s "$zsh_path" "$user"
            echo "install.sh: zsh is now the login shell; log out and back in to use it"
            ;;
    esac
}

apply_dotfiles() {
    tree=$(chezmoi execute-template '{{ .chezmoi.workingTree }}' </dev/null 2>/dev/null || true)
    if [ -n "$tree" ] && [ -e "$tree/.git" ]; then
        origin=$(git -C "$tree" config --get remote.origin.url 2>/dev/null || true)
        case "${origin%.git}" in
            */"$owner"/dotfiles | *:"$owner"/dotfiles) ;;
            *) die "$tree already holds another repo (origin: ${origin:-none}); move it away and re-run" ;;
        esac
        chezmoi update --init </dev/null
    else
        chezmoi init --apply "$owner" </dev/null
    fi
}

# Wrapped in a function so `curl | sh` reads it all before running.
main() {
    want_zsh=0
    for arg in "$@"; do
        case "$arg" in
            --zsh) want_zsh=1 ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                exit 2
                ;;
        esac
    done

    os=$(uname -s)
    PATH="$HOME/.local/bin:$PATH"
    if ! command -v chezmoi >/dev/null 2>&1; then
        case "$os" in
            Linux) install_chezmoi_linux ;;
            Darwin) install_chezmoi_darwin ;;
            *) die "unsupported system '$os'" ;;
        esac
    fi

    if [ "$want_zsh" = 1 ] && [ "$os" = Linux ]; then
        use_zsh
    fi

    apply_dotfiles
}

main "$@"
