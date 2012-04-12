# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="../custom/themes/jimf"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want disable red dots displayed while waiting for completion
# DISABLE_COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(extract git vagrant)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
###############################################################################
# SET PATHS:                                                                  #
###############################################################################
path=(~/bin /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin /opt/local/bin /usr/local/bin $path /bin /usr/bin /opt/awutil /opt/awbin)
if (( $EUID == 0 )); then
    path=($path /sbin /usr/sbin /usr/local/sbin)
fi
cdpath=(. ~ ~/Desktop ~/svn ~/svn/trunk/code/sites/aweber_app ~/svn/trunk/code/awlib)
manpath=(/usr/local/man /usr/share/man)
manpath=($manpath /usr/man)
[ -d ~/.zfunc ] && fpath=(~/.zfunc $fpath)

typeset -gU path cdpath manpath fpath


###############################################################################
# SET ENVIRONMENT VARS:                                                       #
###############################################################################
(( ${+USER} )) || export USER=$USERNAME
(( ${+HOSTNAME} )) || export HOSTNAME=$HOST
(( ${+EDITOR} )) || export EDITOR=`which vim`
(( ${+VISUAL} )) || export VISUAL=`which vim`
(( ${+FCEDIT} )) || export FCEDIT=`which vim`
(( ${+PAGER} )) || export PAGER=`whence most || whence less`
(( ${+LESSOPEN} )) || export LESSOPEN='|lesspipe.sh %s'
(( ${+CC} )) || export CC='gcc'
(( ${+TERM} )) || export TERM='xterm-256color'
#(( ${+SVN_EDITOR} )) || export SVN_EDITOR='vim -f --noplugin'
(( ${+SVN_EDITOR} )) || export SVN_EDITOR=`which vim`
(( ${+GIT_EDITOR} )) || export GIT_EDITOR=`which vim`
(( ${+DATE} )) || export DATE=`date +%m-%d`
(( ${+VERSIONER_PERL_PREFER_32_BIT} )) || export VERSIONER_PERL_PREFER_32_BIT=yes
(( ${+PGHOST} )) || export PGHOST=yugg.colo.lair
(( ${+PGPORT} )) || export PGPORT=6000
(( ${+PGDATABASE} )) || export PGDATABASE=app
(( ${+NODE_PATH} )) || export NODE_PATH=/usr/local/lib/jsctags/:$HOME/git/doctorjs/lib/jsctags/:$NODE_PATH
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
case "$HOSTNAME" in
    dev*)
        export SERVERTYPE='dev'
        ;;
    *)
        export SERVERTYPE='critical'
        ;;
esac

if [ "`id -u`" -eq 0 ] || [[ "$SERVERTYPE" == critical ]]; then
   TMOUT=900  # 15 min timeout
fi

case $TERM in
    *xterm*|rxvt|(dt|k|E)term)
    unset TMOUT
    ;;
esac


###############################################################################
# ADJUST ENVIRONMENT:                                                         #
###############################################################################
setopt extended_glob
watch=(notme)
setopt nohup
setopt NO_beep


###############################################################################
# COMPLETION:                                                                 #
###############################################################################

# Complete packages.
[ -d ~/svn/packages ] && compctl -g "~/svn/packages/*/(:t)" pkg
[ -d /opt/packages ] && compctl -g "/opt/packages/*/(:t)" pkg

function preexec () {
    # Output sudo commands in red
    if [[ "${1[0,4]}" = sudo ]]; then
        echo -ne '\e[0;31m'
    # Prepend ack with a purple bar
    elif [[ "${1[0,3]}" = ack ]]; then
        echo -ne '\e[0;35m'
        printf "%$(tput cols)s\n"|tr ' ' '─'
        echo -ne '\e[0m'
    fi
}

function chpwd () {
    ls
}

# According to http://nicolas.barcet.com/drupal/screen-by-default, -xRR is better
if [ -n "$SSH_TTY" ]; then
    if [[ "$TERM" != screen* ]]; then
        if which screen > /dev/null; then
            screen -xRR && [ ! -e /tmp/stayloggedin ] && exit
            [ -e /tmp/stayloggedin ] && rm -f /tmp/stayloggedin
        fi
    else
        [ -f /etc/motd ] && [ "$EUID" != 0 ] && cat /etc/motd
        [ -f /etc/zsh/zprofile ] && [ "$EUID" != 0 ] && source /etc/zsh/zprofile
    fi
fi
