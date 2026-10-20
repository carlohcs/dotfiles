#!/usr/bin/env zsh

# ==========================================
# ZSHRC - Shell entry point
# This file ONLY bootstraps zsh/oh-my-zsh
# and loads the dotfiles repository modules.
# No loose alias, export or function here.
#
# Module map (loaded in this order):
#   .exports      -> environment variables and PATH
#   .bootstrap    -> tooling init (asdf, pyenv, starship...)
#   .aliases      -> one-line shortcuts
#   .functions    -> shell functions
#   .navigation   -> zoxide + fzf + fsearch + named dirs
#   .warp-config  -> Warp-specific settings
#   .extras       -> optional catalog (all commented out)
#   .extra        -> private, outside git (tokens, profiles)
# ==========================================

# ==========================================
# DOTFILES - Repository root
# Redefine here if you move the repository elsewhere.
# ==========================================
export DOTFILES="${DOTFILES:-$HOME/Documents/repository/dotfiles}"

# ==========================================
# SENSITIVE VARIABLES - Private tokens and paths
# Loaded BEFORE everything else: .exports only applies the
# GODADDY_*/POYNT_* fallbacks if nothing is already set,
# and .navigation builds DOT_DIRS from them.
# Outside git. chmod 600.
# ==========================================
[[ -r "$HOME/.sensitive_variables" ]] && source "$HOME/.sensitive_variables"

# ==========================================
# OH MY ZSH - Base framework
# https://github.com/ohmyzsh/ohmyzsh
# ==========================================
export ZSH="$HOME/.oh-my-zsh"

# With starship active, oh-my-zsh's theme is wasted work.
if command -v starship >/dev/null 2>&1; then
    ZSH_THEME=""
else
    ZSH_THEME="robbyrussell"
fi

# ==========================================
# OH MY ZSH - Plugins
# Keep it lean: every plugin costs startup time.
# git-extras and kubectl bring heavy completions.
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
# COMPLETIONS - fpath before compinit
# oh-my-zsh runs compinit internally, so anything that
# adds completions must enter fpath BEFORE the source.
# (The old version ran compinit twice.)
# ==========================================
fpath+=${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

source "$ZSH/oh-my-zsh.sh"

# ==========================================
# MODULES - Load the dotfiles
# Order matters: exports defines the PATH that bootstrap uses.
# ==========================================
for _dotfile in exports bootstrap aliases functions navigation warp-config extras; do
    [[ -r "$DOTFILES/.$_dotfile" ]] && source "$DOTFILES/.$_dotfile"
done
unset _dotfile

# ==========================================
# LEGACY - carlohcs.zsh
# Old file that used to hold everything. Kept for
# compatibility: migrate the content to the modules above
# and then delete this line.
# ==========================================
# [[ -r "$DOTFILES/carlohcs.zsh" ]] && source "$DOTFILES/carlohcs.zsh"

# ==========================================
# PRIVATE - .extra (outside git)
# Tokens, corporate profiles and anything that should
# not be versioned: GODADDY_WORKSPACE, GODADDY_POYNT,
# POYNT_KEYS, GOCODE_API_TOKEN, ANTHROPIC_BASE_URL,
# OPEN_CLAW_ASSISTANT_TELEGRAM_BOT_TOKEN...
# Loaded last so it can override anything.
# ==========================================
[[ -r "$HOME/.extra" ]] && source "$HOME/.extra"

# Global ccstatusline configuration
export CCSTATUSLINE_CONFIG="/Users/carlohcs/Documents/repository/dotfiles/ai/tools/ccstatusline-config.json"
