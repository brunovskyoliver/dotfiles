# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="/home/brunovsky/.local/bin:$PATH"
export PATH="/Applications/Emacs.app/Contents/MacOS:$PATH"
export PATH="$HOME/.local/scripts:$PATH"
bindkey -s ^f "vim-fzf\n"
# bindkey -s ^s "ssh-connections\n"

#alias remf='rm -rf "$HOME/Library/Containers/com.apple.FinalCutTrial/Data/Library/Application Support/.ffuserdata"'
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="ys"
#ZSH_THEME="robbyrussell"
##### Aliases #####
# Enable colors by default.
alias diff='diff --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias air='~/go/bin/air'
# Replace utilities with their equivalents.
alias cat='bat --pager=never --style=plain'
alias sudo='sudo '
alias gdb='arm-none-eabi-gdb'
alias vim='nvim'
locip() {
  ifconfig | grep -Eo 'inet (192\.[0-9]+\.[0-9]+\.[0-9]+)' | awk '{print $2}' | xargs
}
alias b='w3m "$(cat ~/.cache/last_url)" -o accept_encoding="identity;q=0"'
alias n='echo "$(cat ~/.cache/preloaded_buffer)" | nvim -'
alias nb='newsboat --refresh-on-start'

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions sudo copyfile z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# bun completions
[ -s "/Users/oliver/.bun/_bun" ] && source "/Users/oliver/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/oliver/Documents/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/oliver/Documents/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/oliver/Documents/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/oliver/Documents/google-cloud-sdk/completion.zsh.inc'; fi


alias gcssh='gcloud compute ssh --zone "europe-north1-a" "debianvm" --project "podman-417414" && ssh-add -K -'

weather() {
  if [ -z "$1" ]; then
    curl wttr.in
  else
    curl "wttr.in/$1"
  fi
}
alias m='insect'
alias pd='cd ~/Documents/Programming'
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
eval "$(zoxide init zsh)"
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/tcl-tk/lib"
export CPPFLAGS="-I/opt/homebrew/opt/tcl-tk/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/tcl-tk/lib/pkgconfig"
export PATH="/usr/local/bin:$PATH"
export PATH="/Library/Frameworks/Mono.framework/Versions/6.12.0/bin:$PATH"
t() { command tre -l "3" "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
cl() { find . -name "$1" -type f -exec wc -l {} + | sort -n }
export DOTNET_ROOT=/usr/local/share/dotnet
export PATH="$DOTNET_ROOT:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/go/bin:$PATH"

