-- CLI-friendly theme configuration (nightfox instead of gruvbox)
return {
  'EdenEast/nightfox.nvim',
  priority = 1000,
  config = function()
    -- Terminal-friendly settings for a dark theme
    require('nightfox').setup({
      options = {
        -- Transparent background
        transparent = true,
        -- No italic or bold font styles
        styles = {
          comments = "NONE",
          conditionals = "NONE",
          constants = "NONE",
          functions = "NONE",
          keywords = "NONE",
          numbers = "NONE",
          operators = "NONE",
          strings = "NONE",
          types = "NONE",
          variables = "NONE",
        },
        -- For 32-bit systems and CLI compatibility
        terminal_colors = true,
        dim_inactive = false,
      },
      groups = {
        all = {
          -- Simplify UI elements for CLI
          CursorLine = { bg = "NONE" },
          StatusLine = { fg = "fg1", bg = "bg1" },
          StatusLineNC = { fg = "fg2", bg = "bg1" },
          SignColumn = { bg = "NONE" },
        }
      }
    })
    
    -- Set to carbonfox or nordfox variant (CLI friendly)
    vim.cmd.colorscheme('carbonfox')
  end,
}
