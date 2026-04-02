# dotfiles

Minimal setup: **git repo + manual symlink**

## rules

* no bare repo
* no stow / chezmoi
* no install script
* config only
* no private keys

## bootstrap

clone and apply:

```
git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles && cd ~/personal/dotfiles && make
git remote set-url origin git@github-personal:zouzonghua/dotfiles.git
```

## git

directory → identity

```
~/work      → work
~/personal  → personal
```

## ssh

host → key

```
github-work      → id_ed25519_work
github-personal  → id_ed25519_personal
```

## make

```
make        # setup all
make git    # setup git only
make ssh    # setup ssh only
```

behavior:

* create target directories if missing
* backup existing files → `*.backup`
* create symlink with `ln -sfn`
* safe to run multiple times

