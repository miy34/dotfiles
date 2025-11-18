vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.o.background = "dark"
vim.o.termguicolors = true

vim.g.colors_name = "miy"

local hl = vim.api.nvim_set_hl

local colors = {
  bg       = "#1F1F28", 
  -- bg       = "#1B1B2B", 
  -- fg       = "#C0A8CF", 
  fg      = "#f92672", 
  red      = "#F07078", 
  green    = "#90B080", 
  blue      = "#7aa2f7",
  yellow   = "#E2B45C", 
  brown     = "#c07000", 
  purple   = "#C080D0", 
  cyan     = "#70C0D0", 
  orange   = "#FF9E64", 
  pink     = "#FF85A0", 
}

-- Define highlight groups
hl(0, "Normal",   { fg=colors.purple })
hl(0, "Comment",  { fg=colors.cyan, italic = true })
hl(0, "SpecialComment",  { fg=colors.brown, italic = true })
hl(0, "String",   { fg=colors.pink })

-- link groups
hl(0, "Constant", { link = "String" })
hl(0, "Number",   { link = "String" })

-- status line
hl(0, "StatusLine",   { fg = "#DCD7BA", bg = "#1F1F28" })
hl(0, "StatusLineNC", { fg = "#727169", bg = "#16161D" })

-- diagnostics
hl(0, "DiagnosticError", { fg = colors.red })
hl(0, "DiagnosticWarn", { fg = colors.yellow })

-- dim line numbers and highlight current line
hl(0, "LineNr",      { fg = "#3C3C44" })
hl(0, "CursorLineNr",{ fg = "#DCD7BA", bold = true })
hl(0, "CursorLine",  { bg = "#1F1F28" })

-- Floating windows (hover, signature help, completion, etc.)
hl(0, "NormalFloat", { fg = "#D27E99", bg = colors.bg })
hl(0, "FloatBorder", { fg = "#7FB4CA", bg = colors.bg })
-- Specifically for LSP hover/signature help windows
hl(0, "LspFloatWinNormal", { fg = "#D27E99", bg = colors.bg })
hl(0, "LspFloatWinBorder", { fg = "#7FB4CA", bg = colors.bg })

-- Completion menu (if you use omnifunc or cmp without extra styling)
hl(0, "Pmenu",      { fg = "#D27E99", bg = "#1F1F28" })
hl(0, "PmenuSel",   { fg = "#1F1F28", bg = "#7FB4CA" })

hl(0, "markdownH1", { fg = colors.orange })
hl(0, "markdownH2", { fg = colors.pink })
hl(0, "markdownH3", { fg = colors.green })
hl(0, "markdownH4", { fg = colors.blue })
hl(0, "markdownH5", { fg = colors.red })
hl(0, "markdownH6", { fg = colors.cyan })
hl(0, "Todo", { fg = colors.bg, bg = colors.purple })

local groups_to_neutralize = {
  "Function", "Identifier", "Statement", "Type", "PreProc",
  "Constant", "Special", "Operator", "Label", "Repeat", "Conditional",
  "Structure", "Include", "Define", "Delimiter"
}

for _, group in ipairs(groups_to_neutralize) do
  vim.api.nvim_set_hl(0, group, { link = "Normal" })
end
