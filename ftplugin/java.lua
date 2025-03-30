-- Ultra simple JDTLS setup with fallback mechanism

-- Try to load the jdtls module
local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify("[JDTLS] Module not found. Install with :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

-- Find project root
local root_dir = vim.fn.getcwd()

-- Project name for workspace folder - use simpler logic
local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/" .. project_name)

-- Find Java command
local java_cmd = vim.fn.exepath('java')
if not java_cmd or java_cmd == "" then
  vim.notify("[JDTLS] Java executable not found in PATH", vim.log.levels.ERROR)
  return
end

-- Find JDTLS installation
local jdtls_path = nil

-- Try Mason first
local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
if mason_registry_ok and mason_registry.is_installed('jdtls') then
  jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
else
  -- Try common system paths
  local possible_paths = {
    '/usr/share/java/jdtls',
    '/opt/jdtls',
    vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls')
  }
  
  for _, path in ipairs(possible_paths) do
    if vim.fn.isdirectory(path) == 1 then
      jdtls_path = path
      break
    end
  end
end

if not jdtls_path then
  vim.notify("[JDTLS] Installation not found", vim.log.levels.ERROR)
  return
end

-- Try 3 different approaches, if one fails try the next one
local function try_start_jdtls()
  vim.notify("[JDTLS] Attempting to start server with approach 1...", vim.log.levels.INFO)
  
  -- Approach 1: Standard configuration with environment variable
  local attempt_1 = function()
    -- Ensure directories exist
    vim.fn.mkdir(workspace_dir, 'p')
    
    local config = {
      cmd = {
        java_cmd,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Xmx512m',
        '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', jdtls_path .. '/config_linux',
        '-data', workspace_dir,
      },
      root_dir = root_dir
    }
    
    return jdtls.start_or_attach(config)
  end
  
  -- Approach 2: Try with a tmp directory
  local attempt_2 = function()
    vim.notify("[JDTLS] First attempt failed, trying approach 2...", vim.log.levels.WARN)
    
    -- Create temporary directory with full permissions
    local temp_dir = vim.fn.expand('/tmp/jdtls_tmp_' .. os.time())
    vim.fn.mkdir(temp_dir, 'p')
    
    local config = {
      cmd = {
        java_cmd,
        '-Djava.io.tmpdir=' .. temp_dir,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Xmx512m',
        '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', jdtls_path .. '/config_linux',
        '-data', temp_dir .. '/workspace',
      },
      root_dir = root_dir
    }
    
    return jdtls.start_or_attach(config)
  end
  
  -- Approach 3: Ultra minimal configuration
  local attempt_3 = function()
    vim.notify("[JDTLS] Second attempt failed, trying approach 3...", vim.log.levels.WARN)
    
    -- Create a unique temporary directory directly in /tmp
    local temp_dir = '/tmp/jdtls_' .. os.time()
    vim.fn.mkdir(temp_dir, 'p')
    vim.fn.system('chmod 777 ' .. vim.fn.shellescape(temp_dir))
    
    -- Set environment variables
    vim.env.TEMP = temp_dir
    vim.env.TMP = temp_dir
    vim.env.TMPDIR = temp_dir
    
    local config = {
      cmd = {
        java_cmd,
        '-Djava.io.tmpdir=' .. temp_dir,
        '-XX:+UseParallelGC',
        '-XX:GCTimeRatio=4',
        '-XX:AdaptiveSizePolicyWeight=90',
        '-Dsun.zip.disableMemoryMapping=true',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms100m',
        '-Xmx512m',
        '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', jdtls_path .. '/config_linux',
        '-data', temp_dir,
      },
      root_dir = root_dir,
      settings = {},
      init_options = {},
    }
    
    return jdtls.start_or_attach(config)
  end
  
  -- Try each approach in sequence, if one fails try the next
  local ok, err = pcall(attempt_1)
  if not ok then
    ok, err = pcall(attempt_2)
    if not ok then
      ok, err = pcall(attempt_3)
      if not ok then
        vim.notify("[JDTLS] All attempts failed. Last error: " .. tostring(err), vim.log.levels.ERROR)
        vim.notify("[JDTLS] Try running the debug script: bash ~/nvim/debug_jdtls.sh", vim.log.levels.INFO)
        return false
      end
    end
  end
  
  return true
end

-- Start the server with our multi-attempt approach
if try_start_jdtls() then
  vim.notify("[JDTLS] Server started successfully", vim.log.levels.INFO)
  
  -- Add commands for easier management
  vim.api.nvim_create_user_command('JdtRestart', function()
    -- Stop existing clients
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.name == "jdtls" then
        client.stop()
      end
    end
    
    -- Try starting again
    try_start_jdtls()
  end, {})
end
