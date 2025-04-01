-- Use bundled JDTLS distribution that comes with the config
local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify("[JDTLS] nvim-jdtls plugin not found", vim.log.levels.ERROR)
  return
end

-- Find root directory
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
local root_dir = require('jdtls.setup').find_root(root_markers) or vim.fn.getcwd()

-- Project name for workspace folder
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
vim.fn.mkdir(workspace_dir, "p")

-- Get config directory where Neovim configuration is stored
local config_dir = vim.fn.stdpath("config")

-- Use bundled JDTLS directly (it's already included in the config)
local jdtls_dir = config_dir .. "/jdtls-1.43"
local launcher_jar = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")

if launcher_jar == "" then
  vim.notify("[JDTLS] Bundled JDTLS not found. Using the configuration for the first time? Contact the provider.", vim.log.levels.ERROR)
  return
end

-- Find Java executable
local java_cmd = vim.fn.exepath('java')
if not java_cmd or java_cmd == "" then
  vim.notify("[JDTLS] Java executable not found", vim.log.levels.ERROR)
  return
end

-- Set up the JDTLS configuration
local config = {
  cmd = {
    java_cmd,
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Xms512m',
    '-Xmx1g',
    '-jar', launcher_jar,
    '-configuration', jdtls_dir .. "/config_linux",
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-17",
            path = vim.env.JAVA_HOME or vim.fn.expand("/usr/lib/jvm/java-17-openjdk/"),
            default = true,
          },
        },
      },
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
    },
  },
  init_options = {
    bundles = {},
  },
  on_attach = function(client, bufnr)
    -- Regular LSP keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    
    -- JDTLS specific keymaps for Java refactoring
    vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, opts)
    vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, opts)
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, opts)
    vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, opts)
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, opts)
  end,
}

-- Log the configuration being used
vim.notify("[JDTLS] Starting with bundled JDTLS from " .. jdtls_dir, vim.log.levels.INFO)
vim.notify("[JDTLS] Workspace: " .. workspace_dir, vim.log.levels.INFO)

-- Start the JDTLS server
jdtls.start_or_attach(config)
