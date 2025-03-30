local lspconfig = require("lspconfig")
local handlers = require("lsp.handlers")

lspconfig.clangd.setup({
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp" },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    -- Optimizations for 32-bit systems
    "--limit-results=20",
    "--limit-references=20",
    "--malloc-trim", -- Help reduce memory usage
    "--pch-storage=memory", -- Store precompiled headers in memory
    "-j=2", -- Limit parallel jobs for indexing
  },
  -- IntelliJ-like settings
  init_options = {
    usePlaceholders = true, -- Like parameter hints in IntelliJ
    completeUnimported = true,
    clangdFileStatus = true,
  },
})
