--// WindUI Library Load
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// UI Setup
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromOffset(200, 200)
})

--// Tabs
local MainTab = Window:CreateTab("Main", "rbxassetid://7733965386")
local AutoKillTab = Window:CreateTab("Auto Kill", "rbxassetid://7733964640")
local StatTab = Window:CreateTab("Stat Player", "rbxassetid://7733970521")
local TeleportTab = Window:CreateTab("Teleport", "rbxassetid://7733974992")

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
    while AutoKillPlayer do
        -- สร้างแพลตฟอร์มที่ 50K studs จาก spawn (0,0,0)
        local platformPos = Vector3.new(50000, 50000, 50000)
        
        -- หาเป้าหมายที่ใกล้ที่สุด
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                
                -- TP เป้าหมายไปแพลตฟอร์ม
                targetHRP.CFrame = CFrame.new(platformPos + Vector3.new(0, 5, 0))
                
                -- TP ตัวเองไปด้วย
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = CFrame.new(platformPos + Vector3.new(10, 5, 0))
                    
                    -- หันหน้าเข้าหาเป้าหมาย
                    myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetHRP.Position)
                    
                    -- ต่อยไม่มีดีเลย์
                    Punch()
                end
            end
        end
        task.wait()
    end
end

--// ==================== MAIN TAB ====================

-- Style Dropdown
MainTab:CreateDropdown({
    Name = "Select Style",
    Options = Styles,
    CurrentOption = SelectedStyle,
    Callback = function(option)
        SelectedStyle = option
        EquipStyle(SelectedStyle)
    end
})

-- Auto Rep Toggle
MainTab:CreateToggle({
    Name = "Auto Rep Farm (No Delay)",
    CurrentValue = false,
    Callback = function(value)
        AutoRep = value
        if AutoRep then
            EquipStyle(SelectedStyle)
            task.spawn(DoRep)
        end
    end
})

-- Divider
MainTab:CreateSection("Durability Farm")

-- Rock Dropdown
MainTab:CreateDropdown({
    Name = "Select Rock",
    Options = (function()
        local names = {}
        for name, _ in pairs(Rocks) do
            table.insert(names, name)
        end
        return names
    end)(),
    CurrentOption = SelectedRock,
    Callback = function(option)
        SelectedRock = option
    end
})

-- Auto Farm Rock Toggle
MainTab:CreateToggle({
    Name = "Auto Farm Rock (Face & Move Close)",
    CurrentValue = false,
    Callback = function(value)
        AutoFarmRock = value
        if AutoFarmRock then
            task.spawn(AutoFarmRockLoop)
        end
    end
})

-- Divider
MainTab:CreateSection("Auto Redeem Chest")

-- Auto Redeem Chest Toggle
MainTab:CreateToggle({
    Name = "Auto Redeem All Chests (Delay 1s)",
    CurrentValue = false,
    Callback = function(value)
        AutoRedeemChest = value
        if AutoRedeemChest then
            task.spawn(RedeemAllChests)
        end
    end
})

--// ==================== AUTO KILL TAB ====================

AutoKillTab:CreateToggle({
    Name = "Auto Kill Player (50K Studs Platform)",
    CurrentValue = false,
    Callback = function(value)
        AutoKillPlayer = value
        if AutoKillPlayer then
            task.spawn(AutoKillLoop)
        end
    end
})

--// ==================== STAT PLAYER TAB ====================

local SelectedStatPlayer = nil
local PlayerDropdown

local function RefreshPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    
    -- อัปเดต dropdown (ต้องสร้างใหม่หรืออัปเดต options)
    return playerNames
end

StatTab:CreateDropdown({
    Name = "Select Player",
    Options = RefreshPlayerList(),
    CurrentOption = "",
    Callback = function(option)
        SelectedStatPlayer = option
    end
})

StatTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        -- รีเฟรชรายชื่อผู้เล่น
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list updated!",
            Duration = 2
        })
    end
})

StatTab:CreateButton({
    Name = "👁️ View Selected Player Stats",
    Callback = function()
        local targetPlayer = Players:FindFirstChild(SelectedStatPlayer)
        if targetPlayer then
            -- ดึงข้อมูลสถิติ (ตัวอย่าง)
            local stats = {
                ["Player"] = targetPlayer.Name,
                ["Gems"] = targetPlayer:FindFirstChild("Gems") and targetPlayer.Gems.Value or "N/A",
                ["Rebirth"] = targetPlayer:FindFirstChild("Rebirth") and targetPlayer.Rebirth.Value or "N/A",
                ["Play Time"] = targetPlayer:FindFirstChild("PlayTime") and targetPlayer.PlayTime.Value or "N/A",
                ["Strength"] = targetPlayer:FindFirstChild("Strength") and targetPlayer.Strength.Value or "N/A",
                ["Durability"] = targetPlayer:FindFirstChild("Durability") and targetPlayer.Durability.Value or "N/A"
            }
            
            -- แสดงใน UI หรือ Notify
            local statText = ""
            for stat, value in pairs(stats) do
                statText = statText .. stat .. ": " .. tostring(value) .. "\n"
            end
            
            WindUI:Notify({
                Title = "Stats: " .. targetPlayer.Name,
                Content = statText,
                Duration = 5
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Player not found!",
                Duration = 2
            })
        end
    end
})

--// ==================== TELEPORT TAB ====================

-- TP to Kill Platform
TeleportTab:CreateButton({
    Name = "🎯 Teleport to Kill Platform (50K)",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(50000, 50000, 50000)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Moved to kill platform!",
                Duration = 2
            })
        end
    end
})

TeleportTab:CreateSection("Island Teleport")

-- Island Dropdown
local SelectedIsland = "Tiny Island"
TeleportTab:CreateDropdown({
    Name = "Select Island/Gym",
    Options = (function()
        local names = {}
        for name, _ in pairs(Islands) do
            table.insert(names, name)
        end
        return names
    end)(),
    CurrentOption = SelectedIsland,
    Callback = function(option)
        SelectedIsland = option
    end
})

-- TP to Island Button
TeleportTab:CreateButton({
    Name = "🌴 Teleport to Selected Island",
    Callback = function()
        local pos = Islands[SelectedIsland]
        if pos then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Moved to " .. SelectedIsland,
                    Duration = 2
                })
            end
        end
    end
})

--// Initial Notification
WindUI:Notify({
    Title = "Muscle Legends Script",
    Content = "Loaded successfully! Made with WindUI",
    Duration = 3
})
