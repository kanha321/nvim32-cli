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
    
    -- Enable snippet filetype detection
    luasnip.filetype_extend("javascript", { "javascriptreact" })
    luasnip.filetype_extend("javascript", { "html" })
    luasnip.filetype_extend("typescript", { "html" })
    luasnip.filetype_extend("kotlin", { "java" }) -- Reuse Java snippets for Kotlin
    
    -- Make snippets work with Tab key in the same session
    require("luasnip").config.set_config({ 
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
      -- Add snippet autocompletion
      experimental = {
        ghost_text = true,
      }
    })
    
    -- Add more custom snippets
    local snip = luasnip.snippet
    local text = luasnip.text_node
    local insert = luasnip.insert_node
    
    -- Custom snippets for Java and Kotlin
    -- Example: "psvm" expands to public static void main
    luasnip.add_snippets("java", {
      snip({
        trig = "psvm",
        name = "public static void main",
        dscr = "Public static void main method"
      }, {
        text("public static void main(String[] args) {"),
        text("\n\t"),
        insert(0),
        text("\n}")
      }),
      -- Add a record snippet for Java 17
      snip({
        trig = "record",
        name = "Java record",
        dscr = "Create a Java 17 record"
      }, {
        text("record "),
        insert(1, "RecordName"),
        text("("),
        insert(2, "String field1, int field2"),
        text(") {"),
        text("\n\t"),
        insert(0),
        text("\n}")
      }),
      -- Add a sealed class snippet for Java 17
      snip({
        trig = "sealed",
        name = "Java sealed class",
        dscr = "Create a Java 17 sealed class"
      }, {
        text("sealed class "),
        insert(1, "BaseClass"),
        text(" permits "),
        insert(2, "SubClass1, SubClass2"),
        text(" {"),
        text("\n\t"),
        insert(0),
        text("\n}")
      })
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
