# Usage

## Setup on a new machine

```
brew install chezmoi
chezmoi init --apply --verbose igor-sirotin
```

## Update dotfiles

After you have made changes to your dotfiles, you can update them with:
```
chezmoi add <file>
chezmoi apply
```

## Secrets management

`keyring` is used to manage secrets, this corresponds to `keychain` on macOS.
To add/modify a secret, use:
```
chezmoi secret keyring set --service <service> --user <user>
chezmoi apply
```
