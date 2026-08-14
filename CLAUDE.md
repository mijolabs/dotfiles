# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

macOS dotfiles and provisioning repo. A single `Makefile` orchestrates bootstrapping a fresh macOS system.

## Commands

- `make` or `make help` — list all available targets
- `make all` — run full provisioning (prompts for sudo upfront)
- Individual targets: `make macos`, `make xcode-clt`, `make homebrew`, `make omz`, `make brewfile`, `make python`, `make fonts`, `make claude-code`, `make iterm2`

There are no tests or linters.

## Architecture

The `Makefile` is the single entry point. All targets are idempotent (they check before installing). The Makefile shell is bash with strict mode (`-eu -o pipefail`).

`bootstrap/` contains config files and scripts organized by concern:

- `homebrew/` — Brewfile package declarations (`brew bundle`)
- `omz/` — shell config: `zshrc.sh`, `zprofile.sh`, and `custom/*.zsh` modules
- `macos/` — `macos-bootstrap.sh` applies system defaults (runs as root via sudo)
- `fonts/` — font files encrypted with `age` (passphrase-based); `_encrypt_font.sh` to add new ones
- `claude-code/` — Claude Code config; `symlinks/` contains files symlinked into `~/.claude/`, plugin marketplace sources and installs are declared in `settings.json`
- `iterm2/` — iTerm2 plist preferences

## Key Patterns

**Symlink-based deployment** — config files are symlinked (not copied) into their target locations, so edits in this repo take effect immediately:
- `bootstrap/omz/custom/*.zsh` → `~/.oh-my-zsh/custom/`
- `bootstrap/omz/zshrc.sh` is sourced from `~/.zshrc`
- `bootstrap/claude-code/symlinks/*` → `~/.claude/`

**Font encryption** — fonts are stored as `.age` files. Decrypt with `age --decrypt`; encrypt new fonts with `_encrypt_font.sh` (prompts for passphrase).
