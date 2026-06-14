local M = {}

local _is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local _is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
local _is_linux = not _is_windows and not _is_mac

local _has_pwsh = vim.fn.executable("pwsh") == 1
local _has_powershell = vim.fn.executable("powershell.exe") == 1
local _has_zsh = vim.fn.executable("zsh") == 1
local _has_bash = vim.fn.executable("bash") == 1

function M.is_windows()
    return _is_windows
end

function M.is_mac()
    return _is_mac
end

function M.is_linux()
    return _is_linux
end

function M.get_shell()
    if M.is_windows() then
        if _has_pwsh then return "pwsh.exe" end
        if _has_powershell then return "powershell.exe" end
        return "cmd.exe"
    end
    -- Unix / macOS / Linux: prefer zsh (macOS default), then bash, then current $SHELL, then sh
    if _has_zsh then return "zsh" end
    if _has_bash then return "bash" end
    local shell = vim.env.SHELL
    if shell and shell ~= "" then return shell end
    return "sh"
end

function M.apply_os_quirks()
    if M.is_windows() then
        vim.fn.setenv("SHELL", M.get_shell())
        vim.fn.setenv("TERM", "")
        -- Disable git operations that might invoke WSL
        vim.fn.setenv("GIT_TERMINAL_PROMPT", "0")
    end
    -- macOS/Linux: nothing special; native shells + TERM handled by terminal emulator
end

return M
