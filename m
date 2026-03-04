--// WindUI Library Load
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--// UI Setup
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends Pro",
    Icon = "dumbbell",
    Author = "by WindUI",
})

--// Tabs with Lucide Icons
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
    Locked = false,
})

local AutoKillTab = Window:Tab({
    Title = "Auto Kill",
    Icon = "sword",
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
local SelectedRock = "Tiny Rock"
local AutoRedeemChest = false
local AutoKillPlayer = false

--// Styles & Rocks Data
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

--// Islands Data
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

--// Chests List
local Chests = {
    "Enchanted Chest",
    "Golden Chest",
    "Legends Chest",
    "Magma Chest",
    "Jungle Chest"
}

--// Platform (สร้างครั้งเดียว ไม่ลบ)
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

--// Function: Get Rock Names
local function GetRockNames()
    local names = {}
    for name, _ in pairs(Rocks) do
        table.insert(names, name)
    end
    return names
end

--// Function: Get Island Names
local function GetIslandNames()
    local names = {}
    for name, _ in pairs(Islands) do
        table.insert(names, name)
    end
    return names
end

--// Function: Equip Style (ใช้ remote ที่ถูกต้อง)
local function EquipStyle(style)
    local args = {style}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

--// Function: Do Rep
local function DoRep()
    while AutoRep do
        local args = {"rep"}
        LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
        task.wait()
    end
end

--// Function: Punch
local function Punch()
    local args = {"punch", "leftHand"}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

--// Function: Auto Farm Rock (TP รัวๆ เข้าไปใกล้สัสๆ ล็อกหน้า)
local function AutoFarmRockLoop()
    while AutoFarmRock do
        local rockPos = Rocks[SelectedRock]
        if rockPos then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- เข้าไปใกล้สัสๆ (2 studs จากหิน)
                    local targetPos = rockPos + Vector3.new(0, 0, 2)
                    
                    -- TP รัวๆ ไม่ใช้ Tween
                    hrp.CFrame = CFrame.new(targetPos, rockPos) -- หันหน้าเข้าหาหิน + ล็อก
                    
                    -- ต่อยทันที
                    Punch()
                end
            end
        end
        task.wait(0.4)
    end
end

--// Function: Redeem All Chests
local function RedeemAllChests()
    while AutoRedeemChest do
        -- Group Rewards
        ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("groupRemote"):InvokeServer("groupRewards")
        
        -- All Chests
        for _, chestName in ipairs(Chests) do
            ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("checkChestRemote"):InvokeServer(chestName)
        end
        
        task.wait(1)
    end
end

--// Function: Auto Kill
local function AutoKillLoop()
    -- สร้างแพลตฟอร์ม (ไม่ลบ)
    GetOrCreatePlatform()
    local platformPos = Vector3.new(50000, 50002, 50000)
    
    while AutoKillPlayer do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myHRP then
                    -- TP เป้าหมายไปแพลตฟอร์ม
                    targetHRP.CFrame = CFrame.new(platformPos + Vector3.new(0, 5, 0))
                    targetHRP.Velocity = Vector3.new(0, 0, 0) -- หยุดความเร็ว
                    
                    -- TP ตัวเองไปด้วย ห่างจากเป้าหมายนิดหน่อย
                    myHRP.CFrame = CFrame.new(platformPos + Vector3.new(8, 5, 0))
                    
                    -- หันหน้าเข้าหาเป้าหมาย + ล็อก
                    myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetHRP.Position)
                    
                    -- ต่อยรัวๆ
                    Punch()
                end
            end
        end
        task.wait()
    end
end

--// ==================== MAIN TAB ====================

MainTab:Section({Title = "Auto Reputation Farm"})

-- Style Dropdown
MainTab:Dropdown({
    Title = "Select Style",
    Desc = "Choose training style",
    Values = Styles,
    Value = SelectedStyle,
    Callback = function(option)
        SelectedStyle = option
    end
})

-- Auto Rep Toggle (แก้ให้ Equip จริงๆ)
MainTab:Toggle({
    Title = "Auto Rep Farm (No Delay)",
    Desc = "Equip style and loop rep",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRep = state
        if AutoRep then
            -- Equip ก่อนแล้วค่อยเริ่ม loop
            EquipStyle(SelectedStyle)
            task.wait(0.1)
            task.spawn(DoRep)
        end
    end
})

-- Section: Durability Farm
MainTab:Section({Title = "Durability Farm"})

-- Rock Dropdown
MainTab:Dropdown({
    Title = "Select Rock",
    Desc = "Choose rock to punch",
    Values = GetRockNames(),
    Value = SelectedRock,
    Callback = function(option)
        SelectedRock = option
    end
})

-- Auto Farm Rock Toggle (TP รัวๆ เข้าไกล้สัสๆ)
MainTab:Toggle({
    Title = "Auto Farm Rock",
    Desc = "TP fast, close as fuck (2 studs), face locked",
    Icon = "pickaxe",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoFarmRock = state
        if AutoFarmRock then
            task.spawn(AutoFarmRockLoop)
        end
    end
})

-- Section: Auto Redeem
MainTab:Section({Title = "Auto Redeem Chests"})

-- Auto Redeem Chest Toggle
MainTab:Toggle({
    Title = "Auto Redeem All Chests",
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

AutoKillTab:Toggle({
    Title = "Auto Kill Player",
    Desc = "TP to 50K platform, lock face, spam punch",
    Icon = "skull",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoKillPlayer = state
        if AutoKillPlayer then
            task.spawn(AutoKillLoop)
        end
    end
})

--// ==================== STAT PLAYER TAB ====================

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
    Title = "Refresh Player List",
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
    Desc = "Show gems, rebirth, playtime, strength, durability",
    Locked = false,
    Callback = function()
        local target = Players:FindFirstChild(SelectedStatPlayer)
        if target then
            local stats = {["Player"] = target.Name}
            
            -- ดึงจาก leaderstats
            local leaderstats = target:FindFirstChild("leaderstats")
            if leaderstats then
                for _, stat in ipairs(leaderstats:GetChildren()) do
                    stats[stat.Name] = stat.Value
                end
            end
            
            -- ดึงจาก Values อื่นๆ
            local values = {"Gems", "Rebirth", "Strength", "Durability", "PlayTime"}
            for _, name in ipairs(values) do
                local val = target:FindFirstChild(name)
                if val then
                    stats[name] = val.Value
                end
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
        else
            WindUI:Notify({
                Title = "❌ Error",
                Content = "Player not found!",
                Duration = 2
            })
        end
    end
})

--// ==================== TELEPORT TAB ====================

-- Rename: TP to Platform
TeleportTab:Button({
    Title = "TP to Platform",
    Desc = "Teleport to 50K studs kill platform",
    Locked = false,
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            GetOrCreatePlatform()
            hrp.CFrame = CFrame.new(50000, 50005, 50000)
            WindUI:Notify({
                Title = "Teleported",
                Content = "At 50K platform!",
                Duration = 2
            })
        end
    end
})

TeleportTab:Section({Title = "Island Teleport"})

local SelectedIsland = "Tiny Island"

TeleportTab:Dropdown({
    Title = "Select Island/Gym",
    Desc = "Choose destination",
    Values = GetIslandNames(),
    Value = SelectedIsland,
    Callback = function(option)
        SelectedIsland = option
    end
})

TeleportTab:Button({
    Title = "Teleport to Island",
    Desc = "Instant travel",
    Locked = false,
    Callback = function()
        local pos = Islands[SelectedIsland]
        if pos then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "At " .. SelectedIsland .. "!",
                    Duration = 2
                })
            end
        end
    end
})

--// Init
WindUI:Notify({
    Title = "Muscle Legends Pro",
    Content = "Loaded! 💪",
    Duration = 3
})
