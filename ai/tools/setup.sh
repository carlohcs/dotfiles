#!/usr/bin/env bash

# ==============================================================================
# SETUP DE FERRAMENTAS PARA IA NO TERMINAL (MCP / Claude Code)
# ==============================================================================
# Este script automatiza a instalação do ecossistema de otimização de contexto,
# reduzindo o consumo de tokens e melhorando a precisão das edições e leituras.
# ==============================================================================

echo "Iniciando configuração das ferramentas de IA..."

# ------------------------------------------------------------------------------
# 1. TOKENSAVE
# O que faz: Servidor MCP que faz o parsing do repositório para criar um banco
# de dados local com um grafo estrutural do código.
# Referência: https://github.com/aovestdipaperino/tokensave (Tap Homebrew)
# ------------------------------------------------------------------------------
echo -e "\n[1/5] Configurando Tokensave..."
if ! command -v tokensave &> /dev/null; then
    brew install aovestdipaperino/tap/tokensave
    tokensave install # Registra o servidor globalmente
    echo "Tokensave instalado."
else
    echo "Tokensave já está instalado."
fi

# ------------------------------------------------------------------------------
# 2. SERENA ("Cérebro de IDE")
# O que faz: Servidor MCP que integra a IA diretamente ao LSP do projeto.
# Referência: Pacote instalado via 'uv' (https://github.com/serena-agent)
# ------------------------------------------------------------------------------
echo -e "\n[2/5] Configurando Serena..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! command -v serena &> /dev/null; then
    uv tool install -p 3.13 serena-agent
    serena init # Inicializa backend LSP
    echo "Serena instalada."
else
    echo "Serena já está instalada."
fi

# ------------------------------------------------------------------------------
# 3. RTK (Rust Token Killer)
# O que faz: CLI que atua como filtro de ruído entre o terminal e a IA.
# Referência: Instalação via Homebrew (https://crates.io/crates/rtk)
# ------------------------------------------------------------------------------
echo -e "\n[3/5] Configurando RTK..."
if ! command -v rtk &> /dev/null; then
    brew install rtk
    rtk init -g --auto-patch # Adiciona o hook global silenciosamente
    echo "RTK instalado."
else
    echo "RTK já está instalado."
fi

# ------------------------------------------------------------------------------
# 4. HEADROOM
# O que faz: Utilitário focado no gerenciamento dinâmico da janela de contexto.
# Referência: https://pypi.org/project/headroom-ai/
# ------------------------------------------------------------------------------
echo -e "\n[4/5] Configurando Headroom..."
if ! command -v headroom &> /dev/null; then
    # O uso de aspas impede que o shell expanda os colchetes
    pip install "headroom-ai[proxy]"
    echo "Headroom instalado."
else
    echo "Headroom já está instalado."
fi

# ------------------------------------------------------------------------------
# 5. CCSTATUSLINE (Atualizado com persistência global e limpeza de cache)
# ------------------------------------------------------------------------------
echo -e "\n[5/5] Configurando ccstatusline..."
if ! command -v ccstatusline &> /dev/null; then
    npm install -g ccstatusline 
    echo "ccstatusline instalado."
else
    echo "ccstatusline já está instalado."
fi

echo "Forçando configuração global do ccstatusline..."
CONFIG_PATH="$HOME/Documents/repository/dotfiles/ai/tools/ccstatusline-config.json"

if [ -f "$CONFIG_PATH" ]; then
    # 1. Cria o symlink (método mais garantido para ferramentas em Node)
    mkdir -p "$HOME/.config/ccstatusline"
    ln -sf "$CONFIG_PATH" "$HOME/.config/ccstatusline/settings.json"
    
    # 2. Injeta a variável de ambiente no ~/.zshrc se ela ainda não existir
    if ! grep -q "CCSTATUSLINE_CONFIG" "$HOME/.zshrc"; then
        echo -e "\n# Configuração global do ccstatusline" >> "$HOME/.zshrc"
        echo "export CCSTATUSLINE_CONFIG=\"$CONFIG_PATH\"" >> "$HOME/.zshrc"
        echo "Variável adicionada ao ~/.zshrc."
    fi

    # 3. Mata qualquer processo em background que esteja segurando o cache antigo
    echo "Limpando cache e reiniciando daemons do ccstatusline..."
    pkill -f ccstatusline || true
    
    # 4. Remove a pasta de cache padrão (caso a ferramenta grave estado temporário)
    rm -rf "$HOME/.cache/ccstatusline"

    echo "Configuração do ccstatusline apontada para $CONFIG_PATH com sucesso."
else
    echo "Aviso: Arquivo $CONFIG_PATH não encontrado. Verifique o caminho."
fi

# ==============================================================================
echo -e "\n✅ Instalação concluída! Execute 'source ~/.zshrc' ou abra um novo terminal para aplicar."
