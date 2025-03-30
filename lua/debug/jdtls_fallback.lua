-- Ultra minimal JDTLS fallback setup for fixing error code 13
local M = {}

-- Simple function to find items in a list
local function contains(list, item)
  for _, val in ipairs(list) do
    if val == item then return true end
  end
  return false
end

-- Reset and manually configure all environment variables and directories
function M.hard_reset_and_start()
  -- Stop any running JDTLS instances
  local clients = vim.lsp.get_active_clients({name = "jdtls"})
  for _, client in ipairs(clients) do
    client.stop()
    print("Stopped existing JDTLS client")
  end

  -- Create cache directory with maximum permissions
  local cache_dir = vim.fn.expand('~/.cache/jdtls_reset')
  vim.fn.system("rm -rf " .. vim.fn.shellescape(cache_dir))
  vim.fn.mkdir(cache_dir, 'p', 0777)
  vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(cache_dir))
  print("Created fresh cache directory: " .. cache_dir)

  -- Create workspace directory with maximum permissions
  local workspace_dir = cache_dir .. "/workspace"
  vim.fn.mkdir(workspace_dir, 'p', 0777)
  vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(workspace_dir))
  print("Created fresh workspace directory: " .. workspace_dir)

  -- Create temp directory with maximum permissions
  local temp_dir = cache_dir .. "/temp"
  vim.fn.mkdir(temp_dir, 'p', 0777)
  vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(temp_dir))
  print("Created fresh temp directory: " .. temp_dir)

  -- Set critical environment variables
  vim.env.TEMP = temp_dir
  vim.env.TMP = temp_dir
  vim.env.TMPDIR = temp_dir
  vim.env.XDG_CACHE_HOME = cache_dir
  vim.env.JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=" .. temp_dir

  -- Find Java executable, favoring JDK 17
  local java_cmd = nil
  local java_home = nil
  local possible_java_paths = {
    '/usr/lib/jvm/java-17-openjdk/bin/java',
    '/usr/lib/jvm/java-17-openjdk-amd64/bin/java',
    '/usr/lib/jvm/java-17/bin/java',
    '/usr/lib/jvm/java-17-oracle/bin/java',
    '/usr/lib/jvm/jdk-17/bin/java',
    vim.fn.exepath('java')
  }

  for _, path in ipairs(possible_java_paths) do
    if vim.fn.executable(path) == 1 then
      java_cmd = path
      java_home = vim.fn.fnamemodify(path, ":h:h")
      break
    end
  end

  if not java_cmd then
    print("No Java runtime found! Please install JDK 17")
    return false
  end

  print("Using Java: " .. java_cmd)
  vim.env.JAVA_HOME = java_home
  print("Set JAVA_HOME to: " .. java_home)

  -- Find JDTLS path
  local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
  local jdtls_path = nil
  
  if mason_registry_ok and mason_registry.is_installed("jdtls") then
    jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
    print("Found JDTLS in Mason: " .. jdtls_path)
  else
    -- Try common system paths
    local system_paths = {
      "/usr/share/java/jdtls",
      "/opt/jdtls",
      vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")
    }
    
    for _, path in ipairs(system_paths) do
      if vim.fn.isdirectory(path) == 1 then
        jdtls_path = path
        break
      end
    end
  end

  if not jdtls_path then
    print("JDTLS installation not found!")
    return false
  end

  -- Find launcher jar
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher_jar == "" then
    print("JDTLS launcher jar not found!")
    return false
  end

  -- Create configuration folder with proper permissions
  local config_dir = jdtls_path .. "/config_linux"
  if vim.fn.isdirectory(config_dir) == 1 then
    vim.fn.system("chmod -R 755 " .. vim.fn.shellescape(config_dir))
    print("Fixed permissions for config directory: " .. config_dir)
  else
    print("Config directory not found: " .. config_dir)
    return false
  end

  -- Check for the jdtls module
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    print("JDTLS Neovim plugin not found! Please install nvim-jdtls")
    return false
  end

  -- Create absolute minimal config with no extras
  local config = {
    cmd = {
      java_cmd,
      '-Djava.io.tmpdir=' .. temp_dir,
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Xms256m',
      '-Xmx512m',
      '-jar', launcher_jar,
      '-configuration', config_dir,
      '-data', workspace_dir,
    },
    -- Use minimal root directory handling
    root_dir = vim.fn.getcwd(),
    -- Disable all settings to keep it minimal
    settings = {},
    init_options = {},
    -- Allow only essential flags
    flags = {
      allow_incremental_sync = false,
      server_side_fuzzy_completion = false,
      debounce_text_changes = 500,
    },
    -- Minimal on_attach
    on_attach = function(client, bufnr)
      print("JDTLS attached to buffer " .. bufnr)
      
      -- Set up minimal keymaps
      local opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end
  }

  -- Add a log file
  local log_file = cache_dir .. "/jdt.log"
  local log_level = "WARNING" -- Keep logging minimal to avoid permissions issues
  
  -- Add logging options to cmd
  table.insert(config.cmd, 2, "-Dlog.level=" .. log_level)
  table.insert(config.cmd, 2, "-Dlog.file=" .. log_file)
  
  -- Start JDTLS with clear error handling
  print("Starting JDTLS with minimal config...")
  
  local start_ok, err = pcall(jdtls.start_or_attach, config)
  if not start_ok then
    print("Error starting JDTLS: " .. tostring(err))
    print("Try running the external script with: ':JdtlsExternal'")
    return false
  end
  
  print("JDTLS started successfully")
  return true
end

-- Create launcher script
function M.create_external_script()
  local script_path = vim.fn.expand("~/launch_jdtls.sh")
  local script = io.open(script_path, "w")
  if not script then
    print("Failed to create external script")
    return
  end
  
  -- Find JDTLS path
  local jdtls_path = ""
  local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
  if mason_registry_ok and mason_registry.is_installed("jdtls") then
    jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
  else
    jdtls_path = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")
  end

  -- Write shell script content
  script:write("#!/bin/bash\n\n")
  script:write("# External JDTLS launcher script to bypass permission issues\n\n")
  script:write("# Create fresh directories\n")
  script:write("mkdir -p ~/.cache/jdtls_ext/workspace ~/.cache/jdtls_ext/temp\n")
  script:write("chmod -R 777 ~/.cache/jdtls_ext\n\n")
  script:write("# Set environment variables\n")
  script:write("export TEMP=~/.cache/jdtls_ext/temp\n")
  script:write("export TMP=~/.cache/jdtls_ext/temp\n")
  script:write("export TMPDIR=~/.cache/jdtls_ext/temp\n")
  script:write("export JAVA_TOOL_OPTIONS=\"-Djava.io.tmpdir=~/.cache/jdtls_ext/temp\"\n\n")
  script:write("# Find Java\n")
  script:write("JAVA_CMD=$(which java)\n")
  script:write("if [ -z \"$JAVA_CMD\" ]; then\n")
  script:write("  echo \"Java not found in PATH\"\n")
  script:write("  exit 1\n")
  script:write("fi\n\n")
  script:write("# Start JDTLS\n")
  script:write("echo \"Starting JDTLS...\"\n")
  script:write("$JAVA_CMD \\\n")
  script:write("  -Djava.io.tmpdir=~/.cache/jdtls_ext/temp \\\n")
  script:write("  -Declipse.application=org.eclipse.jdt.ls.core.id1 \\\n")
  script:write("  -Dosgi.bundles.defaultStartLevel=4 \\\n")
  script:write("  -Declipse.product=org.eclipse.jdt.ls.core.product \\\n")
  script:write("  -Xms256m \\\n")
  script:write("  -Xmx512m \\\n")
  script:write("  -jar " .. jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar \\\n")
  script:write("  -configuration " .. jdtls_path .. "/config_linux \\\n")
  script:write("  -data ~/.cache/jdtls_ext/workspace &\n\n")
  script:write("echo \"JDTLS started in background\"\n")
  
  script:close()
  
  -- Make the script executable
  vim.fn.system("chmod +x " .. vim.fn.shellescape(script_path))
  
  print("External script created at: " .. script_path)
  print("Run it with: bash " .. script_path)
end

-- Register user commands
function M.setup()
  vim.api.nvim_create_user_command("JdtlsFallback", function()
    M.hard_reset_and_start()
  end, {})
  
  vim.api.nvim_create_user_command("JdtlsExternal", function()
    M.create_external_script()
  end, {})
  
  -- Register key mapping
  vim.keymap.set("n", "<leader>jf", M.hard_reset_and_start, 
    { noremap = true, desc = "JDTLS fallback mode" })
end

-- Initialize
M.setup()

return M
