vim.g.mapleader = ' '

-- general settings 
vim.opt.filetype.plugin = true
vim.opt.filetype.indent = true
vim.opt.textwidth = 80
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.conceallevel = 1
vim.opt.showcmd = true
vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.shada = ""  -- disable shada file. No need to keep commands/jump lists or buffers around 
vim.opt.hlsearch = false
vim.opt.backup = false
vim.opt.wrap = true
vim.opt.smartindent = true
vim.opt.completeopt = { "menu" }
vim.opt.foldenable = false
vim.opt.wildmenu = true
vim.g.netrw_fastbrowse = 0 -- makes it so that the netwr buffer is closed after use

vim.cmd.colorscheme("miy")

-- disable built-in treesitter 
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    vim.treesitter.stop(args.buf)
  end,
})

-- custom functions

function PopulateQuickfixFromSelection()
    -- Get the visually selected text
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
    -- Get selected lines
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

    -- Extract markdown links using pattern
    local qflist = {}
    local pattern = "%[.-%]%((.-)%)"  -- Matches "[text](filename.md)"

    for _, line in ipairs(lines) do
        for filename in line:gmatch(pattern) do
            table.insert(qflist, { filename = filename, lnum = 1, col = 1, text = "Markdown File: " .. filename })
        end
    end

    if #qflist > 0 then
        vim.fn.setqflist(qflist, "r")
    else
        print("No Markdown links found!")
    end
end

function toggle_quickfix() 
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
end

function restart_lsp() 
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in ipairs(clients) do
    -- Stop the client
    client.stop(true)
    -- Start it again with the same configuration
    vim.lsp.start_client(client.config)
  end
end

function current_date()
  local date = os.date("%Y-%m-%d") -- Format as YYYY-MM-DD
  vim.api.nvim_put({ date }, "", true, true) -- Inserts the date at the cursor position
end

function open_markdown_item()
  -- Get the current line
  local line = vim.fn.getline(".")

  -- Try to extract a Markdown-style link target
  local path = line:match("%[[^%]]+%]%(([^%)]+)%)")

  if not path then
    local word = vim.fn.expand("<cWORD>")
    path = word:match("%(([^)]+)%)") or word
  end

  if not path then return end

  -- Determine if it's a URL
  if path:match("^https?://") or path:match("^file://") then
    vim.fn.jobstart({ "xdg-open", path }, { detach = true })
    return
  end

  -- Extract extension
  local ext = path:match("^.+%.([^%.]+)$")
  local xdg_exts = { png = true, jpg = true, jpeg = true, gif = true, mp4 = true, webm = true }

  -- Build full file path
  local root_dir = vim.fn.expand("%:p:h")
  local full_path = vim.fn.fnamemodify(root_dir .. "/" .. path, ":p")

  if ext and xdg_exts[ext:lower()] then
    vim.fn.jobstart({ "xdg-open", full_path }, { detach = true })
  else
    vim.cmd.edit(full_path)
  end
end

vim.api.nvim_create_user_command("QuickfixFromSelection", PopulateQuickfixFromSelection, {range = true})
vim.api.nvim_create_user_command("CurrentDate", current_date, {})
vim.api.nvim_create_user_command("OpenMarkdownItem", open_markdown_item, {})

-- LSP 
vim.lsp.config('*', {
    root_markers = { '.git', '.jj' },
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
    end,
})

vim.lsp.config('rust-analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = {'rust'},
    settings = {
      ["rust-analyzer"] = {
          check = {
              command = "clippy",
              extraArgs = { "--no-deps" },
          },
          cargo = {
              allFeatures = true,  -- optional
          },
      }
  }
})

vim.lsp.config('marksman', {
    cmd = { 'marksman' },
    filetypes = {'markdown'},
})

vim.lsp.enable({'rust-analyzer', 'marksman'})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function() 
      vim.diagnostic.setqflist({nr=1, open=false}, "r")
      update_status_line()
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern={"*.rs"},
    callback=function() vim.lsp.buf.format({async=false}) end,
}) 

local function hover()
  vim.lsp.buf.hover(vim.tbl_extend("force", { border = "single" }, {}))
end

-- Keymaps
  -- util 
vim.keymap.set("n", "<leader>t", current_date, { noremap = false })
vim.keymap.set("n", "gx", open_markdown_item, { noremap = false })
  -- lsp
vim.keymap.set("n", "gk", hover,{ noremap = false })
vim.keymap.set("n", "dk", vim.diagnostic.open_float,  { noremap = false })             
vim.keymap.set("n", "ga", vim.lsp.buf.code_action,  { noremap = false })             
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = false })   
vim.keymap.set("n", "gi", vim.lsp.buf.references, { noremap = false })  
vim.keymap.set("n", "gr", vim.lsp.buf.rename, { noremap = false }) 
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { noremap = false })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { noremap = false })
vim.keymap.set("n", "<leader>rr", restart_lsp, { noremap = false })
vim.keymap.set("i", "<C-space>", "<C-x><C-o>", { noremap = false })

  -- quickfix
vim.keymap.set("n", "dn", ":silent! cnext<CR>", { noremap = false })
vim.keymap.set("n", "dp", ":silent! cprev<CR>", { noremap = false })
vim.keymap.set("n", "dc", ":cclose<CR>", { noremap = false })
vim.keymap.set("n", "dl", toggle_quickfix, { noremap = false })

-- diagnostics 
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

function update_status_line() 
    local warnings = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.WARN})
    local errors = #vim.diagnostic.get(nil, {severity = vim.diagnostic.severity.ERROR})

    vim.o.statusline = "%f %#DiagnosticError#✘:" .. errors .. " %#DiagnosticWarn#▲:" .. warnings .. "%## %h%m%r%=%-14.(%l,%c%V%) %P"
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function() 
      vim.diagnostic.setqflist({nr=1, open=false}, "r")
      update_status_line()
    end,
})

