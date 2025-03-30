-- NvimTree configuration
local function setup()
  require("nvim-tree").setup({
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = { ".git", "node_modules", "target", ".idea" }, -- Hide IntelliJ and build files
    },
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
  })
  
  -- Set up keymaps
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-1>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
end

setup()
