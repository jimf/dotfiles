###############################################################################
# SET ENVIRONMENT VARS:                                                       #
###############################################################################
(( ${+USER} )) || export USER=$USERNAME
(( ${+HOSTNAME} )) || export HOSTNAME=$HOST
(( ${+PGDATABASE} )) || export PGDATABASE='app'
(( ${+EDITOR} )) || export EDITOR=`which vim`
(( ${+VISUAL} )) || export VISUAL=`which vim`
(( ${+FCEDIT} )) || export FCEDIT=`which vim`
(( ${+PAGER} )) || export PAGER=`whence most || whence less`
(( ${+LESSOPEN} )) || export LESSOPEN='|lesspipe.sh %s'
(( ${+CC} )) || export CC='gcc'
(( ${+TERM} )) || export TERM='xterm-256color'
(( ${+SVN_EDITOR} )) || export SVN_EDITOR='vim -f --noplugin'
(( ${+DATE} )) || export DATE=`date +%F`
(( ${+VERSIONER_PERL_PREFER_32_BIT} )) || export VERSIONER_PERL_PREFER_32_BIT=yes

# Colorize manpages:
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export PGUSER='jimf'
export PGHOST='yugg'
export PGDATABASE='app'
export PGSEARCHPATH='public'

case "$HOSTNAME" in
    avatar)
        export PGHOST='localhost'
        export SERVERTYPE='dev'
        ;;
    dev*)
        export SERVERTYPE='dev'
        ;;
    *)
        export SERVERTYPE='critical'
        ;;
esac


###############################################################################
# SET PATHS:                                                                  #
###############################################################################
# Path and cdpath:
path=(~/bin /usr/local/bin /opt/local/bin $path /bin /usr/bin /opt/awutil /opt/awbin)
cdpath=(. ~ ~/Desktop ~/svn ~/svn/trunk/code/sites/aweber_app ~/svn/trunk/code/awlib)

# Adjust for root:
if (( $EUID == 0 )); then
    path=($path /sbin /usr/sbin /usr/local/sbin)
fi

# Additional function path:
if [ -d ~/.zfunc ]; then
    fpath=(~/.zfunc $fpath)
    #autoload -U ~/.zfunc/*(:t)
fi

# Manpath:
manpath=(/usr/local/man /usr/share/man)
manpath=($manpath /usr/man)

# Remove duplicate entries from paths:
typeset -gU path cdpath manpath fpath


###############################################################################
# ADJUST ENVIRONMENT:                                                         #
###############################################################################
# Set auto-logout in seconds.
if [ "`id -u`" -eq 0 ] || [[ "$SERVERTYPE" == critical ]]; then
    # 15 min timeout
   TMOUT=900
fi

# Disable the timeout on avatar. It just gets in the way.
if [[ "$HOSTNAME" == avatar ]]; then
    unset TMOUT
    if [ $SUDO_USER ]; then
        export SVN_SSH="ssh -o \"IdentitiesOnly yes\" -i $HOME/.ssh/svn-id_rsa -l $SUDO_USER"
    fi
fi

# If we are in X then disable TMOUT
case $TERM in
    *xterm*|rxvt|(dt|k|E)term)
    unset TMOUT
    ;;
esac

#bindkey -v  # Use vi key-bindings.
bindkey -e  # Use emacs key-bindings.
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Watch for everyone but me.
watch=(notme)
setopt nohup
setopt NO_beep


###############################################################################
# COLORS:                                                                     #
###############################################################################
# Enable color support of ls.
if [ -f dircolors ]; then
    eval "`dircolors -b`"
fi
if [[ "$TERM" != "dumb" ]]; then
    if [[ "`uname`" = Darwin ]]; then
        alias ls='ls -G'
        export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
    else
        alias ls='ls --color=auto'
    fi
fi

zmodload -i zsh/complist  # Color completion.


###############################################################################
# COMPLETION:                                                                 #
###############################################################################
## This allows incremental completion of a word.
## After starting this command, a list of completion
## choices can be shown after every character you
## type, which you can delete with ^h or DEL.
## RET will accept the completion so far.
## You can hit TAB to do normal completion, ^g to            
## abort back to the state when you started, and ^d to list the matches.
autoload -U incremental-complete-word
zle -N incremental-complete-word
bindkey "^Xi" incremental-complete-word ## C-x-i

## This function allows you type a file pattern,
## and see the results of the expansion at each step.
## When you hit return, they will be inserted into the command line.
autoload -U insert-files
zle -N insert-files
bindkey "^Xf" insert-files ## C-x-f

## This set of functions implements a sort of magic history searching.
## After predict-on, typing characters causes the editor to look backward
## in the history for the first line beginning with what you have typed so
## far.  After predict-off, editing returns to normal for the line found.
## In fact, you often don't even need to use predict-off, because if the
## line doesn't match something in the history, adding a key performs
## standard completion - though editing in the middle is liable to delete
## the rest of the line.
autoload -U predict-on
zle -N predict-on
zle -N predict-off
bindkey "^X^Z" predict-on ## C-x C-z
bindkey "^Z" predict-off ## C-z


###############################################################################
# HISTORY:                                                                    #
###############################################################################
HISTSIZE=5000
SAVEHIST=4500
if [ -n "$SSH_TTY" ]; then
    HISTFILE="$HOME/.zshhist_${USER}_${HOST}"
else
    HISTFILE="$HOME/.zshhist"
fi
setopt NO_hist_allow_clobber
setopt NO_hist_beep
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt append_history
setopt inc_append_history


###############################################################################
# COMPLETION:                                                                 #
###############################################################################
autoload -U compinit promptinit
compinit -u -d ~/.zcompdump_$USER
promptinit
if [ -n "$LSCOLORS" ]; then
    ZLS_COLORS="$LSCOLORS"
else
    ZLS_COLORS="$LS_COLORS"
fi
zstyle ':completion:*' list-colors ${(s.:.)ZLS_COLORS}

# Complete as much as possible:
zstyle ':completion:*' completer _complete _list _oldlist _expand _ignored _match _correct _approximate _prefix

# Allow one error for every three characters typed in approximate completer:
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# Formatting and messages:
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' file-sort name
zstyle ':completion:*' menu select=0 on=long
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache 1
#zstyle ':completion::complete:*' cache-path ~/.zcompcache/$HOST
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns \
'*?.(o|c~|old|pro|zwc)' '*~'
compdef _gnu_generic slrnpull make df du
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
setopt always_to_end

# Complete hostnames.
hosts=(avatar dev1 dev2 ogre orc shoggoth stage1 stage2 web1 web2 web3 web4)
compctl -k hosts ssh sftp scp

# Complete packages.
[ -d ~/svn/packages ] && compctl -g "~/svn/packages/*/(:t)" pkg
[ -d /opt/packages ] && compctl -g "/opt/packages/*/(:t)" pkg

# Completion for stew
function _stew {
    local line point words cword
    read -l line
    read -ln point
    read -Ac words
    read -cn cword
    words[1]=$(which $words[1])
    reply=( $( COMP_LINE="$line" COMP_POINT=$(( point-1 )) \
               COMP_WORDS="$words[*]" COMP_CWORD=$(( cword-1 )) \
               OPTPARSE_AUTO_COMPLETE=1 python $words[1] ) )
}
compctl -K _stew stew

# Make cd pushd too.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS


###############################################################################
# KEY BINDINGS:                                                               #
###############################################################################
bindkey "^Xh" run-help                           # Run help with ^Xh.
bindkey '\eOH' beginning-of-line                 # Home.
bindkey '\e[7~' beginning-of-line                # Home.
bindkey "^[[1~" beginning-of-line                # Home.
bindkey "\eOF" end-of-line                       # End  (console).
bindkey "\e[8~" end-of-line                      # End  (console).
bindkey "^[[4~" end-of-line                      # End  (console).
bindkey "\e[3~" delete-char                      # Delete.
bindkey "^u" backward-kill-line                  # Delete to beginning of line.
bindkey "^r" history-incremental-search-backward # History completion.


###############################################################################
# CONSOLE:                                                                    #
###############################################################################
## SPROMPT - the spelling prompt
SPROMPT='zsh: correct '%R' to '%r' ? ([Y]es/[N]o/[E]dit/[A]bort) '

function set_title() {
    case $TERM in
        *xterm*)
            if [ "$SSH_TTY" ] || [[ "`tty`" = /dev/pts/* ]]; then
                if [ "$USER" != jimf ]; then
                    print -Pn "\e]0;%n@%M\a"
                else
                    print -Pn "\e]0;%M\a"
                fi
            else
                print -Pn "\e]0;\a"
            fi
            ;;
    esac
}


function precmd {
    #local TERMWIDTH
    #(( TERMWIDTH = ${COLUMNS} - 1))

    ####
    ## Truncate the path if it's too long.
    #PR_FILLBAR=""
    #PR_PWDLEN=""

    #local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    #local pwdsize=${#${(%):-%~}}

    #if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
    #   ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    #else
    #   PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    #fi
    set_title
}

function preexec () {
   echo $1 | grep ^sudo >> /dev/null

   if [ $? -eq 0 ]; then
      echo -ne '\e[0;31m'
   fi
}

function setprompt () {
   setopt prompt_subst

   autoload colors zsh/terminfo
   if [[ "$terminfo[colors]" -ge 8 ]]; then
      colors
   fi
   for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
      eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
      eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
      (( count = $count + 1 ))
   done
   PR_NO_COLOUR="%{$terminfo[sgr0]%}"

   local PR_RED=$'%{\e[0;31m%}'
   local PR_GREEN=$'%{\e[1;32m%}'
   local PR_PURPLE=$'%{\e[0;35m%}'
   local PR_CYAN=$'%{\e[0;36m%}'
   local PR_GRAY=$'%{\e[1;30m%}'
   local PR_NORMAL=$'%{\e[0m%}'

   ###
   # See if we can use extended characters to look nicer.
   typeset -A altchar
   set -A altchar ${(s..)terminfo[acsc]}
   PR_SET_CHARSET="%{$terminfo[enacs]%}"
   PR_SHIFT_IN="%{$terminfo[smacs]%}"
   PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
   PR_HBAR=${altchar[q]:--}
   PR_ULCORNER=${altchar[l]:--}
   PR_LLCORNER=${altchar[m]:--}
   PR_LRCORNER=${altchar[j]:--}
   PR_URCORNER=${altchar[k]:--}

   ###
   # Decide if we need to set titlebar text.
   case $TERM in
      xterm*)
      PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
      ;;
   screen)
      PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
      ;;
   *)
      PR_TITLEBAR=''
      ;;
   esac

   ###
   # Finally, the prompt.
   PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_CYAN%(!.%SROOT%s.%n)$PR_GREEN@%m:%~\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_MAGENTA%$PR_PWDLEN<...<%l%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
${(e)PR_APM}$PR_YELLOW%D{%H:%M}\
$PR_LIGHT_BLUE:%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '
}

function define_colors() {
   RED=$'%{\e[0;31m%}'
   RED_BOLD=$'%{\e[1;31m%}'
   YELLOW=$'%{\e[0;33m%}'
   YELLOW_BOLD=$'%{\e[1;33m%}'
   GREEN=$'%{\e[0;32m%}'
   GREEN_BOLD=$'%{\e[1;32m%}'
   PURPLE=$'%{\e[0;35m%}'
   PURPLE_BOLD=$'%{\e[1;35m%}'
   CYAN=$'%{\e[0;36m%}'
   CYAN_BOLD=$'%{\e[1;36m%}'
   GRAY=$'%{\e[1;30m%}'
   NORMAL=$'%{\e[0m%}'
   INVERT=$'%{\e[7m%}'
   #RED=$'%{\e[0;31;44m%}'
   #RED_BOLD=$'%{\e[1;31;44m%}'
   #YELLOW=$'%{\e[0;33;44m%}'
   #YELLOW_BOLD=$'%{\e[1;33;44m%}'
   #GREEN=$'%{\e[0;32;44m%}'
   #GREEN_BOLD=$'%{\e[1;32;44m%}'
   #PURPLE=$'%{\e[0;35;44m%}'
   #CYAN=$'%{\e[0;36;44m%}'
   #CYAN_BOLD=$'%{\e[1;36;44m%}'
   #GRAY=$'%{\e[1;30;44m%}'
   #NORMAL=$'%{\e[0;44m%}'
   #INVERT=$'%{\e[7m%}'
}

# Define prompt.
function set_prompt() {
   local current_tty=`tty | sed -e "s/\/dev\/\(.*\)/\1/"`
   local name=""
   local host=""

   if [ "$USER" != jimf ]; then
      name="$C3%n"
   fi

   if [ "$SSH_TTY" ] || [[ "`tty`" = /dev/pts/* ]]; then
      host="$C5%m$C6: "
   fi

   if [ -n "$name" ] && [ -n "$host" ]; then
      host="$C4@$host"
   fi

   PS1="$C1%D{%H:%M} $C2($name$host$C7%3~$C8)$C9%(!.#.$)$NORMAL "
}

#setprompt

# Source aliases.
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

bgdark
set_title

#if [ -n "$SSH_TTY" ] && [ -z "$SCREEN_EXIST" ]; then
#   if which screen > /dev/null; then
#      export SCREEN_EXIST=1
#      screen -DR && exit
#   fi
#fi
# According to http://nicolas.barcet.com/drupal/screen-by-default, -xRR is better
if [ -n "$SSH_TTY" ]; then
    if [[ "$TERM" != screen* ]]; then
        if which screen > /dev/null; then
            screen -xRR && [ ! -e /tmp/stayloggedin ] && exit
            [ -e /tmp/stayloggedin ] && rm -f /tmp/stayloggedin
        fi
    else
        [ -f /etc/motd ] && [ "$EUID" != 0 ] && cat /etc/motd
    fi
fi
