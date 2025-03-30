local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

-- Check if we have lsp_signature for better parameter hints
local has_signature, lsp_signature = pcall(require, "lsp_signature")
if has_signature then
  lsp_signature.setup({
    bind = true,
    handler_opts = {
      border = "rounded",
    },
    hint_enable = false, -- We'll use our own keybinding instead of automatic hints
    hint_prefix = "🔍 ",
    max_height = 12,
    max_width = 80,
    toggle_key = nil, -- We'll set our own toggle key
  })
end

-- Show parameters on keypress
vim.keymap.set('i', '<C-p>', function()
  if has_signature then
    lsp_signature.signature()
  else
    vim.lsp.buf.signature_help()
  end
end, { noremap = true, silent = true, desc = "Show parameter hints" })

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
  }),
  -- Optimize performance for 32-bit system
  performance = {
    throttle = 50,
    fetching_timeout = 500,
    max_view_entries = 10,
  },
})
