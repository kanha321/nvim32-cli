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
keymap("n", "<leader>lR", "<cmd>StartJdtls<CR>", { noremap = true, desc = "Restart JDTLS" })
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

-- Add enhanced LSP diagnostics commands
keymap("n", "<leader>lD", function()
  local debug_ok, debug_lsp = pcall(require, "debug.lsp")
  if debug_ok then
    debug_lsp.print_diagnostics()
  else
    print("Debug module not available. Run :e lua/debug/lsp.lua first")
  end
end, { noremap = true, desc = "Print detailed LSP diagnostics" })

keymap("n", "<leader>lf", function()
  local debug_ok, debug_lsp = pcall(require, "debug.lsp")
  if debug_ok then
    debug_lsp.force_start_lsp()
  else
    print("Debug module not available. Run :e lua/debug/lsp.lua first")
  end
end, { noremap = true, desc = "Force start LSP for current filetype" })

-- Show keymaps help - ensure the keymaps.md file exists
if vim.fn.filereadable(vim.fn.expand("~/nvim/keymaps.md")) == 1 then
  keymap("n", "<leader>?", "<cmd>edit ~/nvim/keymaps.md<CR>", opts)
else
  keymap("n", "<leader>?", function() print("Keymaps help file not found") end, opts)
end

-- Add a force reload config option
keymap("n", "<leader>r", "<cmd>ReloadConfig<CR>", opts)

-- Add JDTLS debug keymaps
local jdtls_debug_loaded, jdtls_debug = pcall(require, "debug.jdtls")
if jdtls_debug_loaded then
  keymap("n", "<leader>jd", jdtls_debug.print_diagnostics, { noremap = true, desc = "JDTLS diagnostics" })
  keymap("n", "<leader>jr", jdtls_debug.restart_with_debug, { noremap = true, desc = "JDTLS restart with debug" })
  keymap("n", "<leader>jp", jdtls_debug.fix_permissions, { noremap = true, desc = "JDTLS fix permissions" })
  keymap("n", "<leader>js", jdtls_debug.restart_simplified, { noremap = true, desc = "JDTLS restart simplified" })
  keymap("n", "<leader>jm", jdtls_debug.restart_minimal, { noremap = true, desc = "JDTLS minimal restart" })
  
  -- Add fallback mode
  local jdtls_fallback_loaded, jdtls_fallback = pcall(require, "debug.jdtls_fallback")
  if jdtls_fallback_loaded then
    keymap("n", "<leader>jf", jdtls_fallback.hard_reset_and_start, { noremap = true, desc = "JDTLS fallback mode" })
    keymap("n", "<leader>je", function() 
      jdtls_fallback.create_external_script()
    end, { noremap = true, desc = "Create external JDTLS script" })
  end

  -- Add verification tools
  local jdtls_verify_loaded, jdtls_verify = pcall(require, "debug.jdtls_verify")
  if jdtls_verify_loaded then
    keymap("n", "<leader>jv", jdtls_verify.verify, { noremap = true, desc = "Verify JDTLS functionality" })
    keymap("n", "<leader>jt", jdtls_verify.test_with_file, { noremap = true, desc = "Test JDTLS with sample file" })
  end
else
  -- Create fallback that loads the module when needed
  keymap("n", "<leader>jd", function()
    local ok, module = pcall(require, "debug.jdtls")
    if ok then
      module.print_diagnostics()
    else
      print("JDTLS debug module not available")
    end
  end, { noremap = true, desc = "JDTLS diagnostics" })
  
  keymap("n", "<leader>jr", function()
    local ok, module = pcall(require, "debug.jdtls")
    if ok then
      module.restart_with_debug()
    else
      print("JDTLS debug module not available")
    end
  end, { noremap = true, desc = "JDTLS restart with debug" })

  keymap("n", "<leader>js", function()
    local ok, module = pcall(require, "debug.jdtls")
    if ok then
      module.restart_simplified()
    else
      print("JDTLS debug module not available")
    end
  end, { noremap = true, desc = "JDTLS restart simplified" })

  keymap("n", "<leader>jm", function()
    local ok, module = pcall(require, "debug.jdtls")
    if ok then
      module.restart_minimal()
    else
      print("JDTLS debug module not available")
    end
  end, { noremap = true, desc = "JDTLS minimal restart" })
  
  -- Add fallback mode
  keymap("n", "<leader>jf", function()
    local ok, module = pcall(require, "debug.jdtls_fallback")
    if ok then
      module.hard_reset_and_start()
    else
      print("JDTLS fallback module not available")
    end
  end, { noremap = true, desc = "JDTLS fallback mode" })
  
  keymap("n", "<leader>je", function()
    local ok, module = pcall(require, "debug.jdtls_fallback")
    if ok then
      module.create_external_script()
    else
      print("JDTLS fallback module not available")
    end
  end, { noremap = true, desc = "Create external JDTLS script" })

  -- Add verification tools
  keymap("n", "<leader>jv", function()
    local ok, module = pcall(require, "debug.jdtls_verify")
    if ok then
      module.verify()
    else
      print("JDTLS verify module not available")
    end
  end, { noremap = true, desc = "Verify JDTLS functionality" })
  
  keymap("n", "<leader>jt", function()
    local ok, module = pcall(require, "debug.jdtls_verify")
    if ok then
      module.test_with_file()
    else
      print("JDTLS verify module not available")
    end
  end, { noremap = true, desc = "Test JDTLS with sample file" })
end

-- Special command to manually restart JDTLS
keymap("n", "<leader>jR", function()
  -- Stop current JDTLS if running
  local clients = vim.lsp.get_active_clients({name = "jdtls"})
  for _, client in ipairs(clients) do
    client.stop()
    vim.notify("Stopped JDTLS client", vim.log.levels.INFO)
  end
  
  -- Create clean workspace
  local bufnr = vim.api.nvim_get_current_buf()
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
  if not root_dir then
    root_dir = vim.fn.getcwd()
  end
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name

  -- Delete old workspace
  vim.fn.system("rm -rf " .. workspace_dir)
  vim.fn.mkdir(workspace_dir, "p")
  vim.notify("Created fresh JDTLS workspace at " .. workspace_dir, vim.log.levels.INFO)
  
  -- Try to restart
  vim.cmd("StartJdtls")
  
  -- Reopen the file
  vim.cmd("e " .. fname)
end, { noremap = true, desc = "JDTLS full restart with clean workspace" })
