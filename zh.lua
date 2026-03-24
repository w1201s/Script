local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Ultra Farm (Realtime)",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local AutoFarm = false
local Mode = "Behind"
local Distance = 5
local ToolSpam = false
local TargetType = "NPC" -- "Player", "NPC", or "Both"

-- Store original gravity
local OriginalGravity = Workspace.Gravity

-- OFFSET
local function GetOffset(cf)
    if Mode == "Behind" then
        return cf * CFrame.new(0, 0, Distance)
    elseif Mode == "Under" then
        return cf * CFrame.new(0, -Distance, 0)
    elseif Mode == "Above" then
        return cf * CFrame.new(0, Distance, 0)
    end
end

-- 🔥 TOOL SPAM (IMPROVED)
task.spawn(function()
    while true do
        task.wait(0.05)
        if ToolSpam then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function()
                                if tool.Parent == char then
                                    tool:Activate()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 🔥 CHECK IF MODEL IS VALID TARGET
local function IsValidTarget(model)
    -- Must be a model with humanoid
    if not model or not model:IsA("Model") then return false end
    
    -- Skip self
    if model == LocalPlayer.Character then return false end
    if model.Name == LocalPlayer.Name then return false end
    
    -- Check for humanoid and HRP
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return false end
    if hum.Health <= 0 then return false end
    if hrp.Position.Y <= -50 then return false end
    
    -- Check target type
    local player = Players:GetPlayerFromCharacter(model)
    
    if TargetType == "Player" then
        return player ~= nil -- Must be a player
    elseif TargetType == "NPC" then
        return player == nil -- Must NOT be a player (NPC)
    elseif TargetType == "Both" then
        return true -- Any valid humanoid
    end
    
    return false
end

-- 🔥 FIND TARGET
local function GetTarget()
    -- First check player characters (more priority)
    if TargetType == "Player" or TargetType == "Both" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char and IsValidTarget(char) then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        return hum, hrp
                    end
                end
            end
        end
    end
    
    -- Then check workspace for NPCs
    if TargetType == "NPC" or TargetType == "Both" then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name ~= "R6n_w1201s" then
                if IsValidTarget(v) then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        -- Double check it's not a player if NPC mode
                        if TargetType == "NPC" and Players:GetPlayerFromCharacter(v) then
                            continue
                        end
                        return hum, hrp
                    end
                end
            end
        end
    end
    
    return nil, nil
end

-- 🚀 REALTIME MOVE (FIXED)
local CurrentTarget = nil
local CurrentHRP = nil

RunService.Heartbeat:Connect(function()
    if not AutoFarm then 
        CurrentTarget = nil
        CurrentHRP = nil
        return 
    end

    local char = LocalPlayer.Character
    if not char then 
        CurrentTarget = nil
        CurrentHRP = nil
        return 
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then 
        CurrentTarget = nil
        CurrentHRP = nil
        return 
    end

    -- Get new target if current is invalid or dead
    if not CurrentTarget or not CurrentHRP or CurrentTarget.Health <= 0 or CurrentHRP.Position.Y <= -50 then
        local hum, hrp = GetTarget()
        if hum and hrp then
            CurrentTarget = hum
            CurrentHRP = hrp
        else
            CurrentTarget = nil
            CurrentHRP = nil
            return
        end
    end

    -- 🎯 Update position every frame
    if CurrentHRP and CurrentHRP.Parent then
        local targetCF = GetOffset(CurrentHRP.CFrame)
        
        -- 💨 Instant teleport (no lerp delay)
        root.CFrame = targetCF
        
        -- Reset velocity to prevent falling
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    else
        -- Target lost, clear it
        CurrentTarget = nil
        CurrentHRP = nil
    end
end)

-- UI
Tab:CreateToggle({
    Name = "Auto Farm (Realtime)",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v
        -- 🌍 GRAVITY CONTROL
        if AutoFarm then
            Workspace.Gravity = 0
            OriginalGravity = OriginalGravity ~= 0 and OriginalGravity or 196.2
        else
            Workspace.Gravity = OriginalGravity
            CurrentTarget = nil
            CurrentHRP = nil
        end
    end,
})

Tab:CreateDropdown({
    Name = "Target Type",
    Options = {"NPC", "Player", "Both"},
    CurrentOption = "NPC",
    Callback = function(v)
        TargetType = v
        -- Reset target when changing type
        CurrentTarget = nil
        CurrentHRP = nil
    end,
})

Tab:CreateDropdown({
    Name = "Position Mode",
    Options = {"Behind", "Under", "Above"},
    CurrentOption = "Behind",
    Callback = function(v)
        Mode = v
    end,
})

Tab:CreateSlider({
    Name = "Distance",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        Distance = v
    end,
})

Tab:CreateToggle({
    Name = "Auto Tool Activate",
    CurrentValue = false,
    Callback = function(v)
        ToolSpam = v
    end,
})

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if AutoFarm then
        Workspace.Gravity = OriginalGravity
    end
    CurrentTarget = nil
    CurrentHRP = nil
end)

-- Reset on death
LocalPlayer.CharacterAdded:Connect(function()
    CurrentTarget = nil
    CurrentHRP = nil
    if AutoFarm then
        Workspace.Gravity = 0
    end
end)
