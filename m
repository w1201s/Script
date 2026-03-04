-- Wind UI Script for Muscle Legends
-- Load Wind UI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends Hub",
    Icon = "dumbbell",
    Author = "Custom Script",
    Folder = "MuscleLegendsHub",
    Size = UDim2.fromOffset(580, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = false
})

-- Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- States
local AutoRep = false
local AutoDurability = false
local AutoChest = false
local AutoKill = false
local SelectedStyle = "Handstands"
local SelectedRock = "Tiny Rock (0+)"
local SelectedIsland = "Tiny Island"
local SelectedPlayer = nil

-- Rock Data with formatted durability
local Rocks = {
    ["Tiny Rock (0+)"] = {Position = Vector3.new(24, 4, 2097), Durability = 0},
    ["Punching Rock (10+)"] = {Position = Vector3.new(-163, 4, 430), Durability = 10},
    ["Large Rock (100+)"] = {Position = Vector3.new(153, 4, -154), Durability = 100},
    ["Golden Rock (5K+)"] = {Position = Vector3.new(295, 4, -620), Durability = 5000},
    ["Frozen Rock (150K+)"] = {Position = Vector3.new(-2587, 4, -232), Durability = 150000},
    ["Mystic Rock (400K+)"] = {Position = Vector3.new(2206, 4, 1284), Durability = 400000},
    ["Inferno Rock (750K+)"] = {Position = Vector3.new(-7259, 4, -1219), Durability = 750000},
    ["Rock of Legends (1M+)"] = {Position = Vector3.new(4169, 988, -4130), Durability = 1000000},
    ["Muscle King Mountain (5M+)"] = {Position = Vector3.new(-9020, 16, -6109), Durability = 5000000},
    ["Ancient Jungle Rock (10M+)"] = {Position = Vector3.new(-7524, 1, 2927), Durability = 10000000}
}

-- Island Data
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

-- Styles
local Styles = {"Handstands", "Pushup", "Situp", "Weight"}

-- Chests
local Chests = {"Enchanted Chest", "Golden Chest", "Legends Chest", "Magma Chest", "Jungle Chest"}

-- Auto Rep Function
task.spawn(function()
    while true do
        if AutoRep then
            local args = {"rep"}
            LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(args))
        end
        task.wait()
    end
end)

-- Auto Durability Function
task.spawn(function()
    while true do
        if AutoDurability and Rocks[SelectedRock] then
            local rockData = Rocks[SelectedRock]
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(rockData.Position)
                task.wait(0.4)
                local punchArgs = {"punch", "leftHand"}
                LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(punchArgs))
            end
        end
        task.wait()
    end
end)

-- Auto Chest Function
task.spawn(function()
    while true do
        if AutoChest then
            for _, chestName in ipairs(Chests) do
                local args = {chestName}
                ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("checkChestRemote"):InvokeServer(unpack(args))
            end
            -- Group rewards
            local groupArgs = {"groupRewards"}
            ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("groupRemote"):InvokeServer(unpack(groupArgs))
            task.wait(1)
        else
            task.wait(0.1)
        end
    end
end)

-- Auto Kill Variables
local KillPlatform = nil
local KillLoopRunning = false

-- Create Kill Platform Function
local function CreateKillPlatform()
    if KillPlatform then KillPlatform:Destroy() end
    
    local platform = Instance.new("Part")
    platform.Name = "KillPlatform"
    platform.Size = Vector3.new(50, 5, 50)
    platform.Position = Vector3.new(50000, 50000, 50000) -- 50K studs away
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = workspace
    
    -- Make it invisible but functional
    local invisibleMaterial = Enum.Material.SmoothPlastic
    platform.Material = invisibleMaterial
    platform.Transparency = 1
    
    KillPlatform = platform
    return platform
end

-- Auto Kill Function
task.spawn(function()
    CreateKillPlatform()
    
    while true do
        if AutoKill and KillPlatform then
            -- Find target player
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local localChar = LocalPlayer.Character
                    
                    if targetHRP and localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        -- Teleport target to platform
                        targetHRP.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(0, 10, 0))
                        
                        -- Teleport local player to platform to punch
                        localChar.HumanoidRootPart.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(0, 10, 10))
                        
                        -- Punch
                        local punchArgs = {"punch", "leftHand"}
                        LocalPlayer:WaitForChild("muscleEvent"):FireServer(unpack(punchArgs))
                        
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait()
    end
end)

-- Get Player Stats Function
local function GetPlayerStats(player)
    local stats = {}
    local leaderstats = player:FindFirstChild("leaderstats")
    
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            table.insert(stats, {Name = stat.Name, Value = stat.Value})
        end
    end
    
    -- Additional stats
    local gems = player:FindFirstChild("Gems") and player.Gems.Value or "N/A"
    local rebirths = player:FindFirstChild("Rebirths") and player.Rebirths.Value or "N/A"
    local playTime = player:FindFirstChild("PlayTime") and player.PlayTime.Value or "N/A"
    
    return {
        Stats = stats,
        Gems = gems,
        Rebirths = rebirths,
        PlayTime = playTime
    }
end

-- ==================== MAIN TAB ====================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
    Selected = true
})

-- UI Setup Section
MainTab:Section({Title = "UI Setup"})

-- Style Dropdown
local StyleDropdown = MainTab:Dropdown({
    Title = "Select Style",
    Values = Styles,
    Value = SelectedStyle,
    Callback = function(value)
        SelectedStyle = value
        -- Equip style logic here (you may need to adjust based on game mechanics)
    end
})

-- Auto Rep Toggle
MainTab:Toggle({
    Title = "Auto Rep Loop (No Delay)",
    Default = false,
    Callback = function(value)
        AutoRep = value
    end
})

-- Durability Farm Section
MainTab:Section({Title = "Durability Farm"})

-- Rock Dropdown with formatted names
local RockDropdown = MainTab:Dropdown({
    Title = "Select Rock",
    Values = {
        "Tiny Rock (0+)",
        "Punching Rock (10+)",
        "Large Rock (100+)",
        "Golden Rock (5K+)",
        "Frozen Rock (150K+)",
        "Mystic Rock (400K+)",
        "Inferno Rock (750K+)",
        "Rock of Legends (1M+)",
        "Muscle King Mountain (5M+)",
        "Ancient Jungle Rock (10M+)"
    },
    Value = SelectedRock,
    Callback = function(value)
        SelectedRock = value
    end
})

-- Auto Durability Toggle
MainTab:Toggle({
    Title = "Auto Farm Durability",
    Default = false,
    Callback = function(value)
        AutoDurability = value
    end
})

-- Auto Chest Section
MainTab:Section({Title = "Auto Redeem Chest"})

MainTab:Toggle({
    Title = "Auto Redeem All Chests (1s Delay)",
    Default = false,
    Callback = function(value)
        AutoChest = value
    end
})

-- ==================== AUTO KILL TAB ====================
local AutoKillTab = Window:Tab({
    Title = "Auto Kill",
    Icon = "skull"
})

AutoKillTab:Section({Title = "Auto Kill Setup"})

AutoKillTab:Label({
    Title = "Platform Location: 50K studs from spawn",
    Description = "X: 50000, Y: 50000, Z: 50000"
})

-- Create Platform Button
AutoKillTab:Button({
    Title = "Create/Reset Kill Platform",
    Callback = function()
        CreateKillPlatform()
        WindUI:Notify({
            Title = "Platform Created",
            Content = "Kill platform created at 50K studs away",
            Duration = 3
        })
    end
})

-- Auto Kill Toggle
AutoKillTab:Toggle({
    Title = "Auto Kill Players",
    Description = "TP players to platform & punch (No delay)",
    Default = false,
    Callback = function(value)
        AutoKill = value
        if value then
            CreateKillPlatform()
        end
    end
})

-- ==================== STAT TAB ====================
local StatTab = Window:Tab({
    Title = "Player Stats",
    Icon = "bar-chart-2"
})

StatTab:Section({Title = "View Player Statistics"})

-- Player Dropdown
local PlayerDropdown = StatTab:Dropdown({
    Title = "Select Player",
    Values = {},
    Value = "Select a player...",
    Callback = function(value)
        SelectedPlayer = value
    end
})

-- Refresh Button
StatTab:Button({
    Title = "Refresh Player List",
    Callback = function()
        local playerNames = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        PlayerDropdown:Refresh(playerNames)
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list updated",
            Duration = 2
        })
    end
})

-- Stats Display
local StatsLabel = StatTab:Label({
    Title = "No player selected",
    Description = "Select a player and click 'View Stats'"
})

-- View Stats Button
StatTab:Button({
    Title = "View Selected Player Stats",
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "Select a player..." then
            local targetPlayer = Players:FindFirstChild(SelectedPlayer)
            if targetPlayer then
                local stats = GetPlayerStats(targetPlayer)
                local statText = "Player: " .. targetPlayer.Name .. "\n\n"
                statText = statText .. "Gems: " .. tostring(stats.Gems) .. "\n"
                statText = statText .. "Rebirths: " .. tostring(stats.Rebirths) .. "\n"
                statText = statText .. "Play Time: " .. tostring(stats.PlayTime) .. "\n\n"
                statText = statText .. "Leaderstats:\n"
                
                for _, stat in ipairs(stats.Stats) do
                    statText = statText .. "• " .. stat.Name .. ": " .. tostring(stat.Value) .. "\n"
                end
                
                StatsLabel:SetTitle(targetPlayer.Name .. " Stats")
                StatsLabel:SetDescription(statText)
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Please select a player first",
                Duration = 3
            })
        end
    end
})

-- ==================== TELEPORT TAB ====================
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin"
})

TeleportTab:Section({Title = "Teleport Options"})

-- TP to Platform Button
TeleportTab:Button({
    Title = "Teleport to Kill Platform",
    Callback = function()
        if KillPlatform then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(0, 10, 0))
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Moved to kill platform",
                    Duration = 2
                })
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Platform not created yet",
                Duration = 3
            })
        end
    end
})

TeleportTab:Section({Title = "Island/Gym Teleport"})

-- Island Dropdown
local IslandDropdown = TeleportTab:Dropdown({
    Title = "Select Island/Gym",
    Values = {
        "Tiny Island",
        "Legends Beach",
        "Frost Gym",
        "Mythical Gym",
        "Eternal Gym",
        "Legends Gym",
        "Muscle King Gym",
        "Jungle Gym"
    },
    Value = SelectedIsland,
    Callback = function(value)
        SelectedIsland = value
    end
})

-- TP to Island Button
TeleportTab:Button({
    Title = "Teleport to Selected Island/Gym",
    Callback = function()
        local position = Islands[SelectedIsland]
        if position then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Moved to " .. SelectedIsland,
                    Duration = 2
                })
            end
        end
    end
})

-- Initialize player list
task.spawn(function()
    task.wait(1)
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    if #playerNames > 0 then
        PlayerDropdown:Refresh(playerNames)
    end
end)

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    local currentPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(currentPlayers, p.Name)
        end
    end
    PlayerDropdown:Refresh(currentPlayers)
end)

Players.PlayerRemoving:Connect(function(player)
    task.wait(0.5)
    local currentPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(currentPlayers, p.Name)
        end
    end
    PlayerDropdown:Refresh(currentPlayers)
end)

WindUI:Notify({
    Title = "Script Loaded",
    Content = "Muscle Legends Hub is ready!",
    Duration = 3
})
