-- Alternative minimal git indicators for 32-bit systems
-- This plugin is much simpler and less likely to cause errors
return {
  'airblade/vim-gitgutter',
  lazy = true,
  event = "BufReadPre",
  init = function()
    vim.g.gitgutter_max_signs = 500 -- Limit the number of signs for performance
    vim.g.gitgutter_map_keys = 0 -- Disable default key mappings
    vim.g.gitgutter_preview_win_floating = 0 -- Disable floating windows
    vim.g.gitgutter_sign_added = '+'
    vim.g.gitgutter_sign_modified = '~'
    vim.g.gitgutter_sign_removed = '_'
    vim.g.gitgutter_sign_removed_first_line = '^'
    vim.g.gitgutter_sign_removed_above_and_below = '{'
    vim.g.gitgutter_sign_modified_removed = '~_'
    vim.g.gitgutter_highlight_linenrs = 0 -- Don't highlight line numbers
  end,
}
