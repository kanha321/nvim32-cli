-- Main plugins module
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Debug function to check plugin loading (only called when explicitly requested)
local function debug_plugins()
  local loaded = {}
  for _, plugin in ipairs(vim.fn.globpath(vim.fn.stdpath("data") .. "/lazy", "*", false, true)) do
    table.insert(loaded, vim.fn.fnamemodify(plugin, ":t"))
  end
  print("Lazy-loaded plugins: " .. vim.inspect(loaded))
end

-- Force loading order to prevent conflicts
local plugins = {
  -- First load core Neovim enhancements
  { 'nvim-lua/plenary.nvim' }, -- Load plenary first as it's a dependency for many plugins
  
  -- LSP and Mason - load early
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    build = ":MasonUpdate",
    priority = 999,
    config = function()
      require("mason").setup({
        ui = {
          border = "single",
          icons = {
            package_installed = "+",
            package_pending = "~",
            package_uninstalled = "-"
          }
        }
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {'williamboman/mason.nvim'},
    priority = 998,
  },
  
  -- Then load UI essentials
  { 'EdenEast/nightfox.nvim', priority = 1000 },
  
  -- Welcome dashboard - CLI friendly
  {
    'goolord/alpha-nvim',
    dependencies = {},
    config = function()
      require("plugins.configs.dashboard").setup()
    end,
  },
  
  -- Load NvimTree without git integration
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require("nvim-tree").setup({
        git = { enable = false },
        view = { width = 30 },
        renderer = {
          icons = { show = { git = false, folder = false, file = false, folder_arrow = false } },
          group_empty = true,
          add_trailing = true,
        },
      })
    end,
  },
}

-- Helper function to safely load plugin configurations from a directory
local function load_plugins_from_dir(directory)
  local plugin_path = vim.fn.stdpath("config") .. "/lua/plugins/" .. directory
  local plugin_files = vim.fn.glob(plugin_path .. "/*.lua", false, true)
  
  if #plugin_files == 0 then
    return
  end
  
  for _, file in ipairs(plugin_files) do
    local plugin_name = vim.fn.fnamemodify(file, ":t:r") -- Get filename without extension
    -- Skip certain plugins that cause errors
    if plugin_name ~= "init" and plugin_name ~= "gitsigns" then
      local ok, plugin = pcall(require, "plugins." .. directory .. "." .. plugin_name)
      if ok and plugin then
        if type(plugin) == "function" then
          local p = plugin()
          if p then table.insert(plugins, p) end
        else
          table.insert(plugins, plugin)
        end
      end
    end
  end
end

-- Load plugins from each directory, skipping git for now
local plugin_dirs = {
  "ui",
  "lsp",
  "completion",
  "treesitter", 
  "navigation",
  -- "git", -- Skip git integration initially
  "editor",
  "debugging"
}

-- Load plugins from each directory (silently)
for _, dir in ipairs(plugin_dirs) do
  load_plugins_from_dir(dir)
end

-- Finally, try to load a simplified git integration
pcall(function()
  table.insert(plugins, require("plugins.git.alternative"))
end)

-- Initialize lazy.nvim with all the collected plugins
local lazy_opts = {
  defaults = {
    lazy = false, -- Load plugins by default
  },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", 
        "tutor", "zipPlugin", "spellfile"
      },
    },
  },
  ui = {
    border = "single",
    icons = {
      cmd = "[CMD]",
      config = "[CONFIG]",
      event = "[EVENT]",
      ft = "[FT]",
      init = "[INIT]",
      keys = "[KEYS]",
      plugin = "[PLUGIN]",
      runtime = "[RUNTIME]",
      source = "[SOURCE]",
      start = "[START]",
      task = "[TASK]",
      lazy = "[LAZY]",
    },
  },
  install = {
    missing = true,
  },
  change_detection = {
    enabled = true, -- Enable change detection
    notify = true,
  },
}

-- Load lazy and setup plugins
local lazy_ok, lazy = pcall(require, "lazy")
if lazy_ok then
  lazy.setup(plugins, lazy_opts)
else
  vim.notify("Failed to load lazy.nvim plugin manager", vim.log.levels.ERROR)
end

-- Ensure commands are available
vim.api.nvim_create_user_command('Mason', function()
  vim.cmd('lua require("mason.ui").open()')
end, {})

vim.api.nvim_create_user_command('LspInfo', function()
  -- Use the proper built-in function if available
  if vim.lsp and vim.lsp.info and vim.lsp.info.show_window then
    -- For newer versions of Neovim
    vim.lsp.info.show_window()
  elseif vim.lsp.buf and vim.lsp.buf.server_info then
    -- For older versions
    vim.lsp.buf.server_info()
  else
    -- Simple fallback
    local clients = vim.lsp.get_active_clients()
    print("Active LSP clients: " .. vim.inspect(clients))
  end
end, {})

-- Create command to debug plugins
vim.api.nvim_create_user_command('DebugPlugins', debug_plugins, {})

return { plugins = plugins }
