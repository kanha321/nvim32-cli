-- LSP setup
local function setup()
  -- Set up LSP configuration
  require("plugins.configs.lspconfig").setup()
  
  -- Set up completion
  require("plugins.configs.cmp").setup()
end

return setup
