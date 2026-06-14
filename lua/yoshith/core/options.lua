-- options.lua: pure Vim settings only. No plugin configuration here.

local opt = vim.opt

-- Line numbers & Indentation
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Visuals
opt.wrap = false
opt.termguicolors = true -- true-colour support (required by themes)
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false -- lualine (or statusline) handles this
opt.pumheight = 10
opt.cmdheight = 1
opt.conceallevel = 0
opt.fileencoding = "utf-8"
opt.pumblend = 0 -- no opacity tint on popup menus
opt.winblend = 0 -- no opacity tint on floating windows

-- Scrolling & Splits
opt.scrolloff = 10 -- increased from 8 for more breathing room
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true

-- Search & Performance
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 300

-- Quality of life
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- sync with system clipboard
opt.undofile = true          -- persistent undo
opt.showmatch = true          -- Highlight matching brackets
opt.matchtime = 2
-- NOTE: opt.lazyredraw was removed in Neovim 0.10+ (causes errors on 0.12)
opt.synmaxcol = 300 -- Syntax cap for long lines
opt.completeopt = "menuone,noinsert,noselect,fuzzy,popup"
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.autochdir = false -- Keep original working dir
opt.selection = "exclusive"
opt.iskeyword:append("-")        -- Hyphens as word chars
