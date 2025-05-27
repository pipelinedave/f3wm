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
2. **Configure clipmenu**: The clipmenu service may need manual configuration. If it doesn't start automatically, you can create a user systemd service.
3. **Check i3wm login**: Make sure to select i3 from your display manager when logging in.

### Known Issues

- The clipmenu systemd service might not exist by default. You may need to create `~/.config/systemd/user/clipmenud.service` manually if the service fails to start.

