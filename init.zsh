#
# Utility aliases and settings
#

#
# ls aliases
#

alias ll='ls -lh'       # Long format and human-readable sizes
alias l='ll -A'         # Long format, all files
[[ -n ${PAGER} ]] && alias lm="l | ${PAGER}" # Long format, all files, use pager
alias lr='ll -R'        # Long format, recursive
alias lk='ll -Sr'       # Long format, largest file size last
alias lt='ll -tr'       # Long format, newest modification time last
alias lc='lt -c'        # Long format, newest status change (ctime) last


#
# File downloads
#

# Order of preference: aria2c, axel, wget, curl. This order is derrived from speed based on personal tests.
if (( ${+commands[aria2c]} )); then
  alias get='aria2c --max-connection-per-server=5 --continue'
elif (( ${+commands[axel]} )); then
  alias get='axel --num-connections=5 --alternate'
elif (( ${+commands[wget]} )); then
  alias get='wget --continue --progress=bar --timestamping'
elif (( ${+commands[curl]} )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
fi


#
# Resource usage
#

alias df='df -h'
alias du='du -h'


#
# Colours
#

if (( terminfo[colors] >= 8 )); then
  # grep colours
  (( ! ${+GREP_COLOR} )) && export GREP_COLOR='37;45'               #BSD
  (( ! ${+GREP_COLORS} )) && export GREP_COLORS="mt=${GREP_COLOR}"  #GNU
  if [[ ${OSTYPE} == openbsd* ]]; then
    (( ${+commands[ggrep]} )) && alias grep='ggrep --color=auto'
  else
   alias grep='grep --color=auto'
  fi

  # less colours
  if (( ${+commands[less]} )); then
    (( ! ${+LESS_TERMCAP_mb} )) && export LESS_TERMCAP_mb=$'\E[1;31m'   # Begins blinking
    (( ! ${+LESS_TERMCAP_md} )) && export LESS_TERMCAP_md=$'\E[1;31m'   # Begins bold
    (( ! ${+LESS_TERMCAP_me} )) && export LESS_TERMCAP_me=$'\E[0m'      # Ends mode
    (( ! ${+LESS_TERMCAP_se} )) && export LESS_TERMCAP_se=$'\E[0m'      # Ends standout-mode
    (( ! ${+LESS_TERMCAP_so} )) && export LESS_TERMCAP_so=$'\E[7m'      # Begins standout-mode
    (( ! ${+LESS_TERMCAP_ue} )) && export LESS_TERMCAP_ue=$'\E[0m'      # Ends underline
    (( ! ${+LESS_TERMCAP_us} )) && export LESS_TERMCAP_us=$'\E[1;32m'   # Begins underline
  fi
else
  # See https://no-color.org
  export NO_COLOR=1
fi


#
# GNU vs. BSD
#

if (( ${+commands[dircolors]} )) && ls --version &>/dev/null; then
  # GNU

  # ls aliases
  alias lx='ll -X' # Long format, sort by extension

  # ls colours
  if (( ! ${+NO_COLOR} )); then
    (( ! ${+LS_COLORS} )) && if [[ -s ${HOME}/.dir_colors ]]; then
      eval "$(dircolors --sh ${HOME}/.dir_colors)"
    else
      export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43'
    fi
    alias ls='ls --group-directories-first --color=auto'
  fi

  # Always wear a condom
  alias chmod='chmod --preserve-root -v'
  alias chown='chown --preserve-root -v'

  # Not aliasing rm -i, but if safe-rm is available, use condom.
  # If safe-rmdir is also available, the OS is suse which has its own terrible safe-rm which is not what we want.
  if (( ${+commands[safe-rm]} && ! ${+commands[safe-rmdir]} )); then
    alias rm='safe-rm'
  fi
else
  # BSD

  # ls colours
  if (( ! ${+NO_COLOR} )); then
    (( ! ${+CLICOLOR} )) && export CLICOLOR=1
    (( ! ${+LSCOLORS} )) && export LSCOLORS='ExfxcxdxbxGxDxabagacad'

    # Stock OpenBSD ls does not support colors at all, but colorls does.
    if [[ ${OSTYPE} == openbsd* && ${+commands[colorls]} -ne 0 ]]; then
      alias ls='colorls'
    fi
  fi
fi
