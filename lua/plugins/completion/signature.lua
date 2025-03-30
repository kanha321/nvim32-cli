-- LSP signature help for function parameter hints
return {
  "ray-x/lsp_signature.nvim",
  event = "VeryLazy",
  config = function()
    local lsp_signature = require("lsp_signature")
    lsp_signature.setup({
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
      lsp_signature.signature()
    end, { noremap = true, silent = true, desc = "Show parameter hints" })
  end,
}
