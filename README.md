# Usage

## Setup on a new machine

Populate the keyring before applying: a secret that is missing aborts the apply
partway through. `chezmoi secret` does not need an initialised source directory,
so this works straight after installing chezmoi — see
[Secrets management](#secrets-management) for the commands.
```
brew install chezmoi
# set every secret first, see "Secrets management" below
chezmoi init --apply --verbose igor-sirotin
```

If you would rather look up the list of secrets from the repo itself, split it
into `chezmoi init igor-sirotin`, then the secrets, then `chezmoi apply`.

## Update dotfiles

After you have made changes to your dotfiles, you can update them with:
```
chezmoi add <file>
chezmoi apply
```

## Shell startup performance

Measure a warm interactive startup:
```
for i in $(seq 1 10); do /usr/bin/time -p zsh -i -c exit; done 2>&1 | awk '/real/{s+=$2; n++} END{print s/n*1000 " ms avg"}'
```

Attribute the time to a specific line — add `zmodload zsh/zprof` as the first
line of `~/.zshrc`, then run `zprof | head -20` in a new shell.

Two known costs, both already mitigated here:

- **`compinit`** is normally the largest single item. `.zshrc` runs the full
  security audit at most once a day and loads the cached `.zcompdump` with `-C`
  the rest of the time. Delete `~/.zcompdump*` after installing something that
  ships completions if they don't show up.
- **Subprocess spawns.** Anything in `.zshrc.d/` that runs a command pays for it
  on every new shell. `brew --prefix` and `vivid generate` were both called on
  each startup; they are now a hardcoded `$HOMEBREW_PREFIX` and a cached file
  (`~/.cache/vivid-lava.ls_colors` — `rm` it to regenerate).

Starship spawns are separate from the above and happen at *prompt render*, not
shell init. If you see:
```
[WARN] - (starship::utils): Executing command "/opt/homebrew/bin/node" timed out.
```
a version module exceeded `command_timeout` in `dot_config/starship.toml`. Check
whether the underlying binary is genuinely slow before raising the cap:
```
for i in 1 2 3; do /usr/bin/time -p node --version; done
```
A cold first run of several hundred ms that drops to ~40ms afterwards is normal
macOS behaviour (page cache + Gatekeeper); a consistently slow one is not.

## Secrets management

`keyring` is used to manage secrets, this corresponds to `keychain` on macOS.
To add/modify a secret, use:
```
chezmoi secret keyring set --service <service> --user <user>
chezmoi apply
```

A missing secret is a hard error — `chezmoi apply` stops at the first one:
```
error calling keyring: status-proxy USER: secret not found in keyring
```
So on a new machine, set every secret the templates reference before the first
apply. To carry them over from an existing machine:
```
scripts/export-secrets.sh ~/secrets-restore.sh   # on the old machine
# copy it across securely, then on the new machine:
sh ~/secrets-restore.sh && rm -P ~/secrets-restore.sh
```
The generated file holds the secrets in plaintext (mode 0600). `scripts/` is in
`.chezmoiignore`, so none of this is applied to `$HOME`.
