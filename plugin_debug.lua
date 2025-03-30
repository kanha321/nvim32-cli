-- Helper for debugging plugin issues
local M = {}

-- Helper function to inspect plugin health
function M.check_plugins()
  -- Check if NvimTree is loaded
  local nvimtree_loaded = package.loaded["nvim-tree"]
  print("NvimTree loaded: " .. tostring(nvimtree_loaded ~= nil))

  -- Check if Treesitter is loaded
  local ts_loaded = package.loaded["nvim-treesitter"]
  print("Treesitter loaded: " .. tostring(ts_loaded ~= nil))

  -- Check keymapping
  local leader_e_mapping = vim.api.nvim_get_keymap('n')
  local found = false
  for _, map in ipairs(leader_e_mapping) do
    if map.lhs == " e" then
      print("Leader+e mapping found: " .. vim.inspect(map))
      found = true
      break
    end
  end
  if not found then
    print("Leader+e mapping not found!")
  end

  -- Print leader key
  print("Leader key: " .. vim.inspect(vim.g.mapleader))
end

-- Create user command for easy checking
vim.api.nvim_create_user_command('CheckPlugins', M.check_plugins, {})

return M
