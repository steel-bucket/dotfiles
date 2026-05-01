alias gs="git status"
alias gb="git branch"
alias gss='for d in */; do [ -d "$d/.git" ] && echo "=== $d ===" && git -C "$d" status; done'
alias gbb='for d in */; do [ -d "$d/.git" ] && echo "=== $d ===" && git -C "$d" branch; done'
alias gitac="git add -A && git commit -m"
alias gitacsrc="git add src && git commit -m"
alias intl="sudo apt install"
alias gd="git diff"
alias gch="git checkout"
alias lj="lazygit"
alias qux="hx ~/.bashrc"
alias qug="source ~/.bashrc"
alias editbranch="hx variants/vscode/pkg/scripts/build.js"
alias 1="ls -larth"
alias 2="codex resume"
alias 3="claude --dangerously-skip-permissions"
alias gdd='git diff -- . ":(exclude)*lock*" ":(exclude)package-lock.json" ":(exclude)yarn.lock" ":(exclude)pnpm-lock.yaml" ":(exclude)*-lock.json" ":(exclude)*.lock" ":(exclude)*test.ts"'
alias dstop='docker stop $(docker ps -q)'

gc() {
  local repo="$1"
  shift
  git clone "$@" "git@github.com:interviewstreet/${repo}.git"
}

mkcd() {
  mkdir -p "$@" && cd "$@"
}

cursor() {
  command cursor "$@"
}

zed() {
  command zed "$@"
}

bringoutthelobster() {
  npm i &&
    npm run compile &&
    cd ../ideaas-frontend &&
    yarn install &&
    cd ../hackerrank-vscode-copilot-chat &&
    npm i &&
    npm run compile &&
    ./start-dev.js
}

testthing() {
  [ ! -d node_modules ] && npm i
  npm run compile && npm run test:coverage
}

deployer() {
  npm i && node scripts/release.js vscode --variant pkg --env "$@"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
[ -s "/usr/share/nvm/init-nvm.sh" ] && source "/usr/share/nvm/init-nvm.sh"

prompt_separator() {
  printf '\033[36m%s\033[0m\n' '------------------------------------------------------------------------------------------------------------------------------------------------------'
}

case ";${PROMPT_COMMAND:-};" in
  *";prompt_separator;"*) ;;
  *) PROMPT_COMMAND="prompt_separator${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

if [[ -n "${CXXFLAGS:-}" ]]; then
  export CXXFLAGS="${CXXFLAGS} -fexperimental-new-constant-interpreter"
else
  export CXXFLAGS="-fexperimental-new-constant-interpreter"
fi

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.opencode/bin:$PATH"
