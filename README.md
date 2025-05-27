# f3wm - Fedora i3wm Configuration

Welcome to the f3wm project! This Ansible playbook is designed to configure a Fedora Linux system with the i3wm tiling window manager, Polybar for a feature-rich status bar, and a suite of essential applications and custom scripts for a productive and personalized environment.

## Overview

This project automates the setup of:

- i3wm (Window Manager)
- Polybar (Status Bar)
- Alacritty (Terminal Emulator)
- Neovim (Text Editor, with scratchpad functionality)
- dmenu (Application Launcher)
- clipmenu (Clipboard Manager)
- Custom scripts for enhanced workflow (e.g., storage mounting, PWA launching)
- RPM Fusion repositories for wider software availability
- LUKS-encrypted BTRFS data partitions (manual setup assisted by Ansible)

It's primarily targeted for Fedora 39+ (with considerations for Fedora 42 compatibility).

## Prerequisites

- A **fresh Fedora Linux installation** is highly recommended.
- **Ansible**: `sudo dnf install ansible-core` (or `ansible` if `ansible-core` is not found).
- **Git**: `sudo dnf install git`.
- Your user account must have `sudo` privileges (the playbook will use `become` for tasks requiring root access).
- **Internet connection** for downloading packages and cloning the repository.

## Installation Steps

### 1. Clone the Repository

```bash
git clone <your-repository-url> # Replace with your actual repository URL
cd f3wm
```

### 2. Plan and Partition Your Storage (Crucial for New Systems with Encrypted Data)

If you intend to use the encrypted data partition setup (`/backup`, `/secrets`, `/toast`), you **must** partition your drive correctly during the Fedora installation.

**Recommended Partitioning Scheme (Example for a 1TB NVMe):**

During the Fedora installation, choose **Custom** partitioning:

1. **EFI System Partition**: 1GB, Mount Point: `/boot/efi`, Type: `FAT32`
2. **Boot Partition**: 1GB, Mount Point: `/boot`, Type: `ext4`
3. **Root Partition**: 500GB (adjust as needed), Mount Point: `/`, Type: **BTRFS (unencrypted)**. This will typically include `/home`.
4. **Data Partition 1 (e.g., Backup)**: 250GB, Type: **BTRFS (unencrypted for now)**. *Do not assign a mount point yet.*
5. **Data Partition 2 (e.g., Toast)**: 200GB, Type: **BTRFS (unencrypted for now)**. *Do not assign a mount point yet.*
6. **Data Partition 3 (e.g., Secrets)**: 50GB, Type: **BTRFS (unencrypted for now)**. *Do not assign a mount point yet.*
7. *(Optional)* Leave any remaining space unallocated for future use.

**Important Notes on Partitioning:**

- Create the data partitions (Backup, Toast, Secrets) as standard BTRFS partitions **without encryption** during the OS installation. We will encrypt them *after* Fedora is installed and the main playbook has run. This approach is generally more reliable.
- If you are **not** using this encrypted data partition scheme, you can proceed with a simpler partitioning layout. The `storage` role in the playbook is tagged and can be skipped if not needed.

**Why BTRFS for NVMe?**

- Built-in compression (e.g., zstd) can reduce write amplification and save space.
- Copy-on-Write (CoW) is generally more SSD-friendly than traditional journaling.
- Features like snapshots and better space efficiency for subvolumes.
- Strong support within Fedora.

### 3. Run the Ansible Playbook

Execute the main playbook. This will install software, copy configuration files, and set up most of the environment.

```bash
ansible-playbook playbook.yaml --ask-become-pass
```

You will be prompted for your sudo password.

## Post-Playbook Setup: Encrypting Data Partitions

If you partitioned your drive for encrypted data storage as described in Step 2, follow these manual steps **after** the main Ansible playbook has completed successfully:

### 1. Identify Your Data Partitions

Use `lsblk` to find the device names for the BTRFS partitions you created for Backup, Toast, and Secrets.

```bash
sudo lsblk -f
# Look for your BTRFS partitions (e.g., /dev/nvme0n1p4, /dev/nvme0n1p5, etc.)
```

### 2. Encrypt Each Data Partition

For each partition you intend to encrypt (e.g., `/dev/nvme0n1pX`):

```bash
# Example for the 'backup' partition. Adjust device name and LUKS mapping name.
sudo umount /dev/nvme0n1pX  # If it was auto-mounted
sudo cryptsetup luksFormat /dev/nvme0n1pX
# Enter YES (in uppercase) and set a strong passphrase when prompted.

sudo cryptsetup luksOpen /dev/nvme0n1pX backup_crypt
# 'backup_crypt' is the temporary name for the mapped device. Choose unique names.

sudo mkfs.btrfs -L backup /dev/mapper/backup_crypt
# This formats the encrypted container with BTRFS and sets the label 'backup'.

sudo cryptsetup luksClose backup_crypt

# Repeat for 'toast' (e.g., luksOpen as 'toast_crypt', mkfs.btrfs -L 'toast')
# Repeat for 'secrets' (e.g., luksOpen as 'secrets_crypt', mkfs.btrfs -L 'secrets')
```

### 3. Obtain LUKS Partition UUIDs

Get the UUIDs of the newly LUKS-formatted partitions:

```bash
sudo blkid -t TYPE=crypto_LUKS
```

Copy the UUID values for your backup, toast, and secrets partitions.

### 4. Update Ansible Group Variables

Edit the `group_vars/all.yml` file in your cloned repository:

```yaml
# group_vars/all.yml
# Ensure these are uncommented and have the correct UUIDs from the blkid command
# backup_partition_uuid: "YOUR-BACKUP-PARTITION-UUID-HERE"
# secrets_partition_uuid: "YOUR-SECRETS-PARTITION-UUID-HERE"
# toast_partition_uuid: "YOUR-TOAST-PARTITION-UUID-HERE"
```

Replace the placeholder UUIDs with the actual UUIDs you obtained.

### 5. Re-run the Ansible 'storage' Role

This will configure `/etc/crypttab` and `/etc/fstab` to automatically manage and mount your encrypted partitions using the UUIDs.

```bash
ansible-playbook playbook.yaml --tags storage --ask-become-pass
```

### 6. Reboot and Test

Reboot your system. After logging back into i3, your encrypted partitions should not be mounted automatically but should be ready for on-demand mounting.

Test the storage mount helper script (default keybinding `Super+m`):

- This should open a dmenu prompt listing your configured encrypted partitions (`backup`, `secrets`, `toast`).
- Selecting a partition will prompt for its LUKS passphrase in a new terminal.
- Once mounted, they will be accessible at `/mnt/backup`, `/mnt/secrets`, and `/mnt/toast`.
- Selecting a mounted partition from the dmenu will offer to unmount it.

You can also test the helper script directly:

```bash
~/.local/bin/storage-mount-helper.sh test backup
```

## Usage and Key Functionality

- **Login**: After the playbook runs and you've rebooted, select "i3" from your display manager's session menu.
- **Keybindings (Common)**:
  - `$mod+Return`: Open Alacritty terminal.
  - `$mod+d`: Launch application dmenu.
  - `$mod+v`: Launch clipmenu (clipboard history).
  - `$mod+n`: Toggle Neovim scratchpad terminal.
  - `$mod+m`: Open dmenu for mounting/unmounting encrypted storage.
  - `$mod+Shift+s`: Take a screenshot (using `maim`).
  - *(Refer to `roles/i3wm/files/config` for the full list of i3 keybindings).*
- **Polybar**: Provides workspace indicators, system tray, i3 layout/mode, power profile switcher, date/time, etc.
- **Custom Scripts**: Various scripts are copied to `~/.config/i3/scripts/` and `~/.local/bin/` to enhance functionality.

## Customization

- **i3wm Configuration**: `roles/i3wm/files/config`
- **Polybar Configuration**: `roles/polybar/files/config.ini` and associated scripts in `roles/polybar/files/`.
- **Alacritty Configuration**: `roles/alacritty/files/alacritty.toml`
- **Neovim Configuration**: `roles/neovim/files/nvim/init.vim`
- **Adding Custom Scripts**:
    1. Place script files in `roles/i3wm/files/scripts/` (for i3-specific scripts) or create a new role for more general scripts.
    2. Ensure the `i3wm` role (or your new role) copies them to an appropriate location (e.g., `~/.config/i3/scripts/` or `~/.local/bin/`).
    3. Make them executable using the `ansible.builtin.file` module with `mode: '0755'`.
    4. Update your i3 config (`roles/i3wm/files/config`) to bind them to keys if needed.

## Troubleshooting and Known Points

- **Clipmenu Service**: The `clipmenud.service` (systemd user service) should be enabled and started by the `clipmenu` role. If you encounter issues, check its status: `systemctl --user status clipmenud.service` and logs: `journalctl --user -u clipmenud.service`.
- **SSH Key Paths in `.bashrc`**: The `.bashrc` copied by the `bash` role might have example SSH agent setup. If you use non-standard SSH key names or paths, you may need to adjust `roles/bash/files/.bashrc` accordingly before running the playbook or modify `~/.bashrc` post-installation.
- **Idempotency**: The playbook is designed to be idempotent, meaning it can be run multiple times without adverse effects. However, for the initial setup, a fresh Fedora installation is recommended.
- **Fedora Versioning**: While designed with Fedora 39/42 in mind, package names or availability can change between Fedora releases. The `rpmfusion` role attempts to handle repository versions dynamically.

---

This README should provide a much clearer guide. Let me know if you want any sections expanded or clarified further!
