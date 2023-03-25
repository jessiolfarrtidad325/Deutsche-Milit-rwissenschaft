--[[
    Use your proper mobile keyboard as a keyboard for keybinds. ex: GBoard, Unexpected Keyboard, etc.

    Credits:
    - BabyHamsta: CoreGui Bypasses (GetFocusedTextbox, super important to spoof): https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua
    - ScriptUNC.org: Support for some functions and mainly their documentation

    Supported for:
    - Fluxus-Android: Full
    - Scriptware-IOS: Should work
    - Unknown: depends wether they actually have atleast some exploit functions
    made by pengwin, under CC/BY License
]]

pcall(function()
    shared.mobKeyboard.cleanup()
end)

local warning = {}

local msg = messagebox or function(...)
    local t = {...}
    warn(t[2] or t[1])
end

local request = request or (syn and syn.request) or http_request or (http and http.request) or function(a)
    if not warning["requestWarn"] then
        warning["requestWarn"] = true
        msg(
            "warning",
            "GET only. missing request func or UNC support"
        )
    end
    
    local suc, req = pcall(function()
        return game:HttpGet(a.Url) -- no header setting sorry,
    end)

    if suc and res ~= nil then
        return {
            Body = res,
            StatusCode = 200,
            StatusMessage = "HTTP/1.1 200 OK",
            Success = true,
            Headers = {}
        }
    else
        if not warning["requestError"] then
            warning["requestError"] = true
            msg(
                "warning",
                "cant fetch. unable to access internet via executor"
            )
        end
        return {
            StatusCode = 400,
            StatusMessage = "Bad Request",
            Success = false,
        }
    end
end

local loadstring = loadstring or function() -- too lazy to add custom luau loadstring module
    if not warning["loadstringError"] then
        warning["loadstringError"] = true
        msg(
            "warning",
            "cant loadstring. no loadstring function"
        )
    end
    -- error("No loadstring in exploit..")
end

-- special thanks to babyhamsta for both of these
loadstring(request({
    Url = "https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/CloneRef.lua",
    Method = "GET"
}).Body)()
loadstring(request({
    Url = "https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/Bypasses.lua",
    Method = "GET"
}).Body)()

local yeat = {
    bigmoney = math.huge,
    create = Instance.new
} or math

local virInput = game:GetService("VirtualInputManager")
local guiServ = game:GetService("GuiService")
local protect_gui = (syn and syn.protect_gui) or function() end
local asset = getcustomasset or (syn and syn.getcustomasset) or function()
    return "rbxassetid://0" -- do nothing :giggle:
end

local hooks = {}
local bind = function(event, func)
    local hook = hooks[httpServ:GenerateGUID(false)]
    hook = event:Connect(func)
    return hook
end

local gethui = gethui or nil
local core = yeat.create("ScreenGui")

if gethui then
    core.Parent = gethui()
end
core.Parent = cloneref(game:GetService("CoreGui"))
core.ResetOnSpawn = false
core.IgnoreGuiInset = true
core.DisplayOrder = yeat.bigmoney
core.OnTopOfCoreBlur = true

local isGUIOpen = false
local btn = yeat.create("ImageButton", core)
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.Size = UDim2.new(.1, 0, .1, 0)
btn.AnchorPoint = Vector2.new(.5, .5)
btn.Position = UDim2.new(.9, 0, .4, 0)

bind(guiServ.MenuOpened, function()
    isGUIOpen = true
    btn.Visible = not isGUIOpen
end)
bind(guiServ.MenuClosed, function()
    isGUIOpen = false
    btn.Visible = not isGUIOpen
end)

Instance.new("UIAspectRatioConstraint", btn)
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

btn.Image = asset(request({
    Url = "https://www.iconpacks.net/icons/1/free-keyboard-icon-1425-thumb.png",
    Method = "GET"
}).Body)
btn.ScaleType = Enum.ScaleType.Fit
btn.ResampleMode = Enum.ResamplerMode.Pixelated

local txtBox
local registerKey = function(k)
    virInput:SendKeyEvent(false, k, false, nil)
end
local checkKey = function(t)
    local keyCodes = Enum.KeyCodes:GetEnumItems()
    local selkey

    for _, key in next, keyCodes do
        if string.lower(key.Name) == t then
            selkey = key
        end
    end

    return (selkey)
end
local activated
local deactivateKeyboard = function()
    activated = false
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    if txtBox then
        txtBox:ReleaseFocus()
        txtBox:Destroy()
    end
end
local activateKeyboard = function()
    if isGUIOpen or activated then return end
    activated = true
    btn.BackgroundColor3 = Color3.fromRGB(2, 74, 191)

    txtBox = yeat.create("TextBox", core)
    txtBox.AnchorPoint = Vector2.new(0, .5)
    txtBox.Position = UDim2.new(0, 0, .5, 0)
    txtBox.Size = UDim2.new(1, 0, .1, 0)
    txtBox.TextScaled = true
    txtBox:CaptureFocus()
    
    txtBox.FocusLost:Connect(function()
        deactivateKeyboard()
    end)

    txtBox:GetPropertyChangedSignal("Text"):Connect(function()
        local str = txtBox.Text
        if string.sub(str, -1, -1) == " " then
            str = string.gsub(str, " ", "")
            str = string.lower(str)
            local keycode = checkKey(str)
            if keycode then
                registerKey(keycode)
                deactivateKeyboard()
            end
        end
    end)
end

btn.MouseButton1Click:Connect(activateKeyboard)

shared.mobKeyboard = {}
shared.mobKeyboard.cleanup = function()
    for _, hook in next, hooks do
        hook:Disconnect()
    end
    core:Destroy()
    shared.mobKeyboard = nil
end