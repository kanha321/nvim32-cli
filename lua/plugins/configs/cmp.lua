-- Completion configuration
local M = {}

function M.setup()
  local cmp_ok, cmp = pcall(require, "cmp")
  if not cmp_ok then
    vim.notify("cmp not found", vim.log.levels.ERROR)
    return
  end

  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    vim.notify("luasnip not found", vim.log.levels.ERROR)
    return
  end

  -- Load friendly-snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp', priority = 1000 },
      { name = 'luasnip', priority = 750 },
      { name = 'buffer', priority = 500 },
      { name = 'path', priority = 250 },
    }),
    formatting = {
      format = function(entry, vim_item)
        -- Set icons based on completion source type
        local source_mapping = {
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]",
        }
        
        vim_item.menu = source_mapping[entry.source.name]
        return vim_item
      end,
    },
    -- Optimize performance for 32-bit system
    performance = {
      throttle = 50,
      fetching_timeout = 500,
      max_view_entries = 10,
    },
  })

  -- Set up signature help
  local has_signature, lsp_signature = pcall(require, "lsp_signature")
  if has_signature then
    lsp_signature.setup({
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      hint_enable = false,
      hint_prefix = "🔍 ",
      max_height = 12,
      max_width = 80,
    })
    -- Show parameters on keypress
    vim.keymap.set('i', '<C-p>', function()
      lsp_signature.signature()
    end, { noremap = true, silent = true, desc = "Show parameter hints" })
  else
    vim.keymap.set('i', '<C-p>', function()
      vim.lsp.buf.signature_help()
    end, { noremap = true, silent = true, desc = "Show parameter hints" })
  end
end

return M
