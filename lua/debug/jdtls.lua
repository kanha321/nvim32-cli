-- JDTLS Debug Utilities
local M = {}

-- Function to diagnose JDTLS issues
function M.diagnose()
  local info = {
    java_version = nil,
    jdtls_location = nil,
    workspace_dir = nil,
    stderr_log = nil,
    config_dir = nil,
    project_root = nil,
    maven_settings = nil,
    gradle_settings = nil,
  }
  
  -- Check Java version
  local java_cmd = io.popen("java -version 2>&1")
  if java_cmd then
    info.java_version = java_cmd:read("*all")
    java_cmd:close()
  end
  
  -- Check JDTLS location from Mason
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if mason_ok then
    if mason_registry.is_installed("jdtls") then
      info.jdtls_location = mason_registry.get_package("jdtls"):get_install_path()
      
      -- Check config directory
      local config_dir = info.jdtls_location .. "/config_linux"
      if vim.fn.isdirectory(config_dir) == 1 then
        info.config_dir = config_dir
        
        -- Check config files
        local config_files = vim.fn.glob(config_dir .. "/*.ini", false, true)
        info.config_files = config_files
      end
    end
  end
  
  -- Get JDTLS workspace
  local cache_dir = vim.fn.expand("~/.cache/jdtls")
  if vim.fn.isdirectory(cache_dir) == 1 then
    info.workspace_dir = cache_dir
    
    -- Check for stderr log
    local stderr_path = cache_dir .. "/jdtls_stderr.log"
    if vim.fn.filereadable(stderr_path) == 1 then
      local stderr_file = io.open(stderr_path, "r")
      if stderr_file then
        info.stderr_log = stderr_file:read("*all")
        stderr_file:close()
      end
    end
  end
  
  -- Check project structure
  local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
  local jdtls_setup_ok, jdtls_setup = pcall(require, 'jdtls.setup')
  if jdtls_setup_ok then
    info.project_root = jdtls_setup.find_root(root_markers) or vim.fn.getcwd()
    
    -- Check for Maven settings
    if vim.fn.filereadable(info.project_root .. "/pom.xml") == 1 then
      info.maven_settings = "pom.xml found"
      
      -- Check Maven wrapper
      if vim.fn.filereadable(info.project_root .. "/mvnw") == 1 then
        info.maven_settings = info.maven_settings .. " (with wrapper)"
      end
    end
    
    -- Check for Gradle settings
    if vim.fn.filereadable(info.project_root .. "/build.gradle") == 1 then
      info.gradle_settings = "build.gradle found"
      
      -- Check Gradle wrapper
      if vim.fn.filereadable(info.project_root .. "/gradlew") == 1 then
        info.gradle_settings = info.gradle_settings .. " (with wrapper)"
      end
    end
  end
  
  return info
end

-- Print diagnostic information
function M.print_diagnostics()
  local info = M.diagnose()
  
  print("\n=== JDTLS DIAGNOSTICS ===")
  
  print("\nJava Version:")
  print(info.java_version or "Not found")
  
  print("\nJDTLS Location:")
  print(info.jdtls_location or "Not found")
  
  if info.config_dir then
    print("\nConfig Directory:")
    print(info.config_dir)
    
    if info.config_files and #info.config_files > 0 then
      print("\nConfig Files:")
      for _, file in ipairs(info.config_files) do
        print("- " .. vim.fn.fnamemodify(file, ":t"))
      end
    end
  end
  
  print("\nWorkspace Directory:")
  print(info.workspace_dir or "Not found")
  
  print("\nProject Root:")
  print(info.project_root or "Not found")
  
  if info.maven_settings then
    print("\nMaven Configuration:")
    print(info.maven_settings)
  end
  
  if info.gradle_settings then
    print("\nGradle Configuration:")
    print(info.gradle_settings)
  end
  
  if info.stderr_log and #info.stderr_log > 0 then
    print("\nJDTLS Error Log:")
    print(info.stderr_log)
  else
    print("\nNo JDTLS errors found in log")
  end
  
  print("\n=== END JDTLS DIAGNOSTICS ===")
end

-- Function to restart JDTLS with increased verbosity
function M.restart_with_debug()
  -- First, stop any running instances
  local clients = vim.lsp.get_active_clients({name = "jdtls"})
  for _, client in ipairs(clients) do
    client.stop()
  end
  
  -- Create debug directory
  vim.fn.mkdir(vim.fn.expand("~/.cache/jdtls/debug"), "p")
  
  -- Set debugging environment variables
  vim.env.JDTLS_DEBUG = "true"
  vim.env.JDTLS_LOG_FILE = vim.fn.expand("~/.cache/jdtls/debug/jdtls.log")
  vim.env.JDTLS_LOG_LEVEL = "ALL"
  
  -- Try to start JDTLS with plugins.lsp.jdtls
  local ok, _ = pcall(require, "plugins.lsp.jdtls")
  if ok then
    vim.notify("Restarting JDTLS with debug mode", vim.log.levels.INFO)
    require("plugins.lsp.jdtls").setup()
  else
    -- Try alternative methods
    pcall(function()
      require("plugins.configs.jdtls").setup()
    end)
  end
end

-- Enhanced function to fix permissions for JDTLS directories
function M.fix_permissions()
  local home_dir = vim.loop.os_homedir()
  local cache_dir = home_dir .. "/.cache/jdtls"
  local mason_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  local temp_dir = "/tmp/jdtls_temp"
  
  print("Starting comprehensive permission fix...")
  
  -- Ensure temp directory exists with proper permissions
  vim.fn.mkdir(temp_dir, 'p', 0777)
  vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(temp_dir))
  print("Created temp directory with full permissions: " .. temp_dir)
  
  -- Set environment variables to use this temp directory
  vim.env.TEMP = temp_dir
  vim.env.TMP = temp_dir
  vim.env.TMPDIR = temp_dir
  
  -- Create necessary directories with very permissive settings
  vim.fn.mkdir(cache_dir, 'p', 0777)
  vim.fn.mkdir(cache_dir .. "/workspace", 'p', 0777)
  vim.fn.mkdir(cache_dir .. "/temp", 'p', 0777)
  
  -- Fix permissions on cache directory with maximum permissions first
  local fix_cmd = "chmod -R 777 " .. vim.fn.shellescape(cache_dir)
  vim.fn.system(fix_cmd)
  print("Set initial permissions to 777 for JDTLS cache directory: " .. cache_dir)
  
  -- Try to fix Mason package permissions if it exists
  if vim.fn.isdirectory(mason_dir) == 1 then
    local mason_fix_cmd = "chmod -R 755 " .. vim.fn.shellescape(mason_dir)
    vim.fn.system(mason_fix_cmd)
    print("Fixed permissions for Mason JDTLS directory: " .. mason_dir)
    
    -- Make scripts executable
    local scripts_fix_cmd = "find " .. vim.fn.shellescape(mason_dir) .. " -name '*.sh' -exec chmod +x {} \\;"
    vim.fn.system(scripts_fix_cmd)
    
    -- Make jar files readable
    local jar_fix_cmd = "find " .. vim.fn.shellescape(mason_dir) .. " -name '*.jar' -exec chmod 644 {} \\;"
    vim.fn.system(jar_fix_cmd)
  end
  
  -- Create and fix stderr log file permissions
  local stderr_path = cache_dir .. "/jdtls_stderr.log"
  local stderr_file = io.open(stderr_path, "w")
  if stderr_file then
    stderr_file:write("Log file created " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    stderr_file:close()
    vim.fn.system("chmod 666 " .. vim.fn.shellescape(stderr_path))
    print("Created and fixed permissions for stderr log: " .. stderr_path)
  end
  
  -- Fix Java temporary directory permissions
  local home_tmp = home_dir .. "/.cache/tmp"
  vim.fn.mkdir(home_tmp, 'p', 0777)
  vim.fn.system("chmod -R 777 " .. vim.fn.shellescape(home_tmp))
  vim.env.JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=" .. home_tmp
  print("Set Java temp directory with full permissions: " .. home_tmp)
  
  print("Permission fixing completed")
  
  -- Return the home directory temporary path for use in configuration
  return home_tmp
end

-- Clean workspace to reset JDTLS state
function M.clean_workspace()
  local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
  local jdtls_setup_ok, jdtls_setup = pcall(require, 'jdtls.setup')
  
  if not jdtls_setup_ok then
    print("JDTLS setup module not available")
    return
  end
  
  local root_dir = jdtls_setup.find_root(root_markers) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
  
  local rm_cmd = "rm -rf " .. vim.fn.shellescape(workspace_dir)
  vim.fn.system(rm_cmd)
  vim.fn.mkdir(workspace_dir, 'p', 0700)
  
  print("Cleaned workspace for project: " .. project_name)
  print("New workspace directory: " .. workspace_dir)
end

-- Extremely simplified JDTLS starter without extra options
function M.restart_minimal()
  -- Stop any running JDTLS instances
  local clients = vim.lsp.get_active_clients({name = "jdtls"})
  for _, client in ipairs(clients) do
    client.stop()
    print("Stopped existing JDTLS client")
  end
  
  -- Fix permissions aggressively
  local tmp_dir = M.fix_permissions()
  
  -- Clean workspace
  M.clean_workspace()
  
  -- Create new config with absolute minimal options
  local root_dir = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
  
  -- Find Java executable
  local java_cmd = vim.fn.exepath('java')
  if not java_cmd or java_cmd == "" then
    print("Java not found in PATH!")
    return
  end
  
  -- Find JDTLS installation
  local jdtls_path
  local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
  if mason_registry_ok and mason_registry.is_installed('jdtls') then
    jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
  else
    for _, path in ipairs({'/usr/share/java/jdtls', '/opt/jdtls'}) do
      if vim.fn.isdirectory(path) == 1 then
        jdtls_path = path
        break
      end
    end
  end
  
  if not jdtls_path then
    print("JDTLS installation not found!")
    return
  end
  
  -- Create absolute minimal config
  local config = {
    cmd = {
      java_cmd,
      '-Djava.io.tmpdir=' .. tmp_dir,
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Xms256m',
      '-Xmx1024m',
      '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', jdtls_path .. '/config_linux',
      '-data', workspace_dir,
    },
    root_dir = root_dir,
    settings = {},
    init_options = {},
    flags = {
      allow_incremental_sync = true,
    },
  }
  
  -- Start JDTLS with absolute minimum configuration
  print("Starting JDTLS with minimal config...")
  local jdtls_ok, jdtls = pcall(require, 'jdtls')
  if jdtls_ok then
    jdtls.start_or_attach(config)
    print("JDTLS started with minimal config")
  else
    print("Failed to load JDTLS module")
  end
end

-- Fix permissions and restart JDTLS with simplified options
function M.restart_simplified()
  -- Stop any running JDTLS instances
  local clients = vim.lsp.get_active_clients({name = "jdtls"})
  for _, client in ipairs(clients) do
    client.stop()
  end
  
  -- Fix permissions
  M.fix_permissions()
  
  -- Clean workspace
  M.clean_workspace()
  
  -- Get current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  local fname = vim.api.nvim_buf_get_name(bufnr)
  
  -- Create new config with minimal options
  local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
  local jdtls_setup = require('jdtls.setup')
  local root_dir = jdtls_setup.find_root(root_markers) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
  
  -- Find Java executable
  local java_cmd = vim.fn.exepath('java')
  
  -- Find JDTLS installation
  local jdtls_path
  local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
  if mason_registry_ok and mason_registry.is_installed('jdtls') then
    jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
  else
    jdtls_path = '/usr/share/java/jdtls'
  end
  
  -- Create simplified config
  local config = {
    cmd = {
      java_cmd,
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Xms512m',
      '-Xmx1024m',
      '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', jdtls_path .. '/config_linux',
      '-data', workspace_dir,
    },
    root_dir = root_dir,
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = "JavaSE-17",
              path = java_cmd:gsub('/bin/java', ''),
              default = true,
            },
          },
        },
      },
    },
  }
  
  -- Start JDTLS
  print("Starting JDTLS with simplified config...")
  local jdtls = require('jdtls')
  jdtls.start_or_attach(config)
  print("JDTLS started")
end

-- Create user commands for easy access
function M.setup_commands()
  vim.api.nvim_create_user_command('JdtlsDiagnose', function()
    M.print_diagnostics()
  end, {})
  
  vim.api.nvim_create_user_command('JdtlsDebug', function()
    M.restart_with_debug()
  end, {})
  
  vim.api.nvim_create_user_command('JdtlsFixPermissions', function()
    M.fix_permissions()
  end, {})
  
  vim.api.nvim_create_user_command('JdtlsCleanWorkspace', function()
    M.clean_workspace()
  end, {})
  
  vim.api.nvim_create_user_command('JdtlsSimplified', function()
    M.restart_simplified()
  end, {})
  
  vim.api.nvim_create_user_command('JdtlsMinimal', function()
    M.restart_minimal()
  end, {})
  
  -- Add keymaps
  local keymap = vim.keymap.set
  keymap("n", "<leader>jd", M.print_diagnostics, { noremap = true, desc = "JDTLS diagnostics" })
  keymap("n", "<leader>jr", M.restart_with_debug, { noremap = true, desc = "JDTLS restart with debug" })
  keymap("n", "<leader>jp", M.fix_permissions, { noremap = true, desc = "JDTLS fix permissions" })
  keymap("n", "<leader>js", M.restart_simplified, { noremap = true, desc = "JDTLS restart simplified" })
  keymap("n", "<leader>jm", M.restart_minimal, { noremap = true, desc = "JDTLS minimal restart" })
end

-- Initialize the module
M.setup_commands()

return M
