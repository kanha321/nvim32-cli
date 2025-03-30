# Neovim Key Mappings (IntelliJ-Style)

This document outlines keyboard shortcuts configured in our Neovim setup, organized to help IntelliJ users transition smoothly.

## 1. Identical to IntelliJ

These keybindings function exactly the same as in IntelliJ IDEA/Android Studio:

| Key Binding | Human-Readable | Mode | Description | 
|-------------|----------------|------|-------------|
| `<C-s>` | Ctrl+S | Normal | Save file |
| `<C-S-f>` | Ctrl+Shift+F | Normal | Search in files |
| `<C-e>` | Ctrl+E | Normal | Recent files |
| `<F12>` | F12 | Normal | File structure |
| `<C-A-l>` | Ctrl+Alt+L | Normal | Format code |
| `<C-/>` | Ctrl+/ | Normal/Visual | Toggle comment |
| `<A-Enter>` | Alt+Enter | Normal | Code actions |
| `<A-o>` | Alt+O | Normal | Organize imports |
| `<F9>` | F9 | Normal | Start/continue debugging |
| `<A-F7>` | Alt+F7 | Normal | Find usages |
| `<C-1>` | Ctrl+1 | Normal | Toggle file explorer (similar to Alt+1) |
| `<C-p>` | Ctrl+P | Insert | Show parameter hints |

### Java/Kotlin Refactoring

| Key Binding | Human-Readable | Mode | Description |
|-------------|----------------|------|-------------|
| `<leader>ev` | Space+e+v | Normal/Visual | Extract variable (like Ctrl+Alt+V) |
| `<leader>ec` | Space+e+c | Normal/Visual | Extract constant (like Ctrl+Alt+C) |
| `<leader>em` | Space+e+m | Visual | Extract method (like Ctrl+Alt+M) |
| `<leader>oi` | Space+o+i | Normal | Organize imports (like Ctrl+Alt+O) |
| `<leader>ji` | Space+j+p | Normal | Organize imports (like Ctrl+Alt+O) |
| `<leader>jv` | Space+j+v | Normal/Visual | Extract variable (like Ctrl+Alt+V) |
| `<leader>jc` | Space+j+c | Normal/Visual | Extract constant (like Ctrl+Alt+C) |
| `<leader>jm` | Space+j+m | Visual | Extract method (like Ctrl+Alt+M) |
| `<leader>ji` | Space+j+i | Normal | Organize imports (like Ctrl+Alt+O) |
| `<leader>jr` | Space+j+r | Normal | Restart Java language server |
| `<leader>jc` | Space+j+c | Normal | Clean Java workspace |

## 2. Different from IntelliJ

These keybindings serve similar functions but use different key combinations:

| Key Binding | Human-Readable | Mode | Description | IntelliJ Equivalent |
|-------------|----------------|------|-------------|---------------------|
| `<C-p>` | Ctrl+P | Normal | Find files | Ctrl+Shift+N |
| `<C-b>` | Ctrl+B | Normal | Toggle breakpoint | Ctrl+F8 |
| `<C-S-r>` | Ctrl+Shift+R | Normal | Rename symbol | Shift+F6 |
| `<leader>rn` | Space+r+n | Normal | Rename symbol | Shift+F6 |
| `<C-S-n>` | Ctrl+Shift+N | Normal | New file | Ctrl+Alt+Insert |
| `<C-A-o>` | Ctrl+Alt+O | Normal | Call hierarchy | Ctrl+Alt+H |
| `<C-S-o>` | Ctrl+Shift+O | Normal | Go to symbol | Ctrl+Alt+Shift+N |
| `gd` | g+d | Normal | Go to definition | Ctrl+B |
| `gr` | g+r | Normal | Show references | Alt+F7 (also mapped to A-F7) |
| `gi` | g+i | Normal | Go to implementation | Ctrl+Alt+B |
| `K` | Shift+K | Normal | Show documentation | Ctrl+Q |

### Vim-Specific Navigation

These are Vim/Neovim specific and don't have direct IntelliJ equivalents:

| Key Binding | Human-Readable | Mode | Description |
|-------------|----------------|------|-------------|
| `<Space>` | Space | Normal | Leader key for commands |
| `<C-h>` | Ctrl+H | Normal | Move to left window |
| `<C-j>` | Ctrl+J | Normal | Move to lower window |
| `<C-k>` | Ctrl+K | Normal | Move to upper window |
| `<C-l>` | Ctrl+L | Normal | Move to right window |
| `<C-\>` | Ctrl+\ | Normal | Split window vertically |
| `<C-=>` | Ctrl+= | Normal | Split window horizontally |
| `<C-Up>` | Ctrl+↑ | Normal | Decrease window height |
| `<C-Down>` | Ctrl+↓ | Normal | Increase window height |
| `<C-Left>` | Ctrl+← | Normal | Decrease window width |
| `<C-Right>` | Ctrl+→ | Normal | Increase window width |
| `<` | < | Visual | Decrease indent and stay in visual mode |
| `>` | > | Visual | Increase indent and stay in visual mode |
| `gD` | g+Shift+D | Normal | Go to declaration |

### LSP Diagnostics

| Key Binding | Human-Readable | Mode | Description |
|-------------|----------------|------|-------------|
| `<leader>f` | Space+f | Normal | Show diagnostics |
| `[d` | [+d | Normal | Go to previous diagnostic |
| `]d` | ]+d | Normal | Go to next diagnostic |
| `<leader>q` | Space+q | Normal | Send diagnostics to location list |
| `<C-k>` | Ctrl+K | Normal | Show signature help |

## Common Workflow Examples

### Finding and Navigating Code
- `<C-p>` (Ctrl+P) to find a file (instead of Ctrl+Shift+N in IntelliJ)
- `<C-S-f>` (Ctrl+Shift+F) to search across files (same as IntelliJ)
- `gd` (g+d) to jump to definition (instead of Ctrl+B in IntelliJ)

### Refactoring
- Select code in visual mode, then `<leader>em` (Space+e+m) to extract a method
- Put cursor on a variable, then `<leader>rn` (Space+r+n) or `<C-S-r>` (Ctrl+Shift+R) to rename it

### Debugging
- `<C-b>` (Ctrl+B) to set breakpoints (instead of Ctrl+F8 in IntelliJ)
- `<F9>` (F9) to start/continue debugging (same as IntelliJ)

## Tips for IntelliJ Users

1. Most important shortcuts (save, find, formatting) use the same key combinations
2. For Vim-specific navigation between windows, remember `Ctrl` + `h`/`j`/`k`/`l`
3. The leader key (`<Space>` or Space) is used for many custom commands
4. Code refactoring for Java/Kotlin follows similar patterns with leader key
