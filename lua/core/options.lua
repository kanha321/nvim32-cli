-- Basic Neovim settings
local opt = vim.opt

-- UI
opt.number = true          -- Show line numbers
opt.relativenumber = true  -- Show relative line numbers
opt.termguicolors = true   -- Better colors
opt.scrolloff = 8          -- Lines of context
opt.showmode = false       -- Don't show mode (shown in status line)
opt.signcolumn = "yes"     -- Always show signcolumn
opt.cursorline = true      -- Highlight current line

-- Behavior
opt.shiftwidth = 4         -- Number of spaces for indentation - Changed to 4
opt.tabstop = 4            -- Number of spaces tabs count for - Changed to 4
opt.softtabstop = 4        -- Makes backspace treat 4 spaces like a tab
opt.expandtab = true       -- Use spaces instead of tabs
opt.smartindent = true     -- Smart autoindenting
opt.wrap = false           -- No line wrapping
opt.mouse = "a"            -- Enable mouse in all modes
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.completeopt = "menu,menuone,noselect" -- Better completion

-- File handling
opt.swapfile = false       -- No swap files
opt.backup = false         -- No backup files
opt.undodir = vim.fn.expand('~/.vim/undodir')
opt.undofile = true        -- Persistent undo history

-- Search
opt.hlsearch = false       -- Don't highlight search results
opt.incsearch = true       -- Incremental search
opt.ignorecase = true      -- Ignore case when searching
opt.smartcase = true       -- Unless search contains uppercase

-- Performance optimizations for 32-bit systems
opt.updatetime = 100       -- Faster completion
opt.timeoutlen = 500       -- Time to wait for a mapped sequence
opt.lazyredraw = true      -- Don't redraw while executing macros
opt.hidden = true          -- Enable background buffers

-- Global settings
vim.g.mapleader = " "      -- Set leader key to space
