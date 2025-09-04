vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.o.background = "dark"
vim.o.termguicolors = true

vim.g.colors_name = "miy"

local hl = vim.api.nvim_set_hl

-- Define highlight groups
hl(0, "Normal",   { fg = "#D27E99", bg = "#16161D" })
hl(0, "Comment",  { fg = "#7FB4CA", italic = true })
hl(0, "String",   { fg = "#C34043" })

-- link groups
hl(0, "Constant", { link = "String" })
hl(0, "Number",   { link = "String" })

-- status line
hl(0, "StatusLine",   { fg = "#DCD7BA", bg = "#1F1F28" })
hl(0, "StatusLineNC", { fg = "#727169", bg = "#16161D" })

-- dim line numbers and highlight current line
hl(0, "LineNr",      { fg = "#3C3C44" })
hl(0, "CursorLineNr",{ fg = "#DCD7BA", bold = true })
hl(0, "CursorLine",  { bg = "#1F1F28" })


local groups_to_neutralize = {
  "Function", "Identifier", "Statement", "Type", "PreProc", "Keyword",
  "Constant", "Special", "Operator", "Label", "Repeat", "Conditional",
  "Structure", "Include", "Define", "Todo", "Delimiter", "markdownH1",
  "markdownH2", "markdownH3", "markdownH4", "markdownH5", "markdownH6"
}

for _, group in ipairs(groups_to_neutralize) do
  vim.api.nvim_set_hl(0, group, { link = "Normal" })
end
