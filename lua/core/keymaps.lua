-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Re-add leader key for safety
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Define NvimTree toggle mapping - try different approaches
-- Safety check to make sure nvim-tree is loaded
local nvim_tree_loaded, _ = pcall(require, "nvim-tree")
if nvim_tree_loaded then
  keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", opts)
  keymap("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", opts)
else
  -- Fallback to a message if nvim-tree isn't available
  keymap("n", "<leader>e", function()
    print("NvimTree plugin not loaded!")
  end, opts)
end

-- IntelliJ-like keymaps
keymap("n", "<C-S-n>", "<cmd>enew<CR>", opts)                   -- New file
keymap("n", "<C-s>", "<cmd>w<CR>", opts)                        -- Save

-- Format code - safely check for LSP first
keymap("n", "<C-A-l>", function() 
  if vim.lsp.buf.format then
    vim.lsp.buf.format()
  else
    print("LSP format not available")
  end
end, opts)

-- Safely add other LSP and DAP keybindings
local has_dap, dap = pcall(require, "dap")
if has_dap then
  keymap("n", "<C-b>", function() dap.toggle_breakpoint() end, opts) -- Toggle breakpoint
  keymap("n", "<F9>", function() dap.continue() end, opts)         -- Start/continue debugging
else
  keymap("n", "<C-b>", function() print("DAP not loaded") end, opts)
  keymap("n", "<F9>", function() print("DAP not loaded") end, opts)
end

-- LSP keys with safety checks
local function safe_lsp_call(lsp_fn, fallback_msg)
  return function()
    if vim.lsp and vim.lsp.buf and vim.lsp.buf[lsp_fn] then
      vim.lsp.buf[lsp_fn]()
    else
      print(fallback_msg or "LSP not available")
    end
  end
end

keymap("n", "<A-F7>", safe_lsp_call("references", "LSP references not available"), opts)
keymap("n", "<C-S-r>", safe_lsp_call("rename", "LSP rename not available"), opts)
keymap("n", "<A-Enter>", safe_lsp_call("code_action", "LSP code actions not available"), opts)
keymap("n", "<C-A-o>", safe_lsp_call("outgoing_calls", "LSP outgoing calls not available"), opts)

-- Split window
keymap("n", "<C-\\>", "<cmd>vsplit<CR>", opts)       -- Vertical split
keymap("n", "<C-=>", "<cmd>split<CR>", opts)         -- Horizontal split

-- LSP with safety checks
keymap("n", "K", safe_lsp_call("hover", "LSP hover not available"), opts)
keymap("n", "gd", safe_lsp_call("definition", "LSP definition not available"), opts)
keymap("n", "gr", safe_lsp_call("references", "LSP references not available"), opts)
keymap("n", "<leader>ca", safe_lsp_call("code_action", "LSP code action not available"), opts)
keymap("n", "<leader>rn", safe_lsp_call("rename", "LSP rename not available"), opts)

-- LSP info panel - useful for debugging
keymap("n", "<leader>li", function()
  vim.cmd("LspInfo")
end, { noremap = true, silent = true, desc = "Show LSP information" })

-- LSP log - useful for debugging
keymap("n", "<leader>ll", function()
  vim.cmd("edit " .. vim.lsp.get_log_path())
end, { noremap = true, silent = true, desc = "Open LSP log file" })

-- LSP debug/fix keys
keymap("n", "<leader>ld", "<cmd>LspDebug<CR>", { noremap = true, desc = "Debug LSP setup" })
keymap("n", "<leader>ls", function()
  local ft = vim.bo.filetype
  if ft ~= "" then
    vim.cmd("LspStart " .. ft)
    print("Starting LSP for " .. ft)
  else
    print("No filetype detected")
  end
end, { noremap = true, desc = "Start LSP for current filetype" })

-- Show keymaps help - ensure the keymaps.md file exists
if vim.fn.filereadable(vim.fn.expand("~/nvim/keymaps.md")) == 1 then
  keymap("n", "<leader>?", "<cmd>edit ~/nvim/keymaps.md<CR>", opts)
else
  keymap("n", "<leader>?", function() print("Keymaps help file not found") end, opts)
end

-- Add a force reload config option
keymap("n", "<leader>r", "<cmd>ReloadConfig<CR>", opts)

-- Java development keymaps
keymap("n", "<leader>jr", function()
  -- Restart Java language server by reloading the current file
  vim.cmd("e")
end, { noremap = true, desc = "Restart Java language server" })

keymap("n", "<leader>ji", function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if jdtls_ok then
    jdtls.organize_imports()
  else
    print("JDTLS not available")
  end
end, { noremap = true, desc = "Organize imports" })

keymap("n", "<leader>jc", "<cmd>JavaClean<CR>", { noremap = true, desc = "Clean Java workspace" })

keymap("n", "<leader>jv", function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if jdtls_ok then
    jdtls.extract_variable()
  else
    print("JDTLS not available")
  end
end, { noremap = true, desc = "Extract variable" })

keymap("v", "<leader>jv", function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if jdtls_ok then
    jdtls.extract_variable(true)
  else
    print("JDTLS not available")
  end
end, { noremap = true, desc = "Extract variable (visual)" })

keymap("n", "<leader>jm", function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if jdtls_ok then
    jdtls.extract_method()
  else
    print("JDTLS not available")
  end
end, { noremap = true, desc = "Extract method" })

keymap("v", "<leader>jm", function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if jdtls_ok then
    jdtls.extract_method(true)
  else
    print("JDTLS not available")
  end
end, { noremap = true, desc = "Extract method (visual)" })

keymap("n", "<leader>jt", function() 
  local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
  local root_dir = require('jdtls.setup').find_root(root_markers) or vim.fn.getcwd()
  -- Try to find the main class
  vim.cmd("!cd " .. root_dir .. " && java -jar target/*.jar")
end, { noremap = true, desc = "Run Java application" })

-- Code running (manual implementation)
function RunCode()
    local filetype = vim.bo.filetype
    local commands = {
        python = "python %",
        c = "gcc % -o a.out && ./a.out || echo 'Compilation failed!'",
        cpp = "g++ % -o a.out && ./a.out || echo 'Compilation failed!'",
        asm = "gcc % -nostdlib -static -o a.out && ./a.out || echo 'Compilation failed!'",
        sh = "if [ -x % ]; then ./%; else sh %; fi",
        java = "mkdir -p out && javac -d out " .. vim.fn.expand('%:p') .. " && java -cp out " .. vim.fn.expand('%:t:r'),
    }

    local command = commands[filetype]
    if command then
        vim.cmd("w") -- Save file
        vim.cmd("TermExec cmd='" .. command .. "'")
    else
        print("No run command set for this filetype: " .. filetype)
    end
end

-- Key mapping to run code (traditional method as backup)
keymap("n", ")", ":lua RunCode()<CR>", { desc = "Run code based on filetype" })
keymap("n", "<C-'>", ":lua RunCode()<CR>", { noremap = true, silent = true })

-- nvimtree toggle (added here for redundancy/backup)
keymap('n', '<leader>e', "<cmd>NvimTreeToggle<CR>", { desc = "Toggle [E]xplorer" })
