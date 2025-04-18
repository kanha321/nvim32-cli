-- Comment toggling like in IntelliJ
return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup()
    
    -- Comment toggling (IntelliJ-like)
    local api = require('Comment.api')
    vim.keymap.set('n', '<C-/>', api.toggle.linewise.current, { noremap = true, silent = true })
    vim.keymap.set('v', '<C-/>', function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
      api.toggle.linewise(vim.fn.visualmode())
    end, { noremap = true, silent = true })
  end,
}
