--[[
    Blade Ball Auto Parry - Mobile Edition (FIXED)
    Proper Touch Simulation + Perfect Ball Tracking
]]

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Balls = Workspace:WaitForChild("Balls", 9e9)

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Settings
local Settings = {
    Enabled = false,
    Distance = 10,
    VisualizerEnabled = true,
    VisualizerColor = Color3.fromRGB(0, 255, 255),
    VisualizerTransparency = 0.5,
    ParryCooldown = 0.1
}

-- Store active connections
local ActiveConnections = {}
local LastParryTime = 0

-- Visual Distance Indicator
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
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Mobile Version",
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

-- FIXED Mobile Parry - Uses proper touch simulation
local function Parry()
    local CurrentTime = tick()
    if CurrentTime - LastParryTime < Settings.ParryCooldown then
        return
    end
    LastParryTime = CurrentTime
    
    -- Method 1: Try to find and click the parry button directly
    local success = pcall(function()
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local Hotbar = PlayerGui:WaitForChild("Hotbar")
        local BlockButton = Hotbar:WaitForChild("Block")
        
        -- Fire the button's activated signal
        if BlockButton and BlockButton:IsA("GuiButton") then
            -- Simulate touch at button position
            local absPos = BlockButton.AbsolutePosition
            local absSize = BlockButton.AbsoluteSize
            local centerX = absPos.X + (absSize.X / 2)
            local centerY = absPos.Y + (absSize.Y / 2)
            
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
        end
    end)
    
    -- Method 2: If button method fails, use screen center (fallback)
    if not success then
        local screenSize = Workspace.CurrentCamera.ViewportSize
        local centerX = screenSize.X / 2
        local centerY = screenSize.Y / 2 + 100 -- Slightly lower than center (where parry button usually is)
        
        VirtualInputManager:SendTouchEvent(1, 0, centerX, centerY) -- Touch begin
        task.wait(0.05)
        VirtualInputManager:SendTouchEvent(1, 2, centerX, centerY) -- Touch end
    end
end

-- Alternative: Use keypress for mobile (some executors support this)
local function ParryKey()
    local CurrentTime = tick()
    if CurrentTime - LastParryTime < Settings.ParryCooldown then
        return
    end
    LastParryTime = CurrentTime
    
    -- Try F key first (works on some mobile executors with keyboard emulation)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- Ball Tracking System - FIXED
Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    local OldPosition = Ball.Position
    local OldTick = tick()
    local HasParried = false
    
    local Connection
    
    Connection = RunService.Heartbeat:Connect(function()
        -- Check if enabled FIRST
        if not Settings.Enabled then
            HasParried = false
            return
        end
        
        -- Check if ball exists
        if not Ball or not Ball.Parent then
            return
        end
        
        -- Check if we're target
        if not IsTarget() then
            HasParried = false
            return
        end
        
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        if not HRP then
            return
        end
        
        -- Get ball velocity from zoomies if available
        local Zoomies = Ball:FindFirstChild("zoomies")
        local Velocity = Vector3.zero
        
        if Zoomies and Zoomies:IsA("LinearVelocity") then
            Velocity = Zoomies.VectorVelocity
        else
            -- Fallback: calculate manually
            local CurrentPosition = Ball.Position
            Velocity = (CurrentPosition - OldPosition) / (tick() - OldTick)
            OldPosition = CurrentPosition
            OldTick = tick()
        end
        
        local Distance = (Ball.Position - HRP.Position).Magnitude
        local Speed = Velocity.Magnitude
        
        -- Prevent division by zero
        if Speed <= 0 then
            return
        end
        
        -- Calculate time to impact
        local TimeToImpact = Distance / Speed
        
        -- DEBUG: You can remove this after testing
        -- print(string.format("Distance: %.2f, Speed: %.2f, Time: %.2f, Threshold: %.2f", Distance, Speed, TimeToImpact, Settings.Distance))
        
        -- Parry when ball is close enough
        if TimeToImpact <= Settings.Distance and not HasParried then
            Parry() -- Try button method first
            -- ParryKey() -- Uncomment to try F-key method instead
            HasParried = true
            
            task.delay(Settings.ParryCooldown, function()
                HasParried = false
            end)
        end
    end)
    
    ActiveConnections[Ball] = Connection
    
    -- Cleanup
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

-- Notification
Rayfield:Notify({
    Title = "Auto Parry Loaded",
    Content = "Mobile version ready. Make sure parry button is visible!",
    Duration = 6.5,
    Image = 4483362458,
})
