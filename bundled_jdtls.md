# Bundled JDTLS for Neovim

This configuration uses a bundled version of Eclipse JDTLS for Java development in Neovim.

## Setup

1. Run the installation script to download JDTLS:
   ```bash
   bash ~/nvim/install_jdtls.sh
   ```

2. This will install JDTLS to `~/.config/nvim/jdtls-1.43/`

## How It Works

- The configuration automatically finds the bundled JDTLS using a relative path from your Neovim config directory.
- When you open a Java file, JDTLS will automatically start.
- A workspace is created for each project in `~/.cache/jdtls/workspace/`.

## Commands

- `:JdtRestart` - Restart the JDTLS server
- `:JdtUpdateConfig` - Update project configuration
- `:JdtJol` - Analyze object layout
- `:JdtBytecode` - View bytecode
- `:JdtJshell` - Start JShell with project classpath

## Keymaps

Standard LSP keymaps:
- `gd` - Go to definition
- `K` - Show documentation

Java-specific keymaps:
- `<leader>jo` - Organize imports
- `<leader>jv` - Extract variable
- `<leader>jc` - Extract constant
- `<leader>jm` - Extract method (visual mode)
- `<leader>jr` - Restart JDTLS
- `<leader>jt` - Run Java application

## Manual Usage

You can also use the bundled JDTLS directly from command line:

```bash
~/.config/nvim/jdtls-1.43/bin/jdtls
```

## Updating JDTLS

To update JDTLS to a newer version:

1. Edit the installation script to update the version number
2. Run the installation script again to download the new version
3. Update the configuration files to point to the new version
