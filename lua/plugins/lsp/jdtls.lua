-- Basic JDTLS configuration
return {
  'mfussenegger/nvim-jdtls',
  ft = { "java" }, -- Only load for Java files
  config = function()
    local jdtls_config = function()
      -- Find root directory
      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = require('jdtls.setup').find_root(root_markers) or vim.fn.getcwd()
      
      -- Project name for workspace folder
      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
      
      -- Find Java command
      local java_cmd = vim.fn.exepath('java')
      
      -- Find JDTLS installation
      local jdtls_path
      local mason_registry = require('mason-registry')
      if mason_registry.is_installed('jdtls') then
        jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
      else
        jdtls_path = '/usr/share/java/jdtls' -- System package fallback
      end
      
      -- Basic config
      local config = {
        cmd = {
          java_cmd,
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Xms1g',
          '-Xmx2g',
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
                  path = vim.fn.expand("/usr/lib/jvm/java-17-openjdk/"),
                  default = true,
                },
              }
            }
          }
        },
      }
      
      -- Start JDTLS server
      require('jdtls').start_or_attach(config)
    end
    
    -- Create autocmd to start JDTLS when opening Java files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = jdtls_config
    })
  end
}
