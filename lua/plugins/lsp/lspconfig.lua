-- LSP configuration for CLI
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/neodev.nvim', -- Optional: Better Lua development
    'mfussenegger/nvim-jdtls', -- Add JDTLS as a direct dependency
  },
  config = function()
    -- Set up Mason first (must be before LSP setup)
    require("mason").setup({
      ui = {
        border = "single", -- Simple border
        icons = {
          package_installed = "+",
          package_pending = "~",
          package_uninstalled = "-"
        }
      },
      -- Limit concurrent downloads
      max_concurrent_installers = 2,
      -- Make sure the install directory has correct permissions
      install_root_dir = vim.fn.stdpath("data") .. "/mason",
    })

    -- Set up diagnostic signs with ASCII characters
    local signs = {
      { name = "DiagnosticSignError", text = "E" },
      { name = "DiagnosticSignWarn", text = "W" },
      { name = "DiagnosticSignHint", text = "H" },
      { name = "DiagnosticSignInfo", text = "I" },
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
        border = "single", -- Simple border
        source = "always",
        header = "",
        prefix = "",
      },
    })

    -- Set up keymaps when LSP attaches to a buffer
    local on_attach = function(client, bufnr)
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
    end
    
    -- Get capabilities for completion
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    
    -- Then set up mason-lspconfig as a bridge between Mason and lspconfig
    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd",           -- C/C++
        "kotlin_language_server",
        "jdtls",           -- Now we include JDTLS in ensure_installed
      },
      automatic_installation = true,
    })
    
    -- Let mason-lspconfig handle the server setup
    require("mason-lspconfig").setup_handlers({
      -- Default handler
      function(server_name)
        if server_name ~= "jdtls" then -- Skip jdtls as it's handled separately
          local server_config = {
            on_attach = on_attach,
            capabilities = capabilities,
          }
          
          -- Special configs for specific servers
          if server_name == "clangd" then
            server_config.cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
              "--limit-results=20",
              "--limit-references=20",
              "--malloc-trim",
              "--pch-storage=memory",
              "-j=2",
            }
          elseif server_name == "kotlin_language_server" then
            server_config.settings = {
              kotlin = {
                java = {
                  javaToolchain = {
                    minimumVersion = "17",
                  },
                },
                compiler = {
                  jvm = {
                    target = "17",
                  },
                },
              },
            }
          end
          
          require("lspconfig")[server_name].setup(server_config)
          print("LSP server " .. server_name .. " configured")
        end
      end,
    })
  end
}
