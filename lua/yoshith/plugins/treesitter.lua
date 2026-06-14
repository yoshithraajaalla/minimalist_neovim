return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- master frozen for 0.12+
    build = ":TSUpdate",
    lazy = false,
    config = function()
        local install_dir = vim.fn.stdpath("data") .. "/site"
        if not vim.tbl_contains(vim.opt.rtp:get(), install_dir) then
            vim.opt.rtp:prepend(install_dir)
        end

        local ok, ts = pcall(require, "nvim-treesitter")
        local compilers = require("yoshith.core.env").is_windows() and { "gcc" } or { "clang", "gcc" }

        if ok and ts.install then
            require("nvim-treesitter.install").compilers = compilers

            ts.install({
                "lua", "python", "go", "bash", "json", "yaml", "toml",
                "markdown", "markdown_inline", "dockerfile", "regex",
            })
        else
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "python", "go", "bash", "json", "yaml", "toml",
                    "markdown", "markdown_inline", "dockerfile", "regex",
                },
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
            })
        end
    end,
}
