alias gs="git status"
alias gb="git branch"
alias gss='for d in */; do [ -d "$d/.git" ] && echo "=== $d ===" && git -C "$d" status; done'
alias gbb='for d in */; do [ -d "$d/.git" ] && echo "=== $d ===" && git -C "$d" branch; done'
alias gitac="git add -A && git commit -m"
alias gitacsrc="git add src && git commit -m"
alias intl="brew install"
alias gd="git diff"
alias gch="git checkout"
alias bringoutthelobster="npm i && npm run compile && cd ../ideaas-frontend && yarn install && cd ../<REDACTED>  && npm i && npm run compile && ./start-dev.js"
alias moneyshot="cloneout && cd <REDACTED> && bringoutthelobster"
alias testthing="[ ! -d node_modules ] && npm i; npm run compile && npm run test:coverage"
alias deployer="npm i && node scripts/release.js vscode --variant pkg --env"
alias lj="lazygit"
alias qux="hx ~/.zshrc"
alias qug="source ~/.zshrc"
alias editbranch="hx variants/vscode/pkg/scripts/build.js"
alias 1="ls -larth"
alias 2="codex resume"
alias 3="claude --dangerously-skip-permissions"
alias cursor="/Applications/Cursor.app/Contents/MacOS/Cursor"
alias zed="/Applications/Zed.app/Contents/MacOS/Zed"
alias gdd='git diff -- . ":(exclude)*lock*" ":(exclude)package-lock.json" ":(exclude)yarn.lock" ":(exclude)pnpm-lock.yaml" ":(exclude)*-lock.json" ":(exclude)*.lock" ":(exclude)*test.ts"'
alias dstop='docker stop $(docker ps -q)'
gc() {
  local repo="$1"
  shift
  git clone "$@" "git@github.com:interviewstreet/${repo}.git"
}
mkcd () {
  mkdir -p "$@" && cd "$@"
}

# --- cloneout (APFS clone + rsync fallback with progress) ---

# Remove any old alias/function definitions to avoid conflicts/hangs
unalias cloneout 2>/dev/null
unset -f cloneout 2>/dev/null
cloneout() {
  emulate -LR zsh
  setopt localoptions pipefail

  local src_base="${HOME}/mainbranch"
  local dest="${PWD}"

  local -a repos=(
  )

  # Basic sanity (cheap + avoids confusing failures later)
  if [[ ! -d "${src_base}" ]]; then
    echo "❌ cloneout: source base does not exist: ${src_base}"
    return 1
  fi
  if [[ ! -d "${dest}" ]]; then
    echo "❌ cloneout: destination does not exist: ${dest}"
    return 1
  fi

  # Pick best rsync available (Homebrew if installed), else system rsync
  local RSYNC_BIN
  if [[ -x /opt/homebrew/bin/rsync ]]; then
    RSYNC_BIN="/opt/homebrew/bin/rsync"
  elif [[ -x /usr/local/bin/rsync ]]; then
    RSYNC_BIN="/usr/local/bin/rsync"
  else
    RSYNC_BIN="$(command -v rsync 2>/dev/null)"
  fi

  if [[ -z "${RSYNC_BIN}" || ! -x "${RSYNC_BIN}" ]]; then
    echo "❌ cloneout: rsync not found. Install rsync (e.g., brew install rsync) or ensure it's on PATH."
    return 1
  fi

  # Decide progress flag based on rsync major version
  local rsync_ver_major RSYNC_PROGRESS_FLAG
  rsync_ver_major="$("${RSYNC_BIN}" --version 2>/dev/null | awk 'NR==1{print $3}')"
  rsync_ver_major="${rsync_ver_major%%.*}"
  RSYNC_PROGRESS_FLAG="--progress"
  if [[ "${rsync_ver_major:-0}" -ge 3 ]]; then
    RSYNC_PROGRESS_FLAG="--info=progress2"
  fi

  # Cache APFS/device checks once (stat is relatively expensive; avoid per-repo)
  local src_fs dest_fs src_dev dest_dev
  src_fs="$(stat -f %T "${src_base}" 2>/dev/null || true)"
  dest_fs="$(stat -f %T "${dest}" 2>/dev/null || true)"
  src_dev="$(stat -f %d "${src_base}" 2>/dev/null || true)"
  dest_dev="$(stat -f %d "${dest}" 2>/dev/null || true)"

  local -i can_apfs_clone=0
  if [[ "${src_fs}" == "apfs" && "${dest_fs}" == "apfs" && -n "${src_dev}" && "${src_dev}" == "${dest_dev}" ]]; then
    can_apfs_clone=1
  fi

  # Prebuild rsync args so we don't rebuild strings each call
  local -a RSYNC_ARGS
  RSYNC_ARGS=(-a --delete "${RSYNC_PROGRESS_FLAG}")

  _update_repo() {
    local name="$1"
    local src="${src_base}/${name}"

    if [[ ! -d "${src}/.git" ]]; then
      echo "❌ cloneout: missing git repo at ${src}"
      return 1
    fi

    printf "\n🔄 Updating %s...\n" "${name}"

    local -a G
    G=(git -C "${src}")

    # Ensure origin exists (otherwise fetch/reset will be misleading)
    if ! "${G[@]}" remote get-url origin >/dev/null 2>&1; then
      echo "❌ cloneout: ${name} has no 'origin' remote (${src})"
      return 1
    fi

    # Fetch MUST succeed; otherwise we'd copy stale bits and still claim success
    if ! "${G[@]}" fetch --prune origin; then
      echo "❌ cloneout: git fetch failed for ${name} (auth/VPN/remote URL?)"
      return 1
    fi

    # Refresh origin/HEAD to match the remote's HEAD if possible
    # (helps after default-branch changes like master→main)
    "${G[@]}" remote set-head origin -a >/dev/null 2>&1 || true

    # Determine default branch (prefer origin/HEAD; fallback to remote show)
    local main_branch
    main_branch="$("${G[@]}" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
    main_branch="${main_branch#origin/}"

    if [[ -z "${main_branch}" ]]; then
      main_branch="$("${G[@]}" remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF; exit}' || true)"
    fi
    if [[ -z "${main_branch}" ]]; then
      echo "❌ cloneout: could not determine default branch for ${name}"
      return 1
    fi

    # If this repo was cloned with a narrow fetch refspec (e.g., single-branch),
    # origin/<default> might not exist locally even after fetch.
    if ! "${G[@]}" show-ref --verify --quiet "refs/remotes/origin/${main_branch}"; then
      if ! "${G[@]}" fetch --prune origin "refs/heads/${main_branch}:refs/remotes/origin/${main_branch}"; then
        echo "❌ cloneout: could not fetch origin/${main_branch} for ${name}"
        return 1
      fi
    fi

    # Hard-sync working tree to origin/<default>
    if ! "${G[@]}" checkout -q -B "${main_branch}" "origin/${main_branch}"; then
      echo "❌ cloneout: could not checkout ${main_branch} for ${name}"
      return 1
    fi
    if ! "${G[@]}" reset --hard "origin/${main_branch}"; then
      echo "❌ cloneout: reset failed for ${name}"
      return 1
    fi
    if ! "${G[@]}" clean -fdx; then
      echo "❌ cloneout: clean failed for ${name}"
      return 1
    fi

    echo "✅ ${name} updated → origin/${main_branch}"
  }

  _materialize_repo() {
    local name="$1"
    local src="${src_base}/${name}"
    local dst="${dest}/${name}"

    printf "\n📦 Materializing %s → %s\n" "${name}" "${dst}"

    # Remove previous copy (this can take time; show a line so it doesn't look stuck)
    if [[ -e "${dst}" ]]; then
      echo "🧹 Removing old ${dst}..."
      rm -rf "${dst}" || return 1
    fi

    # APFS clone if possible (instant)
    if (( can_apfs_clone )); then
      echo "⚡ APFS clone (copy-on-write)"
      cp -cR "${src}" "${dst}" || return 1
      echo "✅ ${name} cloned"
      return 0
    fi

    # rsync fallback with progress
    echo "🟡 Different volume/filesystem → rsync fallback (${RSYNC_PROGRESS_FLAG})"
    mkdir -p "${dst}" || return 1
    "${RSYNC_BIN}" "${RSYNC_ARGS[@]}" "${src}/" "${dst}/" || return 1
    echo "✅ ${name} synced"
  }

  echo "======================================"
  echo "cloneout → Destination: ${dest}"
  echo "Source   → ${src_base}"
  echo "Rsync    → ${RSYNC_BIN} (${RSYNC_PROGRESS_FLAG})"
  echo "APFS COW → $(( can_apfs_clone )) (1=enabled, 0=disabled)"
  echo "======================================"

  local name
  for name in "${repos[@]}"; do
    _update_repo "${name}" || return 1
    _materialize_repo "${name}" || return 1
  done

  echo ""
  echo "🎉 cloneout done."
}

# --- end cloneout ---
# NVM stuff
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# API Key for portkey
export PORTKEY_API_KEY="<REDACTED>"
precmd() { print -P "%F{cyan}------------------------------------------------------------------------------------------------------------------------------------------------------%f" }

# Rust (rustup)
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export CXXFLAGS="-fexperimental-new-constant-interpreter"

# bun completions
[ -s "/Users/deepnarayan/.bun/_bun" ] && source "/Users/deepnarayan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/Users/deepnarayan/.opencode/bin:$PATH
