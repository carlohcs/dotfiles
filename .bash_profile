#!/usr/bin/env bash

# ==========================================
# BASH PROFILE - Shell secundário
# O shell principal é o zsh (ver .zshrc). Este arquivo existe
# para quando algo cai no bash: scripts, `arch -x86_64 bash`,
# containers e ferramentas que ignoram o $SHELL.
#
# Mudança importante: a versão anterior rodava init de zsh
# (starship init zsh, completion.zsh.inc, pyenv init -) aqui
# dentro, o que só funcionava por ser sourceado pelo zsh.
# Agora cada shell inicializa o que é seu.
#
# Módulos compartilhados: .exports, .aliases, .functions
# (.navigation e .warp-config são zsh-only e NÃO entram aqui)
# ==========================================

export DOTFILES="${DOTFILES:-$HOME/Documents/repository/dotfiles}"

[ -r "$HOME/.sensitive_variables" ] && . "$HOME/.sensitive_variables"

# ==========================================
# MÓDULOS COMPARTILHADOS - Portáveis entre bash e zsh
# ==========================================
for _dotfile in exports aliases functions; do
    [ -r "$DOTFILES/.$_dotfile" ] && . "$DOTFILES/.$_dotfile"
done
unset _dotfile

# ==========================================
# FAST SHELL - Terminais automatizados
# Mantém o shell mínimo em tasks do VS Code e CI.
# ==========================================
if [ -n "$VSCODE_GIT_IPC_HANDLE" ] || [ "$TERM_PROGRAM" = "vscode" ] || [ -n "$CI" ]; then
    export DOTFILES_FAST_SHELL=1
    export DISABLE_AUTO_TITLE="true"
fi

# ==========================================
# BASH OPTIONS - Comportamento do shell
# Só funcionam no bash; por isso nunca estiveram ativas antes.
# https://stackoverflow.com/questions/26616003
# ==========================================
shopt -s nocaseglob  # glob sem diferenciar maiúsculas
shopt -s histappend  # anexa ao histórico em vez de sobrescrever
shopt -s cdspell     # corrige typos em `cd`
for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
done
unset option

# ==========================================
# VERSION MANAGERS - Init no dialeto do bash
# ==========================================
[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ] && . /opt/homebrew/opt/asdf/libexec/asdf.sh

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init - bash)"
fi

# ==========================================
# GOOGLE CLOUD SDK - Versões .bash.inc
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
# COMPLETIONS - Regras pontuais
# `g` herda o completion do git; hosts do ssh vêm do ~/.ssh/config.
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
# Observação do Warp: o starship pode não renderizar quando
# o shell padrão é /bin/bash — use o prompt nativo do Warp nesse caso.
# ==========================================
if [ "$DOTFILES_FAST_SHELL" != "1" ] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ==========================================
# WARPIFY - Blocos do Warp em subshells bash
# ==========================================
if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash"}}\x9c'
fi

# ==========================================
# PRIORIDADE FINAL DE PATH - pipx acima dos shims
# Precisa vir depois do init de asdf/pyenv.
# ==========================================
export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# PRIVADO - .extra (fora do git)
# ==========================================
[ -r "$HOME/.extra" ] && . "$HOME/.extra"
