-- Entry point for Neovim configuration

-- Set leader key before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable maximum LSP logging for debugging
vim.lsp.set_log_level("info") -- Changed from debug to info (less verbose)

-- Check for bundled JDTLS
local config_dir = vim.fn.stdpath("config")
local jdtls_dir = config_dir .. "/jdtls-1.43"
if vim.fn.isdirectory(jdtls_dir) == 0 then
  vim.notify("Bundled JDTLS not found. The Java support will not work correctly.", vim.log.levels.WARN)
end

-- Create a special location for JDTLS workspace
vim.fn.mkdir(vim.fn.expand("~/.cache/jdtls/workspace"), "p")

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

-- Add command for Java workspace cleaning
vim.api.nvim_create_user_command('JavaClean', function()
  -- Get current project
  local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
  local jdtls_setup = require('jdtls.setup')
  local root_dir = jdtls_setup.find_root(root_markers) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
  
  -- Clean workspace
  vim.fn.system("rm -rf " .. vim.fn.shellescape(workspace_dir))
  vim.fn.mkdir(workspace_dir, "p")
  
  -- Notify user
  vim.notify("Java workspace cleaned. Restart JDTLS with :e", vim.log.levels.INFO)
end, {})

-- Create TermExec command if the code_runner plugin isn't loaded yet
if not pcall(require, "toggleterm") then
  vim.api.nvim_create_user_command('TermExec', function(opts)
    -- Parse the command from the arguments
    local cmd = opts.args:match("cmd='(.*)'")
    if not cmd then
      cmd = opts.args -- If not in cmd='...' format, just use the args directly
    end
    
    -- Fallback implementation using built-in terminal
    vim.cmd('terminal ' .. cmd)
    vim.cmd('startinsert')
  end, {
    nargs = '+',
    desc = 'Execute command in terminal',
    complete = 'file'
  })
end

-- Create command to reload configuration
vim.api.nvim_create_user_command('ReloadConfig', function()
  -- Unload modules to ensure fresh state
  for name, _ in pairs(package.loaded) do
    if name:match('^plugins') or name:match('^core') or name:match('^snippets') then
      package.loaded[name] = nil
    end
  end
  
  -- Reload the config
  dofile(vim.fn.stdpath('config') .. '/init.lua')
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, {})
