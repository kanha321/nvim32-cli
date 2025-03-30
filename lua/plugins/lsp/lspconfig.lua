-- LSP configuration for CLI
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/neodev.nvim', -- Optional: Better Lua development
    'mfussenegger/nvim-jdtls', -- Add JDTLS as a direct dependency
  },
  priority = 100, -- Load this before most plugins
  -- Force loading on startup instead of lazy loading
  lazy = false,
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

    -- Ensure jdtls is installed by Mason if it's not available on the system
    local jdtls_ok = pcall(require, "jdtls")
    if not jdtls_ok then
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if mason_registry_ok then
        if not mason_registry.is_installed("jdtls") then
          vim.notify("JDTLS not found, installing with Mason...", vim.log.levels.INFO)
          local jdtls_pkg = mason_registry.get_package("jdtls")
          jdtls_pkg:install():once("closed", function()
            vim.notify("JDTLS installation complete", vim.log.levels.INFO)
          end)
        else
          vim.notify("JDTLS is installed in Mason", vim.log.levels.INFO)
        end
      end
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

    -- Set up diagnostic signs with ASCII characters
    local function setup_diagnostics()
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
    end

    setup_diagnostics()
    
    -- Get capabilities for completion
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    
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
          vim.notify("LSP server " .. server_name .. " configured", vim.log.levels.INFO)
        end
      end,
    })
    
    -- Create a timer to check if any Java files are open and start JDTLS
    vim.defer_fn(function()
      local java_buffers = {}
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, "filetype") == "java" then
          table.insert(java_buffers, bufnr)
        end
      end
      
      if #java_buffers > 0 then
        vim.notify("Found Java files, starting JDTLS", vim.log.levels.INFO)
        -- Try to use our custom setup, but fall back to Mason's setup if needed
        local ok, jdtls_setup = pcall(require, "plugins.lsp.jdtls")
        if ok then
          jdtls_setup.setup()
        else
          -- Backup path: try to load from configs directory
          local ok2, jdtls_config = pcall(require, "plugins.configs.jdtls")
          if ok2 then
            jdtls_config.setup()
          else
            -- Last resort: try the base file
            pcall(require, "lsp.java")
          end
        end
      end
    end, 1000) -- 1 second delay
    
    -- Set up Java file detection
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        vim.notify("Java file detected, starting JDTLS", vim.log.levels.INFO)
        -- Try to use our custom setup, but fall back to Mason's setup if needed
        local ok, jdtls_setup = pcall(require, "plugins.lsp.jdtls")
        if ok then
          jdtls_setup.setup()
        else
          -- Backup path: try to load from configs directory
          local ok2, jdtls_config = pcall(require, "plugins.configs.jdtls")
          if ok2 then
            jdtls_config.setup()
          else
            -- Last resort: try the base file
            pcall(require, "lsp.java")
          end
        end
      end,
    })

    -- Create proper LspInfo command that shows the UI
    vim.api.nvim_create_user_command('LspInfo', function()
      -- Use the proper built-in function if available
      if vim.lsp and vim.lsp.buf and vim.lsp.buf.server_info then
        vim.lsp.buf.server_info()
      else
        -- Fallback to a basic version if the builtin command isn't available
        local clients = vim.lsp.get_active_clients()
        if #clients == 0 then
          vim.notify("No active LSP clients found.", vim.log.levels.WARN)
        else
          local lines = {"Active LSP clients:"}
          for i, client in ipairs(clients) do
            local client_info = string.format("%d. %s (id: %d) - serving: %s", 
              i, client.name, client.id, table.concat(vim.lsp.get_buffers_by_client_id(client.id) or {}, ", "))
            table.insert(lines, client_info)
          end
          vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
        end
      end
    end, {})
    
    -- Add a command to manually start the LSP for Java
    vim.api.nvim_create_user_command('StartJdtls', function()
      vim.notify("Manually starting JDTLS", vim.log.levels.INFO)
      local ok, jdtls_setup = pcall(require, "plugins.lsp.jdtls")
      if ok then
        jdtls_setup.setup()
        vim.notify("JDTLS startup requested from plugins.lsp.jdtls", vim.log.levels.INFO)
      else
        vim.notify("Failed to load plugins.lsp.jdtls: " .. tostring(jdtls_setup), vim.log.levels.ERROR)
        -- Try other paths
        local ok2, jdtls_config = pcall(require, "plugins.configs.jdtls")
        if ok2 then
          jdtls_config.setup()
          vim.notify("JDTLS startup requested from plugins.configs.jdtls", vim.log.levels.INFO)
        else
          vim.notify("Failed to load plugins.configs.jdtls: " .. tostring(jdtls_config), vim.log.levels.ERROR)
          -- Last resort
          local ok3, _ = pcall(require, "lsp.java")
          if ok3 then
            vim.notify("JDTLS startup requested from lsp.java", vim.log.levels.INFO)
          else
            vim.notify("All JDTLS configurations failed to load", vim.log.levels.ERROR)
          end
        end
      end
    end, {})
    
    -- Add debugging command
    vim.api.nvim_create_user_command('LspDebug', function()
      -- Check Mason installation
      local mason_ok, mason_registry = pcall(require, "mason-registry")
      if mason_ok then
        if mason_registry.is_installed("jdtls") then
          local path = mason_registry.get_package("jdtls"):get_install_path()
          vim.notify("JDTLS installed at: " .. path, vim.log.levels.INFO)
        else
          vim.notify("JDTLS not installed via Mason", vim.log.levels.WARN)
        end
      end
      
      -- Check available config files
      local function check_file(path)
        if vim.fn.filereadable(path) == 1 then
          vim.notify("Config file exists: " .. path, vim.log.levels.INFO)
        else
          vim.notify("Config file missing: " .. path, vim.log.levels.WARN)
        end
      end
      
      check_file(vim.fn.stdpath("config") .. "/lua/plugins/lsp/jdtls.lua")
      check_file(vim.fn.stdpath("config") .. "/lua/plugins/configs/jdtls.lua")
      check_file(vim.fn.stdpath("config") .. "/lua/lsp/java.lua")
      
      -- Show LSP logs
      vim.notify("LSP log path: " .. vim.lsp.get_log_path(), vim.log.levels.INFO)
    end, {})
  end,
}
