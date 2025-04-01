-- CLI-friendly completion configuration with snippets
return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets', -- IntelliJ-like snippets
  },
  config = function()
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

    -- Load friendly-snippets and configure them
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Load our custom snippets
    require("snippets").setup()
    
    -- Enable snippet filetype detection
    luasnip.filetype_extend("javascript", { "javascriptreact" })
    luasnip.filetype_extend("javascript", { "html" })
    luasnip.filetype_extend("typescript", { "html" })
    luasnip.filetype_extend("kotlin", { "java" }) -- Reuse Java snippets for Kotlin
    
    -- Make snippets work with Tab key in the same session
    luasnip.config.set_config({ 
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
    })

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = { 
          border = "single", 
          winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
        },
        documentation = {
          border = "single",
          winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
        },
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
      -- Show source in completion menu
      formatting = {
        format = function(entry, vim_item)
          -- Simple text labels for CLI
          local source_mapping = {
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
          }
          
          -- Show which snippet engine provided this completion
          vim_item.menu = source_mapping[entry.source.name]
          
          -- If this is a snippet completion, add the snippet name
          if entry.source.name == "luasnip" then
            vim_item.menu = source_mapping.luasnip .. " " .. (entry.completion_item.label or "")
          end
          
          return vim_item
        end,
      },
      -- Optimize performance for 32-bit system
      performance = {
        throttle = 50,
        fetching_timeout = 500,
        max_view_entries = 10,
      },
      -- Add snippet autocompletion
      experimental = {
        ghost_text = true,
      }
    })
    
    -- Make cmp work in command mode too
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })
  end
}
