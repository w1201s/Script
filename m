--// WindUI Library Load
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--// UI Setup
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends Pro max",
    Icon = "dumbbell",
    Author = "by w1201s",
})

--// Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
    Locked = false,
})

local AutoKillTab = Window:Tab({
    Title = "Auto Kill",
    Icon = "skull",
    Locked = false,
})

local StatTab = Window:Tab({
    Title = "Stat Player",
    Icon = "bar-chart-3",
    Locked = false,
})

local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
    Locked = false,
})

--// Variables
local AutoRep = false
local SelectedStyle = "Handstands"
local AutoFarmRock = false
local AutoPunchRock = false
local SelectedRock = "Tiny Rock"
local AutoRedeemChest = false
local AutoKillPlayer = false

-- Auto Kill Styles
local AutoKillStyles = {
    Handstands = false,
    Punch = false,
    Pushups = false,
    Situps = false,
    Weight = false
}

--// Data
local Styles = {"Handstands", "Pushup", "Situp", "Weight"}
local Rocks = {
    ["Tiny Rock"] = Vector3.new(24, 4, 2097),
    ["Punching Rock"] = Vector3.new(-163, 4, 430),
    ["Large Rock"] = Vector3.new(153, 4, -154),
    ["Golden Rock"] = Vector3.new(295, 4, -620),
    ["Frozen Rock"] = Vector3.new(-2587, 4, -232),
    ["Mystic Rock"] = Vector3.new(2206, 4, 1284),
    ["Inferno Rock"] = Vector3.new(-7259, 4, -1219),
    ["Rock of Legends"] = Vector3.new(4169, 988, -4130),
    ["Muscle King Mountain"] = Vector3.new(-9020, 16, -6109),
    ["Ancient Jungle Rock"] = Vector3.new(-7524, 1, 2927)
}

local Islands = {
    ["Tiny Island"] = Vector3.new(-38, 4, 1884),
    ["Legends Beach"] = Vector3.new(-8, 4, -262),
    ["Frost Gym"] = Vector3.new(-2623, 4, -409),
    ["Mythical Gym"] = Vector3.new(2251, 4, 1073),
    ["Eternal Gym"] = Vector3.new(-6759, 4, -1285),
    ["Legends Gym"] = Vector3.new(4607, 988, -3891),
    ["Muscle King Gym"] = Vector3.new(-8626, 14, -5730),
    ["Jungle Gym"] = Vector3.new(-8670, 3, 2494)
}

local Chests = {
    "Enchanted Chest",
    "Golden Chest",
    "Legends Chest",
    "Magma Chest",
    "Jungle Chest"
}

--// Platform
local KillPlatform = nil
local function GetOrCreatePlatform()
    if not KillPlatform or not KillPlatform.Parent then
        KillPlatform = Instance.new("Part")
        KillPlatform.Name = "KillPlatform_50K"
        KillPlatform.Size = Vector3.new(100, 5, 100)
        KillPlatform.Position = Vector3.new(50000, 50000, 50000)
        KillPlatform.Anchored = true
        KillPlatform.CanCollide = true
        KillPlatform.Material = Enum.Material.Neon
        KillPlatform.Color = Color3.fromRGB(255, 0, 0)
        KillPlatform.Parent = workspace
    end
    return KillPlatform
end

--// Helper Functions
local function GetRockNames()
    local names = {}
    for name, _ in pairs(Rocks) do
        table.insert(names, name)
    end
    return names
end

local function GetIslandNames()
    local names = {}
    for name, _ in pairs(Islands) do
        table.insert(names, name)
    end
    return names
end

local function GetHRP()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

--// Remote Functions
local function EquipStyle(style)
    local args = {style}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

local function DoRep()
    while AutoRep do
        local args = {"rep"}
        LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
        task.wait()
    end
end

local function Punch()
    local args = {"punch", "leftHand"}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

local function DoStyle(style)
    local args = {style}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

--// Auto Farm Rock (TP + Face + ต่อย)
local function AutoFarmRockLoop()
    while AutoFarmRock do
        local rockPos = Rocks[SelectedRock]
        if rockPos then
            local hrp = GetHRP()
            if hrp then
                -- เข้าไปใกล้สัสๆ (3 studs จากหิน)
                local direction = (hrp.Position - rockPos).Unit
                local targetPos = rockPos + (direction * 3)
                targetPos = Vector3.new(targetPos.X, rockPos.Y, targetPos.Z) -- ให้ Y เท่ากับหิน
                
                -- TP รัวๆ + หันหน้าเข้าหาหิน
                hrp.CFrame = CFrame.new(targetPos, rockPos)
                
                -- Auto Punch ถ้าเปิด
                if AutoPunchRock then
                    Punch()
                end
            end
        end
        task.wait()
    end
end

--// Auto Redeem
local function RedeemAllChests()
    while AutoRedeemChest do
        ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("groupRemote"):InvokeServer("groupRewards")
        for _, chestName in ipairs(Chests) do
            ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("checkChestRemote"):InvokeServer(chestName)
        end
        task.wait(1)
    end
end

--// Auto Kill (เข้าไกล้ 6 studs + ทำท่าตามที่เลือก)
local function AutoKillLoop()
    GetOrCreatePlatform()
    local platformPos = Vector3.new(50000, 50002, 50000)
    
    while AutoKillPlayer do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                local myHRP = GetHRP()
                
                if myHRP then
                    -- TP เป้าหมายไปแพลตฟอร์ม
                    targetHRP.CFrame = CFrame.new(platformPos + Vector3.new(0, 5, 0))
                    targetHRP.Velocity = Vector3.new(0, 0, 0)
                    
                    -- TP ตัวเองไปใกล้ๆ อีก 2 studs (รวม 6 studs จากเป้าหมายเดิม)
                    local myPos = platformPos + Vector3.new(5, 5, 0) -- เข้าไปอีก 2 studs
                    myHRP.CFrame = CFrame.new(myPos, targetHRP.Position)
                    
                    -- ทำท่าตามที่เลือก (หลายท่าพร้อมกันได้)
                    if AutoKillStyles.Handstands then
                        DoStyle("Handstands")
                    end
                    if AutoKillStyles.Punch then
                        Punch()
                    end
                    if AutoKillStyles.Pushups then
                        DoStyle("Pushup")
                    end
                    if AutoKillStyles.Situps then
                        DoStyle("Situp")
                    end
                    if AutoKillStyles.Weight then
                        DoStyle("Weight")
                    end
                end
            end
        end
        task.wait()
    end
end

--// ==================== MAIN TAB ====================

MainTab:Section({Title = "Auto Reputation Farm"})

MainTab:Dropdown({
    Title = "Select Style",
    Desc = "Choose training style",
    Values = Styles,
    Value = SelectedStyle,
    Callback = function(option)
        SelectedStyle = option
    end
})

MainTab:Toggle({
    Title = "Auto Rep Farm",
    Desc = "Equip style and loop rep no delay",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRep = state
        if AutoRep then
            EquipStyle(SelectedStyle)
            task.wait()
            task.spawn(DoRep)
        end
    end
})

MainTab:Section({Title = "Durability Farm"})

MainTab:Dropdown({
    Title = "Select Rock",
    Desc = "Choose rock to farm",
    Values = GetRockNames(),
    Value = SelectedRock,
    Callback = function(option)
        SelectedRock = option
    end
})

-- Toggle: Auto TP to Rock (แยกจาก punch)
MainTab:Toggle({
    Title = "Auto TP to Rock",
    Desc = "Auto teleport close to rock (3 studs) and face it",
    Icon = "locate",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoFarmRock = state
        if AutoFarmRock then
            task.spawn(AutoFarmRockLoop)
        end
    end
})

-- Toggle: Auto Punch (แยก)
MainTab:Toggle({
    Title = "Auto Punch Rock",
    Desc = "Auto punch when near rock (need Auto TP on)",
    Icon = "hammer",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoPunchRock = state
    end
})

MainTab:Section({Title = "Auto Redeem Chests"})

MainTab:Toggle({
    Title = "Auto Redeem All",
    Desc = "All chests + group rewards, delay 1s",
    Icon = "gift",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRedeemChest = state
        if AutoRedeemChest then
            task.spawn(RedeemAllChests)
        end
    end
})

--// ==================== AUTO KILL TAB ====================

AutoKillTab:Section({Title = "Auto Kill Settings"})

AutoKillTab:Toggle({
    Title = "Enable Auto Kill",
    Desc = "TP target to 50K platform and attack",
    Icon = "sword",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoKillPlayer = state
        if AutoKillPlayer then
            task.spawn(AutoKillLoop)
        end
    end
})


AutoKillTab:Toggle({
    Title = "Punch",
    Desc = "Punch target",
    Icon = "fist",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoKillStyles.Punch = state
    end
})


--// ==================== STAT TAB ====================

local SelectedStatPlayer = nil

local function RefreshPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

StatTab:Dropdown({
    Title = "Select Player",
    Desc = "Choose player to view stats",
    Values = RefreshPlayerList(),
    Value = "",
    Callback = function(option)
        SelectedStatPlayer = option
    end
})

StatTab:Button({
    Title = "Refresh List",
    Desc = "Update online players",
    Locked = false,
    Callback = function()
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list updated!",
            Duration = 2
        })
    end
})

StatTab:Button({
    Title = "View Stats",
    Desc = "Show all player statistics",
    Locked = false,
    Callback = function()
        local target = Players:FindFirstChild(SelectedStatPlayer)
        if not target then
            WindUI:Notify({Title = "Error", Content = "Player not found!", Duration = 2})
            return
        end
        
        local stats = {["Player"] = target.Name}
        local leaderstats = target:FindFirstChild("leaderstats")
        
        if leaderstats then
            for _, stat in ipairs(leaderstats:GetChildren()) do
                stats[stat.Name] = stat.Value
            end
        end
        
        for _, name in ipairs({"Gems", "Rebirth", "Strength", "Durability", "PlayTime"}) do
            local val = target:FindFirstChild(name)
            if val then stats[name] = val.Value end
        end
        
        local text = ""
        for k, v in pairs(stats) do
            text = text .. k .. ": " .. tostring(v) .. "\n"
        end
        
        WindUI:Notify({
            Title = "📊 " .. target.Name,
            Content = text,
            Duration = 5
        })
    end
})

--// ==================== TELEPORT TAB ====================

TeleportTab:Button({
    Title = "TP to Platform",
    Desc = "Teleport to 50K studs platform",
    Locked = false,
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            GetOrCreatePlatform()
            hrp.CFrame = CFrame.new(50000, 50005, 50000)
            WindUI:Notify({Title = "Teleported", Content = "At 50K platform!", Duration = 2})
        end
    end
})

TeleportTab:Section({Title = "Island Teleport"})

local SelectedIsland = "Tiny Island"

TeleportTab:Dropdown({
    Title = "Select Island",
    Desc = "Choose destination",
    Values = GetIslandNames(),
    Value = SelectedIsland,
    Callback = function(option)
        SelectedIsland = option
    end
})

TeleportTab:Button({
    Title = "TP to Island",
    Desc = "Instant travel",
    Locked = false,
    Callback = function()
        local pos = Islands[SelectedIsland]
        if pos then
            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = CFrame.new(pos)
                WindUI:Notify({Title = "Teleported", Content = "At " .. SelectedIsland .. "!", Duration = 2})
            end
        end
    end
})
