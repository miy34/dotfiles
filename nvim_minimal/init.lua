vim.g.mapleader = ' '

-- general settings 
vim.opt.filetype.plugin = true
vim.opt.filetype.indent = true
vim.opt.textwidth = 80
vim.opt.tabstop = 2         -- visually treat tabs as 2
vim.opt.shiftwidth = 4      -- but when auto-indenting, still use 4
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
vim.o.exrc = true
vim.o.secure = true
vim.g.netrw_fastbrowse = 0 -- makes it so that the netwr buffer is closed after use

vim.cmd.colorscheme("miy")

local lsp_servers = {'rust-analyzer', 'marksman'}

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

    -- disable all configs (stops/detaches clients)
    vim.lsp.enable(lsp_servers, false)

    -- re-enable them (starts/attaches as appropriate)
    vim.lsp.enable(lsp_servers, true)
end

function current_date()
  local date = os.date("%Y-%m-%d") -- Format as YYYY-MM-DD
  vim.api.nvim_put({ date }, "", true, true) -- Inserts the date at the cursor position
end

function current_time()
  local time = os.date("%H:%M") 
  vim.api.nvim_put({ time }, "", true, true)
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
vim.api.nvim_create_user_command("CurrentTime", current_time, {})
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

vim.lsp.enable(lsp_servers)

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
vim.keymap.set("n", "<leader>d", current_date)
vim.keymap.set("n", "<leader>t", current_time)
vim.keymap.set("n", "gx", open_markdown_item)
  -- lsp
vim.keymap.set("n", "gk", hover)
vim.keymap.set("n", "dk", vim.diagnostic.open_float)             
vim.keymap.set("n", "ga", vim.lsp.buf.code_action)             
vim.keymap.set("n", "gd", vim.lsp.buf.definition)   
vim.keymap.set("n", "gi", vim.lsp.buf.references)  
vim.keymap.set("n", "gr", vim.lsp.buf.rename) 
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>rr", restart_lsp)
vim.keymap.set("i", "<C-space>", "<C-x><C-o>")
vim.keymap.set("n", "<leader>b", ":silent make!<CR>")

  -- quickfix
vim.keymap.set("n", "dn", ":silent! cnext<CR>")
vim.keymap.set("n", "dp", ":silent! cprev<CR>")
vim.keymap.set("n", "dc", ":cclose<CR>")
vim.keymap.set("n", "dl", toggle_quickfix)

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

function FZF(show_preview)
  local preview_command = show_preview and "--preview 'bat --style=numbers --color=always {}'" or ""
  local fzf_command = "fd --type f --strip-cwd-prefix | fzf --prompt '' --multi"
  local awk_command = "awk '{ print $1 }'"

  local tempname = vim.fn.tempname()
  local buf = vim.api.nvim_create_buf(false, true)

  -- window style
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a floating window with a minimal style and rounded border
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  local cmd = fzf_command .. " " .. preview_command .. " | " .. awk_command .. " > " .. vim.fn.fnameescape(tempname)

  -- Run the command in the terminal using termopen.
  vim.fn.termopen(cmd, {
    on_exit = function(job_id, exit_code, event)
      -- Use vim.schedule to safely call Vim commands from the callback.
      vim.schedule(function()
        vim.api.nvim_win_close(win, true)
        if exit_code == 0 then
          local file = io.open(tempname, "r")
          if not file then 
              print("Error: Failed to open file " .. tempname)
              return
          end

          local target = file:read("*l")
          file:close()

          if not target or target == "" then 
              print("Error: No file to open")
              return
          end

          -- vim.cmd("cfile " .. tempname)
          vim.cmd("edit " .. vim.fn.fnameescape(target))
        end

        -- Clean up the temporary file.
        vim.fn.delete(tempname)
      end)
    end,
  })
end

vim.keymap.set('n', '<leader>f', ':lua FZF(true)<CR> i', { silent = true })

