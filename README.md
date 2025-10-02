# dotfiles

This repository contains my personal dotfiles for configuring various development tools and shells.

## Contents

- **`.bash_aliases`** - Bash aliases for common commands including ls colors, kubectl shortcuts, and Python virtual environment helpers
- **`.bashrc`** - Bash shell configuration with history settings, prompt customization, and color support
- **`.flake8`** - Python linter configuration (ignores E501 line length)
- **`.gitconfig`** - Git configuration with useful aliases and credential helper setup
- **`.gitignore`** - Global gitignore patterns for Python and Terraform projects
- **`.pre-commit-config.yaml`** - Pre-commit hooks configuration with trailing whitespace, file fixers, black, and flake8
- **`.vimrc`** - Vim editor configuration with line numbers, syntax highlighting, and tab settings
- **`.zshrc`** - Zsh shell configuration with oh-my-zsh, agnoster theme, and custom aliases

## Usage

To use these dotfiles, you can either:

1. Copy individual files to your home directory:
   ```bash
   cp .bashrc ~/
   cp .bash_aliases ~/
   # etc...
   ```

2. Create symbolic links from your home directory to this repository:
   ```bash
   ln -s /path/to/this/repo/.bashrc ~/.bashrc
   ln -s /path/to/this/repo/.bash_aliases ~/.bash_aliases
   # etc...
   ```

## Notes

- The `.zshrc` file assumes oh-my-zsh is installed. Install it from: https://ohmyz.sh/
- The `.gitconfig` includes personal email - update this for your own use
- Some aliases reference specific paths that may need to be adjusted for your environment