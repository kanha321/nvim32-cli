local M = {}

function M.setup()
  local ls = require("luasnip")
  
  -- Configure Luasnip
  ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    ext_opts = {
      [require("luasnip.util.types").choiceNode] = {
        active = {
          virt_text = { { "●", "GruvboxOrange" } }
        }
      }
    }
  })

  -- Load VSCode-style snippets from friendly-snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  -- Load custom snippets
  local java_snippets = require("snippets.java")
  ls.add_snippets("java", java_snippets)

  -- Java snippets should also work in Kotlin files
  ls.filetype_extend("kotlin", {"java"})
  
  -- Optional: Make snippets available in JavaDoc comments
  ls.filetype_extend("javadoc", {"java"})

  -- Add more custom snippet languages here as needed
  -- local python_snippets = require("snippets.python")
  -- ls.add_snippets("python", python_snippets)

  -- Print a message when snippets are loaded
  vim.notify("Custom snippets loaded: Java", vim.log.levels.INFO)
end

return M
