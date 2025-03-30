-- Mason plugin configuration
return {
  'williamboman/mason.nvim',
  cmd = "Mason",
  build = ":MasonUpdate",
  priority = 999,
  config = function()
    -- Explicitly setup Mason
    require("mason").setup({
      ui = {
        border = "single",
        icons = {
          package_installed = "+",
          package_pending = "~",
          package_uninstalled = "-"
        }
      },
      -- Ensure proper installation paths
      install_root_dir = vim.fn.stdpath("data") .. "/mason",
      PATH = "prepend", -- Prepend Mason binaries to PATH
      pip = {
        upgrade_pip = true,
      },
      max_concurrent_installers = 2, -- Limit for 32-bit systems
      registries = {
        "github:mason-org/mason-registry",
      },
      log_level = vim.log.levels.INFO,
    })

    -- Create convenience commands that users expect
    vim.api.nvim_create_user_command('MasonInstall', function(opts)
      vim.cmd('lua require("mason-registry").install("' .. opts.args .. '")')
    end, { nargs = 1, complete = "custom,v:lua.mason_completion" })
    
    vim.api.nvim_create_user_command('MasonUninstall', function(opts)
      vim.cmd('lua require("mason-registry").uninstall("' .. opts.args .. '")')
    end, { nargs = 1, complete = "custom,v:lua.mason_completion" })
    
    vim.api.nvim_create_user_command('MasonUpdate', function()
      vim.cmd('lua require("mason-registry").update()')
    end, {})
    
    -- Completion function for Mason commands
    _G.mason_completion = function()
      local packages = require("mason-registry").get_all_packages()
      local names = {}
      for _, pkg in ipairs(packages) do
        table.insert(names, pkg.name)
      end
      return table.concat(names, "\n")
    end
  end,
  dependencies = {},
}
