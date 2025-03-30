-- CLI-friendly Git integration with error fix
return {
  'lewis6991/gitsigns.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Add missing dependency
  },
  config = function()
    -- Helper function to check if we're in a git repo
    local function is_git_repo()
      local output = vim.fn.systemlist('git rev-parse --is-inside-work-tree 2>/dev/null')
      return output[1] == 'true'
    end

    -- Only setup gitsigns if we're in a git repo to avoid errors
    if is_git_repo() then
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '^' },
          changedelete = { text = '~' },
        },
        -- Safe settings for 32-bit system
        watch_gitdir = {
          follow_files = false, -- Disable file following
          interval = 4000, -- Increase interval to reduce CPU usage
        },
        sign_priority = 5, -- Lower priority to avoid conflicts
        update_debounce = 500, -- Increase debounce time
        status_formatter = nil, -- Disable status formatter
        max_file_length = 10000,
        preview_config = {
          border = 'single',
          style = 'minimal',
        },
        -- Turn off most features to prevent errors
        current_line_blame = false,
        current_line_blame_opts = {
          delay = 1000,
        },
        -- Disable advanced features for stability
        _threaded_diff = false,
        _extmark_signs = false,
        _signs_staged_enable = false,
        _signs_staged = false,
        _worktrees = {},
      })
    else
      -- Skip setup and notify
      vim.schedule(function()
        vim.notify("Gitsigns not loaded: not a git repository", vim.log.levels.INFO)
      end)
    end
  end,
  -- Set this to false to prevent loading on startup
  -- Load gitsigns only when needed to prevent errors
  lazy = true,
  event = "BufReadPre",
}
