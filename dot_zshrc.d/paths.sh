export PATH="/Users/sirotin/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"
export PATH="/opt/homebrew/sbin/:$PATH"
export PATH="/Users/sirotin/go/bin:$PATH"
export PATH="/Users/sirotin/.nimble/bin:$PATH"
export PATH="/Users/sirotin/.local/bin:$PATH"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
