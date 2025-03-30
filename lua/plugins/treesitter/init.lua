-- Treesitter for better syntax highlighting
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    -- Check if we are in a CLI environment
    local is_cli = not (vim.g.gui_running or vim.o.termguicolors)
    
    require('nvim-treesitter.configs').setup {
      -- Install parsers synchronously if in a CLI environment
      sync_install = is_cli,
      -- Install only specific parsers to save memory on 32-bit system
      ensure_installed = { "c", "cpp", "java", "kotlin", "lua" },
      -- Enabling syntax highlighting
      highlight = { 
        enable = true,
        -- Disable for large files
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      -- Enabling indentation
      indent = { enable = true },
      -- Optimizations for 32-bit system
      incremental_selection = { enable = false },
    }

    -- Print status to help debug
    local loaded_parsers = require('nvim-treesitter.info').installed_parsers()
    print("Treesitter parsers loaded: " .. vim.inspect(loaded_parsers))
  end,
}
