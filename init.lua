-- ============================================================
-- Opções gerais
-- ============================================================
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.termguicolors  = true
vim.opt.background     = "dark"
vim.opt.signcolumn     = "yes"
vim.opt.updatetime     = 200
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.g.mapleader        = " "
vim.g.maplocalleader   = " "

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({

  -- Dependências obrigatórias do refactoring.nvim
  { "nvim-lua/plenary.nvim" },

  -- Which-key (popup de keymaps ao pressionar leader)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Treesitter (obrigatório pelo refactoring.nvim)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main  = "nvim-treesitter",
    opts  = {
      ensure_installed = {
        "lua", "javascript", "typescript", "python",
        "go", "java", "c", "cpp", "ruby", "php", "c_sharp",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },

  -- Telescope (opcional — habilita extensão do refactoring)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      telescope.load_extension("fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>ff",       builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg",       builtin.live_grep,  { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb",       builtin.buffers,    { desc = "Buffers" })
    end,
  },

  -- Terminal flutuante
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Live Server
  {
    "barrett-ruth/live-server.nvim",
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<CR>", desc = "Live Server Start" },
      { "<leader>lx", "<cmd>LiveServerStop<CR>",  desc = "Live Server Stop" },
    },
    config = function()
      vim.g.live_server = {}
    end,
  },

  -- Git signs (mudanças inline no gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]h",          gs.next_hunk,    vim.tbl_extend("force", opts, { desc = "Próximo hunk" }))
          vim.keymap.set("n", "[h",          gs.prev_hunk,    vim.tbl_extend("force", opts, { desc = "Hunk anterior" }))
          vim.keymap.set("n", "<leader>gp",  gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Visualizar hunk" }))
          vim.keymap.set("n", "<leader>gb",  gs.blame_line,   vim.tbl_extend("force", opts, { desc = "Blame da linha" }))
          vim.keymap.set("n", "<leader>gr",  gs.reset_hunk,   vim.tbl_extend("force", opts, { desc = "Resetar hunk" }))
          vim.keymap.set("n", "<leader>gd",  gs.diffthis,     vim.tbl_extend("force", opts, { desc = "Ver diff" }))
        end,
      })
    end,
  },

  -- Lazygit (TUI completo do git)
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },

  -- Supermaven (AI suggestions com Tab)
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion  = "<C-]>",
          accept_word       = "<C-j>",
        },
        -- Tab é gerenciado pelo nvim-cmp acima; desativa o keymap interno
        disable_keymaps = false,
      })
    end,
  },

  -- ============================================================
  -- Mason — gerenciador de LSPs
  -- ============================================================
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "html", "cssls", "ts_ls" },
        automatic_installation = true,
      })
    end,
  },

  -- nvim-cmp (autocompleção)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            local supermaven = require("supermaven-nvim.completion_preview")
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif supermaven.suggestion_preview ~= nil and supermaven.suggestion_preview ~= "" then
              supermaven.on_accept_suggestion()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "supermaven" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd",         vim.lsp.buf.definition,    opts)
        vim.keymap.set("n", "K",          vim.lsp.buf.hover,         opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,   opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,        opts)
        vim.keymap.set("n", "gr",         vim.lsp.buf.references,    opts)
        vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float, opts)
      end

      vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.enable({ "html", "cssls", "ts_ls" })
    end,
  },

  -- ============================================================
  -- refactoring.nvim — https://github.com/ThePrimeagen/refactoring.nvim
  -- ============================================================
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    config = function()
      require("refactoring").setup({
        -- Solicita tipo de retorno ao extrair função (útil em Go, C++, Java)
        prompt_func_return_type = {
          go   = true,
          java = true,
          cpp  = true,
          c    = true,
        },
        -- Solicita tipo dos parâmetros ao extrair função
        prompt_func_param_type = {
          go   = true,
          java = true,
          cpp  = true,
          c    = true,
        },
        printf_statements    = {},
        print_var_statements = {},
        show_success_message = true,
      })

      -- Carregar extensão do Telescope para navegar nos refactors
      require("telescope").load_extension("refactoring")

      -- ── Keymaps via Ex commands (recomendado — suporta preview) ──

      -- Extrair seleção visual para função
      vim.keymap.set("x", "<leader>re", ":Refactor extract ",          { desc = "Extract function" })
      -- Extrair seleção visual para arquivo separado
      vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ",  { desc = "Extract to file" })
      -- Extrair seleção visual para variável
      vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ",      { desc = "Extract variable" })
      -- Inline variável (normal + visual)
      vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var",       { desc = "Inline variable" })
      -- Inline função (normal)
      vim.keymap.set("n",          "<leader>rI", ":Refactor inline_func",      { desc = "Inline function" })
      -- Extrair bloco para função
      vim.keymap.set("n",          "<leader>rb",  ":Refactor extract_block",   { desc = "Extract block" })
      -- Extrair bloco para arquivo
      vim.keymap.set("n",          "<leader>rbf", ":Refactor extract_block_to_file", { desc = "Extract block to file" })

      -- Seletor via Telescope (<leader>rr)
      vim.keymap.set({ "n", "x" }, "<leader>rr", function()
        require("telescope").extensions.refactoring.refactors()
      end, { desc = "Refactor (Telescope)" })

      -- ── Debug helpers ──

      -- Inserir printf de debug acima da linha atual
      vim.keymap.set("n", "<leader>rp", function()
        require("refactoring").debug.printf({ below = false })
      end, { desc = "Debug: printf" })

      -- Imprimir variável sob cursor (normal + visual)
      vim.keymap.set({ "x", "n" }, "<leader>rv", function()
        require("refactoring").debug.print_var()
      end, { desc = "Debug: print var" })

      -- Limpar todos os prints de debug inseridos pelo refactoring
      vim.keymap.set("n", "<leader>rc", function()
        require("refactoring").debug.cleanup({})
      end, { desc = "Debug: cleanup prints" })
    end,
  },

}, {
  checker = { enabled = true, notify = false },
})

-- ============================================================
-- Keymaps gerais
-- ============================================================
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Explorador de arquivos (netrw)" })

vim.api.nvim_create_user_command("Tg", function(opts)
  vim.cmd("ToggleTerm " .. opts.args)
end, { nargs = 1 })
