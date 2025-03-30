-- LSP configuration

local M = {}

-- Set up diagnostic signs
local function setup_diagnostics()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  vim.diagnostic.config({
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })
end

-- Set up keymaps when LSP attaches to a buffer
local function on_attach(client, bufnr)
  -- LSP keybindings
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Navigation
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  
  -- Actions
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  
  -- Diagnostics
  vim.keymap.set("n", "<leader>f", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
  
  -- Add signature help in insert mode
  vim.keymap.set("i", "<C-p>", vim.lsp.buf.signature_help, opts)
  
  -- Disable formatting for LSP if we want to use a separate formatter
  if client.name == "jdtls" or client.name == "kotlin_language_server" then
    client.server_capabilities.documentFormattingProvider = false
  end
end

local function setup()
  setup_diagnostics()
  
  -- Set up Mason for managing LSP servers
  require("mason").setup({
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
  
  require("mason-lspconfig").setup({
    ensure_installed = {
      "clangd",       -- For C/C++
      "kotlin_language_server",
      -- jdtls already installed via yay
    },
    automatic_installation = true,
  })
  
  -- Get capabilities for completion
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if has_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  
  -- Configure LSP servers
  local lspconfig = require("lspconfig")
  
  -- C/C++
  lspconfig.clangd.setup({
    on_attach = on_attach,
    capabilities = capabilities,
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
      "--malloc-trim",
      "--pch-storage=memory",
      "-j=2",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  })
  
  -- Kotlin
  lspconfig.kotlin_language_server.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "kotlin" },
    settings = {
      kotlin = {
        java = {
          javaToolchain = {
            minimumVersion = "8",
          },
        },
        compiler = {
          jvm = {
            target = "1.8",
          },
        },
      },
    },
  })
  
  -- Java setup is handled separately through an autocommand and nvim-jdtls
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
      require("plugins.configs.jdtls").setup()
    end,
  })
end

return { setup = setup }
