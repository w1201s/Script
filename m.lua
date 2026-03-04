--// WindUI Library Load
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// UI Setup
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends Pro",
    Icon = "dumbbell", -- Lucide icon
    Author = "by WindUI",
})

--// Tabs with Lucide Icons
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home", -- Lucide icon
    Locked = false,
})

local AutoKillTab = Window:Tab({
    Title = "Auto Kill",
    Icon = "sword", -- Lucide icon
    Locked = false,
})

local StatTab = Window:Tab({
    Title = "Stat Player",
    Icon = "bar-chart-3", -- Lucide icon
    Locked = false,
})

local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin", -- Lucide icon
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
    ["Tiny Rock"] = {Position = Vector3.new(24, 4, 2097), Durability = 0},
    ["Punching Rock"] = {Position = Vector3.new(-163, 4, 430), Durability = 10},
    ["Large Rock"] = {Position = Vector3.new(153, 4, -154), Durability = 100},
    ["Golden Rock"] = {Position = Vector3.new(295, 4, -620), Durability = 5000},
    ["Frozen Rock"] = {Position = Vector3.new(-2587, 4, -232), Durability = 150000},
    ["Mystic Rock"] = {Position = Vector3.new(2206, 4, 1284), Durability = 400000},
    ["Inferno Rock"] = {Position = Vector3.new(-7259, 4, -1219), Durability = 750000},
    ["Rock of Legends"] = {Position = Vector3.new(4169, 988, -4130), Durability = 1000000},
    ["Muscle King Mountain"] = {Position = Vector3.new(-9020, 16, -6109), Durability = 5000000},
    ["Ancient Jungle Rock"] = {Position = Vector3.new(-7524, 1, 2927), Durability = 10000000}
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

--// Function: Get Rock Names for Dropdown
local function GetRockNames()
    local names = {}
    for name, _ in pairs(Rocks) do
        table.insert(names, name)
    end
    return names
end

--// Function: Get Island Names for Dropdown
local function GetIslandNames()
    local names = {}
    for name, _ in pairs(Islands) do
        table.insert(names, name)
    end
    return names
end

--// Function: Auto Rep Farm
local function DoRep()
    while AutoRep do
        local args = {"rep"}
        LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
        task.wait()
    end
end

--// Function: Equip Style
local function EquipStyle(style)
    local args = {style}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

--// Function: Face to Target & Move Close
local function FaceAndMoveToTarget(targetPosition, distance)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- หันหน้าเข้าหาเป้าหมาย
    local lookCFrame = CFrame.lookAt(hrp.Position, targetPosition)
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(targetPosition.X - hrp.Position.X, targetPosition.Z - hrp.Position.Z), 0)
    
    -- คำนวณตำแหน่งที่จะไป (ใกล้เป้าหมายตามระยะที่กำหนด)
    local direction = (targetPosition - hrp.Position).Unit
    local targetPos = targetPosition - (direction * distance)
    
    -- Tween ไปที่ตำแหน่ง
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos, targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

--// Function: Punch
local function Punch()
    local args = {"punch", "leftHand"}
    LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
end

--// Function: Auto Farm Rock
local function AutoFarmRockLoop()
    while AutoFarmRock do
        local rockData = Rocks[SelectedRock]
        if rockData then
            -- หันหน้าเข้าหาหินและเข้าไปใกล้ (ระยะ 6 studs)
            FaceAndMoveToTarget(rockData.Position, 6)
            task.wait(0.1)
            -- ต่อยไม่มีดีเลย์
            Punch()
        end
        task.wait(0.4) -- Loop ทุก 0.4 วิ
    end
end

--// Function: Redeem All Chests
local function RedeemAllChests()
    while AutoRedeemChest do
        -- Group Rewards
        local groupArgs = {"groupRewards"}
        ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("groupRemote"):InvokeServer(unpack(groupArgs))
        
        -- All Chests
        for _, chestName in ipairs(Chests) do
            local args = {chestName}
            ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("checkChestRemote"):InvokeServer(unpack(args))
        end
        
        task.wait(1) -- Delay 1 วิ
    end
end

--// Function: Auto Kill Player
local function AutoKillLoop()
    -- สร้างแพลตฟอร์มก่อน
    local platformPos = Vector3.new(50000, 50000, 50000)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(50, 5, 50)
    platform.Position = platformPos
    platform.Anchored = true
    platform.Parent = workspace
    
    while AutoKillPlayer do
        -- หาเป้าหมายที่ใกล้ที่สุด
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                
                -- TP เป้าหมายไปแพลตฟอร์ม
                targetHRP.CFrame = CFrame.new(platformPos + Vector3.new(0, 10, 0))
                
                -- TP ตัวเองไปด้วย
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = CFrame.new(platformPos + Vector3.new(15, 10, 0))
                    
                    -- หันหน้าเข้าหาเป้าหมาย
                    myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetHRP.Position)
                    
                    -- ต่อยไม่มีดีเลย์
                    Punch()
                end
            end
        end
        task.wait()
    end
    
    -- ลบแพลตฟอร์มเมื่อปิด
    platform:Destroy()
end

--// ==================== MAIN TAB ====================

-- Section: Auto Rep
local RepSection = MainTab:Section({
    Title = "Auto Reputation Farm"
})

-- Style Dropdown
MainTab:Dropdown({
    Title = "Select Style",
    Desc = "Choose training style",
    Values = Styles,
    Value = SelectedStyle,
    Callback = function(option)
        SelectedStyle = option
        EquipStyle(SelectedStyle)
    end
})

-- Auto Rep Toggle
MainTab:Toggle({
    Title = "Auto Rep Farm (No Delay)",
    Desc = "Loop reputation farming with selected style",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRep = state
        if AutoRep then
            EquipStyle(SelectedStyle)
            task.spawn(DoRep)
        end
    end
})

-- Section: Durability Farm
local DurabilitySection = MainTab:Section({
    Title = "Durability Farm"
})

-- Rock Dropdown
MainTab:Dropdown({
    Title = "Select Rock",
    Desc = "Choose rock to farm durability",
    Values = GetRockNames(),
    Value = SelectedRock,
    Callback = function(option)
        SelectedRock = option
    end
})

-- Auto Farm Rock Toggle
MainTab:Toggle({
    Title = "Auto Farm Rock",
    Desc = "Face rock, move close (6 studs), and punch every 0.4s",
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

-- Section: Auto Redeem Chest
local ChestSection = MainTab:Section({
    Title = "Auto Redeem Chests"
})

-- Auto Redeem Chest Toggle
MainTab:Toggle({
    Title = "Auto Redeem All Chests",
    Desc = "Redeem all chests with 1 second delay",
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
    Desc = "Build platform at 50K studs, TP target there, auto punch",
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
local PlayerList = {}

local function RefreshPlayerList()
    PlayerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayerList, player.Name)
        end
    end
    return PlayerList
end

-- Player Dropdown
StatTab:Dropdown({
    Title = "Select Player",
    Desc = "Choose player to view stats",
    Values = RefreshPlayerList(),
    Value = "",
    Callback = function(option)
        SelectedStatPlayer = option
    end
})

-- Refresh Button
StatTab:Button({
    Title = "Refresh Player List",
    Desc = "Update online players list",
    Locked = false,
    Callback = function()
        RefreshPlayerList()
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list updated!",
            Duration = 2
        })
    end
})

-- View Stats Button
StatTab:Button({
    Title = "View Selected Player Stats",
    Desc = "Show gems, rebirth, playtime, strength, durability",
    Locked = false,
    Callback = function()
        local targetPlayer = Players:FindFirstChild(SelectedStatPlayer)
        if targetPlayer then
            local leaderstats = targetPlayer:FindFirstChild("leaderstats")
            local stats = {
                ["Player"] = targetPlayer.Name,
                ["Gems"] = "N/A",
                ["Rebirth"] = "N/A",
                ["Play Time"] = "N/A",
                ["Strength"] = "N/A",
                ["Durability"] = "N/A"
            }
            
            -- ดึงข้อมูลจาก leaderstats หรือ values ต่างๆ
            if leaderstats then
                for _, stat in ipairs(leaderstats:GetChildren()) do
                    if stats[stat.Name] then
                        stats[stat.Name] = stat.Value
                    end
                end
            end
            
            -- ดึงจาก Values อื่นๆ ถ้ามี
            local gems = targetPlayer:FindFirstChild("Gems")
            if gems then stats["Gems"] = gems.Value end
            
            local rebirth = targetPlayer:FindFirstChild("Rebirth")
            if rebirth then stats["Rebirth"] = rebirth.Value end
            
            local strength = targetPlayer:FindFirstChild("Strength")
            if strength then stats["Strength"] = strength.Value end
            
            local durability = targetPlayer:FindFirstChild("Durability")
            if durability then stats["Durability"] = durability.Value end
            
            -- แสดงผล
            local statText = ""
            for stat, value in pairs(stats) do
                statText = statText .. stat .. ": " .. tostring(value) .. "\n"
            end
            
            WindUI:Notify({
                Title = "📊 Stats: " .. targetPlayer.Name,
                Content = statText,
                Duration = 5
            })
        else
            WindUI:Notify({
                Title = "❌ Error",
                Content = "Player not found or left the game!",
                Duration = 2
            })
        end
    end
})

--// ==================== TELEPORT TAB ====================

-- TP to Kill Platform Button
TeleportTab:Button({
    Title = "Teleport to Kill Platform (50K)",
    Desc = "Go to 50K studs platform",
    Locked = false,
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(50000, 50010, 50000)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Moved to kill platform at 50K studs!",
                Duration = 2
            })
        end
    end
})

-- Island Section
local IslandSection = TeleportTab:Section({
    Title = "Island Teleport"
})

local SelectedIsland = "Tiny Island"

-- Island Dropdown
TeleportTab:Dropdown({
    Title = "Select Island/Gym",
    Desc = "Choose destination",
    Values = GetIslandNames(),
    Value = SelectedIsland,
    Callback = function(option)
        SelectedIsland = option
    end
})

-- TP to Island Button
TeleportTab:Button({
    Title = "Teleport to Selected Island",
    Desc = "Instant travel to chosen location",
    Locked = false,
    Callback = function()
        local pos = Islands[SelectedIsland]
        if pos then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Arrived at " .. SelectedIsland .. "!",
                    Duration = 2
                })
            end
        end
    end
})

--// Initial Notification
WindUI:Notify({
    Title = "Muscle Legends Pro",
    Content = "Script loaded successfully with WindUI! 💪",
    Duration = 3
})
