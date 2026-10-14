#!/usr/bin/env zsh

# ==========================================
# ZSHRC - Ponto de entrada do shell
# Este arquivo faz APENAS o bootstrap do zsh/oh-my-zsh
# e carrega os módulos do repositório de dotfiles.
# Nada de alias, export ou função solta aqui.
#
# Mapa dos módulos (carregados nesta ordem):
#   .exports      -> variáveis de ambiente e PATH
#   .bootstrap    -> init de ferramentas (asdf, pyenv, starship...)
#   .aliases      -> atalhos de uma linha
#   .functions    -> funções de shell
#   .navigation   -> zoxide + fzf + fsearch + named dirs
#   .warp-config  -> ajustes específicos do Warp
#   .extras       -> catálogo opcional (tudo comentado)
#   .extra        -> privado, fora do git (tokens, perfis)
# ==========================================

# ==========================================
# DOTFILES - Raiz do repositório
# Redefina aqui se mover o repositório de lugar.
# ==========================================
export DOTFILES="${DOTFILES:-$HOME/Documents/repository/dotfiles}"

# ==========================================
# SENSITIVE VARIABLES - Tokens e caminhos privados
# Carregado ANTES de tudo: o .exports só aplica os
# fallbacks de GODADDY_*/POYNT_* se nada estiver definido,
# e o .navigation monta o DOT_DIRS a partir deles.
# Fora do git. chmod 600.
# ==========================================
[[ -r "$HOME/.sensitive_variables" ]] && source "$HOME/.sensitive_variables"

# ==========================================
# OH MY ZSH - Framework base
# https://github.com/ohmyzsh/ohmyzsh
# ==========================================
export ZSH="$HOME/.oh-my-zsh"

# Com starship ativo o tema do oh-my-zsh é trabalho jogado fora.
if command -v starship >/dev/null 2>&1; then
    ZSH_THEME=""
else
    ZSH_THEME="robbyrussell"
fi

# ==========================================
# OH MY ZSH - Plugins
# Mantenha enxuto: cada plugin pesa no tempo de abertura.
# git-extras e kubectl trazem completions pesadas.
# ==========================================
plugins=(
    git
    common-aliases
    colorize
    history
    kubectl
    git-extras
    fzf
)

# ==========================================
# COMPLETIONS - fpath antes do compinit
# O oh-my-zsh roda o compinit internamente, então tudo que
# adiciona completion precisa entrar no fpath ANTES do source.
# (A versão antiga rodava compinit duas vezes.)
# ==========================================
fpath+=${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

source "$ZSH/oh-my-zsh.sh"

# ==========================================
# MÓDULOS - Carga dos dotfiles
# A ordem importa: exports define o PATH que o bootstrap usa.
# ==========================================
for _dotfile in exports bootstrap aliases functions navigation warp-config extras; do
    [[ -r "$DOTFILES/.$_dotfile" ]] && source "$DOTFILES/.$_dotfile"
done
unset _dotfile

# ==========================================
# LEGADO - carlohcs.zsh
# Arquivo antigo que concentrava tudo. Mantido por
# compatibilidade: migre o conteúdo para os módulos acima
# e depois apague esta linha.
# ==========================================
# [[ -r "$DOTFILES/carlohcs.zsh" ]] && source "$DOTFILES/carlohcs.zsh"

# ==========================================
# PRIVADO - .extra (fora do git)
# Tokens, perfis corporativos e qualquer coisa que não
# deve ser versionada: GODADDY_WORKSPACE, GODADDY_POYNT,
# POYNT_KEYS, GOCODE_API_TOKEN, ANTHROPIC_BASE_URL,
# OPEN_CLAW_ASSISTANT_TELEGRAM_BOT_TOKEN...
# Carregado por último para poder sobrescrever qualquer coisa.
# ==========================================
[[ -r "$HOME/.extra" ]] && source "$HOME/.extra"

# Configuração global do ccstatusline
export CCSTATUSLINE_CONFIG="/Users/carlohcs/Documents/repository/dotfiles/ai/tools/ccstatusline-config.json"
