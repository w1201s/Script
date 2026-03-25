--[[
    Blade Ball Auto Parry - Rayfield Edition
    Fixed Toggle + New Parry System + Orb Visualizer Toggle
]]

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Balls = Workspace:WaitForChild("Balls", 9e9)

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Settings
local Settings = {
    Enabled = false,
    Distance = 10,
    VisualizerEnabled = true, -- Master toggle for orb visibility
    VisualizerColor = Color3.fromRGB(0, 255, 255),
    VisualizerTransparency = 0.5
}

-- Store active connections to manage them
local ActiveConnections = {}

-- Visual Distance Indicator (No Collision, No Physics)
local Visualizer = Instance.new("Part")
Visualizer.Name = "ParryDistanceVisualizer"
Visualizer.Shape = Enum.PartType.Ball
Visualizer.Anchored = true
Visualizer.CanCollide = false
Visualizer.CanQuery = false
Visualizer.CanTouch = false
Visualizer.CastShadow = false
Visualizer.Material = Enum.Material.ForceField
Visualizer.Color = Settings.VisualizerColor
Visualizer.Transparency = Settings.VisualizerTransparency
Visualizer.Size = Vector3.new(Settings.Distance * 2, Settings.Distance * 2, Settings.Distance * 2)
Visualizer.Parent = nil

-- Update visualizer
RunService.RenderStepped:Connect(function()
    if Settings.VisualizerEnabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        Visualizer.Size = Vector3.new(Settings.Distance * 2, Settings.Distance * 2, Settings.Distance * 2)
        Visualizer.Color = Settings.VisualizerColor
        Visualizer.Transparency = Settings.VisualizerTransparency
        Visualizer.CFrame = Character.HumanoidRootPart.CFrame
        Visualizer.Parent = Workspace
    else
        Visualizer.Parent = nil
    end
end)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Blade Ball Auto Parry",
    LoadingTitle = "Loading Auto Parry...",
    LoadingSubtitle = "by System",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BladeBallParry",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParryToggle",
    Callback = function(Value)
        Settings.Enabled = Value
    end
})

MainTab:CreateSlider({
    Name = "Parry Distance",
    Range = {1, 50},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 10,
    Flag = "DistanceSlider",
    Callback = function(Value)
        Settings.Distance = Value
    end
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- Toggle to show/hide the orb
VisualTab:CreateToggle({
    Name = "Show Distance Orb",
    CurrentValue = true,
    Flag = "VisualizerToggle",
    Callback = function(Value)
        Settings.VisualizerEnabled = Value
    end
})

VisualTab:CreateColorPicker({
    Name = "Orb Color",
    Color = Settings.VisualizerColor,
    Flag = "VisualizerColor",
    Callback = function(Value)
        Settings.VisualizerColor = Value
    end
})

VisualTab:CreateSlider({
    Name = "Orb Transparency",
    Range = {0, 0.9},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "VisualizerTransparency",
    Callback = function(Value)
        Settings.VisualizerTransparency = Value
    end
})

-- Functions
local function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
    return false
end

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Ball Tracking System
Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    local OldPosition = Ball.Position
    local OldTick = tick()
    
    local Connection
    
    Connection = Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not Settings.Enabled then
            return
        end
        
        if not IsTarget() then
            return
        end
        
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        if not HRP then
            return
        end
        
        local Distance = (Ball.Position - HRP.Position).Magnitude
        local Velocity = (OldPosition - Ball.Position).Magnitude
        
        if Velocity <= 0 then
            return
        end
        
        local TimeToImpact = Distance / Velocity
        
        if TimeToImpact <= Settings.Distance then
            Parry()
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
    
    ActiveConnections[Ball] = Connection
    
    Ball.AncestryChanged:Connect(function()
        if not Ball:IsDescendantOf(Workspace) then
            if Connection then
                Connection:Disconnect()
                ActiveConnections[Ball] = nil
            end
        end
    end)
end)

Balls.ChildRemoved:Connect(function(Ball)
    if ActiveConnections[Ball] then
        ActiveConnections[Ball]:Disconnect()
        ActiveConnections[Ball] = nil
    end
end)

Player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
end)

Rayfield:LoadConfiguration()
