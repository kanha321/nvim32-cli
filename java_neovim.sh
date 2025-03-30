#!/bin/bash
# Script to fix permissions before starting Neovim for Java development

# Create and set permissions for JDTLS directories
mkdir -p ~/.cache/jdtls/workspace ~/.cache/jdtls/temp
chmod -R 777 ~/.cache/jdtls

# Create a clean environment for JDTLS
export JDTLS_HOME=~/.local/share/nvim/mason/packages/jdtls
export TEMP=~/.cache/jdtls/temp
export TMP=~/.cache/jdtls/temp
export TMPDIR=~/.cache/jdtls/temp
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=~/.cache/jdtls/temp"

# Start Neovim
nvim "$@"
