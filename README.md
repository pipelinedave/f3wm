# f3wm Configuration

Welcome to the f3wm project - your Fedora-i3wm blend, crafted to bring the sleekness of i3wm into the robust Fedora environment, spiced up with Polybar for that extra flair.

## Getting Started

These instructions will get your very own f3wm environment set up and rolling. We'll be using Ansible, so make sure you're somewhat familiar with its rhythms.

### Prerequisites

Before we hit the play button, make sure you've got the following ready:
- A Fedora workstation, fresh and clean.
- Ansible installed (`sudo dnf install ansible` - as simple as a drum beat).
- Git installed (`sudo dnf install git`).
- Your soul filled with the love for a minimalist yet functional desktop environment.

### Installation

Follow these steps to get your environment set up:

1. Clone this repository to your local machine:
   ```bash
   git clone <your-repository-url>
   cd f3wm
   ```

2. Run the Ansible playbook:

   ```bash
   ansible-playbook --ask-become-pass playbook.yaml
   ```

This step will install i3wm, Polybar, and place all the necessary configuration files in their rightful places. It will ask for your sudo password - that's your key to the backstage.

### Post-Installation Notes

After the playbook runs successfully:

1. **Log out and log back in** (or reboot) to see the changes.
2. **Select i3 from your display manager** when logging in.
3. **Configure clipmenu**: The clipmenu systemd service should start automatically.
4. **Test your setup**: Try the key bindings:
   - `$mod+d` for dmenu application launcher  
   - `$mod+v` for clipboard manager
   - `$mod+Return` for terminal (Alacritty)
   - `$mod+n` for scratchpad notes

### Known Issues

- Some additional packages like `pins` might not be available in all Fedora repositories.
- If clipmenu doesn't work initially, restart the service: `systemctl --user restart clipmenud`
- SSH keys setup in `.bashrc` assumes specific key names - adjust if needed.

