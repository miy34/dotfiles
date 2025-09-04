-- bootstrap lazy.vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ' '

require("lazy").setup({
    -- load and set theme it right away
    {
        "catppuccin/nvim",
	    lazy = false,
        name = "catppuccin",
        priority = 1000,
    },
    {  
        "tiagovla/tokyodark.nvim",
	    lazy = false,
        priority = 1000,
    },
    {  
        "marko-cerovac/material.nvim",
	    lazy = false,
        priority = 1000,
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function() 
            vim.cmd.colorscheme("kanagawa-dragon")
        end,
    },
    {
        "rose-pine/neovim", 
        name = "rose-pine",
        priority = 1000,
    },
    {
        "liuchengxu/vista.vim",
        lazy = false;
    },
    { 
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim"},
        config = function(plugin, opts)
            require "telescope".setup {
                defaults = {
                    layout_strategy = "vertical",
                    layout_config = {
                        height = vim.o.lines, -- maximally available lines
                        --width = vim.o.columns, -- maximally available columns
                        width = 0.6,
                        prompt_position = "bottom",
                        preview_height = 0.6, -- 60% of available lines
                    },
                    prompt_prefix = " ",
                },
            }
        end,
        keys = {
            { "<leader>f", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
            { "<leader>n", "<cmd>Telescope resume<CR>", desc = "Open previous Telescope window" },
            { "<leader>d", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
            { "<leader>g", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
            { "<leader>r", "<cmd>Telescope lsp_references<CR>", desc = "Find References" },
            { "<leader>s", "<cmd>Telescope lsp_document_symbols ignore_symbols={'field','enummember','function'}<CR>", desc = "List Symbols" },
        }
    },
    {
        "hrsh7th/nvim-cmp",
        name = 'cmp',
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
        config = function(plugin, opts)
          vim.cmd([[set shortmess+=c]])

          local cmp = require("cmp")
          cmp.setup({
          preselect = 'item',
          completion = {
              completeopt = 'menuone,noinsert,menu'
          },
          snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
          },
            mapping = {
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }),
         },
             sources = {
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
            },
          })
        end

    },
    {
        "godlygeek/tabular",
        ft = { "markdown" },
        name = "tabular",
    },
    {
        "preservim/vim-markdown",
        ft = { "markdown" },
        name = "vim-markdown",
        config = function(_, ops) 
            vim.g.vim_markdown_no_default_key_mappings = 1
            vim.g.vim_markdown_fenced_languages = {"rust"}
            vim.g.vim_markdown_frontmatter = 1
            vim.g.vim_markdown_strikethrough = 1
        end,
    },
    {
        "tikhomirov/vim-glsl",
        ft = { "glsl" },
        name = "vim-glsl",
    },
    --lsp
    {
        "neovim/nvim-lspconfig",
        ft = { "rust", "markdown", "wgsl" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function(_, opts)
            local capabilities = require("cmp_nvim_lsp").default_capabilities() 
            for server, server_opts in pairs(opts.servers) do 
                server_opts.capabilities = capabilities
                require("lspconfig")[server].setup(server_opts)
            end

            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = true,
                    style = 'minimal',
                    border = 'rounded',
                    source = 'always',
                    header = '',
                    prefix = '',
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '✘',
                        [vim.diagnostic.severity.WARN] = '▲',
                        [vim.diagnostic.severity.HINT] = '⚑',
                        [vim.diagnostic.severity.INFO] = '',
                    },
                    texthl = {
                        [vim.diagnostic.severity.ERROR] = '✘',
                        [vim.diagnostic.severity.WARN] = '▲',
                        [vim.diagnostic.severity.HINT] = '⚑',
                        [vim.diagnostic.severity.INFO] = '',
                    },
                    numhl = '',
                }
            })

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern={"*.rs"},
                callback=function() vim.lsp.buf.format({async=false}) end,
            }) 
        end,
        opts = {
            servers = {
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            check = { command = "clippy"},
                            diagnostics = { enable = true },
                            cargo = { allFeatures = true },
                        },
                    },
                    on_attach = function(bufnr) 
                        vim.keymap.set("n", "K", vim.lsp.buf.hover, {noremap = false })
                        vim.keymap.set("n", "gK", vim.diagnostic.open_float, { noremap = false })
                        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { noremap = false })
                        vim.keymap.set("n", "gr", vim.lsp.buf.rename, { noremap = false })
                        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { noremap = false })
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = false })
                        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = false })
                        vim.keymap.set("n", "gs", vim.lsp.buf.workspace_symbol, { noremap = false })
                        vim.keymap.set("n", "gh", function() 
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, { noremap = false })
                    end
                },
                marksman = {
                    on_attach = function(bufnr) 
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = false })
                        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { noremap = false })
                        vim.keymap.set("n", "gs", vim.lsp.buf.workspace_symbol, { noremap = false })
                    end
                },
                wgsl_analyzer = {
                }
            },
        },
    }
})

-- general settings 
vim.opt.filetype.plugin = true
vim.opt.filetype.indent = true
vim.opt.textwidth = 80
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.conceallevel = 3
vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.shada = ""  -- disable shada file. No need to keep commands/jump lists or buffers around 
vim.opt.hlsearch = false  -- highlighting search is annoying
vim.opt.backup = false
vim.opt.wrap = true
vim.opt.smartindent = true
vim.opt.completeopt = { "menu" }
vim.opt.foldenable = false
vim.opt.wildmenu = true
vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"
vim.opt.termguicolors = true

--DEBUGGER     
vim.cmd([[packadd termdebug]])

--vertical split
vim.g.termdebug_wide = 1

vim.keymap.set("n", "<leader>t", ":Vista!!<CR>", { noremap = false })
-- buffer movement
vim.keymap.set("n", "<leader>b", "<cmd>bnext<cr>", { noremap = false })
vim.keymap.set("n", "<leader>p", "<cmd>bprev<cr>", { noremap = false })
vim.keymap.set("n", "<leader><leader>", "<cmd>b#<CR>", { noremap = false })

-- Nvim always hangs for a couple of seconds when I accidentially hit 
-- n in while in visual mode
vim.keymap.set("v", "n", "", {})

-- map it so that ESC will go to normal mode,
-- even when TermDebug is active
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {})

-- center cursor after scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = false })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = false })

-- misc functions
local function current_date()
  local date = os.date("%Y-%m-%d") -- Format as YYYY-MM-DD
  vim.api.nvim_put({ date }, "", true, true) -- Inserts the date at the cursor position
end

vim.keymap.set("n", "T", current_date, { noremap = false })

function update_status_line() 
    local warnings = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.WARN})
    local errors = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.ERROR})

    vim.o.statusline = "%f %#Error#✘:" .. errors .. " %#WarningMsg#▲:" .. warnings .. "%## %h%m%r%=%-14.(%l,%c%V%) %P"
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function() 
    local warnings = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.WARN})
    local errors = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.ERROR})

    vim.o.statusline = "%f %#Error#✘:" .. errors .. " %#WarningMsg#▲:" .. warnings .. "%## %h%m%r%=%-14.(%l,%c%V%) %P"
    end,
})

function open_markdown_item()
  -- Get the current line and cursor position
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")

  -- Get the word under the cursor
  local path = line:match("%[[^%]]+%]%(([^%)]+)%)")

  if not path then 
      local word = vim.fn.expand("<cWORD>")
      path = word:match("%(([^)]+)%)") or word
  end 

  local root_dir = vim.fn.expand("%:p:h")

  local full_path = root_dir .. "/" .. path

  vim.fn.system("xdg-open " .. full_path)
end

vim.keymap.set("n", "gx", open_markdown_item, { noremap = false })

vim.cmd [[
let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction

nnoremap <S-h> :call ToggleHiddenAll()<CR>
]]

-- Auto-create parent directories (except for URIs "://").
vim.api.nvim_create_autocmd({"BufWritePre", "FileWritePre"}, {
  pattern = "*",
  callback = function()
    local file_path = vim.fn.expand("<afile>:p:h")
    if not file_path:match("://") then
      vim.fn.mkdir(file_path, "p")
    end
  end
})

vim.keymap.set("n", "dn", ":cnext<CR>", { noremap = false })
vim.keymap.set("n", "dp", ":cprev<CR>", { noremap = false })
vim.keymap.set("n", "dc", ":cclose<CR>", { noremap = false })
vim.keymap.set("n", "dl", function()
  local qf_open = false
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "" and vim.fn.getwininfo(win)[1].quickfix == 1 then
      qf_open = true
      break
    end
  end
  if qf_open then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end, { noremap = false })


function quickfix_from_selection()
    -- Get the visually selected text
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
    -- Get selected lines
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

    -- Extract markdown links using pattern
    local qflist = {}
    local pattern = "%[.-%]%((.-)%)"  -- Matches "[text](filename.md)"

   -- Get the directory of the current buffer
    local current_dir = vim.fn.expand('%:p:h')

    for _, line in ipairs(lines) do
        for filename in line:gmatch(pattern) do
            filename = current_dir .. '/' .. filename
            table.insert(qflist, { filename = filename, lnum = 1, col = 1, text = "Markdown File: " .. filename })
        end
    end

    if #qflist > 0 then
        vim.fn.setqflist(qflist, "r")
    else
        print("No Markdown links found!")
    end
end

-- Create a command to call it after visual selection
vim.api.nvim_create_user_command("QuickfixFromSelection", quickfix_from_selection, {range = true})
