return {
    "saghen/blink.cmp",
    -- Use a release tag so lazy downloads pre-built native fuzzy (the "blink.lib" part)
    -- for common platforms. This avoids needing a separate saghen/blink.lib dep
    -- or manual cargo build in most cases (including many Windows setups).
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "default",
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
        },
        sources = {
            default = { "lsp", "snippets", "path", "buffer" },
            -- Order defines priority (LSP first per CONTEXT)
        },
        completion = {
            list = { selection = { preselect = true, auto_insert = true } },
        },
    },
    -- Uncomment ONLY if you still get "blink.lib not found" after :Lazy sync + restart.
    -- Requires Rust (scoop install rust). Then run :Lazy build blink.cmp
    -- build = "cargo build --release",
}
