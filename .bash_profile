#!/usr/bin/env bash

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Pipx
export PATH="$PATH:/Users/carlohcs/.local/bin"

# Skip heavy prompt/plugins in VS Code automation-like terminals
if [[ -n "$VSCODE_GIT_IPC_HANDLE" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export STARSHIP_SHELL=""
  export DISABLE_AUTO_TITLE="true"
  # return early keeps shell minimal for tooling
  return
fi

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Google Cloud SDK
. ~/google-cloud-sdk/path.zsh.inc
# Google Cloud SDK (completion)
. ~/google-cloud-sdk/completion.zsh.inc

# Load known SSH keys
ssh-add -A 2>/dev/null;

# pnpm
export PNPM_HOME="/Users/carlohcs/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# https://github.com/allenk/GeminiWatermarkTool
export VCPKG_ROOT="$HOME/Documents/repository/vcpkg"

# Starship
# export STARSHIP_CONFIG=~/.dotfiles/starship.toml
export STARSHIP_CONFIG="/Users/carlohcs/Documents/repository/dotfiles/starship.toml"
eval "$(starship init zsh)"

# ONLY WORKS FOR BASH
# https://stackoverflow.com/questions/26616003/shopt-command-not-found-in-bashrc-after-shell-updation
# # Load the shell dotfiles, and then some:
# # * ~/.path can be used to extend `$PATH`.
# # * ~/.extra can be used for other settings you don’t want to commit.
# for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
# 	[ -r "$file" ] && [ -f "$file" ] && source "$file";
# done;
# unset file;

# Case-insensitive globbing (used in pathname expansion)
# shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
# shopt -s histappend;

# Autocorrect typos in path names when using `cd`
# shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
# for option in autocd globstar; do
# 	shopt -s "$option" 2> /dev/null;
# done;

# Pyenv
# Add pyenv ao PATH - this is not needed
# export PATH="$HOME/.pyenv/bin:$PATH"

# Inicialize pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# # echo "Forçando configuração global do ccstatusline..."
# CONFIG_PATH="$HOME/Documents/repository/dotfiles/ai/tools/ccstatusline-config.json"

# if [ -f "$CONFIG_PATH" ]; then
#     export CCSTATUSLINE_CONFIG="$CONFIG_PATH"
# else
#     echo "Aviso: Arquivo $CONFIG_PATH não encontrado. Verifique o caminho."
# fi
