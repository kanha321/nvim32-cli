# Minimal JDTLS Setup

## Requirements

1. Java JDK 17 or newer installed
2. JDTLS installed either:
   - Through Mason: `:MasonInstall jdtls`
   - Or system package: `yay -S jdtls` (for Arch) or equivalent

## Usage

1. Open a Java file
2. JDTLS will automatically start
3. Use standard LSP commands:
   - `gd` - Go to definition
   - `K` - Hover documentation
   - `gr` - Find references

## Troubleshooting

If JDTLS doesn't start:

1. Check that Java 17 is installed and in your PATH
2. Verify JDTLS is installed with `:MasonList`
3. Look at logs with `:e ~/.cache/nvim/lsp.log`

## Manual restart

If needed, restart JDTLS manually:

```vim
:lua vim.cmd('e') -- Force buffer reload
```
