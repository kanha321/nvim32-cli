-- Java Development Tools Language Server configuration
local M = {}

function M.setup()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    vim.notify("JDTLS not found, trying to install it with Mason...", vim.log.levels.WARN)
    
    -- Try to install JDTLS with Mason
    local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
    if mason_registry_ok then
      if not mason_registry.is_installed("jdtls") then
        vim.notify("Installing JDTLS with Mason...", vim.log.levels.INFO)
        local handle = vim.loop.spawn("mason", {
          args = {"install", "jdtls"},
        }, function(code)
          if code == 0 then
            vim.notify("JDTLS installed successfully. Please restart Neovim.", vim.log.levels.INFO)
          else
            vim.notify("Failed to install JDTLS with Mason.", vim.log.levels.ERROR)
          end
        end)
        if handle then
          vim.loop.close(handle)
        end
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

  -- Project specific data directory
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name

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
      break
    end
  end

  if not jdtls_path then
    vim.notify("JDTLS installation not found. Please install JDTLS with Mason or system package manager.", vim.log.levels.ERROR)
    return
  end

  local config = {
    cmd = {
      java_cmd,
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xms512m',  -- Memory tuning for 32-bit system
      '-Xmx1024m', -- Memory tuning for 32-bit system
      '--add-modules=ALL-SYSTEM',
      '--add-opens', 'java.base/java.util=ALL-UNNAMED',
      '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
      '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', jdtls_path .. '/config_linux',
      '-data', workspace_dir,
    },
    
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
          updateBuildConfiguration = "interactive",
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
    },
    
    on_attach = function(client, bufnr)
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
      vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
      vim.keymap.set("n", "<leader>jp", jdtls.organize_imports, opts)
      vim.keymap.set("n", "<leader>ev", jdtls.extract_variable, opts)
      vim.keymap.set("v", "<leader>ev", function() jdtls.extract_variable(true) end, opts)
      vim.keymap.set("n", "<leader>ec", jdtls.extract_constant, opts)
      vim.keymap.set("v", "<leader>ec", function() jdtls.extract_constant(true) end, opts)
      vim.keymap.set("v", "<leader>em", function() jdtls.extract_method(true) end, opts)
    end,
    
    -- Setup Java test capabilities
    flags = {
      allow_incremental_sync = true,
    },
  }
  
  -- Start JDTLS
  jdtls.start_or_attach(config)
end

return M
