-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
local TrimWhiteSpaceGrp = augroup("TrimWhiteSpaceGrp", { clear = true })
autocmd("BufWritePre", {
  group = TrimWhiteSpaceGrp,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Highlight on yank
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Return to last edit position when opening files
autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.fn.setpos(".", vim.fn.getpos("'\""))
      -- When entering a file, center the cursor
      vim.cmd('normal zz')
    end
  end
})

-- Auto close file explorer when it's the last window
autocmd("BufEnter", {
  nested = true,
  callback = function()
    local winnr = vim.fn.winnr("$")
    if winnr == 1 and vim.fn.bufname() == "NvimTree_" .. vim.fn.tabpagenr() then
      vim.cmd("quit")
    end
  end
})

-- Start with dashboard when no args
autocmd("VimEnter", {
  callback = function()
    -- Open alpha if no arguments given and not in diff mode
    local should_skip = false
    if vim.fn.argc() > 0 or vim.fn.line2byte('$') ~= -1 or vim.o.insertmode or vim.o.filetype == 'alpha' then
      should_skip = true
    end

    if not should_skip then
      -- Call alpha dashboard
      require('alpha').start(true)
    end
  end
})
