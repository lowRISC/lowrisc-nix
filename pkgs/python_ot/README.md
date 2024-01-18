# Managing OpenTitan Python Environment

The canonical source of dependencies live in pyproject.toml.

From here, poetry generates poetry.lock which pins the hash for all pip and url dependencies.

poetry2nix generates poetry-git-overlay.nix which pins the hash for all git and url dependencies.

Git dependencies need to be avoided because hash pinning is not supported when outputting python-requirements.txt.

## Pinning Steps

To generate poetry.lock:

```bash
nix run nixpkgs#poetry lock
```

To generate poetry-git-overlay.nix:

```bash
nix run github:nix-community/poetry2nix lock
```
