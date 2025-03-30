-- Git related plugins
return {
  -- Git integration (lightweight)
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        -- Optimize for 32-bit system
        watch_gitdir = {
          interval = 2000,
          follow_files = true,
        },
        attach_to_untracked = false,
        max_file_length = 10000,
      })
    end,
  },
}
