-- Entry point for Neovim configuration

-- Verify lazy.nvim path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable maximum LSP logging for debugging
vim.lsp.set_log_level("debug")

-- Create a special location for JDTLS logs
vim.fn.mkdir(vim.fn.expand("~/.cache/jdtls"), "p")
vim.env.JDTLS_HOME = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")

-- Setup special debug helpers
vim.defer_fn(function()
  -- Silently try to load the debug modules
  pcall(require, "debug.lsp")
  pcall(require, "debug.jdtls")
end, 1000)

-- Basic Neovim settings first
-- Load core settings
require('core.options')  -- Basic vim options

-- Bootstrap and load plugins
require('plugins.init') -- This loads our modular plugin system

-- Add debug commands
vim.api.nvim_create_user_command('LspDebugInfo', function()
  local debug_ok, debug_lsp = pcall(require, "debug.lsp")
  if debug_ok then
    debug_lsp.print_diagnostics()
  else
    vim.notify("Debug module not loaded. Create lua/debug/lsp.lua first", vim.log.levels.WARN)
  end
end, {})

-- Load after plugins are initialized
require('core.keymaps')  -- Key mappings that may depend on plugins
require('core.autocmds') -- Auto commands

-- Defer LSP initialization check to give it time to start
vim.defer_fn(function()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify("No LSP clients active after initialization. Use :LspDebugInfo to troubleshoot", vim.log.levels.WARN)
  else
    vim.notify(#clients .. " LSP client(s) active", vim.log.levels.INFO)
  end
end, 3000)

-- Disable unnecessary messages
vim.opt.shortmess:append("I") -- Disable intro message when starting Neovim

-- Create command to reload configuration
vim.api.nvim_create_user_command('ReloadConfig', function()
  -- Unload modules
  for name, _ in pairs(package.loaded) do
    if name:match('^plugins') or name:match('^core') then
      package.loaded[name] = nil
    end
  end
  
  -- Reload the config
  dofile(vim.fn.stdpath('config') .. '/init.lua')
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, {})

-- Create a command to check key mappings
vim.api.nvim_create_user_command('CheckKeys', function()
  local leader_mappings = {}
  for _, map in ipairs(vim.api.nvim_get_keymap('n')) do
    if map.lhs:match("^ ") then
      table.insert(leader_mappings, map.lhs .. " -> " .. (map.rhs or map.callback or "?"))
    end
  end
  
  print("Leader mappings:")
  for _, mapping in ipairs(leader_mappings) do
    print(mapping)
  end
end, {})
