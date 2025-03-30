-- JDTLS configuration for Java development
return {
  'mfussenegger/nvim-jdtls',
  dependencies = {
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim', -- Add Mason as a dependency
  },
  config = function() 
    -- Configuration is in the setup function called by FileType autocmd
  end,
  setup = function()
    local jdtls_ok, jdtls = pcall(require, "jdtls")
    if not jdtls_ok then
      vim.notify("JDTLS not found, trying to install it with Mason...", vim.log.levels.WARN)
      
      -- Try to install JDTLS with Mason
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if mason_registry_ok then
        if not mason_registry.is_installed("jdtls") then
          vim.notify("Installing JDTLS with Mason...", vim.log.levels.INFO)
          local jdtls_pkg = mason_registry.get_package("jdtls")
          jdtls_pkg:install():once("closed", function()
            vim.notify("JDTLS installation complete", vim.log.levels.INFO)
          end)
        else
          vim.notify("JDTLS is already installed with Mason", vim.log.levels.INFO)
        end
      end
      return
    end

    -- Find project root
    local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
    local root_dir = require('jdtls.setup').find_root(root_markers)
    if not root_dir then
      root_dir = vim.fn.getcwd()
    end
    vim.notify("JDTLS project root: " .. root_dir, vim.log.levels.INFO)

    -- Make sure the data directory exists and has correct permissions
    local cache_dir = vim.fn.expand('~/.cache/jdtls')
    if vim.fn.isdirectory(cache_dir) ~= 1 then
      vim.fn.mkdir(cache_dir, 'p', 0700)
      vim.notify("Created JDTLS cache directory: " .. cache_dir, vim.log.levels.INFO)
    else
      -- Fix permissions if needed
      vim.loop.fs_chmod(cache_dir, 448) -- 0700 in octal
      vim.notify("Fixed permissions for JDTLS cache directory", vim.log.levels.INFO)
    end
    
    -- Project specific data directory
    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = cache_dir .. "/workspace/" .. project_name
    
    -- Ensure workspace directory exists and has proper permissions
    if vim.fn.isdirectory(workspace_dir) ~= 1 then
      vim.fn.mkdir(workspace_dir, 'p', 0700)
      vim.notify("Created JDTLS workspace: " .. workspace_dir, vim.log.levels.INFO)
    else
      -- Fix permissions
      vim.loop.fs_chmod(workspace_dir, 448) -- 0700 in octal
    end
    
    -- Fix for exit code 13: Redirect stderr to a file with proper permissions
    local stderr_path = cache_dir .. "/jdtls_stderr.log"
    local stderr_file = io.open(stderr_path, 'w')
    if stderr_file then
      stderr_file:close()
      -- Fix permissions for the log file
      vim.loop.fs_chmod(stderr_path, 384) -- 0600 in octal
    end

    -- Fix permissions for directories and files
    local function fix_permissions()
      -- Create a temp directory with permissive permissions
      local tmp_dir = vim.fn.expand("~/.cache/jdtls/temp")
      vim.fn.mkdir(tmp_dir, 'p', 0777)
      vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(tmp_dir))
      
      -- Fix workspace directory permissions
      vim.fn.mkdir(workspace_dir, 'p', 0777)
      vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(workspace_dir))
      
      -- Set temp directory environment variables
      vim.env.TEMP = tmp_dir
      vim.env.TMP = tmp_dir
      vim.env.TMPDIR = tmp_dir
      vim.env.JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=" .. tmp_dir
      
      return tmp_dir
    end

    -- Fix permissions before proceeding
    local tmp_dir = fix_permissions()

    -- Check if jdtls is already running for this buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
        if client.name == "jdtls" then
            vim.notify("JDTLS is already running for this buffer", vim.log.levels.INFO)
            return
        end
    end

    -- Find available Java runtime
    local java_cmd = nil
    local possible_java_paths = {
      '/usr/lib/jvm/java-17-openjdk/bin/java',
      '/usr/lib/jvm/java-17-openjdk-amd64/bin/java',
      '/usr/lib/jvm/java-17/bin/java',
      '/usr/lib/jvm/java-17-oracle/bin/java',
      vim.fn.exepath('java') -- Try to use java from PATH
    }

    for _, path in ipairs(possible_java_paths) do
      if vim.fn.executable(path) == 1 then
        java_cmd = path
        break
      end
    end

    if not java_cmd then
      vim.notify("Java 17 not found. Please install Java 17.", vim.log.levels.ERROR)
      return
    end

    -- Get jdtls path - try multiple sources
    local jdtls_path = nil
    local try_paths = {}
    
    -- First check if Mason has it
    local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
    if mason_registry_ok then
      if mason_registry.is_installed('jdtls') then
        local package = mason_registry.get_package('jdtls')
        local install_path = package:get_install_path()
        table.insert(try_paths, install_path)
        vim.notify("Found Mason JDTLS at: " .. install_path, vim.log.levels.INFO)
      end
    end

    -- Then try system paths
    table.insert(try_paths, '/usr/share/java/jdtls') -- Arch Linux
    table.insert(try_paths, '/opt/jdtls') -- Another common location

    -- Try each path until we find one with the launcher jar
    for _, path in ipairs(try_paths) do
      local launcher_jar = vim.fn.glob(path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
      if launcher_jar ~= "" then
        jdtls_path = path
        vim.notify("Found JDTLS at: " .. jdtls_path, vim.log.levels.INFO)
        break
      end
    end

    if not jdtls_path then
      vim.notify("JDTLS installation not found. Please install JDTLS with Mason or system package manager.", vim.log.levels.ERROR)
      return
    end

    -- Create temporary directory with correct permissions
    vim.fn.mkdir(vim.fn.expand('~/.cache/jdtls/temp'), 'p', 0700)

    -- Simplified configuration with minimal options to avoid permission issues
    local config = {
      cmd = {
        java_cmd,
        '-Djava.io.tmpdir=' .. tmp_dir,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.level=INFO',
        '-Xms512m',
        '-Xmx1024m',
        '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', jdtls_path .. '/config_linux',
        '-data', workspace_dir,
      },
      
      -- Handle stderr redirection differently - don't use cmd_env as it might cause issues
      root_dir = root_dir,

      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = 'fernflower' },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.jupiter.api.Assumptions.*",
              "org.junit.jupiter.api.DynamicContainer.*",
              "org.junit.jupiter.api.DynamicTest.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
          },
          configuration = {
            -- Updated to Java 17
            runtimes = {
              {
                name = "JavaSE-17",
                path = "/usr/lib/jvm/java-17-openjdk/", -- Updated to Java 17
                default = true,
              },
            },
            updateBuildConfiguration = "automatic", -- Change to automatic
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
          errors = {
            incompleteClasspath = { enabled = false },
          },
        },
      },
      
      init_options = {
        bundles = {},
        extendedClientCapabilities = {
          progressReportProvider = true,
          classFileContentProvider = true,
          overrideMethodsPromptSupport = true,
          hashCodeEqualsPromptSupport = true,
          advancedOrganizeImportsSupport = true,
          generateToStringPromptSupport = true,
          advancedExtractRefactoringSupport = true,
        },
        -- Add client-side timeout settings
        clientSideRpcPreferenceMaxTimeout = 60000, -- 60 seconds
      },
      
      on_attach = function(client, bufnr)
        vim.notify("JDTLS attached to buffer", vim.log.levels.INFO)
        
        -- Protected call for keymaps
        local status_ok, _ = pcall(function()
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
          
          -- JDTLS specific key mappings (IntelliJ-like)
          vim.keymap.set("n", "<A-o>", function()
            pcall(jdtls.organize_imports)
          end, opts)
          
          vim.keymap.set("n", "<leader>jp", function()
            pcall(jdtls.organize_imports)
          end, opts)
          
          vim.keymap.set("n", "<leader>ev", function()
            pcall(jdtls.extract_variable)
          end, opts)
          vim.keymap.set("v", "<leader>ev", function()
            pcall(function() jdtls.extract_variable(true) end)
          end, opts)
          vim.keymap.set("n", "<leader>ec", function()
            pcall(jdtls.extract_constant)
          end, opts)
          vim.keymap.set("v", "<leader>ec", function()
            pcall(function() jdtls.extract_constant(true) end)
          end, opts)
          vim.keymap.set("v", "<leader>em", function()
            pcall(function() jdtls.extract_method(true) end)
          end, opts)
        end)
        
        if not status_ok then
          vim.notify("Error setting up JDTLS keymaps", vim.log.levels.ERROR)
        end
      end,
      
      -- Add an on_exit handler to log when the server exits
      on_exit = function(code, signal, client_id)
        vim.notify(string.format("JDTLS exited with code %d and signal %s (client_id: %d)", 
                                code, signal, client_id), 
                  vim.log.levels.WARN)
        
        if stderr_file then
          stderr_file:close()
          
          -- Read and display the stderr log
          local stderr_content = io.open(vim.fn.expand('~/.cache/jdtls/jdtls_stderr.log'), 'r')
          if stderr_content then
            local content = stderr_content:read("*all")
            stderr_content:close()
            
            if content and #content > 0 then
              vim.notify("JDTLS stderr: " .. content, vim.log.levels.ERROR)
            end
          end
        end
      end,

      flags = {
        allow_incremental_sync = true,
        server_side_fuzzy_completion = true,
        debounce_text_changes = 150,
      },
    }
    
    -- Start JDTLS with protected call and additional error handling
    vim.notify("Starting JDTLS...", vim.log.levels.INFO)
    local start_ok, error_msg = pcall(function()
      jdtls.start_or_attach(config)
    end)
    
    if not start_ok then
      vim.notify("Error starting JDTLS: " .. tostring(error_msg), vim.log.levels.ERROR)
      vim.notify("Try running ':JdtlsMinimal' command for a minimal configuration", vim.log.levels.INFO)
      
      -- Alternative startup with even more minimal options
      vim.defer_fn(function()
        vim.notify("Attempting alternative startup...", vim.log.levels.INFO)
        
        -- Try ultra minimal config as a last resort
        local minimal_config = {
          cmd = {
            java_cmd,
            '-Djava.io.tmpdir=' .. tmp_dir,
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
            '-configuration', jdtls_path .. '/config_linux',
            '-data', workspace_dir,
          },
          root_dir = root_dir,
        }
        
        pcall(function()
          jdtls.start_or_attach(minimal_config)
        end)
      end, 1000)
      
      return
    end
    
    vim.notify("JDTLS started successfully", vim.log.levels.INFO)
  end
}
