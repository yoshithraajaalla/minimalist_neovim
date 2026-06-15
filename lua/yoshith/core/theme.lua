-- core/theme.lua
-- Exact implementation per CONTEXT.md reference (adapted for yoshith namespace + koda adapter).
local M = {}

local SCHEMES = { "koda-dark", "koda-light" }
local DEFAULT = "koda-dark"
local STATE_FILE = vim.fn.stdpath("state") .. "/theme.txt"

M._timer = nil
M._os_registry_theme = nil

local function persist(name)
    vim.fn.mkdir(vim.fn.fnamemodify(STATE_FILE, ":h"), "p")
    vim.fn.writefile({ name }, STATE_FILE)
end

local function read_persisted()
    if vim.fn.filereadable(STATE_FILE) == 0 then return nil end
    return vim.fn.readfile(STATE_FILE)[1]
end

local function index_of(name)
    for i, t in ipairs(SCHEMES) do
        if t == name then return i end
    end
end

local function apply_transparency()
    vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC",    { bg = "none" })
end

local function setup_koda(name)
    local variant = "dark"
    local colors = {}

    if name == "koda-light" then
        variant = "light"
    else
        colors = {
            border = "#eeeeee",
            emphasis = "#eeeeee",
            func = "#eeeeee",
            string = "#eeeeee",
            char = "#eeeeee",
            special = "#eeeeee",
        }
    end

    local ok, koda = pcall(require, "koda")
    if ok and koda.setup then
        koda.setup({
            variant = variant,
            colors = colors,
        })
    end
end

local function apply(name, opts)
    opts = opts or {}
    if not index_of(name) then
        vim.notify(("Unknown theme: %s"):format(name), vim.log.levels.ERROR)
        return false
    end
    setup_koda(name)  -- configure koda variant before loading
    local ok, err = pcall(vim.cmd.colorscheme, name)
    if not ok then
        vim.notify(("Failed to load %s: %s"):format(name, err), vim.log.levels.ERROR)
        return false
    end
    apply_transparency()
    if name == "koda-light" then
        vim.api.nvim_set_hl(0, "Visual", { bg = "#DBDBDB" })
    end
    if opts.persist ~= false then persist(name) end
    if opts.notify then vim.notify(("Theme: %s"):format(name)) end
    return true
end

local function get_cached_theme()
    local cache_file = vim.fn.stdpath("data") .. "/os_theme_cache.txt"
    local f = io.open(cache_file, "r")
    if f then
        local theme = f:read("*a"):match("^%s*(.-)%s*$")
        f:close()
        if theme == "light" or theme == "dark" then
            return theme
        end
    end
    return nil
end

local function save_cached_theme(theme)
    local cache_file = vim.fn.stdpath("data") .. "/os_theme_cache.txt"
    local f = io.open(cache_file, "w")
    if f then
        f:write(theme)
        f:close()
    end
end

local function handle_theme_change(os_theme)
    if M._os_registry_theme == nil then
        M._os_registry_theme = os_theme
        save_cached_theme(os_theme)
        -- If the startup theme differs from current OS setting, update it
        local target = os_theme == "light" and "koda-light" or "koda-dark"
        if vim.g.colors_name ~= target then
            apply(target)
        end
        return
    end

    if os_theme ~= M._os_registry_theme then
        M._os_registry_theme = os_theme
        save_cached_theme(os_theme)
        local target = os_theme == "light" and "koda-light" or "koda-dark"
        apply(target)
    end
end

local function check_os_theme_async()
    local env = require("yoshith.core.env")
    if env.is_windows() then
        vim.system({
            'C:\\Windows\\System32\\reg.exe', 'query',
            'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize',
            '/v', 'AppsUseLightTheme'
        }, { text = true }, function(obj)
            if obj.code == 0 then
                local is_light = obj.stdout:match("REG_DWORD%s+0x1") ~= nil
                local os_theme = is_light and "light" or "dark"
                vim.schedule(function()
                    handle_theme_change(os_theme)
                end)
            end
        end)
    elseif env.is_mac() then
        vim.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' }, { text = true }, function(obj)
            local os_theme = (obj.code == 0 and obj.stdout:match("Dark") ~= nil) and "dark" or "light"
            vim.schedule(function()
                handle_theme_change(os_theme)
            end)
        end)
    elseif env.is_linux() then
        vim.system({ 'gsettings', 'get', 'org.gnome.desktop.interface', 'color-scheme' }, { text = true }, function(obj)
            if obj.code == 0 then
                local scheme = obj.stdout:match("['\"]?(.-)['\"]?%s*$")
                local os_theme = (scheme == "prefer-light" or scheme == "default") and "light" or "dark"
                vim.schedule(function()
                    handle_theme_change(os_theme)
                end)
            else
                vim.system({
                    'dbus-send', '--print-reply', '--dest=org.freedesktop.portal.Desktop',
                    '/org/freedesktop/portal/desktop',
                    'org.freedesktop.portal.Settings.Read',
                    'string:org.freedesktop.appearance', 'string:color-scheme'
                }, { text = true }, function(dbus_obj)
                    if dbus_obj.code == 0 then
                        local is_light = dbus_obj.stdout:match("uint32%s+2") ~= nil
                        local dbus_theme = is_light and "light" or "dark"
                        vim.schedule(function()
                            handle_theme_change(dbus_theme)
                        end)
                    end
                end)
            end
        end)
    end
end

function M.set(name, opts) return apply(name, opts) end

function M.cycle(step)
    step = step or 1
    local idx = index_of(vim.g.colors_name) or index_of(DEFAULT) or 1
    return apply(SCHEMES[((idx - 1 + step) % #SCHEMES) + 1], { notify = true })
end

function M.select()
    vim.ui.select(SCHEMES, {
        prompt = "Select theme",
        format_item = function(item)
            return item == vim.g.colors_name and item .. " (current)" or item
        end,
    }, function(choice)
        if choice then apply(choice, { notify = true }) end
    end)
end

function M.setup(opts)
    opts = opts or {}
    local sync_with_os = opts.sync_with_os
    if sync_with_os == nil then
        sync_with_os = true
    end

    local name
    if sync_with_os then
        local cached = get_cached_theme()
        if cached then
            name = cached == "light" and "koda-light" or "koda-dark"
        else
            name = DEFAULT
        end
    else
        name = read_persisted() or DEFAULT
    end

    if not apply(name, { persist = false }) then
        if name ~= DEFAULT then apply(DEFAULT) end
    end

    if sync_with_os then
        check_os_theme_async()
        M._timer = (vim.uv or vim.loop).new_timer()
        M._timer:start(3000, 3000, check_os_theme_async)
    end

    vim.api.nvim_create_user_command("Theme", function(o)
        if o.args == "" then M.select() else M.set(o.args, { notify = true }) end
    end, {
        nargs = "?",
        complete = function(lead)
            return vim.tbl_filter(function(t) return t:find(lead, 1, true) == 1 end, SCHEMES)
        end,
    })
    vim.api.nvim_create_user_command("ThemeNext", function() M.cycle(1) end, {})
    vim.api.nvim_create_user_command("ThemePrev", function() M.cycle(-1) end, {})
end

return M
