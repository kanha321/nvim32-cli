-- Entry point for Neovim configuration

-- Set leader key before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable maximum LSP logging for debugging
vim.lsp.set_log_level("debug")

-- Verify lazy.nvim path and install if needed
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

-- Create a special location for JDTLS logs
vim.fn.mkdir(vim.fn.expand("~/.cache/jdtls"), "p")
-- Set permission on the JDTLS directory
vim.fn.system("chmod -R 777 " .. vim.fn.expand("~/.cache/jdtls"))
-- Let JDTLS know where it can find things
vim.env.JDTLS_HOME = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")

-- Basic Neovim settings first
require('core.options')  -- Basic vim options

-- Bootstrap and load plugins with clear error handling
local plugins_ok, plugins_error = pcall(require, 'plugins.init')
if not plugins_ok then
  vim.notify("Error loading plugins: " .. tostring(plugins_error), vim.log.levels.ERROR)
  -- Continue anyway to allow some functionality
else 
  vim.notify("Plugins loaded successfully", vim.log.levels.INFO)
end

-- Load core components
require('core.keymaps')  -- Key mappings
require('core.autocmds') -- Auto commands

-- Add JavaRestart command for manual JDTLS control
vim.api.nvim_create_user_command('JavaRestart', function()
  -- Load our java.lua file directly
  local success, err = pcall(function()
    vim.cmd('source ' .. vim.fn.stdpath("config") .. '/ftplugin/java.lua')
  end)
  
  if success then
    vim.notify("JDTLS restarted", vim.log.levels.INFO)
  else
    vim.notify("Failed to restart JDTLS: " .. tostring(err), vim.log.levels.ERROR)
  end
end, {})

-- Create command to reload configuration
vim.api.nvim_create_user_command('ReloadConfig', function()
  -- Unload modules to ensure fresh state
  for name, _ in pairs(package.loaded) do
    if name:match('^plugins') or name:match('^core') then
      package.loaded[name] = nil
    end
  end
  
  -- Reload the config
  dofile(vim.fn.stdpath('config') .. '/init.lua')
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, {})
