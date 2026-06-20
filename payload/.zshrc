# ── Auto-inicio de tmux ─────────────────────────────────────
# Si no estamos dentro de tmux y hay terminal interactiva → adjuntar o crear sesión "main"
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]] && [[ -z "${STACK_NO_AUTO_TMUX:-}" ]] && [[ -t 0 ]] && [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  tmux new-session -A -s main
fi

# Habilita historial básico
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Alias útiles (puedes personalizar)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Prompt limpio
export PROMPT_EOL_MARK=''

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Aliases personalizados
source ~/.zsh_aliases
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# ── PATH ──────────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$HOME/go/bin:/usr/local/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"  # pipx tools

# ── Autocompletado (Zinit plugins) ───────────────────────────
zinit light zsh-users/zsh-autosuggestions          # sugiere mientras escribís
[[ -t 0 && -t 1 ]] && zinit light marlonrichert/zsh-autocomplete  # evita errores zle fuera de TTY
zinit light zsh-users/zsh-syntax-highlighting      # colorea comandos en tiempo real
zinit light Aloxaf/fzf-tab                         # tab completion con preview fzf

# Completions de herramientas
[[ -t 0 && -t 1 ]] && zinit snippet OMZP::fzf

# ── fzf ───────────────────────────────────────────────────────
[[ -t 0 && -t 1 && -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -t 0 && -t 1 && -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
alias ff='fzf --preview "test -f {} && sed -n '\''1,160p'\'' {} || ls -la {}"'

# ── zoxide (reemplaza cd) ─────────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── bat (en Mint se llama batcat) ────────────────────────────
command -v batcat &>/dev/null && alias bat='batcat'
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"   # man pages con syntax highlight

# ── Aliases modernos (reemplazo de comandos clásicos) ────────
command -v eza   &>/dev/null && alias ls='eza --icons' && alias ll='eza -lah --icons' && alias lt='eza --tree --icons' && alias lsa='eza -lah --icons' && alias lta='eza --tree --icons -a'
command -v bat   &>/dev/null || command -v batcat &>/dev/null && alias cat='batcat'
command -v dua   &>/dev/null && alias du='dua'
command -v procs &>/dev/null && alias ps='procs'

# ── try: experimentos diarios estilo Omarchy ─────────────────
try() {
  local base="$HOME/Work/tries"
  local stamp slug dir
  stamp="$(date +%Y-%m-%d)"
  slug="${1:-experiment}"
  slug="$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+|-+$//g')"
  dir="$base/$stamp-${slug:-experiment}"
  mkdir -p "$dir"
  cd "$dir" || return
}

# ── SSH port forwarding estilo Omarchy ───────────────────────
fip() {
  if (( $# < 2 )); then
    print "usage: fip <host> <port...>" >&2
    return 2
  fi

  local host="$1"
  shift

  local -a forwards
  local port
  for port in "$@"; do
    if [[ ! "$port" =~ '^[0-9]+$' ]]; then
      print "fip: invalid port: $port" >&2
      return 2
    fi
    forwards+=(-L "127.0.0.1:${port}:127.0.0.1:${port}")
  done

  ssh -fN -o ExitOnForwardFailure=yes "${forwards[@]}" "$host"
}

dip() {
  if (( $# < 1 )); then
    print "usage: dip <port...>" >&2
    return 2
  fi

  local port pattern
  for port in "$@"; do
    if [[ ! "$port" =~ '^[0-9]+$' ]]; then
      print "dip: invalid port: $port" >&2
      return 2
    fi
    pattern="ssh .*127\\.0\\.0\\.1:${port}:127\\.0\\.0\\.1:${port}"
    command pkill -f "$pattern" 2>/dev/null || true
  done
}

lip() {
  command pgrep -af 'ssh .*127\.0\.0\.1:[0-9]+:127\.0\.0\.1:[0-9]+' || true
}

# ── git con diff-so-fancy ─────────────────────────────────────
if command -v diff-so-fancy &>/dev/null; then
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  git config --global interactive.diffFilter "diff-so-fancy --patch"
fi

# ── Completions nativas ───────────────────────────────────────
if command -v just &>/dev/null; then
  mkdir -p ~/.zsh/completions
  just --completions zsh > ~/.zsh/completions/_just 2>/dev/null
  fpath=(~/.zsh/completions $fpath)
fi
command -v rclone &>/dev/null && source <(rclone completion zsh 2>/dev/null)
command -v lazygit    &>/dev/null && alias lg='lazygit'
command -v lazyjournal &>/dev/null && alias lj='lazyjournal'
command -v lazydocker &>/dev/null && function ld() { docker ps >/dev/null 2>&1 || { print -P '%F{214}Docker no es accesible desde esta sesión.%f'; print 'Si esto empezó tras una actualización/reinicio, repara permisos del socket o cerrá sesión y volvé a entrar.'; return 1; }; lazydocker "$@"; }

# ── Man pages ─────────────────────────────────────────────────
export LESS="-R"
if command -v batcat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
elif command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  export MANPAGER="less -R"
fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/catppuccin_json_balanced.editable.omp.json)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# ---lazy lector de  filesystem---------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# STACKI3 truecolor theme support
export COLORTERM=truecolor
