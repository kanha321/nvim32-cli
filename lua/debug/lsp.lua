-- LSP Debugging Utilities
local M = {}

-- Collect comprehensive LSP setup information
function M.collect_info()
  local info = {
    active_clients = vim.lsp.get_active_clients(),
    neovim_version = vim.version(),
    log_path = vim.lsp.get_log_path(),
    log_level = vim.lsp.get_log_level(),
    current_filetype = vim.bo.filetype,
    mason_packages = {},
  }
  
  -- Check Mason packages
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if mason_ok then
    local installed = mason_registry.get_installed_packages()
    for _, pkg in ipairs(installed) do
      table.insert(info.mason_packages, {
        name = pkg.name,
        path = pkg:get_install_path()
      })
    end
  end
  
  -- Check JDTLS specific info
  info.jdtls = {
    loaded = package.loaded["jdtls"] ~= nil,
    java_path = vim.fn.executable('/usr/lib/jvm/java-17-openjdk/bin/java') == 1
  }

  -- Get all active buffer filetypes
  info.buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      table.insert(info.buffers, {
        bufnr = bufnr,
        filetype = ft,
        name = vim.api.nvim_buf_get_name(bufnr)
      })
    end
  end

  return info
end

-- Print info in human-readable format
function M.print_diagnostics()
  local info = M.collect_info()
  
  print("=== LSP DIAGNOSTICS ===")
  print("\nNeovim: " .. vim.inspect(info.neovim_version))
  print("\nLSP Log Path: " .. info.log_path)
  print("LSP Log Level: " .. info.log_level)
  print("\nActive Clients (" .. #info.active_clients .. "):")
  
  for i, client in ipairs(info.active_clients) do
    print(string.format("%d. %s (id: %d)", i, client.name, client.id))
    local buffers = vim.lsp.get_buffers_by_client_id(client.id)
    if buffers and #buffers > 0 then
      print("   Attached to buffers: " .. table.concat(buffers, ", "))
    else
      print("   Not attached to any buffers")
    end
  end
  
  print("\nMason Packages (" .. #info.mason_packages .. "):")
  for _, pkg in ipairs(info.mason_packages) do
    print("- " .. pkg.name .. " (" .. pkg.path .. ")")
  end
  
  print("\nJDTLS Status:")
  print("- Module loaded: " .. tostring(info.jdtls.loaded))
  print("- Java 17 available: " .. tostring(info.jdtls.java_path))
  
  print("\nBuffers:")
  for _, buf in ipairs(info.buffers) do
    print(string.format("- [%d] %s (ft: %s)", buf.bufnr, vim.fn.fnamemodify(buf.name, ":t"), buf.filetype))
  end
  
  print("\nLSP Handlers:")
  local handlers = vim.tbl_keys(vim.lsp.handlers)
  for _, h in ipairs(handlers) do
    print("- " .. h)
  end

  print("\n=== END DIAGNOSTICS ===")
end

-- Create an LSP start helper
function M.force_start_lsp(filetype)
  filetype = filetype or vim.bo.filetype
  if filetype == "" then
    print("No filetype detected")
    return
  end
  
  print("Attempting to start LSP for filetype: " .. filetype)
  
  -- Special case for java
  if filetype == "java" then
    local jdtls_ok, _ = pcall(require, "jdtls")
    if jdtls_ok then
      -- Try each possible JDTLS setup path
      local ok, result
      
      -- Option 1: plugins.lsp.jdtls
      ok, result = pcall(function()
        require("plugins.lsp.jdtls").setup()
        return true
      end)
      if ok and result then
        print("Started JDTLS using plugins.lsp.jdtls")
        return
      end
      
      -- Option 2: plugins.configs.jdtls
      ok, result = pcall(function()
        require("plugins.configs.jdtls").setup()
        return true
      end)
      if ok and result then
        print("Started JDTLS using plugins.configs.jdtls")
        return
      end
      
      -- Option 3: lsp.java
      ok, result = pcall(function()
        require("lsp.java")
        print("Loaded lsp.java")
        return true
      end)
      if ok and result then
        print("Started JDTLS using lsp.java")
        return
      end
      
      print("Failed to start JDTLS from any configuration")
    else
      print("JDTLS module not found")
    end
    return
  end
  
  -- Regular LSP servers
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if lspconfig_ok then
    local server_mapping = {
      lua = "lua_ls",
      typescript = "tsserver",
      javascript = "tsserver",
      c = "clangd",
      cpp = "clangd",
      kotlin = "kotlin_language_server"
    }
    
    local server_name = server_mapping[filetype] or filetype
    local config_ok, _ = pcall(function()
      lspconfig[server_name].setup({})
      vim.cmd("LspStart " .. server_name)
      return true
    end)
    
    if config_ok then
      print("Started " .. server_name .. " for " .. filetype)
    else
      print("Failed to start LSP server for " .. filetype)
    end
  else
    print("LSP config not available")
  end
end

return M
