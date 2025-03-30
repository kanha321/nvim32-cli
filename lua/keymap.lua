local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Set leader key to space
vim.g.mapleader = " "

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- IntelliJ-like keymaps
keymap("n", "<C-S-n>", "<cmd>enew<CR>", opts)                   -- New file
keymap("n", "<C-s>", "<cmd>w<CR>", opts)                        -- Save
keymap("n", "<C-A-l>", "<cmd>lua vim.lsp.buf.format()<CR>", opts) -- Format code
keymap("n", "<C-b>", "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts) -- Toggle breakpoint
keymap("n", "<F9>", "<cmd>lua require('dap').continue()<CR>", opts)         -- Start/continue debugging
keymap("n", "<A-F7>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)        -- Find usages
keymap("n", "<C-S-r>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)           -- Rename
keymap("n", "<A-Enter>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)     -- Quick fix/actions
keymap("n", "<C-A-o>", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>", opts)   -- Call hierarchy

-- Comment toggling (IntelliJ-like)
keymap("n", "<C-/>", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("v", "<C-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

-- Telescope
keymap("n", "<C-p>", "<cmd>Telescope find_files<CR>", opts)           -- Find files (IntelliJ Ctrl+Shift+N)
keymap("n", "<C-S-f>", "<cmd>Telescope live_grep<CR>", opts)          -- Find in files
keymap("n", "<C-e>", "<cmd>Telescope buffers<CR>", opts)              -- Recent files
keymap("n", "<F12>", "<cmd>Telescope lsp_definitions<CR>", opts)      -- Go to definition
keymap("n", "<C-S-o>", "<cmd>Telescope lsp_document_symbols<CR>", opts) -- File structure

-- File Explorer
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", opts)
keymap("n", "<C-1>", "<cmd>NvimTreeToggle<CR>", opts)  -- Like IntelliJ's Alt+1

-- LSP
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- Split window
keymap("n", "<C-\\>", "<cmd>vsplit<CR>", opts)       -- Vertical split
keymap("n", "<C-=>", "<cmd>split<CR>", opts)         -- Horizontal split
