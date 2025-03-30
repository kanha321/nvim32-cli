-- LSP related plugins
return {
  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require("plugins.configs.lsp")
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets', -- IntelliJ-like snippets
    },
    config = function()
      require("plugins.configs.cmp")
    end,
  },

  -- LSP signature help (for showing function parameters)
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function()
      require("lsp_signature").setup({
        bind = true,
        handler_opts = {
          border = "rounded",
        },
        hint_enable = false, -- We'll use our own keybinding instead of automatic hints
        hint_prefix = "🔍 ",
        max_height = 12,
        max_width = 80,
      })
      -- Show parameters on keypress
      vim.keymap.set('i', '<C-p>', function()
        require("lsp_signature").signature()
      end, { noremap = true, silent = true, desc = "Show parameter hints" })
    end,
  },

  -- JDTLS (Java support)
  {
    'mfussenegger/nvim-jdtls',
  },
}
