-- CLI-friendly status line configuration
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      options = {
        icons_enabled = false, -- Disable icons for CLI
        theme = 'auto', -- Auto detect from colorscheme
        component_separators = { left = '|', right = '|' }, -- Simple ASCII separators
        section_separators = { left = '', right = '' },
        disabled_filetypes = { "NvimTree" },
      },
      sections = {
        lualine_a = {{'mode', fmt = function(str) return str:sub(1,1) end}}, -- Show only first letter of mode
        lualine_b = {{'filename', path = 1}}, -- Show relative path
        lualine_c = {{'diagnostics', symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'}}},
        lualine_x = {'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    })
  end,
  dependencies = {} -- Remove dependency on web-devicons
}
