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
vim.opt.showcmd = false
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

-- keymaps
vim.keymap.set("n", "<leader><t>", current_date, { noremap = false })
vim.keymap.set("n", "gx", open_markdown_item, { noremap = false })
