-- CLI-friendly indentation guides
return {
  'lukas-reineke/indent-blankline.nvim',
  main = "ibl",
  opts = {
    indent = { 
      char = "|",           -- Simple ASCII character
      tab_char = "|",       -- Same character for tabs
    },
    scope = { enabled = false }, -- Disable scope highlighting to save resources
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
      },
    },
  },
}
