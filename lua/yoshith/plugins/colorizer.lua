return {
    "catgoose/nvim-colorizer.lua",
    enabled = function()
        return vim.g.yoshith_enable_colorizer == true
    end,
    event = "BufReadPre",
    opts = {},
}