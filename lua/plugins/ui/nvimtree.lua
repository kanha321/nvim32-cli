-- CLI-friendly file explorer with error fixes
return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    -- Disable netrw (vim's built-in file explorer)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    
    -- Disable git integration to avoid gitsigns conflicts
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
        
        -- Vim-like navigation with h and l
        map("l", api.node.open.edit, "Open File/Directory")
        map("h", api.node.navigate.parent_close, "Close Directory")
      end,
      
      view = {
        width = 30,
        preserve_window_proportions = true, -- Prevent window size issues
      },
      renderer = {
        add_trailing = true, -- Add trailing slash to folder names
        group_empty = true,
        highlight_git = false, -- Disable git highlighting
        highlight_opened_files = "none", -- Disable highlighting open files
        icons = {
          webdev_colors = false,
          show = {
            file = true,
            folder = true,
            folder_arrow = false,
            git = false,
          },
          glyphs = {
            default = ".", -- Simple dot for all files
            symlink = "L",
            folder = {
              arrow_closed = ">",
              arrow_open = "v",
              default = "#", -- Simple hash for folders
              open = "#",
              empty = "#",
              empty_open = "#",
              symlink = "L#",
              symlink_open = "L#",
            }
          },
        },
        special_files = {}, -- No special highlighting
        symlink_destination = false, -- Don't show symlink destination
      },
      git = {
        enable = false, -- Disable git integration completely
      },
      diagnostics = {
        enable = false, -- Disable diagnostics integration to reduce complexity
      },
      filters = {
        dotfiles = false,
        custom = { ".git", "node_modules", "target", ".idea" },
      },
      sync_root_with_cwd = false, -- Disable syncing to reduce errors
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true, 
        update_root = false, -- Disable updating root to prevent errors
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = true,
          global = false,
          restrict_above_cwd = true,
        },
        open_file = {
          quit_on_open = false,
          resize_window = false, -- Disable resizing to avoid issues
        },
      },
      notify = {
        threshold = vim.log.levels.WARN, -- Only show warnings and errors
      },
      log = {
        enable = false,
        truncate = true,
        types = {
          git = false, -- Disable git logging
          profile = false, -- Disable profile logging
        },
      },
      system_open = {
        cmd = nil,
      },
    })
    
    -- Simple key mapping with error handling
    vim.keymap.set("n", "<leader>e", function()
      local status, err = pcall(function()
        vim.cmd("NvimTreeToggle")
      end)
      if not status then
        vim.notify("NvimTree error: " .. err, vim.log.levels.ERROR)
      end
    end, { noremap = true, silent = true, desc = "Toggle NvimTree" })
  end,
  -- No dependencies to prevent issues
  dependencies = {},
}
