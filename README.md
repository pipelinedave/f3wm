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

## Storage Setup for New Laptop

This setup includes encrypted storage partitions for `/backup`, `/secrets`, and `/toast` that can be mounted/unmounted via dmenu (`Super+m`).

### Partitioning Your New Laptop (1TB NVMe)

During Fedora installation, use **Custom** partitioning:

1. **EFI System Partition**: 1GB (`/boot/efi`) - FAT32
2. **Boot Partition**: 1GB (`/boot`) - ext4
3. **Root Partition**: 500GB (`/`) - **BTRFS, unencrypted** (includes /home)
4. **Backup**: 250GB - **BTRFS** (encrypt later from desktop)
5. **Toast**: 200GB - **BTRFS** (encrypt later from desktop)
6. **Secrets**: 50GB - **BTRFS** (encrypt later from desktop)
7. **Remaining**: ~200GB - Leave unpartitioned for future use

**Note**: If the installer's encryption option isn't working, just create them as regular BTRFS partitions. We'll encrypt them after installation from the desktop - it's actually easier and more reliable.

### Why BTRFS for NVMe?

- **Built-in compression** (zstd) reduces wear on your SSD
- **Copy-on-write** is more SSD-friendly than ext4's journaling
- **Better space efficiency** and **snapshots** capability
- **Red Hat's future direction** - well supported in Fedora

### Post-Installation Storage Setup

After installing Fedora and running the playbook, you'll encrypt the partitions:

1. **First, identify your partitions**:

   ```bash
   sudo lsblk
   # Look for your backup, toast, and secrets partitions (probably /dev/nvme0n1p4, p5, p6)
   ```

2. **Encrypt each partition** (backup data first if any exists):

   ```bash
   # Example for backup partition (adjust device names as needed)
   sudo umount /dev/nvme0n1p4  # if mounted
   sudo cryptsetup luksFormat /dev/nvme0n1p4
   sudo cryptsetup luksOpen /dev/nvme0n1p4 backup
   sudo mkfs.btrfs -L backup /dev/mapper/backup
   sudo cryptsetup luksClose backup
   
   # Repeat for toast and secrets partitions with different names
   ```

3. **Find your new partition UUIDs**:
   ```bash
   sudo blkid -t TYPE=crypto_LUKS
   ```

4. **Update the storage configuration**:

   Edit `group_vars/all.yml` and uncomment/update these lines:

   ```yaml
   backup_partition_uuid: "your-backup-uuid-here"
   secrets_partition_uuid: "your-secrets-uuid-here"
   toast_partition_uuid: "your-toast-uuid-here"
   ```

5. **Re-run the storage role**:

   ```bash
   ansible-playbook playbook.yaml --tags storage --ask-become-pass
   ```

6. **Test the mount script**:

   ```bash
   ~/.local/bin/storage-mount-helper.sh test backup
   ```

### Storage Key Bindings

- `Super+m`: Open mount/unmount dmenu for encrypted partitions
- The script will show `[mounted]` or `[unmounted]` status for each partition
- Mounting will prompt for encryption password in a new terminal
- Unmounting will safely close the LUKS container

