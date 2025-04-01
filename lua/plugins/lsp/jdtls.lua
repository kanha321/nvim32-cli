-- Bundled JDTLS configuration
return {
  'mfussenegger/nvim-jdtls',
  ft = { "java" },
  config = function()
    local function configure_jdtls()
      local jdtls = require('jdtls')
      
      -- Find root directory
      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = require('jdtls.setup').find_root(root_markers) or vim.fn.getcwd()
      
      -- Project name for workspace folder
      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
      vim.fn.mkdir(workspace_dir, "p")

      -- Get the config directory path
      local config_dir = vim.fn.stdpath("config")
      
      -- Use bundled JDTLS version (using relative path)
      local jdtls_dir = config_dir .. "/jdtls-1.43"
      local launcher_jar = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      
      -- Find Java executable
      local java_cmd = vim.fn.exepath('java')
      
      -- Basic config
      local config = {
        cmd = {
          java_cmd,
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Xms1g',
          '-Xmx2g',
          '-jar', launcher_jar,
          '-configuration', jdtls_dir .. "/config_linux",
          '-data', workspace_dir,
        },
        root_dir = root_dir,
        settings = {
          java = {
            configuration = {
              -- Use bundled JDK if available or fall back to system JDK
              runtimes = {
                {
                  name = "JavaSE-17",
                  path = vim.env.JAVA_HOME or vim.fn.expand("/usr/lib/jvm/java-17-openjdk/"),
                  default = true,
                },
              },
              updateBuildConfiguration = "interactive",
            },
            server = {
              -- Enable tracing for debugging
              trace = {
                server = "verbose",
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            format = {
              enabled = true,
            },
            signatureHelp = { 
              enabled = true,
            },
          },
        },
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        on_attach = function(client, bufnr)
          -- Standard keymaps
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

          -- JDTLS specific keymaps
          vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
          vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
          vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, opts)
          vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, opts)
          vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, opts)
          vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, opts)
          vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, opts)
        end,
        init_options = {
          bundles = {},
        },
        flags = {
          debounce_text_changes = 150,
          allow_incremental_sync = true,
        }
      }
      
      -- Start JDTLS server
      jdtls.start_or_attach(config)
      
      -- Register commands
      vim.api.nvim_create_user_command('JdtUpdateConfig', function() 
        jdtls.update_project_config()
        print("JDTLS project configuration updated")
      end, {})
      
      vim.api.nvim_create_user_command('JdtJol', function(opts)
        jdtls.jol(opts.args)
      end, { nargs = '?' })
      
      vim.api.nvim_create_user_command('JdtBytecode', function(opts)
        jdtls.javap(opts.args)
      end, { nargs = '?' })
      
      vim.api.nvim_create_user_command('JdtJshell', function()
        jdtls.jshell()
      end, {})
    end
    
    -- Create autocmd to start JDTLS when opening Java files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = configure_jdtls,
    })
    
    -- Add restart command
    vim.api.nvim_create_user_command('JdtRestart', function()
      -- Stop any running JDTLS
      for _, client in ipairs(vim.lsp.get_active_clients()) do
        if client.name == "jdtls" then
          client.stop()
        end
      end
      
      -- Reload the current buffer to trigger the FileType autocmd
      vim.cmd("e")
      
      -- Print confirmation
      print("JDTLS restarted")
    end, {})
  end
}
