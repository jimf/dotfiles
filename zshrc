# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="jimf"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(extract vagrant npm grunt rbenv)
builtin which -s git &>/dev/null && plugins+=(git)

source $ZSH/oh-my-zsh.sh &>/dev/null

# Customize to your needs...
###############################################################################
# SET PATHS:                                                                  #
###############################################################################
# command -v node >/dev/null 2>&1 && export NODE_VERSION=$(node --version | tr -d v)
# path=(~/bin /Applications/MacVim.app/Contents/MacOS /usr/local/n/versions/node/$NODE_VERSION/bin /usr/local/bin /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin /opt/local/bin $path /bin /usr/bin /opt/awutil /opt/awbin)
path=(~/bin /Applications/MacVim.app/Contents/MacOS /usr/local/bin /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin /opt/local/bin $path /bin /usr/bin /opt/awutil /opt/awbin)
if (( $EUID == 0 )); then
    path=($path /sbin /usr/sbin /usr/local/sbin)
fi
cdpath=(. ~ ~/git)
manpath=(/usr/local/man /usr/local/share/man /usr/share/man /usr/man)
[ -d ~/.zfunc ] && fpath=(~/.zfunc $fpath)
export FPATH="$FPATH:/opt/local/share/zsh/site-functions/"
if [ -f /opt/local/etc/profile.d/autojump.sh ]; then
    source /opt/local/etc/profile.d/autojump.sh
fi

typeset -gU path cdpath manpath fpath


###############################################################################
# SET ENVIRONMENT VARS:                                                       #
###############################################################################
(( ${+USER} )) || export USER=$USERNAME
(( ${+HOSTNAME} )) || export HOSTNAME=$HOST
(( ${+EDITOR} )) || export EDITOR=`which vim`
(( ${+VISUAL} )) || export VISUAL=`which vim`
(( ${+FCEDIT} )) || export FCEDIT=`which vim`
(( ${+LESSOPEN} )) || export LESSOPEN='|lesspipe.sh %s'
(( ${+CC} )) || export CC='gcc'
#(( ${+SVN_EDITOR} )) || export SVN_EDITOR='vim -f --noplugin'
(( ${+SVN_EDITOR} )) || export SVN_EDITOR=`builtin which vim`
(( ${+GIT_EDITOR} )) || export GIT_EDITOR=`builtin which vim`
(( ${+DATE} )) || export DATE=`date +%m-%d`
(( ${+YDATE} )) || export YDATE=`date +%Y-%m-%d`
(( ${+VERSIONER_PERL_PREFER_32_BIT} )) || export VERSIONER_PERL_PREFER_32_BIT=yes
# (( ${+PGHOST} )) || export PGHOST=yugg.colo.lair
# (( ${+PGPORT} )) || export PGPORT=6000
# (( ${+PGDATABASE} )) || export PGDATABASE=app
# (( ${+NODE_PATH} )) || export NODE_PATH=/usr/local/n/versions/node/$NODE_VERSION/lib/node_modules:/usr/local/lib/node_modules:/usr/local/lib/jsctags/:$HOME/git/doctorjs/lib/jsctags/:$NODE_PATH
# (( ${+NODE_PATH} )) || export NODE_PATH=/usr/local/bin:/usr/local/lib/node_modules:/usr/local/lib/jsctags/:$HOME/git/doctorjs/lib/jsctags/:$NODE_PATH
(( ${+REPORTTIME} )) || export REPORTTIME=10

if [ -z "$SSH_TTY" ] && [ -z "$TMUX" ]; then
    if [ -e /usr/share/terminfo/78/xterm-256color ] || [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM=xterm-256color
    fi
fi
export PAGER="less -R"

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
if [ -n "$SSH_TTY" ]; then
    case "$HOSTNAME" in
        dev*)
            export SERVERTYPE='dev'
            ;;
        *)
            export SERVERTYPE='critical'
            ;;
    esac
fi

if [ "`id -u`" -eq 0 ] || [[ "$SERVERTYPE" == critical ]]; then
   TMOUT=900  # 15 min timeout
fi

case $TERM in
    *xterm*|rxvt|(dt|k|E)term)
    unset TMOUT
    ;;
esac

if [ -e "$HOME"/perl5 ]; then
    source "$HOME/perl5/perlbrew/etc/bashrc"
fi

if command -v pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi

if command -v pyenv-virtualenv-init > /dev/null; then
    eval "$(pyenv virtualenv-init -)"
fi

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
