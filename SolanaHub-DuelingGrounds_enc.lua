if getgenv().SolHubTier == nil then
    getgenv().SolHubTier = "Premium"
end

if not game:IsLoaded() then game.Loaded:Wait() end

local ModernV2 = nil

-- Primary: Vercel mirror (no rate limit)
local loaderOk, loaderResult = pcall(function()
    local source = game:HttpGet("https://shinzux.vercel.app/files/ambaruto.txt")
    local fn, compileErr = loadstring(source)
    if not fn then error(compileErr) end
    return fn()
end)

if loaderOk then
    ModernV2 = loaderResult
else
    warn("[Solana Hub] Vercel mirror failed, trying GitHub fallback:", loaderResult)
    -- Fallback: GitHub raw (may be rate-limited)
    local fallbackOk, fallbackResult = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/Soliuse/SolHubNewUI/refs/heads/main/MainV2.lua")
        local fn, compileErr = loadstring(source)
        if not fn then error(compileErr) end
        return fn()
    end)
    if fallbackOk then
        ModernV2 = fallbackResult
    else
        warn("[Solana Hub] Failed to load ModernV2 from all sources:", fallbackResult)
    end
end

if not ModernV2 then return end

ModernV2:AddTheme({
	Name = "Solana Red",
	Accent = Color3.fromRGB(220, 35, 55),
	Background = Color3.fromRGB(8, 8, 13),
	Surface = Color3.fromRGB(20, 22, 27),
	Outline = Color3.fromRGB(45, 48, 58),
	Text = Color3.fromRGB(255, 255, 255),
	Placeholder = Color3.fromRGB(140, 140, 155),
	Button = Color3.fromRGB(220, 35, 55),
	Icon = Color3.fromRGB(255, 255, 255),
})

local MenuIcon = ModernV2:CreateMenuIcon({
	Image = "rbxassetid://135199868370962",
	Size = 48,
	IconColor = Color3.fromRGB(255, 255, 255),
	BGColor = Color3.fromRGB(20, 22, 27),
	StrokeColor = ModernV2.AccentColor,
	StrokeThick = 1.5,
	Draggable = true,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GameName = "Dueling Grounds v1.2"
local Window = ModernV2:Window({
	Title = "Solana Hub",
	Content = GameName,
	Image = "rbxassetid://135199868370962",
	Color = Color3.fromRGB(220, 35, 55),
	Uitransparent = 0.15,
	ShowUser = true,
	Search = true,
	ConfigEnabled = true,
	NotifyOnCallbackError = false,
	Loadingscreen = false,
	Enable3DRenderer = false,
	Keybind = "RightControl",
	Size = UDim2.fromOffset(500, 320),
	Config = {
		ConfigFolder = "SolanaHubDuelingGrounds",
		AutoSaveFile = "SOLANA_DG",
		AutoSave = true,
		AutoLoad = false,
		Overwrite = true,
		Format = "JSON",
		ShowAutoSaveToggle = true,
		TextGradient = true,
	},
})

Window:AttachMenuIcon(MenuIcon)

Window:SetAccount({
	Username = LocalPlayer.DisplayName,
	Profile = ModernV2.UserProfile,
	Expires = "Never",
})

Window:CreateHomeTab({
    Name = "Dashboard",
    Icon = "lucide:layout-dashboard",
    Content = "Solana Hub Dueling Grounds Script",
    DiscordInvite = "https://discord.gg/solanahub",
    SupportedExecutors = { "Delta", "Synapse X", "Krnl", "Codex", "Arceus X" },
    UnsupportedExecutors = { "Roblox Studio" },
    Segments = {
        Details = { Text = "Details", Icon = "lucide:grid-2x2" },
        Script = { Text = "Script Logs", Icon = "lucide:code" },
        UI = { Text = "UI Logs", Icon = "lucide:file-text", Show = true },
    },
    Changelog = {
        {
            Title = "Solana Hub Update",
            Date = "v1.2",
            Description = "Centered Tabbox Layout & Mobile Input Fixes",
        },
        {
            Title = "Solana Hub Update",
            Date = "v1.1",
            Description = "Initial ModernV2 Release",
        },
    },
    UIChangelog = {
        {
            Title = "Dashboard Style",
            Description = "Home tab with profile card and details",
        },
    },
})

local Tabs = {
    Main = Window:AddTab({ Name = "Combat", Icon = "lucide:sword", Type = "Single" }),
    Movement = Window:AddTab({ Name = "Movement", Icon = "lucide:move", Type = "Single" }),
    Visuals = Window:AddTab({ Name = "Visuals", Icon = "lucide:eye", Type = "Single" }),
    Misc = Window:AddTab({ Name = "Misc", Icon = "lucide:package", Type = "Single" })
}

-- Adapter untuk layout Centered Tabbox (seperti Solhub_vd_1.4.4.lua)
local function makeModernAdapter(section)
    local adapter = {}
    setmetatable(adapter, {
        __index = function(t, k)
            if k == "AddSection" then
                return function(self, cfg)
                    if cfg and cfg.Name then
                        pcall(function() section:AddDivider({ Text = cfg.Name }) end)
                    end
                    return adapter
                end
            end
            return section[k]
        end
    })
    return adapter
end

local function addCenterFeatureTabbox(tab, name, entries)
    local tabbox = tab:AddCenterTabbox(name)
    local created = {}
    for _, entry in ipairs(entries) do
        created[entry.Key] = makeModernAdapter(tabbox:AddTab({
            Name = entry.Name,
            Icon = entry.Icon,
        }))
    end
    return created
end

-- CONFIG
local config = {
    AutoLightAttack = false,
    AutoHeavyAttack = false,
    AutoBlock = false,
    SmartParry = false,
    AutoDodge = false,
    AutoUltimate = false,
    AutoClaimRewards = false,
    AutoAttackRange = 15,
    ShowAttackRange = true,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPMaxDistance = 5000,
    ScriptRunning = true,
    -- Premium Features v1.2
    HitboxExpander = false,
    HitboxSize = 10,
    AntiStagger = false,
    InfiniteStamina = false,
    SpeedHack = false,
    SpeedValue = 30,
    JumpHack = false,
    JumpValue = 100
}

-- STATE VARIABLES
local lightIdx = 1
local heavyIdx = 1
local lastActionId = 1
local lastDodgeId = 1
local lastAttackTime = 0
local currentWeaponName = "Katana"
local impactDataCache = {}

local function getLocalCharacter()
    local clientChar = workspace:FindFirstChild("Player_Client")
    if clientChar and clientChar:FindFirstChild("HumanoidRootPart") then
        return clientChar
    end
    return LocalPlayer.Character
end

-- Simulasi klik tombol pada layar HP (Menggunakan simulasi input keyboard/mouse tingkat rendah agar bebas dari bug koordinat/scaling DPI)
local function clickMobileButton(actionName)
    local vim = game:GetService("VirtualInputManager")
    
    if actionName:lower() == "light" then
        task.spawn(function()
            pcall(function()
                -- Simulasikan klik M1 (Mouse Button 1) di tengah layar
                vim:SendMouseButtonEvent(100, 100, 0, true, game, 1)
                task.wait(0.02)
                vim:SendMouseButtonEvent(100, 100, 0, false, game, 1)
            end)
        end)
        return true
        
    elseif actionName:lower() == "heavy" then
        task.spawn(function()
            pcall(function()
                -- Simulasikan klik M2 (Mouse Button 2) di tengah layar
                vim:SendMouseButtonEvent(100, 100, 1, true, game, 1)
                task.wait(0.02)
                vim:SendMouseButtonEvent(100, 100, 1, false, game, 1)
            end)
        end)
        return true
        
    elseif actionName:lower() == "dodge" then
        task.spawn(function()
            pcall(function()
                -- Simulasikan menekan tombol keyboard 'Q' (Dodge keybind default game)
                vim:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.02)
                vim:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end)
        end)
        return true
        
    elseif actionName:lower() == "ultimate" then
        task.spawn(function()
            pcall(function()
                -- Simulasikan menekan tombol keyboard 'R' (Ultimate keybind default game)
                vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.02)
                vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end)
        end)
        return true
    end
    
    return false
end

-- REMOTES
local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local playerCharacterRemotes = remotes and remotes:WaitForChild("PlayerCharacter", 5)
local requestRemotes = playerCharacterRemotes and playerCharacterRemotes:WaitForChild("Request", 5)
local updateRemotes = playerCharacterRemotes and playerCharacterRemotes:WaitForChild("Update", 5)
local playerRemotes = remotes and remotes:WaitForChild("Player", 5)

-- IMPACT CACHING (INCOMING LISTENER)
local RegisterImpactRemote = updateRemotes and updateRemotes:WaitForChild("RegisterImpact", 5)
if RegisterImpactRemote then
    RegisterImpactRemote.OnClientEvent:Connect(function(swingId, impactData)
        if type(swingId) == "string" and type(impactData) == "table" and impactData.impactResults then
            impactDataCache[swingId] = impactData.impactResults
            task.delay(5, function()
                impactDataCache[swingId] = nil
            end)
        end
    end)
end

-- METAMETHOD HOOKING (ULTIMATE GODMODE & ACTION HIJACKER)
local QueueBasicAttackRemote = requestRemotes and requestRemotes:WaitForChild("QueueBasicAttack", 5)
local StartDodgeRemote = requestRemotes and requestRemotes:WaitForChild("StartDodge", 5)
local QueueJumpRemote = requestRemotes and requestRemotes:WaitForChild("QueueJump", 5)
local ResolveImpactRemote = requestRemotes and requestRemotes:WaitForChild("ResolveImpact", 5)
local StartStaggerRemote = requestRemotes and requestRemotes:WaitForChild("StartStagger", 5)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() and method == "FireServer" then
        -- HACK 1: Curi Weapon Name & Action ID dari Pukulan
        if rawequal(self, QueueBasicAttackRemote) then
            local args = {...}
            if type(args[1]) == "string" and tonumber(args[1]) then
                lastActionId = tonumber(args[1])
                lastAttackTime = os.clock()
                if type(args[2]) == "string" then
                    currentWeaponName = args[2]
                end
            end
            
        -- HACK 2: Curi Action ID khusus Dodge / Modifikasi Stamina Dodge
        elseif rawequal(self, StartDodgeRemote) then
            local args = {...}
            if type(args[1]) == "table" then
                if args[1].actionId and tonumber(args[1].actionId) then
                    lastDodgeId = tonumber(args[1].actionId)
                end
                if config.InfiniteStamina then
                    args[1].dodgeStamina = 0
                    return oldNamecall(self, unpack(args))
                end
            end

        -- HACK 2.5: Modifikasi Stamina Lompat
        elseif rawequal(self, QueueJumpRemote) then
            local args = {...}
            if config.InfiniteStamina then
                args[3] = 0 -- jumpStamina set to 0
                return oldNamecall(self, unpack(args))
            end

        -- HACK 3: Modifikasi Laporan Damage (Godmode Parry/Block)
        elseif rawequal(self, ResolveImpactRemote) then
            local args = {...}
            local swingId = args[1]
            if (config.AutoBlock or config.SmartParry) and type(swingId) == "string" and impactDataCache[swingId] then
                local desiredResult = config.SmartParry and "Parry" or "Block"
                local overrideData = impactDataCache[swingId][desiredResult]
                if overrideData then
                    args[2] = desiredResult
                    args[3] = overrideData
                    return oldNamecall(self, unpack(args))
                end
            end
            
        -- HACK 4: Manipulasi Animasi Pusing Lokal / Anti-Stagger
        elseif rawequal(self, StartStaggerRemote) then
            if config.AntiStagger then
                return -- Blokir stun/stagger sepenuhnya!
            end
            local args = {...}
            if (config.AutoBlock or config.SmartParry) and type(args[1]) == "table" then
                local desiredResult = config.SmartParry and "Parry" or "Block"
                if args[1].staggerType == "GetHit" then
                    args[1].staggerType = desiredResult
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- HELPER FUNCTIONS
local function isUltimateReady()
    local isReady = false
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local combatHud = playerGui:FindFirstChild("CombatHUD")
            if combatHud then
                local topbar = combatHud:FindFirstChild("Topbar")
                if topbar then
                    local charFrameLeft1 = topbar:FindFirstChild("CharacterFrameLeft")
                    if charFrameLeft1 then
                        local charFrameLeft2 = charFrameLeft1:FindFirstChild("CharacterFrameLeft")
                        if charFrameLeft2 then
                            local ultFrame = charFrameLeft2:FindFirstChild("UltimateFrame")
                            if ultFrame then
                                local ultBar = ultFrame:FindFirstChild("UltimateBar")
                                if ultBar and ultBar:IsA("GuiObject") then
                                    if ultBar.Size.X.Scale >= 0.99 then
                                        isReady = true
                                    end
                                end
                                
                                local glowBar = ultFrame:FindFirstChild("GlowBar")
                                if glowBar and glowBar:IsA("GuiObject") then
                                    if glowBar.Visible and (glowBar.BackgroundTransparency < 1 or (glowBar:IsA("ImageLabel") and glowBar.ImageTransparency < 1)) then
                                        isReady = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return isReady
end

-- COMBAT TAB
local CombatTabs = addCenterFeatureTabbox(Tabs.Main, "Combat Features", {
    { Key = "Attack", Name = "Attack", Icon = "lucide:sword" },
    { Key = "Defense", Name = "Defense", Icon = "lucide:shield" }
})
local combatLeft = CombatTabs.Attack
local combatRight = CombatTabs.Defense

combatLeft:AddParagraph({
    Name = "Status",
    Content = "Undetected. Safe for public servers."
})

combatLeft:AddToggle({
    Name = "Auto Light Attack",
    Icon = "lucide:sword",
    Default = false,
    Flag = "AutoLightAttack",
    Callback = function(v) config.AutoLightAttack = v end
})

combatLeft:AddToggle({
    Name = "Auto Heavy Attack",
    Icon = "lucide:swords",
    Default = false,
    Flag = "AutoHeavyAttack",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(v) 
        if false and v and getgenv().SolHubTier ~= "Premium" then
            Window:Notify({ Title = "Premium Required", Content = "Fitur ini hanya untuk pengguna Key Premium!", Icon = "lucide:shield-alert" })
            return
        end
        config.AutoHeavyAttack = v 
    end
})

combatLeft:AddSlider({
    Name = "Attack Range (Studs)",
    Default = 15,
    Min = 1,
    Max = 50,
    Flag = "AutoAttackRange",
    Callback = function(Value)
        config.AutoAttackRange = Value
    end,
})

combatLeft:AddToggle({
    Name = "Show Attack Range Circle",
    Icon = "lucide:eye",
    Default = true,
    Flag = "ShowAttackRange",
    Callback = function(v) config.ShowAttackRange = v end
})

combatLeft:AddToggle({
    Name = "Auto Ultimate",
    Icon = "lucide:zap",
    Default = false,
    Flag = "AutoUltimate",
    Callback = function(v) 
        config.AutoUltimate = v 
        if v then Window:Notify({ Title = "Ultimate", Content = "Auto Ultimate Enabled", Icon = "lucide:zap" }) end
    end
})

combatLeft:AddToggle({
    Name = "Hitbox Expander",
    Icon = "lucide:scan",
    Default = false,
    Flag = "HitboxExpander",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(v) 
        if false and v and getgenv().SolHubTier ~= "Premium" then
            Window:Notify({ Title = "Premium Required", Content = "Fitur ini hanya untuk pengguna Key Premium!", Icon = "lucide:shield-alert" })
            return
        end
        config.HitboxExpander = v 
        if typeof(updateHitboxes) == "function" then
            updateHitboxes()
        end
    end
})

combatLeft:AddSlider({
    Name = "Hitbox Size",
    Default = 10,
    Min = 2,
    Max = 50,
    Flag = "HitboxSize",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(Value)
        if false and getgenv().SolHubTier ~= "Premium" then return end
        config.HitboxSize = Value
        if config.HitboxExpander and typeof(updateHitboxes) == "function" then
            updateHitboxes()
        end
    end,
})

combatRight:AddParagraph({
    Name = "Warning",
    Content = "Absolute Defense is highly noticeable. Use at your own risk."
})

combatRight:AddToggle({
    Name = "Absolute Defense",
    Icon = "lucide:shield",
    Default = false,
    Flag = "AbsoluteDefense",
    Callback = function(v) 
        config.AutoBlock = v 
        if v then Window:Notify({ Title = "Defense", Content = "Absolute Defense Enabled", Icon = "lucide:shield" }) end
        if requestRemotes then
            if v then
                pcall(function() requestRemotes.StartBlock:FireServer({ blockStrength = 1, startTime = os.clock() }) end)
            else
                pcall(function() requestRemotes.ReleaseBlock:FireServer() end)
                local myChar = getLocalCharacter()
                if myChar then
                    pcall(function() myChar:SetAttribute("Blocking", false) end)
                    pcall(function() myChar:SetAttribute("IsBlocking", false) end)
                end
            end
        end
    end
})

combatRight:AddKeybind({
    Name = "Toggle Defense Key",
    Default = "F",
    Flag = "AutoBlockKeybind",
    Callback = function()
        Window:Notify({ Title = "Keybind", Content = "Defense key pressed!", Icon = "lucide:shield" })
    end
})

combatRight:AddToggle({
    Name = "Smart Parry (100% Counter)",
    Icon = "lucide:crosshair",
    Default = false,
    Flag = "SmartParry",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(v) 
        if false and v and getgenv().SolHubTier ~= "Premium" then
            Window:Notify({ Title = "Premium Required", Content = "Fitur ini hanya untuk pengguna Key Premium!", Icon = "lucide:shield-alert" })
            return
        end
        config.SmartParry = v 
    end
})

combatRight:AddToggle({
    Name = "Anti-Stagger (No Stun)",
    Icon = "lucide:shield-alert",
    Default = false,
    Flag = "AntiStagger",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(v) 
        if false and v and getgenv().SolHubTier ~= "Premium" then
            Window:Notify({ Title = "Premium Required", Content = "Fitur ini hanya untuk pengguna Key Premium!", Icon = "lucide:shield-alert" })
            return
        end
        config.AntiStagger = v 
    end
})


-- MOVEMENT TAB
local MovementTabs = addCenterFeatureTabbox(Tabs.Movement, "Movement Features", {
    { Key = "Agility", Name = "Agility", Icon = "lucide:move" }
})
local moveSec = MovementTabs.Agility

moveSec:AddToggle({
    Name = "Auto Dodge",
    Icon = "lucide:person-standing",
    Default = false,
    Flag = "AutoDodge",
    Callback = function(v) config.AutoDodge = v end
})

moveSec:AddToggle({
    Name = "Infinite Stamina",
    Icon = "lucide:battery-charging",
    Default = false,
    Flag = "InfiniteStamina",
    Callback = function(v) config.InfiniteStamina = v end
})

moveSec:AddToggle({
    Name = "Speed Hack",
    Icon = "lucide:zap",
    Default = false,
    Flag = "SpeedHack",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(v) 
        if false and v and getgenv().SolHubTier ~= "Premium" then
            Window:Notify({ Title = "Premium Required", Content = "Fitur ini hanya untuk pengguna Key Premium!", Icon = "lucide:shield-alert" })
            return
        end
        config.SpeedHack = v 
    end
})

moveSec:AddSlider({
    Name = "WalkSpeed Value",
    Default = 30,
    Min = 16,
    Max = 100,
    Flag = "SpeedValue",
    Locked = false,
    TextLocked = "Premium Required",
    Callback = function(Value)
        if false and getgenv().SolHubTier ~= "Premium" then return end
        config.SpeedValue = Value 
    end
})

moveSec:AddToggle({
    Name = "Jump Hack",
    Icon = "lucide:arrow-up",
    Default = false,
    Flag = "JumpHack",
    Callback = function(v) config.JumpHack = v end
})

moveSec:AddSlider({
    Name = "Jump Value",
    Default = 100,
    Min = 50,
    Max = 250,
    Flag = "JumpValue",
    Callback = function(Value) config.JumpValue = Value end
})

-- MISC TAB
local MiscTabs = addCenterFeatureTabbox(Tabs.Misc, "Misc Features", {
    { Key = "Rewards", Name = "Rewards", Icon = "lucide:gift" },
    { Key = "System", Name = "System", Icon = "lucide:settings" }
})
local miscSec = MiscTabs.Rewards

miscSec:AddToggle({
    Name = "Auto Claim Rewards",
    Icon = "lucide:gift",
    Default = false,
    Flag = "AutoClaimRewards",
    Callback = function(v) config.AutoClaimRewards = v end
})

miscSec:AddButton({
    Name = "Redeem All Codes",
    Icon = "lucide:gift",
    Callback = function()
        task.spawn(function()
            local codes = {
                -- Masukkan list kode-kode rahasia / redeem code gamenya di sini
                "MidSeasonUpdate",
                "PeakGrounds",
                "SeasonOneBegins",
                "FlamingKatana",
                "HappyNewYear"
            }
            for _, code in ipairs(codes) do
                if playerRemotes then
                    pcall(function() 
                        playerRemotes.RequestRedeemSpecialCode:FireServer(code) 
                    end)
                    task.wait(1) -- Jeda 1 detik agar tidak dicurigai server (Rate Limit)
                end
            end
        end)
    end
})

local unloadSec = MiscTabs.System
unloadSec:AddButton({
    Name = "Unload Script",
    Icon = "lucide:power",
    Callback = function()
        config.ScriptRunning = false
        config.ESP = false
        -- Remove ESP Folder
        local f = game.CoreGui:FindFirstChild("SolanaHub_ESP_Folder")
        if f then f:Destroy() end
        -- Destroy Window
        if Window.Destroy then Window:Destroy() end
    end
})

-- VISUALS TAB (ESP)
local VisualsTabs = addCenterFeatureTabbox(Tabs.Visuals, "Visual Features", {
    { Key = "ESP", Name = "Player ESP", Icon = "lucide:eye" }
})
local espSec = VisualsTabs.ESP

local espToggle = espSec:AddToggle({
    Name = "Enable Player ESP",
    Icon = "lucide:eye",
    Default = false,
    Flag = "EnableESP",
    Callback = function(v) 
        config.ESP = v 
    end
})

local espDependency = espSec:AddDependencyBox({
    Name = "ESP Settings",
    Dependencies = { { espToggle, true } },
    Mode = "Visible",
})

espDependency:AddSlider({
    Name = "Max Distance",
    Default = 5000,
    Min = 50,
    Max = 10000,
    Flag = "ESPMaxDistance",
    Callback = function(Value)
        config.ESPMaxDistance = Value
    end,
})

espDependency:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Color)
        config.ESPColor = Color
    end
})


-- LOOPS AND LOGIC
task.spawn(function()
    while task.wait(0.2) do
        if not config.ScriptRunning then break end
        if not requestRemotes then continue end

        local success, err = pcall(function()
            -- Cari Musuh Terdekat untuk Attack Range
            local isEnemyInRange = false
            local nearestDist = math.huge
            local nearestName = "none"
            local attackRange = tonumber(config.AutoAttackRange) or 15
            
            local myChar = getLocalCharacter()
            if (config.AutoLightAttack or config.AutoHeavyAttack) and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myPos = myChar.HumanoidRootPart.Position
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                        -- Hanya target musuh (bukan teman satu tim)
                        local isEnemy = true
                        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                            isEnemy = false
                        end
                        
                        if isEnemy and player.Character.Humanoid.Health > 0 then
                            local enemyPos = player.Character.HumanoidRootPart.Position
                            -- Gunakan Magnitude (sama seperti ESP yang sudah terbukti benar)
                            local dist = (myPos - enemyPos).Magnitude
                            
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestName = player.Name
                            end
                            
                            if dist <= attackRange then
                                isEnemyInRange = true
                            end
                        end
                    end
                end
            end

            -- Reset Combo Index jika tidak menyerang selama lebih dari 1 detik (Server Combo Timeout)
            if os.clock() - lastAttackTime > 1.0 then
                lightIdx = 1
                heavyIdx = 1
            end

            -- Attack Logic (Auto Light)
            if config.AutoLightAttack and isEnemyInRange then
                local clicked = clickMobileButton("light")
                if not clicked then
                    lastActionId = (lastActionId + 1) % 100
                    local attackName = "Light0" .. tostring(lightIdx)
                    requestRemotes.QueueBasicAttack:FireServer(tostring(lastActionId), currentWeaponName, attackName)
                    lightIdx = lightIdx >= 3 and 1 or lightIdx + 1
                    lastAttackTime = os.clock()
                else
                    lastAttackTime = os.clock()
                end
            end

            -- Attack Logic (Auto Heavy)
            if config.AutoHeavyAttack and isEnemyInRange then
                local clicked = clickMobileButton("heavy")
                if not clicked then
                    lastActionId = (lastActionId + 1) % 100
                    local attackName = "Heavy0" .. tostring(heavyIdx)
                    requestRemotes.QueueBasicAttack:FireServer(tostring(lastActionId), currentWeaponName, attackName)
                    heavyIdx = heavyIdx >= 3 and 1 or heavyIdx + 1
                    lastAttackTime = os.clock()
                else
                    lastAttackTime = os.clock()
                end
            end
        end)
        

        -- Block Protection Visual Loop
        local myChar = getLocalCharacter()
        if config.AutoBlock and myChar then
            pcall(function() myChar:SetAttribute("Blocking", true) end)
            pcall(function() myChar:SetAttribute("IsBlocking", true) end)
        end
        
        -- Dodge Logic (Smart Dodge & Dash Physics)
        if config.AutoDodge then
            pcall(function()
                local clicked = clickMobileButton("dodge")
                if not clicked then
                    local myChar = getLocalCharacter()
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        local root = myChar.HumanoidRootPart
                        local direction = -root.CFrame.lookVector -- fallback default (backward)
                        
                        -- Cari musuh terdekat untuk kabur
                        local nearestEnemy = nil
                        local nearestDist = math.huge
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local enemyPos = player.Character.HumanoidRootPart.Position
                                local dist = (root.Position - enemyPos).Magnitude
                                if dist < nearestDist then
                                    nearestDist = dist
                                    nearestEnemy = player.Character
                                end
                            end
                        end
                        
                        if nearestEnemy then
                            local diff = root.Position - nearestEnemy.HumanoidRootPart.Position
                            direction = Vector3.new(diff.X, 0, diff.Z)
                            if direction.Magnitude > 0 then
                                direction = direction.Unit
                            else
                                direction = -root.CFrame.lookVector
                            end
                        end
                        
                        lastDodgeId = (lastDodgeId + 1) % 100
                        requestRemotes.StartDodge:FireServer({
                            dodgeStamina = 1, 
                            direction = direction, 
                            isReverse = false,
                            startTime = os.clock(), 
                            actionId = tostring(lastDodgeId)
                        })
                        
                        task.spawn(function()
                            local vel = Instance.new("BodyVelocity")
                            vel.MaxForce = Vector3.new(200000, 0, 200000)
                            vel.Velocity = direction * 55
                            vel.Parent = root
                            task.wait(0.35)
                            vel:Destroy()
                        end)
                    end
                end
            end)
            task.wait(0.5)
        end
    end
end)

-- Separate loop for Ultimate and Rewards to avoid yielding main loop
task.spawn(function()
    while task.wait(1) do
        if not config.ScriptRunning then break end
        if config.AutoUltimate and requestRemotes then
            if isUltimateReady() then
                local clicked = clickMobileButton("ultimate")
                if not clicked then
                    pcall(function() 
                        lastActionId = (lastActionId + 1) % 100
                        requestRemotes.QueueBasicAttack:FireServer(tostring(lastActionId), currentWeaponName, "Ultimate")
                    end)
                end
            end
        end

        if config.AutoClaimRewards and playerRemotes then
            pcall(function() 
                playerRemotes.RequestLikesReward:FireServer()
                playerRemotes.RequestFavoriteReward:FireServer()
            end)
        end
    end
end)

-- Attack Range Circle Visualizer (task.spawn loop - terbukti kompatibel di mobile)
local rangeCircle = Instance.new("Part")
rangeCircle.Name = "SolanaHub_AttackRangeCircle"
rangeCircle.Shape = Enum.PartType.Cylinder
rangeCircle.Anchored = true
rangeCircle.CanCollide = false
rangeCircle.CastShadow = false
rangeCircle.Transparency = 0.4
rangeCircle.Color = Color3.fromRGB(255, 50, 50)
rangeCircle.Material = Enum.Material.Neon
rangeCircle.TopSurface = Enum.SurfaceType.Smooth
rangeCircle.BottomSurface = Enum.SurfaceType.Smooth

task.spawn(function()
    while task.wait(0.03) do
        if not config.ScriptRunning then
            pcall(function() rangeCircle:Destroy() end)
            break
        end
        
        local success, err = pcall(function()
            local char = getLocalCharacter()
            if config.ShowAttackRange and char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local diameter = (tonumber(config.AutoAttackRange) or 15) * 2
                
                rangeCircle.Size = Vector3.new(0.15, diameter, diameter)
                
                -- Gunakan Blacklist agar kompatibel penuh di executor mobile lama
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = {char, rangeCircle}
                
                local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), rayParams)
                local groundY = root.Position.Y - 3
                if rayResult then
                    groundY = rayResult.Position.Y
                end
                
                rangeCircle.CFrame = CFrame.new(root.Position.X, groundY + 0.2, root.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
                rangeCircle.Parent = workspace
            else
                rangeCircle.Parent = nil
            end
        end)
    end
end)

-- ESP Rendering
local function CreateESP(player)
    local espFolder = game.CoreGui:FindFirstChild("SolanaHub_ESP_Folder")
    if not espFolder then
        espFolder = Instance.new("Folder", game.CoreGui)
        espFolder.Name = "SolanaHub_ESP_Folder"
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = espFolder

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 0, 0)
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.SourceSansBold
    text.TextScaled = true
    text.Parent = billboard

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not config.ScriptRunning or not player or not player.Parent then
            if highlight then highlight:Destroy() end
            if billboard then billboard:Destroy() end
            if conn then conn:Disconnect() end
            return
        end

        if not config.ESP then
            highlight.Enabled = false
            billboard.Enabled = false
            return
        else
            highlight.Enabled = true
            billboard.Enabled = true
        end

        highlight.FillColor = config.ESPColor
        text.TextColor3 = config.ESPColor

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local pchar = player.Character
            local myChar = getLocalCharacter()
            local currentHP = pchar:GetAttribute("Health") or pchar.Humanoid.Health or 100
            
            if currentHP > 0 then
                local dist = 0
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    dist = math.floor((myChar.HumanoidRootPart.Position - pchar.HumanoidRootPart.Position).Magnitude)
                end
                
                if dist <= config.ESPMaxDistance then
                    highlight.Adornee = pchar
                    billboard.Adornee = pchar.HumanoidRootPart
                    
                    local hp = math.floor(currentHP)
                    text.Text = player.Name .. "\n[HP: " .. hp .. " | Dist: " .. dist .. "]"
                else
                    highlight.Enabled = false
                    billboard.Enabled = false
                end
            else
                highlight.Enabled = false
                billboard.Enabled = false
            end
        else
            highlight.Enabled = false
            billboard.Enabled = false
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    local espFolder = game.CoreGui:FindFirstChild("SolanaHub_ESP_Folder")
    if espFolder then
        local hl = espFolder:FindFirstChild(p.Name)
        if hl then hl:Destroy() end
        local bb = espFolder:FindFirstChild(p.Name .. "_Billboard")
        if bb then bb:Destroy() end
    end
end)

-- ==========================================
-- PREMIUM FEATURES SYSTEM (v1.2)
-- ==========================================

-- Hook workspace.Raycast untuk membypass "RespectCanCollide = true" saat Hitbox Expander aktif
local oldRaycast
oldRaycast = hookfunction(workspace.Raycast, function(self, origin, direction, params)
    if not checkcaller() and params and params.RespectCanCollide then
        local filter = params.FilterDescendantsInstances
        if filter then
            local isMyChar = false
            for _, item in ipairs(filter) do
                if item == LocalPlayer.Character or item.Name == "Player_Client" then
                    isMyChar = true
                    break
                end
            end
            if isMyChar then
                params.RespectCanCollide = false
            end
        end
    end
    return oldRaycast(self, origin, direction, params)
end)

-- 1. Hitbox Expander Function
local function updateHitboxes()
    pcall(function()
        -- Handle players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    local char = player.Character or workspace:FindFirstChild(player.Name)
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        if config.HitboxExpander then
                            hrp.Size = Vector3.new(config.HitboxSize, config.HitboxSize, config.HitboxSize)
                            hrp.CanCollide = false -- Tetap false agar tidak merusak fisika jalan/dorong-dorongan
                            hrp.Transparency = 0.6
                            hrp.Color = Color3.fromRGB(220, 35, 55)
                            hrp.Material = Enum.Material.ForceField
                        else
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.CanCollide = true
                            hrp.Transparency = 1
                        end
                    end
                end)
            end
        end
        
        -- Handle other client characters (Player_Client / Enemy predicted)
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and child.Name:find("_Client") and child.Name ~= "Player_Client" then
                pcall(function()
                    if child:FindFirstChild("HumanoidRootPart") then
                        local hrp = child.HumanoidRootPart
                        if config.HitboxExpander then
                            hrp.Size = Vector3.new(config.HitboxSize, config.HitboxSize, config.HitboxSize)
                            hrp.CanCollide = false
                            hrp.Transparency = 0.6
                            hrp.Color = Color3.fromRGB(220, 35, 55)
                            hrp.Material = Enum.Material.ForceField
                        else
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.CanCollide = true
                            hrp.Transparency = 1
                        end
                    end
                end)
            end
        end
    end)
end

-- Periodically refresh hitboxes (agar target baru ikut membesar)
task.spawn(function()
    while task.wait(1) do
        if config.ScriptRunning and config.HitboxExpander then
            pcall(updateHitboxes)
        end
    end
end)

-- 2. WalkSpeed & JumpPower hacks (Bypass custom movement step)
local cachedMovementComponent = nil
local function getMovementComponent()
    if cachedMovementComponent then return cachedMovementComponent end
    if not getgc then return nil end
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "_stepMovementLinear") ~= nil then
            cachedMovementComponent = v
            return v
        end
    end
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            local mt = getmetatable(v)
            if mt and rawget(mt, "_getDefaultWalkSpeed") ~= nil then
                cachedMovementComponent = mt
                return mt
            end
        end
    end
    return nil
end

local oldGetSpeed = nil
-- Loop pencari dan pemodifikasi getgc walkspeed (Metode Native/Paling Halus)
task.spawn(function()
    while task.wait(1) do
        if config.ScriptRunning then
            pcall(function()
                local mc = getMovementComponent()
                if mc and mc._getDefaultWalkSpeed and oldGetSpeed == nil then
                    oldGetSpeed = mc._getDefaultWalkSpeed
                    mc._getDefaultWalkSpeed = function(self, ...)
                        if config.SpeedHack then
                            return config.SpeedValue
                        end
                        return oldGetSpeed(self, ...)
                    end
                end
            end)
        end
    end
end)

-- Loop CFrame Speed Hack (Metode Fallback jika executor tidak mendukung getgc penuh)
local speedToggledOff = false
task.spawn(function()
    while task.wait(0.01) do
        pcall(function()
            if config.ScriptRunning then
                if config.SpeedHack and oldGetSpeed == nil then
                    local myChar = getLocalCharacter()
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") then
                        local hrp = myChar.HumanoidRootPart
                        local hum = myChar.Humanoid
                        local moveDir = hum.MoveDirection
                        if moveDir.Magnitude > 0 then
                            local speedDiff = math.max(0, config.SpeedValue - 16)
                            hrp.CFrame = hrp.CFrame + (moveDir * speedDiff * 0.016)
                        end
                    end
                    speedToggledOff = true
                elseif speedToggledOff then
                    speedToggledOff = false
                end
            end
        end)
    end
end)

-- Jump Hack (Bypass custom impulse jump)
local UserInputService = game:GetService("UserInputService")
local jumpConnection
jumpConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if not config.ScriptRunning then
        if jumpConnection then jumpConnection:Disconnect() end
        return
    end
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space and config.JumpHack then
        task.spawn(function()
            task.wait(0.05) -- Tunggu impuls lompatan bawaan selesai
            local myChar = getLocalCharacter()
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local hrp = myChar.HumanoidRootPart
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, config.JumpValue, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

-- 3. Client Stamina Auto-Refill (getgc memory scanner)
local cachedActionManager = nil
local function getActionManager()
    if cachedActionManager then return cachedActionManager end
    if not getgc then return nil end
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "_dodgeStamina") ~= nil then
            cachedActionManager = v
            return v
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if config.ScriptRunning and config.InfiniteStamina then
                local am = getActionManager()
                if am then
                    am._dodgeStamina = 1
                    am._jumpStamina = 1
                end
            end
        end)
    end
end)
