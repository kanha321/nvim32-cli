-- Auto pairs for brackets
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    require('nvim-autopairs').setup({
      -- Settings optimized for 32-bit system
      check_ts = false, -- Don't use treesitter to check for pairs
      disable_filetype = { "TelescopePrompt" },
    })
  end,
}
