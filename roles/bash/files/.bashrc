# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Enable usage of file dialogs and somesuch
export GTK_USE_PORTAL=1

# Fancy coloured prompt
export PS1="\[\033[01;33m\]\u@\h \W\$\[\033[00m\] "

# Set Window title to last run command
trap 'echo -ne "\033]0;${BASH_COMMAND}\007"' DEBUG

# Set keyboard speed to something snazzy
xset r rate 175 75

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
