#!/bin/sh
#
# Bootstrap these dotfiles on a new machine: install chezmoi if it is missing,
# then apply the repo. Safe to re-run; a later run pulls and re-applies.
#
# Usage: install.sh [--zsh]
#   --zsh   Linux only: install zsh and make it the login shell first, so the
#           full zsh config is applied instead of the bash one.
#
# Run it without a clone:
#   curl -fsSL https://raw.githubusercontent.com/igor-sirotin/dotfiles/main/install.sh | sh -s -- --zsh

set -eu

repo=igor-sirotin

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

install_zsh() {
    command -v apt-get >/dev/null 2>&1 || die "--zsh needs apt-get; install zsh and chsh to it by hand"
    as_root apt-get update </dev/null
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends zsh </dev/null
    as_root chsh -s "$(command -v zsh)" "$(id -un)"
}

install_chezmoi_linux() {
    case "$(uname -m)" in
        x86_64) arch=amd64 sha256=$chezmoi_sha256_amd64 ;;
        aarch64 | arm64) arch=arm64 sha256=$chezmoi_sha256_arm64 ;;
        *) die "no pinned chezmoi build for $(uname -m)" ;;
    esac
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp/chezmoi.tar.gz" \
        "https://github.com/twpayne/chezmoi/releases/download/v$chezmoi_version/chezmoi_${chezmoi_version}_linux_$arch.tar.gz"
    echo "$sha256  $tmp/chezmoi.tar.gz" | sha256sum -c - >/dev/null
    tar -xzf "$tmp/chezmoi.tar.gz" -C "$tmp" chezmoi
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$tmp/chezmoi" "$HOME/.local/bin/chezmoi"
}

# The whole script is wrapped in a function so that `curl | sh` has read all of
# it before anything runs.
main() {
    want_zsh=0
    for arg in "$@"; do
        case "$arg" in
            --zsh) want_zsh=1 ;;
            -h | --help)
                usage
                exit 0
                ;;
            *) die "unknown argument '$arg' (usage: install.sh [--zsh])" ;;
        esac
    done

    os=$(uname -s)
    if [ "$want_zsh" = 1 ] && [ "$os" = Linux ]; then
        install_zsh
    fi

    PATH="$HOME/.local/bin:$PATH"
    if ! command -v chezmoi >/dev/null 2>&1; then
        case "$os" in
            Linux) install_chezmoi_linux ;;
            Darwin)
                command -v brew >/dev/null 2>&1 || die "install Homebrew first: https://brew.sh"
                brew install chezmoi </dev/null
                ;;
            *) die "unsupported system '$os'" ;;
        esac
    fi

    if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi/.git" ]; then
        chezmoi update --init </dev/null
    else
        chezmoi init --apply "$repo" </dev/null
    fi

    if [ "$want_zsh" = 1 ] && [ "$os" = Linux ]; then
        echo "install.sh: zsh is now the login shell; log out and back in to use it"
    fi
}

main "$@"
