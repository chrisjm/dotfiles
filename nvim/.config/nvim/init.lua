-- Sensible defaults for occasional editing. No plugins.
-- EditorConfig support is built into Neovim and overrides indent per project.

local opt = vim.opt

-- Indentation
opt.expandtab = true -- spaces, not tabs
opt.tabstop = 4
opt.shiftwidth = 4 -- Python-friendly default; EditorConfig overrides
opt.softtabstop = 4
opt.smartindent = true

-- Interface
opt.number = true
opt.cursorline = true
opt.scrolloff = 5
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250
opt.background = "dark"

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Editing, clipboard, files
opt.wrap = false
opt.clipboard = "unnamedplus" -- yank to the system clipboard
opt.undofile = true -- persistent undo across sessions
opt.swapfile = false
opt.backup = false

-- Quality of life
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
