pcall(function() if typeof(getgenv)=="function" then getgenv().SolanaHubTier="Premium" end end)
if getgenv().solanahub_community_running then
    return
end

getgenv().solanahub_community_running = true
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
waxwritefile, waxreadfile = writefile, readfile
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
getconnections = missing("function", getconnections or get_signal_cons)

local S = setmetatable({}, {
    __index = function(t, k)
        local s = cloneref(game:GetService(k))
        t[k] = s
        return s
    end
})

local Players = S.Players
local Plr = Players.LocalPlayer
local PGui = cloneref(Plr:FindFirstChildWhichIsA("PlayerGui"))
local Lighting = game:GetService("Lighting")

local RS = S.ReplicatedStorage
local RunService = S.RunService
local Http = S.HttpService
local Gui = S.GuiService
local TP = S.TeleportService
local Tween = S.TweenService

local Marketplace = S.MarketplaceService

local UIS = S.UserInputService
local VIM = S.VirtualInputManager
local VU = S.VirtualUser

local RM = RS:WaitForChild("Remotes")
local RE = RS:WaitForChild("RemoteEvents")

local Env = {
    GameName = "Sailor Piece",
    Version = "1.6.9",
    InviteCode = "https://discord.gg/UgtRrcjxh3",
    Executor = (identifyexecutor and identifyexecutor() or "Unknown"),
    IsBadExec = false,
	Support = {
		Webhook = type(httprequest) == "function",
		Clipboard = type(everyClipboard) == "function",
		FileIO = (typeof(writefile) == "function" and typeof(isfile) == "function"),
		Connections = type(getconnections) == "function",
		FPS = (typeof(setfpscap) == "function"),
		Proximity = type(fireproximityprompt) == "function",
}
}

local success, info = pcall(Marketplace.GetProductInfo, Marketplace, game.PlaceId)
if success and info then
    Env.GameName = info.Name
end

local lowerExec = Env.Executor:lower()
local LimitedList = {"xeno"}

for _, name in ipairs(LimitedList) do
    if lowerExec:find(name) then
        Env.IsBadExec = true
        break
    end
end

Env.IsXeno = lowerExec:find("xeno") ~= nil
Env.IsDelta = lowerExec:find("delta") ~= nil

local GENV = (getgenv and getgenv()) or _G
if GENV.SolanaHub_Debug == nil then
    GENV.SolanaHub_Debug = true
end
local DEBUG_ENABLED = GENV.SolanaHub_Debug and true or false

-- ================================================================
-- [BRIDGE ADAPTER INJECTION START - ModernV2 Backend]
-- ================================================================
local _mvLib; do
    local ok, lib = pcall(function()
        local source = game:HttpGet("https://shinzux.vercel.app/files/ambaruto.txt")
        local fn, compileErr = loadstring(source)
        if not fn then error(compileErr) end
        return fn()
    end)
    if ok and lib then
        _mvLib = lib
    else
        warn("[SolanaHub] Vercel mirror failed, trying GitHub fallback:", lib)
        local fallbackOk, fallbackLib = pcall(function()
            local source = game:HttpGet("https://raw.githubusercontent.com/SolanaHubmy/ggsolana/refs/heads/main/SolanaHub-ModernV2.txt")
            local fn, compileErr = loadstring(source)
            if not fn then error(compileErr) end
            return fn()
        end)
        if fallbackOk and fallbackLib then
            _mvLib = fallbackLib
        else
            warn("[SolanaHub] ModernV2 UI gagal dimuat.")
            return
        end
    end
end
if not game:IsLoaded() then game.Loaded:Wait() end

_mvLib:AddTheme({
    Name = "Lumi Purple",
    Accent = Color3.fromRGB(220, 35, 55),
    Background = Color3.fromRGB(8, 8, 13),
    Surface = Color3.fromRGB(20, 22, 27),
    Outline = Color3.fromRGB(45, 48, 58),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(140, 140, 155),
    Button = Color3.fromRGB(220, 35, 55),
    Icon = Color3.fromRGB(255, 255, 255),
})

local _menuIconSP = _mvLib:CreateMenuIcon({
    Image = "rbxassetid://135199868370962", Size = 48,
    IconColor = Color3.fromRGB(255,255,255), BGColor = Color3.fromRGB(20,22,27),
    StrokeColor = Color3.fromRGB(220, 35, 55), StrokeThick = 1.5, Draggable = true,
})

local _spLocalPlayer = game:GetService("Players").LocalPlayer
local _mvWindow = _mvLib:Window({
    Title = "SolanaHub", Content = "Sailor Piece v1.6.9 | Dev: Opixx",
    Image = "135199868370962", Color = Color3.fromRGB(220, 35, 55),
    Uitransparent = 0.15, ShowUser = true, Search = true, ConfigEnabled = true,
    NotifyOnCallbackError = false, LoadingScreen = false, Enable3DRenderer = false,
    Keybind = "LeftAlt", Size = UDim2.fromOffset(540, 340),
    Config = {
        ConfigFolder = "SolanaHubSailorPiece", AutoSaveFile = "sailor-piece",
        AutoSave = true, AutoLoad = false, Overwrite = true,
        Format = "JSON", ShowAutoSaveToggle = true, TextGradient = true
    },
})
_mvWindow:AttachMenuIcon(_menuIconSP)
_mvWindow:SetAccount({ Username = _spLocalPlayer.DisplayName, Profile = _mvLib.UserProfile, Expires = "Never" })
_mvWindow:CreateHomeTab({
    Name = "Dashboard", Icon = "lucide:layout-dashboard",
    Content = "SolanaHub Sailor Piece Script | Dev: Opixx",
    ScriptIcon = "lucide:file-text",
    DiscordInvite = "https://discord.gg/UgtRrcjxh3",
    SupportedExecutors = {"Delta","Synapse X","Krnl","Codex","Arceus X"},
    UnsupportedExecutors = {"Roblox Studio"},
    Changelog = {
        {Title="SailorPiece v1.6.9", Date="v1.6.9", Description="Optimized Merchant auto-buy & timer sync, removed Artifact and Valentine tabs, and cleaned up rich text tags from pity & merchant labels."},
        {Title="SailorPiece v1.6.8", Date="v1.6.8", Description="Added new Questlines, decimal sliders, performance optimizations, and layout fixes."},
        {Title="SailorPiece v1.6.7", Date="v1.6.7", Description="Migrated to ModernV2 UI."},
    },
})

local function getRoundingFromIncrement(inc)
    if not inc or inc <= 0 then return 0 end
    local log10Val = math.log10(inc)
    if log10Val < 0 then
        return math.ceil(math.abs(log10Val))
    end
    return 0
end

local _tabboxIconMap = {
    -- Autofarm Tabbox
    Autofarm = "lucide:swords",
    Boss = "lucide:skull",
    Misc = "lucide:layers",
    ["Alt Account"] = "lucide:users",
    Config = "lucide:settings",
    ["Farm Settings"] = "lucide:settings",
    ["Sea Beast"] = "lucide:waves",

    -- MiscAuto / Skills / Combo / Haki Tabbox
    Haki = "lucide:shield",
    Skill = "lucide:zap",
    Combo = "lucide:flame",

    -- Switch Tabbox
    Title = "lucide:award",
    Rune = "lucide:sparkles",
    Build = "lucide:hammer",

    -- Rolling / Ascend / Trade / Info Tabbox
    Ascend = "lucide:trending-up",
    Rolls = "lucide:dices",
    Trade = "lucide:repeat",
    Information = "lucide:circle-info",

    -- Stats1 Tabbox
    Level = "lucide:activity",
    Gem = "lucide:gem",
    SkillTree = "lucide:git-fork",

    -- Enchant Tabbox
    Enchant = "lucide:sparkles",
    Passive = "lucide:star",

    -- Dungeon Tabbox
    Autojoin = "lucide:door-open",

    -- Waypoint / Teleport Tabbox
    Island = "lucide:map-pin",
    Quest = "lucide:scroll",

    -- NPCs Tabbox
    Moveset = "lucide:book-open",
    Mastery = "lucide:trophy",

    -- Merchant Tabbox
    Merchant = "lucide:shopping-bag",


    -- Misc1 Tabbox
    Chests = "lucide:box",
    Craft = "lucide:anvil",

    -- Puzzle Tabbox
    Puzzles = "lucide:puzzle",
    Questlines = "lucide:list-todo",
}

-- Shim: membuat ModernV2 section terlihat seperti VelarisUI section
-- sehingga wrapSection() di bawah berjalan tanpa perubahan
local function makeMvSecShim(mvSec)
    if not mvSec then
        local d = {}
        local noop = {Set=function()end,SetValues=function()end,Refresh=function()end,Update=function()end,SetChoices=function()end,SetVisible=function()end,SetTitle=function()end,SetText=function()end,SetContent=function()end}
        function d:AddToggle() return noop end
        function d:AddDropdown() return noop end
        function d:AddSlider() return noop end
        function d:AddInput() return noop end
        function d:AddParagraph() return noop end
        function d:AddButton() end
        function d:AddTabbox() return d end
        function d:AddTabBox() return d end
        return d
    end
    local shim = {}
    function shim:AddToggle(cfg)
        local flag = cfg.Flag or ("t"..tostring(math.random(1000,9999)))
        local el; pcall(function()
            el = mvSec:AddToggle({Name=cfg.Title or flag, Flag=flag, Default=cfg.Default or false, Locked=cfg.Locked, TextLocked=cfg.TextLocked, Callback=cfg.Callback})
        end)
        return {
            Set=function(s,v) if el and el.SetValue then pcall(el.SetValue,el,v) end end,
            SetVisible=function()end, SetTitle=function()end, SetText=function()end,
        }
    end
    function shim:AddDropdown(cfg)
        local flag = cfg.Flag or ("d"..tostring(math.random(1000,9999)))
        local el; pcall(function()
            if cfg.Stacked then
                local lbl = mvSec:AddLabel(cfg.Title or flag, true)
                lbl:SetStacked(true)
                el = lbl:AddDropdown({
                    Flag = flag, 
                    Values = cfg.Options or cfg.Values or {}, 
                    Default = cfg.Default, 
                    Search = cfg.Search or cfg.Searchable or false, 
                    Multi = cfg.Multi or cfg.Multiple or false,
                    DropdownPosition = "Center",
                    Locked = cfg.Locked,
                    TextLocked = cfg.TextLocked,
                    Callback = cfg.Callback
                })
            else
                el = mvSec:AddDropdown({
                    Name = cfg.Title or flag, 
                    Flag = flag, 
                    Values = cfg.Options or cfg.Values or {}, 
                    Default = cfg.Default, 
                    Search = cfg.Search or cfg.Searchable or false, 
                    Multi = cfg.Multi or cfg.Multiple or false,
                    DropdownPosition = "Center",
                    Locked = cfg.Locked,
                    TextLocked = cfg.TextLocked,
                    Callback = cfg.Callback
                })
            end
        end)
        return {
            Set=function(s,v) if el and el.SetValue then pcall(el.SetValue,el,v) end end,
            SetValues=function(s,list) if el then pcall(function() if el.SetValues then el:SetValues(list) elseif el.Refresh then el:Refresh(list) end end) end end,
            Refresh=function(s,list) if el then pcall(function() if el.Refresh then el:Refresh(list) elseif el.SetValues then el:SetValues(list) end end) end end,
            Update=function(s,list) if el and el.SetValues then pcall(el.SetValues,el,list) end end,
            SetChoices=function(s,list) if el and el.SetValues then pcall(el.SetValues,el,list) end end,
            SetVisible=function()end, SetTitle=function()end, SetText=function()end,
        }
    end
    function shim:AddSlider(cfg)
        local flag = cfg.Flag or ("s"..tostring(math.random(1000,9999)))
        local el; pcall(function()
            local increment = cfg.Increment
            local rounding = cfg.Rounding and tonumber(cfg.Rounding)
            if rounding == nil then
                if increment then
                    rounding = getRoundingFromIncrement(increment)
                else
                    local maxVal = tonumber(cfg.Max) or 100
                    if maxVal <= 5 then
                        increment = 0.01
                        rounding = 2
                    elseif maxVal <= 50 then
                        increment = 0.1
                        rounding = 1
                    else
                        increment = 1
                        rounding = 0
                    end
                end
            else
                if rounding > 0 then
                    increment = 10 ^ (-rounding)
                else
                    increment = 1
                end
            end
            if cfg.Stacked then
                local lbl = mvSec:AddLabel(cfg.Title or flag, true)
                lbl:SetStacked(true)
                el = lbl:AddSlider({Flag=flag, Min=cfg.Min or 0, Max=cfg.Max or 100, Default=cfg.Default, Increment=increment, Rounding=rounding, Callback=cfg.Callback})
            else
                el = mvSec:AddSlider({Name=cfg.Title or flag, Flag=flag, Min=cfg.Min or 0, Max=cfg.Max or 100, Default=cfg.Default, Increment=increment, Rounding=rounding, Callback=cfg.Callback})
            end
        end)
        return {
            Set=function(s,v) if el and el.SetValue then pcall(el.SetValue,el,v) end end,
            SetVisible=function()end, SetTitle=function()end, SetText=function()end,
        }
    end
    function shim:AddInput(cfg)
        local flag = cfg.Flag or ("i"..tostring(math.random(1000,9999)))
        local el; pcall(function()
            -- AddTextInput bukan AddInput karena label handle tidak punya AddInput
            el = mvSec:AddTextInput({Name=cfg.Title or cfg.Name or flag, Flag=flag,
                Default="", PlaceholderText=cfg.Placeholder or cfg.PlaceholderText or "...",
                Callback=cfg.Callback})
        end)
        return {
            Set=function(s,v) if el and el.SetValue then pcall(el.SetValue,el,v) end end,
            SetVisible=function()end, SetTitle=function()end, SetText=function()end,
        }
    end
    function shim:AddLabel(cfg, isMarkup)
        local text = type(cfg) == "table" and (cfg.Text or cfg.Title or cfg.Name or "") or tostring(cfg or "")
        local markup = (type(cfg) == "table" and cfg.Markup)
        if markup == nil then markup = true end
        local el
        pcall(function()
            if mvSec and mvSec.AddLabel then
                el = mvSec:AddLabel(text, markup)
            elseif mvSec and mvSec.AddParagraph then
                el = mvSec:AddParagraph({Name = text, Content = ""})
            end
        end)
        return {
            SetText = function(s, t)
                if el then
                    if el.SetText then pcall(el.SetText, el, t)
                    elseif el.SetContent then pcall(el.SetContent, el, t) end
                end
            end,
            SetContent = function(s, t)
                if el then
                    if el.SetContent then pcall(el.SetContent, el, t)
                    elseif el.SetText then pcall(el.SetText, el, t) end
                end
            end,
            SetVisible = function(s, vis)
                if el and el.SetVisible then pcall(el.SetVisible, el, vis) end
            end
        }
    end
    function shim:AddParagraph(cfg)
        cfg = cfg or {}
        local title = cfg.Title or cfg.Name or "Info"
        local content = cfg.Content or ""
        local el
        pcall(function()
            if mvSec and mvSec.AddParagraph then
                el = mvSec:AddParagraph({Name = title, Content = content})
            elseif mvSec and mvSec.AddLabel then
                local formattedText = string.format("<b>%s</b>\n%s", title, content)
                el = mvSec:AddLabel(formattedText, true)
            end
        end)
        return {
            SetContent = function(s, t)
                if el then
                    if el.SetContent then
                        pcall(el.SetContent, el, t)
                    elseif el.SetText then
                        pcall(el.SetText, el, string.format("<b>%s</b>\n%s", title, t))
                    end
                end
            end,
            SetText = function(s, t)
                if el then
                    if el.SetContent then
                        pcall(el.SetContent, el, t)
                    elseif el.SetText then
                        pcall(el.SetText, el, t)
                    end
                end
            end,
            SetVisible = function(s, vis)
                if el and el.SetVisible then
                    pcall(el.SetVisible, el, vis)
                end
            end,
        }
    end
    function shim:AddButton(cfg)
        local name = type(cfg)=="table" and (cfg.Title or cfg.Text or "") or tostring(cfg or "")
        local cb = type(cfg)=="table" and (cfg.Callback or cfg.Func) or nil
        local locked = type(cfg)=="table" and (cfg.Locked or false)
        local textLocked = type(cfg)=="table" and cfg.TextLocked or nil
        pcall(function()
            mvSec:AddButton({
                Name = name,
                Locked = locked,
                TextLocked = textLocked,
                Callback = function()
                    if locked and false --[[Unlocked]] then
                        Library:Notify("Premium Required 👑", "Fitur ini hanya untuk pengguna Key Premium!", 5)
                        return
                    end
                    if cb then cb() end
                end
            })
        end)
    end
    function shim:AddTabbox() return self end
    function shim:AddTabBox() return self end
    return shim
end

local Toggles = setmetatable({}, { 
    __index = function(t, k)
        local obj = {
            Value = false, 
            Callbacks = {},
            SetValue = function(self, v)
                if self.Value == v then return end
                self.Value = v
                for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
            end,
            OnChanged = function(self, cb) table.insert(self.Callbacks, cb) end,
            SetVisible = function() end,
            SetText = function() end,
        }
        rawset(t, k, obj)
        return obj
    end
})
local Options = setmetatable({}, { 
    __index = function(t, k)
        local obj = {
            Value = nil, 
            Callbacks = {},
            SetValue = function(self, v) 
                self.Value = v 
                for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
            end,
            SetValues = function() end,
            OnChanged = function(self, cb) table.insert(self.Callbacks, cb) end,
            SetVisible = function() end,
            SetText = function() end,
        }
        rawset(t, k, obj)
        return obj
    end
})

local Library = {
    Options = Options,
    Toggles = Toggles,
    Unloaded = false,
    ForceCheckbox = true,
    ShowToggleFrameInKeybinds = true,
    KeybindFrame = { Visible = false },
    ShowCustomCursor = false,
}

local _lastNotifyTime = 0
local _lastNotifyText = ""
function Library:Notify(text, time)
    local now = os.clock()
    -- Throttle: max 1 notif per 2s, skip duplicate text
    if text == _lastNotifyText or (now - _lastNotifyTime < 2) then return end
    _lastNotifyTime = now
    _lastNotifyText = text
    pcall(function() _mvWindow:Notify({ Title = "SolanaHub", Content = text, Icon = "lucide:bell", Duration = time or 2 }) end)
end

function Library:Unload()
    self.Unloaded = true
end

function Library:SetNotifySide(side)
    self.NotifySide = side
end

local function DebugLog(tag, message, alsoNotify)
    if not DEBUG_ENABLED then return end
    local msg = ("[NexDebug][%s] %s"):format(tostring(tag or "GEN"), tostring(message or ""))
    print(msg)
    if alsoNotify then
        Library:Notify(msg, 4)
    end
end

local function SetDebugEnabled(state)
    DEBUG_ENABLED = state and true or false
    GENV.SolanaHub_Debug = DEBUG_ENABLED
    local statusText = DEBUG_ENABLED and "ON" or "OFF"
    print("[NexDebug] Debug mode " .. statusText)
    Library:Notify("Debug mode " .. statusText, 3)
end

function Library:SetDPIScale(scale)
    self.DPIScale = scale
end

function Library:Toggle()
    self.KeybindFrame.Visible = not self.KeybindFrame.Visible
    if self._window and self._window.ToggleUI then
        pcall(function() self._window:ToggleUI() end)
    end
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local WindowConfig = {
        Title = cfg.Title or "SolanaHub | Best Script",
        Footer = cfg.Footer or "Premium Version",
        Content = "SCRIPT: " .. Env.GameName,
        Color = "Default",
        Version = 1.0,
        ["Tab Width"] = 120,
        Image = "135199868370962",
        Configname = "SOL",
        Uitransparent = 0.15,
        ShowUser = false,
        Search = true,
        Animation = true,
        TypeDelay = 0.07,
        TypePause = 2.5,
        Config = {
            ConfigFolder = "SolanaHubSailorPiece/",
            AutoSaveFile = "Default",
            AutoSave = false,
            AutoLoad = false,
        },
        Author = "developed by Sol",
        Folder = "SolanaHubSailorPiece",
        Icon = "rbxassetid://135199868370962",
        IconSize = 30,
        NewElements = true,
        Size = UDim2.fromOffset(640, 520),
        ToggleKey = Enum.KeyCode.LeftAlt,
        User = {Enabled = true, Anonymous = true},
        HideSearchBar = false,
        Topbar = {Height = 43, ButtonsType = "Default"},
    }

    -- ModernV2 win shim menggantikan VelarisUI:Window()
    local _tabIconMap = {
        Information="lucide:circle-info",    -- alias → circle-i (built-in)
        Priority="lucide:toggle-right",       -- alias → two-switches-horizontal
        Main="lucide:house",                  -- alias → house (built-in)
        Automation="lucide:refresh-cw",

        Dungeon="lucide:map-pin",
        Player="lucide:user",
        Teleport="lucide:map-pin",
        Webhook="lucide:bell",
        Misc="lucide:layout-grid",            -- alias → grid (built-in)
        Event="lucide:star",
        Config="lucide:settings",
    }
    local win = {
        AddTab = function(self2, tabCfg)
            local tName = tabCfg.Name or tabCfg.Title or "Tab"
            local icon  = _tabIconMap[tName] or "lucide:layout-grid"
            local tabType = tabCfg.Single and "Single" or "Double"
            local actualTab; pcall(function()
                actualTab = _mvWindow:AddTab({Name=tName, Icon=icon, Type=tabType})
            end)
            return {
                AddSection = function(self3, secCfg)
                    local pos
                    if secCfg.Column == "Right" then
                        pos = "Right"
                    elseif secCfg.Column == "Center" then
                        pos = "Left"  -- single-column tabs: any pos fills full width
                    else
                        pos = "Left"
                    end
                    local mvSec; pcall(function()
                        mvSec = actualTab:AddSection({Name=secCfg.Title or secCfg.Name or "", Position=pos, Box=true, BoxBorder=true, Opened=true})
                    end)
                    return makeMvSecShim(mvSec)
                end,
                -- Expose AddTabbox agar createTabbox() bisa pakai ModernV2 tabbox asli
                AddTabbox = function(self3, tbCfg)
                    tbCfg = tbCfg or {}
                    local pos = string.lower(tostring(tbCfg.Position or tbCfg.Column or "left"))
                    if pos ~= "right" then pos = "left" end
                    local tb; pcall(function()
                        tb = actualTab:AddTabbox({Name=tbCfg.Name or tbCfg.Title or "", Position=pos})
                    end)
                    return tb
                end,
            }
        end
    }

    local winAdapter = {}
    Library._window = win
    function winAdapter:SetCornerRadius() end
    function winAdapter:SetTitle(t) end
    function winAdapter:SetFooter(t) end
    function winAdapter:Tag(opts) end

    function winAdapter:AddTab(name, icon)
        -- Single-column (full width) layout for all tabs per user preference
        local isSingle = true
        local ok_tab, vTab = pcall(function()
            return win:AddTab({ Name = name, Title = name, Border = true, Columns = true, Single = isSingle })
        end)
        if not ok_tab or not vTab then
            vTab = { AddSection = function() return makeMvSecShim(nil) end }
        end
        
        local function isArray(tbl)
            if type(tbl) ~= "table" then return false end
            local n = 0
            for k in pairs(tbl) do
                if type(k) ~= "number" then
                    return false
                end
                if k > n then
                    n = k
                end
            end
            return n == #tbl
        end

        local function cloneTable(tbl)
            local out = {}
            if type(tbl) == "table" then
                for k, v in pairs(tbl) do
                    out[k] = v
                end
            end
            return out
        end

        local function normalizeMultiValue(value)
            if value == nil then
                return {}
            end
            if type(value) ~= "table" then
                return { [value] = true }
            end
            if isArray(value) then
                local mapped = {}
                for _, v in ipairs(value) do
                    mapped[v] = true
                end
                return mapped
            end
            local mapped = {}
            for k, v in pairs(value) do
                if type(v) == "boolean" then
                    if v then
                        mapped[k] = true
                    end
                elseif v ~= nil then
                    mapped[k] = true
                end
            end
            return mapped
        end

        local function multiValueToList(value)
            if value == nil then
                return {}
            end
            if type(value) ~= "table" then
                return { value }
            end
            if isArray(value) then
                return cloneTable(value)
            end
            local list = {}
            for k, v in pairs(value) do
                if v then
                    table.insert(list, k)
                end
            end
            table.sort(list, function(a, b)
                return tostring(a) < tostring(b)
            end)
            return list
        end

        local function normalizeArgs(id, opts)
            if type(id) == "table" and opts == nil then
                local cfg = id
                id = cfg.Flag or cfg.Title or cfg.Text or cfg.Placeholder or ("Unnamed_" .. tostring(math.random(1000, 9999)))
                opts = {
                    Text = cfg.Title or cfg.Text or id,
                    Content = cfg.Content,
                    Title2 = cfg.Title2,
                    Default = cfg.Default,
                    Values = cfg.Options or cfg.Values,
                    Multi = cfg.Multi,
                    Callback = cfg.Callback,
                    Placeholder = cfg.Placeholder,
                    Min = cfg.Min,
                    Max = cfg.Max,
                    Increment = cfg.Increment,
                    Rounding = cfg.Rounding,
                    Searchable = cfg.Searchable,
                    SpecialType = cfg.SpecialType,
                    ExcludeLocalPlayer = cfg.ExcludeLocalPlayer,
                    AllowNull = cfg.AllowNull,
                    Disabled = cfg.Disabled,
                    Visible = cfg.Visible,
                    Numeric = cfg.Numeric,
                    Finished = cfg.Finished,
                    ClearTextOnFocus = cfg.ClearTextOnFocus,
                    DoesWrap = cfg.DoesWrap,
                    Badge = cfg.Badge,
                    Locked = cfg.Locked,
                    DisabledValues = cfg.DisabledValues,
                    Tooltip = cfg.Tooltip,
                }
            else
                opts = opts or {}
            end
            return tostring(id), opts
        end

        local function wrapSection(vSec)
            local sec = {}
            if not vSec then vSec = {} end

            function sec:AddToggle(id, opts)
                id, opts = normalizeArgs(id, opts)
                opts = opts or {}
                local toggleObj = rawget(Toggles, id) or { Value = false, Callbacks = {} }
                toggleObj.Value = opts.Default or false
                if not toggleObj.Callbacks then toggleObj.Callbacks = {} end
                rawset(Toggles, id, toggleObj)
                if type(opts.Callback) == "function" then
                    table.insert(toggleObj.Callbacks, opts.Callback)
                end
                
                local vToggle
                if vSec.AddToggle then
                    pcall(function()
                        vToggle = vSec:AddToggle({
                            Flag = id,
                            Title = opts.Text or id,
                            Content = opts.Content or "",
                            Title2 = opts.Title2 or "",
                            Default = opts.Default or false,
                            Badge = opts.Badge,
                            Locked = opts.Disabled or opts.Locked,
                            TextLocked = opts.TextLocked,
                            Callback = function(v)
                                toggleObj.Value = v
                                for _, cb in ipairs(toggleObj.Callbacks) do pcall(task.spawn, cb, v) end
                            end
                        })
                    end)
                    if vToggle and opts.Visible ~= nil and vToggle.SetVisible then
                        pcall(function() vToggle:SetVisible(opts.Visible) end)
                    end
                end
                
                function toggleObj:OnChanged(cb) table.insert(self.Callbacks, cb) end
                function toggleObj:SetValue(v)
                    local oldValue = self.Value
                    if vToggle and vToggle.Set then
                        pcall(function() vToggle:Set(v) end)
                    end
                    self.Value = v
                    if oldValue ~= v then
                        for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
                    end
                end
                function toggleObj:SetVisible(vis)
                    if vToggle and vToggle.SetVisible then
                        pcall(function() vToggle:SetVisible(vis) end)
                    end
                end
                function toggleObj:SetText(txt)
                    if vToggle then
                        pcall(function()
                            if vToggle.SetTitle then
                                vToggle:SetTitle(txt)
                            elseif vToggle.SetText then
                                vToggle:SetText(txt)
                            end
                        end)
                    end
                end
                return toggleObj
            end

            function sec:AddDropdown(id, opts)
                id, opts = normalizeArgs(id, opts)
                opts = opts or {}
                local defaultValue = opts.Multi and normalizeMultiValue(opts.Default) or opts.Default
                local values = opts.Values or {}
                if opts.SpecialType == "Player" then
                    values = {}
                    for _, player in ipairs(Players:GetPlayers()) do
                        if not (opts.ExcludeLocalPlayer and player == Plr) then
                            table.insert(values, player.Name)
                        end
                    end
                    table.sort(values)
                end
                local optObj = rawget(Options, id) or { Value = nil, Callbacks = {} }
                optObj.Value = defaultValue
                optObj.Values = values
                if not optObj.Callbacks then optObj.Callbacks = {} end
                rawset(Options, id, optObj)
                if type(opts.Callback) == "function" then
                    table.insert(optObj.Callbacks, opts.Callback)
                end
                local firstDropdownCallback = true
                
                local vDrop
                if vSec.AddDropdown then
                    pcall(function()
                        vDrop = vSec:AddDropdown({
                            Flag = id,
                            Title = opts.Text or id,
                            Content = opts.Content or "",
                            Options = values,
                            Default = opts.Multi and multiValueToList(defaultValue) or defaultValue,
                            Multi = opts.Multi,
                            Search = opts.Searchable,
                            Stacked = opts.Stacked,
                            Badge = opts.Badge,
                            Locked = opts.Disabled or opts.Locked,
                            TextLocked = opts.TextLocked,
                            DisabledValues = opts.DisabledValues,
                            Callback = function(v)
                                local normalized = opts.Multi and normalizeMultiValue(v) or v
                                if firstDropdownCallback then
                                    firstDropdownCallback = false
                                    local hasDefault = opts.Default ~= nil and (not opts.Multi or next(normalizeMultiValue(opts.Default)) ~= nil)
                                    local isEmpty = normalized == nil or (type(normalized) == "table" and next(normalized) == nil)
                                    if not hasDefault and isEmpty then
                                        optObj.Value = normalized
                                        return
                                    end
                                end
                                optObj.Value = normalized
                                for _, cb in ipairs(optObj.Callbacks) do pcall(task.spawn, cb, normalized) end
                            end
                        })
                    end)
                    if vDrop and opts.Visible ~= nil and vDrop.SetVisible then
                        pcall(function() vDrop:SetVisible(opts.Visible) end)
                    end
                end
                if opts.SpecialType == "Player" and not optObj.PlayerBinding then
                    optObj.PlayerBinding = true
                    local function refreshPlayerValues()
                        local updated = {}
                        for _, player in ipairs(Players:GetPlayers()) do
                            if not (opts.ExcludeLocalPlayer and player == Plr) then
                                table.insert(updated, player.Name)
                            end
                        end
                        table.sort(updated)
                        optObj.Values = updated
                        if vDrop and vDrop.SetValues then
                            pcall(function()
                                vDrop:SetValues(updated, opts.Multi and multiValueToList(optObj.Value) or optObj.Value)
                            end)
                        end
                    end
                    Players.PlayerAdded:Connect(refreshPlayerValues)
                    Players.PlayerRemoving:Connect(refreshPlayerValues)
                    task.defer(refreshPlayerValues)
                end
                
                function optObj:OnChanged(cb) table.insert(self.Callbacks, cb) end
                function optObj:SetValues(list)
                    self.Values = list or {}
                    if vDrop then
                        pcall(function()
                            local currentSelection = opts.Multi and multiValueToList(self.Value) or self.Value
                            if vDrop.Refresh then vDrop:Refresh(list)
                            elseif vDrop.SetValues then vDrop:SetValues(list, currentSelection)
                            elseif vDrop.Update then vDrop:Update(list)
                            elseif vDrop.SetChoices then vDrop:SetChoices(list) end
                        end)
                    end
                end
                function optObj:SetValue(v)
                    local normalized = opts.Multi and normalizeMultiValue(v) or v
                    local oldValue = self.Value
                    if vDrop and vDrop.Set then
                        pcall(function()
                            vDrop:Set(opts.Multi and multiValueToList(normalized) or normalized)
                        end)
                    end
                    self.Value = normalized
                    if oldValue ~= normalized then
                        for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, normalized) end
                    end
                end
                function optObj:SetVisible(vis)
                    if vDrop and vDrop.SetVisible then
                        pcall(function() vDrop:SetVisible(vis) end)
                    end
                end
                function optObj:SetText(txt)
                    if vDrop then
                        pcall(function()
                            if vDrop.SetTitle then
                                vDrop:SetTitle(txt)
                            elseif vDrop.SetText then
                                vDrop:SetText(txt)
                            end
                        end)
                    end
                end
                return optObj
            end

            function sec:AddSlider(id, opts)
                id, opts = normalizeArgs(id, opts)
                opts = opts or {}
                local increment = opts.Increment
                local rounding = opts.Rounding and tonumber(opts.Rounding)
                if rounding == nil then
                    if increment then
                        rounding = getRoundingFromIncrement(increment)
                    else
                        local maxVal = tonumber(opts.Max) or 100
                        if maxVal <= 5 then
                            increment = 0.01
                            rounding = 2
                        elseif maxVal <= 50 then
                            increment = 0.1
                            rounding = 1
                        else
                            increment = 1
                            rounding = 0
                        end
                    end
                else
                    if rounding > 0 then
                        increment = 10 ^ (-rounding)
                    else
                        increment = 1
                    end
                end
                local optObj = rawget(Options, id) or { Value = 0, Callbacks = {} }
                optObj.Value = opts.Default or opts.Min or 0
                if not optObj.Callbacks then optObj.Callbacks = {} end
                rawset(Options, id, optObj)
                if type(opts.Callback) == "function" then
                    table.insert(optObj.Callbacks, opts.Callback)
                end
                
                local vSlide
                if vSec.AddSlider then
                    pcall(function()
                        vSlide = vSec:AddSlider({
                            Flag = id,
                            Title = opts.Text or id,
                            Content = opts.Content or "",
                            Min = opts.Min or 0,
                            Max = opts.Max or 100,
                            Default = opts.Default,
                            Increment = increment,
                            Rounding = rounding,
                            Stacked = opts.Stacked,
                            Badge = opts.Badge,
                            Locked = opts.Disabled or opts.Locked,
                            TextLocked = opts.TextLocked,
                            Tooltip = opts.Tooltip,
                            Callback = function(v)
                                optObj.Value = v
                                for _, cb in ipairs(optObj.Callbacks) do pcall(task.spawn, cb, v) end
                            end
                        })
                    end)
                    if vSlide and opts.Visible ~= nil and vSlide.SetVisible then
                        pcall(function() vSlide:SetVisible(opts.Visible) end)
                    end
                end
                
                function optObj:OnChanged(cb) table.insert(self.Callbacks, cb) end
                function optObj:SetVisible(vis)
                    if vSlide and vSlide.SetVisible then
                        pcall(function() vSlide:SetVisible(vis) end)
                    end
                end
                function optObj:SetText(txt)
                    if vSlide then
                        pcall(function()
                            if vSlide.SetTitle then
                                vSlide:SetTitle(txt)
                            elseif vSlide.SetText then
                                vSlide:SetText(txt)
                            end
                        end)
                    end
                end
                function optObj:SetValue(v)
                    local oldValue = self.Value
                    if vSlide and vSlide.Set then
                        pcall(function() vSlide:Set(v) end)
                    end
                    self.Value = v
                    if oldValue ~= v then
                        for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
                    end
                end
                return optObj
            end

            function sec:AddInput(id, opts)
                id, opts = normalizeArgs(id, opts)
                opts = opts or {}
                local optObj = rawget(Options, id) or { Value = "", Callbacks = {} }
                optObj.Value = opts.Default or ""
                if not optObj.Callbacks then optObj.Callbacks = {} end
                rawset(Options, id, optObj)
                if type(opts.Callback) == "function" then
                    table.insert(optObj.Callbacks, opts.Callback)
                end
                
                local vInp
                if vSec.AddInput then
                    pcall(function()
                        vInp = vSec:AddInput({
                            Flag = id,
                            Title = opts.Text or id,
                            Content = opts.Content or "",
                            Placeholder = opts.Placeholder or "",
                            Locked = opts.Disabled or opts.Locked,
                            Callback = function(v)
                                optObj.Value = v
                                for _, cb in ipairs(optObj.Callbacks) do pcall(task.spawn, cb, v) end
                            end
                        })
                    end)
                    if vInp and opts.Visible ~= nil and vInp.SetVisible then
                        pcall(function() vInp:SetVisible(opts.Visible) end)
                    end
                end
                
                function optObj:OnChanged(cb) table.insert(self.Callbacks, cb) end
                function optObj:SetValue(v)
                    local oldValue = self.Value
                    if vInp and vInp.Set then
                        pcall(function() vInp:Set(v) end)
                    end
                    self.Value = v
                    if oldValue ~= v then
                        for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
                    end
                end
                function optObj:SetVisible(vis)
                    if vInp and vInp.SetVisible then
                        pcall(function() vInp:SetVisible(vis) end)
                    end
                end
                function optObj:SetText(txt)
                    if vInp then
                        pcall(function()
                            if vInp.SetTitle then
                                vInp:SetTitle(txt)
                            elseif vInp.SetText then
                                vInp:SetText(txt)
                            end
                        end)
                    end
                end
                return optObj
            end

            function sec:AddLabel(text, hasTextSize)
                local resolvedText = text
                if type(text) == "table" then
                    resolvedText = text.Text or text.Title or text.Desc or ""
                end
                local labelObj = { Text = resolvedText }
                local vPara
                if vSec.AddLabel then
                    pcall(function()
                        vPara = vSec:AddLabel(resolvedText, true)
                    end)
                elseif vSec.AddParagraph then
                    pcall(function()
                        vPara = vSec:AddParagraph({ Title = "", Content = resolvedText })
                    end)
                end
                if vPara and type(text) == "table" and text.Visible ~= nil and vPara.SetVisible then
                    pcall(function() vPara:SetVisible(text.Visible) end)
                end
                
                function labelObj:SetText(txt)
                    if vPara then
                        pcall(function()
                            if vPara.SetContent then
                                vPara:SetContent(txt)
                            elseif vPara.SetText then
                                vPara:SetText(txt)
                            end
                        end)
                    end
                    self.Text = txt
                end
                function labelObj:SetContent(txt)
                    self:SetText(txt)
                end
                function labelObj:SetVisible(vis)
                    if vPara and vPara.SetVisible then
                        pcall(function() vPara:SetVisible(vis) end)
                    end
                end
                
                function labelObj:AddKeyPicker(id, opts)
                    opts = opts or {}
                    local kpObj = rawget(Options, id) or { Value = opts.Default or "None", Callbacks = {}, ClickCallbacks = {}, Bound = false }
                    kpObj.Value = opts.Default or "None"
                    if not kpObj.Callbacks then kpObj.Callbacks = {} end
                    if not kpObj.ClickCallbacks then kpObj.ClickCallbacks = {} end
                    function kpObj:OnClick(cb)
                        if type(cb) == "function" then
                            table.insert(self.ClickCallbacks, cb)
                            return
                        end
                        for _, c in ipairs(self.ClickCallbacks) do pcall(task.spawn, c, true) end
                    end
                    function kpObj:OnChanged(cb) table.insert(self.Callbacks, cb) end
                    function kpObj:SetValue(v)
                        self.Value = v
                        for _, cb in ipairs(self.Callbacks) do pcall(task.spawn, cb, v) end
                    end
                    function kpObj:SetValues() end
                    if not kpObj.Bound then
                        kpObj.Bound = true
                        UIS.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then return end
                            local keyName = tostring(kpObj.Value or "None")
                            if keyName == "None" or keyName == "" then return end
                            if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == keyName then
                                if id == "MenuKeybind" then
                                    Library:Toggle()
                                end
                                kpObj:OnClick()
                            end
                        end)
                    end
                    rawset(Options, id, kpObj)
                    return kpObj
                end
                return labelObj
            end
            
            function sec:AddParagraph(cfg)
                cfg = cfg or {}
                local title = cfg.Title or cfg.Name or cfg.Text or "Info"
                local content = cfg.Content or ""
                local pObj = { Title = title, Content = content }
                local vPara
                if vSec.AddParagraph then
                    pcall(function()
                        vPara = vSec:AddParagraph({ Title = title, Name = title, Content = content })
                    end)
                elseif vSec.AddLabel then
                    local formattedText = (title ~= "" and ("<b>" .. title .. "</b>\n" .. content) or content)
                    pcall(function()
                        vPara = vSec:AddLabel(formattedText, true)
                    end)
                end
                
                function pObj:SetContent(txt)
                    if vPara then
                        pcall(function()
                            if vPara.SetContent then
                                vPara:SetContent(txt)
                            elseif vPara.SetText then
                                vPara:SetText(title ~= "" and ("<b>" .. title .. "</b>\n" .. txt) or txt)
                            end
                        end)
                    end
                    self.Content = txt
                end
                function pObj:SetText(txt)
                    self:SetContent(txt)
                end
                function pObj:SetVisible(vis)
                    if vPara and vPara.SetVisible then
                        pcall(function() vPara:SetVisible(vis) end)
                    end
                end
                return pObj
            end

            function sec:AddButton(text_or_opts, func)
                local btnCfg = type(text_or_opts) == "table" and text_or_opts or { Text = text_or_opts, Func = func }
                local btnText = btnCfg.Text
                local btnFunc = btnCfg.Func
                local btnDisabled = btnCfg.Disabled == true
                local btnDisabledTooltip = btnCfg.DisabledTooltip or "This action is currently disabled."
                local wrappedBtnFunc = function(...)
                    if btnDisabled then
                        Library:Notify(btnDisabledTooltip, 3)
                        return
                    end
                    if type(btnFunc) == "function" then
                        return btnFunc(...)
                    end
                end
                
                if vSec.AddButton then
                    pcall(function()
                        vSec:AddButton({
                            Title = btnText,
                            Callback = wrappedBtnFunc
                        })
                    end)
                end
                
                local btnObj = {}
                function btnObj:AddButton(t2, f2)
                    local b2Cfg = type(t2) == "table" and t2 or { Text = t2, Func = f2 }
                    local b2Text = b2Cfg.Text
                    local b2Func = b2Cfg.Func
                    local b2Disabled = b2Cfg.Disabled == true
                    local b2DisabledTooltip = b2Cfg.DisabledTooltip or "This action is currently disabled."
                    if vSec.AddButton then
                        pcall(function()
                            vSec:AddButton({
                                Title = b2Text,
                                Callback = function(...)
                                    if b2Disabled then
                                        Library:Notify(b2DisabledTooltip, 3)
                                        return
                                    end
                                    if type(b2Func) == "function" then
                                        return b2Func(...)
                                    end
                                end
                            })
                        end)
                    end
                    return btnObj
                end
                return btnObj
            end
            
            function sec:AddDivider() end
            function sec:AddTabbox(opts)
                local ok_box, vBox = pcall(function()
                    if vSec.AddTabbox then
                        return vSec:AddTabbox(opts or {})
                    elseif vSec.AddTabBox then
                        return vSec:AddTabBox(opts or {})
                    end
                end)
                return wrapSection(ok_box and vBox or nil)
            end
            return sec
        end

        local tabAdapter = {}
        function tabAdapter:AddLeftGroupbox(title) 
            local ok_sec, vSec = pcall(function() return vTab:AddSection({ Title = title, Column = "Left" }) end)
            return wrapSection(ok_sec and vSec or nil)
        end
        function tabAdapter:AddRightGroupbox(title) 
            local ok_sec, vSec = pcall(function() return vTab:AddSection({ Title = title, Column = "Right" }) end)
            return wrapSection(ok_sec and vSec or nil)
        end
        function tabAdapter:AddCenterGroupbox(title)
            -- On Single-type tabs, Left fills full width (center effect)
            local ok_sec, vSec = pcall(function() return vTab:AddSection({ Title = title, Column = "Left" }) end)
            return wrapSection(ok_sec and vSec or nil)
        end
        function tabAdapter:UpdateWarningBox(opts)
            opts = opts or {}
            local ok_sec, vSec = pcall(function()
                return vTab:AddSection({ Title = opts.Title or "Warning", Column = "Right" })
            end)
            if ok_sec and vSec and vSec.AddParagraph then
                pcall(function()
                    vSec:AddParagraph({
                        Title = opts.Title or "Warning",
                        Content = opts.Text or "",
                    })
                end)
            end
        end

        local function createTabbox(column, groupTitle)
            local tBox = {}
            -- Gunakan ModernV2 Tab:AddTabbox() asli → tab buttons yang bisa diklik
            local actualTabbox; pcall(function()
                actualTabbox = vTab:AddTabbox({Name=groupTitle or "", Position="left"})
            end)
            function tBox:AddTab(tName, tIcon)
                local icon = tIcon
                if type(tName) == "table" then
                    icon = tName.Icon or icon
                    tName = tName.Name or tName.Title or "Tab"
                end
                if not icon or icon == "" or icon == "folder" then
                    icon = _tabboxIconMap[tName] or "lucide:layout-grid"
                end
                local handler; pcall(function()
                    if actualTabbox and actualTabbox.AddTab then
                        handler = actualTabbox:AddTab({ Name = tName, Icon = icon })
                    end
                end)
                return wrapSection(handler and makeMvSecShim(handler) or nil)
            end
            return tBox
        end

        function tabAdapter:AddLeftTabbox(groupTitle)
            return createTabbox("Left", groupTitle)
        end

        function tabAdapter:AddRightTabbox(groupTitle)
            return createTabbox("Right", groupTitle)
        end
        return tabAdapter
    end
    
    -- Notifikasi startup dihapus untuk mengurangi popup yang mengganggu
    return winAdapter
end

local ThemeManager = { SetLibrary = function() end, SetFolder = function() end, ApplyToTab = function() end, LoadDefault = function() end }
local SaveManager = {}
do
    SaveManager.Folder = "SolanaHubSailorPiece"
    SaveManager.Ignore = {}
    SaveManager.Library = nil

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in ipairs(list) do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        if not isfolder(self.Folder) then makefolder(self.Folder) end
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName"
        })
    end

    function SaveManager:Save(name)
        if not name or name == "" then return false end
        local fullPath = self.Folder .. "/" .. name .. ".json"
        
        local data = {}
        if self.Library then
            for key, toggle in pairs(self.Library.Toggles) do
                if not self.Ignore[key] then
                    data[key] = { type = "toggle", value = toggle.Value }
                end
            end
            for key, option in pairs(self.Library.Options) do
                if not self.Ignore[key] then
                    data[key] = { type = "option", value = option.Value }
                end
            end
        end

        local success, result = pcall(function()
            local json = Http:JSONEncode(data)
            writefile(fullPath, json)
            return true
        end)
        
        return success
    end

    function SaveManager:Load(name)
        if not name or name == "" then return false end
        local fullPath = self.Folder .. "/" .. name .. ".json"
        
        if not isfile(fullPath) then return false end
        
        local success, result = pcall(function()
            local content = readfile(fullPath)
            local parsed = Http:JSONDecode(content)
            
            if self.Library then
                for key, item in pairs(parsed) do
                    if item.type == "toggle" and self.Library.Toggles[key] then
                        self.Library.Toggles[key]:SetValue(item.value)
                    elseif item.type == "option" and self.Library.Options[key] then
                        self.Library.Options[key]:SetValue(item.value)
                    end
                end
            end
            return true
        end)
        return success
    end

    function SaveManager:Delete(name)
        if not name or name == "" then return false end
        local fullPath = self.Folder .. "/" .. name .. ".json"
        
        if isfile(fullPath) then
            pcall(function() delfile(fullPath) end)
            return true
        end
        return false
    end

    function SaveManager:RefreshConfigList()
        local list = {}
        if isfolder(self.Folder) then
            for _, file in ipairs(listfiles(self.Folder)) do
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
        return list
    end

    function SaveManager:LoadAutoloadConfig()
        local path = self.Folder .. "/autoload.txt"
        if isfile(path) then
            local name = readfile(path)
            if name and name ~= "" then
                self:Load(name)
            end
        end
    end

    function SaveManager:SetAutoloadConfig(name)
        local path = self.Folder .. "/autoload.txt"
        writefile(path, name)
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")
        
        local section = tab:AddLeftGroupbox("Configuration")
        
        section:AddInput("SaveManager_ConfigName", { Text = "Config Name", Placeholder = "Enter config name" })
        
        local listDropdown = section:AddDropdown("SaveManager_ConfigList", { Text = "Config List", Values = self:RefreshConfigList(), Default = nil, Multi = false })
        
        section:AddButton("Save Config", function()
            local name = self.Library.Options.SaveManager_ConfigName.Value
            if name == "" then 
                name = self.Library.Options.SaveManager_ConfigList.Value
            end
            if name and name ~= "" then
                if self:Save(name) then
                    self.Library:Notify("Saved config: " .. name, 3)
                    listDropdown:SetValues(self:RefreshConfigList())
                else
                    self.Library:Notify("Failed to save config: " .. name, 3)
                end
            else
                self.Library:Notify("Please enter a name for the config.", 3)
            end
        end)
        
        section:AddButton("Load Config", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value
            if name and name ~= "" then
                if self:Load(name) then
                    self.Library:Notify("Loaded config: " .. name, 3)
                else
                    self.Library:Notify("Failed to load config: " .. name, 3)
                end
            else
                self.Library:Notify("Please select a config to load.", 3)
            end
        end)
        
        section:AddButton("Delete Config", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value
            if name and name ~= "" then
                if self:Delete(name) then
                    self.Library:Notify("Deleted config: " .. name, 3)
                    listDropdown:SetValues(self:RefreshConfigList())
                else
                    self.Library:Notify("Failed to delete config: " .. name, 3)
                end
            else
                self.Library:Notify("Please select a config to delete.", 3)
            end
        end)

        section:AddButton("Refresh List", function()
            listDropdown:SetValues(self:RefreshConfigList())
        end)
        
        local autoLoadSection = tab:AddRightGroupbox("Autoload")
        autoLoadSection:AddButton("Set Autoload", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value
            if name and name ~= "" then
                self:SetAutoloadConfig(name)
                self.Library:Notify("Set autoload config to: " .. name, 3)
            end
        end)
        
        autoLoadSection:AddButton("Clear Autoload", function()
            self:SetAutoloadConfig("")
            self.Library:Notify("Cleared autoload config.", 3)
        end)
    end
end
-- ================================================================
-- [BRIDGE ADAPTER INJECTION END]
-- ================================================================

local omg = {
    13820188365,
    13413231458,
    5638697306,
    16660143487,
    12669880433,
    121554255694758,
    14287111618,
    16119081646,
    15868464144,
    13699729039,
    10502160439,
    76020690430974,
    92696084646822,
}

local fire = {
    "https://i.pinimg.com/736x/9b/d2/5f/9bd25f7e1d6e95c6253ef5e5f075f643.jpg",
    "https://i.pinimg.com/736x/f8/4d/c7/f84dc705b8f23ecdb8c650ec931b43c3.jpg",
    "https://i.pinimg.com/736x/10/3e/c8/103ec8d6ae5b9b7b38cd2614777aae90.jpg",
    "https://i.pinimg.com/736x/94/30/21/94302144f136aca660829c6824ada44f.jpg",
    "https://i.pinimg.com/736x/44/20/95/4420957839b426f39a0f712d7fee41f5.jpg",
    "https://i.pinimg.com/736x/d4/3e/c1/d43ec166f5fa3bffb0eba74f80a485d3.jpg",
    "https://i.pinimg.com/736x/79/9d/0e/799d0e707b953c372553449d96bbb1f8.jpg",
    "https://i.pinimg.com/736x/ba/e2/b3/bae2b38b9353be080d8df7460e9a9a49.jpg",
    "https://i.pinimg.com/736x/4c/60/4a/4c604abf385acef014f56dc3244bd58c.jpg",
    "https://i.pinimg.com/736x/0d/4a/2d/0d4a2d3b6add65506932c2429935c074.jpg",
    "https://i.pinimg.com/736x/91/fb/f8/91fbf8588cf51349670177e0f289432d.jpg",
    "https://i.pinimg.com/736x/44/81/d5/4481d5741397085afbee3fe42096ce83.jpg",
    "https://i.pinimg.com/1200x/0a/f8/61/0af861dbeafdcfce6fde30ce2d24e355.jpg",
    "https://i.pinimg.com/736x/d5/67/49/d56749b3fdf8ab8253ad32965518d309.jpg",
    "https://i.pinimg.com/1200x/40/cb/c2/40cbc211cc86a1e131f25dd0fa339e65.jpg",
    "https://i.pinimg.com/736x/51/27/c5/5127c5c03c81b72fbd666ca0ee9c20f3.jpg"
}

local eh_success, err = pcall(function()

local randomIndex = math.random(1, #omg)
local theChosenOne = omg[randomIndex]

local hasJoinedDiscord = "OTD.txt"

if not isfile(hasJoinedDiscord) then 
    Library:Notify("join the dc for leaks", 5)
    
    pcall(function()
        if Env.Support.Clipboard then
            setclipboard("discord.gg/"..Env.InviteCode)
        end
    end)

    if Env.Support.Webhook then
        task.spawn(function()
            pcall(function()
                httprequest({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = { 
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = Http:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        args = { code = Env.InviteCode },
                        nonce = Http:GenerateGUID(false)
                    })
                })
            end)
        end)
    end

    pcall(function()
        writefile(hasJoinedDiscord, "Joined")
    end)
elseif not Env.Support.FileIO then
    Library:Notify("Recommended to use better executor.", 3)
end

local Status = {
	Priority = {
		Task = {"Boss", "Pity Boss", "Summon", "Level Farm", "All Mob Farm", "Mob", "Merchant", "Alt Help"},
		Default = {"Boss", "Pity Boss", "Summon", "Level Farm", "All Mob Farm", "Mob", "Merchant", "Alt Help"},
	},
	Main = {
		GlobalPrio = "FARM",
		Farm = true,
		Recovering = false,
		MovingIsland = false,
		Island = "",
		Target = nil,
		KillTick = 0,
		TargetValid = false,
        IsSummoning = false,

		QuestNPC = "",
		
		MobIdx = 1,
		AllMobIdx = 1,
		WeapRotationIdx = 1,
		ComboIdx = 1,
		ParsedCombo = {},
		RawWeapCache = { Sword = {}, Melee = {} },
		ActiveWeap = "",

		ArmHaki = false,

		BossTIMap = {},
        BossMap = {},
        SummonMap = {},
		
		InventorySynced = false,
		Stats = {},
		Settings = {},
		GemStats = {},
		SkillTree = { Nodes = {}, Points = 0 },
		Passives = {},
		SpecStatsSlider = {},
        PowerSliders = {},
        CurrentPower = { Name = "None", Buffs = {}, MythicalBuff = 0 },
		UpBlacklist = {},

		MerchantBusy = false,
		LocalMerchantTime = 0,
		LastTimerTick = tick(),
		MerchantExecute = false,
		FirstMerchantSync = false,
		CurrentStock = {},
		
			LastM1 = 0,
			LastWRSwitch = 0,
			LastSwitch = { Title = "", Rune = "" },
			LastBuildSwitch = 0,
			LastDungeon = 0,
	        LastSummon = 0,
            SeaBeastLastHP = 0,
            SeaBeastDodgeUntil = 0,
			
			AltDamage = {},
		AltActive = false,
		TradeState = {},
	},
    Dungeon = {
        SafetyPoint = nil,
        hasStartedWave = false,
        CountedThisRun = false,
        Count = 0,
    },
    Cached = {
		StartTime = os.time(),
        activeTween = nil,
        Inv = {},
        NewItem = {},
        Accessories = {},
        RawWeapCache = { Sword = {}, Melee = {} },
        CharParts = {},
        BossRemote = {},
        BossConf = {},
        PlayerLastPos = {},
        QuestlineForced = { AutoM1 = false, AutoSkill = false },
    },
    Connections = {
        Player_General = nil,
        Idled = nil,
        Merchant = nil,
        Dash = nil,
        Knockback = {},
        Reconnect = nil,
    },
	Misc = {
		GroupId = 1002185259,
		Rank = {255, 254, 175, 150},
        Kicking = false,
	}
}

local StartStats = {
    Level = Plr.Data.Level.Value,
    Money = Plr.Data.Money.Value,
    Gems = Plr.Data.Gems.Value,
    Bounty = (Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Bounty") and Plr.leaderstats.Bounty.Value) or 0
}

local function GetSessionTime()
    local seconds = os.time() - Status.Cached.StartTime
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    
    return string.format("%dh %02dm", hours, mins)
end

local function Module(parent, name)
    local obj = parent:FindFirstChild(name)
    if obj and obj:IsA("ModuleScript") then
        local success, result = pcall(require, obj)
        if success then return result end
    end
    return nil
end

local function Remote(parent, pathString)
    local current = parent
    for _, name in ipairs(pathString:split(".")) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function LoadModule(name)
    local obj = RS:FindFirstChild(name)
    if not obj then obj = RS:FindFirstChild("Modules") and RS:FindFirstChild("Modules"):FindFirstChild(name) end
    
    if obj and obj:IsA("ModuleScript") then
        local success, result = pcall(require, obj)
        if success then return result end
        warn("Module failed to require: " .. name .. " - " .. tostring(result))
    else
        warn("Module not found: " .. name)
    end
    return nil
end

local Remotes = {}

local remotePaths = {
    _DR = {RE, "DashRemote"},

    SettingsToggle = {RE, "SettingsToggle"},
    SettingsSync = {RE, "SettingsSync"},
    UseCode = {RE, "CodeRedeem"},

    M1 = {RS, "CombatSystem.Remotes.RequestHit"},
    EquipWeapon = {RM, "EquipWeapon"},
    UseSkill = {RS, "AbilitySystem.Remotes.RequestAbility"},
    UseFruit = {RE, "FruitPowerRemote"},
    QuestAccept = {RE, "QuestAccept"},
    QuestAbandon = {RE, "QuestAbandon"},
    RequestSpawnSpiritWarrior = {RE, "RequestSpawnSpiritWarrior"},

    UseItem = {RM, "UseItem"},
    SlimeCraft = {RM, "RequestSlimeCraft"},
    GrailCraft = {RM, "RequestGrailCraft"},

    RerollSingleStat = {RM, "RerollSingleStat"},

    SkillTreeUpgrade = {RE, "SkillTreeUpgrade"},
    GetSkillTreeData = {RE, "GetSkillTreeData"},
    SkillTreeUnlock = {RE, "SkillTreeUnlock"},
    Enchant = {RM, "EnchantAccessory"},
    Blessing = {RM, "BlessWeapon"},



    Roll_Trait = {RE, "TraitReroll"},
    TraitAutoSkip = {RE, "TraitUpdateAutoSkip"},
    TraitConfirm = {RE, "TraitConfirm"},
    SpecPassiveReroll = {RE, "SpecPassiveReroll"},

    PowerRoll = {RE, "PowerReroll"},
    PowerGetData = {RF, "PowerGetData"},
    PowerSkip = {RE, "PowerUpdateAutoSkip"},
    UpPower = {RE, "PowerDataUpdate"},

    ArmHaki = {RE, "HakiRemote"},
    ObserHaki = {RE, "ObservationHakiRemote"},
    ConquerorHaki = {RM, "ConquerorHakiRemote"},

    TP_Portal = {RM, "TeleportToPortal"},
    OpenDungeon = {RM, "RequestDungeonPortal"},
    StartDungeon = {RM, "StartDungeonPortal"},

    EquipTitle = {RE, "TitleEquip"},
    TitleUnequip = {RE, "TitleUnequip"},
    EquipRune = {RM, "EquipRune"},
    LoadoutLoad = {RE, "LoadoutLoad"},
    AddStat = {RE, "AllocateStat"},

    OpenMerchant = {RM, "MerchantRemotes.OpenMerchantUI"},
    MerchantBuy = {RM, "MerchantRemotes.PurchaseMerchantItem"},

    StockUpdate = {RM, "MerchantRemotes.MerchantStockUpdate"},

    SummonBoss = {RM, "RequestSummonBoss"},
    JJKSummonBoss = {RM, "RequestSpawnStrongestBoss"},
    RimuruBoss = {RE, "RequestSpawnRimuru"},
    AnosBoss = {RM, "RequestSpawnAnosBoss"},
    TrueAizenBoss = {RE, "RequestSpawnTrueAizen"},
    AtomicBoss = {RE, "RequestSpawnAtomic"},

    ReqInventory = {RM, "RequestInventory"},
    Ascend = {RE, "RequestAscend"},
    ReqAscend = {RE, "GetAscendData"},
    CloseAscend = {RE, "CloseAscendUI"},

    TradeRespond = {RM, "TradeRemotes.RespondToRequest"},
    TradeSend = {RM, "TradeRemotes.SendTradeRequest"},
    TradeAddItem = {RM, "TradeRemotes.AddItemToTrade"},
    TradeReady = {RM, "TradeRemotes.SetReady"},
    TradeConfirm = {RM, "TradeRemotes.ConfirmTrade"},
    TradeUpdated = {RM, "TradeRemotes.TradeUpdated"},

    HakiStateUpdate = {RE, "HakiStateUpdate"},
    UpCurrency = {RE, "UpdateCurrency"},
    UpInventory = {RM, "UpdateInventory"},
    UpPlayerStats = {RE, "UpdatePlayerStats"},
    UpAscend = {RE, "AscendDataUpdate"},
    UpStatReroll = {RE, "StatRerollUpdate"},
    SpecPassiveUpdate = {RE, "SpecPassiveDataUpdate"},
    SpecPassiveSkip = {RE, "SpecPassiveUpdateAutoSkip"},
    UpSkillTree = {RE, "SkillTreeUpdate"},
    BossUIUpdate = {RM, "BossUIUpdate"},
    TitleSync = {RE, "TitleDataSync"},

    DungeonVote = {RM, "DungeonWaveVote"},
    DungeonReplay = {RM, "DungeonWaveReplayVote"},
}

for key, data in pairs(remotePaths) do
    Remotes[key] = Remote(data[1], data[2])
end

local Modules = {
    BossConfig = LoadModule("BossConfig", {Bosses = {},}),
    TimedConfig = LoadModule("TimedBossConfig"),
    SummonConfig = LoadModule("SummonableBossConfig"),
    WorldBossConfig = LoadModule("WorldBossConfig"),

    Merchant = LoadModule("MerchantConfig", {ITEMS = {},}),
    Travel = LoadModule("TravelConfig"),
    DungeonConfig = LoadModule("DungeonConfig"),

    Title = LoadModule("TitlesConfig", {}),
    Quests = LoadModule("QuestConfig", {RepeatableQuests = {}, Questlines = {},}),

    WeaponClass = LoadModule("WeaponClassification", {Tools = {},}),
    Fruits = Module(RS:FindFirstChild("FruitPowerSystem") or RS, "FruitPowerConfig") or {Powers = {}},


    LevelingConfig = LoadModule("LevelingConfig", {STATS = {}}),
    Stats = LoadModule("StatRerollConfig"),
    Codes = LoadModule("CodesConfig", {Codes = {},}),
    ItemRarity = LoadModule("ItemRarityConfig"),
    ItemDropConfig = LoadModule("ItemDropConfig"),
    ItemCapsConfig = LoadModule("ItemCapsConfig", {Caps = {}}),
    Trait = LoadModule("TraitConfig", {Traits = {},}),
    Race = LoadModule("RaceConfig", {Races = {},}),
    Clan = LoadModule("ClanConfig", {Clans = {},}),
    SpecPassive = LoadModule("SpecPassiveConfig"),
    Power = LoadModule("PowerConfig"),
    Bloodline = LoadModule("BloodlineConfig"),
    SkillTree = LoadModule("SkillTreeConfig")
}

local PATH = {
    Mobs = workspace:WaitForChild('NPCs'),
    InteractNPCs = workspace:WaitForChild('ServiceNPCs'),
}

local function GetServiceNPC(name)
    return PATH.InteractNPCs:FindFirstChild(name)
end

local NPCs = {
    Merchant = {
        Regular = GetServiceNPC("MerchantNPC"),
        Dungeon = GetServiceNPC("DungeonMerchantNPC"),
    }
}

local UI = {
    Merchant = {
        Regular = PGui:WaitForChild("MerchantUI"),
        Dungeon = PGui:WaitForChild("DungeonMerchantUI"),
    }
}

local Tables = {
    AscendLabels = {},
    DiffList = {"Normal", "Medium", "Hard", "Extreme"},
    MobList = {},
    MiniBossList = {"ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss"},
    BossList = {},
    AllBossList = {},
    AllNPCList = {},
    AllEntitiesList = {},
    SummonList = {},
    OtherSummonList = {},
--    OtherSummonList = {"StrongestHistory", "StrongestToday", "Rimuru", "Anos", "TrueAizen"},
    FullSummon = {},
    Weapon = {"Melee", "Sword", "Power"},
    ManualWeaponClass = {
        ["Invisible"] = "Power",
        ["Bomb"] = "Power",
        ["Quake"] = "Power",
    },

    MerchantList = {},

    Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"},
    CraftItemList = {"SlimeKey", "DivineGrail"},
    UnlockedTitle = {},
    TitleCategory = {"None", "Best EXP", "Best Money & Gem", "Best Luck", "Best DMG"},
    TitleList = {},
    SortedTitle = Modules.Title:GetSortedTitleIds(),
    BuildList = {"1", "2", "3", "4", "5", "None"},
    TraitList = {},
    RarityWeight = {
    ["Secret"] = 1,
    ["Mythical"] = 2,
    ["Legendary"] = 3,
    ["Epic"] = 4,
    ["Rare"] = 5,
    ["Uncommon"] = 6,
    ["Common"] = 7
    },

    RaceList = {},
    ClanList = {},
    RuneList = {"None"},
    SpecPassive = {},
    Power = {},
    BloodlineList = {},
    GemStat = Modules.Stats.StatKeys,
    GemRank = Modules.Stats.RankOrder,
    OwnedWeapon = {},
    AllOwnedWeapons = {},
    OwnedAccessory = {},
    QuestlineList = {},
    SkillBranches = { "Damage %", "HP %", "Crit Damage", "Crit Chance", "Luck %" },

    ITEM_WEIGHTS = {
    Chests = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"},
    Materials = {["Wood"] = 1, ["Iron"] = 2, ["Obsidian"] = 3, ["Mythril"] = 4, ["Adamantite"] = 5},
    Rarities = {["Common"] = 1, ["Rare"] = 2, ["Epic"] = 3, ["Legendary"] = 4},
    Gears = {["Helmet"] = 1, ["Gloves"] = 2, ["Body"] = 3, ["Boots"] = 4}
    },

    OwnedItem = {},

    NPC_QuestList = {"DungeonUnlock", "SlimeKeyUnlock"},
    NPC_MiscList = {"Blessing", "Enchant", "SkillTree", "Cupid", "ArmHaki", "Observation", "Conqueror"},
    DungeonList = {},

    NPC_MovesetList = {},
    NPC_MasteryList = {},

    IslandList = {},
    IslandCrystals = {},
    MobToIsland = {},
}

local TradePresets = {
    ["Madara Set"] = {
        ["Path Fragment"] = 3,
        ["Eternal Core"] = 8,
        ["Battle Sigil"] = 18,
        ["Power Remnant"] = 15,
    },
    ["Aizen Set"] = {
        ["Hyoguko Fragment"] = 1,
        ["Reiatsu Core"] = 3,
        ["Illusion Prism"] = 6,
        ["Mirage Pendant"] = 10,
    },
    ["True Aizen Set"] = {
        ["Evolution Fragment"] = 1,
        ["Transcendent Core"] = 3,
        ["Divinity Essence"] = 8,
        ["Fusion Ring"] = 15,
        ["Chrysalis Sigil"] = 75,
        ["Transmutation Shards"] = 5,
    },
    ["Atomic Set"] = {
        ["Atomic Omen"] = 1,
        ["Eminence Essence"] = 3,
        ["Shadow Remnant"] = 9,
        ["Magic Shard"] = 16,
        ["Abyss Sigil"] = 140,
    },
    ["Shadow Set"] = {
        ["Atomic Core"] = 1,
        ["Shadow Essence"] = 4,
        ["Void Seed"] = 8,
        ["Umbral Capsule"] = 20,
    },
    ["Saber Alter Set"] = {
        ["Dark Grail"] = 110,
        ["Morgan Remnant"] = 15,
        ["Alter Essence"] = 8,
        ["Corruption Core"] = 12,
        ["Corrupt Crown"] = 3,
    },
    ["Blessed Maiden Set"] = {
        ["Celestial Mark"] = 3,
        ["Aero Core"] = 1,
        ["Gale Essence"] = 8,
        ["Tide Remnant"] = 14,
        ["Tempest Relic"] = 100,
    },
    ["Yamato Set"] = {
        ["Azure Heart"] = 1,
        ["Silent Storm"] = 3,
        ["Yamato Essence"] = 7,
        ["Frozen Will"] = 14,
    },
    ["Gilgamesh Set"] = {
        ["Ancient Shards"] = 6,
        ["Throne Remnants"] = 12,
        ["Golden Essence"] = 8,
        ["Phantasm Cores"] = 3,
        ["Broken Swords"] = 100,
    },
    ["Kokushibo Set"] = {
        ["Moon Crest"] = 2,
        ["Crescent Shard"] = 14,
        ["Lunar Essence"] = 9,
        ["Demon Remnant"] = 16,
        ["Upper Seal"] = 110,
    },
    ["Esdeath Set"] = {
        ["Ice Core"] = 3,
        ["Frozen Brand"] = 14,
        ["Glaciar Remant"] = 9,
        ["Battle Shard"] = 17,
        ["Frost Relic"] = 110,
    }
}

local BossRemoteRegistry = {
    ["StrongestofTodayBoss"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestToday"} },
    ["StrongestinHistoryBoss"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestHistory"} },
    ["AnosBoss"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} },
    ["Strongest of Today"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestToday"} },
    ["Strongest in History"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestHistory"} },
    ["Anos"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} },
    ["Demon King"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} }
}

local function GetOtherSummon()
    local modules = RS:FindFirstChild("Modules")
    if not modules then return end

    local manualBosses = {"Strongest in History", "Strongest of Today"}
    
    local ignoreList = {
        "SummonableBossConfig", "BossConfig", "TimedBossConfig", "StrongestBossConfig"
    }

    for _, name in ipairs(manualBosses) do
        if not table.find(Tables.OtherSummonList, name) then
            table.insert(Tables.OtherSummonList, name)
        end
    end

    -- Scanner
    for _, obj in pairs(modules:GetChildren()) do
        if table.find(ignoreList, obj.Name) then continue end
        
        local bossPrefix = obj.Name:match("^(.-)BossConfig$")
        if bossPrefix and bossPrefix ~= "" then
            local displayName = bossPrefix 
            if not table.find(Tables.OtherSummonList, displayName) then
                table.insert(Tables.OtherSummonList, displayName)
            end
        end
    end
    table.sort(Tables.OtherSummonList)
end

GetOtherSummon()

local function InitializeIslands()
    local TravelConfig = Modules.Travel
    if not TravelConfig or not TravelConfig.Zones then return end

    table.clear(Tables.IslandList)
    table.clear(Tables.IslandCrystals)

    -- Pre-scan workspace for models with the CheckpointName attribute
    local crystalCache = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local attrValue = obj:GetAttribute("CheckpointName")
        if attrValue then
            crystalCache[attrValue] = obj
        end
    end

    for internalName, data in pairs(TravelConfig.Zones) do
        local baseName = internalName:gsub("Island", ""):gsub("Station", "")
        local displayName = data.DisplayName
        
        -- Match crystal via attribute
        local crystal = crystalCache[displayName]

        if crystal then
            Tables.IslandCrystals[baseName] = crystal
        end
        
        table.insert(Tables.IslandList, baseName)
    end
    table.sort(Tables.IslandList)

    if Options.SelectedIsland then
        Options.SelectedIsland:SetValues(Tables.IslandList)
    end
end

local function GetTPName(baseName)
    if baseName == "Hollow" then 
        return "HollowIsland" 
    end
    return baseName
end

InitializeIslands()

local function Fill(target, source, sortFunc)
    for k in pairs(source) do table.insert(target, k) end
    table.sort(target, sortFunc)
end

local function SortByRarity(dataTable, rarityKey)
    return function(a, b)
        local dataA = dataTable[a]
        local dataB = dataTable[b]
        if not dataA or not dataB then return false end

        local rA = dataA[rarityKey] or dataA["Rarity"] or dataA["rarity"] or "Common"
        local rB = dataB[rarityKey] or dataB["Rarity"] or dataB["rarity"] or "Common"

        local wA = Tables.RarityWeight[rA] or 99
        local wB = Tables.RarityWeight[rB] or 99

        if wA ~= wB then
            return wA < wB
        end
        return a < b
    end
end

if Modules.TimedConfig and Modules.TimedConfig.Bosses then
    table.clear(Tables.BossList)
    for internalId, data in pairs(Modules.TimedConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.BossList, data.displayName)
        
        local tpName = data.spawnLocation:gsub(" Island", ""):gsub(" Station", "")
        if data.spawnLocation == "Judgement Island" then tpName = "Judgement" end
        Status.Main.BossTIMap[data.displayName] = tpName
    end
    table.sort(Tables.BossList)
end

if Modules.SummonConfig and Modules.SummonConfig.Bosses then
    table.clear(Tables.SummonList)
    for internalId, data in pairs(Modules.SummonConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.SummonList, data.displayName)
        Status.Main.SummonMap[data.displayName] = data.bossId or internalId
    end
    table.sort(Tables.SummonList)
end

for _, v in ipairs(Tables.SummonList) do table.insert(Tables.FullSummon, v) end
for _, v in ipairs(Tables.OtherSummonList) do table.insert(Tables.FullSummon, v) end
table.sort(Tables.FullSummon)

if Modules.BossConfig and Modules.BossConfig.Bosses then
    for internalId, data in pairs(Modules.BossConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.AllBossList, data.displayName)
    end
end

if Modules.WorldBossConfig and Modules.WorldBossConfig.Bosses then
    for internalId, data in pairs(Modules.WorldBossConfig.Bosses) do
        if type(data) == "table" and data.displayName then
            Status.Main.BossMap[data.displayName] = internalId
            table.insert(Tables.AllBossList, data.displayName)
            table.insert(Tables.BossList, data.displayName)
            
            local tpName = data.spawnLocation:gsub(" Island", ""):gsub(" Station", ""):gsub(" Shrine", "")
            if data.spawnLocation == "Sun Shrine" then tpName = "Slayer" end
            Status.Main.BossTIMap[data.displayName] = tpName
        end
    end
    table.sort(Tables.BossList)
    table.sort(Tables.AllBossList)
end

local DisplayToInternal = {}
if Modules.BossConfig and Modules.BossConfig.Bosses then
    for internalId, data in pairs(Modules.BossConfig.Bosses) do
        DisplayToInternal[data.displayName] = internalId
    end
end

local function GetBestOwnedTitle(category)
    if #Tables.UnlockedTitle == 0 then return nil end
    
    local bestTitleId = nil
    local highestValue = -1
    
    local statMap = {
        ["Best EXP"] = "XPPercent",
        ["Best Money & Gem"] = "MoneyPercent", 
        ["Best Luck"] = "LuckPercent",
        ["Best DMG"] = "DamagePercent"
    }
    
    local targetStat = statMap[category]
    if not targetStat then return nil end

    for _, titleId in ipairs(Tables.UnlockedTitle) do
        local data = Modules.Title.Titles[titleId]
        if data and data.statBonuses and data.statBonuses[targetStat] then
            local val = data.statBonuses[targetStat]
            if val > highestValue then
                highestValue = val
                bestTitleId = titleId
            end
        end
    end
    
    return bestTitleId
end

-- // Title
local CombinedTitleList = {}
for _, v in ipairs(Tables.TitleCategory) do table.insert(CombinedTitleList, v) end
for _, v in ipairs(Tables.SortedTitle) do
    table.insert(Tables.TitleList, v)
    table.insert(CombinedTitleList, v)
end


Fill(Tables.SpecPassive, Modules.SpecPassive.Passives)
Fill(Tables.Power, Modules.Power.Powers)
Fill(Tables.QuestlineList, Modules.Quests.Questlines)
Fill(Tables.MerchantList, Modules.Merchant.ITEMS)
Fill(Tables.DungeonList, Modules.DungeonConfig.Dungeons)
Fill(Tables.TraitList, Modules.Trait.Traits, SortByRarity(Modules.Trait.Traits, "rarity"))
Fill(Tables.RaceList, Modules.Race.Races, SortByRarity(Modules.Race.Races, "rarity"))
Fill(Tables.ClanList, Modules.Clan.Clans, SortByRarity(Modules.Clan.Clans, "rarity"))
if Modules.Bloodline and Modules.Bloodline.Bloodlines then
    Fill(Tables.BloodlineList, Modules.Bloodline.Bloodlines, SortByRarity(Modules.Bloodline.Bloodlines, "rarity"))
end

for _, v in ipairs(PATH.InteractNPCs:GetChildren()) do
    table.insert(Tables.AllNPCList, v.Name)
end

local function Cleanup(tbl)
    for key, value in pairs(tbl) do
        if typeof(value) == "RBXScriptConnection" then
            value:Disconnect()
            tbl[key] = nil
        elseif typeof(value) == 'thread' then
            task.cancel(value)
            tbl[key] = nil
        elseif type(value) == 'table' then
            Cleanup(value)
        end
    end
end

local Flags = {}

function Thread(featurePath, featureFunc, isEnabled, ...)
    local pathParts = featurePath:split(".")
    local currentTable = Flags 

    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not currentTable[part] then currentTable[part] = {} end
        currentTable = currentTable[part]
    end

    local flagKey = pathParts[#pathParts]
    local activeThread = currentTable[flagKey]

    if isEnabled then
        if not activeThread or coroutine.status(activeThread) == "dead" then
            local newThread = task.spawn(featureFunc, ...)
            currentTable[flagKey] = newThread
        end
    else
        if activeThread and typeof(activeThread) == 'thread' then
            task.cancel(activeThread)
            currentTable[flagKey] = nil
        end
    end
end

local function SafeLoop(name, func)
    return function(...)
        local success, err = pcall(func, ...)
        if not success then
            Library:Notify("ERROR in ["..name.."]: Check console and send to script developer.", 10)
            warn("⚠️ ["..name.."] ERROR: " .. tostring(err))
        end
    end
end

local function SafeSetValues(id, list)
    local opt = Options[id]
    if opt and opt.SetValues then opt:SetValues(list) end
end

local function SafeSetOptionValue(id, value, context)
    local opt = Options[id]
    if not (opt and opt.SetValue) then
        DebugLog("MISSING_OPTION", ("[%s] Options.%s unavailable"):format(context or "Unknown", id), true)
        return false
    end
    opt:SetValue(value)
    DebugLog("SET_OPTION", ("[%s] Options.%s updated"):format(context or "Unknown", id))
    return true
end

local function SafeSetToggleValue(id, value, context)
    local tog = Toggles[id]
    if not (tog and tog.SetValue) then
        DebugLog("MISSING_TOGGLE", ("[%s] Toggles.%s unavailable"):format(context or "Unknown", id), true)
        return false
    end
    tog:SetValue(value)
    DebugLog("SET_TOGGLE", ("[%s] Toggles.%s = %s"):format(context or "Unknown", id, tostring(value)))
    return true
end

local function DebugCheckFeatureBindings()
    if not DEBUG_ENABLED then return end
    local requiredToggles = { "AutoSummon", "SummonBossFarm", "AutoOtherSummon", "OtherSummonFarm" }
    local requiredOptions = { "SelectedSummon", "SelectedSummonDiff", "SelectedOtherSummon", "SelectedOtherSummonDiff" }
    local missing = {}

    for _, id in ipairs(requiredToggles) do
        if rawget(Toggles, id) == nil then
            table.insert(missing, "Toggles." .. id)
        end
    end
    for _, id in ipairs(requiredOptions) do
        if rawget(Options, id) == nil then
            table.insert(missing, "Options." .. id)
        end
    end

    if #missing == 0 then
        DebugLog("DIAG", "Summon binding check passed.")
    else
        DebugLog("DIAG", "Missing bindings: " .. table.concat(missing, ", "), true)
    end
end

local function CommaFormat(n)
    local s = tostring(n)
    return s:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function Abbreviate(n)
    local abbrev = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, v in ipairs(abbrev) do
        if n >= v[1] then return string.format("%.1f%s", n / v[1], v[2]) end
    end
    return tostring(n)
end

local function GetFormattedItemSections(itemSourceTable, isNewItems)
    local categories = {
        Chests = {}, Rerolls = {}, Keys = {},
        Materials = {}, Gears = {}, Accessories = {}, Runes = {}, Others = {}
    }

    local totalDust = 0

    for key, data in pairs(itemSourceTable) do
        local name = tostring(type(data) == "table" and data.name or key)
        local qty = tonumber(type(data) == "table" and data.quantity or data) or 1

        if name:find("Auto%-deleted") then
            local dustValue = name:match("%+(%d+) dust")
            if dustValue then totalDust = totalDust + (qty * tonumber(dustValue)) end
            continue
        end

        local totalInInv = 0
        if isNewItems then
            for _, item in pairs(Status.Cached.Inv or {}) do
                if item.name == name then totalInInv = item.quantity break end
            end
        end

        local entryText = isNewItems 
            and string.format("+ [%d] %s [Total: %s]", qty, name, CommaFormat(totalInInv)) 
            or string.format("- %s: %s", name, CommaFormat(qty))

        -- Categorization Logic
        if name:find("Chest") or name:find("Crate") then
            local weight = 99
            for i, v in ipairs(Tables.ITEM_WEIGHTS.Chests) do if name:find(v) then weight = i break end end
            table.insert(categories.Chests, {Text = entryText, Weight = weight})
        elseif name:find("Reroll") then table.insert(categories.Rerolls, entryText)
        elseif name:find("Key") then table.insert(categories.Keys, entryText)
        elseif Tables.ITEM_WEIGHTS.Materials[name] then
            table.insert(categories.Materials, {Text = entryText, Weight = Tables.ITEM_WEIGHTS.Materials[name]})
        elseif name:find("Helmet") or name:find("Gloves") or name:find("Body") or name:find("Boots") then
            local rWeight, tWeight = 99, 99
            for k, v in pairs(Tables.ITEM_WEIGHTS.Rarities) do if name:find(k) then rWeight = v break end end
            for k, v in pairs(Tables.ITEM_WEIGHTS.Gears) do if name:find(k) then tWeight = v break end end
            table.insert(categories.Gears, {Text = entryText, Rarity = rWeight, Type = tWeight})
        elseif name:find("Rune") then table.insert(categories.Runes, entryText)
        else table.insert(categories.Others, entryText) end
    end

    if totalDust > 0 then
        local dustText = isNewItems and string.format("+ [%d] Dust", totalDust) or string.format("- Dust: %s", CommaFormat(totalDust))
        table.insert(categories.Materials, 1, {Text = dustText, Weight = 0})
    end

    local result = ""
    local function process(title, tbl, sortFunc)
        if #tbl > 0 then
            if sortFunc then table.sort(tbl, sortFunc) end
            result = result .. "**< " .. title .. " >**\n```" 
            for _, v in ipairs(tbl) do result = result .. (type(v) == "table" and v.Text or v) .. "\n" end
            result = result .. "```\n" 
        end
    end

    process("Chests", categories.Chests, function(a,b) return a.Weight < b.Weight end)
    process("Rerolls", categories.Rerolls)
    process("Keys", categories.Keys)
    process("Materials", categories.Materials, function(a,b) return a.Weight < b.Weight end)
    process("Gears", categories.Gears, function(a,b) 
        return (a.Rarity ~= b.Rarity) and (a.Rarity < b.Rarity) or (a.Type < b.Type)
    end)
    process("Runes", categories.Runes)
    process("Others", categories.Others)

    return result
end

local function PostToWebhook()
    local url = Options.WebhookURL.Value
    if url == "" or not url:find("discord.com/api/webhooks/") then return end

    local selected = Options.SelectedData.Value
    local allowedRarity = Options.SelectedItemRarity.Value or {}
    
    local data = Plr.Data
    local lstats = Plr:FindFirstChild("leaderstats")
    local bounty = lstats and lstats:FindFirstChild("Bounty") and lstats.Bounty.Value or 0
    
    local desc = "### sailor solanahub\n"
    
    if selected["Name"] then
        desc = desc .. string.format("\n👤 **Player:** ||%s||\n", Plr.Name)
    end

    if selected["Stats"] then
        local gainedLvl = data.Level.Value - StartStats.Level
        local gainedMoney = data.Money.Value - StartStats.Money
        local gainedGems = data.Gems.Value - StartStats.Gems
        local gainedBounty = bounty - StartStats.Bounty

        desc = desc .. string.format("📈 **Level:** `%s` (+%d)\n", CommaFormat(data.Level.Value), gainedLvl)
        desc = desc .. string.format("💰 **Currency:** 💵 %s (+%s) | 💎 %s (+%s)\n", 
            Abbreviate(data.Money.Value), Abbreviate(gainedMoney),
            CommaFormat(data.Gems.Value), CommaFormat(gainedGems))
        desc = desc .. string.format("☠️ **Bounty:** %s (+%s)\n", Abbreviate(bounty), Abbreviate(gainedBounty))
    end
    
    desc = desc .. "\n"

    local function IsAllowed(itemName)
        local rarity = Modules.ItemRarity and Modules.ItemRarity.Items[itemName] or "Common"
        return allowedRarity[rarity] == true
    end

    if selected["New Items"] and next(Status.Cached.NewItem) then
        local filteredNew = {}
        for name, qty in pairs(Status.Cached.NewItem) do
            if IsAllowed(name) then filteredNew[name] = qty end
        end

        if next(filteredNew) then
            desc = desc .. "✨ **New Items**\n"
            desc = desc .. GetFormattedItemSections(filteredNew, true) .. "\n"
        end
    end

    if selected["All Items"] then
        local filteredInv = {}
        for _, item in pairs(Status.Cached.Inv or {}) do
            if IsAllowed(item.name) then table.insert(filteredInv, item) end
        end

        if #filteredInv > 0 then
            desc = desc .. "---"
            desc = desc .. "\n🎒 **Inventory**\n"
            desc = desc .. GetFormattedItemSections(filteredInv, false)
        end
    end

    local catLink = fire[math.random(1, #fire)] or ""

    local payload = {
        ["embeds"] = {{
            ["description"] = desc,
            ["color"] = tonumber("ffff77", 16),
            ["footer"] = { ["text"] = string.format("SolanaHub Community • Session: %s • %s", GetSessionTime(), os.date("%x %X")) },
            ["thumbnail"] = { ["url"] = catLink }
        }}
    }
    
    if Toggles.PingUser.Value then payload["content"] = (Options.UID.Value ~= "" and "<@"..Options.UID.Value..">" or "@everyone") end

    task.spawn(function()
        pcall(function()
            httprequest({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = Http:JSONEncode(payload) })
            table.clear(Status.Cached.NewItem)
        end)
    end)
end

local function GetSortedUniqueNames(dataList)
    local unique = {}
    local result = {}
    for _, item in ipairs(dataList) do
        if not unique[item.name] then
            unique[item.name] = true
            table.insert(result, item.name)
        end
    end
    table.sort(result)
    return result
end

Remotes.UpInventory.OnClientEvent:Connect(function(category, data)
    Status.Main.InventorySynced = true
    local safeData = (type(data) == "table") and data or {}

    if category == "Items" then 
        Status.Cached.Inv = safeData
        table.clear(Tables.OwnedItem)
        
        for presetName, _ in pairs(TradePresets) do
            table.insert(Tables.OwnedItem, presetName)
        end

        for _, item in pairs(safeData) do
            if not table.find(Tables.OwnedItem, item.name) then
                table.insert(Tables.OwnedItem, item.name)
            end
        end
        table.sort(Tables.OwnedItem)
        SafeSetValues("SelectedTradeItems", Tables.OwnedItem)

    elseif category == "Runes" then
        table.clear(Tables.RuneList)
        table.insert(Tables.RuneList, "None")
        for name, _ in pairs(safeData) do table.insert(Tables.RuneList, name) end
        table.sort(Tables.RuneList)
        
        for _, dd in ipairs({"DefaultRune", "Rune_Mob", "Rune_Boss", "Rune_BossHP"}) do
            SafeSetValues(dd, Tables.RuneList)
        end

    elseif category == "Accessories" then
        table.clear(Status.Cached.Accessories)
        for _, accInfo in ipairs(safeData) do
            if accInfo.name and accInfo.quantity then
                Status.Cached.Accessories[accInfo.name] = accInfo.quantity
            end
        end
        
        table.clear(Tables.OwnedAccessory)
        local processed = {}
        for _, item in ipairs(safeData) do
            if (item.enchantLevel or 0) < 10 and not processed[item.name] then
                table.insert(Tables.OwnedAccessory, item.name)
                processed[item.name] = true
            end
        end
        table.sort(Tables.OwnedAccessory)
        SafeSetValues("SelectedEnchant", Tables.OwnedAccessory)
        
    elseif category == "Sword" or category == "Melee" then
        Status.Main.RawWeapCache[category] = safeData
        
        table.clear(Tables.OwnedWeapon)
        table.clear(Tables.AllOwnedWeapons)
        local processedUpgradeable = {}
        local processedAll = {}
        
        for _, cat in pairs({"Sword", "Melee"}) do
            local weapList = Status.Main.RawWeapCache[cat] or {}
            for _, item in ipairs(weapList) do
                if (item.blessingLevel or 0) < 10 and not processedUpgradeable[item.name] then
                    table.insert(Tables.OwnedWeapon, item.name)
                    processedUpgradeable[item.name] = true
                end

                if not processedAll[item.name] then
                    table.insert(Tables.AllOwnedWeapons, item.name)
                    processedAll[item.name] = true
                end
            end
        end
        
        table.sort(Tables.OwnedWeapon)
        table.sort(Tables.AllOwnedWeapons)
        
        SafeSetValues("SelectedBlessing", Tables.OwnedWeapon)
        SafeSetValues("SelectedPassive", Tables.AllOwnedWeapons)
    end
end)

Remotes.HakiStateUpdate.OnClientEvent:Connect(function(target, state)
    if target == false then Status.Main.ArmHaki = false
    elseif target == Plr then Status.Main.ArmHaki = state end
end)

if Remotes.BossUIUpdate then
    Remotes.BossUIUpdate.OnClientEvent:Connect(function(mode, data)
        if mode == "DamageStats" and data.stats then
            for _, info in pairs(data.stats) do
                if info.player then Status.Main.AltDamage[info.player.Name] = tonumber(info.percent) or 0 end
            end
        end
    end)
end

Remotes.UpPower.OnClientEvent:Connect(function(data)
    if data then
        local pData = data.RolledPower or data.Current
        if pData then
            Status.Main.CurrentPower.Name = pData.Name or "None"
            Status.Main.CurrentPower.Buffs = pData.RolledBuffs or {}
            
            if pData.RolledMythical then
                Status.Main.CurrentPower.MythicalBuff = pData.RolledMythical.DebuffPercent 
                    or pData.RolledMythical.BossDamagePercent 
                    or 0
            end
            
            if PowerLabel then
                local text = string.format("<b>Current:</b> %s", Status.Main.CurrentPower.Name)
                PowerLabel:SetText(text)
            end
        end
    end
end)

PATH.Mobs.ChildRemoved:Connect(function(child)
    if child.Name:lower():find("boss") then
        table.clear(Status.Main.AltDamage)
        Status.Main.AltActive = false
    end
end)

RS.Remotes.NotifyItemDrop.OnClientEvent:Connect(function(d) if d and type(d) == "table" and d.name then Status.Cached.NewItem[d.name] = (Status.Cached.NewItem[d.name] or 0) + (d.quantity or 1) end end)
Remotes.StockUpdate.OnClientEvent:Connect(function(n, s) Status.Main.CurrentStock[n] = tonumber(s) end)
Remotes.UpSkillTree.OnClientEvent:Connect(function(d)
    if d then
        Status.Main.SkillTree.Nodes = d.Nodes or {}
        Status.Main.SkillTree.SkillPoints = d.SkillPoints or d.Points or 0
        pcall(UpdateSkillTreeInfoPanel)
    end
end)

task.spawn(function()
    task.wait(1)
    if Remotes.GetSkillTreeData then
        local success, d = pcall(function()
            return Remotes.GetSkillTreeData:InvokeServer()
        end)
        if success and d then
            if not d.Unlocked and Remotes.SkillTreeUnlock then
                pcall(function() Remotes.SkillTreeUnlock:FireServer() end)
                task.wait(0.5)
                local success2, d2 = pcall(function() return Remotes.GetSkillTreeData:InvokeServer() end)
                if success2 and d2 then d = d2 end
            end
            Status.Main.SkillTree.Nodes = d.Nodes or {}
            Status.Main.SkillTree.SkillPoints = d.SkillPoints or d.Points or 0
            pcall(UpdateSkillTreeInfoPanel)
        end
    end
end)
Remotes.SettingsSync.OnClientEvent:Connect(function(d) Status.Main.Settings = d end)
Remotes.TitleSync.OnClientEvent:Connect(function(d) Tables.UnlockedTitle = d.unlocked or {} end)
Remotes.TradeUpdated.OnClientEvent:Connect(function(d) Status.Main.TradeState = d end)

function AddSliderToggle(Config)
    local Toggle = Config.Group:AddToggle({
        Title = Config.Text,
        Flag = Config.Id,
        Default = Config.DefaultToggle or false
    })
    
    local Slider = Config.Group:AddSlider({
        Title = Config.Text,
        Flag = Config.Id .. "Value",
        Default = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Rounding = Config.Rounding or 0,
        Visible = false
    })

    Toggle:OnChanged(function()
        Slider:SetVisible(Toggle.Value)
    end)

    return Toggle, Slider
end

local function CreateSwitchGroup(tab, id, displayName, tableSource)
    local toggle = tab:AddToggle({ Title = "Auto Switch "..displayName, Flag = "Auto"..id, Default = false })
    
    toggle:OnChanged(function(state)
        if not state then
            Status.Main.LastSwitch[id] = ""
        end
    end)

    local listToUse = (id == "Title") and CombinedTitleList or tableSource

    tab:AddDropdown({ Title = "Select Default "..displayName, Flag = "Default"..id, Options = listToUse })
    tab:AddDropdown({ Title = displayName.." [Mob]", Flag = id.."_Mob", Options = listToUse })
    tab:AddDropdown({ Title = displayName.." [Boss]", Flag = id.."_Boss", Options = listToUse })
    tab:AddDropdown({ Title = displayName.." [Combo F Move]", Flag = id.."_Combo", Options = listToUse })
    tab:AddDropdown({ Title = displayName.." [Boss HP%]", Flag = id.."_BossHP", Options = listToUse })
    
    tab:AddSlider({ Title = "Change Until Boss HP%", Flag = id.."_BossHPAmt", Default = 15, Min = 0, Max = 100 })
end

function gsc(guiObject)
    if not guiObject then return false end
    
    local success = false
    pcall(function()
        if Gui and VIM then
            Gui.SelectedObject = guiObject
            task.wait(0.05)
            
            local keys = {Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter, Enum.KeyCode.ButtonA}
            for _, key in ipairs(keys) do
                VIM:SendKeyEvent(true, key, false, game); task.wait(0.03)
                VIM:SendKeyEvent(false, key, false, game); task.wait(0.03)
            end

            Gui.SelectedObject = nil
            success = true
        end
    end)
    
    return success
end

local function UpdateAscendUI(data)
    if data.isMaxed then
        Tables.AscendLabels[1]:SetText("⭐ Max Ascension Reached!")
        Tables.AscendLabels[1]:SetVisible(true)
        for i = 2, 10 do Tables.AscendLabels[i]:SetVisible(false) end
        return
    end

    local reqs = data.requirements or {}
    for i = 1, 10 do
        local req = reqs[i]
        local label = Tables.AscendLabels[i]
        
        if req then
            local displayText = req.display:gsub("<[^>]+>", "")
            local status = req.completed and " ✅" or " ❌"
            local progress = string.format(" (%s/%s)", CommaFormat(req.current), CommaFormat(req.needed))
            
            label:SetText("- " .. displayText .. progress .. status)
            label:SetVisible(true)
        else
            label:SetVisible(false)
        end
    end
end

local function UpdateStatsLabel()
    if not StatsLabel then return end
    local text = ""
    local hasData = false
    
    for _, statName in ipairs(Tables.GemStat) do
        local data = Status.Main.GemStats[statName]
        if data then
            hasData = true
            text = text .. string.format("<b>%s:</b> %s\n", statName, tostring(data.Rank))
        end
    end
    
    if not hasData then
        StatsLabel:SetText("<i>No data. Reroll once to sync.</i>")
    else
        StatsLabel:SetText(text)
    end
end

local function UpdateSpecPassiveLabel()
    if not SpecPassiveLabel then return end
    
    local text = ""
    local selectedWeapons = Options.SelectedPassive.Value or {}
    local hasAny = false

    if type(Status.Main.Passives) ~= "table" then 
        Status.Main.Passives = {} 
    end

    for weaponName, isEnabled in pairs(selectedWeapons) do
        if isEnabled then
            hasAny = true
            
            local data = Status.Main.Passives[weaponName]
            local displayName = "None"

            if type(data) == "table" then
                displayName = tostring(data.Name or "None")
            elseif type(data) == "string" then
                displayName = data
            end

            text = text .. string.format("<b>%s:</b> %s\n", tostring(weaponName), displayName)
        end
    end

    if not hasAny then
        SpecPassiveLabel:SetText("<i>No weapons selected.</i>")
    else
        SpecPassiveLabel:SetText(text)
    end
end

local function GetCharacter()
    local c = Plr.Character
    return (c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid")) and c or nil
end

local function GetPlayerByName(name)
    name = name:lower()
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
    return nil
end

local function PanicStop()
    Status.Main.Farm = false
    Status.Main.AltActive = false
    Status.Main.GlobalPrio = "FARM"
    Status.Main.Target = nil
    Status.Main.MovingIsland = false
    
    for _, toggle in pairs(Toggles) do
        if toggle.SetValue then
            toggle:SetValue(false)
        end
    end
    
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        root.CFrame = root.CFrame * CFrame.new(0, 2, 0)
    end
    
    task.delay(0.5, function()
        Status.Main.Farm = true
    end)

    Library:Notify("Stopped.", 5)
end

local function FuncTPW()
    while true do
        local delta = RunService.Heartbeat:Wait()
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hum and hum.Health > 0 then
            if hum.MoveDirection.Magnitude > 0 then
                local speed = Options.TPWValue.Value
                char:TranslateBy(hum.MoveDirection * speed * delta * 10)
            end
        end
    end
end

local function FuncNoclip()
    while Toggles.Noclip.Value do
        RunService.Stepped:Wait()
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then 
                    part.CanCollide = false 
                end
            end
        end
    end
end

local function Func_AntiKnockback()
    if type(Status.Connections.Knockback) == "table" then
        for _, conn in pairs(Status.Connections.Knockback) do 
            if conn then conn:Disconnect() end 
        end
        table.clear(Status.Connections.Knockback)
    else
        Status.Connections.Knockback = {}
    end

    local function ApplyAntiKB(character)
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart", 10)
        
        if root then
            local conn = root.ChildAdded:Connect(function(child)
                if not Toggles.AntiKnockback.Value then return end
                
                if child:IsA("BodyVelocity") and child.MaxForce == Vector3.new(40000, 40000, 40000) then
                    child:Destroy()
                end
            end)
            table.insert(Status.Connections.Knockback, conn)
        end
    end

    if Plr.Character then
        ApplyAntiKB(Plr.Character)
    end

    local charAddedConn = Plr.CharacterAdded:Connect(function(newChar)
        ApplyAntiKB(newChar)
    end)
    table.insert(Status.Connections.Knockback, charAddedConn)

    repeat task.wait(1) until not Toggles.AntiKnockback.Value

    for _, conn in pairs(Status.Connections.Knockback) do 
        if conn then conn:Disconnect() end 
    end
    table.clear(Status.Connections.Knockback)
end

local function DisableIdled()
    pcall(function()
        if getconnections then
            for _, v in pairs(getconnections(Plr.Idled)) do
                if v.Disable then v:Disable()
                elseif v.Disconnect then v:Disconnect() end
            end
        end
    end)
end

local function PulseAntiAFK()
    pcall(function()
        VU:CaptureController()
        VU:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.08)
        VU:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    pcall(function()
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:Move(Vector3.new(0.2, 0, 0), true)
            task.wait(0.05)
            hum:Move(Vector3.zero, true)
        end
    end)
end

local function Func_AntiKickClient()
    if Status.Misc.AntiKickHooked then return end

    local hasHookMeta = type(hookmetamethod) == "function"
    local hasNewCClosure = type(newcclosure) == "function"
    if not (hasHookMeta and hasNewCClosure) then
        Library:Notify("Anti Kick (Client) unsupported on this executor.", 4)
        return
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod and getnamecallmethod()

        if Toggles.AntiKick and Toggles.AntiKick.Value and self == Plr and method and tostring(method):lower() == "kick" then
            Library:Notify("Blocked a client-side kick attempt.", 3)
            return nil
        end

        return oldNamecall(self, ...)
    end))

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if Toggles.AntiKick and Toggles.AntiKick.Value and self == Plr and tostring(key):lower() == "kick" then
            return function() return nil end
        end

        return oldIndex(self, key)
    end))

    Status.Misc.AntiKickHooked = true
end

local function Func_AutoReconnect()
    if Status.Connections.Reconnect then Status.Connections.Reconnect:Disconnect() end

    Status.Connections.Reconnect = Gui.ErrorMessageChanged:Connect(function()
        if not Toggles.AutoReconnect.Value then return end

        task.delay(2, function()
            pcall(function()
                local promptOverlay = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
                if promptOverlay then
                    local errorPrompt = promptOverlay.promptOverlay:FindFirstChild("ErrorPrompt")
                    
                    if errorPrompt and errorPrompt.Visible then
                        local secondaryTimer = 5
                        
                        task.wait(secondaryTimer)
                        
                        TP:Teleport(game.PlaceId, Plr)
                    end
                end
            end)
        end)
    end)
end

local function Func_NoGameplayPaused()
    while Toggles.NoGameplayPaused.Value do
        local success, err = pcall(function()
            local pauseGui = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
            if pauseGui then
                pauseGui:Destroy()
            end
        end)
        task.wait(1)
    end
end

local function Func_MemoryMonitor()
    local StatsService = game:GetService("Stats")
    
    while Toggles.AutoRejoinMemory.Value do
        local currentMemory = StatsService:GetTotalMemoryUsageMb()
        local limit = Options.MemoryLimit.Value
        
        if currentMemory >= limit then
            Library:Notify(string.format("Memory Limit Reached: %.0fMB. Sending Webhook & Rejoining...", currentMemory), 5)
            
            local url = Options.WebhookURL.Value
            if url and url ~= "" and url:find("discord.com/api/webhooks/") then
                task.spawn(function()
                    pcall(function()
                        local payload = {
                            ["embeds"] = {{
                                ["title"] = "💾 Auto Rejoin",
                                ["description"] = "ROBLOX's memory reached set amount.",
                                ["color"] = 16753920,
                                ["fields"] = {
                                    { ["name"] = "Player", ["value"] = "`" .. Plr.Name .. "`", ["inline"] = true },
                                    { ["name"] = "Usage", ["value"] = string.format("`%.0f MB` / `%.0f MB`", currentMemory, limit), ["inline"] = true },
                                    { ["name"] = "JobId", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
                                },
                                ["footer"] = { ["text"] = "SolanaHub Community • " .. os.date("%x %X") }
                            }}
                        }
                        httprequest({ 
                            Url = url, 
                            Method = "POST", 
                            Headers = {["Content-Type"] = "application/json"}, 
                            Body = Http:JSONEncode(payload) 
                        })
                    end)
                end)
            end

            task.wait(3)
            
            if #game:GetService("Players"):GetPlayers() <= 1 then
                Plr:Kick("\n[SolanaHub Community]\nRejoining (" .. math.floor(currentMemory) .. "MB)")
                task.wait(0.5)
                TP:Teleport(game.PlaceId, Plr)
            else
                TP:Teleport(game.PlaceId, Plr)
            end
        end
        
        task.wait(2)
    end
end

local function ApplyFPSBoost(state)
    if not state then return end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
        task.spawn(function()
            for i, v in pairs(workspace:GetDescendants()) do
                if Toggles.FPSBoost and not Toggles.FPSBoost.Value then break end
                pcall(function()
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end)
                if i % 500 == 0 then task.wait() end
            end
        end)
    end)
end

local function ApplyIslandWipe()
    if not Toggles.FPSBoost_AF.Value then return end

    task.spawn(function()
        local TravelConfig = Modules.Travel
        if not TravelConfig then return end

        -- 1. Pause Farm to prevent conflicts
        local originalFarmState = Status.Main.Farm
        Status.Main.Farm = false
        Status.Main.Target = nil
        
        local char = GetCharacter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then Status.Main.Farm = originalFarmState return end

        local protectKeywords = {"SpawnPointCrystal_", "Portal_", "QuestNPC", "NPCs", "ServiceNPCs", "Main Temple"}
        local problemIslands = {
            {Internal = "JudgementIsland", Base = "Judgement"},
            {Internal = "SlimeIsland", Base = "Slime"}
        }

        local function shouldProtect(name)
            for _, kw in ipairs(protectKeywords) do
                if name:find(kw) then return true end
            end
            return false
        end

        local function PerformRecursiveWipe()
            -- Wipe Island Folders
            for _, obj in ipairs(workspace:GetChildren()) do
                local name = obj.Name:lower()
                if name:find("island") or name == "shibuyastation" or name == "huecomundo" then
                    local descendants = obj:GetDescendants()
                    for i = 1, #descendants do
                        local target = descendants[i]
                        if (target:IsA("BasePart") or target:IsA("Model") or target:IsA("MeshPart")) then
                            if not shouldProtect(target.Name) then
                                pcall(function() target:Destroy() end)
                            end
                        end
                    end
                end
            end

            -- Wipe loose parts in Workspace root (Crucial for Judgement/Slime)
            for _, v in ipairs(workspace:GetChildren()) do
                if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) and not shouldProtect(v.Name) then
                    if v.Name ~= "Terrain" and v ~= char then 
                        pcall(function() v:Destroy() end) 
                    end
                end
            end
        end

        -- Save position and enable Noclip
        local originalCF = root.CFrame
        local oldNoclip = Toggles.Noclip.Value
        Toggles.Noclip:SetValue(true)

        for _, data in ipairs(problemIslands) do
            local zoneData = TravelConfig.Zones[data.Internal]
            local portal = Tables.IslandCrystals[data.Base]
            local islandFolder = workspace:FindFirstChild(data.Internal)

            if zoneData then
                -- Step A: Teleport to Portal/Crystal first
                if portal then
                    root.CFrame = portal:GetPivot() * CFrame.new(0, 10, 0)
                    task.wait(1.5)
                    PerformRecursiveWipe()
                end

                -- Step B: Teleport to Island Center (Forces full load of ungrouped parts)
                root.CFrame = CFrame.new(zoneData.Center) * CFrame.new(0, 50, 0)
                task.wait(2.5) -- Wait longer for the engine to load the center area

                -- Step C: Enforce cleanup until child count is < 10
                local attempts = 0
                repeat
                    PerformRecursiveWipe()
                    task.wait(1)
                    attempts = attempts + 1
                    
                    local currentChildren = islandFolder and #islandFolder:GetChildren() or 0
                until currentChildren <= 10 or attempts >= 4
            end
        end

        -- Final Root Cleanup while returning
        for _, v in ipairs(workspace:GetChildren()) do
            if (v:IsA("BasePart") or v:IsA("MeshPart")) and not shouldProtect(v.Name) then
                if v.Name ~= "Terrain" then pcall(function() v:Destroy() end) end
            end
        end

        -- Restore player
        root.CFrame = originalCF
        Toggles.Noclip:SetValue(oldNoclip)
        Status.Main.Farm = originalFarmState
    end)
end

local function SendSafetyWebhook(targetPlayer, reason)
    local url = Options.WebhookURL.Value
    if url == "" or not url:find("discord.com/api/webhooks/") then return end

    local payload = {
        ["embeds"] = {{
            ["title"] = "⚠️ Auto Kick",
            ["description"] = "Someone joined you blud",
            ["color"] = 16711680,
            ["fields"] = {
                { ["name"] = "Username", ["value"] = "`" .. targetPlayer.Name .. "`", ["inline"] = true },
                { ["name"] = "Type", ["value"] = reason, ["inline"] = true },
                { ["name"] = "ID", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
            },
            ["footer"] = { ["text"] = "SolanaHub Community • " .. os.date("%x %X") }
        }}
    }

    task.spawn(function()
        pcall(function()
            httprequest({ 
                Url = url, 
                Method = "POST", 
                Headers = {["Content-Type"] = "application/json"}, 
                Body = Http:JSONEncode(payload) 
            })
        end)
    end)
end

local function CheckServerTypeSafety()
    if not Toggles.AutoKick.Value then return end
    local kickTypes = Options.SelectedKickType.Value or {}

    if kickTypes["Public Server"] then
        local success, serverType = pcall(function()
            local remote = game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType", 2)
            if remote then
                return remote:InvokeServer()
            end
            return "Unknown"
        end)

        if success and serverType ~= "VIPServer" then
            local url = Options.WebhookURL.Value
            if url ~= "" and url:find("discord.com/api/webhooks/") then
                local payload = {
                    ["embeds"] = {{
                        ["title"] = "⚠️ Auto Kick",
                        ["description"] = "Kicked because in Public server.",
                        ["color"] = 16753920,
                        ["fields"] = {
                            { ["name"] = "Username", ["value"] = "`" .. Plr.Name .. "`", ["inline"] = true },
                            { ["name"] = "JobId", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
                        },
                        ["footer"] = { ["text"] = "SolanaHub Community" }
                    }}
                }
                task.spawn(function()
                    pcall(function()
                        httprequest({ 
                            Url = url, 
                            Method = "POST", 
                            Headers = {["Content-Type"] = "application/json"}, 
                            Body = Http:JSONEncode(payload) 
                        })
                    end)
                end)
            end

            task.wait(0.8)
            Plr:Kick("\n[SolanaHub Community]\nReason: You are in a public server.")
        end
    end
end

local function CheckPlayerForSafety(targetPlayer)
    if not Toggles.AutoKick.Value then return end
    if targetPlayer == Plr then return end
    
    local kickTypes = Options.SelectedKickType.Value or {}
    
    if kickTypes["Player Join"] then
        SendSafetyWebhook(targetPlayer, "Player Join Detection")
        
        task.wait(0.5) 
        Plr:Kick("\n[SolanaHub Community]\nReason: A player joined the server (" .. targetPlayer.Name .. ")")
        return
    end

    if kickTypes["Mod"] then
        local success, rank = pcall(function() return targetPlayer:GetRankInGroup(Status.Misc.GroupId) end)
        if success and table.find(Status.Misc.Rank, rank) then
            SendSafetyWebhook(targetPlayer, "Moderator Detection (Rank: " .. tostring(rank) .. ")")
            
            task.wait(0.5)
            Plr:Kick("\n[SolanaHub Community]\nReason: Moderator Detected (" .. targetPlayer.Name .. ")")
        end
    end
end

local function ACThing(state)
    if Status.Connections.Dash then Status.Connections.Dash:Disconnect() end
    if not (state and Remotes._DR) then return end

    Status.Connections.Dash = S.RunService.Heartbeat:Connect(function()
        local randDir = vector.create(0, 0, 0)
        local randPower = 0 
        task.spawn(function()
            Remotes._DR:FireServer(randDir, randPower, false)
        end)
    end)
end

local function InitAutoKick()
    CheckServerTypeSafety()

    for _, p in ipairs(Players:GetPlayers()) do
        CheckPlayerForSafety(p)
    end

    Players.PlayerAdded:Connect(CheckPlayerForSafety)
end

local function GetNearestIsland(targetPos, npcName)
    if npcName and Status.Main.BossTIMap[npcName] then
        return Status.Main.BossTIMap[npcName]
    end

    local nearestIsland = "Starter"
    local minDistance = math.huge

    for baseName, crystal in pairs(Tables.IslandCrystals) do
        if crystal then
            local dist = (targetPos - crystal:GetPivot().Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestIsland = baseName
            end
        end
    end
    
    return nearestIsland
end

local function UpdateNPCLists()
    local dropData = Modules.ItemDropConfig.Drops
    local uniqueMobs = {}
    
    for mobKey, _ in pairs(dropData) do
        if mobKey == "Default" then continue end

        local isBoss = mobKey:find("Boss") ~= nil
        local isMiniBoss = table.find(Tables.MiniBossList, mobKey) ~= nil
        
        if isBoss and not isMiniBoss then
            continue
        end

        local cleanName = mobKey:gsub("%d+$", "")
        
        if not uniqueMobs[cleanName] then
            uniqueMobs[cleanName] = true
        end
    end

    table.clear(Tables.MobList)
    for name, _ in pairs(uniqueMobs) do
        table.insert(Tables.MobList, name)
    end
    
    for _, name in ipairs(Tables.MobList) do
        for _, v in pairs(PATH.Mobs:GetChildren()) do
            if v.Name:match("^(.-)%d*$") == name then
                local npcPos = v:GetPivot().Position
                local closestIsland = "Unknown"
                local minDistance = math.huge
                
                for islandName, crystal in pairs(Tables.IslandCrystals) do
                    local dist = (npcPos - crystal:GetPivot().Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestIsland = islandName
                    end
                end
                Tables.MobToIsland[name] = closestIsland
                break
            end
        end
    end
    
    table.sort(Tables.MobList)
    Options.SelectedMob:SetValues(Tables.MobList)
end

local function UpdateAllEntities()
    table.clear(Tables.AllEntitiesList)
    local unique = {}
    for _, v in pairs(PATH.Mobs:GetChildren()) do
        local cleanName = v.Name:gsub("%d+$", "") 
        if not unique[cleanName] then
            unique[cleanName] = true
            table.insert(Tables.AllEntitiesList, cleanName)
        end
    end
    table.sort(Tables.AllEntitiesList)
    if Options.SelectedQuestline_DMGTaken then
        Options.SelectedQuestline_DMGTaken:SetValues(Tables.AllEntitiesList)
    end
end

local function PopulateNPCLists()
    table.clear(Tables.NPC_MovesetList)
    table.clear(Tables.NPC_MasteryList)

    local seenQuest = {}
    for _, name in ipairs(Tables.NPC_QuestList) do
        seenQuest[name] = true
    end
    local seenMoveset = {}
    local seenMastery = {}

    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^QuestNPC%d+$") then
            if not seenQuest[child.Name] then
                table.insert(Tables.NPC_QuestList, child.Name)
                seenQuest[child.Name] = true
            end
        end
    end

    for _, child in ipairs(PATH.InteractNPCs:GetChildren()) do
        if child.Name:match("^QuestNPC%d+$") then
            if not seenQuest[child.Name] then
                table.insert(Tables.NPC_QuestList, child.Name)
                seenQuest[child.Name] = true
            end
        end
    end

    table.sort(Tables.NPC_QuestList, function(a, b)
        local numA = tonumber(a:match("%d+$")) or 0
        local numB = tonumber(b:match("%d+$")) or 0
        return (numA == numB) and (a < b) or (numA < numB)
    end)

    local interactives = PATH.InteractNPCs:GetChildren()
    for _, v in pairs(interactives) do
        local name = v.Name
        if (name:find("Moveset") or name:find("Buyer")) and not name:find("Observation") and not seenMoveset[name] then
            table.insert(Tables.NPC_MovesetList, name)
            seenMoveset[name] = true
        end
        if (name:find("Mastery") or name:find("Questline") or name:find("Craft"))
        and not (name:find("Grail") or name:find("Slime")) and not seenMastery[name] then
            table.insert(Tables.NPC_MasteryList, name)
            seenMastery[name] = true
        end
    end
    table.sort(Tables.NPC_MovesetList)
    table.sort(Tables.NPC_MasteryList)

    SafeSetValues("SelectedQuestNPC", Tables.NPC_QuestList)
    SafeSetValues("SelectedMovesetNPC", Tables.NPC_MovesetList)
    SafeSetValues("SelectedMasteryNPC", Tables.NPC_MasteryList)
end

local function GetCurrentPity()
    local pityLabel = PGui:FindFirstChild("BossUI", true) and PGui:FindFirstChild("BossUI", true).MainFrame.BossHPBar.Pity
    if not pityLabel then return 0, 25 end -- Fallback if GUI isn't loaded
    
    -- Strip RichText tags (like <font>) just in case
    local rawText = pityLabel.Text:gsub("<[^>]+>", "")
    local current, max = rawText:match("Pity:%s*(%d+)/(%d+)")
    
    local curVal = tonumber(current) or 0
    local maxVal = tonumber(max) or 25
    
    -- Update your global label if it exists
    if PityLabel then
        PityLabel:SetText(string.format("Pity: %d/%d", curVal, maxVal))
    end
    
    return curVal, maxVal
end

local function IsSmartMatch(npcName, targetMobType)
    local n = npcName:gsub("%d+$", ""):lower()
    local t = targetMobType:lower()
    
    if n == t then return true end
    if t:find(n) == 1 then return true end 
    if n:find(t) == 1 then return true end
    
    return false
end

local function SafeTeleportToNPC(targetName, customMap)
    if not targetName or targetName == "" then
        return false
    end
    local character = GetCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local actualName = customMap and customMap[targetName] or targetName
    if not actualName or actualName == "" then
        return false
    end
    
    local target = workspace:FindFirstChild(actualName) or PATH.InteractNPCs:FindFirstChild(actualName)
    if not target then
        for _, v in pairs(PATH.InteractNPCs:GetChildren()) do
            if v.Name:find(actualName) then 
                target = v 
                break 
            end
        end
    end

    if target then
        local npcPivot = target:GetPivot()

        root.CFrame = npcPivot * CFrame.new(0, 3, 0)
        
        root.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0)
        root.AssemblyAngularVelocity = Vector3.zero
        return target
    else
        Library:Notify("NPC not found: " .. tostring(actualName), 3)
        return false
    end
end

local function Clean(str)
    return str:gsub("%s+", ""):lower()
end

local function GetRealToolName(tool)
    if not tool or not tool:IsA("Tool") then return "" end
    return tool:GetAttribute("_ToolName") or tool.Name
end

local function GetToolTypeFromModule(toolName)
    local cleanedTarget = Clean(toolName)

    for manualName, toolType in pairs(Tables.ManualWeaponClass) do
        if Clean(manualName) == cleanedTarget then
            return toolType
        end
    end

    if Modules.WeaponClass and Modules.WeaponClass.Tools then
        for moduleName, toolType in pairs(Modules.WeaponClass.Tools) do
            if Clean(moduleName) == cleanedTarget then
                return toolType
            end
        end
    end

    if toolName:lower():find("fruit") then
        return "Power"
    end

    return "Melee"
end

local function GetWeaponsByType()
    local available = {}
    local enabledTypes = Options.SelectedWeaponType.Value or {}
    local char = GetCharacter()
    
    local containers = {Plr.Backpack}
    if char then table.insert(containers, char) end

    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local realName = GetRealToolName(tool)
                local toolType = GetToolTypeFromModule(realName)
                
                if enabledTypes[toolType] then
                    if not table.find(available, realName) then
                        table.insert(available, realName)
                    end
                end
            end
        end
    end
    return available
end

local function UpdateWeaponRotation()
    local weaponList = GetWeaponsByType()
    
    if #weaponList == 0 then 
        Status.Main.ActiveWeap = "" 
        return 
    end

    local switchDelay = Options.SwitchWeaponCD.Value or 4
    if tick() - Status.Main.LastWRSwitch >= switchDelay then
        Status.Main.WeapRotationIdx = Status.Main.WeapRotationIdx + 1
        if Status.Main.WeapRotationIdx > #weaponList then Status.Main.WeapRotationIdx = 1 end
        
        Status.Main.ActiveWeap = weaponList[Status.Main.WeapRotationIdx]
        Status.Main.LastWRSwitch = tick()
    end

    local exists = false
    for _, name in ipairs(weaponList) do
        if name == Status.Main.ActiveWeap then exists = true break end
    end
    
    if not exists then
        Status.Main.ActiveWeap = weaponList[1]
    end
end

local function EquipWeapon()
    UpdateWeaponRotation()
    if Status.Main.ActiveWeap == "" then return end
    
    local char = GetCharacter()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local alreadyEquipped = false
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and GetRealToolName(obj) == Status.Main.ActiveWeap then
            alreadyEquipped = true
            break
        end
    end

    if alreadyEquipped then return end 
    
    local targetTool = nil
    for _, tool in ipairs(Plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and GetRealToolName(tool) == Status.Main.ActiveWeap then
            targetTool = tool
            break
        end
    end

    if targetTool then 
        hum:EquipTool(targetTool) 
    end
end

local function CheckObsHaki()
    local PlayerGui = Plr:FindFirstChild("PlayerGui")
    if PlayerGui then
        local DodgeUI = PlayerGui:FindFirstChild("DodgeCounterUI")
        if DodgeUI and DodgeUI:FindFirstChild("MainFrame") then
            return DodgeUI.MainFrame.Visible
        end
    end
    return false
end

local function CheckArmHaki()
    if Status.Main.ArmHaki == true then 
        return true 
    end

    local char = GetCharacter()
    if char then
        local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        
        local hasVisual = (leftArm and leftArm:FindFirstChild("Lightning Strike")) or 
                          (rightArm and rightArm:FindFirstChild("Lightning Strike"))
        
        if hasVisual then
            Status.Main.ArmHaki = true
            return true
        end
    end

    return false
end

local function IsBusy()
    return Plr.Character and Plr.Character:FindFirstChildOfClass("ForceField") ~= nil
end

local function IsSkillReady(key)
    local char = GetCharacter()
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return true end

    local keyMap = {["Z"] = 1, ["X"] = 2, ["C"] = 3, ["V"] = 4, ["F"] = 5}
    local slotIdx = keyMap[key] or 1

    local newUI = PGui:FindFirstChild("CD Ability UI")
    if newUI and newUI.Enabled then
        local specInfo = newUI:FindFirstChild("SpecInfoFrame")
        if specInfo then
            local skillHolders = {}
            for _, child in pairs(specInfo:GetChildren()) do
                if child.Name == "SkillMainHolder" then
                    table.insert(skillHolders, child)
                end
            end
            
            local holder = skillHolders[slotIdx]
            if holder then
                local skillHolder = holder:FindFirstChild("SkillHolder")
                local skillName = skillHolder and skillHolder:FindFirstChild("SkillName")
                
                if skillName then
                    local statusText = skillName.Text
                    if skillName:GetAttribute("ContentText") then
                        statusText = skillName:GetAttribute("ContentText")
                    end
                    
                    return not statusText:find("Unready")
                end
            end
        end
    end
    local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame")
    if mainFrame then
        local realToolName = GetRealToolName(tool)
        local cleanTool = Clean(realToolName)
        
        for _, frame in pairs(mainFrame:GetChildren()) do
            if not frame:IsA("Frame") then continue end
            local fname = frame.Name:lower()
            if fname:find("cooldown") and (fname:find(cleanTool) or fname:find("skill")) then
                local mapped = "none"
                if fname:find("skill 1") or fname:find("_z") then mapped = "Z"
                elseif fname:find("skill 2") or fname:find("_x") then mapped = "X"
                elseif fname:find("skill 3") or fname:find("_c") then mapped = "C"
                elseif fname:find("skill 4") or fname:find("_v") then mapped = "V"
                elseif fname:find("skill 5") or fname:find("_f") then mapped = "F" end

                if mapped == key then
                    local cdLabel = frame:FindFirstChild("WeaponNameAndCooldown", true)
                    return (cdLabel and cdLabel.Text:find("Ready"))
                end
            end
        end
    end

    return true -- Default to true if no UI found
end

local function GetSecondsFromTimer(text)
    local min, sec = text:match("(%d+):(%d+)")
    if min and sec then
        return (tonumber(min) * 60) + tonumber(sec)
    end
    return nil
end

local function FormatSecondsToTimer(s)
    local minutes = math.floor(s / 60)
    local seconds = s % 60
    return string.format("Refresh: %02d:%02d", minutes, seconds)
end

local function OpenMerchantInterface()
    if Env.IsXeno then
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("MerchantNPC")
        local prompt = npc and npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart:FindFirstChild("MerchantPrompt")
        
        if prompt then
            local char = GetCharacter()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local oldCF = root.CFrame
                
                root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.2)
                
                if Env.Support.Proximity then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.1)
                    prompt:InputHoldEnd()
                end
                
                task.wait(0.5)
                root.CFrame = oldCF
            end
        end
    else
        if firesignal then
            firesignal(Remotes.OpenMerchant.OnClientEvent)
        elseif getconnections then
            for _, v in pairs(getconnections(Remotes.OpenMerchant.OnClientEvent)) do
                if v.Function then task.spawn(v.Function) end
            end
        end
    end
end

local function SyncRaceSettings()
    if not Toggles.AutoRace.Value then return end

    pcall(function()
        local selected = Options.SelectedRace.Value or {}
        local hasEpic = false
        local hasLegendary = false
        
        for name, data in pairs(Modules.Race.Races) do
            local rarity = data.rarity or data.Rarity
            if rarity == "Mythical" then
                local shouldSkip = not selected[name]
                if Status.Main.Settings["SkipRace_" .. name] ~= shouldSkip then
                    Remotes.SettingsToggle:FireServer("SkipRace_" .. name, shouldSkip)
                end
            end
            if selected[name] then
                if rarity == "Epic" then hasEpic = true end
                if rarity == "Legendary" then hasLegendary = true end
            end
        end

        if Status.Main.Settings["SkipEpicReroll"] ~= not hasEpic then
            Remotes.SettingsToggle:FireServer("SkipEpicReroll", not hasEpic)
        end
        if Status.Main.Settings["SkipLegendaryReroll"] ~= not hasLegendary then
            Remotes.SettingsToggle:FireServer("SkipLegendaryReroll", not hasLegendary)
        end
    end)
end

local function SyncClanSettings()
    if not Toggles.AutoClan.Value then return end

    pcall(function()
        local selected = Options.SelectedClan.Value or {}
        local hasEpic = false
        local hasLegendary = false

        for name, data in pairs(Modules.Clan.Clans) do
            local rarity = data.rarity or data.Rarity
            
            if rarity == "Legendary" then
                local shouldSkip = not selected[name]
                if Status.Main.Settings["SkipClan_" .. name] ~= shouldSkip then
                    Remotes.SettingsToggle:FireServer("SkipClan_" .. name, shouldSkip)
                end
            end

            if selected[name] then
                if rarity == "Epic" then hasEpic = true end
                if rarity == "Legendary" then hasLegendary = true end
            end
        end

        if Status.Main.Settings["SkipEpicClan"] ~= not hasEpic then
            Remotes.SettingsToggle:FireServer("SkipEpicClan", not hasEpic)
        end
        if Status.Main.Settings["SkipLegendaryClan"] ~= not hasLegendary then
            Remotes.SettingsToggle:FireServer("SkipLegendaryClan", not hasLegendary)
        end
    end)
end

local function SyncSpecPassiveAutoSkip()
    local skipData = {
        ["Epic"] = true,
        ["Legendary"] = true,
        ["Mythical"] = true
    }
    pcall(function()
        local remote = Remotes.SpecPassiveSkip
        if remote then
            remote:FireServer(skipData)
        end
    end)
end

local function SyncPowerAutoSkip()
    if not Remotes.PowerSkip then return end
    pcall(function()
        local selected = Options.SelectedPower.Value or {}
        local skipData = { ["Epic"] = true, ["Legendary"] = true, ["Mythical"] = true }
        
        local lowestRarityValue = 99
        local rarityMap = { ["Epic"] = 1, ["Legendary"] = 2, ["Mythical"] = 3 }

        for name, enabled in pairs(selected) do
            if enabled then
                local data = Modules.Power and Modules.Power.Powers and Modules.Power.Powers[name]
                if data and data.Rarity then
                    local val = rarityMap[data.Rarity] or 0
                    if val > 0 and val < lowestRarityValue then lowestRarityValue = val end
                end
            end
        end

        if lowestRarityValue ~= 99 then
            skipData["Epic"] = 1 < lowestRarityValue
            skipData["Legendary"] = 2 < lowestRarityValue
            skipData["Mythical"] = 3 < lowestRarityValue
            Remotes.PowerSkip:FireServer(skipData)
        end
    end)
end

local function SyncTraitAutoSkip()
    if not Toggles.AutoTrait.Value then return end

    pcall(function()
    local selected = Options.SelectedTrait.Value or {}
    local rarityHierarchy = { ["Epic"] = 1, ["Legendary"] = 2, ["Mythical"] = 3, ["Secret"] = 4 }
    local lowestTargetValue = 99

    for traitName, enabled in pairs(selected) do
        if enabled then
            local data = Modules.Trait.Traits[traitName]
            if data then
                local val = rarityHierarchy[data.Rarity] or 0
                if val > 0 and val < lowestTargetValue then
                    lowestTargetValue = val
                end
            end
        end
    end

    if lowestTargetValue == 99 then return end

    local skipData = {
        ["Epic"] = 1 < lowestTargetValue,
        ["Legendary"] = 2 < lowestTargetValue,
        ["Mythical"] = 3 < lowestTargetValue,
        ["Secret"] = 4 < lowestTargetValue
    }

    Remotes.TraitAutoSkip:FireServer(skipData)
    end)
end

local function GetMatches(data, subStatFilter)
    local count = 0
    for _, sub in pairs(data.Substats or {}) do
        if subStatFilter[sub.Stat] then
            count = count + 1
        end
    end
    return count
end


local function IsStrictBossMatch(npcName, targetDisplayName)
    local internalId = Status.Main.BossMap[targetDisplayName]
    if not internalId then return false end
    
    local cleanNpcName = npcName:match("^([^_]+)") or npcName
    
    return cleanNpcName == internalId
end

local function AutoUpgradeLoop(mode)
    local toggle = Toggles["Auto"..mode]
    local allToggle = Toggles["Auto"..mode.."All"]
    local remote = (mode == "Enchant") and Remotes.Enchant or Remotes.Blessing
    local sourceTable = (mode == "Enchant") and Tables.OwnedAccessory or Tables.OwnedWeapon

    while toggle.Value or allToggle.Value do
        local selection = Options["Selected"..mode].Value or {}
        local workDone = false
        
        for _, itemName in ipairs(sourceTable) do
            if Status.Main.UpBlacklist[itemName] then continue end

            local isSelected = false
            if allToggle.Value then
                isSelected = true
            else
                isSelected = selection[itemName] or table.find(selection, itemName)
            end

            if isSelected then
                workDone = true
                pcall(function()
                    remote:FireServer(itemName)
                end)

                task.wait(1.5)
                break 
            end
        end

        if not workDone then
            Library:Notify("Stopping..", 5)
            toggle:SetValue(false)
            allToggle:SetValue(false)
            break
        end
        task.wait(0.1)
    end
end

local function FindRemoteDynamic(remoteName)
    local locations = {RS:FindFirstChild("Remotes"), RS:FindFirstChild("RemoteEvents")}
    for _, folder in pairs(locations) do
        if folder then
            local obj = folder:FindFirstChild(remoteName)
            if obj then return obj end
        end
    end
    return nil
end

local function FireBossRemote(bossDisplayName, diff)
    local internalId = Status.Main.BossMap[bossDisplayName] or bossDisplayName
    
    local registryData = BossRemoteRegistry[internalId] or BossRemoteRegistry[bossDisplayName]
    if registryData then
        local args = table.clone(registryData.Args)
        table.insert(args, diff)
        
        registryData.Remote:FireServer(unpack(args))
        return
    end

    local shortId = internalId:gsub("Boss$", "")
    local remoteNameWith = "RequestSpawn" .. internalId
    local remoteNameBoss = "RequestSpawn" .. shortId .. "Boss"
    local remoteNameWithout = "RequestSpawn" .. shortId
    
    if not Status.Cached.BossRemote[internalId] then
        Status.Cached.BossRemote[internalId] = FindRemoteDynamic(remoteNameWith) 
                                            or FindRemoteDynamic(remoteNameBoss) 
                                            or FindRemoteDynamic(remoteNameWithout)
    end

    local foundRemote = Status.Cached.BossRemote[internalId]
    if foundRemote then
        foundRemote:FireServer(diff)
        return
    end

    local summonId = Status.Main.SummonMap[bossDisplayName] or internalId
    Remotes.SummonBoss:FireServer(summonId, diff)
end

local function IsBossAlreadySpawned(displayName)
    local internalId = DisplayToInternal[displayName] or Status.Main.BossMap[displayName]
    if not internalId then return false end

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc.Name:find(internalId) then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function IsSummonable(displayName)
    -- 1. Check if it's a known summonable boss
    if table.find(Tables.SummonList, displayName) then return true end
    
    -- 2. Check your custom list
    if table.find(Tables.OtherSummonList, displayName) then return true end
    
    return false
end

local function HandleSummons()
    if tick() - Status.Main.LastSummon < 2 then return end
    
    if Status.Main.MerchantBusy then return end

    -- 1. Pity Summoning Logic
    if Toggles.PityBossFarm.Value then
        local current, max = GetCurrentPity()
        local buildOptions = Options.SelectedBuildPity and Options.SelectedBuildPity.Value or {}
        local useName = Options.SelectedUsePity and Options.SelectedUsePity.Value 
        
        if useName and next(buildOptions) then
            if current >= (max - 1) then
                local isSpawned = IsBossAlreadySpawned(useName)
                local isSummonable = IsSummonable(useName)
                
                if not isSpawned and isSummonable then
                    FireBossRemote(useName, Options.SelectedPityDiff.Value or "Normal")
                    Status.Main.LastSummon = tick()
                    return 
                end
            else
                -- Logic for normal summon when not at pity
                local anyBuildSpawned = false
                for bossName, enabled in pairs(buildOptions) do
                    if enabled and IsBossAlreadySpawned(bossName) then
                        anyBuildSpawned = true break
                    end
                end

                if not anyBuildSpawned then
                    for bossName, enabled in pairs(buildOptions) do
                        if enabled and IsSummonable(bossName) then
                            FireBossRemote(bossName, "Normal")
                            Status.Main.LastSummon = tick()
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Consolidated Auto-Summon
    if Toggles.AutoSummon.Value then
        local selected = Options.SelectedSummon.Value
        if selected and not IsBossAlreadySpawned(selected) and IsSummonable(selected) then
            FireBossRemote(selected, Options.SelectedSummonDiff.Value or "Normal")
            Status.Main.LastSummon = tick()
            DebugLog("SUMMON", ("AutoSummon -> %s (%s)"):format(tostring(selected), tostring(Options.SelectedSummonDiff.Value or "Normal")))
        end
    end

    if Toggles.AutoOtherSummon.Value then
        local selectedOther = Options.SelectedOtherSummon.Value
        if selectedOther and not IsBossAlreadySpawned(selectedOther) and IsSummonable(selectedOther) then
            FireBossRemote(selectedOther, Options.SelectedOtherSummonDiff.Value or "Normal")
            Status.Main.LastSummon = tick()
            DebugLog("SUMMON", ("AutoOtherSummon -> %s (%s)"):format(tostring(selectedOther), tostring(Options.SelectedOtherSummonDiff.Value or "Normal")))
        end
    end
end

local function UpdateSwitchState(target, farmType)
    if Status.Main.GlobalPrio == "COMBO" then return end

    local types = {
        { id = "Title", remote = Remotes.EquipTitle, method = function(val) return val end },
        { id = "Rune", remote = Remotes.EquipRune, method = function(val) return {"Equip", val} end },
        { id = "Build", remote = Remotes.LoadoutLoad, method = function(val) return tonumber(val) end }
    }

    for _, switch in ipairs(types) do
        local toggleObj = Toggles["Auto"..switch.id]
        if not (toggleObj and toggleObj.Value) then continue end

        if switch.id == "Build" and tick() - Status.Main.LastBuildSwitch < 3.1 then 
            continue 
        end

        local toEquip = ""
        local threshold = Options[switch.id.."_BossHPAmt"].Value
        local isLow = false
        
        if farmType == "Boss" and target then
            local hum = target:FindFirstChildOfClass("Humanoid")
            if hum and (hum.Health / hum.MaxHealth) * 100 <= threshold then
                isLow = true
            end
        end

        if farmType == "None" then toEquip = Options["Default"..switch.id].Value
        elseif farmType == "Mob" then toEquip = Options[switch.id.."_Mob"].Value
        elseif farmType == "Boss" then toEquip = isLow and Options[switch.id.."_BossHP"].Value or Options[switch.id.."_Boss"].Value end

        if not toEquip or toEquip == "" or toEquip == "None" then continue end

        local finalEquipValue = toEquip
        if switch.id == "Title" and toEquip:find("Best ") then
                local bestId = GetBestOwnedTitle(toEquip)
                if bestId then finalEquipValue = bestId else continue end
        end

        if finalEquipValue ~= Status.Main.LastSwitch[switch.id] then
            local args = switch.method(finalEquipValue)
            pcall(function()
                if type(args) == "table" then 
                    switch.remote:FireServer(unpack(args))
                else 
                    switch.remote:FireServer(args) 
                end
            end)
            
            Status.Main.LastSwitch[switch.id] = finalEquipValue
            
            if switch.id == "Build" then
                Status.Main.LastBuildSwitch = tick()
            end
        end
    end
end

local function UniversalPuzzleSolver(puzzleType)
    local function CollectPuzzleQuestCandidates(source, puzzleName, out, seen, depth)
        if depth > 4 or type(source) ~= "table" then return end
        for k, v in pairs(source) do
            local key = tostring(k):lower()
            if type(v) == "string" then
                local lowerV = v:lower()
                if key:find("quest") or key:find("npc") or lowerV:find("questnpc") or lowerV:find(puzzleName:lower()) then
                    if v ~= "" and not seen[v] then
                        seen[v] = true
                        table.insert(out, v)
                    end
                end
            elseif type(v) == "table" then
                CollectPuzzleQuestCandidates(v, puzzleName, out, seen, depth + 1)
            end
        end
    end

    local function TriggerNPCInteraction(target)
        if not target then return false end
        for _, desc in ipairs(target:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.RequiresLineOfSight = false
                desc.HoldDuration = 0
                pcall(fireproximityprompt, desc)
                return true
            end
            if desc:IsA("ClickDetector") and fireclickdetector then
                pcall(fireclickdetector, desc)
                return true
            end
        end
        return false
    end

    local function EnsurePuzzleQuestAccepted(puzzleName, configData)
        if puzzleName ~= "Demonite" and puzzleName ~= "Hogyoku" then
            return
        end

        local questCandidates, seen = {}, {}
        CollectPuzzleQuestCandidates(configData, puzzleName, questCandidates, seen, 1)

        for _, npc in ipairs(PATH.InteractNPCs:GetChildren()) do
            local npcName = npc.Name
            local lowerName = npcName:lower()
            if lowerName:find(puzzleName:lower()) or lowerName:find("quest") then
                if not seen[npcName] then
                    seen[npcName] = true
                    table.insert(questCandidates, npcName)
                end
            end
        end

        local fallbackMap = {
            Demonite = {"Academy", "Demonite", "DemoniteQuest", "DemoniteQuestNPC"},
            Hogyoku = {"Snow", "Hogyoku", "HogyokuQuest", "HogyokuQuestNPC"},
        }
        for _, candidate in ipairs(fallbackMap[puzzleName] or {}) do
            if not seen[candidate] then
                seen[candidate] = true
                table.insert(questCandidates, candidate)
            end
        end

        for _, candidate in ipairs(questCandidates) do
            if type(candidate) == "string" and candidate ~= "" then
                if candidate:match("^QuestNPC%d+$") and Remotes.QuestAccept then
                    pcall(function() Remotes.QuestAccept:FireServer(candidate) end)
                    task.wait(0.6)
                    if PGui:FindFirstChild("QuestUI") and PGui.QuestUI.Quest.Visible then
                        return true
                    end
                end

                local npcTarget = SafeTeleportToNPC(candidate)
                if npcTarget then
                    task.wait(0.5)
                    TriggerNPCInteraction(npcTarget)
                    task.wait(0.75)
                    if PGui:FindFirstChild("QuestUI") and PGui.QuestUI.Quest.Visible then
                        return true
                    end
                end
            end
        end

        return false
    end

    local moduleMap = {
        ["Dungeon"] = RS.Modules:FindFirstChild("DungeonConfig"),
        ["Slime"] = RS.Modules:FindFirstChild("SlimePuzzleConfig"),
        ["Demonite"] = RS.Modules:FindFirstChild("DemoniteCoreQuestConfig"),
        ["Hogyoku"] = RS.Modules:FindFirstChild("HogyokuQuestConfig")
    }
    
    local hogyokuIslands = {"Snow", "Shibuya", "HollowIsland", "Shinjuku", "Slime", "Judgement"}
    local targetModule = moduleMap[puzzleType]
    if not targetModule then return end
    
    local data = require(targetModule)
    local settings = data.PuzzleSettings or data.PieceSettings
    local piecesToCollect = data.Pieces or settings.IslandOrder
    local pieceModelName = settings and settings.PieceModelName or "DungeonPuzzlePiece"
    
    Library:Notify("Starting " .. puzzleType .. " Puzzle...", 5)
    EnsurePuzzleQuestAccepted(puzzleType, data)

    for i, islandOrPiece in ipairs(piecesToCollect) do
        local piece = nil
        local tpTarget = nil
        
    if puzzleType == "Demonite" then 
        tpTarget = "Academy"
    elseif puzzleType == "Hogyoku" then 
        tpTarget = hogyokuIslands[i]
    else
        if islandOrPiece == "HollowIsland" then
            tpTarget = "HollowIsland"
        else
            tpTarget = islandOrPiece:gsub("Island", ""):gsub("Station", "")
        end
    end
        
        if tpTarget then
            Remotes.TP_Portal:FireServer(tpTarget)
            task.wait(1.5)
        end

        if puzzleType == "Slime" and i == #piecesToCollect then
            local char = GetCharacter()
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                Remotes.TP_Portal:FireServer("Shinjuku")
                task.wait(1.5)
                Remotes.TP_Portal:FireServer("Slime")
                task.wait(1.5)
                root.CFrame = CFrame.new(788, 68, -2309)
                task.wait(1.5)
            end
        end

        if puzzleType == "Demonite" or puzzleType == "Hogyoku" then
            piece = workspace:FindFirstChild(islandOrPiece, true)
        else
            local islandFolder = workspace:FindFirstChild(islandOrPiece)
            piece = islandFolder and islandFolder:FindFirstChild(pieceModelName, true) or workspace:FindFirstChild(pieceModelName, true)
        end
        
        if piece then
            local char = Plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = piece:GetPivot() * CFrame.new(0, 3, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
            
            task.wait(0.5)

            local prompt = piece:FindFirstChildOfClass("ProximityPrompt") 
                or piece:FindFirstChild("PuzzlePrompt", true) 
                or piece:FindFirstChild("ProximityPrompt", true)
            
            if prompt then
                prompt.RequiresLineOfSight = false
                prompt.HoldDuration = 0
                
                fireproximityprompt(prompt)
                
                Library:Notify(string.format("Collected Piece %d/%d", i, #piecesToCollect), 2)
                task.wait(0.25)
            else
                Library:Notify("Found piece but no prompt was detected.", 3)
            end
        else
            Library:Notify("Failed to find piece " .. i .. " on " .. tostring(tpTarget or "Island"), 3)
        end
    end
    Library:Notify(puzzleType .. " Puzzle Completed!", 5)
end

local function GetCurrentQuestUI()
    local holder = PGui.QuestUI.Quest.Quest.Holder.Content
    local info = holder.QuestInfo
    return {
        Title = info.QuestTitle.QuestTitle.Text,
        Description = info.QuestDescription.Text,
        SwitchVisible = holder.QuestSwitchButton.Visible,
        SwitchBtn = holder.QuestSwitchButton,
        IsVisible = PGui.QuestUI.Quest.Visible
    }
end

local function AutoQuestlineLoop()
    local function normalizeSingleDropdownValue(value)
        if type(value) == "string" then
            return value ~= "" and value or nil
        end
        if type(value) ~= "table" then
            return nil
        end

        if type(value[1]) == "string" and value[1] ~= "" then
            return value[1]
        end

        for k, v in pairs(value) do
            if type(k) == "string" and v then
                return k
            end
        end
        return nil
    end

    local function getFallbackPlayerName()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                return p.Name
            end
        end
        return nil
    end

    local function getMobIslandByFuzzyName(targetName)
        if type(targetName) ~= "string" or targetName == "" then return nil end
        local hardcoded = {
            ["sea2quincymember"] = "Frost",
            ["rukiaboss"] = "Frost",
            ["frostempress"] = "Frost",
            ["quincy"] = "Frost",
            ["enelboss"] = "Punch",
            ["lightningboss"] = "Punch"
        }
        local needle = targetName:lower()
        if hardcoded[needle] then return hardcoded[needle] end
        for k, v in pairs(hardcoded) do
            if needle:find(k) or k:find(needle) then return v end
        end

        if Tables.MobToIsland[targetName] then
            return Tables.MobToIsland[targetName]
        end
        for mobName, island in pairs(Tables.MobToIsland) do
            local m = tostring(mobName):lower()
            if m:find(needle) or needle:find(m) then
                return island
            end
        end
        return nil
    end

    local function getPlayerIslandHint(targetPlayer)
        if not targetPlayer then return nil end
        local hints = {
            targetPlayer:GetAttribute("CurrentIsland"),
            targetPlayer:GetAttribute("Island"),
            targetPlayer:GetAttribute("CurrentZone"),
            targetPlayer:GetAttribute("Zone"),
        }
        for _, h in ipairs(hints) do
            if type(h) == "string" and h ~= "" then
                return h
            end
        end
        return nil
    end

    local lastQuestM1, lastQuestSkill = 0, 0
    local keyToSlot = { Z = 1, X = 2, C = 3, V = 4, F = 5 }

    local function fireQuestlineSkill()
        local selected = Options.SelectedSkills and Options.SelectedSkills.Value or {}
        local fired = false

        if type(selected) == "table" then
            local priority = {"Z", "X", "C", "V", "F"}
            for _, key in ipairs(priority) do
                if selected[key] and keyToSlot[key] then
                    Remotes.UseSkill:FireServer(keyToSlot[key])
                    fired = true
                    break
                end
            end
        end

        if not fired then
            Remotes.UseSkill:FireServer(math.random(1, 4))
        end
    end

    local function runQuestlineCombatOnTarget(target, enableQuestCombat, enableQuestSkill)
        if not target then return false end
        local char = GetCharacter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = target:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return false end

        local island = GetNearestIsland(target:GetPivot().Position, target.Name)
        Status.Main.Target = target
        Status.Main.TargetValid = true
        ExecuteFarmLogic(target, island, (target.Name:find("Boss") and "Boss") or "Mob")

        if not enableQuestCombat then
            return true
        end

        EquipWeapon()
        local m1Cd = tonumber(Options.M1Speed and Options.M1Speed.Value) or 0.2
        if tick() - lastQuestM1 >= math.max(0.05, m1Cd) then
            Remotes.M1:FireServer()
            lastQuestM1 = tick()
        end

        if enableQuestSkill and tick() - lastQuestSkill >= 0.7 then
            fireQuestlineSkill()
            lastQuestSkill = tick()
        end
        return true
    end

    local function findQuestlineMob(targetMobName)
        if type(targetMobName) ~= "string" or targetMobName == "" then return nil end
        for _, v in pairs(PATH.Mobs:GetChildren()) do
            if IsSmartMatch(v.Name, targetMobName) and IsValidTarget(v) then
                return v
            end
        end
        return nil
    end

    while Toggles.AutoQuestline.Value do
        task.wait(0.1)
        
        local selectedId = normalizeSingleDropdownValue(Options.SelectedQuestline.Value)
        if not selectedId then continue end
        
        local questData = Modules.Quests.Questlines[selectedId]
        if not questData then continue end

        local ui = GetCurrentQuestUI()
        local actualNPCName = questData.npcName 

        local isMatchingStage = false
        for _, stage in ipairs(questData.stages) do
            if stage.title == ui.Title then isMatchingStage = true break end
        end

        if not ui.IsVisible or not isMatchingStage then
            if ui.SwitchVisible and not isMatchingStage then
                gsc(ui.SwitchBtn)
                task.wait(1)
                ui = GetCurrentQuestUI()
            end
            if not isMatchingStage then
                if type(actualNPCName) == "string" and actualNPCName ~= "" then
                    Remotes.QuestAccept:FireServer(actualNPCName)
                else
                    DebugLog("QUESTLINE", "Skip QuestAccept: npcName missing", true)
                end
                task.wait(1.5)
                continue
            end
        end

        local currentStage = nil
        for _, stage in ipairs(questData.stages) do
            if stage.title == ui.Title then currentStage = stage break end
        end

        if currentStage then
            local taskType = currentStage.trackingType
            local enableQuestCombat = (not Toggles.QuestlineAutoCombat) or Toggles.QuestlineAutoCombat.Value
            local enableQuestSkill = Toggles.QuestlineAutoSkill and Toggles.QuestlineAutoSkill.Value

            if taskType == "CombatNPCKills" or taskType == "CombatPunches" or taskType == "GroundSmashUses" then
                local character = GetCharacter()
                local hasCombat = Plr.Backpack:FindFirstChild("Combat") or (character and character:FindFirstChild("Combat"))
                
                if not hasCombat then
                    Remotes.EquipWeapon:FireServer("Equip", "Combat")
                    
                    local timeout = 0
                    repeat
                        task.wait(0.2)
                        timeout = timeout + 1
                        hasCombat = Plr.Backpack:FindFirstChild("Combat") or (GetCharacter() and GetCharacter():FindFirstChild("Combat"))
                    until hasCombat or timeout > 15
                end

                Options.SelectedWeaponType:SetValue({["Melee"] = true})

                local targetEntity = findQuestlineMob("Thief")
                if targetEntity then
                    runQuestlineCombatOnTarget(targetEntity, enableQuestCombat, enableQuestSkill)
                end

                if taskType == "GroundSmashUses" then
                    Remotes.UseSkill:FireServer(1)
                    task.wait(1)
                elseif taskType == "CombatPunches" then
                    Remotes.M1:FireServer()
                    task.wait(0.2)
                end

            elseif taskType:find("Kills") and taskType ~= "PlayerKills" and not taskType:find("Boss") then
                local mobName = taskType:gsub("Kills", "")

                local targetName = mobName
                if mobName == "AnyNPC" or mobName == "HakiNPC" then
                    local pick = normalizeSingleDropdownValue(Options.SelectedQuestline_DMGTaken and Options.SelectedQuestline_DMGTaken.Value)
                    if pick then
                        targetName = pick
                    else
                        targetName = "Bandit"
                    end
                end

                if mobName == "HakiNPC" then
                    Toggles.ArmHaki:SetValue(true)
                end

                local targetEntity = findQuestlineMob(targetName)
                if targetEntity then
                    runQuestlineCombatOnTarget(targetEntity, enableQuestCombat, enableQuestSkill)
                else
                    local island = getMobIslandByFuzzyName(targetName)
                    if island then
                        Remotes.TP_Portal:FireServer(island)
                    end
                end

            elseif taskType == "DamageTaken" then
                local targetName = normalizeSingleDropdownValue(Options.SelectedQuestline_DMGTaken.Value)
                if type(targetName) == "string" and targetName ~= "" then
                    local targetEntity = nil
                    for _, v in pairs(PATH.Mobs:GetChildren()) do
                        if IsSmartMatch(v.Name, targetName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetEntity = v
                            break
                        end
                    end

                    if targetEntity then
                        local character = GetCharacter()
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = targetEntity:GetPivot() * CFrame.new(0, 0, 3)
                            root.AssemblyLinearVelocity = Vector3.zero
                            Status.Main.Target = targetEntity
                            Status.Main.TargetValid = true
                        end
                    else
                        local island = getMobIslandByFuzzyName(targetName)
                        if island then
                            Remotes.TP_Portal:FireServer(island)
                            DebugLog("QUESTLINE", "DamageTaken TP -> " .. tostring(island))
                        else
                            DebugLog("QUESTLINE", "DamageTaken: island hint not found for " .. tostring(targetName), true)
                        end
                    end
                end

            elseif taskType == "PlayerKills" then
                local targetName = normalizeSingleDropdownValue(Options.SelectedQuestline_Player.Value)
                if type(targetName) ~= "string" or targetName == "" then
                    targetName = getFallbackPlayerName()
                    if targetName then
                        SafeSetOptionValue("SelectedQuestline_Player", targetName, "Questline-PlayerFallback")
                        DebugLog("QUESTLINE", "Auto-selected player target: " .. targetName, true)
                    else
                        DebugLog("QUESTLINE", "PlayerKills waiting: no valid player target", true)
                        task.wait(1)
                        continue
                    end
                end
                local targetPlayer = Players:FindFirstChild(targetName)

                local tChar = targetPlayer and targetPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                local character = GetCharacter()
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if tRoot and root then
                    Status.Cached.PlayerLastPos[targetName] = tRoot.Position
                    if tHum and tHum.Health > 0 then
                        root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                        runQuestlineCombatOnTarget(tChar, enableQuestCombat, enableQuestSkill)
                    end
                elseif root then
                    local cachedPos = Status.Cached.PlayerLastPos[targetName]
                    if cachedPos then
                        root.CFrame = CFrame.new(cachedPos + Vector3.new(0, 3, 0))
                        DebugLog("QUESTLINE", "PlayerKills using cached position for " .. targetName)
                    else
                        local islandHint = getPlayerIslandHint(targetPlayer)
                        if islandHint then
                            Remotes.TP_Portal:FireServer(islandHint)
                            DebugLog("QUESTLINE", "PlayerKills TP by island hint -> " .. islandHint)
                        else
                            DebugLog("QUESTLINE", "PlayerKills: target not streamed yet for " .. targetName)
                        end
                    end
                end

            elseif taskType:find("BossKills") or taskType == "AnyBossKills" then
                if taskType ~= "AnyBossKills" then
                    local bossName = ""
                    local diff = "Normal"
                    for _, d in ipairs(Tables.DiffList) do
                        if taskType:find(d) then 
                            diff = d
                            bossName = taskType:gsub(d, ""):gsub("BossKills", "")
                            break 
                        end
                    end
                    if bossName == "" then bossName = taskType:gsub("BossKills", "") end
                    if bossName == "Rukia" then bossName = "Frost Empress" end

                    local lowerB = bossName:lower()
                    if lowerB:find("strongest") then
                        if lowerB:find("history") then bossName = "StrongestHistory"
                        elseif lowerB:find("today") then bossName = "StrongestToday" end
                    end

                    local foundBoss = findQuestlineMob(bossName)
                    if foundBoss then
                        runQuestlineCombatOnTarget(foundBoss, enableQuestCombat, enableQuestSkill)
                    else
                        local isRegular = table.find(Tables.SummonList, bossName)
                        local isOther = table.find(Tables.OtherSummonList, bossName)
                        if (isRegular or isOther) and tick() - Status.Main.LastSummon > 2 then
                            FireBossRemote(bossName, diff)
                            Status.Main.LastSummon = tick()
                            DebugLog("QUESTLINE", ("Boss summon request -> %s (%s)"):format(tostring(bossName), tostring(diff)))
                        else
                            local island = Status.Main.BossTIMap[bossName]
                            if island then
                                Remotes.TP_Portal:FireServer(island)
                            end
                        end
                    end
                else
                    local foundAnyBoss = nil
                    for _, npc in pairs(PATH.Mobs:GetChildren()) do
                        if npc.Name:find("Boss") and IsValidTarget(npc) then
                            foundAnyBoss = npc
                            break
                        end
                    end
                    if foundAnyBoss then
                        runQuestlineCombatOnTarget(foundAnyBoss, enableQuestCombat, enableQuestSkill)
                    end
                end

            elseif taskType:find("Piece") or taskType:find("Found") then
                local pType = taskType:find("Dungeon") and "Dungeon" or (taskType:find("Slime") and "Slime" or "Demonite" or "Hogyoku")
                UniversalPuzzleSolver(pType)

            elseif taskType:find("Has") and taskType:find("Race") then
                local race = taskType:gsub("Has", ""):gsub("Race", "")
                if Plr:GetAttribute("CurrentRace") ~= race then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                end
            elseif taskType == "MonarchClanCheck" then
                if Plr:GetAttribute("CurrentClan") ~= "Monarch" then
                    Remotes.UseItem:FireServer("Use", "Clan Reroll", 1)
                end
            elseif taskType == "DeemedWorthy" then
                Remotes.UseItem:FireServer("Use", "Worthiness Fragment", 1)

            elseif taskType == "SoulFragmentCollect" then
                local targetBoss = findQuestlineMob("RukiaBoss") or findQuestlineMob("Frost Empress")
                if targetBoss then
                    runQuestlineCombatOnTarget(targetBoss, enableQuestCombat, enableQuestSkill)
                else
                    Remotes.TP_Portal:FireServer("Frost")
                end

            elseif taskType == "SecretDropAsAngel" then
                if Plr:GetAttribute("CurrentRace") ~= "Angel" then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                    task.wait(1.5)
                else
                    local target = findQuestlineMob("Bandit") or findQuestlineMob("Thief") or PATH.Mobs:GetChildren()[1]
                    if target then
                        runQuestlineCombatOnTarget(target, enableQuestCombat, enableQuestSkill)
                    else
                        Remotes.TP_Portal:FireServer("Starter")
                    end
                end

            elseif taskType == "HiddenHaloFound" then
                local halo = workspace:FindFirstChild("AngelHalo1", true)
                if halo then
                    local char = Plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = halo:GetPivot() * CFrame.new(0, 3, 0)
                        task.wait(0.5)
                        local prompt = halo:FindFirstChildOfClass("ProximityPrompt") or halo:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                            task.wait(0.5)
                        end
                    end
                else
                    local spawns = {"HaloSpawn1", "HaloSpawn2", "HaloSpawn3", "HaloSpawn4"}
                    local targetSpawn = nil
                    for _, name in ipairs(spawns) do
                        local s = workspace:FindFirstChild(name, true)
                        if s then
                            targetSpawn = s
                            break
                        end
                    end
                    if targetSpawn then
                        local char = Plr.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local pos = targetSpawn:GetPivot().Position
                            local island = GetNearestIsland(pos)
                            if island and island ~= Status.Main.Island then
                                Remotes.TP_Portal:FireServer(island)
                                task.wait(1.5)
                            end
                            root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                            task.wait(1)
                        end
                    else
                        local searchIslands = {"Starter", "Jungle", "Desert", "Snow"}
                        local nextIsland = searchIslands[math.random(1, #searchIslands)]
                        Remotes.TP_Portal:FireServer(nextIsland)
                        task.wait(2)
                    end
                end

            elseif taskType == "BossHaloFound" then
                local bosses = {"Atomic Boss", "Strongest Shinobi", "Cosmic Being", "Sun God", "Spirit Warrior", "The World"}
                local targetBoss = nil
                for _, b in ipairs(bosses) do
                    local npc = findQuestlineMob(b)
                    if npc then
                        targetBoss = npc
                        break
                    end
                end
                if targetBoss then
                    runQuestlineCombatOnTarget(targetBoss, enableQuestCombat, enableQuestSkill)
                else
                    if tick() - Status.Main.LastSummon > 5 then
                        Remotes.RequestSpawnSpiritWarrior:FireServer()
                        Status.Main.LastSummon = tick()
                    end
                    task.wait(1)
                end

            elseif taskType == "NPCKillAsWraith" then
                if Plr:GetAttribute("CurrentRace") ~= "Wraith" then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                    task.wait(1.5)
                else
                    local target = findQuestlineMob("Bandit") or findQuestlineMob("Thief") or PATH.Mobs:GetChildren()[1]
                    if target then
                        runQuestlineCombatOnTarget(target, enableQuestCombat, enableQuestSkill)
                    else
                        Remotes.TP_Portal:FireServer("Starter")
                    end
                end

            elseif taskType == "RareSoulFound" then
                local bosses = {"HollowBoss", "RukiaBoss"}
                local targetBoss = nil
                for _, b in ipairs(bosses) do
                    local npc = findQuestlineMob(b)
                    if npc then
                        targetBoss = npc
                        break
                    end
                end
                if targetBoss then
                    runQuestlineCombatOnTarget(targetBoss, enableQuestCombat, enableQuestSkill)
                else
                    local isles = {"Hollow", "Frost"}
                    local targetIsle = isles[math.random(1, #isles)]
                    Remotes.TP_Portal:FireServer(targetIsle)
                    task.wait(2)
                end

            elseif taskType == "KrakenKillAsWraith" then
                if Plr:GetAttribute("CurrentRace") ~= "Wraith" then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                    task.wait(1.5)
                else
                    Toggles.SeaBeastFarm:SetValue(true)
                    task.wait(1)
                end

            elseif taskType == "RaidWinAsWraithNoDeath" then
                if Plr:GetAttribute("CurrentRace") ~= "Wraith" then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                    task.wait(1.5)
                else
                    Toggles.DungeonFarm:SetValue(true)
                    task.wait(1)
                end

            elseif taskType == "SpiritStoneConsume" then
                Remotes.UseItem:FireServer("Use", "Spirit Stone", 1)
                task.wait(1.5)

            elseif taskType == "SpiritWarriorWithMelee" then
                Options.SelectedWeaponType:SetValue({["Melee"] = true})
                local target = findQuestlineMob("SpiritWarrior") or findQuestlineMob("Spirit Warrior")
                if target then
                    runQuestlineCombatOnTarget(target, enableQuestCombat, enableQuestSkill)
                else
                    if tick() - Status.Main.LastSummon > 5 then
                        Remotes.RequestSpawnSpiritWarrior:FireServer()
                        Status.Main.LastSummon = tick()
                    end
                    task.wait(1)
                end

            end
        end
    end
end

local function IsValidTarget(npc)
    if not npc or not npc.Parent then return false end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if npc:GetAttribute("IK_Active") then
        return true
    end

    local minMaxHP = tonumber(Options.InstaKillMinHP.Value) or 0
    local isEligible = Toggles.InstaKill.Value and hum.MaxHealth >= minMaxHP

    if isEligible then
        return (hum.Health > 0) or (npc == Status.Main.Target)
    else
        return (hum.Health > 0)
    end
end

local function GetBestMobCluster(mobNamesDictionary)
    local allMobs = {}
    local clusterRadius = 35

    if type(mobNamesDictionary) ~= "table" then return nil end

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            local cleanName = npc.Name:gsub("%d+$", "")
            if mobNamesDictionary[cleanName] and IsValidTarget(npc) then
                table.insert(allMobs, npc)
            end
        end
    end

    if #allMobs == 0 then return nil end

    local bestMob = allMobs[1]
    local maxNearby = 0

    for _, mobA in ipairs(allMobs) do
        local nearbyCount = 0
        local posA = mobA:GetPivot().Position
        
        for _, mobB in ipairs(allMobs) do
            if (posA - mobB:GetPivot().Position).Magnitude <= clusterRadius then
                nearbyCount = nearbyCount + 1
            end
        end

        if nearbyCount > maxNearby then
            maxNearby = nearbyCount
            bestMob = mobA
        end
    end

    return bestMob, maxNearby
end

local function EnsureQuestSettings()
    local settings = PGui.SettingsUI.MainFrame.Frame.Content.SettingsTabFrame
    
    local tog1 = settings:FindFirstChild("Toggle_EnableQuestRepeat", true)
    if tog1 and tog1.SettingsHolder.Off.Visible then
        Remotes.SettingsToggle:FireServer("EnableQuestRepeat", true)
        task.wait(0.3)
    end

    local tog2 = settings:FindFirstChild("Toggle_AutoQuestRepeat", true)
    if tog2 and tog2.SettingsHolder.Off.Visible then
        Remotes.SettingsToggle:FireServer("AutoQuestRepeat", true)
    end
end

local function GetBestQuestNPC()
    local QuestModule = Modules.Quests
    local playerLevel = Plr.Data.Level.Value
    local bestNPC = "QuestNPC1"
    local highestLevel = -1

    for npcId, questData in pairs(QuestModule.RepeatableQuests) do
        local reqLevel = questData.recommendedLevel or 0
        if playerLevel >= reqLevel and reqLevel > highestLevel then
            highestLevel = reqLevel
            bestNPC = npcId
        end
    end
    return bestNPC
end

local function UpdateQuest()
    if not Toggles.LevelFarm.Value then return end
    
    EnsureQuestSettings()
    local targetNPC = GetBestQuestNPC()
    local questUI = PGui.QuestUI.Quest
    
    if Status.Main.QuestNPC ~= targetNPC or not questUI.Visible then
        
        Remotes.QuestAbandon:FireServer("repeatable")
        
        local abandonTimeout = 0
        while questUI.Visible and abandonTimeout < 15 do
            task.wait(0.2)
            abandonTimeout = abandonTimeout + 1
        end

        Remotes.QuestAccept:FireServer(targetNPC)
        
        local acceptTimeout = 0
        while not questUI.Visible and acceptTimeout < 20 do
            task.wait(0.2)
            acceptTimeout = acceptTimeout + 1
            
            if acceptTimeout % 5 == 0 then
                Remotes.QuestAccept:FireServer(targetNPC)
            end
        end

        if questUI.Visible then
            Status.Main.QuestNPC = targetNPC
        end
    end
end

local function GetPityTarget()
    if not Toggles.PityBossFarm.Value then return nil end
    local current, max = GetCurrentPity()
    local buildBosses = Options.SelectedBuildPity.Value or {}
    local useName = Options.SelectedUsePity.Value
    if not useName then return nil end

    local isUseTurn = (current >= (max - 1))
    
    if isUseTurn then
        for _, npc in pairs(PATH.Mobs:GetChildren()) do
            if IsStrictBossMatch(npc.Name, useName) and IsValidTarget(npc) then
                local island = Status.Main.BossTIMap[useName] or "Boss"
                return npc, island, "Boss"
            end
        end
    else
        for bossName, enabled in pairs(buildBosses) do
            if enabled then
                for _, npc in pairs(PATH.Mobs:GetChildren()) do
                    if IsStrictBossMatch(npc.Name, bossName) and IsValidTarget(npc) then
                        local island = Status.Main.BossTIMap[bossName] or "Boss"
                        return npc, island, "Boss"
                    end
                end
            end
        end
    end
    return nil
end

local function GetAllMobTarget()
    if not Toggles.AllMobFarm.Value then 
        Status.Main.AllMobIdx = 1 
        return nil 
    end

    local rotateList = {}
    for _, mobName in ipairs(Tables.MobList) do
        if mobName ~= "TrainingDummy" then
            table.insert(rotateList, mobName)
        end
    end

    if #rotateList == 0 then return nil end

    if Status.Main.AllMobIdx > #rotateList then Status.Main.AllMobIdx = 1 end
    
    local targetMobName = rotateList[Status.Main.AllMobIdx]
    local target, count = GetBestMobCluster({[targetMobName] = true})

    if target then
        local island = GetNearestIsland(target:GetPivot().Position, target.Name)
        return target, island, "Mob"
    else
        Status.Main.AllMobIdx = Status.Main.AllMobIdx + 1
        if Status.Main.AllMobIdx > #rotateList then Status.Main.AllMobIdx = 1 end
        return nil
    end
end

local function GetLevelFarmTarget()
    if not Toggles.LevelFarm.Value then return nil end
    
    UpdateQuest()
    
    if not PGui.QuestUI.Quest.Visible then return nil end
    
    local questData = Modules.Quests.RepeatableQuests[Status.Main.QuestNPC]
    if not questData or not questData.requirements[1] then return nil end
    
    local targetMobType = questData.requirements[1].npcType
    local matches = {}

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            if IsSmartMatch(npc.Name, targetMobType) then
                local cleanName = npc.Name:gsub("%d+$", "")
                matches[cleanName] = true
            end
        end
    end

    local bestMob, count = GetBestMobCluster(matches)
    
    if bestMob then
        local island = GetNearestIsland(bestMob:GetPivot().Position, bestMob.Name)
        return bestMob, island, "Mob"
    end
    
    return nil
end

local function GetSummonTarget()
    local selected
    if Toggles.SummonBossFarm.Value then
        selected = Options.SelectedSummon.Value
    elseif Toggles.OtherSummonFarm.Value then
        selected = Options.SelectedOtherSummon.Value
    else
        return nil
    end
    if not selected then return nil end

    local workspaceName = Status.Main.SummonMap[selected] or (selected .. "Boss")

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc.Name:lower():find(workspaceName:lower()) then
            if IsValidTarget(npc) then
                return npc, "Boss", "Boss"
            end
        end
    end
    return nil
end

local function GetWorldBossTarget()
    if Toggles.AllBossesFarm.Value then
        for _, npc in pairs(PATH.Mobs:GetChildren()) do
            local isBoss = npc.Name:find("Boss") and not table.find(Tables.MiniBossList, npc.Name)
            if isBoss and IsValidTarget(npc) then
                local island = "Boss"
                for dName, iId in pairs(Status.Main.BossMap) do
                    if npc.Name:find(iId) then
                        island = Status.Main.BossTIMap[dName] or "Boss"
                        break
                    end
                end
                return npc, island, "Boss"
            end
        end
    end

    if Toggles.BossesFarm.Value then
        local selected = Options.SelectedBosses.Value or {}
        for bossDisplayName, isEnabled in pairs(selected) do
            if isEnabled then
                local internalId = Status.Main.BossMap[bossDisplayName]
                for _, npc in pairs(PATH.Mobs:GetChildren()) do
                    if npc.Name:find(internalId) and IsValidTarget(npc) then
                        local island = Status.Main.BossTIMap[bossDisplayName] or "Boss"
                        return npc, island, "Boss"
                    end
                end
            end
        end
    end
    return nil
end

local function GetMobTarget()
    if not Toggles.MobFarm.Value then 
        Status.Main.MobIdx = 1 
        return nil 
    end

    local selectedDict = Options.SelectedMob and Options.SelectedMob.Value or {} -- NIL GUARD
    local enabledMobs = {}
    
    for mob, enabled in pairs(selectedDict) do
        if enabled then table.insert(enabledMobs, mob) end
    end
    table.sort(enabledMobs)

    if #enabledMobs == 0 then return nil end

    if Status.Main.MobIdx > #enabledMobs then Status.Main.MobIdx = 1 end
    
    local targetMobName = enabledMobs[Status.Main.MobIdx]
    local target, count = GetBestMobCluster({[targetMobName] = true})

    if target then
        local island = GetNearestIsland(target:GetPivot().Position, target.Name)
        return target, island, "Mob"
    else
        Status.Main.MobIdx = Status.Main.MobIdx + 1
        return nil
    end
end

local function ShouldMainWait()
    if not Toggles.AltBossFarm.Value then return false end
    
    local selectedAlts = {}
    for i = 1, 5 do
        local val = Options["SelectedAlt_" .. i].Value
        local name = (typeof(val) == "Instance" and val:IsA("Player")) and val.Name or tostring(val)
        
        if name and name ~= "" and name ~= "nil" and name ~= "None" then
            table.insert(selectedAlts, name)
        end
    end

    if #selectedAlts == 0 then return false end

    for _, altName in ipairs(selectedAlts) do
        local currentDmg = Status.Main.AltDamage[altName] or 0
        if currentDmg < 10 then
            return true 
        end
    end

    return false 
end

local function GetAltHelpTarget()
    if not Toggles.AltBossFarm.Value then return nil end
    
    local targetBossName = Options.SelectedAltBoss.Value
    if not targetBossName then return nil end

    local targetNPC = nil
    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if IsStrictBossMatch(npc.Name, targetBossName) then
            if IsValidTarget(npc) then
                targetNPC = npc
                break
            end
        end
    end

    if not targetNPC then
        FireBossRemote(targetBossName, Options.SelectedAltDiff.Value or "Normal")
        task.wait(0.5)
        return nil
    end

    Status.Main.AltActive = ShouldMainWait()
    
    local island = Status.Main.BossTIMap[targetBossName] or "Boss"
    return targetNPC, island, "Boss"
end

local function CheckTask(taskType)
    if taskType == "Merchant" then
        if Toggles.AutoMerchant.Value and Status.Main.MerchantBusy then
            return true, nil, "None"
        end
        return nil
    elseif taskType == "Pity Boss" then
        return GetPityTarget()
    elseif taskType == "Summon" then
        return GetSummonTarget()
    elseif taskType == "Boss" then
        return GetWorldBossTarget()
    elseif taskType == "Level Farm" then
        return GetLevelFarmTarget()
    elseif taskType == "All Mob Farm" then
        return GetAllMobTarget()
    elseif taskType == "Mob" then
        return GetMobTarget()
    elseif taskType == "Alt Help" then
        return GetAltHelpTarget()
    end
    return nil
end

local function GetNearestAuraTarget()
    local nearest = nil
    local maxRange = tonumber(Options.KillAuraRange.Value) or 200
    local lastDist = maxRange
    
    local char = Plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local myPos = root.Position
    local mobFolder = workspace:FindFirstChild("NPCs")
    if not mobFolder then return nil end

    for _, v in ipairs(mobFolder:GetChildren()) do
        if v:IsA("Model") then
            local npcPos = v:GetPivot().Position
            local dist = (myPos - npcPos).Magnitude
            
            if dist <= lastDist then
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    nearest = v
                    lastDist = dist
                end
            end
        end
    end
    return nearest
end

local function Func_KillAura()
    while Toggles.KillAura.Value do
        if IsBusy() then 
            task.wait(0.1) 
            continue 
        end

        local target = GetNearestAuraTarget()
        
        if target then
            EquipWeapon()
            
            local targetPos = target:GetPivot().Position
            
            pcall(function()
                Remotes.M1:FireServer(targetPos)
            end)
        end
        
        task.wait(tonumber(Options.KillAuraCD.Value) or 0.12)
    end
end

local function GetTargetAttackPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("RootPart")
        or model:FindFirstChild("SeaBeastHitbox")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart")
end

local function ExecuteFarmLogic(target, island, farmType, positionOverride)
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not target or Status.Main.Recovering or not root or not hum then return end

    if Status.Main.MovingIsland then return end
    Status.Main.Target = target

    if Toggles.IslandTP.Value then
        if island and island ~= "" and island ~= Status.Main.Island then
            Status.Main.MovingIsland = true
            
            Remotes.TP_Portal:FireServer(island)
            
            task.wait(tonumber(Options.IslandTPCD.Value) or 0.8)
            Status.Main.Island = island
            Status.Main.MovingIsland = false
            return
        end
    end

    local useFollowAttackPart = positionOverride and positionOverride.FollowAttackPart
    local attackPart = useFollowAttackPart and GetTargetAttackPart(target) or nil
    local targetPivot = attackPart and attackPart.CFrame or target:GetPivot()
    local targetPos = targetPivot.Position
    local distVal = (positionOverride and tonumber(positionOverride.Distance)) or tonumber(Options.Distance.Value) or 10
    local posType = (positionOverride and positionOverride.Type) or Options.SelectedFarmType.Value
    local useDynamicSafeDistance = positionOverride and positionOverride.DynamicSafeDistance
    local noBounce = positionOverride and positionOverride.NoBounce
    local parkMode = positionOverride and positionOverride.ParkMode
    local parkHeight = (positionOverride and tonumber(positionOverride.ParkHeight)) or 28
    local parkBack = (positionOverride and tonumber(positionOverride.ParkBack)) or distVal
    local parkSide = (positionOverride and tonumber(positionOverride.ParkSide)) or 0
    if useDynamicSafeDistance then
        local extents = Vector3.new(0, 0, 0)
        pcall(function()
            extents = target:GetExtentsSize()
        end)
        local horizontalSize = math.max(extents.X, extents.Z)
        local bonus = math.clamp(horizontalSize * 0.15, 0, 14)
        distVal = math.clamp(distVal + bonus, 8, 28)
    end
    
    local finalPos

    if parkMode then
        finalPos = (targetPivot * CFrame.new(parkSide, parkHeight, parkBack)).Position
    elseif Status.Main.AltActive then
        finalPos = targetPos + Vector3.new(0, 120, 0)
    elseif posType == "Above" then
        finalPos = targetPos + Vector3.new(0, distVal, 0)
    elseif posType == "Below" then
        finalPos = targetPos + Vector3.new(0, -distVal, 0)
    else
        finalPos = (targetPivot * CFrame.new(0, 0, distVal)).Position
    end

    local finalDestination = CFrame.lookAt(finalPos, targetPos)

    if noBounce then
        if Status.Cached.activeTween then
            Status.Cached.activeTween:Cancel()
            Status.Cached.activeTween = nil
        end
        root.CFrame = finalDestination
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        return
    end

    if (root.Position - finalPos).Magnitude > 0.1 then
        if Options.SelectedMovementType.Value == "Teleport" then
    root.CFrame = finalDestination
    else
    if (root.Position - finalPos).Magnitude > 2 then
        local distance = (root.Position - finalPos).Magnitude
        local speed = tonumber(Options.TweenSpeed.Value) or 180
        
        if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
        
        Status.Cached.activeTween = Tween:Create(root, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear), {CFrame = finalDestination})
        Status.Cached.activeTween:Play()
        
        Status.Cached.activeTween.Completed:Connect(function()
            if Status.Cached.activeTween then
                Status.Cached.activeTween:Destroy()
                Status.Cached.activeTween = nil
            end
        end)
    else
        if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
        root.CFrame = finalDestination
    end
end
end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function Func_WebhookLoop()
    while Toggles.SendWebhook.Value do
        PostToWebhook()
        local delay = math.max(Options.WebhookDelay.Value, 0.5) * 60
        task.wait(delay)
    end
end

local function Func_AutoHaki()
    while task.wait(0.5) do
        if Toggles.ObserHaki.Value and not CheckObsHaki() then
            Remotes.ObserHaki:FireServer("Toggle")
        end

        if Toggles.ArmHaki.Value and not CheckArmHaki() then
            Remotes.ArmHaki:FireServer("Toggle")
            task.wait(0.5) 
        end

        if Toggles.ConquerorHaki.Value then
            if Toggles.OnlyTarget.Value then
                if not Status.Main.Farm or not Status.Main.Target or not Status.Main.Target.Parent then
                    continue
                end
            end

            Remotes.ConquerorHaki:FireServer("Activate")
        end
    end
end

local function Func_AutoM1()
    while task.wait(Options.M1Speed.Value) do
        if Toggles.AutoM1.Value then
        Remotes.M1:FireServer()
        end
    end
end

local function Func_AutoSkill()
    local keyToEnum = { ["Z"] = Enum.KeyCode.Z, ["X"] = Enum.KeyCode.X, ["C"] = Enum.KeyCode.C, ["V"] = Enum.KeyCode.V, ["F"] = Enum.KeyCode.F }
    local keyToSlot = { ["Z"] = 1, ["X"] = 2, ["C"] = 3, ["V"] = 4, ["F"] = 5 }
    local priority = {"Z", "X", "C", "V", "F"}

    while task.wait() do
        if not Toggles.AutoSkill.Value then continue end

        local target = Status.Main.Target
        if Toggles.OnlyTarget.Value and (not Status.Main.Farm or not target or not target.Parent) then
            continue
        end

        local canExecute = true
        if Toggles.AutoSkill_BossOnly.Value then
            if not target or not target.Parent then
                canExecute = false
            else
                local npcHum = target:FindFirstChildOfClass("Humanoid")
                local isRealBoss = target.Name:find("Boss") and not table.find(Tables.MiniBossList, target.Name)
                local hpPercent = npcHum and (npcHum.Health / npcHum.MaxHealth * 100) or 101
                local threshold = tonumber(Options.AutoSkill_BossHP.Value) or 100

                if not isRealBoss or hpPercent > threshold then
                    canExecute = false
                end
            end
        end

        if canExecute and target and target.Parent then
            if target:FindFirstChild("IK_Active") and Options.InstaKillType.Value == "V1" then
                canExecute = false
            end
        end

        if not canExecute then continue end

        local char = GetCharacter()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not tool then continue end

        local toolName = tool.Name
        local toolType = GetToolTypeFromModule(toolName)
        local useMode = Options.AutoSkillType.Value
        local selected = Options.SelectedSkills.Value or {}

        if useMode == "Instant" then
            for _, key in ipairs(priority) do
                if selected[key] then
                    if toolType == "Power" then
                        Remotes.UseFruit:FireServer("UseAbility", {
                            ["FruitPower"] = toolName:gsub(" Fruit", ""), 
                            ["KeyCode"] = keyToEnum[key]
                        })
                    else
                        Remotes.UseSkill:FireServer(keyToSlot[key])
                    end
                end
            end
            task.wait(.01)
        else
            local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame")
            if not mainFrame then continue end

            for _, key in ipairs(priority) do
                if selected[key] then
                    if IsSkillReady(key) then
                        if toolType == "Power" then
                            Remotes.UseFruit:FireServer("UseAbility", {
                                ["FruitPower"] = toolName:gsub(" Fruit", ""), 
                                ["KeyCode"] = keyToEnum[key]
                            })
                        else
                            Remotes.UseSkill:FireServer(keyToSlot[key])
                        end
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
end

local function Func_AutoCombo()
    Status.Main.ComboIdx = 1
    
    while Toggles.AutoCombo.Value do
        task.wait(0.1)
        
        local rawPattern = Options.ComboPattern.Value
        if not rawPattern or rawPattern == "" then continue end
        Status.Main.ParsedCombo = {}
        for item in string.gmatch(rawPattern:upper():gsub("%s+", ""), "([^,>]+)") do
            table.insert(Status.Main.ParsedCombo, item)
        end
        if #Status.Main.ParsedCombo == 0 then continue end
        if Status.Main.ComboIdx > #Status.Main.ParsedCombo then Status.Main.ComboIdx = 1 end

        if IsBusy() then
            local waitStart = tick()
            repeat task.wait(0.1) until not IsBusy() or (tick() - waitStart > 8)
        end
        task.wait(0.4) 

        if Toggles.ComboBossOnly.Value then
            if not Status.Main.Target or not Status.Main.Target.Parent or not Status.Main.Target.Name:lower():find("boss") then
                Status.Main.ComboIdx = 1
                task.wait(0.5)
                continue
            end
        end

        local currentAction = Status.Main.ParsedCombo[Status.Main.ComboIdx]
        
        local waitTime = tonumber(currentAction)
        if waitTime then
            if Options.ComboMode.Value == "Normal" then task.wait(waitTime) end
            Status.Main.ComboIdx = Status.Main.ComboIdx + 1
            continue
        end

        if IsSkillReady(currentAction) then
            local isF = (currentAction == "F")

            if isF then
                Status.Main.GlobalPrio = "COMBO" 
                
                local cTitle = Options.Title_Combo.Value
                local cRune = Options.Rune_Combo.Value
                if cTitle and cTitle ~= "None" then Remotes.EquipTitle:FireServer(cTitle) end
                if cRune and cRune ~= "None" then Remotes.EquipRune:FireServer("Equip", cRune) end
                
                Status.Main.LastSwitch.Title = cTitle
                Status.Main.LastSwitch.Rune = cRune
                task.wait(0.7) 

                local uiConfirmed = false
                repeat
                    EquipWeapon()
                    Remotes.UseSkill:FireServer(5)
                    local check = tick()
                    repeat
                        task.wait(0.1)
                        if not IsSkillReady("F") then uiConfirmed = true end
                    until uiConfirmed or (tick() - check > 1.0)
                until uiConfirmed or not Toggles.AutoCombo.Value

                local ffStarted = false
                local catchTimer = tick()
                repeat
                    task.wait()
                    if IsBusy() then ffStarted = true end
                until ffStarted or (tick() - catchTimer > 2.0)

                if ffStarted then
                    local holdStart = tick()
                    repeat task.wait(0.1) until not IsBusy() or (tick() - holdStart > 15)
                else
                    task.wait(2.5) 
                end

                Status.Main.GlobalPrio = "FARM" 
                Status.Main.LastSwitch.Title = "" 
                Status.Main.LastSwitch.Rune = ""
                Status.Main.ComboIdx = Status.Main.ComboIdx + 1
                task.wait(0.3)

            else
                local slot = ({["Z"]=1, ["X"]=2, ["C"]=3, ["V"]=4})[currentAction] or 1
                
                local stepDone = false
                repeat
                    Remotes.UseSkill:FireServer(slot)
                    local check = tick()
                    repeat
                        task.wait(0.1)
                        if not IsSkillReady(currentAction) or IsBusy() then stepDone = true end
                    until stepDone or (tick() - check > 1.2)
                until stepDone or not Toggles.AutoCombo.Value

                if stepDone then
                    Status.Main.ComboIdx = Status.Main.ComboIdx + 1
                    task.wait(0.2)
                end
            end
        else
            task.wait(0.2)
        end
    end
end

local function Func_AutoStats()
    local pointsPath = Plr:WaitForChild("Data"):WaitForChild("StatPoints")

    while task.wait(1) do
        if not Toggles.AutoStats.Value then break end
        
        local availablePoints = pointsPath.Value
        if availablePoints > 0 then
            local selectedStats = Options.SelectedStats.Value or {}
            local activeStats = {}
            
            for statName, enabled in pairs(selectedStats) do
                if enabled then
                    local currentLevel = Status.Main.Stats[statName] or 0
                    
                    local statConfig = Modules.LevelingConfig.STATS[statName]
                    local maxPoints = statConfig and statConfig.maxPoints or 13000
                    
                    if currentLevel < maxPoints then
                        table.insert(activeStats, statName)
                    end
                end
            end
            
            local statCount = #activeStats
            if statCount > 0 then
                local pointsPerStat = math.floor(availablePoints / statCount)
                
                if pointsPerStat > 0 then
                    for _, stat in ipairs(activeStats) do
                        Remotes.AddStat:FireServer(stat, pointsPerStat)
                    end
                else
                    Remotes.AddStat:FireServer(activeStats[1], availablePoints)
                end
            end
        end
    end
end

local function AutoRollStatsLoop()
    local function ToSelectionSet(value)
        if type(value) ~= "table" then
            return {}
        end
        local result = {}
        local hasArrayPart = false
        for k, v in pairs(value) do
            if type(k) == "number" then
                hasArrayPart = true
                result[v] = true
                result[tostring(v)] = true
            elseif v then
                result[k] = true
                result[tostring(k)] = true
            end
        end
        if hasArrayPart then
            for _, v in ipairs(value) do
                result[v] = true
                result[tostring(v)] = true
            end
        end
        return result
    end

    local selectedStats = ToSelectionSet(Options.SelectedGemStats.Value or {})
    local selectedRanks = ToSelectionSet(Options.SelectedRank.Value or {})
    
    local hasStat = false; for _ in pairs(selectedStats) do hasStat = true break end
    local hasRank = false; for _ in pairs(selectedRanks) do hasRank = true break end

    if not hasStat or not hasRank then
        Library:Notify("Error: Select at least one Stat and one Rank first!", 5)
        Toggles.AutoRollStats:SetValue(false)
        return
    end

    while Toggles.AutoRollStats.Value do
        if not next(Status.Main.GemStats) then
            task.wait(0.1)
            continue
        end

        local workDone = true
        
        for _, statName in ipairs(Tables.GemStat) do
            if selectedStats[statName] then
                local currentData = Status.Main.GemStats[statName]
                
                if currentData then
                    local currentRank = currentData.Rank
                    local currentRankStr = tostring(currentRank)
                    
                    if not selectedRanks[currentRank] and not selectedRanks[currentRankStr] then
                        workDone = false
                        
                        local success, err = pcall(function()
                            Remotes.RerollSingleStat:InvokeServer(statName)
                        end)
                        
                        if not success then
                            Library:Notify("ERROR: " .. tostring(err):gsub("<", "["), 5)
                        end
                        
                        task.wait(tonumber(Options.StatsRollCD.Value) or 0.1)
                        
                        break 
                    end
                end
            end
        end

        if workDone then
            Library:Notify("Successfully rolled selected stats.", 5)
            Toggles.AutoRollStats:SetValue(false)
            break
        end
        
        task.wait()
    end
end

local function Func_UnifiedRollManager()
    while task.wait() do
        -- Priority 1: Traits
        if Toggles.AutoTrait.Value then
            local traitUIFrame = PGui:FindFirstChild("TraitRerollUI")
            local content = traitUIFrame and traitUIFrame:FindFirstChild("MainFrame")
                and traitUIFrame.MainFrame:FindFirstChild("Frame")
                and traitUIFrame.MainFrame.Frame:FindFirstChild("Content")
            local traitPage = content and content:FindFirstChild("TraitPage")
            local traitGottenFrame = traitPage and traitPage:FindFirstChild("TraitGottenFrame")
            local holder = traitGottenFrame and traitGottenFrame:FindFirstChild("Holder")
            local trait = holder and holder:FindFirstChild("Trait")
            local traitUI = trait and trait:FindFirstChild("TraitGotten")
            
            if not traitUI then
                -- UI Trait Reroll belum dibuka oleh player, tunggu sejenak agar hemat CPU
                task.wait(0.5)
                continue
            end

            local confirmFrame = content:FindFirstChild("AreYouSureYouWantToRerollFrame")
            local currentTrait = traitUI.Text
            local selected = Options.SelectedTrait.Value or {}

            if selected[currentTrait] then
                Library:Notify("Success! Got Trait: " .. currentTrait, 5)
                Toggles.AutoTrait:SetValue(false)
            else
                pcall(SyncTraitAutoSkip)
                if confirmFrame and confirmFrame.Visible then
                    Remotes.TraitConfirm:FireServer(true)
                    task.wait(0.1)
                end
                Remotes.Roll_Trait:FireServer()
                task.wait(Options.RollCD.Value)
            end
            continue -- Jump to next loop cycle to ensure 1-by-1
        end

        -- Priority 2: Race
        if Toggles.AutoRace.Value then
            local currentRace = Plr:GetAttribute("CurrentRace")
            local selected = Options.SelectedRace.Value or {}

            if selected[currentRace] then
                Library:Notify("Success! Got Race: " .. currentRace, 5)
                Toggles.AutoRace:SetValue(false)
            else
                pcall(SyncRaceSettings)
                Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                task.wait(Options.RollCD.Value)
            end
            continue
        end

        -- Priority 3: Clan
        if Toggles.AutoClan.Value then
            local currentClan = Plr:GetAttribute("CurrentClan")
            local selected = Options.SelectedClan.Value or {}

            if selected[currentClan] then
                Library:Notify("Success! Got Clan: " .. currentClan, 5)
                Toggles.AutoClan:SetValue(false)
            else
                pcall(SyncClanSettings)
                Remotes.UseItem:FireServer("Use", "Clan Reroll", 1)
                task.wait(Options.RollCD.Value)
            end
            continue
        end

        -- Priority 4: Bloodline
        if Toggles.AutoBloodline and Toggles.AutoBloodline.Value then
            local currentBloodline = Plr:GetAttribute("CurrentBloodline")
            
            -- Fallback reading from UI if attribute is missing
            if not currentBloodline then
                pcall(function()
                    local blLabel = PGui.StatsUI.MainFrame.Frame.Content.SideFrame.UserStats:FindFirstChild("BloodlineEquipped")
                    if blLabel and blLabel:FindFirstChild("StatName") then
                        currentBloodline = blLabel.StatName.Text
                    else
                        local blContainer = PGui.StatsUI.MainFrame.Frame.Content.SideFrame.UserStats:FindFirstChild("Bloodline")
                        if blContainer and blContainer:FindFirstChild("StatName") then
                            currentBloodline = blContainer.StatName.Text
                        end
                    end
                end)
            end
            
            local selected = Options.SelectedBloodline and Options.SelectedBloodline.Value or {}

            if selected[currentBloodline] then
                Library:Notify("Success! Got Bloodline: " .. currentBloodline, 5)
                Toggles.AutoBloodline:SetValue(false)
            else
                Remotes.UseItem:FireServer("Use", "Bloodline Stone", 1)
                task.wait(Options.RollCD.Value)
            end
            continue
        end

        -- If nothing is enabled, wait a bit longer to save CPU
        task.wait(0.4)
    end
end

local function EnsureRollManager()
    Thread("UnifiedRollManager", Func_UnifiedRollManager, 
        Toggles.AutoTrait.Value or Toggles.AutoRace.Value or Toggles.AutoClan.Value or (Toggles.AutoBloodline and Toggles.AutoBloodline.Value)
    )
end

local function AutoSpecPassiveLoop()
    pcall(SyncSpecPassiveAutoSkip)
    task.wait(Options.SpecRollCD.Value)

    while Toggles.AutoSpec.Value do
        local targetWeapons = Options.SelectedPassive.Value or {}
        local targetPassives = Options.SelectedSpec.Value or {}
        local workDone = false

        if type(Status.Main.Passives) ~= "table" then Status.Main.Passives = {} end

        for weaponName, isWeaponEnabled in pairs(targetWeapons) do
            if not isWeaponEnabled then continue end

            local currentData = Status.Main.Passives[weaponName] 
            
            local currentName = "None"
            local currentBuffs = {}
            
            if type(currentData) == "table" then
                currentName = currentData.Name or "None"
                currentBuffs = currentData.RolledBuffs or {}
            elseif type(currentData) == "string" then
                currentName = currentData
            end

            local isCorrectName = targetPassives[currentName]
            local meetsAllStats = true

            if isCorrectName then
                if type(currentBuffs) == "table" then
                    for statKey, rolledValue in pairs(currentBuffs) do
                        local sliderId = "Min_" .. currentName:gsub("%s+", "") .. "_" .. statKey
                        local minRequired = Options[sliderId] and Options[sliderId].Value or 0
                        
                        if tonumber(rolledValue) and rolledValue < minRequired then
                            meetsAllStats = false
                            break
                        end
                    end
                end
            else
                meetsAllStats = false
            end

            if not isCorrectName or not meetsAllStats then
                workDone = true
                Remotes.SpecPassiveReroll:FireServer(weaponName)
                
                local startWait = tick()
                repeat 
                    task.wait()
                    local checkData = Status.Main.Passives[weaponName]
                    local checkName = (type(checkData) == "table" and checkData.Name) or (type(checkData) == "string" and checkData) or ""
                until (checkName ~= currentName) or (tick() - startWait > 1.5)
                break 
            end
        end

        if not workDone then
            Library:Notify("Done", 5)
            Toggles.AutoSpec:SetValue(false)
            break
        end
        task.wait()
    end
end

local function AutoPowerLoop()
    while Toggles.AutoPower.Value do
        if Remotes.PowerGetData then
            pcall(function()
                local res = Remotes.PowerGetData:InvokeServer()
                if res then
                    local pData = res.Current or res.RolledPower
                    if pData then
                        Status.Main.CurrentPower.Name = pData.Name or "None"
                        Status.Main.CurrentPower.Buffs = pData.RolledBuffs or pData.Buffs or {}
                        if pData.RolledMythical then
                            Status.Main.CurrentPower.MythicalBuff = pData.RolledMythical.DebuffPercent or pData.RolledMythical.BossDamagePercent or 0
                        end
                    end
                end
            end)
        end

        local targets = Options.SelectedPower.Value or {}
        local cur = Status.Main.CurrentPower
        
        local isTargetName = (cur and cur.Name and cur.Name ~= "None") and targets[cur.Name] or false
        local statsSatisfied = true

        if isTargetName and cur and cur.Buffs then
            -- Check Regular Buffs
            for statKey, val in pairs(cur.Buffs) do
                local sliderId = "MinPower_" .. (cur.Name or ""):gsub("%s+", "") .. "_" .. statKey
                local sOpt = Options[sliderId]
                local targetMin = sOpt and tonumber(sOpt.Value)
                local statVal = tonumber(val) or 0
                if targetMin and statVal < targetMin then
                    statsSatisfied = false
                    break
                end
            end
            
            -- Check Mythical Buffs
            if statsSatisfied then
                local mythStatKey = (cur.Name == "Cursebrand" and "DebuffPercent") or (cur.Name == "Colossus" and "BossDamagePercent")
                if mythStatKey then
                    local sliderId = "MinPower_" .. (cur.Name or ""):gsub("%s+", "") .. "_" .. mythStatKey
                    local sOpt = Options[sliderId]
                    local targetMin = sOpt and tonumber(sOpt.Value)
                    local mythVal = tonumber(cur.MythicalBuff) or 0
                    if targetMin and mythVal < targetMin then
                        statsSatisfied = false
                    end
                end
            end
        else
            statsSatisfied = false
        end

        if not statsSatisfied then
            pcall(SyncPowerAutoSkip)
            if Remotes.PowerRoll then
                pcall(function() Remotes.PowerRoll:FireServer() end)
            end
            task.wait((Options.RollCD and Options.RollCD.Value or 0.1) + 0.1)
        else
            Library:Notify("Got Target Power: " .. tostring(cur.Name), 5)
            Toggles.AutoPower:SetValue(false)
            break
        end
        task.wait()
    end
end

local SkillTreeInfoLabel = nil

local function UpdateSkillTreeInfoPanel()
    if not SkillTreeInfoLabel then return end
    local nodes = Status.Main.SkillTree and Status.Main.SkillTree.Nodes or {}
    local points = tonumber(Status.Main.SkillTree and (Status.Main.SkillTree.SkillPoints or Status.Main.SkillTree.Points)) or 0
    local unlockedCount = 0
    for _, unlocked in pairs(nodes) do
        if unlocked then unlockedCount = unlockedCount + 1 end
    end
    
    local lastNode = Status.Main.SkillTree and Status.Main.SkillTree.LastUpgradedNode or "None"
    
    local text = string.format(
        "Available Skill Points: %d\nTotal Unlocked Nodes: %d / 25\nLast Upgraded Node: %s",
        points, unlockedCount, tostring(lastNode)
    )
    SkillTreeInfoLabel:SetText(text)
end

local function AutoSkillTreeLoop()
    if Remotes.GetSkillTreeData then
        local success, d = pcall(function()
            return Remotes.GetSkillTreeData:InvokeServer()
        end)
        if success and d then
            if not d.Unlocked and Remotes.SkillTreeUnlock then
                pcall(function() Remotes.SkillTreeUnlock:FireServer() end)
                task.wait(0.5)
                local success2, d2 = pcall(function() return Remotes.GetSkillTreeData:InvokeServer() end)
                if success2 and d2 then d = d2 end
            end
            Status.Main.SkillTree.Nodes = d.Nodes or {}
            Status.Main.SkillTree.SkillPoints = d.SkillPoints or d.Points or 0
            pcall(UpdateSkillTreeInfoPanel)
        end
    end

    while Toggles.AutoSkillTree.Value do
        task.wait(0.5) 
        
        local nodes = Status.Main.SkillTree and Status.Main.SkillTree.Nodes or {}
        local points = tonumber(Status.Main.SkillTree and (Status.Main.SkillTree.SkillPoints or Status.Main.SkillTree.Points)) or 0

        if points <= 0 then
            pcall(UpdateSkillTreeInfoPanel)
            continue 
        end

        local branches = Modules.SkillTree and Modules.SkillTree.Branches
        if type(branches) ~= "table" then
            DebugLog("SKILL_TREE", "SkillTree.Branches not available", true)
            task.wait(1)
            continue
        end

        local selectedBranches = Options.SelectedSkillBranch and Options.SelectedSkillBranch.Value or {}

        for branchKey, branch in pairs(branches) do
            if type(branch) ~= "table" or type(branch.Nodes) ~= "table" then
                continue
            end
            
            local bDisplayName = branch.DisplayName or tostring(branchKey)
            
            local isSelectedBranch = true
            if next(selectedBranches) then
                isSelectedBranch = selectedBranches[bDisplayName] or selectedBranches[branchKey] or false
            end

            if isSelectedBranch then
                for idx, node in ipairs(branch.Nodes) do
                    local nodeId = node.Id
                    local cost = tonumber(node.Cost) or 1

                    if nodeId and not nodes[nodeId] then
                        if points >= cost then
                            local success, err = pcall(function()
                                Remotes.SkillTreeUpgrade:FireServer(nodeId)
                            end)
                            
                            if success then
                                points = math.max(0, points - cost)
                                Status.Main.SkillTree.SkillPoints = points
                                Status.Main.SkillTree.Nodes[nodeId] = true
                                Status.Main.SkillTree.LastUpgradedNode = string.format("%s (Tier %d)", tostring(bDisplayName), idx)
                                pcall(UpdateSkillTreeInfoPanel)
                                task.wait(0.3)
                            else
                                DebugLog("SKILL_TREE", tostring(err))
                            end
                        end
                        
                        break 
                    end
                end
            end
        end
        pcall(UpdateSkillTreeInfoPanel)
    end
end

local function Func_AutoDungeon()
    while (Toggles.AutoDungeon.Value or Toggles.AutoReplay.Value or Toggles.AutoDiff.Value or Toggles.DungeonAutofarm.Value) do
        task.wait(1)
        
        local selected = Options.SelectedDungeon.Value
        if not selected then continue end

        local inDungeonRun = workspace:FindFirstChild("DungeonSpawns") ~= nil
        if not inDungeonRun then
            pcall(function()
                inDungeonRun = PGui.DungeonPortalJoinUI.LeaveButton.Visible
            end)
        end

        if inDungeonRun then
            local voteCd = Status.Main.LastVote or 0
            if tick() - voteCd > 5 then
                -- Auto Replay: use the replay vote remote
                if Toggles.AutoReplay.Value and Remotes.DungeonReplay then
                    pcall(function() Remotes.DungeonReplay:FireServer("sponsor") end)
                end
                
                -- Auto Difficulty: vote for difficulty
                if Toggles.AutoDiff.Value and Options.SelectedDiff and Options.SelectedDiff.Value and Remotes.DungeonVote then
                    pcall(function() Remotes.DungeonVote:FireServer(tostring(Options.SelectedDiff.Value)) end)
                end
                Status.Main.LastVote = tick()
            end

            if Toggles.DungeonAutofarm.Value then
                local char = GetCharacter()
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local nearestTarget, nearestDist = nil, math.huge
                    
                    -- Scan all NPC sources for DungeonNPC models
                    local function ScanForDungeonNPC(folder)
                        if not folder then return end
                        for _, npc in pairs(folder:GetChildren()) do
                            if npc:IsA("Model") then
                                local isDungeonNPC = string.match(npc.Name, "^DungeonNPC%d*$")
                                if isDungeonNPC and IsValidTarget(npc) then
                                    local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart")
                                    if npcRoot then
                                        local dist = (npcRoot.Position - root.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearestTarget = npc
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Scan workspace.NPCs
                    ScanForDungeonNPC(PATH.Mobs)
                    
                    -- Scan other potential dungeon folders
                    ScanForDungeonNPC(workspace:FindFirstChild("DungeonNPCs"))
                    ScanForDungeonNPC(workspace:FindFirstChild("Enemies"))
                    
                    -- Broader fallback: any Model with Humanoid alive (non-player)
                    if not nearestTarget then
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj:IsA("Folder") and obj.Name ~= "ServiceNPCs" and obj.Name ~= "NPCs" then
                                ScanForDungeonNPC(obj)
                            end
                        end
                    end
                    
                    -- Last resort: any alive Humanoid model anywhere
                    if not nearestTarget then
                        for _, npc in pairs(PATH.Mobs:GetChildren()) do
                            if npc:IsA("Model") and IsValidTarget(npc) then
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                                if npcRoot then
                                    local dist = (npcRoot.Position - root.Position).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearestTarget = npc
                                    end
                                end
                            end
                        end
                    end

                    if nearestTarget then
                        local isShielded = nearestTarget:GetAttribute("ShieldActive") or nearestTarget:FindFirstChild("ShieldEffect") or (nearestTarget:FindFirstChildOfClass("Humanoid") and nearestTarget:FindFirstChildOfClass("Humanoid"):GetAttribute("Immune"))
                        
                        local activeLever = nil
                        if isShielded or workspace:FindFirstChild("ActiveLevers") then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj.Name:lower():find("lever") and obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
                                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt.Enabled then
                                        activeLever = obj
                                        break
                                    end
                                end
                            end
                        end

                        if activeLever then
                            Status.Main.Target = nil
                            local prompt = activeLever:FindFirstChildWhichIsA("ProximityPrompt", true)
                            root.CFrame = activeLever:GetPivot() * CFrame.new(0, 3, 0)
                            task.wait(0.3)
                            fireproximityprompt(prompt)
                            task.wait(0.5)
                        else
                            Status.Main.Target = nearestTarget
                            Status.Main.TargetValid = true
                            UpdateSwitchState(nearestTarget, "Boss")
                            ExecuteFarmLogic(nearestTarget, "Dungeon", "Boss")
                            if Remotes.M1 then pcall(function() Remotes.M1:FireServer() end) end
                        end
                    end
                end
            end
            
            continue
        end

        local targetIsland = "Dungeon"
        if selected == "BossRush" then
            targetIsland = "Sailor"
        end

        local openCd = Toggles.AutoReplay.Value and 5 or 15
        if tick() - Status.Main.LastDungeon > openCd then
            local diff = (Toggles.AutoDiff.Value and Options.SelectedDiff and Options.SelectedDiff.Value) or nil
            pcall(function()
                if diff then
                    Remotes.OpenDungeon:FireServer(tostring(selected), tostring(diff))
                else
                    Remotes.OpenDungeon:FireServer(tostring(selected))
                end
            end)
            Status.Main.LastDungeon = tick()
            task.wait(1)
            pcall(function()
                Remotes.StartDungeon:FireServer()
            end)
            DebugLog("DUNGEON", ("Open/Start -> %s | Diff=%s"):format(tostring(selected), tostring(diff or "Default")))
        end

        if not PGui.DungeonPortalJoinUI.LeaveButton.Visible then
            local portal = workspace:FindFirstChild("ActiveDungeonPortal")

            if not portal then
                if Status.Main.Island ~= targetIsland then
                    Remotes.TP_Portal:FireServer(targetIsland)
                    Status.Main.Island = targetIsland
                    task.wait(2.5)
                end
            else
                local root = GetCharacter():FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = portal.CFrame
                    task.wait(0.2)
                    
                    local prompt = portal:FindFirstChild("JoinPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(1)
                    end
                end
            end
        end
    end
end

local function Func_AutoMerchant()
    local MerchantUI = UI.Merchant.Regular
    local Holder = MerchantUI:FindFirstChild("Holder", true)
    local LastTimerText = ""

    local function StartPurchaseSequence()
        if Status.Main.MerchantExecute then return end
        Status.Main.MerchantExecute = true
        
        if Status.Main.FirstMerchantSync then
            MerchantUI.Enabled = true
            MerchantUI.MainFrame.Visible = true
            task.wait(0.5)
            
            local closeBtn = MerchantUI:FindFirstChild("CloseButton", true)
            if closeBtn then
                gsc(closeBtn)
                task.wait(1.8) 
            end
        end

        OpenMerchantInterface() 
        task.wait(2) 

        local itemsWithStock = {}
        for _, child in pairs(Holder:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Item" then
                local stockLabel = child:FindFirstChild("StockAmountForThatItem", true)
                local currentStock = 0
                if stockLabel then
                    currentStock = tonumber(stockLabel.Text:match("%d+")) or 0
                end
                
                Status.Main.CurrentStock[child.Name] = currentStock
                if currentStock > 0 then
                    table.insert(itemsWithStock, {Name = child.Name, Stock = currentStock})
                end
            end
        end

        if #itemsWithStock > 0 then
            local selectedItems = Options.SelectedMerchantItems.Value
            for _, item in ipairs(itemsWithStock) do
                if selectedItems[item.Name] then
                    local success, err = pcall(function()
                        return Remotes.MerchantBuy:InvokeServer(item.Name, 99)
                    end)
                    if success then
                        Library:Notify("Successfully bought " .. tostring(item.Name) .. " from Merchant!", 4)
                    else
                        Library:Notify("Failed to buy " .. tostring(item.Name) .. ": " .. tostring(err), 4)
                    end
                    task.wait(math.random(11, 17) / 10)
                end
            end
        end

        local closeBtn = MerchantUI:FindFirstChild("CloseButton", true)
        if closeBtn then
            pcall(function() gsc(closeBtn) end)
        else
            if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end
        end
        Status.Main.FirstMerchantSync = true
        Status.Main.MerchantExecute = false
    end

    local function SyncClock()
        OpenMerchantInterface()
        task.wait(1)
        
        local Label = MerchantUI and MerchantUI:FindFirstChild("RefreshTimerLabel", true)
        if Label and Label.Text:find(":") then
            local serverSecs = GetSecondsFromTimer(Label.Text)
            if serverSecs then 
                Status.Main.LocalMerchantTime = serverSecs 
                Status.Main.LastTimerTick = tick()
            end
        end
        local closeBtn = MerchantUI:FindFirstChild("CloseButton", true)
        if closeBtn then
            pcall(function() gsc(closeBtn) end)
        else
            if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end
        end
    end

    SyncClock()

    while Toggles.AutoMerchant.Value do
        Status.Main.LocalMerchantTime = math.max(0, Status.Main.LocalMerchantTime - 1)

        local isRefresh = (Status.Main.LocalMerchantTime <= 1) or (Status.Main.LocalMerchantTime >= 1799)
        if not Status.Main.FirstMerchantSync or isRefresh then
            task.spawn(StartPurchaseSequence)
        end

        if tick() - Status.Main.LastTimerTick > 30 then
            task.spawn(SyncClock)
            Status.Main.LastTimerTick = tick()
        end

        if MerchantTimerLabel then
            MerchantTimerLabel:SetText(FormatSecondsToTimer(Status.Main.LocalMerchantTime))
        end

        task.wait(1)
    end
end

local function Func_AutoTrade()
    local function GetInvQty(name)
        for _, item in pairs(Status.Cached.Inv or {}) do
            if item.name == name then return item.quantity end
        end
        return 0
    end

    local function IsAlreadyInTrade(name)
        if not Status.Main.TradeState.myItems then return false end
        for _, tradeItem in pairs(Status.Main.TradeState.myItems) do
            if tradeItem.name == name then return true end
        end
        return false
    end

    while task.wait(0.5) do
        local inTradeUI = PGui:FindFirstChild("InTradingUI") and PGui.InTradingUI.MainFrame.Visible
        local requestUI = PGui:FindFirstChild("TradeRequestUI") and PGui.TradeRequestUI.TradeRequest.Visible
        
        if Toggles.ReqTradeAccept.Value and requestUI then
            Remotes.TradeRespond:FireServer(true)
            task.wait(1)
        end

    if Toggles.ReqTrade.Value and not inTradeUI and not requestUI then
        local rawName = Options.SelectedTradePlr.Value
        if rawName and rawName ~= "" then
            local target = GetPlayerByName(rawName)
            
            if target and target ~= Plr then
                Library:Notify("Trading with: " .. target.Name, 2)
                
                Remotes.TradeSend:FireServer(target.UserId)
                task.wait(3)
            end
        end
    end

        if inTradeUI and Toggles.AutoAccept.Value then
            local selection = Options.SelectedTradeItems.Value or {}
            local itemsToProcess = {}

            for name, enabled in pairs(selection) do
                if enabled then
                    if TradePresets[name] then
                        for itemName, amount in pairs(TradePresets[name]) do
                            itemsToProcess[itemName] = amount
                        end
                    else
                        itemsToProcess[name] = GetInvQty(name)
                    end
                end
            end

            -- Step 2: Add items to trade
            local addedAny = false
            for itemName, amountNeeded in pairs(itemsToProcess) do
                if not IsAlreadyInTrade(itemName) then
                    local available = GetInvQty(itemName)
                    if available > 0 then
                        local finalAmount = math.min(available, amountNeeded)
                        Remotes.TradeAddItem:FireServer("Items", itemName, finalAmount)
                        addedAny = true
                        task.wait(0.3)
                    end
                end
            end

            if not addedAny then
                if not Status.Main.TradeState.myReady then
                    Remotes.TradeReady:FireServer(true)
                elseif Status.Main.TradeState.myReady and Status.Main.TradeState.theirReady then
                    if Status.Main.TradeState.phase == "confirming" and not Status.Main.TradeState.myConfirm then
                        Remotes.TradeConfirm:FireServer()
                    end
                end
            end
        end
    end
end

local function Func_AutoChest()
    while task.wait(2) do
        if not Toggles.AutoChest.Value then break end

        local selected = Options.SelectedChests.Value
        if type(selected) ~= "table" then continue end

        for _, rarityName in ipairs(Tables.Rarities or {}) do
            if selected[rarityName] == true then
                local fullName = (rarityName == "Aura Crate") and "Aura Crate" or (rarityName .. " Chest")

                pcall(function()
                    Remotes.UseItem:FireServer("Use", fullName, 10000)
                end)

                task.wait(1)
            end
        end
    end
end

local function Func_AutoCraft()
    while task.wait(1) do
        if Toggles.AutoCraftItem.Value then
            local selected = Options.SelectedCraftItems.Value
            
            for _, item in pairs(Status.Cached.Inv) do
                if selected["DivineGrail"] and item.name == "Broken Sword" and item.quantity >= 3 then
                    local totalPossible = math.floor(item.quantity / 3)
                    local craftAmount = math.min(totalPossible, 99)
                    
                    pcall(function()
                        Remotes.GrailCraft:InvokeServer("DivineGrail", craftAmount)
                    end)
                    task.wait(0.5)
                end
                
                if selected["SlimeKey"] and item.name == "Slime Shard" and item.quantity >= 2 then
                    local totalPossible = math.floor(item.quantity / 2)
                    local craftAmount = math.min(totalPossible, 99)
                    
                    pcall(function()
                        Remotes.SlimeCraft:InvokeServer("SlimeKey", craftAmount)
                    end)
                end
            end
        end
        
        if not Toggles.AutoCraftItem.Value then break end
    end
end


local Window = Library:CreateWindow({
	Title = "SolanaHub Community",
	Footer = "" .. Env.GameName .. " | ".. Env.Version,
	NotifySide = "Right",
    Icon = "rbxassetid://135199868370962",
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
    Font = Enum.Font.RobotoMono,

    EnableSidebarResize = true,
    SidebarCompacted = true,
})

if not Env.IsDelta then
    Window:SetCornerRadius(16)
end

local Tabs = {
    Priority = Window:AddTab("Priority", "arrow-up-down"),
	Main = Window:AddTab("Main", "box"),
    Automation = Window:AddTab("Automation", "repeat-2"),
    Dungeon = Window:AddTab("Dungeon", "door-open"),
    Player = Window:AddTab("Player", "user"),
    Teleport = Window:AddTab("Teleport", "map-pin"),
    Webhook = Window:AddTab("Webhook", "send"),
    Misc = Window:AddTab("Misc", "apple"),
    Event = Window:AddTab("Event", "star"),
    Config = Window:AddTab("Config", "cog"),
}

local GB = {}

if Env.IsDelta then
    GB = {
        Priority = {
            Center = {
                Config = Tabs.Priority:AddCenterGroupbox("Config", "wrench"),
            },
        },
        Player = {
            Left = {
                General = Tabs.Player:AddLeftGroupbox("General", "user-cog"),
                Server = Tabs.Player:AddLeftGroupbox("Server", "server"),
                Codes = Tabs.Player:AddLeftGroupbox("Codes", "ticket"),
            },
            Right = {
                Game = Tabs.Player:AddRightGroupbox("Game", "earth"),
                Safety = Tabs.Player:AddRightGroupbox("Safety", "shield"),
            },
        },
        Webhook = {
            Left = {
                Config = Tabs.Webhook:AddLeftGroupbox("Config", "wrench"),
            },
        },
        Event = {
            Left = {
                Easter = Tabs.Event:AddLeftGroupbox("Easter Event 2026", "egg"),
            },
            Right = {
                Teleport = Tabs.Event:AddRightGroupbox("Event Teleports", "map-pin"),
            }
        }
    }
else
    GB = {
        Priority = {
            Center = {
                Config = Tabs.Priority:AddCenterGroupbox("Config", "wrench", true),
            },
        },
        Player = {
            Left = {
                General = Tabs.Player:AddLeftGroupbox("General", "user-cog", true),
                Server = Tabs.Player:AddLeftGroupbox("Server", "server", true),
                Codes = Tabs.Player:AddLeftGroupbox("Codes", "ticket", true),
            },
            Right = {
                Game = Tabs.Player:AddRightGroupbox("Game", "earth", true),
                Safety = Tabs.Player:AddRightGroupbox("Safety", "shield", true),
            },
        },
        Webhook = {
            Left = {
                Config = Tabs.Webhook:AddLeftGroupbox("Config", "wrench", true),
            },
        },
        Event = {
            Left = {
                Easter = Tabs.Event:AddLeftGroupbox("Easter Event 2026", "egg", true),
            },
            Right = {
                Teleport = Tabs.Event:AddRightGroupbox("Event Teleports", "map-pin", true),
            }
        }
    }
end

local TB = {
    Main = {
        Left = {
            Autofarm = Tabs.Main:AddLeftTabbox("Autofarm"),
            AutofarmExtra = Tabs.Main:AddLeftTabbox("Farm Settings"),
        },
        Right = {
            Switch = Tabs.Main:AddRightTabbox("Switch"),
            MiscAuto = Tabs.Main:AddRightTabbox("Misc Auto"),
        },
    },
    Automation = {
        Left = {
            Misc1 = Tabs.Automation:AddLeftTabbox("Rolling"),
            Stats1 = Tabs.Automation:AddLeftTabbox("Stats"),
            Merchant = Tabs.Automation:AddLeftTabbox("Merchant"),
        },
        Right = {
            Enchant = Tabs.Automation:AddRightTabbox("Enchant"),
            Misc1 = Tabs.Automation:AddRightTabbox("Misc"),
        },
    },
    Teleport = {
        Left = {
            Waypoint = Tabs.Teleport:AddLeftTabbox("Waypoint"),
        },
        Right = {
            NPCs = Tabs.Teleport:AddRightTabbox("NPCs"),
        },
    },
    Dungeon = {
        Left = {
            Autojoin = Tabs.Dungeon:AddLeftTabbox("Autojoin"),
        },
        Right = {
            Config = Tabs.Dungeon:AddRightTabbox("Dungeon Settings"),
        },
    },
    Misc = {
        Left = {
            Quests = Tabs.Misc:AddLeftTabbox("Quests"),
        },
        Right = {
        },
    },
}

local TB_Tabs = {
    Autofarm = {
        T1 = TB.Main.Left.Autofarm:AddTab("Autofarm"),
        T2 = TB.Main.Left.Autofarm:AddTab("Boss"),
        T3 = TB.Main.Left.Autofarm:AddTab("Alt Account"),
        T4 = TB.Main.Left.AutofarmExtra:AddTab("Farm Settings"),
        T5 = TB.Main.Left.AutofarmExtra:AddTab("Sea Beast"),
    },
    MiscAuto = {
        T1 = TB.Main.Right.MiscAuto:AddTab("Haki"),
        T2 = TB.Main.Right.MiscAuto:AddTab("Skill"),
        T3 = TB.Main.Right.MiscAuto:AddTab("Combo"),
    },
    Switch = {
        T1 = TB.Main.Right.Switch:AddTab("Title"),
        T2 = TB.Main.Right.Switch:AddTab("Rune"),
        T3 = TB.Main.Right.Switch:AddTab("Build"),
    },
    Rolling = {
        T1 = TB.Automation.Left.Misc1:AddTab("Ascend"),
        T2 = TB.Automation.Left.Misc1:AddTab("Rolls"),
        T3 = TB.Automation.Left.Misc1:AddTab("Trade"),
        T4 = TB.Automation.Left.Misc1:AddTab("Information"),
    },
    Stats1 = {
        T1 = TB.Automation.Left.Stats1:AddTab("Level"),
        T2 = TB.Automation.Left.Stats1:AddTab("Gem"),
        T3 = TB.Automation.Left.Stats1:AddTab("SkillTree"),
    },
    Enchant = {
        T1 = TB.Automation.Right.Enchant:AddTab("Enchant"),
        T2 = TB.Automation.Right.Enchant:AddTab("Passive"),
        T3 = TB.Automation.Right.Enchant:AddTab("Config"),
    },
    Dungeon = {
        T1 = TB.Dungeon.Left.Autojoin:AddTab("Autojoin"),
        T2 = TB.Dungeon.Right.Config:AddTab("Dungeon Settings"),
    },
    Waypoint = {
        T1 = TB.Teleport.Left.Waypoint:AddTab("Island"),
        T2 = TB.Teleport.Left.Waypoint:AddTab("Quest"),
        T3 = TB.Teleport.Left.Waypoint:AddTab("Misc"),
    },
    NPCs = {
        T1 = TB.Teleport.Right.NPCs:AddTab("Moveset"),
        T2 = TB.Teleport.Right.NPCs:AddTab("Mastery"),
    },
    Merchant = {
        T1 = TB.Automation.Left.Merchant:AddTab("Merchant"),
        T2 = TB.Automation.Left.Merchant:AddTab("Dungeon"),

    },
    Misc1 = {
        T1 = TB.Automation.Right.Misc1:AddTab("Chests"),
        T2 = TB.Automation.Right.Misc1:AddTab("Craft"),
    },
    Puzzle = {
        T1 = TB.Misc.Left.Quests:AddTab("Puzzles"),
        T2 = TB.Misc.Left.Quests:AddTab("Questlines"),
    },
}

GB.Player.Left.Codes:AddButton("Redeem All Codes", function()
    local allCodes = Modules.Codes.Codes
    local playerLevel = StartStats.Level
    
    for codeName, data in pairs(allCodes) do
        local levelReq = data.LevelReq or 0
        if playerLevel >= levelReq then
            Library:Notify("Attempting to redeem code: " .. codeName, 5)
            Remotes.UseCode:InvokeServer(codeName)
            task.wait(2)
        else
            Library:Notify(string.format("Not enough requirement for: %s (Req. Lvl %d)", codeName, levelReq), 4)
        end
    end
end)

for i = 1, #Status.Priority.Task do
    GB.Priority.Center.Config:AddDropdown("SelectedPriority_" .. i, {
        Text = "Priority " .. i,
        Values = Status.Priority.Task,
        Default = Status.Priority.Default[i],
        Multi = false,
        AllowNull = true,
        Searchable = true,
    })
end

GB.Webhook.Left.Config:AddInput("WebhookURL", {
	Default = "",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "Webhook URL",
	Placeholder = "Enter Webhook URL...",
})

GB.Webhook.Left.Config:AddInput("UID", {
	Default = "",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "User ID",
	Placeholder = "Enter UID...",
})

GB.Webhook.Left.Config:AddDropdown("SelectedData", {
    Text = "Select Data (s)",
    Values = {"Name", "Stats", "New Items", "All Items"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Webhook.Left.Config:AddDropdown("SelectedItemRarity", {
    Text = "Select Rarity To Send",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Default = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Multi = true,
    Searchable = true,
})

GB.Webhook.Left.Config:AddToggle("PingUser", {
    Text = "Ping User",
    Default = false,
})

GB.Webhook.Left.Config:AddToggle("SendWebhook", {
    Text = "Send Webhook",
    Default = false,
    Disabled = not Env.Support.Webhook,
})

GB.Webhook.Left.Config:AddSlider("WebhookDelay", {
    Text = "Send every [x] minutes",
    Default = 5,
    Min = 1,
    Max = 300,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

GB.Webhook.Left.Config:AddButton("Test Webhook", function()
    PostToWebhook()
end)

TB_Tabs.Autofarm.T1:AddDropdown("SelectedMob", {
    Text = "Select Mob (s)",
    Values = Tables.MobList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T1:AddToggle("MobFarm", {
    Text = "Autofarm Selected Mob",
    Default = false,
})

TB_Tabs.Autofarm.T1:AddToggle("AllMobFarm", {
    Text = "Autofarm All Mobs",
    Default = false,
})

TB_Tabs.Autofarm.T1:AddDropdown("AllMobType", {
    Text = "Select Type [All Mob]",
    Values = {"Normal", "Fast"},
    Default = "Normal",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T1:AddToggle("LevelFarm", {
    Text = "Autofarm Level",
    Default = false,
})

TB_Tabs.Autofarm.T1:AddDivider()

TB_Tabs.Autofarm.T1:AddToggle("AutoFarmRaidKeys", {
    Text = "Auto Farm Raid Keys",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.AutoFarmRaidKeys:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Auto Farm Raid Keys hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Autofarm.T1:AddInput("TargetRaidKeys", {
    Default = "5",
    Numeric = true,
    Text = "Target Raid Keys",
    Placeholder = "Keys amount...",
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedBosses", {
    Text = "Select Bosses",
    Values = Tables.BossList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddToggle("BossesFarm", {
    Text = "Autofarm Selected Boss",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddToggle("AllBossesFarm", {
    Text = "Autofarm All Bosses",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDivider()

TB_Tabs.Autofarm.T2:AddDropdown("SelectedSummon", {
    Text = "Select Boss to Auto-Summon",
    Values = Tables.FullSummon,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedSummonDiff", {
    Text = "Summon Difficulty",
    Values = Tables.DiffList,
    Default = "Normal",
    Multi = false,
})

TB_Tabs.Autofarm.T2:AddToggle("AutoSummon", {
    Text = "Enable Auto Summon",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddToggle("SummonBossFarm", {
    Text = "Autofarm Summon Boss",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedOtherSummon", {
    Text = "Select Boss [Other Summon]",
    Values = Tables.OtherSummonList,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedOtherSummonDiff", {
    Text = "Other Summon Difficulty",
    Values = Tables.DiffList,
    Default = "Normal",
    Multi = false,
})

TB_Tabs.Autofarm.T2:AddToggle("AutoOtherSummon", {
    Text = "Enable Auto Other Summon",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddToggle("OtherSummonFarm", {
    Text = "Autofarm Other Summon Boss",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDivider()

PityLabel = TB_Tabs.Autofarm.T2:AddLabel("Pity: 0/25")

TB_Tabs.Autofarm.T2:AddDropdown("SelectedBuildPity", {
    Text = "Select Boss [Build Pity]",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedUsePity", {
    Text = "Select Boss [Use Pity]",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedPityDiff", {
    Text = "Select Difficulty [Use Pity]",
    Values = Tables.DiffList,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddToggle("PityBossFarm", {
    Text = "Autofarm Pity Boss",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.PityBossFarm:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Autofarm Pity Boss hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Autofarm.T3:AddDropdown("SelectedAltBoss", {
    Text = "Select Boss",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T3:AddDropdown("SelectedAltDiff", {
    Text = "Select Difficulty",
    Values = Tables.DiffList,
    Default = nil,
    Multi = false,
    Searchable = true,
})

for i = 1, 5 do
    TB_Tabs.Autofarm.T3:AddDropdown("SelectedAlt_" .. i, {
        Text = "Select Alt #" .. i,
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Default = nil,
        Multi = false,
        AllowNull = true,
        Searchable = true,
    })
end

TB_Tabs.Autofarm.T3:AddToggle("AltBossFarm", {
    Text = "Auto Help Alt",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.AltBossFarm:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Auto Help Alt hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedWeaponType", {
    Text = "Select Weapon Type",
    Values = Tables.Weapon,
    Default = nil,
    Multi = true,
})

TB_Tabs.Autofarm.T4:AddSlider("SwitchWeaponCD", {
    Text = "Switch Weapon Delay",
    Default = 4,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddToggle("IslandTP", {
    Text = "Island TP [Autofarm]",
    Default = true,
})

TB_Tabs.Autofarm.T4:AddSlider("IslandTPCD", {
    Text = "Island TP CD",
    Default = 0.67,
    Min = 0,
    Max = 2.5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TargetTPCD", {
    Text = "Target TP CD",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TargetDistTP", {
    Text = "Target Distance TP [Tween]",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("M1Speed", {
    Text = "M1 Attack Cooldown",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedMovementType", {
    Text = "Select Movement Type",
    Values = {"Teleport", "Tween"},
    Default = "Tween",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedFarmType", {
    Text = "Select Farm Type",
    Values = {"Behind", "Above", "Below"},
    Default = "Behind",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddSlider("Distance", {
    Text = "Farm Distance",
    Default = 12,
    Min = 0,
    Max = 30,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TweenSpeed", {
    Text = "Tween Speed",
    Default = 160,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddToggle("InstaKill", {
    Text = "Instant Kill",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.InstaKill:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Instant Kill hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Autofarm.T4:AddDropdown("InstaKillType", {
    Text = "Select Type",
    Values = {"V1", "V2"},
    Default = "V1",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddSlider("InstaKillHP", {
    Text = "HP% For Insta-Kill",
    Default = 90,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddInput("InstaKillMinHP", {
    Text = "Min MaxHP for Insta-Kill",
    Default = "100000",
    Numeric = true,
    Finished = true,
    Placeholder = "Number..",
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddDropdown("SelectedSeaBeast", {
    Text = "Select Beast",
    Values = {"Any", "Kraken", "Sea Serpent"},
    Default = "Any",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T5:AddToggle("AutoSummonSeaBeast", {
    Text = "Auto Summon (AFK in Sea)",
    Default = false,
    Callback = function(v) Options.AutoSummonSeaBeast.Value = v end
})

TB_Tabs.Autofarm.T5:AddToggle("AutoKraken", {
    Text = "Auto Farm Sea Beast",
    Default = false,
    Callback = function(v) Options.AutoKraken.Value = v end
})

TB_Tabs.Autofarm.T5:AddDropdown("SeaBeastFarmType", {
    Text = "Sea Beast Position",
    Values = {"Safe Distance", "Orbit", "Behind", "Above", "Below"},
    Default = "Safe Distance",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastSafeDistance", {
    Text = "Safe Distance (Studs)",
    Default = 35,
    Min = 20,
    Max = 50,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastOrbitRadius", {
    Text = "Orbit Radius",
    Default = 80,
    Min = 60,
    Max = 120,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastOrbitHeight", {
    Text = "Orbit Height Offset",
    Default = 20,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastSmoothing", {
    Text = "Movement Smoothing (Lerp)",
    Default = 0.15,
    Min = 0.05,
    Max = 0.5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastRandomOffset", {
    Text = "Random Offset (Legit)",
    Default = 3,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddToggle("SeaBeastFaceTarget", {
    Text = "Always Face Target",
    Default = true,
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastDistance", {
    Text = "Sea Beast Distance (Legacy)",
    Default = 12,
    Min = 0,
    Max = 30,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddToggle("SeaBeastDynamicSafeDistance", {
    Text = "Dynamic Safe Distance",
    Default = true,
})

TB_Tabs.Autofarm.T5:AddToggle("SeaBeastParkMode", {
    Text = "Park Mode (Stable Spot)",
    Default = true,
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastParkHeight", {
    Text = "Park Height",
    Default = 28,
    Min = 10,
    Max = 80,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastParkBack", {
    Text = "Park Back Distance",
    Default = 24,
    Min = 0,
    Max = 60,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastParkSide", {
    Text = "Park Side Offset",
    Default = 0,
    Min = -20,
    Max = 20,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddToggle("SeaBeastAutoDodge", {
    Text = "Auto Dodge (Sea Beast)",
    Default = true,
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastDodgeHeight", {
    Text = "Dodge Height",
    Default = 28,
    Min = 10,
    Max = 80,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T5:AddSlider("SeaBeastDodgeTime", {
    Text = "Dodge Time",
    Default = 0.55,
    Min = 0.2,
    Max = 1.5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

getgenv().SeaBeastStatusUI = TB_Tabs.Autofarm.T5:AddLabel("Status: Idle")

TB_Tabs.MiscAuto.T1:AddToggle("ObserHaki", {
    Text = "Auto Observation Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T1:AddToggle("ArmHaki", {
    Text = "Auto Armament Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T1:AddToggle("ConquerorHaki", {
    Text = "Auto Conqueror Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddParagraph({
    Title = "Auto M1 Information",
    Content = "Autofarm already has auto-M1 built-in. You do not need to enable this separately unless you have any issues with the autofarm M1."
})

TB_Tabs.MiscAuto.T2:AddToggle("AutoM1", {
    Text = "Auto Attack",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddToggle("KillAura", {
    Text = "Kill Aura",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddSlider("KillAuraCD", {
    Text = "CD",
    Default = 0.1,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
})

TB_Tabs.MiscAuto.T2:AddSlider("KillAuraRange", {
    Text = "Range",
    Default = 200,
    Min = 0,
    Max = 200,
    Rounding = 0,
})

TB_Tabs.MiscAuto.T2:AddParagraph({
    Title = "Skill Usage Mode",
    Content = "• Normal: Check skill cooldowns\n• Instant: No check (may affect performance when used for a long time)."
})

TB_Tabs.MiscAuto.T2:AddDropdown("SelectedSkills", {
    Text = "Select Skills",
    Values = {"Z", "X", "C", "V", "F"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto.T2:AddDropdown("AutoSkillType", {
    Text = "Select Mode",
    Values = {"Normal", "Instant"},
    Default = "Normal",
    Multi = false,
    Searchable = true,
})

TB_Tabs.MiscAuto.T2:AddToggle("OnlyTarget", {
    Text = "Target Only",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddToggle("AutoSkill_BossOnly", {
    Text = "Use On Boss Only",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddSlider("AutoSkill_BossHP", {
    Text = "Boss HP%",
    Default = 100,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.MiscAuto.T2:AddToggle("AutoSkill", {
    Text = "Auto Use Skills",
    Default = false,
})

TB_Tabs.MiscAuto.T3:AddParagraph({
    Title = "Combo Settings Guide",
    Content = "Example Pattern:\n• Z > X > C > 0.5 > V (or Z, X, C, 0.5, V)\n\nMode:\n• Normal: Wait for input cooldown (e.g. Z > 0.5)\n• Instant: Ignore input cooldowns entirely"
})

TB_Tabs.MiscAuto.T3:AddInput("ComboPattern", {
    Text = "Combo Pattern",
    Default = "Z > X > C > V > F",
    Placeholder = "combo..",
})

TB_Tabs.MiscAuto.T3:AddDropdown("ComboMode", {
    Text = "Select Mode",
    Values = {"Normal", "Instant"},
    Default = "Normal",
})

TB_Tabs.MiscAuto.T3:AddToggle("ComboBossOnly", {
    Text = "Boss Only",
    Default = false,
})

TB_Tabs.MiscAuto.T3:AddToggle("AutoCombo", {
    Text = "Auto Skill Combo",
    Default = false,
    Callback = function(state)
        if state and Toggles.AutoSkill.Value then
            Toggles.AutoSkill:SetValue(false)
            Library:Notify("NOTICE: Auto Skill disabled for this to works properly.", 3)
        end
    end
})

CreateSwitchGroup(TB_Tabs.Switch.T1, "Title", "Title", CombinedTitleList)
CreateSwitchGroup(TB_Tabs.Switch.T2, "Rune", "Rune", Tables.RuneList)
CreateSwitchGroup(TB_Tabs.Switch.T3, "Build", "Build", Tables.BuildList)

TB_Tabs.Rolling.T1:AddToggle("AutoAscend", {
    Text = "Auto Ascend",
    Default = false,
})

for i = 1, 10 do
    Tables.AscendLabels[i] = TB_Tabs.Rolling.T1:AddLabel("", true)
    Tables.AscendLabels[i]:SetVisible(false)
end

TB_Tabs.Rolling.T2:AddParagraph({
    Title = "Roll Settings Guide",
    Content = "• Increase delay based on your ping/internet speed.\n• Low delay settings are not recommended."
})

TB_Tabs.Rolling.T2:AddSlider("RollCD", {
    Text = "Roll Delay",
    Default = 0.3,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Rolling.T2:AddDropdown("SelectedTrait", {
    Text = "Select Trait (s)",
    Values = Tables.TraitList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T2:AddToggle("AutoTrait", {
    Text = "Auto Roll Trait",
    Default = false,
})

TB_Tabs.Rolling.T2:AddDropdown("SelectedRace", {
    Text = "Select Race (s)",
    Values = Tables.RaceList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T2:AddToggle("AutoRace", {
    Text = "Auto Roll Race",
    Default = false,
})

TB_Tabs.Rolling.T2:AddDropdown("SelectedClan", {
    Text = "Select Clan (s)",
    Values = Tables.ClanList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T2:AddToggle("AutoClan", {
    Text = "Auto Roll Clan",
    Default = false,
})

TB_Tabs.Rolling.T2:AddLabel("--- Bloodline ---", true)

TB_Tabs.Rolling.T2:AddDropdown("SelectedBloodline", {
    Text = "Select Bloodline (s)",
    Values = Tables.BloodlineList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T2:AddToggle("AutoBloodline", {
    Text = "Auto Roll Bloodline",
    Default = false,
})

PowerLabel = TB_Tabs.Rolling.T2:AddLabel("Current: N/A", true)

TB_Tabs.Rolling.T2:AddDropdown("SelectedPower", {
    Text = "Select Power (s)",
    Values = Tables.Power,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T2:AddToggle("AutoPower", {
    Text = "Auto Roll Power",
    Default = false,
})

TB_Tabs.Rolling.T4:AddLabel("Select Power(s) in Rolls to show minimum buff config here.", true)

local function UpdatePowerSliders()
    local selected = Options.SelectedPower.Value or {}
    for _, slider in pairs(Status.Main.PowerSliders) do
        if slider and type(slider) == "table" and slider.SetVisible then
            pcall(function() slider:SetVisible(false) end)
        end
    end

    for name, isSelected in pairs(selected) do
        if isSelected then
            local data = Modules.Power.Powers[name]
            if data and data.Buffs then
                -- 1. Regular Buffs
                for statKey, range in pairs(data.Buffs) do
                    local id = "MinPower_" .. name:gsub("%s+", "") .. "_" .. statKey
                    local label = string.format("%s [%s]", name, statKey:gsub("Percent", "%%"))
                    
                    if not Options[id] then
                        Status.Main.PowerSliders[id] = TB_Tabs.Rolling.T4:AddSlider(id, {
                            Text = label, Default = range[1], Min = range[1], Max = range[2],
                            Rounding = 1, Compact = true
                        })
                    else
                        local sObj = Status.Main.PowerSliders[id]
                        if sObj and type(sObj) == "table" and sObj.SetVisible then
                            pcall(function() sObj:SetVisible(true) end)
                        end
                    end
                end
                -- 2. Mythical Config Buffs
                if data.MythicalConfig then
                    for statKey, range in pairs(data.MythicalConfig) do
                        if type(range) == "table" then
                            local id = "MinPower_" .. name .. "_" .. statKey
                            local label = string.format("%s [%s]", name, statKey:gsub("Percent", "%%"))
                            if not Options[id] then
                                Status.Main.PowerSliders[id] = TB_Tabs.Rolling.T4:AddSlider(id, {
                                    Text = label, Default = range[1], Min = range[1], Max = range[2],
                                    Rounding = 1, Compact = true
                                })
                            else
                                local sObj = Status.Main.PowerSliders[id]
                                if sObj and type(sObj) == "table" and sObj.SetVisible then
                                    pcall(function() sObj:SetVisible(true) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

TB_Tabs.Rolling.T3:AddInput("SelectedTradePlr", {
	Default = nil,
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "Type Player Name",
	Placeholder = "@username...",
})

TB_Tabs.Rolling.T3:AddDropdown("SelectedTradeItems", {
    Text = "Select Item (s)",
    Values = Tables.OwnedItem,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Rolling.T3:AddToggle("ReqTrade", {
    Text = "Auto Send Request",
    Default = false,
})

TB_Tabs.Rolling.T3:AddToggle("ReqTradeAccept", {
    Text = "Auto Accept Request",
    Default = false,
})

TB_Tabs.Rolling.T3:AddToggle("AutoAccept", {
    Text = "Auto Accept Trade",
    Default = false,
})

TB_Tabs.Stats1.T1:AddDropdown("SelectedStats", {
    Text = "Select Stat (s)",
    Values = {"Melee", "Defense", "Sword", "Power"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T1:AddToggle("AutoStats", {
    Text = "Auto UP Stats",
    Default = false,
})

TB_Tabs.Stats1.T2:AddParagraph({
    Title = "Stats Roll Guide",
    Content = "• Increase delay based on your ping/internet speed.\n• Low delay settings are not recommended.\n• Reroll once for this to work."
})

StatsLabel = TB_Tabs.Stats1.T2:AddLabel("N/A", true)

TB_Tabs.Stats1.T2:AddDropdown("SelectedGemStats", {
    Text = "Select Stat (s)",
    Values = Tables.GemStat,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T2:AddDropdown("SelectedRank", {
    Text = "Select Rank (s)",
    Values = Tables.GemRank,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T2:AddSlider("StatsRollCD", {
    Text = "Roll Delay",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Stats1.T2:AddToggle("AutoRollStats", {
    Text = "Auto Roll Stats",
    Default = false,
})

TB_Tabs.Stats1.T3:AddDropdown("SelectedSkillBranch", {
    Text = "Select Skill Branch Focus",
    Values = Tables.SkillBranches,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T3:AddToggle("AutoSkillTree", {
    Text = "Auto Skill Tree",
    Default = false,
})

SkillTreeInfoLabel = TB_Tabs.Stats1.T3:AddParagraph({
    Title = "Skill Tree Upgrade Progress",
    Content = "Available Skill Points: 0\nTotal Unlocked Nodes: 0 / 25\nLast Upgraded Node: None"
})

TB_Tabs.Enchant.T1:AddDropdown("SelectedEnchant", {
    Text = "Select Enchant",
    Values = Tables.OwnedAccessory,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T1:AddToggle("AutoEnchant", {
    Text = "Auto Enchant",
    Default = false,
})

TB_Tabs.Enchant.T1:AddToggle("AutoEnchantAll", {
    Text = "Auto Enchant All",
    Default = false,
})

TB_Tabs.Enchant.T1:AddDivider()

TB_Tabs.Enchant.T1:AddDropdown("SelectedBlessing", {
    Text = "Select Blessing",
    Values = Tables.OwnedWeapon,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T1:AddToggle("AutoBlessing", {
    Text = "Auto Blessing",
    Default = false,
})

TB_Tabs.Enchant.T1:AddToggle("AutoBlessingAll", {
    Text = "Auto Blessing All",
    Default = false,
})

SpecPassiveLabel = TB_Tabs.Enchant.T2:AddLabel("N/A", true)

TB_Tabs.Enchant.T2:AddDropdown("SelectedPassive", {
    Text = "Select Weapon (s)",
    Values = Tables.AllOwnedWeapons,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T2:AddDropdown("SelectedSpec", {
    Text = "Target Passives",
    Values = Tables.SpecPassive,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T2:AddSlider("SpecRollCD", {
    Text = "Roll Delay",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Enchant.T2:AddToggle("AutoSpec", {
    Text = "Auto Reroll Passive",
    Default = false,
})

TB_Tabs.Enchant.T3:AddParagraph({
    Title = "Advanced Passive Config Guide",
    Content = "• Only adjust these values if you are an advanced user.\n• Will stop once the selected passive reaches your set minimum value."
})

local ShortMap = {
    ["DamagePercent"] = "DMG%",
    ["CritChance"] = "CC%",
    ["CritDamage"] = "CD%",
    ["BonusDropChance"] = "Drop%",
    ["ExecuteBonus"] = "BonusDMG%",
    ["ExecuteThreshold"] = "Exec%",
    
    ["Damage"] = "DMG",
    ["Crit Chance"] = "CC",
    ["Crit Damage"] = "CD",
    ["Luck"] = "Luck"
}

local SortedShortKeys = {}
for k in pairs(ShortMap) do table.insert(SortedShortKeys, k) end
table.sort(SortedShortKeys, function(a, b) return #a > #b end)

local function Shorten(text)
    for _, long in ipairs(SortedShortKeys) do
        local short = ShortMap[long]
        local safeShort = short:gsub("%%", "%%%%")
        text = text:gsub(long, safeShort)
    end
    return text
end

local function UpdatePassiveSliders()
    local selectedPassives = Options.SelectedSpec.Value or {}
    
    for _, slider in pairs(Status.Main.SpecStatsSlider) do
        slider:SetVisible(false)
    end

    for passiveName, isSelected in pairs(selectedPassives) do
        if isSelected then
            local data = Modules.SpecPassive.Passives[passiveName]
            if data and data.Buffs then
                for statKey, range in pairs(data.Buffs) do
                    local sliderId = "Min_" .. passiveName:gsub("%s+", "") .. "_" .. statKey
                    
                    local shortName = Shorten(passiveName)
                    local shortStat = Shorten(statKey)
                    local label = string.format("%s [%s]", shortName, shortStat)

                    if not Options[sliderId] then
                        local minVal, maxVal = range[1], range[2]

                        Status.Main.SpecStatsSlider[sliderId] = TB_Tabs.Enchant.T3:AddSlider(sliderId, {
                            Text = label,
                            Default = minVal,
                            Min = minVal,
                            Max = maxVal,
                            Rounding = 1,
                            Compact = true,
                            Visible = true
                        })
                    else
                        Options[sliderId]:SetText(label)
                        Status.Main.SpecStatsSlider[sliderId]:SetVisible(true)
                    end
                end
            end
        end
    end
end


DungeonStatusLabel = TB_Tabs.Dungeon.T1:AddLabel("Select a dungeon to begin.", true)

TB_Tabs.Dungeon.T1:AddDropdown("SelectedDungeon", {
    Text = "Select Dungeon",
    Values = Tables.DungeonList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(v)
        if DungeonStatusLabel then
            if v then
                local dungData = Modules.DungeonConfig and Modules.DungeonConfig.Dungeons and Modules.DungeonConfig.Dungeons[v]
                if dungData and dungData.Difficulties then
                    local diffs = {}
                    for diffName, _ in pairs(dungData.Difficulties) do
                        table.insert(diffs, diffName)
                    end
                    table.sort(diffs)
                    if Options.SelectedDiff then
                        Options.SelectedDiff:SetValues(diffs)
                    end
                    DungeonStatusLabel:SetText("Selected: " .. v .. " (" .. #diffs .. " difficulties)")
                else
                    DungeonStatusLabel:SetText("Selected: " .. v)
                end
            else
                DungeonStatusLabel:SetText("Select a dungeon to begin.")
            end
        end
    end
})

TB_Tabs.Dungeon.T1:AddToggle("AutoDungeon", {
    Text = "Auto Join Dungeon",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.AutoDungeon:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Auto Join Dungeon hanya untuk pengguna Key Premium!", 5)
        end
    end
})

DungeonCount = TB_Tabs.Dungeon.T2:AddLabel("Dungeon Completed: N/A")

TB_Tabs.Dungeon.T2:AddDropdown("SelectedDiff", {
    Text = "Select Difficulty",
    Values = {"Easy", "Medium", "Hard", "Extreme"},
    Default = "Easy",
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Dungeon.T2:AddToggle("AutoDiff", {
    Text = "Auto Select Difficulty",
    Default = false,
})

TB_Tabs.Dungeon.T2:AddToggle("AutoReplay", {
    Text = "Auto Replay",
    Default = false,
})

TB_Tabs.Dungeon.T2:AddToggle("DungeonAutofarm", {
    Text = "Autofarm Dungeon",
    Default = false,
})

    AddSliderToggle({ Group = GB.Player.Left.General, Id = "WS", Text = "WalkSpeed", Default = 16, Min = 16, Max = 250 })
    local TPW_T, TPW_S = AddSliderToggle({ Group = GB.Player.Left.General, Id = "TPW", Text = "TPWalk", Default = 1, Min = 1, Max = 10, Rounding = 1 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "JP", Text = "JumpPower", Default = 50, Min = 0, Max = 500 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "HH", Text = "HipHeight", Default = 2, Min = 0, Max = 10, Rounding = 1 })
    GB.Player.Left.General:AddToggle("Noclip", { Text = "Noclip" })
    GB.Player.Left.General:AddToggle("AntiKnockback", {
    Text = "Anti Knockback",
    Default = false,
    })
    GB.Player.Left.General:AddToggle("Disable3DRender", { Text = "Disable 3D Rendering" })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "Grav", Text = "Gravity", Default = 196, Min = 0, Max = 500, Rounding = 1})
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "Zoom", Text = "Camera Zoom", Default = 128, Min = 128, Max = 10000 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "FOV", Text = "Field of View", Default = 70, Min = 30, Max = 120 })
    local FPS_T, FPS_S = AddSliderToggle({ Group = GB.Player.Left.General, Id = "LimitFPS", Text = "Set Max FPS", Disabled = not Env.Support.FPS, Default = 60, Min = 5, Max = 360 })
    GB.Player.Left.General:AddToggle("FPSBoost", { Text = "FPS Boost" })
    GB.Player.Left.General:AddToggle("FPSBoost_AF", { Text = "FPS Boost [Autofarm]" })

    GB.Player.Left.Server:AddToggle("AntiAFK", {
        Text = "Anti AFK",
        Default = true,
        Disabled = not Env.Support.Connections,
    })
    GB.Player.Left.Server:AddToggle("AntiKick", { Text = "Anti Kick (Client)" })
    GB.Player.Left.Server:AddToggle("AutoReconnect", { Text = "Auto Reconnect" })
    GB.Player.Left.Server:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused"})

    GB.Player.Left.Server:AddButton({ Text = "Serverhop", Func = function() 
        local Servers = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end})
    GB.Player.Left.Server:AddButton({ Text = "Rejoin", Func = function() TP:Teleport(game.PlaceId, Plr) end })

    GB.Player.Left.Server:AddToggle("AutoServerhop", { Text = "Auto Serverhop" })
    GB.Player.Left.Server:AddSlider("AutoHopMins", { Text = "Minutes", Default = 30, Min = 0, Max = 300, Compact = true })

    GB.Player.Left.Server:AddToggle("AutoRejoinMemory", { 
        Text = "Auto Rejoin (Memory)", 
        Default = false 
    })

    GB.Player.Left.Server:AddSlider("MemoryLimit", { 
        Text = "Memory Limit (MB)", 
        Default = 3000, 
        Min = 1000, 
        Max = 20000, 
        Rounding = 0,
        Compact = true 
    })

    GB.Player.Right.Game:AddToggle("InstantPP", { Text = "Instant Prompt" })
    GB.Player.Right.Game:AddToggle("Fullbright", { Text = "Fullbright" })
    GB.Player.Right.Game:AddToggle("NoFog", { Text = "No Fog" })

    AddSliderToggle({ Group = GB.Player.Right.Game, Id = "OverrideTime", Text = "Time Of Day", Default = 12, Min = 0, Max = 24, Rounding = 1 })

    GB.Player.Right.Safety:AddLabel("Panic")
    :AddKeyPicker("PanicKeybind", { Default = "P", Text = "Panic" })
    GB.Player.Right.Safety:AddToggle("AutoKick", { Text = "Auto Kick", Default = true})
    GB.Player.Right.Safety:AddDropdown("SelectedKickType", {
    Text = "Select Type",
    Values = {"Mod", "Player Join", "Public Server"},
    Default = {"Mod"},
    Multi = true,
    Searchable = true,})

TB_Tabs.Waypoint.T1:AddDropdown("SelectedIsland", {
    Text = "Select Island",
    Stacked = true,
    Values = Tables.IslandList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
    if a ~= nil and a ~= "" then
        Remotes.TP_Portal:FireServer(GetTPName(a))
    end
    end
})

TB_Tabs.Waypoint.T2:AddDropdown("SelectedQuestNPC", {
    Text = "Select NPC",
    Stacked = true,
    Values = Tables.NPC_QuestList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
    if not a or a == "" then return end

    local questMap = {
        ["DungeonUnlock"] = "DungeonPortalsNPC",
        ["SlimeKeyUnlock"] = "SlimeCraftNPC"
    }

    SafeTeleportToNPC(a, questMap)
    end
})

TB_Tabs.Waypoint.T3:AddDropdown("SelectedMiscNPC", {
    Text = "Select NPC [Misc]",
    Stacked = true,
    Values = Tables.NPC_MiscList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
    if not a or a == "" then return end

    local miscMap = {
        ["ArmHaki"] = "HakiQuest",
        ["Observation"] = "ObservationBuyer"
    }

    SafeTeleportToNPC(tostring(a), miscMap)
    end
})

TB_Tabs.Waypoint.T3:AddDropdown("SelectedMiscAllNPC", {
    Text = "Select NPC [All NPCs]",
    Stacked = true,
    Values = Tables.AllNPCList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a and a ~= "" then SafeTeleportToNPC(tostring(a)) end
    end
})

TB_Tabs.NPCs.T1:AddDropdown("SelectedMovesetNPC", {
    Text = "Select NPC",
    Stacked = true,
    Values = Tables.NPC_MovesetList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a and a ~= "" then SafeTeleportToNPC(tostring(a)) end
    end
})

TB_Tabs.NPCs.T2:AddDropdown("SelectedMasteryNPC", {
    Text = "Select NPC",
    Stacked = true,
    Values = Tables.NPC_MasteryList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a and a ~= "" then SafeTeleportToNPC(tostring(a)) end
    end
})

MerchantTimerLabel = TB_Tabs.Merchant.T1:AddLabel("Refresh: N/A")

TB_Tabs.Merchant.T1:AddDropdown("SelectedMerchantItems", {
    Text = "Select Item (s)",
    Values = Tables.MerchantList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Merchant.T1:AddToggle("AutoMerchant", {
    Text = "Auto Buy Selected Items",
    Default = false,
})

TB_Tabs.Merchant.T2:AddLabel("Soon...")


TB_Tabs.Misc1.T1:AddDropdown("SelectedChests", {
    Text = "Select Chest (s)",
    Values = Tables.Rarities,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Misc1.T1:AddToggle("AutoChest", {
    Text = "Auto Open Chest",
    Default = false,
})

TB_Tabs.Misc1.T2:AddDropdown("SelectedCraftItems", {
    Text = "Select Item (s) To Craft",
    Values = Tables.CraftItemList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Misc1.T2:AddToggle("AutoCraftItem", {
    Text = "Auto Craft Item",
    Default = false,
})

TB_Tabs.Misc1.T2:AddDivider()

TB_Tabs.Misc1.T2:AddToggle("AutoCraftSunGod", {
    Text = "Auto Craft Sun God Sword",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.AutoCraftSunGod:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Auto Craft Sun God Sword hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Dungeon Puzzle",
    Disabled = not Env.Support.Proximity,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Func = function()
        local currentLevel = Plr.Data.Level.Value
        if currentLevel >= 5000 then
            UniversalPuzzleSolver("Dungeon")
        else
            Library:Notify("Level 5000 required! Current: " .. currentLevel, 3)
        end
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Slime Key Puzzle",
    Disabled = not Env.Support.Proximity,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Func = function()
        UniversalPuzzleSolver("Slime")
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Demonite Puzzle",
    Disabled = not Env.Support.Proximity,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Func = function()
        UniversalPuzzleSolver("Demonite")
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Hogyoku Puzzle",
    Disabled = not Env.Support.Proximity,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Func = function()
        local currentLevel = Plr.Data.Level.Value
        if currentLevel >= 8500 then
            UniversalPuzzleSolver("Hogyoku")
        else
            Library:Notify("Level 8500 required! Current: " .. currentLevel, 4)
        end
    end
})

TB_Tabs.Puzzle.T2:AddLabel({
    Text = "- ⚠️: Experimental feature. Deep testing required!\n- ⚠️: Make sure to store your race & clan before using this.\n- Dungeon tasks only make you join dungeon.\n- Feature will change some other features settings.\n- Report any bugs on discord server!",
    DoesWrap = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline", {
    Text = "Select Questline",
    Values = Tables.QuestlineList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline_Player", {
    Text = "Select Player",
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    AllowNull = true,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline_DMGTaken", {
    Text = "Select Mob [Take Damage]",
    Values = Tables.AllEntitiesList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddButton("Refresh", function()
    UpdateAllEntities()
    Options.SelectedQuestline_DMGTaken:SetValues(Tables.AllEntitiesList)
end)

TB_Tabs.Puzzle.T2:AddToggle("AutoQuestline", {
    Text = "Auto Questline [BETA]",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            Toggles.AutoQuestline:SetValue(false)
            Library:Notify("Premium Required 👑", "Fitur Auto Questline hanya untuk pengguna Key Premium!", 5)
        end
    end
})

TB_Tabs.Puzzle.T2:AddToggle("QuestlineAutoCombat", {
    Text = "Questline Auto Combat Assist",
    Default = true,
})

TB_Tabs.Puzzle.T2:AddToggle("QuestlineAutoSkill", {
    Text = "Questline Auto Skill Assist",
    Default = true,
})

TB_Tabs.Puzzle.T2:AddToggle("QuestlineUseLevelFarm", {
    Text = "Questline Use Level Farm (AnyNPC/HakiNPC)",
    Default = false,
})

Toggles.SendWebhook:OnChanged(function(state)
    Thread("WebhookLoop", Func_WebhookLoop, state)
end)

Toggles.LevelFarm:OnChanged(function(state)
    if not state then Status.Main.QuestNPC = "" end
end)

Toggles.AutoTitle:OnChanged(function(state)
    if state and #Tables.UnlockedTitle == 0 then
        Remotes.TitleUnequip:FireServer()
    end
end)

Toggles.ObserHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.ArmHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.ConquerorHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.AutoM1:OnChanged(function(state)
    Thread("AutoM1", SafeLoop("Auto M1", Func_AutoM1), state)
end)

Toggles.KillAura:OnChanged(function(state)
    Thread("KillAura", Func_KillAura, state)
end)

Toggles.AutoSkill:OnChanged(function(state)
    Thread("AutoSkill", SafeLoop("Auto Skill", Func_AutoSkill), state)
end)

Toggles.AutoStats:OnChanged(function(state)
    Thread("AutoStats", SafeLoop("Auto Stats", Func_AutoStats), state)
end)

Toggles.AutoCombo:OnChanged(function(state)
    if not state then Status.Main.ComboIdx = 1 end
    Thread("AutoCombo", SafeLoop("Skill Combo", Func_AutoCombo), state)
end)

Toggles.AutoAscend:OnChanged(function(state)
    if state then
        Remotes.ReqAscend:InvokeServer()
    else
        Remotes.CloseAscend:FireServer()
        for i = 1, 10 do Tables.AscendLabels[i]:SetVisible(false) end
    end
end)

Toggles.AutoTrait:OnChanged(EnsureRollManager)
Toggles.AutoRace:OnChanged(EnsureRollManager)
Toggles.AutoClan:OnChanged(EnsureRollManager)
Toggles.AutoBloodline:OnChanged(EnsureRollManager)

Options.SelectedTrait:OnChanged(function()
    SyncTraitAutoSkip()
end)

Options.SelectedRace:OnChanged(function()
    SyncRaceSettings()
end)

Options.SelectedClan:OnChanged(function()
    SyncClanSettings()
end)

Options.SelectedSpec:OnChanged(function()
    SyncSpecPassiveAutoSkip()
end)

Options.SelectedPassive:OnChanged(function()
    UpdateSpecPassiveLabel()
end)

Options.SelectedSpec:OnChanged(UpdatePassiveSliders)
Options.SelectedPower:OnChanged(UpdatePowerSliders)

Options.SelectedKickType:OnChanged(function()
    CheckServerTypeSafety()
end)

-- 1. Thread Auto Farm Raid Keys
task.spawn(function()
    while task.wait(1) do
        if not getgenv().solanahub_community_running then break end
        if Toggles.AutoFarmRaidKeys and Toggles.AutoFarmRaidKeys.Value then
            local keysCount = 0
            for _, item in pairs(Status.Cached.Inv or {}) do
                if item.name == "Raid Key" then
                    keysCount = item.quantity or 0
                    break
                end
            end
            
            local targetKeys = tonumber(Options.TargetRaidKeys.Value) or 5
            if keysCount < targetKeys then
                -- Cari monster Fast Ninja di Punch Island (Sea 2) atau Spirit Fighter di Blue Planet
                local target = nil
                for _, npc in pairs(PATH.Mobs:GetChildren()) do
                    local nName = npc.Name:lower()
                    if (nName:find("fast ninja") or nName:find("spirit fighter")) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        target = npc
                        break
                    end
                end
                if target then
                    Status.Main.Target = target
                    Status.Main.TargetValid = true
                    UpdateSwitchState(target, "Mob")
                    
                    local nearestIsland = "Punch"
                    if target.Name:lower():find("spirit fighter") then
                        nearestIsland = "BluePlanet"
                    end
                    ExecuteFarmLogic(target, nearestIsland, "Mob")
                end
            end
        end
    end
end)

-- 2. Thread Auto Craft Sun God Sword
task.spawn(function()
    while task.wait(5) do
        if not getgenv().solanahub_community_running then break end
        if Toggles.AutoCraftSunGod and Toggles.AutoCraftSunGod.Value then
            local hasTitle = false
            local sunEssence = 0
            local solarShard = 0
            local flamePulse = 0
            local divineRemnant = 0
            
            for _, item in pairs(Status.Cached.Inv or {}) do
                local iName = item.name
                if iName == "Sun Essence" then
                    sunEssence = item.quantity or 0
                elseif iName == "Solar Shard" then
                    solarShard = item.quantity or 0
                elseif iName == "Flame Pulse" then
                    flamePulse = item.quantity or 0
                elseif iName == "Divine Remnant" then
                    divineRemnant = item.quantity or 0
                end
            end
            
            local titles = Plr:FindFirstChild("Data") and Plr.Data:FindFirstChild("Titles")
            if titles and titles:FindFirstChild("Sun Dancer") then
                hasTitle = true
            end

            -- Syarat pedang: Sun Dancer title + 2 Essence + 5 Shard + 9 Pulse + 16 Remnant
            if hasTitle and sunEssence >= 2 and solarShard >= 5 and flamePulse >= 9 and divineRemnant >= 16 then
                -- Teleport ke NPC Sun God di atas tebing Slayer Island
                local npc = nil
                for _, child in ipairs(workspace.ServiceNPCs:GetChildren()) do
                    local cName = child.Name:lower()
                    if cName:find("sungod") or cName:find("sun god") or cName:find("yoriichi") then
                        npc = child
                        break
                    end
                end
                if not npc then
                    for _, child in ipairs(workspace:GetChildren()) do
                        local cName = child.Name:lower()
                        if cName:find("sungod") or cName:find("sun god") or cName:find("yoriichi") then
                            npc = child
                            break
                        end
                    end
                end
                local char = GetCharacter()
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if npc and root then
                    Library:Notify("Bahan lengkap! Teleport ke NPC Sun God untuk craft pedang...", 5)
                    root.CFrame = npc:GetPivot() * CFrame.new(0, 3, 0)
                    task.wait(0.5)
                    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                    task.wait(2)
                    
                    -- Invoke Craft Remote
                    if Remotes.RequestRelicCraft then
                        Remotes.RequestRelicCraft:InvokeServer("SunGodSword")
                    end
                end
            end
        end
    end
end)

task.spawn(Func_AutoTrade)

Toggles.AutoSpec:OnChanged(function(state)
    Thread("AutoSpecPassive", SafeLoop("Spec Passive", AutoSpecPassiveLoop), state)
end)

Toggles.AutoPower:OnChanged(function(state)
    Thread("AutoPower", SafeLoop("PowerRoll", AutoPowerLoop), state)
end)


Toggles.AutoRollStats:OnChanged(function(state)
    Thread("AutoRollStats", SafeLoop("Stat Roll", AutoRollStatsLoop), state)
end)

Toggles.AutoSkillTree:OnChanged(function(state)
    Thread("AutoSkillTree", SafeLoop("Skill Tree", AutoSkillTreeLoop), state)
end)
Toggles.AutoEnchant:OnChanged(function(s) Thread("AutoEnchant", SafeLoop("Enchant", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoEnchantAll:OnChanged(function(s) Thread("AutoEnchantAll", SafeLoop("EnchantAll", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoBlessing:OnChanged(function(s) Thread("AutoBlessing", SafeLoop("Blessing", function() AutoUpgradeLoop("Blessing") end), s) end)
Toggles.AutoBlessingAll:OnChanged(function(s) Thread("AutoBlessingAll", SafeLoop("BlessingAll", function() AutoUpgradeLoop("Blessing") end), s) end)
local function UpdateDungeonThread()
    local active =
        (Toggles.AutoDungeon and Toggles.AutoDungeon.Value) or
        (Toggles.AutoDiff and Toggles.AutoDiff.Value) or
        (Toggles.AutoReplay and Toggles.AutoReplay.Value) or
        (Toggles.DungeonAutofarm and Toggles.DungeonAutofarm.Value)
    Thread("AutoDungeon", Func_AutoDungeon, active)
end

Toggles.AutoDungeon:OnChanged(UpdateDungeonThread)
Toggles.AutoDiff:OnChanged(UpdateDungeonThread)
Toggles.AutoReplay:OnChanged(UpdateDungeonThread)
Toggles.DungeonAutofarm:OnChanged(UpdateDungeonThread)

Toggles.AutoMerchant:OnChanged(function(state)
    if state then
        Status.Main.FirstMerchantSync = false
    end
    Thread("AutoMerchant", SafeLoop("Merchant", Func_AutoMerchant), state)
end)

Toggles.AutoChest:OnChanged(function(state)
    Thread("AutoChest", SafeLoop("Chest", Func_AutoChest), state)
end)

Toggles.AutoCraftItem:OnChanged(function(state)
    Thread("AutoCraft", SafeLoop("Craft", Func_AutoCraft), state)
end)

Toggles.AutoQuestline:OnChanged(function(state)
    Thread("AutoQuestline", SafeLoop("Questline", AutoQuestlineLoop), state)
end)

Toggles.AntiKnockback:OnChanged(function(state)
    Thread("AntiKnockback", Func_AntiKnockback, state)
end)

Toggles.TPW:OnChanged(function(v)
    TPW_S:SetVisible(TPW_T.Value)
    Thread("TPW", FuncTPW, v)
end)
Toggles.Noclip:OnChanged(function(v)
    Thread("Noclip", FuncNoclip, v)
end)

Status.Connections.Player_General = RunService.Stepped:Connect(function()
    local Hum = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
    if Hum then
        if Toggles.WS.Value then Hum.WalkSpeed = Options.WSValue.Value end
        if Toggles.JP.Value then Hum.JumpPower = Options.JPValue.Value Hum.UseJumpPower = true end
        if Toggles.HH.Value then Hum.HipHeight = Options.HHValue.Value end
    end
        workspace.Gravity = Toggles.Grav.Value and Options.GravValue.Value or 192
        if Toggles.FOV.Value then workspace.CurrentCamera.FieldOfView = Options.FOVValue.Value end
        if Toggles.Zoom.Value then Plr.CameraMaxZoomDistance = Options.ZoomValue.Value end

    Status.Cached._lastPlayerPosCache = Status.Cached._lastPlayerPosCache or 0
    if tick() - Status.Cached._lastPlayerPosCache > 0.8 then
        Status.Cached._lastPlayerPosCache = tick()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Plr then
                local c = p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    Status.Cached.PlayerLastPos[p.Name] = hrp.Position
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.Fullbright.Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        elseif Toggles.OverrideTime.Value then
            Lighting.ClockTime = Options.OverrideTimeValue.Value
        end
        if Toggles.NoFog.Value then Lighting.FogEnd = 9e9 end
        if Library.Unloaded then break end
    end
end)

Options.LimitFPSValue:OnChanged(function()
    if FPS_T.Value then
        setfpscap(FPS_S.Value)
    end
end)

Toggles.LimitFPS:OnChanged(function(v)
    FPS_S:SetVisible(FPS_T.Value)
    if not v then
        setfpscap(60)
    end
end)

RunService.Stepped:Connect(function()
    if Status.Main.Farm and Status.Main.Target then
        local char = Plr.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not Toggles.SendWebhook.Value and #Status.Cached.NewItem > 100 then
            table.clear(Status.Cached.NewItem)
        end
    end
end)

Toggles.Disable3DRender:OnChanged(function(v) RunService:Set3dRenderingEnabled(not v) end)

Toggles.FPSBoost:OnChanged(function(state)
    ApplyFPSBoost(state)
end)

Toggles.FPSBoost_AF:OnChanged(function(state)
    if state then
        ApplyIslandWipe()
    end
end)

Toggles.AntiKick:OnChanged(function(state)
    if state then
        Func_AntiKickClient()
    end
end)

Toggles.AutoReconnect:OnChanged(function(state)
    if state then Func_AutoReconnect() end
end)

Toggles.NoGameplayPaused:OnChanged(function(state)
    Thread("NoGameplayPaused", SafeLoop("Anti-Pause", Func_NoGameplayPaused), state)
end)

Toggles.AutoRejoinMemory:OnChanged(function(state)
    Thread("AutoRejoinMemory", SafeLoop("AutoRejoinMemory", Func_MemoryMonitor), state)
end)

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.InstantPP and Toggles.InstantPP.Value then
        prompt.HoldDuration = 0
    end
end)

Options.PanicKeybind:OnClick(function()
    PanicStop()
end)

Remotes.SpecPassiveUpdate.OnClientEvent:Connect(function(data)
    if type(Status.Main.Passives) ~= "table" then Status.Main.Passives = {} end
    
    if data and data.Passives then
        for weaponName, info in pairs(data.Passives) do
            if type(info) == "table" then
                Status.Main.Passives[weaponName] = info
            else
                Status.Main.Passives[weaponName] = { Name = tostring(info), RolledBuffs = {} }
            end
        end
        pcall(UpdateSpecPassiveLabel)
    end
end)

Remotes.UpStatReroll.OnClientEvent:Connect(function(data)
    if data and data.Stats then
        Status.Main.GemStats = data.Stats
        task.spawn(UpdateStatsLabel)
    end
end)

Remotes.UpPlayerStats.OnClientEvent:Connect(function(data)
    if data and data.Stats then
        Status.Main.Stats = data.Stats
        UpdateStatsLabel()
    end
end)

Remotes.UpAscend.OnClientEvent:Connect(function(data)
    if not Toggles.AutoAscend.Value then return end
    
    UpdateAscendUI(data)

    if data.isMaxed then 
        Toggles.AutoAscend:SetValue(false) 
        return 
    end

    if data.allMet then
        Library:Notify("All requirements met! Attempt to ascend into: " .. data.nextRankName, 5)
        Remotes.Ascend:FireServer()
        task.wait(1)
    end
end)

task.spawn(function()
    while getgenv().solanahub_community_running do
        if Remotes.ReqInventory then
            Remotes.ReqInventory:FireServer()
        end
        task.wait(60)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().solanahub_community_running then break end
        
        pcall(function()
            if PityLabel then
                local current, max = GetCurrentPity()
                PityLabel:SetText(string.format("Pity: %d/%d", current or 0, max or 25))
            end
        end)
    end
end)

task.spawn(function()
    DisableIdled()
    if Status.Connections.Idled then
        Status.Connections.Idled:Disconnect()
        Status.Connections.Idled = nil
    end

    Status.Connections.Idled = Plr.Idled:Connect(function()
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            PulseAntiAFK()
        end
    end)

    while true do
        task.wait(20)
        if not getgenv().solanahub_community_running then break end
        
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            PulseAntiAFK()
        end
    end

    if Status.Connections.Idled then
        Status.Connections.Idled:Disconnect()
        Status.Connections.Idled = nil
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if Status.Main.AltActive then continue end
            if not Status.Main.Farm or Status.Main.MerchantBusy or not Status.Main.Target then continue end
        
        local success, err = pcall(function()
            local char = GetCharacter()
            local target = Status.Main.Target
            if not target or not char then return end
            
            local npcHum = target:FindFirstChildOfClass("Humanoid")
            local npcRoot = GetTargetAttackPart(target)
            local root = char:FindFirstChild("HumanoidRootPart")
            local myHum = char:FindFirstChildOfClass("Humanoid")
            local isSeaBeastTarget = target:FindFirstChild("SeaBeastHitbox") ~= nil
            local seaHitPos = nil
            local autoDodgeSeaBeast = false
            
            if npcRoot and root then
                if isSeaBeastTarget then
                    local seaAnchor = target:FindFirstChild("RootPart") or npcRoot
                    local seaHitPart = target:FindFirstChild("SeaBeastHitbox") or npcRoot
                    autoDodgeSeaBeast = Options.SeaBeastAutoDodge and Options.SeaBeastAutoDodge.Value
                    local sbType = Options.SeaBeastFarmType and Options.SeaBeastFarmType.Value or "Safe Distance"
                    local parkMode = Options.SeaBeastParkMode and Options.SeaBeastParkMode.Value
                    
                    -- Get configuration values
                    local safeDistance = tonumber(Options.SeaBeastSafeDistance and Options.SeaBeastSafeDistance.Value) or 35
                    local orbitRadius = tonumber(Options.SeaBeastOrbitRadius and Options.SeaBeastOrbitRadius.Value) or 80
                    local orbitHeight = tonumber(Options.SeaBeastOrbitHeight and Options.SeaBeastOrbitHeight.Value) or 20
                    local smoothing = tonumber(Options.SeaBeastSmoothing and Options.SeaBeastSmoothing.Value) or 0.15
                    local randomOffset = tonumber(Options.SeaBeastRandomOffset and Options.SeaBeastRandomOffset.Value) or 3
                    local faceTarget = Options.SeaBeastFaceTarget and Options.SeaBeastFaceTarget.Value
                    
                    -- Legacy fallback values
                    local sbSide = tonumber(Options.SeaBeastParkSide and Options.SeaBeastParkSide.Value) or 0
                    local sbBack = tonumber(Options.SeaBeastParkBack and Options.SeaBeastParkBack.Value) or 24
                    local sbHeight = tonumber(Options.SeaBeastParkHeight and Options.SeaBeastParkHeight.Value) or 28
                    local sbDist = tonumber(Options.SeaBeastDistance and Options.SeaBeastDistance.Value) or 12
                    
                    local targetPos = seaHitPart.Position
                    local currentPos = root.Position
                    local desiredPos
                    local lookAtPos = seaAnchor.Position
                    
                    -- Calculate direction from target to player (safe distance direction)
                    local direction = (currentPos - targetPos).Unit
                    if direction.Magnitude < 0.001 then
                        direction = Vector3.new(0, 0, 1)
                    end
                    
                    -- Generate random offset for natural movement (changes every few seconds)
                    if not Status.SeaBeastRandomSeed or (tick() - (Status.SeaBeastLastRandomUpdate or 0)) > 2 then
                        Status.SeaBeastRandomSeed = Vector3.new(
                            math.random(-100, 100) / 100,
                            math.random(-100, 100) / 100,
                            math.random(-100, 100) / 100
                        )
                        Status.SeaBeastLastRandomUpdate = tick()
                    end
                    local randomVec = Status.SeaBeastRandomSeed * randomOffset
                    
                    -- Check if too close and need to back away
                    local currentDist = (currentPos - targetPos).Magnitude
                    local minSafeDist = safeDistance - 5
                    
                    if sbType == "Safe Distance" or sbType == nil then
                        -- Safe Distance Mode: Maintain distance from hitbox using direction vector
                        desiredPos = targetPos + direction * safeDistance + Vector3.new(0, 5, 0) + randomVec
                        
                        -- If too close, back away immediately
                        if currentDist < minSafeDist then
                            local backAwayDir = (currentPos - targetPos).Unit
                            desiredPos = currentPos + backAwayDir * 10 + Vector3.new(0, 5, 0)
                        end
                        
                    elseif sbType == "Orbit" then
                        -- Orbit Mode: Larger radius with height offset
                        local timeOffset = tick() * 0.5 -- Rotation speed
                        local angle = timeOffset % (2 * math.pi)
                        local orbitX = math.cos(angle) * orbitRadius
                        local orbitZ = math.sin(angle) * orbitRadius
                        desiredPos = targetPos + Vector3.new(orbitX, orbitHeight, orbitZ) + randomVec
                        
                    elseif parkMode then
                        -- Legacy Park Mode
                        sbBack = math.max(sbBack, 20)
                        desiredPos = (seaAnchor.CFrame * CFrame.new(sbSide, sbHeight, sbBack)).Position + randomVec
                        
                    elseif sbType == "Above" then
                        desiredPos = seaAnchor.Position + Vector3.new(0, sbDist, 0) + randomVec
                        
                    elseif sbType == "Below" then
                        desiredPos = seaAnchor.Position + Vector3.new(0, -sbDist, 0) + randomVec
                        
                    else
                        -- Legacy Behind mode
                        desiredPos = (seaAnchor.CFrame * CFrame.new(0, 0, sbDist)).Position + randomVec
                    end
                    
                    -- Cancel any active tween for instant response
                    if Status.Cached.activeTween then
                        Status.Cached.activeTween:Cancel()
                        Status.Cached.activeTween = nil
                    end
                    
                    -- Smooth movement using Lerp
                    local targetCFrame
                    if faceTarget then
                        targetCFrame = CFrame.lookAt(desiredPos, lookAtPos)
                    else
                        targetCFrame = CFrame.new(desiredPos)
                    end
                    
                    -- Apply smoothing with Lerp
                    local smoothedCFrame = root.CFrame:Lerp(targetCFrame, math.clamp(smoothing, 0.05, 1))
                    root.CFrame = smoothedCFrame
                    
                    -- Zero out velocities for stable positioning
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    
                    -- Emergency: if still too close after movement, teleport back
                    local newDist = (root.Position - targetPos).Magnitude
                    if newDist < 15 then
                        local emergencyDir = (root.Position - targetPos).Unit
                        local emergencyPos = targetPos + emergencyDir * safeDistance + Vector3.new(0, 10, 0)
                        root.CFrame = CFrame.lookAt(emergencyPos, lookAtPos)
                    end

                    npcRoot = seaAnchor
                    seaHitPos = seaHitPart.Position
                end

                if autoDodgeSeaBeast and myHum then
                    local lastHP = tonumber(Status.Main.SeaBeastLastHP) or myHum.Health
                    if myHum.Health < (lastHP - 0.5) then
                        local dodgeTime = tonumber(Options.SeaBeastDodgeTime and Options.SeaBeastDodgeTime.Value) or 0.55
                        Status.Main.SeaBeastDodgeUntil = tick() + math.clamp(dodgeTime, 0.2, 1.5)
                    end
                    Status.Main.SeaBeastLastHP = myHum.Health
                elseif myHum then
                    Status.Main.SeaBeastLastHP = myHum.Health
                end

                if isSeaBeastTarget and (Status.Main.SeaBeastDodgeUntil or 0) > tick() then
                    local dodgeHeight = tonumber(Options.SeaBeastDodgeHeight and Options.SeaBeastDodgeHeight.Value) or 28
                    local smoothing = tonumber(Options.SeaBeastSmoothing and Options.SeaBeastSmoothing.Value) or 0.15
                    local faceTarget = Options.SeaBeastFaceTarget and Options.SeaBeastFaceTarget.Value
                    
                    -- Calculate evade position: up and back for safety
                    local seaHitPart = target:FindFirstChild("SeaBeastHitbox") or npcRoot
                    local targetPos = seaHitPart.Position
                    local currentPos = root.Position
                    local safeDistance = tonumber(Options.SeaBeastSafeDistance and Options.SeaBeastSafeDistance.Value) or 35
                    
                    -- Direction away from target
                    local awayDir = (currentPos - targetPos).Unit
                    if awayDir.Magnitude < 0.001 then
                        awayDir = Vector3.new(0, 1, 0)
                    end
                    
                    -- Evade up and away from hitbox
                    local evadePos = targetPos + awayDir * (safeDistance + 10) + Vector3.new(0, math.clamp(dodgeHeight, 10, 80), 0)
                    
                    local targetCFrame
                    if faceTarget then
                        targetCFrame = CFrame.lookAt(evadePos, targetPos)
                    else
                        targetCFrame = CFrame.new(evadePos)
                    end
                    
                    -- Apply smoothing even during dodge
                    local smoothedCFrame = root.CFrame:Lerp(targetCFrame, math.clamp(smoothing * 2, 0.1, 1))
                    root.CFrame = smoothedCFrame
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    return
                end

                local currentDist = (root.Position - npcRoot.Position).Magnitude
                local hpPercent = npcHum and (npcHum.Health / npcHum.MaxHealth) * 100 or 100
                local minMaxHP = tonumber(Options.InstaKillMinHP.Value) or 0
                local ikThreshold = tonumber(Options.InstaKillHP.Value) or 90

            if npcHum and Toggles.InstaKill.Value and npcHum.MaxHealth >= minMaxHP and hpPercent < ikThreshold then
                npcHum.Health = 0 
                if not target:GetAttribute("IK_Active") then
                    target:SetAttribute("IK_Active", true)
                    target:SetAttribute("TriggerTime", tick())
                end
            end

                if currentDist < 35 then
                    if (not isSeaBeastTarget) and math.abs(root.Position.Y - npcRoot.Position.Y) > 50 then
                        root.Velocity = Vector3.new(0, -100, 0)
                    end

                    local m1Delay = tonumber(Options.M1Speed.Value) or 0.2
                    if tick() - Status.Main.LastM1 >= m1Delay then
                        EquipWeapon() 
                        if target:FindFirstChild("SeaBeastHitbox") then
                            Remotes.M1:FireServer(seaHitPos or target.SeaBeastHitbox.Position)
                        else
                            Remotes.M1:FireServer()
                        end
                        Status.Main.LastM1 = tick()
                    end
                end
            end
        end)
        
        if not success then
            Library:Notify("ERROR: " .. tostring(err), 10)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if not Status.Main.Farm or Status.Main.MerchantBusy then 
            Status.Main.Target = nil 
            continue 
        end

        local char = GetCharacter()
        if not char or Status.Main.Recovering then continue end

        if Status.Main.TargetValid then
            local target = Status.Main.Target
            local invalidTarget = (not target or not target.Parent)
            if not invalidTarget and target then
                local targetHum = target:FindFirstChildOfClass("Humanoid")
                if targetHum and targetHum.Health <= 0 then
                    invalidTarget = true
                end
            end
            if invalidTarget then
                Status.Main.KillTick = tick()
                Status.Main.TargetValid = false
            end
        end

        if tick() - Status.Main.KillTick < (tonumber(Options.TargetTPCD.Value) or 0) then continue end

        HandleSummons()

        local currentPity, maxPity = GetCurrentPity()
        local isPityReady = Toggles.PityBossFarm.Value and currentPity >= (maxPity - 1)
        
        local foundTask = false
        
        -- [ SEA 2 VOYAGE OVERRIDE ]
        if Options.AutoTravelSea2 and Options.AutoTravelSea2.Value then
            foundTask = true
            pcall(function()
                local char = GetCharacter()
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Step 1: Check if Sea 2 quest ("Lost Fragment") is active
                local qUI = PGui:FindFirstChild("QuestUI") and PGui.QuestUI:FindFirstChild("Quest")
                local questTitle = ""
                if qUI then
                    pcall(function()
                        questTitle = qUI.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
                    end)
                end
                local isQuestActive = string.find(questTitle or "", "Lost Fragment") ~= nil

                if not isQuestActive then
                    -- Accept quest from MapQuestNPC in ServiceNPCs
                    Library:Notify("Sea 2: Accepting quest from NPC...", 3)
                    local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("MapQuestNPC")
                    if npc then
                        root.CFrame = npc:GetPivot() * CFrame.new(0, 3, 0)
                        task.wait(0.5)
                        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then fireproximityprompt(prompt) end
                        task.wait(1)
                    else
                        Library:Notify("Sea 2: MapQuestNPC not found!", 5)
                    end
                else
                    -- Quest active: collect Lost Fragments
                    local closestFrag, closestDist = nil, math.huge
                    
                    local function checkFragment(child)
                        if (string.find(child.Name, "MapFragment") or string.find(child.Name, "Ancient Fragment")) and child:FindFirstChildWhichIsA("ProximityPrompt", true) then
                            local dist = (child:GetPivot().Position - root.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestFrag = child
                            end
                        end
                    end

                    local sea2Folder = workspace:FindFirstChild("Sea2MapQuest")
                    if sea2Folder then
                        for _, child in ipairs(sea2Folder:GetChildren()) do
                            checkFragment(child)
                        end
                    end
                    
                    -- Fallback scan if not in folder
                    if not closestFrag then
                        for _, child in ipairs(workspace:GetChildren()) do
                            checkFragment(child)
                        end
                    end

                    if closestFrag then
                        Library:Notify("Sea 2: Collecting fragment...", 2)
                        root.CFrame = closestFrag:GetPivot()
                        task.wait(0.5)
                        local prompt = closestFrag:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then fireproximityprompt(prompt) end
                        task.wait(0.5)
                    else
                        Library:Notify("Sea 2: No fragments here, try another island.", 3)
                    end

                    -- Check if quest completed
                    task.wait(0.5)
                    local newTitle = ""
                    pcall(function()
                        newTitle = qUI.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
                    end)
                    if qUI and (not qUI.Visible or (newTitle ~= "" and not string.find(newTitle, "Lost Fragment"))) then
                        Library:Notify("Sea 2 Quest Complete! Please turn off this auto and use the Travel button.", 5)
                        if Toggles.AutoTravelSea2 then Toggles.AutoTravelSea2:SetValue(false) end
                    end
                end
            end)
        end
        -- [ SEA BEAST / KRAKEN OVERRIDE ]
        local doSeaBeast = (Options.AutoKraken and Options.AutoKraken.Value) or (Options.AutoSummonSeaBeast and Options.AutoSummonSeaBeast.Value)
        
        if not foundTask and doSeaBeast then
            Status.Main.IsSea2 = workspace:FindFirstChild("Sea") ~= nil
            
            if not Status.Main.IsSea2 then
                if not Status.Main.NotifiedSea2 then
                    Library:Notify("Auto Sea Beast hanya bekerja di Sea 2!", 5)
                    Status.Main.NotifiedSea2 = true
                end
                if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: Must be in Sea 2") end
            else
                -- In Sea 2
                local sb = nil
                local selectedTarget = Options.SelectedSeaBeast and Options.SelectedSeaBeast.Value or "Any"
                
                local function IsValidBeast(model)
                    if not model:FindFirstChild("SeaBeastHitbox") then return false end
                    local modelName = tostring(model.Name or ""):lower()
                    if selectedTarget == "Any" then return true end
                    if selectedTarget == "Kraken" and modelName:find("kraken") then return true end
                    if selectedTarget == "Sea Serpent" and (modelName:find("serpent") or modelName:find("seaserpent")) then return true end
                    return false
                end
                
                pcall(function()
                    for _, npc in ipairs(PATH.Mobs:GetChildren()) do
                        if IsValidBeast(npc) then
                            sb = npc
                            break
                        end
                    end
                    if not sb then
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and IsValidBeast(obj) then
                                sb = obj
                                break
                            end
                        end
                    end
                end)

                if sb and Options.AutoKraken and Options.AutoKraken.Value then
                    local hum = sb:FindFirstChildOfClass("Humanoid")
                    local hitPart = GetTargetAttackPart(sb)
                    if hitPart and ((not hum) or hum.Health > 0) then
                        foundTask = true
                        Status.Main.Target = sb
                        Status.Main.TargetValid = true
                        if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: ⚔️ Fighting " .. sb.Name) end
                        UpdateSwitchState(sb, "Boss")
                        if Options.SeaBeastParkMode and Options.SeaBeastParkMode.Value then
                            if Status.Cached.activeTween then
                                Status.Cached.activeTween:Cancel()
                                Status.Cached.activeTween = nil
                            end
                        else
                            ExecuteFarmLogic(sb, "Open Ocean", "Boss")
                        end
                    end
                elseif Options.AutoSummonSeaBeast and Options.AutoSummonSeaBeast.Value then
                    -- 🔍 MODE: SUMMON ONLY
                    foundTask = true
                    local char = GetCharacter()
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- 🔥 Base Fixed Position (Klakuylek)
                        local baseSeaPos = Vector3.new(1310.7301025390625, -8.301657676696777, 368.77239990234375)
                        
                        -- Generate dynamic offset every 15 seconds to fake movement (AFK anti-stuck)
                        if not Status.Main.AFKSeaTimer or (tick() - Status.Main.AFKSeaTimer) > 15 then
                            Status.Main.AFKSeaTimer = tick()
                            local randAngle = math.rad(math.random(0, 360))
                            local randDist = math.random(50, 150)
                            Status.Main.AFKSeaOffset = Vector3.new(math.cos(randAngle) * randDist, 0, math.sin(randAngle) * randDist)
                        end
                        
                        local targetSeaPos = baseSeaPos + (Status.Main.AFKSeaOffset or Vector3.zero)
                        local distToSea = (targetSeaPos - root.Position).Magnitude
                        
                        if distToSea > 10 then
                            if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: 🌊 Relocating around Sea...") end
                            if Options.SelectedMovementType and Options.SelectedMovementType.Value == "Teleport" then
                                root.CFrame = CFrame.lookAt(targetSeaPos, targetSeaPos + root.CFrame.LookVector)
                                task.wait(1)
                            else
                                local speed = tonumber(Options.TweenSpeed and Options.TweenSpeed.Value) or 180
                                if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
                                Status.Cached.activeTween = Tween:Create(root, TweenInfo.new(distToSea/speed, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(targetSeaPos, targetSeaPos + root.CFrame.LookVector)})
                                Status.Cached.activeTween:Play()
                                Status.Cached.activeTween.Completed:Connect(function()
                                    if Status.Cached.activeTween then
                                        Status.Cached.activeTween:Destroy()
                                        Status.Cached.activeTween = nil
                                    end
                                end)
                            end
                        else
                            if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: ⏳ AFK in Sea (Waiting spawn)") end
                            if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
                            root.CFrame = CFrame.lookAt(targetSeaPos, targetSeaPos + root.CFrame.LookVector)
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            task.wait(1)
                        end
                    end
                else
                    if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: 🔍 Searching...") end
                end
            end
        else
            if getgenv().SeaBeastStatusUI then getgenv().SeaBeastStatusUI:SetText("Status: Idle") end
        end

        -- [ EASTER EVENT OVERRIDE ]
        if not foundTask and Options.AutoGreatMage and Options.AutoGreatMage.Value then
            for _, v in ipairs(workspace.NPCs:GetChildren()) do
                local ml = v.Name:lower()
                if string.match(ml, "great mage") or string.match(ml, "greatmage") then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        foundTask = true
                        Status.Main.Target = v
                        Status.Main.TargetValid = true
                        UpdateSwitchState(v, "Boss")
                        ExecuteFarmLogic(v, "Easter Island", "Boss")
                        break
                    end
                end
            end
        end
        if not foundTask and Options.AutoFerinBoss and Options.AutoFerinBoss.Value then
            for _, v in ipairs(workspace.NPCs:GetChildren()) do
                local ml = v.Name:lower()
                if string.match(ml, "ferin") then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        foundTask = true
                        Status.Main.Target = v
                        Status.Main.TargetValid = true
                        UpdateSwitchState(v, "Boss")
                        ExecuteFarmLogic(v, "Easter Island", "Boss")
                        break
                    end
                end
            end
        end
        if not foundTask and Options.AutoBunnyMobs and Options.AutoBunnyMobs.Value then
            for _, v in ipairs(workspace.NPCs:GetChildren()) do
                local ml = v.Name:lower()
                if (string.match(ml, "bunny") or string.match(ml, "easter")) and not string.match(ml, "ferin") then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        foundTask = true
                        Status.Main.Target = v
                        Status.Main.TargetValid = true
                        UpdateSwitchState(v, "Mob")
                        ExecuteFarmLogic(v, "Easter Island", "Mob")
                        break
                    end
                end
            end
        end

        if not foundTask then
            for i = 1, #Status.Priority.Task do
            local taskName = Options["SelectedPriority_" .. i].Value
            if not taskName then continue end

            local isBossRelated = (taskName == "Boss" or taskName == "Summon" or taskName == "Alt Help" or taskName == "Pity Boss")

            if isPityReady and isBossRelated then
                local t, isl, fType = GetPityTarget()
                if t then
                    foundTask = true
                    Status.Main.Target = t
                    Status.Main.TargetValid = true
                    UpdateSwitchState(t, fType)
                    ExecuteFarmLogic(t, isl, fType)
                    break 
                end
            else
                local t, isl, fType = CheckTask(taskName)
                if t then
                    foundTask = true
                    Status.Main.Target = t
                    Status.Main.TargetValid = true
                    UpdateSwitchState(t, fType)
                    if taskName ~= "Merchant" then 
                        ExecuteFarmLogic(t, isl, fType) 
                    end
                    break 
                end
            end
            end
        end

        if not foundTask then
            Status.Main.Target = nil
            UpdateSwitchState(nil, "None")
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().solanahub_community_running then break end
        
        local char = GetCharacter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root and not Status.Main.MovingIsland then
            local pos = root.Position
            
            if pos.Y > 5000 or math.abs(pos.X) > 10000 or math.abs(pos.Z) > 10000 then
                Status.Main.Recovering = true
                Library:Notify("Something wrong, attempt to reset..", 5)
                
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                
                if Tables.IslandCrystals["Starter"] then
                    root.CFrame = Tables.IslandCrystals["Starter"]:GetPivot() * CFrame.new(0, 5, 0)
                    task.wait(1)
                end
                
                Status.Main.Recovering = false
            end
        end
    end
end)

local MenuGroup = Tabs.Config:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("AutoShowUI", {
    Text = "Auto Show UI",
    Default = true,
})

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
		Text = "Custom Cursor",
		Default = false,
		Callback = function(Value)
			Library.ShowCustomCursor = Value
		end,
	})
MenuGroup:AddToggle("DebugMode", {
    Text = "Debug Logs/Notify",
    Default = DEBUG_ENABLED,
    Callback = function(v)
        SetDebugEnabled(v)
    end,
})

-- ================================================================
-- EASTER EVENT 2026 UI (SEA 2 UPDATE)
-- ================================================================
GB.Event.Left.Easter:AddToggle("AutoEasterQuests", {
    Text = "Auto Egg Hunt Quest",
    Default = false,
    Tooltip = "Otomatis cari 7 Telur Paskah",
    Callback = function(v) Options.AutoEasterQuests.Value = v end
})

GB.Event.Left.Easter:AddToggle("AutoBunnyMobs", {
    Text = "Auto Farm Bunny Mobs",
    Default = false,
    Tooltip = "Farming Bunny untuk hadiah Easter Keys",
    Callback = function(v) Options.AutoBunnyMobs.Value = v end
})

GB.Event.Left.Easter:AddToggle("AutoFerinBoss", {
    Text = "Auto Ferin Boss",
    Default = false,
    Tooltip = "Gunakan kunci untuk panggil dan bunuh Ferin Boss",
    Callback = function(v) Options.AutoFerinBoss.Value = v end
})

GB.Event.Left.Easter:AddToggle("AutoGreatMage", {
    Text = "Auto Great Mage",
    Default = false,
    Tooltip = "Bunuh Great Mage otomatis",
    Callback = function(v) Options.AutoGreatMage.Value = v end
})

GB.Event.Right.Teleport:AddButton("Teleport Easter Island", function()
    Library:Notify("Mencari Easter Island...", 3)
    pcall(function()
        -- Method 1: Use TP_Portal remote (same as island teleport system)
        local easterName = nil
        for _, name in ipairs(Tables.IslandList) do
            if string.find(name:lower(), "easter") then
                easterName = name
                break
            end
        end
        if easterName then
            Remotes.TP_Portal:FireServer(GetTPName(easterName))
            Library:Notify("Teleport ke " .. easterName .. " berhasil!", 3)
            return
        end
        
        -- Method 2: Use crystal checkpoint
        for crystalName, crystal in pairs(Tables.IslandCrystals) do
            if string.find(crystalName:lower(), "easter") then
                local char = GetCharacter()
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = crystal:GetPivot() * CFrame.new(0, 10, 0)
                    Library:Notify("Teleport ke Easter Crystal berhasil!", 3)
                    return
                end
            end
        end

        Library:Notify("Easter Island tidak ditemukan! Coba Refresh Islands.", 5)
    end)
end)

GB.Event.Right.Teleport:AddDivider()

GB.Event.Right.Teleport:AddButton("Teleport to Sea 2", function()
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    pcall(function()
        Library:Notify("Teleporting to World Island (Sea 1)...", 2)
        Remotes.TP_Portal:FireServer("World")
    end)
    
    task.wait(3) -- Wait for anti-cheat and teleport to resolve
    
    local door = workspace:FindFirstChild("WorldIsland") and workspace.WorldIsland:FindFirstChild("Model") and workspace.WorldIsland.Model:FindFirstChild("Map") and workspace.WorldIsland.Model.Map:FindFirstChild("Door") and workspace.WorldIsland.Model.Map.Door:FindFirstChild("Cube.003")
    if door then
        Library:Notify("Entering Portal...", 2)
        root.CFrame = door.CFrame
        task.wait(0.5)
        local prompt = door:FindFirstChild("Sea2DoorPrompt") or door:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then 
            fireproximityprompt(prompt) 
        else
            Library:Notify("Prompt portal tidak ditemukan!", 4)
        end
    else
        Library:Notify("World Island Door tidak ditemukan di area ini!", 4)
    end
end)

GB.Event.Right.Teleport:AddButton("Teleport to Sea 1", function()
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    pcall(function()
        Library:Notify("Teleporting to Sea2World Island (Sea 2)...", 2)
        Remotes.TP_Portal:FireServer("Sea2World")
    end)
    
    task.wait(3) -- Wait for anti-cheat and teleport to resolve
    
    local door = workspace:FindFirstChild("WorldIsland") and workspace.WorldIsland:FindFirstChild("Model") and workspace.WorldIsland.Model:FindFirstChild("Map") and workspace.WorldIsland.Model.Map:FindFirstChild("Door") and workspace.WorldIsland.Model.Map.Door:FindFirstChild("Cube.003")
    if door then
        Library:Notify("Entering Portal...", 2)
        root.CFrame = door.CFrame
        task.wait(0.5)
        local prompt = door:FindFirstChild("Sea2DoorPrompt") or door:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then 
            fireproximityprompt(prompt) 
        else
            Library:Notify("Prompt portal tidak ditemukan!", 4)
        end
    else
        Library:Notify("World Island Door tidak ditemukan di area ini!", 4)
    end
end)


MenuGroup:AddDropdown("NotificationSide", {
		Values = { "Left", "Right" },
		Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "U", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
    getgenv().solanahub_community_running = false
    Status.Main.Farm = false
    Cleanup(Status.Connections)
    Cleanup(Flags)
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "SelectedIsland" })
SaveManager:SetIgnoreIndexes({ "SelectedQuestNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMiscNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMiscAllNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMovesetNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMasteryNPC" })

ThemeManager:SetFolder("solanahub_community")
SaveManager:SetFolder("solanahub_community/sailor_solanahub")

-- SaveManager:BuildConfigSection(Tabs.Config)

ThemeManager:ApplyToTab(Tabs.Config)


DebugCheckFeatureBindings()
UpdateNPCLists()
PopulateNPCLists()
UpdateAllEntities()
InitAutoKick()
ACThing(true)

PATH.InteractNPCs.ChildAdded:Connect(function()
    task.defer(PopulateNPCLists)
end)

PATH.InteractNPCs.ChildRemoved:Connect(function()
    task.defer(PopulateNPCLists)
end)

task.spawn(function()
    if Remotes.ReqInventory then Remotes.ReqInventory:FireServer() end

    local timeout = 0
    while not Status.Main.InventorySynced and timeout < 5 do
        task.wait(0.15)
        timeout = timeout + 0.15
        
        if timeout == 1.5 then Remotes.ReqInventory:FireServer() end
    end

        task.spawn(function()
            local EasterState = {
                StaticIslands = {"Jungle", "Snow", "Sailor"},
                VisitedStatic = { Jungle = false, Snow = false, Sailor = false },
                TimedIslands = {"Starter", "Desert", "Shibuya", "Lawless"},
                TimedIndex = 1,
                BossIslands = {"Desert", "Sailor", "Slime", "Judgement", "Snow", "Academy"},
                BossIndex = 1,
                LastHop = 0,
                EggTries = {},
                BlacklistedEggs = {}
            }

            while task.wait(1) do
                if Options.AutoEasterQuests and Options.AutoEasterQuests.Value then
                    pcall(function()
                        local char = GetCharacter()
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
                        local questUI = PGui:FindFirstChild("QuestUI")
                        local inQuest = questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible
                        
                        -- Phase 1: Take Quest
                        if not inQuest then
                            if Status.Main.Island ~= "Easter" then
                                if tick() - EasterState.LastHop > 10 then
                                    Library:Notify("Moving to Easter Island to accept quest...", 3)
                                    Remotes.TP_Portal:FireServer("Easter")
                                    Status.Main.Island = "Easter"
                                    EasterState.LastHop = tick()
                                end
                                return
                            end
                            
                            local easterNPC = nil
                            local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
                            if serviceNPCs then
                                easterNPC = serviceNPCs:FindFirstChild("EasterQuestNPC") or serviceNPCs:FindFirstChild("EasterQuestNPC", true)
                            end
                            
                            if easterNPC then
                                root.CFrame = easterNPC:GetPivot() * CFrame.new(0, 3, 0)
                                task.wait(0.5)
                                local prompt = easterNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                                task.wait(1)
                            end
                            return
                        end

                        -- Hunt for Eggs locally first
                        local foundEgg = false
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if not Options.AutoEasterQuests.Value then break end
                            local nl = obj.Name:lower()
                            
                            -- Exact match for EasterEgg_HiddenEgg, EasterEgg_TimedEgg, EasterEgg_BossEgg
                            local isEgg = string.find(nl, "easteregg_hiddenegg") or string.find(nl, "easteregg_timedegg") or string.find(nl, "easteregg_bossegg")
                            if isEgg and not EasterState.BlacklistedEggs[obj] then
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and prompt.Enabled then
                                    local eggPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                    root.CFrame = CFrame.new(eggPos) * CFrame.new(0, 3, 0)
                                    task.wait(0.3)
                                    fireproximityprompt(prompt)
                                    
                                    -- Anti-stuck Tracking
                                    EasterState.EggTries[obj] = (EasterState.EggTries[obj] or 0) + 1
                                    if EasterState.EggTries[obj] >= 3 then
                                        EasterState.BlacklistedEggs[obj] = true
                                        Library:Notify("Egg appears already collected. Ignoring it and moving on.", 3)
                                    end
                                    
                                    task.wait(0.5)
                                    foundEgg = true
                                    break -- Focus on one egg per iteration
                                end
                            end
                        end
                        
                        if foundEgg then return end -- Don't hop if we are collecting
                        
                        -- Phase 2-4: Island Hopping
                        if tick() - EasterState.LastHop > 25 then
                            -- Only hop if we are NOT actively fighting a boss (unless we override)
                            local targetHum = Status.Main.Target and Status.Main.Target:FindFirstChildOfClass("Humanoid")
                            if targetHum and targetHum.Health > 0 and Status.Main.Target.Name:lower():find("reaper") then
                                return -- Stay and fight Reaper Soul!
                            end

                            local nextIsland = nil
                            
                            -- Check Static
                            for _, isl in ipairs(EasterState.StaticIslands) do
                                if not EasterState.VisitedStatic[isl] then
                                    if Status.Main.Island == isl then
                                        EasterState.VisitedStatic[isl] = true
                                    else
                                        nextIsland = isl
                                        break
                                    end
                                end
                            end
                            
                            -- Check Timed
                            if not nextIsland then
                                nextIsland = EasterState.TimedIslands[EasterState.TimedIndex]
                                EasterState.TimedIndex = EasterState.TimedIndex + 1
                                if EasterState.TimedIndex > #EasterState.TimedIslands then
                                    EasterState.TimedIndex = 1
                                    
                                    -- After checking timed, check Boss islands once
                                    nextIsland = EasterState.BossIslands[EasterState.BossIndex]
                                    EasterState.BossIndex = EasterState.BossIndex + 1
                                    if EasterState.BossIndex > #EasterState.BossIslands then
                                         EasterState.BossIndex = 1
                                         -- Wait a bit longer before rotating again if we checked everything
                                         EasterState.LastHop = tick() + 60 
                                    end
                                end
                            end
                            
                            if nextIsland and Status.Main.Island ~= nextIsland then
                                Library:Notify("Egg not found. Hopping to: " .. nextIsland, 3)
                                pcall(function() Remotes.TP_Portal:FireServer(nextIsland) end)
                                Status.Main.Island = nextIsland
                                EasterState.LastHop = tick()
                            end
                        end
                    end)
                end
            end
        end)

    -- SaveManager:LoadAutoloadConfig()
    task.wait(0.25)

    if Toggles.AntiKick and Toggles.AntiKick.Value then
        Func_AntiKickClient()
    end

    if Toggles.AutoRune.Value then
        Status.Main.LastSwitch.Rune = "REFRESHING"
        Toggles.AutoRune:SetValue(false)
        task.wait(.01)
        Toggles.AutoRune:SetValue(true)
    end
    
    Status.Main.LastSwitch.Title = "REFRESHING"
    
    if Remotes.ReqInventory then Remotes.ReqInventory:FireServer() end
end)

task.spawn(function()
    task.wait(0.1)
    if Toggles.AutoTitle and Toggles.AutoTitle.Value then
        Remotes.TitleUnequip:FireServer()
    end
end)

pcall(function()
    local screen = workspace.CurrentCamera.ViewportSize
    if screen.X > 0 and screen.Y > 0 then
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then
            local scale = (screen.X < 500) and 50 or 75
            Library:SetDPIScale(scale)
        else
            Library:SetDPIScale(100)
        end
    end
end)

ThemeManager:LoadDefault()

task.spawn(function()
    task.wait(0.1)
    if Toggles.AutoShowUI.Value == false then
        Library:Toggle()
    end
end)

Library:Notify("Script loaded.", 2)
Library:Notify("Report bug and give suggestion in Discord!", 5)

end)

if not eh_success then
    Library:Notify("ERROR: " .. tostring(err), 4)
end
