local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local local_player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = local_player.Character or local_player.CharacterAdded:Wait()

-- Settings
local PingBased = true
local PingBasedOffset = 0.05
local MinDistanceToParry = 0.3
local MaxDistanceToParry = 1.5
local ParryDelay = 0.015
local MinimumBallVelocity = 10
local ParryCooldown = 0.1
local lastParryTime = 0
local lastCheckTime = 0
local canParry = true
local isParrying = false
local lastBallVelocity = 0
local lastBallPosition = nil
local autoParryEnabled = false

-- NEW: Parry Speed/Sensitivity (higher = faster reaction, lower distance)
local ParrySpeed = 25 -- Default 25 (middle)

-- Visualizer Settings
local VisualizerEnabled = true
local VisualizerColor = Color3.fromRGB(0, 255, 255)
local VisualizerTransparency = 0.5
local VisualizerSize = 25 -- Manual orb size
local AutoScaleOrb = true -- Auto scale based on parry distance

-- Visual Distance Indicator (No Collision)
local Visualizer = Instance.new("Part")
Visualizer.Name = "ParryDistanceVisualizer"
Visualizer.Shape = Enum.PartType.Ball
Visualizer.Anchored = true
Visualizer.CanCollide = false
Visualizer.CanQuery = false
Visualizer.CanTouch = false
Visualizer.CastShadow = false
Visualizer.Material = Enum.Material.ForceField
Visualizer.Color = VisualizerColor
Visualizer.Transparency = VisualizerTransparency
Visualizer.Size = Vector3.new(VisualizerSize, VisualizerSize, VisualizerSize)
Visualizer.Parent = nil

-- Calculate dynamic parry distance based on speed setting
local function CalculateParryDistance(ballVelocity)
    local Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local PingAdjustment = Ping / 1000
    local DynamicPingOffset = PingAdjustment * 0.5
    
    -- Convert ParrySpeed (1-50) to multiplier
    -- Speed 1 = slow reaction (high distance), Speed 50 = instant (low distance)
    local SpeedMultiplier = (51 - ParrySpeed) / 25
    
    local DynamicParryDistance = (MinDistanceToParry + DynamicPingOffset) * SpeedMultiplier
    
    return math.clamp(DynamicParryDistance, MinDistanceToParry, MaxDistanceToParry)
end

-- Update visualizer
RunService.RenderStepped:Connect(function()
    if VisualizerEnabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        local size
        if AutoScaleOrb then
            -- Auto scale: higher parry speed = smaller orb (closer parry)
            local baseSize = 50 - ParrySpeed -- 49 to 1 range
            size = math.clamp(baseSize, 5, 50)
        else
            -- Manual size control
            size = VisualizerSize
        end
        
        Visualizer.Size = Vector3.new(size, size, size)
        Visualizer.Color = VisualizerColor
        Visualizer.Transparency = VisualizerTransparency
        Visualizer.CFrame = Character.HumanoidRootPart.CFrame
        Visualizer.Parent = Workspace
    else
        Visualizer.Parent = nil
    end
end)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
   Name = "blade ball script",
   Icon = 0,
   LoadingTitle = "best script",
   LoadingSubtitle = "by IKӨЯZ",
   Theme = "Default",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "blade ball"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = false
   },
   KeySystem = false
})

Rayfield:Notify({
   Title = "blade ball script",
   Content = "Enhanced - Parry Speed + Orb Control",
   Duration = 6.5,
   Image = 4483362458,
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      autoParryEnabled = Value
   end,
})

-- NEW: Parry Speed Slider (Reaction time)
Tab:CreateSlider({
   Name = "Parry Speed (Aim)",
   Range = {1, 50},
   Increment = 1,
   Suffix = "",
   CurrentValue = 25,
   Flag = "ParrySpeedSlider",
   Callback = function(Value)
      ParrySpeed = Value
      -- Higher speed = lower delay = faster reaction
      ParryDelay = 0.025 - (Value / 2000)
   end,
})

Tab:CreateSlider({
   Name = "Min Parry Distance",
   Range = {0.1, 2.0},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0.3,
   Flag = "MinDistanceSlider",
   Callback = function(Value)
      MinDistanceToParry = Value
   end,
})

Tab:CreateSlider({
   Name = "Max Parry Distance",
   Range = {0.5, 5.0},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 1.5,
   Flag = "MaxDistanceSlider",
   Callback = function(Value)
      MaxDistanceToParry = Value
   end,
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({
   Name = "Show Distance Orb",
   CurrentValue = true,
   Flag = "VisualizerToggle",
   Callback = function(Value)
      VisualizerEnabled = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Auto Scale Orb",
   CurrentValue = true,
   Flag = "AutoScaleToggle",
   Callback = function(Value)
      AutoScaleOrb = Value
   end,
})

-- NEW: Manual Orb Size Slider
VisualTab:CreateSlider({
   Name = "Orb Size",
   Range = {5, 100},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 25,
   Flag = "OrbSizeSlider",
   Callback = function(Value)
      VisualizerSize = Value
   end,
})

VisualTab:CreateColorPicker({
   Name = "Orb Color",
   Color = VisualizerColor,
   Flag = "VisualizerColor",
   Callback = function(Value)
      VisualizerColor = Value
   end,
})

VisualTab:CreateSlider({
   Name = "Orb Transparency",
   Range = {0, 0.9},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0.5,
   Flag = "VisualizerTransparency",
   Callback = function(Value)
      VisualizerTransparency = Value
   end,
})

local function FindBall()
    for _, ball in pairs(workspace:WaitForChild("Balls"):GetChildren()) do
        if ball:GetAttribute("realBall") == true then
            return ball
        end
    end
end

local function IsTheTarget()
    return local_player.Character and local_player.Character:FindFirstChild("Highlight")
end

local function DetectBallCurve(ball)
    local ballPosition = ball.Position
    local ballVelocity = ball.AssemblyLinearVelocity
    if lastBallPosition then
        local deltaPos = ballPosition - lastBallPosition
        local velocityDirection = ballVelocity.Unit
        local angle = math.acos(velocityDirection:Dot(deltaPos.Unit)) * (180 / math.pi)
        if angle > 10 then
            return true
        end
    end
    lastBallPosition = ballPosition
    lastBallVelocity = ballVelocity
    return false
end

local function PerformParry()
    if tick() - lastParryTime >= ParryCooldown and canParry and not isParrying then
        isParrying = true
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        lastParryTime = tick()
        task.delay(ParryCooldown, function()
            canParry = true
            isParrying = false
        end)
    end
end

-- Handle character respawn
local_player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
end)

-- IMPROVED: Better parry logic
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if autoParryEnabled and tick() - lastCheckTime >= ParryDelay then
            local Ball = FindBall()
            if Ball then
                local BallPosition = Ball.Position
                local BallVelocityVec = Ball.AssemblyLinearVelocity
                local BallVelocity = BallVelocityVec.Magnitude
                local Distance = local_player:DistanceFromCharacter(BallPosition)
                
                -- Calculate dynamic distance based on speed setting
                local DynamicParryDistance = CalculateParryDistance(BallVelocity)
                
                -- Time to impact (more accurate)
                local TimeToImpact = Distance / math.max(BallVelocity, 0.1)
                
                local ballIsCurved = DetectBallCurve(Ball)
                
                -- IMPROVED: Stricter timing for better accuracy
                if BallVelocity > MinimumBallVelocity and TimeToImpact <= DynamicParryDistance and IsTheTarget() then
                    if ballIsCurved then
                        -- Slight delay for curved balls
                        task.delay(0.008, PerformParry)
                    else
                        PerformParry()
                    end
                end
            end
            lastCheckTime = tick()
        end
    end)
end)
