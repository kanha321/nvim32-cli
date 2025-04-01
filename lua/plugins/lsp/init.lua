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
  
  -- Java language support with bundled JDTLS
  {
    'mfussenegger/nvim-jdtls',
    ft = { "java" }, -- Only load for Java files
  },

  -- Load our lspconfig settings
  require('plugins/lsp/lspconfig'),
}
