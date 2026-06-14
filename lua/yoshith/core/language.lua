local M = {}

M._toolchains = {}

function M.setup(toolchains)
    M._toolchains = toolchains
end

function M.init_conform()
    local conform = require("conform")
    local by_ft = {}
    for lang, spec in pairs(M._toolchains) do
        if spec.formatters then
            by_ft[lang] = spec.formatters
        end
    end

    conform.formatters.isort = {
        inherit = true,
        args = { "--profile", "black", "-" },
    }

    conform.setup({
        formatters_by_ft = by_ft,
        format_on_save = {
            timeout_ms = 2000,
            lsp_fallback = false,
        },
    })
end

function M.init_mason()
    local exclude_from_mason = {
        gofmt = true,
        rustfmt = true,
    }

    local ensure = {}
    for lang, spec in pairs(M._toolchains) do
        if type(spec.lsp) == "string" then
            table.insert(ensure, spec.lsp)
        end
        if type(spec.lsp) == "table" and spec.lsp.name then
            table.insert(ensure, spec.lsp.name)
        end
        if spec.formatters then
            for _, f in ipairs(spec.formatters) do
                if not exclude_from_mason[f] then
                    table.insert(ensure, f)
                end
            end
        end
        if spec.tools then
            for _, t in ipairs(spec.tools) do
                if not exclude_from_mason[t] then
                    table.insert(ensure, t)
                end
            end
        end
    end

    require("mason-tool-installer").setup({
        ensure_installed = ensure
    })
end

function M.init_lsp()
    local border = "rounded"
    local has_v012 = vim.fn.has("nvim-0.12") == 1

    -- Enhanced diagnostic display (0.11/0.12)
    vim.diagnostic.config({
        virtual_text = {
            prefix = "●",
            format = function(diag)
                return string.format("[%s] %s", diag.code or "E", diag.message)
            end
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_lines = has_v012 and { current_line = true } or false,
        float = {
            border = border,
            source = true,
            max_width = 60,
            prefix = has_v012 and function(diag, i, total)
                local icons = {
                    [vim.diagnostic.severity.ERROR] = "● ",
                    [vim.diagnostic.severity.WARN]  = "● ",
                    [vim.diagnostic.severity.HINT]  = "◆ ",
                    [vim.diagnostic.severity.INFO]  = "◆ ",
                }
                local hls = {
                    [vim.diagnostic.severity.ERROR] = "DiagnosticError",
                    [vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
                    [vim.diagnostic.severity.HINT]  = "DiagnosticHint",
                    [vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
                }
                return (icons[diag.severity] or "● "), (hls[diag.severity] or "DiagnosticInfo")
            end or nil,
        },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("yoshith_lsp_attach", { clear = true }),
        callback = function(event)
            local bufnr  = event.buf
            local client = vim.lsp.get_client_by_id(event.data.client_id)

            -- Disable semantic tokens (Treesitter handles highlighting)
            if client then
                client.server_capabilities.semanticTokensProvider = nil
            end

            -- Pyright-specific noise suppression (structural filter like old clangd pattern)
            if client and client.name == "pyright" then
                local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
                vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                    if result and result.diagnostics then
                        result.diagnostics = vim.tbl_filter(function(d)
                            local msg = d.message or ""
                            if msg:match("reportMissingImports") or msg:match("reportMissingModuleSource") then
                                return false
                            end
                            return true
                        end, result.diagnostics)
                    end
                    return orig_handler(err, result, ctx, config)
                end
            end

            -- LSP keymaps (buffer scoped)
            local m = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
            end
            m("gd", vim.lsp.buf.definition, "Go to definition")
            m("gD", vim.lsp.buf.declaration, "Go to declaration")
            m("gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementations (Telescope)")
            m("gt", "<cmd>Telescope lsp_type_definitions<cr>", "Type definitions (Telescope)")
            m("gR", "<cmd>Telescope lsp_references<cr>", "References (Telescope)")
            m("K", function() vim.lsp.buf.hover({ border = border }) end, "Hover docs")
            m("<C-s>", function() vim.lsp.buf.signature_help({ border = border }) end, "Signature help")
            m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
            m("<leader>ca", vim.lsp.buf.code_action, "Code action")
            m("<leader>D", vim.lsp.buf.type_definition, "Type definition")
            m("<leader>l", vim.diagnostic.open_float, "Show diagnostics (line)")
            m("[d", function() vim.diagnostic.jump({ count = -1, float = { border = border } }) end, "Prev diagnostic")
            m("]d", function() vim.diagnostic.jump({ count = 1, float = { border = border } }) end, "Next diagnostic")
            m("<leader>lf", function() require("conform").format({ async = true, lsp_fallback = true }) end, "Format file")
            m("<leader>la", vim.diagnostic.setloclist, "Show all diagnostics")
            m("<leader>ci", "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls (Telescope)")
            m("<leader>co", "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls (Telescope)")

            -- Confirm completion with CR (blink handles most; fallback for native pum)
            vim.keymap.set("i", "<CR>", function()
                if vim.fn.pumvisible() == 1 then
                    return "<C-y>"
                else
                    return "<CR>"
                end
            end, { buffer = bufnr, expr = true, desc = "Confirm completion or Enter" })
        end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local enable_list = {}
    for lang, spec in pairs(M._toolchains) do
        if spec.lsp then
            local lsp_name = type(spec.lsp) == "string" and spec.lsp or spec.lsp.name
            local lsp_opts = { capabilities = capabilities }
            if type(spec.lsp) == "table" and spec.lsp.settings then
                lsp_opts.settings = spec.lsp.settings
            end

            vim.lsp.config(lsp_name, lsp_opts)
            table.insert(enable_list, lsp_name)
        end
    end

    if #enable_list > 0 then
        vim.lsp.enable(enable_list)
    end
end

return M
