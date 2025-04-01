# Neovim Configuration with Bundled JDTLS

This Neovim configuration comes with a bundled version of Eclipse JDTLS for Java development.

## Features

- Complete LSP support for various languages
- Bundled JDTLS for Java development
- Modern UI with a clean, minimal interface
- Optimized for performance
- VSCode-style snippets for Java development
- Code execution for multiple languages

## Requirements

1. Neovim 0.9.0 or newer
2. Java JDK 17 or newer installed

## Java Development

The configuration includes a bundled version of JDTLS (Eclipse Java Language Server). When you open a Java file, JDTLS will automatically start.

### Java Commands

- `:JavaClean` - Clean the workspace for the current project
- `<leader>jr` - Restart the Java language server
- `<leader>ji` - Organize imports
- `<leader>jv` - Extract variable (visual mode supported)
- `<leader>jc` - Extract constant (visual mode supported)
- `<leader>jm` - Extract method (visual mode supported)
- `<leader>jt` - Run the compiled Java application

### Java Snippets

Type these in insert mode and press Tab to expand:

- `sout` - System.out.println()
- `serr` - System.err.println()
- `psvm` - public static void main method
- `fori` - for loop with index
- `fore` - for each loop
- `try` - try/catch block
- `ife` - if/else statement
- `switch` - switch statement
- `new` - create new instance
- ... and many more!

## Running Code

You can quickly run code for multiple languages with the following keybindings:

- `)` or `<C-'>` - Run the current file based on filetype
- `<leader>r` - Alternative key to run code
- `<leader>rp` - Run project (looks for project files like package.json, gradlew)

Supported languages:
- Java (automatically compiles and runs)
- Python
- C/C++
- Assembly
- Shell scripts
- JavaScript/TypeScript
- Go
- Rust
- Lua
- Kotlin

## Troubleshooting

If you encounter issues with JDTLS:

1. Make sure Java 17 or newer is installed and in your PATH
2. Try running `:JavaClean` to reset the workspace
3. Reload the current Java file to restart JDTLS with `<leader>jr` or `:e`
