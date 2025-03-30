#!/bin/bash
# Script to debug JDTLS issues by running the server directly

echo "=== JDTLS Diagnostic Script ==="

# Create clean directories with all permissions
CACHE_DIR="$HOME/.cache/jdtls_debug"
WORKSPACE_DIR="$CACHE_DIR/workspace"
TEMP_DIR="$CACHE_DIR/temp"
LOG_FILE="$CACHE_DIR/jdtls_direct.log"

# Clean previous debug attempt
rm -rf "$CACHE_DIR"
mkdir -p "$WORKSPACE_DIR" "$TEMP_DIR"
chmod -R 777 "$CACHE_DIR"

echo "Created debug directories in $CACHE_DIR"

# Find Java
JAVA_CMD=$(which java)
if [ -z "$JAVA_CMD" ]; then
  echo "Error: Java not found in PATH"
  exit 1
fi

echo "Using Java: $JAVA_CMD"
echo "Java version:"
$JAVA_CMD -version

# Find JDTLS
JDTLS_PATHS=(
  "$HOME/.local/share/nvim/mason/packages/jdtls"
  "/usr/share/java/jdtls"
  "/opt/jdtls"
)

JDTLS_PATH=""
for path in "${JDTLS_PATHS[@]}"; do
  if [ -d "$path" ]; then
    LAUNCHER=$(find "$path" -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)
    if [ -n "$LAUNCHER" ]; then
      JDTLS_PATH="$path"
      break
    fi
  fi
done

if [ -z "$JDTLS_PATH" ]; then
  echo "Error: JDTLS installation not found"
  exit 1
fi

echo "Found JDTLS at: $JDTLS_PATH"

# Set all relevant environment variables
export TEMP="$TEMP_DIR"
export TMP="$TEMP_DIR"
export TMPDIR="$TEMP_DIR"
export XDG_CACHE_HOME="$CACHE_DIR"
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=$TEMP_DIR"

echo "Starting JDTLS directly..."
echo "All output will be captured in $LOG_FILE"

# Launch JDTLS with all debug options
$JAVA_CMD \
  -Djava.io.tmpdir="$TEMP_DIR" \
  -Dlog.level=ALL \
  -Dlog.protocol=true \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dfile.encoding=UTF-8 \
  -XX:+UseParallelGC \
  -XX:GCTimeRatio=4 \
  -XX:AdaptiveSizePolicyWeight=90 \
  -XX:+ExitOnOutOfMemoryError \
  -Dsun.zip.disableMemoryMapping=true \
  -Xmx512m \
  -Xms100m \
  -jar $(find "$JDTLS_PATH" -name "org.eclipse.equinox.launcher_*.jar") \
  -configuration "$JDTLS_PATH/config_linux" \
  -data "$WORKSPACE_DIR" \
  > "$LOG_FILE" 2>&1

EXIT_CODE=$?
echo "JDTLS exited with code $EXIT_CODE"

if [ $EXIT_CODE -eq 13 ]; then
  echo "Permission denied error (code 13) detected!"
  
  # Try to find more specific error information
  echo -e "\nChecking for specific error messages:"
  grep -i "permission denied" "$LOG_FILE" || echo "No explicit permission denied messages found"
  grep -i "error" "$LOG_FILE" | head -5
  
  # Show permissions of critical directories
  echo -e "\nDirectory permissions:"
  ls -la "$CACHE_DIR"
  ls -la "$JDTLS_PATH/config_linux"
  
  # Check SELinux status if available
  if command -v getenforce &> /dev/null; then
    echo -e "\nSELinux status:"
    getenforce
  fi
  
  echo -e "\nPotential solutions:"
  echo "1. Try running this script as root: sudo $0"
  echo "2. Disable SELinux temporarily: sudo setenforce 0"
  echo "3. Check if your system has strict directory permissions or AppArmor rules"
fi

echo -e "\nCheck the log file for more details: $LOG_FILE"
