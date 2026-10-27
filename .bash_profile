#!/usr/bin/env bash

# ==========================================
# BASH PROFILE - Secondary shell
# The primary shell is zsh (see .zshrc). This file exists
# for when something falls back to bash: scripts, `arch -x86_64 bash`,
# containers and tools that ignore $SHELL.
#
# Important change: the previous version ran zsh init
# (starship init zsh, completion.zsh.inc, pyenv init -) in here,
# which only worked because it was sourced by zsh.
# Now each shell initializes what belongs to it.
#
# Shared modules: .exports, .aliases, .functions
# (.navigation and .warp-config are zsh-only and do NOT enter here)
# ==========================================

export DOTFILES="${DOTFILES:-$HOME/Documents/repository/dotfiles}"

[ -r "$HOME/.sensitive_variables" ] && . "$HOME/.sensitive_variables"

# ==========================================
# SHARED MODULES - Portable between bash and zsh
# ==========================================
for _dotfile in exports aliases functions; do
    [ -r "$DOTFILES/.$_dotfile" ] && . "$DOTFILES/.$_dotfile"
done
unset _dotfile

# ==========================================
# FAST SHELL - Automated terminals
# Keeps the shell minimal in VS Code tasks and CI.
# ==========================================
if [ -n "$VSCODE_GIT_IPC_HANDLE" ] || [ "$TERM_PROGRAM" = "vscode" ] || [ -n "$CI" ]; then
    export DOTFILES_FAST_SHELL=1
    export DISABLE_AUTO_TITLE="true"
fi

# ==========================================
# BASH OPTIONS - Shell behavior
# Only work in bash; that's why they were never active before.
# https://stackoverflow.com/questions/26616003
# ==========================================
shopt -s nocaseglob  # case-insensitive globbing
shopt -s histappend  # append to history instead of overwriting
shopt -s cdspell     # fixes typos in `cd`
for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
done
unset option

# ==========================================
# VERSION MANAGERS - Init in bash dialect
# ASDF v0.16+ is a Go binary with no libexec/asdf.sh to source;
# shims just need to be on PATH, ahead of other shims/managers.
# ==========================================
if command -v asdf >/dev/null 2>&1; then
    export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
    path_prepend "$ASDF_DATA_DIR/shims"
fi

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init - bash)"
fi

# ==========================================
# GOOGLE CLOUD SDK - .bash.inc versions
# disabled by now
# ==========================================
# [ -f "$HOME/google-cloud-sdk/path.bash.inc" ] && . "$HOME/google-cloud-sdk/path.bash.inc"
# if [ "$DOTFILES_FAST_SHELL" != "1" ] && [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then
#     . "$HOME/google-cloud-sdk/completion.bash.inc"
# fi

# ==========================================
# COMPLETIONS - Homebrew bash-completion
# ==========================================
if command -v brew >/dev/null 2>&1 && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ==========================================
# COMPLETIONS - One-off rules
# `g` inherits git's completion; ssh hosts come from ~/.ssh/config.
# ==========================================
if type _git >/dev/null 2>&1; then
    complete -o default -o nospace -F _git g
fi

[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" \
    -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" \
    scp sftp ssh

complete -W "NSGlobalDomain" defaults
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# ==========================================
# STARSHIP - Prompt
# Warp note: starship may not render when
# the default shell is /bin/bash — use Warp's native prompt in that case.
# ==========================================
if [ "$DOTFILES_FAST_SHELL" != "1" ] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ==========================================
# WARPIFY - Warp blocks in bash subshells
# ==========================================
if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash"}}\x9c'
fi

# ==========================================
# FINAL PATH PRIORITY - pipx above the shims
# Must come after the asdf/pyenv init.
# ==========================================
export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# PRIVATE - .extra (outside git)
# ==========================================
[ -r "$HOME/.extra" ] && . "$HOME/.extra"
