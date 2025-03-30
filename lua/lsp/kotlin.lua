local lspconfig = require("lspconfig")
local handlers = require("lsp.handlers")

lspconfig.kotlin_language_server.setup({
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
  filetypes = { "kotlin" },
  settings = {
    kotlin = {
      java = {
        javaToolchain = {
          minimumVersion = "17", -- Updated to Java 17
        },
      },
      compiler = {
        jvm = {
          target = "17", -- Updated to Java 17
        },
      },
    },
  },
})
