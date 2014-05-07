# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#zsh && exit

###############################################################################
# SET ENVIRONMENT VARS:                                                       #
###############################################################################
export VISUAL=vi   # Make Vim the default editor.
export SVN_EDITOR="vim -f"   # Make Vim the default editor.
export GTK2_RC_FILES=~/.gtkrc-2.0
export PGDATABASE=app

# Colorize manpages:
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

case "$HOSTNAME" in
   'jimf-laptop')
      export PGSEARCHPATH='subset'
      ;;
   'avatar')
      export PGSEARCHPATH='subset'
      ;;
   *)
      export PGSEARCHPATH='public'
      ;;
esac


###############################################################################
# SET PATHS:                                                                  #
###############################################################################
export PATH=~/bin:/opt/local/bin:/opt/awutil:/opt/awbin:"${PATH}"
export CDPATH=.:~:~/svn:~/svn/trunk/code/sites/aweber_app:~/svn/trunk/code/sites:~/svn/trunk/code/awlib

# Adjust for root:
if (( $EUID == 0 )); then
   export PATH=/sbin:/usr/sbin:/usr/local/sbin:"${PATH}"
fi


###############################################################################
# ADJUST ENVIRONMENT:                                                         #
###############################################################################
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


###############################################################################
# COLORS:                                                                     #
###############################################################################
# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    if [[ "`uname`" = Darwin ]]; then
        alias ls='ls -G'
    else
        eval "`dircolors -b`"
        alias ls='ls --color=auto'
    fi
fi


###############################################################################
# HISTORY:                                                                    #
###############################################################################
export HISTFILESIZE=5000
export HISTCONTROL=ignoredups
export HISTCONTROL=ignoreboth


###############################################################################
# COMPLETION:                                                                 #
###############################################################################
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

shopt -s cdspell


###############################################################################
# CONSOLE:                                                                    #
###############################################################################
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
function define_colors() {
   DULL=0
   BRIGHT=1

   FG_BLACK=30
   FG_RED=31
   FG_GREEN=32
   FG_YELLOW=33
   FG_BLUE=34
   FG_PURPLE=35
   FG_CYAN=36
   FG_WHITE=37

   FG_NULL=00

   BG_BLACK=40
   BG_RED=41
   BG_GREEN=42
   BG_YELLOW=43
   BG_BLUE=44
   BG_PURPLE=45
   BG_CYAN=46
   BG_WHITE=47

   BG_NULL=00

   RED="\[\033[0;${FG_RED}m\]"
   RED_BOLD="\[\033[1;${FG_RED}m\]"
   GREEN="\[\033[0;${FG_GREEN}m\]"
   GREEN_BOLD="\[\033[1;${FG_GREEN}m\]"
   YELLOW="\[\033[0;${FG_YELLOW}m\]"
   YELLOW_BOLD="\[\033[1;${FG_YELLOW}m\]"
   PURPLE="\[\033[0;${FG_PURPLE}m\]"
   PURPLE_BOLD="\[\033[1;${FG_PURPLE}m\]"
   CYAN="\[\033[0;${FG_CYAN}m\]"
   CYAN_BOLD="\[\033[1;${FG_CYAN}m\]"
   GRAY="\[\033[1;${FG_BLACK}m\]"
   NORMAL="\[\033[0m\]"
}

# Define prompt.
function set_prompt() {
   local current_tty=`tty | sed -e "s/\/dev\/\(.*\)/\1/"`
   local name=""
   local host=""

   if  [ "$USER" != jimf ]; then
       name="$C2%n"
   fi

   if [ "$SSH_TTY" ]; then
       host="$C4%m$C5: "
   fi

   PS1="$C1\$(date +"%R") $name$C3($host$C6\w$C7)${C8}\\$ ${NORMAL}"
}


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac

# Define your own aliases here ...
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

bgdark

#if [ -n "$SSH_TTY" ] && [ -z "$SCREEN_EXIST" ]; then
#   export SCREEN_EXIST=1
#   screen -DR && exit
#fi
# According to http://nicolas.barcet.com/drupal/screen-by-default, -xRR is better
if [ -n "$SSH_TTY" ] && [[ "$TERM" != screen* ]]; then
   screen -xRR && exit
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
