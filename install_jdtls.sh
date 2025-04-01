#!/bin/bash
# Script to download and install JDTLS into the Neovim config directory

# Variables
NVIM_CONFIG_DIR="$HOME/.config/nvim"
JDTLS_VERSION="1.43.0"
JDTLS_DIR="$NVIM_CONFIG_DIR/jdtls-1.43"
JDTLS_DOWNLOAD_URL="https://download.eclipse.org/jdtls/milestones/$JDTLS_VERSION/jdt-language-server-$JDTLS_VERSION-202309291511.tar.gz"

# Create directory
mkdir -p "$JDTLS_DIR"

echo "Downloading JDTLS $JDTLS_VERSION..."
curl -L "$JDTLS_DOWNLOAD_URL" -o /tmp/jdtls.tar.gz

# Check if download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download JDTLS"
  exit 1
fi

echo "Extracting to $JDTLS_DIR..."
tar -xzf /tmp/jdtls.tar.gz -C "$JDTLS_DIR"

# Verify installation
if [ -f "$JDTLS_DIR/plugins/org.eclipse.equinox.launcher_*.jar" ]; then
  echo "JDTLS $JDTLS_VERSION installed successfully at $JDTLS_DIR"
  echo "You can now use JDTLS with Neovim."
else
  echo "JDTLS installation failed. Please check error messages above."
fi

# Clean up
rm /tmp/jdtls.tar.gz

# Create bin/jdtls script for direct execution
mkdir -p "$JDTLS_DIR/bin"
cat > "$JDTLS_DIR/bin/jdtls" << 'EOF'
#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JDTLS_HOME="$(dirname "$SCRIPT_DIR")"

# Find the launcher jar
LAUNCHER=$(find "$JDTLS_HOME/plugins" -name 'org.eclipse.equinox.launcher_*.jar')

# Create workspace directory
WORKSPACE="$HOME/.cache/jdtls/workspace/$(basename "$PWD")"
mkdir -p "$WORKSPACE"

# Run the language server
java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.level=ALL \
  -Xms1g \
  -Xmx2g \
  -jar "$LAUNCHER" \
  -configuration "$JDTLS_HOME/config_linux" \
  -data "$WORKSPACE" \
  "$@"
EOF

# Make the script executable
chmod +x "$JDTLS_DIR/bin/jdtls"
echo "Created executable script at $JDTLS_DIR/bin/jdtls"
