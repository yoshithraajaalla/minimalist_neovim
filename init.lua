-- ═════════════════════════════════════════════════════════════════════════════
-- YOSHITH NEOVIM CONFIG — CONTEXT.md COMPLIANT OVERHAUL
-- Windows-first (pwsh, gcc) with zero-fuss cross-platform support (bash/zsh, macOS/Linux)
-- ═════════════════════════════════════════════════════════════════════════════

-- 0. DEFENSIVE HOUSEKEEPING (per CONTEXT.md — first thing)
-- Truncate huge LSP logs, set ERROR level only.
local lsp_log = vim.lsp.log.get_filename()
local max_lsp_log_size = 10 * 1024 * 1024
local stat = vim.uv.fs_stat(lsp_log)
if stat and stat.size > max_lsp_log_size then
    local fd = vim.uv.fs_open(lsp_log, "w", 420)
    if fd then vim.uv.fs_close(fd) end
end
vim.lsp.log.set_level(vim.log.levels.ERROR)

-- 0.1 Windows native + providers (early)
vim.env.CC = "gcc"
vim.env.CXX = "g++"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

require("yoshith.core.env").apply_os_quirks()

-- 0.5 Version detection (kept for 0.11/0.12 compat)
local has_v012 = vim.fn.has("nvim-0.12") == 1

-- 1. LEADER & NETRW (disable netrw early)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Optional plugins (off by default; flip to true to enable)
vim.g.yoshith_enable_colorizer = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.shortmess:append("I")


-- 2. PURE OPTIONS (no plugins)
require("yoshith.core.options")

-- 3. LAZY BOOTSTRAP
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- 4. PLUGINS — one file / logical group under yoshith/plugins + yoshith/plugins/lsp
-- (import auto-discovers; see individual files for specs)
require("lazy").setup({
    { import = "yoshith.plugins" },
}, {
    ui               = { border = "rounded" },
    rocks            = { enabled = false },
    checker          = { enabled = false },
    change_detection = { notify = false },
    performance      = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } } },
})

-- 5. THEME (Koda only, exact CONTEXT implementation: persisted in state/, cycle, :Theme picker, transparency in apply())
require("yoshith.core.theme").setup({ sync_with_os = true })

-- 6. LANGUAGE / LSP / FORMAT (declarative deep module — Python first + min json/yaml per CONTEXT)
require("yoshith.core.language").setup({
    python = {
        lsp = { name = "pyright", settings = { python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true, useLibraryCodeForTypes = true } } } },
        formatters = { "black" },
        tools = { "isort" },
    },
    go = {
        lsp = { name = "gopls", settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } } },
        formatters = { "gofmt" },
    },
    lua = {
        lsp = { name = "lua_ls", settings = { Lua = { runtime = { version = "LuaJIT" }, workspace = { checkThirdParty = false, library = vim.api.nvim_list_runtime_paths() }, diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } } },
        formatters = { "stylua" },
    },
    json = {
        lsp = "jsonls",
        formatters = { "prettier" },
    },
    yaml = {
        lsp = "yamlls",
        formatters = { "prettier" },
    },
    rust = {
        lsp = "rust_analyzer",
    },
})

-- 7. DEEP / BESPOKE MODULES
-- Note: init_mason() is now called from inside the mason-tool-installer plugin's config
-- (see lua/yoshith/plugins/lsp/tool-installer.lua) so it runs after lazy loads it.
require("yoshith.tools.terminal").setup()
require("yoshith.core.keymaps").setup()

-- 8. AUTOCOMMANDS (ALL use explicit named augroups with clear=true)
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("yoshith_yank_highlight", { clear = true }),
    callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("yoshith_restore_cursor", { clear = true }),
    callback = function()
        local mark, lcount = vim.api.nvim_buf_get_mark(0, '"'), vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("yoshith_trim_trailing_ws", { clear = true }),
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("yoshith_go_tabs", { clear = true }),
    pattern = { "go" },
    callback = function()
        vim.bo.expandtab, vim.bo.tabstop, vim.bo.shiftwidth = false, 4, 4
    end,
})
