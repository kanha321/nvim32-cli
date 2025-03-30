-- JDTLS Verification Utility
local M = {}

-- Function to check if JDTLS is working properly
function M.verify()
  local report = {
    clients = {},
    java_version = nil,
    mason_status = nil,
    test_results = {},
    active_buffers = {},
    autocommands = {},
    environment = {},
  }
  
  print("\n=== JDTLS VERIFICATION ===")
  
  -- 1. Check if JDTLS is loaded
  local jdtls_loaded = package.loaded["jdtls"] ~= nil
  print("JDTLS module loaded: " .. tostring(jdtls_loaded))
  if not jdtls_loaded then
    print("❌ JDTLS module is not loaded - this is a critical issue")
    print("Try running: :Mason and install jdtls")
    return false
  end
  
  -- 2. Check active clients
  local clients = vim.lsp.get_active_clients()
  local jdtls_client = nil
  for _, client in ipairs(clients) do
    if client.name == "jdtls" then
      jdtls_client = client
      print("✓ JDTLS client is active (id: " .. client.id .. ")")
      
      -- Check which buffers this client is attached to
      local buffers = vim.lsp.get_buffers_by_client_id(client.id)
      if #buffers > 0 then
        print("✓ JDTLS attached to " .. #buffers .. " buffer(s): " .. table.concat(buffers, ", "))
        for _, bufnr in ipairs(buffers) do
          local file_path = vim.api.nvim_buf_get_name(bufnr)
          table.insert(report.active_buffers, {
            buffer = bufnr,
            path = file_path,
            filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
          })
        end
      else
        print("❌ JDTLS is not attached to any buffers")
      end
      break
    end
  end
  
  if not jdtls_client then
    print("❌ No active JDTLS client found")
    print("Try running: :StartJdtls or <leader>jm to start minimal JDTLS")
  end
  
  -- 3. Test basic JDTLS functionality on current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(current_buf, "filetype")
  
  if ft == "java" then
    print("\n--- Testing JDTLS on current Java buffer ---")
    
    -- Try hover
    local hover_ok = pcall(vim.lsp.buf.hover)
    print("Hover request: " .. (hover_ok and "✓" or "❌"))
    table.insert(report.test_results, {name = "hover", success = hover_ok})
    
    -- Validate completions (check if omnifunc is set)
    local omnifunc = vim.api.nvim_buf_get_option(current_buf, "omnifunc")
    local completion_ok = omnifunc ~= ""
    print("Completion ready: " .. (completion_ok and "✓" or "❌"))
    table.insert(report.test_results, {name = "completion", success = completion_ok})
    
    -- Check if diagnostic capability is working
    local diagnostics = vim.diagnostic.get(current_buf)
    print("Diagnostics available: " .. (diagnostics and #diagnostics > 0 and "✓" or "⚠️"))
    table.insert(report.test_results, {name = "diagnostics", success = diagnostics ~= nil})
    
    -- Check JDTLS specific features
    local jdtls_ok, jdtls = pcall(require, "jdtls")
    if jdtls_ok and jdtls_client then
      -- Check if organize imports works
      local organize_ok = pcall(jdtls.organize_imports)
      print("Organize imports: " .. (organize_ok and "✓" or "❌"))
      table.insert(report.test_results, {name = "organize_imports", success = organize_ok})
    end
  else
    print("\n⚠️ Current buffer is not Java (filetype: " .. ft .. ")")
    print("Please open a Java file to test JDTLS functionality")
  end
  
  -- 4. Check Java version
  local java_cmd = io.popen("java -version 2>&1")
  if java_cmd then
    report.java_version = java_cmd:read("*all")
    java_cmd:close()
    print("\nJava Version: " .. report.java_version:gsub("\n", " "))
  end
  
  -- 5. Check environment variables related to Java and JDTLS
  local env_vars = {"JAVA_HOME", "JDTLS_HOME", "PATH", "TMPDIR", "TEMP", "TMP", "JAVA_TOOL_OPTIONS"}
  print("\nEnvironment Variables:")
  for _, var in ipairs(env_vars) do
    local value = vim.env[var] or "not set"
    report.environment[var] = value
    if var == "JAVA_HOME" or var == "JDTLS_HOME" then
      print(var .. ": " .. value)
    end
  end
  
  print("\n=== JDTLS VERIFICATION COMPLETE ===")
  return jdtls_client ~= nil
end

-- Function to test Java LSP with a simple test file
function M.test_with_file()
  -- Create a temporary Java file
  local temp_dir = vim.fn.expand("~/.cache/nvim")
  vim.fn.mkdir(temp_dir, "p")
  
  local test_file = temp_dir .. "/LspTest.java"
  local file = io.open(test_file, "w")
  if not file then
    print("Could not create test file")
    return false
  end
  
  -- Write simple Java class
  file:write([[
public class LspTest {
    public static void main(String[] args) {
        System.out.println("Hello, JDTLS!");
        String test = "This is a test";
        System.out.println(test.substring(5));
    }
}
]])
  file:close()
  
  -- Open the file in a new buffer
  vim.cmd("edit " .. test_file)
  
  -- Wait for LSP to attach
  print("Opening test file and waiting for JDTLS to attach...")
  vim.defer_fn(function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({bufnr = bufnr})
    local jdtls_attached = false
    
    for _, client in ipairs(clients) do
      if client.name == "jdtls" then
        jdtls_attached = true
        break
      end
    end
    
    if jdtls_attached then
      print("✓ JDTLS successfully attached to test file")
      -- Test hover on "substring"
      vim.api.nvim_win_set_cursor(0, {5, 30}) -- Position cursor at substring
      vim.defer_fn(function()
        vim.lsp.buf.hover()
        print("If you see hover documentation above, JDTLS is working correctly!")
      end, 500) -- Wait for hover
    else
      print("❌ JDTLS failed to attach to test file")
      print("Try running :JdtlsFallback or :JdtlsMinimal")
    end
  end, 2000) -- Give it 2 seconds to attach
  
  return true
end

-- Create verification commands
function M.setup()
  vim.api.nvim_create_user_command('VerifyJdtls', function()
    M.verify()
  end, {})
  
  vim.api.nvim_create_user_command('TestJdtls', function()
    M.test_with_file()
  end, {})
  
  -- Add keymap
  vim.keymap.set('n', '<leader>jv', M.verify, {desc = "Verify JDTLS functionality"})
  vim.keymap.set('n', '<leader>jt', M.test_with_file, {desc = "Test JDTLS with sample file"})
end

-- Initialize
M.setup()

return M
