local M = {}

function M.setup()
    local has_v012 = vim.fn.has("nvim-0.12") == 1

    local keymaps = {
        -- Window & Buffer Navigation (default nvim buffers + Harpoon; no bufferline)
        { mode = "n", lhs = "<C-h>", rhs = "<C-w>h", desc = "Window ←" },
        { mode = "n", lhs = "<C-l>", rhs = "<C-w>l", desc = "Window →" },
        { mode = "n", lhs = "<C-j>", rhs = "<C-w>j", desc = "Window ↓" },
        { mode = "n", lhs = "<C-k>", rhs = "<C-w>k", desc = "Window ↑" },
        { mode = "n", lhs = "<C-Up>", rhs = "<cmd>resize +2<cr>", desc = "Resize ↑" },
        { mode = "n", lhs = "<C-Down>", rhs = "<cmd>resize -2<cr>", desc = "Resize ↓" },
        { mode = "n", lhs = "<C-Left>", rhs = "<cmd>vertical resize -2<cr>", desc = "Resize ←" },
        { mode = "n", lhs = "<C-Right>", rhs = "<cmd>vertical resize +2<cr>", desc = "Resize →" },
        { mode = "n", lhs = "<S-l>", rhs = "<cmd>bnext<cr>", desc = "Next buffer (default)" },
        { mode = "n", lhs = "<S-h>", rhs = "<cmd>bprev<cr>", desc = "Prev buffer (default)" },
        { mode = "n", lhs = "<leader>bd", rhs = "<cmd>bdelete<cr>", desc = "Delete buffer" },

        -- Editing & Config (CONTEXT + practical)
        { mode = "n", lhs = "<Esc>", rhs = "<cmd>nohlsearch<cr>", desc = "Clear highlights" },
        { mode = "n", lhs = "<leader>w", rhs = function()
            require("conform").format({ async = true, lsp_fallback = true }, function() vim.cmd("w") end)
        end, desc = "Format and save (easier write)" },
        { mode = "n", lhs = "<leader>W", rhs = "<cmd>w<cr>", desc = "Write / Save only (no format)" },
        { mode = "n", lhs = "<leader>q", rhs = "<cmd>q<cr>", desc = "Quit" },
        { mode = "n", lhs = "<leader>Q", rhs = "<cmd>q!<cr>", desc = "Force Quit" },
        { mode = "n", lhs = "<leader>rc", rhs = function() vim.cmd("e " .. vim.fn.stdpath("config") .. "/init.lua") end, desc = "Edit config" },
        { mode = "n", lhs = "<leader>/", rhs = "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search current buffer" },
        { mode = "n", lhs = "<leader>ra", rhs = "<cmd>e#<cr>", desc = "Toggle to alternate file" },
        { mode = "n", lhs = "<leader>cc", rhs = "<cmd>%yank<cr>", desc = "Copy entire file" },
        { mode = "n", lhs = "<leader>s", rhs = "<cmd>normal! ggVG<cr>", desc = "Select entire file" },

        -- Visual Mode Enhancements (CONTEXT)
        { mode = "v", lhs = "<", rhs = "<gv", desc = "Indent left" },
        { mode = "v", lhs = ">", rhs = ">gv", desc = "Indent right" },
        { mode = "v", lhs = "J", rhs = ":m '>+1<CR>gv=gv", desc = "Move selection down" },
        { mode = "v", lhs = "K", rhs = ":m '<-2<CR>gv=gv", desc = "Move selection up" },

        -- Centred Jumps (CONTEXT)
        { mode = "n", lhs = "<C-d>", rhs = "<C-d>zz", desc = "Scroll ↓ (centred)" },
        { mode = "n", lhs = "<C-u>", rhs = "<C-u>zz", desc = "Scroll ↑ (centred)" },
        { mode = "n", lhs = "n", rhs = "nzzzv", desc = "Next match (centred)" },
        { mode = "n", lhs = "N", rhs = "Nzzzv", desc = "Prev match (centred)" },

        -- Cross-Module Toggles
        { mode = { "n", "t" }, lhs = "<leader>t", rhs = function() require("yoshith.tools.terminal").toggle() end, desc = "Toggle floating terminal" },
        { mode = "t", lhs = "<Esc>", rhs = "<C-\\><C-n>", desc = "Exit terminal mode" },
        { mode = "n", lhs = "<leader>T", rhs = function() require("yoshith.core.theme").cycle(1) end, desc = "Cycle theme (or :ThemeNext)" },

        -- Telescope Bindings
        { mode = "n", lhs = "<leader>ff", rhs = "<cmd>Telescope find_files<cr>", desc = "Find files (Telescope)" },
        { mode = "n", lhs = "<leader>fg", rhs = "<cmd>Telescope live_grep<cr>", desc = "Live grep (Telescope)" },
        { mode = "n", lhs = "<leader>fb", rhs = "<cmd>Telescope buffers<cr>", desc = "Buffers (Telescope)" },
        { mode = "n", lhs = "<leader>fr", rhs = "<cmd>Telescope oldfiles<cr>", desc = "Recent files (Telescope)" },
        { mode = "n", lhs = "<leader>fh", rhs = "<cmd>Telescope help_tags<cr>", desc = "Help tags (Telescope)" },

        -- Harpoon Bindings
        { mode = "n", lhs = "<leader>a", rhs = function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
        { mode = "n", lhs = "<C-e>", rhs = function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: menu" },
        { mode = "n", lhs = "<leader>1", rhs = function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
        { mode = "n", lhs = "<leader>2", rhs = function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
        { mode = "n", lhs = "<leader>3", rhs = function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
        { mode = "n", lhs = "<leader>4", rhs = function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
    }

    if has_v012 then
        table.insert(keymaps, { mode = "n", lhs = "<leader>R", rhs = "<cmd>restart<cr>", desc = "Restart Neovim" })
    end

    local delete_maps = {
        ["d"] = "Delete without yank", ["dd"] = "Delete line without yank", ["D"] = "Delete to end without yank",
        ["dw"] = "Delete word without yank", ["db"] = "Delete word back without yank", ["de"] = "Delete to end of word without yank",
        ["d$"] = "Delete to end of line without yank", ["d0"] = "Delete to start of line without yank", ["d^"] = "Delete to first non-blank without yank",
        ["diw"] = "Delete inner word without yank", ["diW"] = "Delete inner WORD without yank", ['di"'] = "Delete inside quotes without yank",
        ["di'"] = "Delete inside single quotes without yank", ["di("] = "Delete inside parentheses without yank", ["di)"] = "Delete inside parentheses without yank",
        ["dib"] = "Delete inside block without yank", ["di["] = "Delete inside brackets without yank", ["di]"] = "Delete inside brackets without yank",
        ["di{"] = "Delete inside braces without yank", ["di}"] = "Delete inside braces without yank", ["diB"] = "Delete inside Block without yank",
        ["di<"] = "Delete inside angle brackets without yank", ["di>"] = "Delete inside angle brackets without yank", ["dit"] = "Delete inside tag without yank",
        ["dip"] = "Delete inside paragraph without yank", ["daw"] = "Delete around word without yank", ["daW"] = "Delete around WORD without yank",
        ['da"'] = "Delete around quotes without yank", ["da'"] = "Delete around single quotes without yank", ["da("] = "Delete around parentheses without yank",
        ["da)"] = "Delete around parentheses without yank", ["dab"] = "Delete around block without yank", ["da["] = "Delete around brackets without yank",
        ["da]"] = "Delete around brackets without yank", ["da{"] = "Delete around braces without yank", ["da}"] = "Delete around braces without yank",
        ["daB"] = "Delete around Block without yank", ["da<"] = "Delete around angle brackets without yank", ["da>"] = "Delete around angle brackets without yank",
        ["dat"] = "Delete around tag without yank", ["dap"] = "Delete around paragraph without yank",
    }

    for key, description in pairs(delete_maps) do
        table.insert(keymaps, { mode = "n", lhs = key, rhs = '"_' .. key, desc = description })
    end

    -- Explicit yanks (CONTEXT spirit)
    table.insert(keymaps, { mode = {"n", "v"}, lhs = "<leader>d", rhs = "d", desc = "Cut (delete with yank)" })
    table.insert(keymaps, { mode = "n", lhs = "<leader>dd", rhs = "dd", desc = "Cut line" })
    table.insert(keymaps, { mode = "n", lhs = "<leader>D", rhs = "D", desc = "Cut to end of line" })

    -- Paste without yank
    table.insert(keymaps, { mode = "x", lhs = "<leader>p", rhs = [["_dP]], desc = "Paste without yank" })

    -- Register all keymaps (pure only)
    for _, map in ipairs(keymaps) do
        vim.keymap.set(map.mode, map.lhs, map.rhs, { desc = map.desc, silent = true })
    end
end

return M
