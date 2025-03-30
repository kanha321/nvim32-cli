local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
  return
end

mason.setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
  -- Limit concurrent downloads to be gentle on 32-bit systems
  max_concurrent_installers = 2,
})

mason_lspconfig.setup({
  ensure_installed = {
    "clangd",       -- For C/C++
    "kotlin_language_server",
    -- jdtls already installed via yay
  },
  automatic_installation = true,
})

-- Configure each language server
local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

-- Setup handlers
local handlers = require("lsp.handlers")
handlers.setup()

-- Configure servers
-- C/C++
lspconfig.clangd.setup({
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

-- Kotlin
lspconfig.kotlin_language_server.setup({
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
})

-- Java is configured separately in java.lua
