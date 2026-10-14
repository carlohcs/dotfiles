# Dotfiles

This repository contains a collection of configuration files (dotfiles) to customize the development environment and computer. Dotfiles are essential for configuring tools and shells according to personal preferences, improving efficiency and development experience.

These are my current (and constantly changing) configurations.

Primary shell is **zsh** on **macOS (Apple Silicon)**, running inside **[Warp](https://www.warp.dev/)**.

---

## Structure

Single-responsibility modules, loaded in order by `.zshrc`.

| File | Responsibility |
| --- | --- |
| `.zshrc` | Bootstraps zsh/oh-my-zsh and loads the modules. Nothing else. |
| `.exports` | Environment variables and `$PATH`. Loaded first. |
| `.bootstrap` | `eval`/`source` of tooling: asdf, pyenv, conda, gcloud, starship. |
| `.aliases` | One-liner shortcuts only. |
| `.functions` | Functions only. |
| `.navigation` | zoxide, fzf, fsearch, named dirs, `cdpath`. |
| `.warp-config` | Warp-specific: warpify, workflows, themes, prompt. |
| `.extras` | Catalog of optional tools, all commented out. |
| `.bash_profile` | Secondary shell. Reuses exports/aliases/functions. |
| `~/.sensitive_variables` | Private, outside git: tokens and corporate paths. Loaded before everything. |
| `~/.extra` | Optional last-word overrides, outside git. |

Load order: `~/.sensitive_variables → exports → bootstrap → aliases → functions → navigation → warp-config → extras → ~/.extra`

Why the order matters: `.exports` only applies its `GODADDY_*` / `POYNT_*` fallbacks when nothing is already set, and `.navigation` builds its directory map on top of those variables. Secrets first, defaults second.

---

## Install

```bash
DOTFILES="$HOME/Documents/repository/dotfiles"

# 1. Back up whatever is in place today
cp ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d)
cp ~/.bash_profile ~/.bash_profile.bak.$(date +%Y%m%d)

# 2. Point the home dotfiles at this repository
ln -sf "$DOTFILES/.zshrc" ~/.zshrc
ln -sf "$DOTFILES/.bash_profile" ~/.bash_profile

# 3. Navigation tooling
brew install zoxide fzf fd bat eza

# 4. Open a new shell (loads the dotfiles, which defines `fsearch-setup`)
exec zsh

# 5. Whole-disk search — only works after step 4
fsearch-setup

# 6. Icons for eza/starship — only works after step 4
nerdfont-setup
```

`nerdfont-setup` installs *MesloLGS Nerd Font* via Homebrew (pass another cask name to use a different one, e.g. `nerdfont-setup font-fira-code-nerd-font`). Installing is not enough: you must also activate the font in the terminal.

| Terminal | Where to activate |
| --- | --- |
| Warp | Settings → Appearance → Text → Terminal font → *MesloLGS Nerd Font* (restart Warp if it is not listed) |
| VS Code | `terminal.integrated.fontFamily` → `MesloLGS Nerd Font` |
| iTerm2 | Settings → Profiles → Text → Font |

Then open a new tab and run `ls`: the icons should appear before each name.

`fsearch-setup` is a function defined in `.navigation`, so it does not exist until the new `.zshrc` is loaded. Running it in a shell that has not been reloaded gives `zsh: command not found: fsearch-setup`.

### Private variables

Never committed. Create it once:

```bash
cat > ~/.sensitive_variables <<'EOF'
export GODADDY_WORKSPACE="$HOME/Documents/godaddy"
export GODADDY_POYNT="$GODADDY_WORKSPACE/poynt"
export POYNT_KEYS="$GODADDY_WORKSPACE/keys"
export GOCODE_API_TOKEN=""
export ANTHROPIC_BASE_URL=""
export OPEN_CLAW_ASSISTANT_TELEGRAM_BOT_TOKEN=""
EOF
chmod 600 ~/.sensitive_variables
```

Keep `.sensitive_variables` and `.extra` in `.gitignore`.

---

## How to

| I want to… | Do this |
| --- | --- |
| Reload the shell | `reload-shell` |
| Edit a module | `edit-aliases`, `edit-functions`, `edit-exports`, `edit-navigation`, `edit-warp` |
| Open the whole repo in the editor | `edit-dotfiles` |
| Add a new project folder shortcut | Add it to the `DOT_DIRS` map in `.navigation` — it generates the named dir, the `cdpath` entry and the legacy alias at once |
| Add a one-liner shortcut | `.aliases` |
| Add anything with arguments or logic | `.functions` |
| Add a `PATH` entry or env var | `.exports`, using `path_prepend` / `path_append` |
| Add a tool that needs `eval "$(tool init zsh)"` | `.bootstrap` |
| Try an optional tool | Uncomment its block in `.extras` |
| Store a token | `~/.sensitive_variables`, never in this repo |
| Jump to a folder visited before | `cd <fragment>` |
| Jump to a folder never visited | `fcd <name>` — finds it on disk and teaches zoxide |
| Pick a folder interactively | `cdd` (or `cdi`) |
| Find a file anywhere on disk | `ff <name>` — typo tolerant, opens it in the editor |
| Search inside files | `fgr <pattern>` |
| Find where a symbol is defined | `fsym <symbol>` |
| List what git changed in a tree | `fgit [folder]` |
| Switch AWS profile | `aws-us`, `aws-eu`, `aws-hermes-dev`, … |
| Inspect the current AWS session | `check-aws-session` |
| Wipe AWS session tokens (keeping personal creds) | `clean-aws-tokens-only` — or `clean-aws-current-session` for a full clean with backup |
| Undo an AWS clean | `restore-aws-credentials` |
| Switch npm registry | `npmg`, `npmp`, `npmgshared`, `npmd` |
| Switch JDK | `switch-java 21.0.2` (or `switch-java-latest` / `switch-java-17`) |
| Start the container VM | `cstart` — first time ever, `colima-setup` |
| Free a busy port | `kill-port 3000` |
| Convert a video | `convert-video file.mov` |
| Symlink a script into `~/.local/bin` | `create-global-link ./script.sh` |
| Measure shell startup time | `time zsh -i -c exit` |

---

## Navigation

Five layers, from most automatic to most manual. The point is that folder aliases are no longer the way to move around.

1. **[zoxide](https://github.com/ajeetdsouza/zoxide)** — replaces `cd` and learns by frequency + recency. `cd herm` lands in the hermes folder.
2. **`cdpath`** — `cd hermes` works from anywhere, with TAB completion.
3. **Named dirs** — `cd ~hermes`, and the prompt shows `~hermes` instead of the full path.
4. **[fzf](https://github.com/junegunn/fzf)** — `Ctrl-T` file, `Ctrl-R` history, `Alt-C` folder, `cdd` for zoxide's own picker.
5. **[fsearch](https://github.com/noahdunnagan/fsearch)** — whole-disk search for anything the layers above don't know yet.

`fsearch` is a file search engine, **not** a directory jumper: fuzzy names with typo tolerance plus indexed content grep, roughly 1 ms across millions of files. The `fcd` helper closes the loop — whatever you pick gets written into zoxide, so next time plain `cd <fragment>` is enough.

Query syntax: `in:` `ext:` `type:` `size:` `mtime:` `grep:` `regex:` `sym:` `git:` `limit:`, plus `'exact`, `^prefix`, `suffix$` and `!exclude`.

For full-disk coverage run `fsearch install --login` and authorize `~/.local/bin/fsearch` under System Settings → Privacy & Security → Full Disk Access. This has to be redone after each rebuild. `fsearch-skip` edits the folders excluded from content indexing.

It also ships an MCP server — `claude mcp add fsearch -- fsearch mcp` gives coding agents `find_files`, `grep` and `multi_grep`.

---

## Warp

| Command | What it does |
| --- | --- |
| `warp-link-dotfiles` | Symlinks `~/.warp/workflows` and `~/.warp/themes` into this repo so they are versioned |
| `warp-install-themes` | Pulls the community themes from [warpdotdev/themes](https://github.com/warpdotdev/themes) |
| `warp-new-workflow <name>` | Scaffolds a parameterized YAML workflow (`Ctrl-Shift-R` to search) |
| `warp-prefs-read` | Dumps Warp preferences (`dev.warp.Warp-Stable`) |

The warpify hook is already active, so nested shells (`docker exec`, `ssh`, a child `zsh`) keep blocks and autocomplete instead of falling back to plain text.

Starship is active inside Warp by default, with the Shell (PS1) input type enabled in Warp's settings. To use Warp's native prompt with context chips instead: `export DOTFILES_STARSHIP_IN_WARP=0` in `~/.sensitive_variables`.

[Workflows](https://docs.warp.dev/features/workflows) are a better home than aliases for long, parameterized commands — they are searchable and shareable per repository via `.warp/workflows/`.

---

## Conventions

Section headers follow one shape, so the files stay scannable:

```zsh
# ==========================================
# <TITLE> - <Description>
# ==========================================
```

Optional tooling in `.extras` carries its source, so the comment itself explains what you would be enabling:

```zsh
# ==========================================
# <NAME> - <repository-url>
# <Description>
# Uncomment the line if you want it
# <function/call/import...>
# ==========================================
```

Everything in `.extras` is commented out on purpose. Each line costs milliseconds at shell startup — enable only what you actually use.

---

## Fast shell mode

VS Code tasks, CI and other automated terminals set `DOTFILES_FAST_SHELL=1` automatically. That skips the cosmetic and expensive parts (starship, gcloud completions, eager conda, `ssh-add`) while keeping version managers loaded, so `node` and `python` still resolve. Conda is then available on demand through `conda-activate`.

If startup creeps past ~400ms, the usual suspects are conda, the gcloud completions and oh-my-zsh's `kubectl` plugin. [zsh-defer](https://github.com/romkatv/zsh-defer) and [mise](https://github.com/jdx/mise) — both already documented in `.extras` — handle most of it.

---

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `cd` stopped jumping | zoxide not installed — `brew install zoxide` |
| A folder shortcut is missing | Its path doesn't exist, so `.navigation` skipped it. Check `GODADDY_*` in `~/.sensitive_variables` |
| `ff` / `fcd` say nothing found | fsearch index not built or no Full Disk Access — rerun `fsearch-setup` |
| `zsh: command not found: fsearch-setup` | The shell was opened before the dotfiles were linked, or `.navigation` failed to parse. Run `exec zsh` and check there are no errors on startup |
| `defining function based on alias 'ff'` / `parse error near '()'` | oh-my-zsh's `common-aliases` plugin defines `alias ff`. `.navigation` defines these with `function name {` (never `name() {`, which zsh expands as an alias at parse time) and runs `unalias` on them first |
| `no such file or directory: ~/.oh-my-zsh/custom/carlohcs.zsh` | Dangling symlink to the old monolithic file, which no longer exists. Remove it with `rm ~/.oh-my-zsh/custom/carlohcs.zsh` |
| `brew` output (`fd is already installed`) on every shell start | An uncommented `brew install` in `.extras`. Nothing there should run `brew`; install tools once by hand |
| `ls` / `eza` icons show as blank gaps or boxes | The terminal font has no Nerd Font glyphs. Run `nerdfont-setup`, then pick *MesloLGS Nerd Font* in Warp → Settings → Appearance → Text → Terminal font |
| Wrong binary version is picked | `.local/bin` precedence is restored at the end of `.bootstrap`; anything appended after that wins. Check with `which -a <binary>` |
| Prompt looks wrong in Warp | Enable Settings → Appearance → Input → Input Type → Shell (PS1). See the Warp section |
| Corporate aliases point nowhere | `~/.sensitive_variables` missing or not loaded before `.exports` |
