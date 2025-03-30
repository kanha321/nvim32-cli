-- JDTLS setup implementation
local M = {}

-- Helper function to notify errors properly
local function notify_error(msg, detailed)
  vim.notify(msg, vim.log.levels.ERROR)
  if detailed then
    print(detailed)
  end
end

-- Get appropriate path for data directory
local function get_workspace_dir()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/" .. project_name)
  
  -- Create directory if it doesn't exist
  if vim.fn.isdirectory(workspace_dir) == 0 then
    vim.fn.mkdir(workspace_dir, "p")
  end
  
  return workspace_dir
end

-- Helper function to find Java command
local function find_java_cmd()
  local candidates = {
    "/usr/lib/jvm/java-17-openjdk/bin/java",
    "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
    "/usr/lib/jvm/java-17/bin/java",
    vim.fn.exepath("java"),
  }
  
  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  
  return nil
end

-- Helper function to find JDTLS installation
local function find_jdtls_path()
  local candidates = {}
  
  -- Try Mason first
  local mason_path
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if mason_ok and mason_registry.is_installed("jdtls") then
    mason_path = mason_registry.get_package("jdtls"):get_install_path()
    table.insert(candidates, mason_path)
  end
  
  -- Try common system paths
  table.insert(candidates, "/usr/share/java/jdtls")
  table.insert(candidates, "/opt/jdtls")
  table.insert(candidates, vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls"))
  
  for _, path in ipairs(candidates) do
    local launcher_jar = vim.fn.glob(path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    if launcher_jar ~= "" then
      return path
    end
  end
  
  return nil
end

function M.setup()
  -- Check if JDTLS is available
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    notify_error("JDTLS is not available. Please install it first.")
    return
  end
  
  -- Find Java runtime
  local java_cmd = find_java_cmd()
  if not java_cmd then
    notify_error("Could not find Java 17. Please install it.")
    return
  end
  
  -- Find JDTLS installation
  local jdtls_path = find_jdtls_path()
  if not jdtls_path then
    notify_error("Could not find JDTLS installation. Please install JDTLS.")
    return
  end
  
  -- Project root finding
  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  local root_dir = require('jdtls.setup').find_root(root_markers)
  if not root_dir then
    -- If no root marker found, use current directory
    root_dir = vim.fn.getcwd()
  end
  
  -- Get workspace directory
  local workspace_dir = get_workspace_dir()
  
  -- Basic configuration
  local config = {
    cmd = {
      java_cmd,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Xms512m",
      "-Xmx1024m",
      "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
      "-configuration", jdtls_path .. "/config_linux",
      "-data", workspace_dir,
    },
    root_dir = root_dir,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*",
            "sun.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        configuration = {
          -- Configure Java runtimes
          runtimes = {
            {
              name = "JavaSE-17",
              path = java_cmd:gsub("/bin/java$", ""),
              default = true,
            },
          }
        }
      }
    },
    on_attach = function(client, bufnr)
      -- Set up standard LSP keybindings
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
      
      -- Java specific actions (using <leader>j prefix to avoid conflicts)
      vim.keymap.set("n", "<leader>ji", function() jdtls.organize_imports() end, opts)
      vim.keymap.set("n", "<leader>jv", function() jdtls.extract_variable() end, opts)
      vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, opts)
      vim.keymap.set("n", "<leader>jc", function() jdtls.extract_constant() end, opts)
      vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, opts)
      vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, opts)
      
      -- Alt keymaps for IntelliJ users
      vim.keymap.set("n", "<A-o>", function() jdtls.organize_imports() end, opts)
    end,
    flags = {
      allow_incremental_sync = true,
      server_side_fuzzy_completion = true,
    },
  }
  
  -- Start or attach to JDTLS
  local status_ok, error_msg = pcall(function()
    jdtls.start_or_attach(config)
  end)
  
  if not status_ok then
    notify_error("Error starting JDTLS", error_msg)
  else
    vim.notify("JDTLS started for Java project: " .. vim.fn.fnamemodify(root_dir, ":t"), vim.log.levels.INFO)
  end
end

-- Command to restart JDTLS
vim.api.nvim_create_user_command('JavaRestart', function()
  -- Stop all current clients
  local clients = vim.lsp.get_active_clients({ name = "jdtls" })
  for _, client in ipairs(clients) do
    client.stop()
  end
  
  -- Restart JDTLS
  vim.defer_fn(function()
    M.setup()
  end, 500) -- Small delay to ensure cleanup
end, {})

-- Command to clean workspace and restart
vim.api.nvim_create_user_command('JavaClean', function()
  -- Stop all current clients
  local clients = vim.lsp.get_active_clients({ name = "jdtls" })
  for _, client in ipairs(clients) do
    client.stop()
  end
  
  -- Clean workspace
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/" .. project_name)
  if vim.fn.isdirectory(workspace_dir) == 1 then
    vim.fn.system("rm -rf " .. vim.fn.shellescape(workspace_dir))
    vim.fn.mkdir(workspace_dir, "p")
  end
  
  -- Restart JDTLS
  vim.defer_fn(function()
    M.setup()
  end, 500) -- Small delay to ensure cleanup
end, {})

return M
