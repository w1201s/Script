-- Wind UI Fixed Script for Muscle Legends
-- ใช้ loadstring ที่ถูกต้อง
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- สร้าง Window
local Window = WindUI:CreateWindow({
    Title = "Muscle Legends Hub",
    Icon = "dumbbell",
    Author = "Fixed Script",
    Size = UDim2.fromOffset(600, 450),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = false
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Variables
local AutoRep = false
local AutoDurability = false
local AutoChest = false
local AutoKill = false
local SelectedStyle = "Handstands"
local SelectedRock = "Tiny Rock (0+)"
local SelectedIsland = "Tiny Island"
local SelectedPlayer = nil

-- Rock Data
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

-- Function to Equip Style (ต้องหาวิธี equip ที่ถูกต้อง)
local function EquipStyle(styleName)
    -- วิธีที่ 1: ใช้ remote event ถ้ามี
    local styleRemote = ReplicatedStorage:FindFirstChild("styleEvent") or ReplicatedStorage:FindFirstChild("equipStyle")
    if styleRemote then
        styleRemote:FireServer(styleName)
    end
    
    -- วิธีที่ 2: หา tool ใน backpack และ equip
    local tool = LocalPlayer.Backpack:FindFirstChild(styleName)
    if tool then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

-- Function to Punch (กด E หรือใช้ remote)
local function Punch()
    -- วิธีที่ 1: ใช้ remote ที่ถูกต้อง
    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
    if muscleEvent then
        muscleEvent:FireServer("punch", "leftHand")
    end
    
    -- วิธีที่ 2: กด E ถ้า remote ไม่ work
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Function to Rep (กดตาม style ที่เลือก)
local function DoRep()
    if SelectedStyle == "Handstands" then
        -- กด Q สำหรับ Handstands
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    elseif SelectedStyle == "Pushup" then
        -- กด R สำหรับ Pushup
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    elseif SelectedStyle == "Situp" then
        -- กด T สำหรับ Situp
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
    elseif SelectedStyle == "Weight" then
        -- กด Y สำหรับ Weight
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
    end
    
    -- หรือใช้ remote ถ้ามี
    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
    if muscleEvent then
        muscleEvent:FireServer("rep")
    end
end

-- Auto Rep Loop
task.spawn(function()
    while true do
        if AutoRep then
            DoRep()
        end
        task.wait(0.1) -- ลด delay ให้เร็วขึ้น
    end
end)

-- Auto Durability Loop (แก้ให้หันหน้าเข้าหาหิน)
task.spawn(function()
    while true do
        if AutoDurability and Rocks[SelectedRock] then
            local rockData = Rocks[SelectedRock]
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- TP ไปที่หิน + หันหน้าเข้าหาหิน
                local rockPosition = rockData.Position
                local lookAtPosition = rockPosition + Vector3.new(0, 0, 5) -- หันหน้าเข้าหาหิน
                character.HumanoidRootPart.CFrame = CFrame.lookAt(rockPosition + Vector3.new(0, 5, -5), rockPosition)
                
                task.wait(0)
                
                -- ต่อย
                Punch()
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Chest Loop
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
            task.wait(0.5)
        end
    end
end)

-- Auto Kill Variables
local KillPlatform = nil

-- Create Kill Platform
local function CreateKillPlatform()
    if KillPlatform then KillPlatform:Destroy() end
    
    local platform = Instance.new("Part")
    platform.Name = "KillPlatform"
    platform.Size = Vector3.new(100, 10, 100)
    platform.Position = Vector3.new(50000, 50000, 50000)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Parent = workspace
    KillPlatform = platform
    return platform
end

-- Auto Kill Loop
task.spawn(function()
    CreateKillPlatform()
    
    while true do
        if AutoKill and KillPlatform then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local localChar = LocalPlayer.Character
                    
                    if targetHRP and localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        -- TP เป้าหมายไปบนแพลตฟอร์ม
                        targetHRP.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(0, 15, 0))
                        targetHRP.Velocity = Vector3.new(0, 0, 0) -- รีเซ็ตความเร็ว
                        
                        -- TP ตัวเองไปใกล้ๆ
                        localChar.HumanoidRootPart.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(20, 15, 0))
                        
                        -- ต่อย
                        Punch()
                        
                        task.wait(0.2)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ==================== MAIN TAB ====================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
    Selected = true
})

MainTab:Section({Title = "UI Setup"})

-- Style Dropdown
local StyleDropdown = MainTab:Dropdown({
    Title = "Select Style",
    Multi = false,
    Value = SelectedStyle,
    Options = Styles,
    Callback = function(value)
        SelectedStyle = value
        EquipStyle(value)
        print("Selected Style:", value)
    end
})

-- Auto Rep Toggle
MainTab:Toggle({
    Title = "Auto Rep Loop (No Delay)",
    Default = false,
    Callback = function(value)
        AutoRep = value
        if value then
            EquipStyle(SelectedStyle)
        end
    end
})

MainTab:Section({Title = "Durability Farm"})

-- Rock Dropdown
local RockDropdown = MainTab:Dropdown({
    Title = "Select Rock",
    Multi = false,
    Value = SelectedRock,
    Options = {
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
    Callback = function(value)
        SelectedRock = value
        print("Selected Rock:", value)
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

MainTab:Section({Title = "Auto Redeem Chest"})

-- Auto Chest Toggle
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
    Title = "Platform: 50K studs away",
    Text = "Safe killing platform"
})

AutoKillTab:Button({
    Title = "Create/Reset Platform",
    Callback = function()
        CreateKillPlatform()
        Window:Notify({
            Title = "Success",
            Content = "Kill platform created!",
            Duration = 3
        })
    end
})

AutoKillTab:Toggle({
    Title = "Auto Kill Players",
    Default = false,
    Callback = function(value)
        AutoKill = value
        if value then
            CreateKillPlatform()
        end
    end
})

-- ==================== TELEPORT TAB ====================
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin"
})

TeleportTab:Section({Title = "Teleport Options"})

TeleportTab:Button({
    Title = "TP to Kill Platform",
    Callback = function()
        if KillPlatform then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(KillPlatform.Position + Vector3.new(0, 15, 0))
            end
        else
            Window:Notify({
                Title = "Error",
                Content = "Create platform first!",
                Duration = 3
            })
        end
    end
})

TeleportTab:Section({Title = "Islands & Gyms"})

local IslandDropdown = TeleportTab:Dropdown({
    Title = "Select Location",
    Multi = false,
    Value = SelectedIsland,
    Options = {
        "Tiny Island",
        "Legends Beach",
        "Frost Gym",
        "Mythical Gym",
        "Eternal Gym",
        "Legends Gym",
        "Muscle King Gym",
        "Jungle Gym"
    },
    Callback = function(value)
        SelectedIsland = value
    end
})

TeleportTab:Button({
    Title = "Teleport to Selected",
    Callback = function()
        local position = Islands[SelectedIsland]
        if position then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                Window:Notify({
                    Title = "Teleported",
                    Content = "Moved to " .. SelectedIsland,
                    Duration = 2
                })
            end
        end
    end
})

-- Notify when loaded
Window:Notify({
    Title = "Script Loaded",
    Content = "Muscle Legends Hub Ready!",
    Duration = 3
})

print("Script Loaded Successfully!")
