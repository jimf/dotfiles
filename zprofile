# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH="~/bin:${PATH}"
fi

export PATH

export PATH="$HOME/.cargo/bin:$PATH"
