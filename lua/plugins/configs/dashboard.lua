-- CLI-friendly welcome dashboard
local M = {}

function M.setup()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")
  
  -- ASCII art header (CLI-friendly)
  dashboard.section.header.val = {
    "                                  ",
    "    ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
    "    ████╗  ██║██║   ██║██║████╗ ████║",
    "    ██╔██╗ ██║██║   ██║██║██╔████╔██║",
    "    ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "    ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "    ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
    "                                  ",
    " Java + Kotlin + C/C++ Development IDE ",
  }

  -- Make the header thinner if terminal width is small
  if vim.o.columns < 70 then
    dashboard.section.header.val = {
      "                                  ",
      "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
      "  ████╗  ██║██║   ██║██║████╗ ████║",
      "  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
      "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      " JVM & C/C++ Development Environment",
    }
  end

  -- Set menu
  dashboard.section.buttons.val = {
    dashboard.button("e", "New file", ":enew<CR>"),
    dashboard.button("f", "Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("p", "Projects", ":Telescope projects<CR>"),
    dashboard.button("g", "Find text", ":Telescope live_grep<CR>"),
    dashboard.button("c", "Configuration", ":e ~/.config/nvim/init.lua<CR>"),
    dashboard.button("u", "Update plugins", ":Lazy sync<CR>"),
    dashboard.button("q", "Quit", ":qa<CR>"),
  }

  -- Simple footer with date/time
  dashboard.section.footer.val = {
    " " .. os.date("%Y-%m-%d %H:%M"),
    " Loaded " .. #vim.tbl_keys(packer_plugins or {}) .. " plugins",
  }

  -- Customize colors for CLI compatibility
  dashboard.section.header.opts.hl = "String"
  dashboard.section.buttons.opts.hl = "Keyword"
  dashboard.section.footer.opts.hl = "Comment"

  -- Don't show the cursor in alpha
  vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
  ]])

  alpha.setup(dashboard.config)
end

return M
