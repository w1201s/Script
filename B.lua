local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local local_player = Players.LocalPlayer
local Character = local_player.Character or local_player.CharacterAdded:Wait()

-- Settings
local autoParryEnabled = false
local orbSize = 25
local VisualizerEnabled = true
local VisualizerColor = Color3.fromRGB(0, 255, 255)
local VisualizerTransparency = 0.5

-- AI System Data (PERSISTS through death)
local AI = {
    currentThreshold = 0.4,
    consecutiveMisses = 0,
    consecutiveHits = 0,
    isLearning = true
}

-- Visual Orb
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
Visualizer.Size = Vector3.new(orbSize, orbSize, orbSize)
Visualizer.Parent = nil

-- AI: Adjust parry timing (LIMITED change per adjustment)
local function AI_Learn(success, ballSpeed)
    if not AI.isLearning then return end

    -- Max change per adjustment: 0.05 (perfect amount)
    local maxChange = 0.05

    if success then
        AI.consecutiveHits = math.min(AI.consecutiveHits + 1, 5)
        AI.consecutiveMisses = 0

        -- Only adjust after 3 consecutive hits
        if AI.consecutiveHits >= 3 then
            -- Try to parry closer (more precise) - decrease threshold
            local change = math.min(0.02, maxChange)
            AI.currentThreshold = math.max(0.2, AI.currentThreshold - change)
            AI.consecutiveHits = 0 -- Reset after adjustment
        end
    else
        AI.consecutiveMisses = math.min(AI.consecutiveMisses + 1, 3)
        AI.consecutiveHits = 0

        -- Adjust immediately on miss
        if AI.consecutiveMisses >= 1 then
            -- Parry earlier (safer) - increase threshold
            local change = math.min(0.05, maxChange)
            AI.currentThreshold = math.min(1.0, AI.currentThreshold + change)
        end
    end

    -- Speed adjustment (subtle)
    if ballSpeed > 150 then
        AI.currentThreshold = math.min(1.0, AI.currentThreshold + 0.02)
    elseif ballSpeed < 30 then
        AI.currentThreshold = math.max(0.2, AI.currentThreshold - 0.01)
    end

    -- Update orb size smoothly (30% transition per frame)
    local targetSize = AI.currentThreshold * 60
    orbSize = orbSize + (targetSize - orbSize) * 0.3
end

-- Update visualizer
RunService.RenderStepped:Connect(function()
    if VisualizerEnabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        Visualizer.Size = Vector3.new(orbSize, orbSize, orbSize)
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
   Name = "Blade Ball AI",
   Icon = 0,
   LoadingTitle = "AI Auto Parry",
   LoadingSubtitle = "Self-Learning System",
   Theme = "Default",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "blade ball ai"
   },
   KeySystem = false
})

Rayfield:Notify({
   Title = "AI System Loaded",
   Content = "Auto-adjusting parry timing enabled",
   Duration = 6.5,
   Image = 4483362458,
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
   Name = "Auto Parry (AI)",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      autoParryEnabled = Value
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

VisualTab:CreateSlider({
   Name = "Orb Size Override",
   Range = {5, 100},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 25,
   Flag = "OrbSizeSlider",
   Callback = function(Value)
      orbSize = Value
      AI.currentThreshold = Value / 60
      AI.isLearning = false -- Disable AI when manual override
   end,
})

VisualTab:CreateToggle({
   Name = "AI Learning",
   CurrentValue = true,
   Flag = "AILearningToggle",
   Callback = function(Value)
      AI.isLearning = Value
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
    return nil
end

-- FIXED: Proper target check
local function IsTheTarget()
    local char = local_player.Character
    if not char then return false end

    -- Check for Highlight (target indicator)
    local highlight = char:FindFirstChild("Highlight")
    if not highlight then return false end

    return true
end

local lastParryTime = 0
local hasParried = false
local ballWhenParried = nil

local function PerformParry()
    if tick() - lastParryTime >= 0.15 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        lastParryTime = tick()
        return true
    end
    return false
end

-- FIXED: Handle character respawn properly
local_player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    -- Don't reset AI data - keep learning across deaths
    hasParried = false
    ballWhenParried = nil
end)

-- Main AI Loop
local lastCheckTime = 0
local ballBeforeParry = nil
local velocityBeforeParry = nil
local lastBallDistance = math.huge

RunService.Heartbeat:Connect(function()
    if not autoParryEnabled then return end
    if tick() - lastCheckTime < 0.01 then return end

    local Ball = FindBall()
    if not Ball then 
        hasParried = false
        ballBeforeParry = nil
        lastBallDistance = math.huge
        return 
    end

    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local BallVelocity = Ball.AssemblyLinearVelocity
    local BallSpeed = BallVelocity.Magnitude
    local Distance = (Ball.Position - HRP.Position).Magnitude

    -- Track if ball is getting closer or further
    local gettingCloser = Distance < lastBallDistance
    lastBallDistance = Distance

    -- FIXED: Check if we are ACTUALLY the target
    local isTarget = IsTheTarget()

    -- Reset parry state if not target or ball is too far
    if not isTarget then
        if hasParried and ballBeforeParry then
            -- Check if parry was successful (ball bounced)
            local currentDist = (ballBeforeParry.Position - HRP.Position).Magnitude
            if currentDist > Distance + 10 then -- Ball moved away
                AI_Learn(true, BallSpeed)
            else
                AI_Learn(false, BallSpeed)
            end
        end

        hasParried = false
        ballBeforeParry = nil
        velocityBeforeParry = nil
        lastCheckTime = tick()
        return
    end

    -- FIXED: Only parry if ball is actually close (within orb)
    local orbRadius = orbSize / 2
    if Distance > orbRadius + 5 then -- Give 5 stud buffer
        hasParried = false
        lastCheckTime = tick()
        return
    end

    -- AI: Calculate time to impact
    local TimeToImpact = Distance / math.max(BallSpeed, 1)

    -- Only parry if ball is approaching and within threshold
    if not hasParried and gettingCloser and TimeToImpact <= AI.currentThreshold and BallSpeed > 5 then
        if PerformParry() then
            hasParried = true
            ballBeforeParry = Ball
            velocityBeforeParry = BallVelocity
        end
    end

    lastCheckTime = tick()
end)
