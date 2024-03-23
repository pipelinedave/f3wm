#!/bin/bash

# Directory where the launcher scripts for Flatpak applications will be placed
FLATPAK_BIN_DIR="$HOME/.local/bin/"

# Create the directory if it doesn't exist
mkdir -p "${FLATPAK_BIN_DIR}"

# List all installed Flatpak applications
flatpak list --app --columns=app | while read -r app_full_id; do
  # Extract the last part of the application ID for a more recognizable name
  app_name=$(echo "${app_full_id}" | awk -F '.' '{print $NF}' | tr '[:lower:]' '[:upper:]' | sed 's/_/ /g')

  # Create a simple, more readable name by capitalizing the first letter
  readable_name=$(echo "${app_name}" | tr '[:upper:]' '[:lower:]' | sed 's/_/ /g')

  # Generate a launcher script for each application
  echo -e "#!/bin/bash\nflatpak run ${app_full_id}" > "${FLATPAK_BIN_DIR}/${readable_name}"

  # Make the launcher script executable
  chmod +x "${FLATPAK_BIN_DIR}/${readable_name}"
done

