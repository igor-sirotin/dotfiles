# Homebrew's prefix is fixed per platform, so resolve it once here rather than
# shelling out to `brew --prefix` from every file that needs it. `brew` is a
# script, not a binary, and this path runs on every single shell startup.
if [ -d /opt/homebrew ]; then
    export HOMEBREW_PREFIX=/opt/homebrew        # Apple Silicon
elif [ -d /usr/local/Homebrew ]; then
    export HOMEBREW_PREFIX=/usr/local           # Intel
fi

export PATH="$HOME/bin:$PATH"
if [ -n "$HOMEBREW_PREFIX" ]; then
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
fi
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.nimble/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/logoscore/bin:$PATH"
export PATH="$HOME/.local/lgpm/bin:$PATH"
export PATH="$HOME/.local/lgpd/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
