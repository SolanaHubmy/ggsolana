pcall(function() if typeof(getgenv)=="function" then getgenv().SolanaHubTier="Premium" end end)
-- ============================================================
--  SolanaHub Community — Survive Zombie Arena
-- ============================================================

local workspace     = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")

local player        = Players.LocalPlayer
local character     = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local backup_cframe = humanoidRootPart.CFrame

-- ── Config vars ───────────────────────────────────────────────
local distance_zom        = 50
local count_zom           = 1
local remove_reward_crytal = false

_G.AUTO_COLLECT_SHARDS    = false
_G.AUTO_COLLECT_RAIN      = false

-- WalkSpeed & JumpPower control
_G.ENABLE_SPEED           = false
_G.SPEED_VALUE            = 16
_G.ENABLE_JUMP            = false
_G.JUMP_VALUE             = 50

-- ── WalkSpeed & JumpPower Active Loop ─────────────────────────
task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if _G.ENABLE_SPEED then
                    hum.WalkSpeed = _G.SPEED_VALUE
                end
                if _G.ENABLE_JUMP then
                    hum.JumpPower = _G.JUMP_VALUE
                    hum.UseJumpPower = true
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ── Instant Event Crystal & Rain Collector ─────────────────────
task.spawn(function()
    local EventRemotes = replicatedStorage:WaitForChild("EventRemotes", 10)
    if EventRemotes then
        local GalacticShardDrop = EventRemotes:WaitForChild("GalacticShardDrop", 5)
        local GalacticShardCollect = EventRemotes:WaitForChild("GalacticShardCollect", 5)
        if GalacticShardDrop and GalacticShardCollect then
            GalacticShardDrop.OnClientEvent:Connect(function(zombieId, amount, position)
                if _G.AUTO_COLLECT_SHARDS then
                    pcall(function() GalacticShardCollect:FireServer(zombieId) end)
                end
            end)
        end
    end
    
    local RainRemotes = replicatedStorage:WaitForChild("RainRemotes", 10)
    if RainRemotes then
        local RainDrop = RainRemotes:WaitForChild("RainDrop", 5)
        local RainCollect = RainRemotes:WaitForChild("RainCollect", 5)
        if RainDrop and RainCollect then
            RainDrop.OnClientEvent:Connect(function(rainId, rainType, _, amount, position)
                if _G.AUTO_COLLECT_RAIN then
                    pcall(function() RainCollect:FireServer(rainId) end)
                end
            end)
        end
    end
end)

-- ── Anti AFK ──────────────────────────────────────────────────
task.spawn(function()
    player.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- ── Helper: Performance Mode ──────────────────────────────────
local function set_Performance()
    task.spawn(function()
        pcall(function()
            replicatedStorage.DataRemotes.SetSetting:FireServer("PerformanceMode", true)
        end)
    end)
end

-- ── Helper: Remove Reward Crystal ────────────────────────────
local function remove_reward()
    task.spawn(function()
        if not remove_reward_crytal then return end
        local Terrain = workspace:WaitForChild("Terrain")
        for _, v in ipairs(Terrain:GetChildren()) do
            if v.Name == "Attachment" or v.Name == "CashRewardAttachment" then
                v:Destroy()
            end
        end
    end)
end

-- ── Helper: Get Zombie Data ───────────────────────────────────
local function getZombieData()
    local data = {}
    local zombiesLocal = workspace:FindFirstChild("Zombies_Local")
    if not zombiesLocal then return data end
    for _, zombie in ipairs(zombiesLocal:GetChildren()) do
        local id = tonumber(zombie.Name:match("%d+"))
        local rootPart = zombie:FindFirstChild("HumanoidRootPart")
        if id and rootPart then
            table.insert(data, { id = id, pos = rootPart.Position })
        end
    end
    return data
end

-- ── Kill Methods ──────────────────────────────────────────────
local function kill_nogun()
    local zombie_index = {}
    local zombiesLocal = workspace:FindFirstChild("Zombies_Local")
    local Event_kill = replicatedStorage:WaitForChild("ZombieRemotes"):WaitForChild("ZombieDamage")
    if not zombiesLocal then return end
    for _, v in ipairs(zombiesLocal:GetDescendants()) do
        if v.Name == "HumanoidRootPart" then
            local id = tonumber(v.Parent.Name:match("%d+"))
            local distance = (v.Position - humanoidRootPart.Position).Magnitude
            if id and distance <= distance_zom then
                table.insert(zombie_index, { id = id, root = v, pos = v.Position, distance = distance })
            end
        end
    end
    table.sort(zombie_index, function(a, b) return a.distance < b.distance end)
    if zombie_index[1] then
        pcall(function()
            for i, v in ipairs(zombie_index) do
                if i <= count_zom then
                    Event_kill:FireServer(zombie_index[i].id, math.huge)
                    if not v.root.Parent then zombie_index = {} end
                end
            end
        end)
    end
end

local function kill_gun()
    local zombie_index = {}
    local zombiesLocal = workspace:FindFirstChild("Zombies_Local")
    local gunHit  = replicatedStorage:WaitForChild("GunRemotes"):WaitForChild("GunHit")
    local gunFire = replicatedStorage:WaitForChild("NetRemotes"):WaitForChild("GunFire")
    if not zombiesLocal then return end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local weaponName = tool.Name
            for _, v in ipairs(zombiesLocal:GetDescendants()) do
                if v.Name == "HumanoidRootPart" then
                    local id = tonumber(v.Parent.Name:match("%d+"))
                    local distance = (v.Position - humanoidRootPart.Position).Magnitude
                    if id and distance <= distance_zom then
                        table.insert(zombie_index, { id = id, root = v, pos = v.Position, distance = distance, weaponName = weaponName })
                    end
                end
            end
        end
    end
    table.sort(zombie_index, function(a, b) return a.distance < b.distance end)
    if zombie_index[1] then
        pcall(function()
            for i, v in ipairs(zombie_index) do
                if i <= count_zom then
                    local origin = humanoidRootPart.Position
                    local direction = (zombie_index[i].pos - origin).Unit
                    gunFire:FireServer(zombie_index[i].weaponName, origin, direction)
                    gunHit:FireServer(zombie_index[i].weaponName, zombie_index[i].id, zombie_index[i].pos)
                    if not v.root.Parent then zombie_index = {} end
                end
            end
        end)
    end
end

-- ════════════════════════════════════════════════════════════
--  UI — MainV2 (SolanaHub)
-- ════════════════════════════════════════════════════════════

local ModernV2 = nil
local loaderOk, loaderResult = pcall(function()
    local source = game:HttpGet("https://shinzux.vercel.app/files/ambaruto.txt")
    local fn, compileErr = loadstring(source)
    if not fn then error(compileErr) end
    return fn()
end)
if loaderOk then
    ModernV2 = loaderResult
else
    warn("[SolanaHub] Vercel mirror failed, trying GitHub fallback:", loaderResult)
    local fallbackOk, fallbackResult = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/SolanaHubmy/ggsolana/refs/heads/main/SolanaHub-ModernV2.txt")
        local fn, compileErr = loadstring(source)
        if not fn then error(compileErr) end
        return fn()
    end)
    if fallbackOk then
        ModernV2 = fallbackResult
    else
        warn("[SolanaHub] Failed to load ModernV2 from all sources:", fallbackResult)
    end
end

if not ModernV2 then return end
if not game:IsLoaded() then game.Loaded:Wait() end

ModernV2:AddTheme({
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

local MenuIcon = ModernV2:CreateMenuIcon({
    Image       = "rbxassetid://135199868370962",
    Size        = 48,
    IconColor   = Color3.fromRGB(255, 255, 255),
    BGColor     = Color3.fromRGB(20, 22, 27),
    StrokeColor = ModernV2.AccentColor,
    StrokeThick = 1.5,
    Draggable   = true,
})

local Window = ModernV2:Window({
    Title            = "SolanaHub",
    Content          = "Survive Zombie Arena v1.1.2 | Dev: Opixx",
    Image            = "135199868370962",
    Color            = Color3.fromRGB(220, 35, 55),
    Uitransparent    = 0.15,
    ShowUser         = true,
    Search           = true,
    ConfigEnabled    = true,
    NotifyOnCallbackError = false,
    Loadingscreen    = false,
    Enable3DRenderer = false,
    Keybind          = "RightControl",
    Size             = UDim2.fromOffset(500, 320),
    Config = {
        ConfigFolder = "SolanaHubSZA",
        AutoSaveFile = "SOL_SZA",
        AutoSave     = true,
        AutoLoad     = true,
        Overwrite    = true,
        Format       = "JSON",
        ShowAutoSaveToggle = true,
        TextGradient = true,
    },
})

Window:AttachMenuIcon(MenuIcon)

Window:SetAccount({
    Username = player.DisplayName,
    Profile  = ModernV2.UserProfile,
    Expires  = "Never",
})

Window:CreateHomeTab({
    Name    = "Dashboard",
    Icon    = "lucide:layout-dashboard",
    Content = "SolanaHub | Survive Zombie Arena Script | Dev: Opixx",
    DiscordInvite = "https://discord.gg/UgtRrcjxh3",
    SupportedExecutors   = { "Delta", "Arceus X", "Codex" },
    UnsupportedExecutors = { "Roblox Studio" },
    Segments = {
        Details = { Text = "Details", Icon = "lucide:grid-2x2" },
        Script  = { Text = "Script Logs", Icon = "lucide:code" },
        UI      = { Text = "UI Logs", Icon = "lucide:file-text", Show = true },
    },
    Changelog = {
        { Title = "SolanaHub SZA", Date = "v1.1.2", Description = "Cleaned up non-functional remotes & added WalkSpeed/JumpPower sliders" },
    },
})

-- ── FPS & Ping label ─────────────────────────────────────────
local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    if tick() - lastUpdate >= 1 then
        lastUpdate = tick()
        frameCount = 0
    end
end)

-- ════════════════════════════════════════════════════════════
--  TAB 1 — Main
-- ════════════════════════════════════════════════════════════

local TabMain  = Window:AddTab({ Name = "Main",  Icon = "lucide:shield",       Type = "Single" })
local TabShop  = Window:AddTab({ Name = "Shop",  Icon = "lucide:banknote",     Type = "Single" })
local TabGacha = Window:AddTab({ Name = "Gacha", Icon = "lucide:dices",        Type = "Single" })
local TabGear  = Window:AddTab({ Name = "Gear",  Icon = "lucide:package-open", Type = "Single" })

local GrpKill = TabMain:AddSection({ Name = "Auto Kill", Position = "Center" })

-- Toggle 1: Auto Kill (No Gun)
local currentTask_kill = nil
GrpKill:AddToggle({
    Name = "Auto Kill Zombie [No Gun]",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        set_Performance()
        _G.FRAM_KILL = state
        if currentTask_kill then task.cancel(currentTask_kill) currentTask_kill = nil end
        if state then
            local Event_kill = replicatedStorage:WaitForChild("ZombieRemotes"):WaitForChild("ZombieDamage")
            currentTask_kill = task.spawn(function()
                while _G.FRAM_KILL do
                    remove_reward()
                    local zombiesLocal = workspace:FindFirstChild("Zombies_Local")
                    if zombiesLocal then
                        for _, zombie in ipairs(zombiesLocal:GetChildren()) do
                            local id = tonumber(zombie.Name:match("%d+"))
                            if id then pcall(function() Event_kill:FireServer(id, math.huge) end) end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- Toggle 2: Auto Kill (With Gun)
local currentTask_gun = nil
GrpKill:AddToggle({
    Name = "Auto Kill Zombie [With Gun]",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        set_Performance()
        local gunHit  = replicatedStorage:WaitForChild("GunRemotes"):WaitForChild("GunHit")
        local gunFire = replicatedStorage:WaitForChild("NetRemotes"):WaitForChild("GunFire")
        _G.FRAM = state
        if currentTask_gun then task.cancel(currentTask_gun) currentTask_gun = nil end
        if state then
            currentTask_gun = task.spawn(function()
                while _G.FRAM do
                    remove_reward()
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local weaponName = tool.Name
                            for _, target in ipairs(getZombieData()) do
                                task.spawn(function()
                                    pcall(function()
                                        local origin = humanoidRootPart.Position
                                        local direction = (target.pos - origin).Unit
                                        gunFire:FireServer(weaponName, origin, direction)
                                        gunHit:FireServer(weaponName, target.id, target.pos)
                                    end)
                                end)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- Toggle 3: Auto Kill Custom (No Gun)
local currentTask_kill_1 = nil
GrpKill:AddToggle({
    Name = "Auto Kill Zombie [No Gun | Custom Range]",
    Icon = "lucide:toggle-right",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Premium Required ✨",
                    Text = "Fitur Auto Kill No Gun [Custom Range] hanya untuk pengguna Key Premium!",
                    Duration = 5,
                })
            end)
            return
        end
        _G.FRAM_KILL_1 = state
        if currentTask_kill_1 then task.cancel(currentTask_kill_1) currentTask_kill_1 = nil end
        if state then
            currentTask_kill_1 = task.spawn(function()
                while _G.FRAM_KILL_1 do
                    remove_reward()
                    kill_nogun()
                    task.wait()
                end
            end)
        end
    end,
})

-- Toggle 4: Auto Kill Custom (With Gun)
local currentTask_kill_2 = nil
GrpKill:AddToggle({
    Name = "Auto Kill Zombie [With Gun | Custom Range]",
    Icon = "lucide:toggle-right",
    Default = false,
    Locked = false --[[Unlocked]],
    TextLocked = "Premium Required",
    Callback = function(state)
        if state and false --[[Unlocked]] then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Premium Required ✨",
                    Text = "Fitur Auto Kill With Gun [Custom Range] hanya untuk pengguna Key Premium!",
                    Duration = 5,
                })
            end)
            return
        end
        _G.FRAM_KILL_2 = state
        if currentTask_kill_2 then task.cancel(currentTask_kill_2) currentTask_kill_2 = nil end
        if state then
            currentTask_kill_2 = task.spawn(function()
                while _G.FRAM_KILL_2 do
                    remove_reward()
                    kill_gun()
                    task.wait()
                end
            end)
        end
    end,
})

-- Slider: Kill Range
GrpKill:AddSlider({
    Name = "Kill Range",
    Min = 50, Max = 1000, Default = 50, Rounding = 0,
    Suffix = " studs",
    Callback = function(value) distance_zom = value end,
})

-- Slider: Kill Count Per Loop
GrpKill:AddSlider({
    Name = "Kill Count Per Loop",
    Min = 1, Max = 50, Default = 1, Rounding = 0,
    Callback = function(value) count_zom = value end,
})

-- Toggle: Rapid Fire & No Spread
local original_gun_config = {}
local gun_modified = false
GrpKill:AddToggle({
    Name = "Rapid Fire & No Spread",
    Icon = "lucide:zap",
    Default = false,
    Callback = function(state)
        local success, GunConfig = pcall(function()
            return require(replicatedStorage:WaitForChild("Data"):WaitForChild("GunConfig"))
        end)
        if success and GunConfig then
            if state then
                for weapon, data in pairs(GunConfig) do
                    if type(data) == "table" then
                        if not gun_modified then
                            original_gun_config[weapon] = {
                                FireRate = data.FireRate,
                                Spread = data.Spread,
                                SpreadAngle = data.SpreadAngle,
                                Recoil = data.Recoil
                            }
                        end
                        data.FireRate = 0.05
                        if data.Spread then data.Spread = 0 end
                        if data.SpreadAngle then data.SpreadAngle = 0 end
                        if data.Recoil then data.Recoil = 0 end
                    end
                end
                gun_modified = true
            else
                if gun_modified then
                    for weapon, orig in pairs(original_gun_config) do
                        local data = GunConfig[weapon]
                        if data then
                            data.FireRate = orig.FireRate
                            data.Spread = orig.Spread
                            data.SpreadAngle = orig.SpreadAngle
                            data.Recoil = orig.Recoil
                        end
                    end
                end
            end
        end
    end,
})

-- ── Misc Section ─────────────────────────────────────────────
local GrpMisc = TabMain:AddSection({ Name = "Misc", Position = "Center" })

-- Toggle: Remove Crystal on Zombie Head
GrpMisc:AddToggle({
    Name = "Remove Crystal on Zombie Head",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state) remove_reward_crytal = state end,
})

-- Toggle: Auto Collect Event Shards (Instant)
GrpMisc:AddToggle({
    Name = "Auto Collect Event Shards",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.AUTO_COLLECT_SHARDS = state
    end,
})

-- Toggle: Auto Collect Rain Drops (Instant)
GrpMisc:AddToggle({
    Name = "Auto Collect Rain Drops",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.AUTO_COLLECT_RAIN = state
    end,
})

-- Toggle: Built-in Fly & Noclip
GrpMisc:AddToggle({
    Name = "Built-in Fly & Noclip",
    Icon = "lucide:plane",
    Default = false,
    Callback = function(state)
        player:SetAttribute("NoclipFly", state)
    end,
})

-- Toggle: Auto Safe Zone
local ch_safe_1 = nil
GrpMisc:AddToggle({
    Name = "Auto Safe Zone",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.SAFE_1 = state
        if ch_safe_1 then task.cancel(ch_safe_1) ch_safe_1 = nil end
        if state then
            local new_cframe = backup_cframe + Vector3.new(0, 20, 0)
            ch_safe_1 = task.spawn(function()
                while _G.SAFE_1 do
                    if character and character.Parent and humanoidRootPart then
                        humanoidRootPart.Velocity    = Vector3.new(0, 0, 0)
                        humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                        humanoidRootPart.CFrame      = new_cframe
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- Toggle: AFK Wave Stand
local ch_tptask = nil
GrpMisc:AddToggle({
    Name = "AFK Wave Stand",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.SAFE = state
        if ch_tptask then task.cancel(ch_tptask) ch_tptask = nil end
        if state then
            ch_tptask = task.spawn(function()
                while _G.SAFE do
                    if character and character.Parent and humanoidRootPart then
                        humanoidRootPart.CFrame = CFrame.new(
                            -221.61351, 41.3945541, -283.593719,
                             0.998308182, -0.000439744443, 0.0581427775,
                             8.71979555e-09, 0.99997139, 0.00756281661,
                            -0.0581444427, -0.00755002117, 0.998279631
                        )
                    end
                    task.wait()
                end
            end)
        else
            humanoidRootPart.CFrame = backup_cframe
        end
    end,
})

-- Toggle: Auto Skip Wave
local skip_task = nil
GrpMisc:AddToggle({
    Name = "Auto Skip Wave",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.SKIP_WAVE = state
        if skip_task then task.cancel(skip_task) skip_task = nil end
        if state then
            local SkipVote = replicatedStorage:WaitForChild("WaveRemotes"):WaitForChild("SkipVote")
            skip_task = task.spawn(function()
                while _G.SKIP_WAVE do
                    pcall(function() SkipVote:FireServer(true) end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Button: FPS Boost
GrpMisc:AddButton({
    Name = "FPS Boost",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.FogStart      = 9e9
        Lighting.Brightness    = 1.5
        Lighting.Ambient       = Color3.new(0.5, 0.5, 0.5)
        Lighting.ClockTime     = 14
        local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            Terrain.WaterWaveSize      = 0
            Terrain.WaterWaveSpeed     = 0
            Terrain.WaterReflectance   = 0
            Terrain.WaterTransparency  = 1
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CastShadow = false
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
                v:Destroy()
            elseif v:IsA("Decal") then
                v.Transparency = 1
            end
        end
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("Bloom") or v:IsA("Blur")
                or v:IsA("SunRays") then
                v.Enabled = false
                pcall(function() v:Destroy() end)
            end
        end
        workspace.DescendantAdded:Connect(function(child)
            task.wait(0.1)
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Smoke")
                or child:IsA("Fire") or child:IsA("Sparkles") or child:IsA("Beam") then
                child:Destroy()
            elseif child:IsA("BasePart") then
                child.CastShadow = false
            end
        end)
    end,
})

-- Toggle: Built-in Fly & Noclip
GrpMisc:AddToggle({
    Name = "Built-in Fly & Noclip",
    Icon = "lucide:plane",
    Default = false,
    Callback = function(state)
        player:SetAttribute("NoclipFly", state)
    end,
})

-- WalkSpeed Control
GrpMisc:AddToggle({
    Name = "Enable Custom WalkSpeed",
    Icon = "lucide:gauge",
    Default = false,
    Callback = function(state)
        _G.ENABLE_SPEED = state
    end,
})

GrpMisc:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16, Max = 250, Default = 16, Rounding = 0,
    Callback = function(value)
        _G.SPEED_VALUE = value
    end,
})

-- JumpPower Control
GrpMisc:AddToggle({
    Name = "Enable Custom JumpPower",
    Icon = "lucide:trending-up",
    Default = false,
    Callback = function(state)
        _G.ENABLE_JUMP = state
    end,
})

GrpMisc:AddSlider({
    Name = "JumpPower Value",
    Min = 50, Max = 300, Default = 50, Rounding = 0,
    Callback = function(value)
        _G.JUMP_VALUE = value
    end,
})

-- ════════════════════════════════════════════════════════════
--  TAB 2 — Shop
-- ════════════════════════════════════════════════════════════

local GrpShop = TabShop:AddSection({ Name = "Auto Purchase", Position = "Center" })

-- Toggle: Auto Upgrade HP
local hp_task = nil
GrpShop:AddToggle({
    Name = "Auto Upgrade HP",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.HP = state
        if hp_task then task.cancel(hp_task) hp_task = nil end
        if state then
            hp_task = task.spawn(function()
                while _G.HP do
                    pcall(function()
                        replicatedStorage:WaitForChild("UpgradeRemotes")
                            :WaitForChild("PurchaseHealthUpgrade"):FireServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- Toggle: Auto Upgrade Weapon (Gameplay)
local wp_task = nil
GrpShop:AddToggle({
    Name = "Auto Upgrade Weapon [Gameplay]",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.WP = state
        if wp_task then task.cancel(wp_task) wp_task = nil end
        if state then
            wp_task = task.spawn(function()
                while _G.WP do
                    pcall(function()
                        replicatedStorage:WaitForChild("UpgradeRemotes")
                            :WaitForChild("PurchaseWeaponUpgrade"):FireServer()
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- ── Lobby Weapon Upgrade ─────────────────────────────────────
local GrpLobbyUpgrade = TabShop:AddSection({ Name = "Lobby Weapon Upgrade", Position = "Center" })

local WEAPON_KEYS = {
    "Pistol", "Revolver", "DualPistols", "USPS", "Deagle",
    "ShotGun", "SMG", "CombatShotgun", "MP5", "HoneyBadger",
    "P90", "Rifle", "BurstRifle", "AK47", "Sniper",
    "TommyGun", "HeavyRifle", "Minigun", "GrenadeLauncher",
    "GumdropBlaster", "ArticStriker", "AcidSpitter", "GoldenAK47",
    "EmberSMG", "LavaRifle", "CoreBreaker", "LavaBow",
    "InfernoMinigun", "LavaGatling", "WorldEnder",
    "CosmicPistol", "Quasar", "Pulsar", "Interstellar",
    "VoidScythe", "Redline",
}

local selectedWeapon = "Pistol"

GrpLobbyUpgrade:AddDropdown({
    Name    = "Select Weapon",
    Icon    = "lucide:crosshair",
    Values  = WEAPON_KEYS,
    Default = "Pistol",
    Callback = function(value)
        selectedWeapon = value
    end,
})

local lobby_wp_task = nil
GrpLobbyUpgrade:AddToggle({
    Name    = "Auto Upgrade Weapon [Lobby]",
    Icon    = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.LOBBY_WP = state
        if lobby_wp_task then task.cancel(lobby_wp_task) lobby_wp_task = nil end
        if state then
            local UpgradeShopRemotes = replicatedStorage:FindFirstChild("UpgradeShopRemotes")
            if not UpgradeShopRemotes then
                Window:Notify({
                    Title    = "Area Peringatan ⚠️",
                    Content  = "Fitur ini hanya dapat digunakan saat berada di LOBBY!",
                    Duration = 5,
                })
                return
            end
            local UpgradeWithCredits = UpgradeShopRemotes:WaitForChild("UpgradeWithCredits", 5)
            lobby_wp_task = task.spawn(function()
                while _G.LOBBY_WP do
                    pcall(function()
                        UpgradeWithCredits:InvokeServer(selectedWeapon)
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

GrpLobbyUpgrade:AddButton({
    Name = "Upgrade Once",
    Icon = "lucide:arrow-up-circle",
    Callback = function()
        local UpgradeShopRemotes = replicatedStorage:FindFirstChild("UpgradeShopRemotes")
        if not UpgradeShopRemotes then
            Window:Notify({
                Title    = "Area Peringatan ⚠️",
                Content  = "Fitur ini hanya dapat digunakan saat berada di LOBBY!",
                Duration = 5,
            })
            return
        end
        local UpgradeWithCredits = UpgradeShopRemotes:WaitForChild("UpgradeWithCredits", 5)
        pcall(function()
            UpgradeWithCredits:InvokeServer(selectedWeapon)
        end)
        Window:Notify({
            Title    = "Lobby Upgrade",
            Content  = "Upgrading: " .. selectedWeapon,
            Duration = 2,
        })
    end,
})

-- ════════════════════════════════════════════════════════════
--  TAB 3 — Gacha
-- ════════════════════════════════════════════════════════════

local GrpGacha = TabGacha:AddSection({ Name = "Auto Spin", Position = "Center" })

-- Toggle: Auto Spin Galactic Crate
local random_GALACTIC_task = nil
GrpGacha:AddToggle({
    Name = "Auto Spin Galactic Crate",
    Icon = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.random_GALACTIC = state
        if random_GALACTIC_task then task.cancel(random_GALACTIC_task) random_GALACTIC_task = nil end
        if state then
            random_GALACTIC_task = task.spawn(function()
                local Event_GALACTIC = replicatedStorage.EventRemotes.GalacticRequestSpin
                while _G.random_GALACTIC do
                    pcall(function() Event_GALACTIC:InvokeServer() end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})


-- ════════════════════════════════════════════════════════════
--  TAB 4 — Gear
-- ════════════════════════════════════════════════════════════

local GrpGear = TabGear:AddSection({ Name = "Auto Buy Gear", Position = "Center" })

-- Gear mapping per class (dari Module.lua)
local CLASS_GEARS = {
    Survivor      = { "Landmine", "AutoTurret", "Barricade" },
    Medic         = { "StimShot", "MendingTower", "HealingStation" },
    Engineer      = { "FlamethrowerTurret", "AutoTurret", "SteelBarricade" },
    Demolitionist = { "StimShot", "ShockwaveMine", "Molotov" },
    Necromancer   = { "SoulHarvester", "RaiseUndead", "DeathNova" },
    Ninja         = { "Cloak", "BladeFury", "Shuriken" },
    Tactician     = { "VanguardTurret", "Spikes", "SteelBarricade" },
    Marksman      = { "FragGrenade", "Deadeye", "TargetMark" },
    Bastion       = { "Bunker", "LaserTurret", "Drone" },
    Celestial     = { "Starfall", "Blackhole", "SpaceBomb" },
    Overclocker   = { "Beacon", "Timewarp", "OverchargePulse" },
}

local selectedClass = "Survivor"
local selectedGear  = "Landmine"
local gearDropdown  = nil

-- Dropdown: Pilih Class
GrpGear:AddDropdown({
    Name    = "Select Class",
    Icon    = "lucide:shield-user",
    Values  = { "Survivor", "Medic", "Engineer", "Demolitionist", "Necromancer",
                "Ninja", "Tactician", "Marksman", "Bastion", "Celestial", "Overclocker" },
    Default = "Survivor",
    Callback = function(value)
        selectedClass = value
        -- Update pilihan gear sesuai class yang dipilih
        local gears = CLASS_GEARS[value] or {}
        selectedGear = gears[1] or ""
        if gearDropdown then
            gearDropdown:SetValues(gears)
            gearDropdown:SetValue(selectedGear)
        end
    end,
})

-- Dropdown: Pilih Gear
GrpGear:AddDropdown({
    Name    = "Select Gear",
    Icon    = "lucide:package",
    Values  = CLASS_GEARS["Survivor"],
    Default = "Landmine",
    Callback = function(value)
        selectedGear = value
    end,
    Init = function(dropdown)
        gearDropdown = dropdown
    end,
})

-- Toggle: Auto Buy Gear
local gear_buy_task = nil
GrpGear:AddToggle({
    Name    = "Auto Buy Gear",
    Icon    = "lucide:toggle-right",
    Default = false,
    Callback = function(state)
        _G.GEAR_BUY = state
        if gear_buy_task then task.cancel(gear_buy_task) gear_buy_task = nil end
        if state then
            local GearPurchase = replicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase")
            gear_buy_task = task.spawn(function()
                while _G.GEAR_BUY do
                    pcall(function()
                        GearPurchase:FireServer(selectedGear)
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Button: Buy Once
GrpGear:AddButton({
    Name = "Buy Gear Once",
    Icon = "lucide:shopping-cart",
    Callback = function()
        pcall(function()
            local GearPurchase = replicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase")
            GearPurchase:FireServer(selectedGear)
        end)
        Window:Notify({
            Title    = "Gear",
            Content  = "Buying: " .. selectedGear,
            Duration = 2,
        })
    end,
})

-- Toggle: No Cooldown Gears
local original_gear_data = {}
local gear_modified = false
GrpGear:AddToggle({
    Name = "No Cooldown Gears",
    Icon = "lucide:infinity",
    Default = false,
    Callback = function(state)
        local success, GearData = pcall(function()
            return require(replicatedStorage:WaitForChild("Data"):WaitForChild("GearData"))
        end)
        if success and GearData then
            if state then
                for gearName, data in pairs(GearData) do
                    if type(data) == "table" then
                        if not gear_modified then
                            original_gear_data[gearName] = {
                                Cooldown = data.Cooldown,
                                OverdriveCooldown = data.OverdriveCooldown,
                                SpawnDelay = data.SpawnDelay
                            }
                        end
                        if data.Cooldown then data.Cooldown = 0 end
                        if data.OverdriveCooldown then data.OverdriveCooldown = 0 end
                        if data.SpawnDelay then data.SpawnDelay = 0 end
                    end
                end
                gear_modified = true
            else
                if gear_modified then
                    for gearName, orig in pairs(original_gear_data) do
                        local data = GearData[gearName]
                        if data then
                            data.Cooldown = orig.Cooldown
                            data.OverdriveCooldown = orig.OverdriveCooldown
                            data.SpawnDelay = orig.SpawnDelay
                        end
                    end
                end
            end
        end
    end,
})

-- ════════════════════════════════════════════════════════════
--  Ready notify
-- ════════════════════════════════════════════════════════════
-- [FIX] AutoSave & AutoLoad
-- MainV2 hanya AutoLoad kalau file config sudah ada duluan
-- Jadi pertama kali execute: buat file dulu → sesi berikutnya bisa AutoLoad
task.defer(function()
    task.wait(1) -- tunggu semua element selesai render
    pcall(function()
        local configPath = "SolanaHubSZA/SOL_SZA"
        if not isfile(configPath) then
            -- File belum ada → save dulu buat bikin file-nya
            Window:SaveConfig("SOL_SZA", true)
        else
            -- File sudah ada → load config
            Window:LoadConfig("SOL_SZA")
        end
    end)
end)

Window:Notify({
    Title    = "SolanaHub",
    Content  = "Script loaded successfully!",
    Duration = 3,
})
