-- UI plugins
return {
  -- TUI Compatible Themes
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    config = function()
      -- Terminal-friendly settings
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
        }
      })
      vim.cmd.colorscheme('carbonfox')
    end,
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = false,
          theme = 'auto', -- Auto detect from colorscheme
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = { "NvimTree" },
        },
        sections = {
          lualine_a = {{'mode', fmt = function(str) return str:sub(1,1) end}},
          lualine_b = {{'filename', path = 1}},
          lualine_c = {{'diagnostics', symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'}}},
          lualine_x = {'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end,
    dependencies = {} -- Remove dependency on web-devicons
  },

  -- File Explorer
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          
          -- Helper function for creating keymaps
          local function map(key, action, desc)
            vim.keymap.set('n', key, action, { buffer = bufnr, desc = desc, noremap = true, silent = true })
          end

          -- Default mappings for usability
          map("<CR>", api.node.open.edit, "Open")
          map("o", api.node.open.edit, "Open")
          map("<2-LeftMouse>", api.node.open.edit, "Open")
          map("d", api.fs.remove, "Delete")
          map("a", api.fs.create, "Create")
          map("r", api.fs.rename, "Rename")
          map("c", api.fs.copy.node, "Copy")
          map("x", api.fs.cut, "Cut")
          map("p", api.fs.paste, "Paste")
          map("q", api.tree.close, "Close Window")
        end,
        
        view = {
          width = 30,
        },
        renderer = {
          add_trailing = true,
          group_empty = true,
          icons = {
            show = {
              git = false,
              folder = false,
              file = false,
              folder_arrow = false,
            },
            glyphs = {
              folder = {
                arrow_closed = "+",
                arrow_open = "-",
              },
            },
          },
          special_files = {},
          symlink_destination = false,
        },
        filters = {
          dotfiles = false,
          custom = { ".git", "node_modules", "target", ".idea" },
        },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
      })
    end,
    dependencies = {} -- Remove dependency on web-devicons
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {
      indent = { char = "|" }, -- Simple ASCII character
      scope = { enabled = false }, -- Disable scope highlighting to save resources
    },
  },
}
