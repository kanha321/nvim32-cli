-- Code Runner plugin
return {
  'CRAG666/code_runner.nvim',
  dependencies = {
    'akinsho/toggleterm.nvim', -- Required for terminal output
  },
  config = function()
    -- First ensure toggleterm is loaded and configured
    require('toggleterm').setup({
      open_mapping = [[<c-\>]],
      direction = 'float', -- Make it a floating window by default
      float_opts = {
        border = 'single', -- Use single border for consistency
        width = function()
          return math.floor(vim.o.columns * 0.8) -- 80% of screen width
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8) -- 80% of screen height
        end,
      },
    })

    -- Now set up code_runner
    require('code_runner').setup({
      -- Choose to either run in a terminal or quickfix
      mode = 'toggleterm',
      -- No specific options needed for toggleterm mode
      -- Focus terminal after running
      focus = true,
      -- Configure commands for filetypes
      filetype = {
        python = "python $file",
        c = "gcc $file -o $fileBase.out && ./$fileBase.out || echo 'Compilation failed!'",
        cpp = "g++ $file -o $fileBase.out && ./$fileBase.out || echo 'Compilation failed!'",
        asm = "gcc $file -nostdlib -static -o $fileBase.out && ./$fileBase.out || echo 'Compilation failed!'",
        sh = "if [ -x $file ]; then $file; else sh $file; fi",
        java = "mkdir -p out && javac -d out $file && java -cp out $fileBasename",
        javascript = "node $file",
        typescript = "ts-node $file",
        rust = "cargo run || rustc $file && ./$fileBase",
        go = "go run $file",
        lua = "lua $file",
        kotlin = "kotlinc $file -include-runtime -d $fileBase.jar && java -jar $fileBase.jar"
      },
      -- Configure commands for projects (useful for specific root directories)
      project = {
        -- Example: detect project type by presence of files
        ["package.json"] = "npm start",
        ["gradlew"] = "./gradlew run"
      },
    })

    -- Set up key mappings
    local opts = { noremap = true, silent = true }
    
    -- Implement your provided mapping
    vim.keymap.set("n", ")", function()
      -- First save the file
      vim.cmd("w")
      -- Then run it
      require('code_runner').run()
    end, { desc = "Run code based on filetype" })
    
    -- Also map Ctrl+' (compatibility with your existing setup)
    vim.keymap.set("n", "<C-'>", function()
      vim.cmd("w")
      require('code_runner').run()
    end, opts)
    
    -- Add a more standard mapping as well
    vim.keymap.set("n", "<leader>r", function()
      vim.cmd("w")
      require('code_runner').run()
    end, { desc = "Run code" })
    
    -- Add run in project functionality with a different key
    vim.keymap.set("n", "<leader>rp", function()
      vim.cmd("w")
      require('code_runner').run_project()
    end, { desc = "Run project" })
    
    -- Create command for terminal command execution
    vim.api.nvim_create_user_command('TermExec', function(opts)
      -- Parse the command from the arguments
      local cmd = opts.args:match("cmd='(.*)'")
      if not cmd then
        cmd = opts.args -- If not in cmd='...' format, just use the args directly
      end
      
      -- Create and open a terminal with the command
      local term = require('toggleterm.terminal').Terminal:new({
        cmd = cmd,
        hidden = false,
        close_on_exit = false,
        direction = 'float',
      })
      
      term:toggle()
    end, {
      nargs = '+',
      desc = 'Execute command in terminal',
      complete = 'file'
    })
  end
}
