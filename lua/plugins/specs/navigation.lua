-- Navigation related plugins
return {
  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          -- Optimize for 32-bit systems
          preview = {
            treesitter = false,
          },
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              preview_height = 0.5,
            },
          },
        },
      })
      
      -- Setup keymaps
      local builtin = require('telescope.builtin')
      local opts = { noremap = true, silent = true }
      
      vim.keymap.set('n', '<C-p>', builtin.find_files, opts)           -- Find files (IntelliJ Ctrl+Shift+N)
      vim.keymap.set('n', '<C-S-f>', builtin.live_grep, opts)          -- Find in files
      vim.keymap.set('n', '<C-e>', builtin.buffers, opts)              -- Recent files
      vim.keymap.set('n', '<F12>', builtin.lsp_definitions, opts)      -- Go to definition
      vim.keymap.set('n', '<C-S-o>', builtin.lsp_document_symbols, opts) -- File structure
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "cpp", "java", "kotlin", "lua" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
}
