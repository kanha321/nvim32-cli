-- LSP setup module
-- This file returns a table of plugin specs for lazy.nvim

return {
  -- General LSP support through lspconfig
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = true, -- Let lazy.nvim call setup()
  },

  -- Mason package manager
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "single",
        icons = {
          package_installed = "+",
          package_pending = "~", 
          package_uninstalled = "-"
        }
      }
    },
    config = true,
  },

  -- Bridge between Mason and lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {'williamboman/mason.nvim'},
    config = true, 
  },

  -- JDTLS support
  {
    'mfussenegger/nvim-jdtls',
    ft = { "java" }, -- Only load for Java files
    config = function()
      -- Create an autocmd that will set up JDTLS when we open java files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          -- Simple config with minimal settings to start
          local config = {
            cmd = {
              vim.fn.exepath('java'),
              '-Declipse.application=org.eclipse.jdt.ls.core.id1',
              '-Dosgi.bundles.defaultStartLevel=4',
              '-Declipse.product=org.eclipse.jdt.ls.core.product',
              '-Dlog.level=ALL',
              '-Xms1g',
              '-Xmx2g',
            },
          }

          -- Find Java executable, root directory, and use ftplugin/java.lua
          -- This defers the complex setup to the ftplugin file
          local jdtls_config_ok, _ = pcall(function()
            vim.cmd('source ' .. vim.fn.stdpath("config") .. '/ftplugin/java.lua')
          end)

          if not jdtls_config_ok then
            print("Error loading Java config. Check ftplugin/java.lua")
          end
        end
      })
    end
  },

  -- Load our lspconfig settings
  require('plugins/lsp/lspconfig'),
}
