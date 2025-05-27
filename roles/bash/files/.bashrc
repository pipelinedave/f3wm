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

# start ssh-agent
# Set up ssh-agent
SSH_ENV="$HOME/.ssh/agent-environment"

# Function to start the agent
start_agent() {
    # First, ensure the target directory for SSH_ENV exists
    if [ ! -d "$HOME/.ssh" ]; then
        echo "SSH Agent: $HOME/.ssh directory not found. Cannot start agent."
        echo "Please ensure your encrypted partition is mounted and then open a new terminal or run 'source ~/.bashrc'."
        return 1 # Indicate failure
    fi

    echo "Initializing new SSH agent..."
    # Start the agent and save its environment variables
    # Ensure we can write to SSH_ENV
    if ssh-agent -s > "${SSH_ENV}"; then
        chmod 600 "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        ssh-add "$HOME/.ssh/id_ed25119" "$HOME/.ssh/id_ed25119_for_github"
    else
        echo "SSH Agent: Failed to start ssh-agent or write to ${SSH_ENV}."
        # Clean up if SSH_ENV was partially created or is invalid
        rm -f "${SSH_ENV}"
        return 1 # Indicate failure
    fi
}

# Source SSH settings if the environment file exists and the agent is running
# Main agent logic: Only proceed if $HOME/.ssh is accessible
if [ -d "$HOME/.ssh" ]; then
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        # Check if the agent is actually running
        # (ps -p is more reliable than ps -ef | grep)
        if ! ps -p "${SSH_AGENT_PID}" > /dev/null 2>&1; then
            # Agent is not running, or SSH_AGENT_PID is not set/stale
            start_agent
        fi
    else
        # No environment file, so start the agent
        start_agent
    fi
else
    # $HOME/.ssh is not available. Inform the user.
    echo "SSH Agent: $HOME/.ssh not found. SSH agent setup deferred."
    echo "Once your encrypted partition is mounted, open a new terminal or run 'source ~/.bashrc'."
fi

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

# Exit if not running interactively
case $- in
    *i*) ;;
      *) return;;
esac

unset rc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# kubectl shell completion
source <(kubectl completion bash)
source <(argocd completion bash)
source <(minikube completion bash)
source <(dsc generate-completions --shell bash)
source <(skaffold completion bash)
source <(flux completion bash)
source <(ethdo completion bash)

. "$HOME/.cargo/env"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin