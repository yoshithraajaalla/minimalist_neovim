local M = {}

local _term_buf = nil
local _term_win = nil
local _shell = require("yoshith.core.env").get_shell()

function M.toggle()
    if _term_win and vim.api.nvim_win_is_valid(_term_win) then
        vim.api.nvim_win_hide(_term_win)
        _term_win = nil
        return
    end

    local cols, rows = vim.o.columns, vim.o.lines
    local width, height = math.floor(cols * 0.85), math.floor(rows * 0.80)
    local col, row = math.floor((cols - width) / 2), math.floor((rows - height) / 2)

    if not (_term_buf and vim.api.nvim_buf_is_valid(_term_buf)) then
        _term_buf = vim.api.nvim_create_buf(false, true)
    end

    _term_win = vim.api.nvim_open_win(_term_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = "  " .. _shell .. " ",
        title_pos = "center",
    })

    if vim.bo[_term_buf].buftype ~= "terminal" then
        vim.fn.jobstart(_shell, { term = true })
        vim.bo[_term_buf].buflisted = false
    end

    vim.cmd("startinsert")
end

function M.setup()
    -- Keymaps registered in core.keymaps or plugin specs
end

return M
