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

-- 🔥 TOOL SPAM (IMPROVED - Checks if tool is equipped)
task.spawn(function()
    while true do
        task.wait(0.05) -- Small delay to prevent lag
        if ToolSpam then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function()
                                -- Check if tool is equipped before activating
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

-- 🔥 FIND TARGET
local function GetTarget()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name ~= LocalPlayer.Name and v.Name ~= "R6n_w1201s" then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 and hrp.Position.Y > -50 then
                -- Make sure it's not a player (optional)
                local isPlayer = Players:GetPlayerFromCharacter(v)
                if not isPlayer then
                    return hum, hrp
                end
            end
        end
    end
end

-- 🚀 REALTIME MOVE (NO DELAY)
RunService.Heartbeat:Connect(function()
    if not AutoFarm then return end

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local hum, hrp = GetTarget()
    if not hum or not hrp then return end

    -- ❌ Skip if target dead or fell
    if hum.Health <= 0 or hrp.Position.Y <= -50 then return end

    -- 🎯 Update position every frame
    local targetCF = GetOffset(hrp.CFrame)

    -- 💨 Realtime movement (no tween)
    root.CFrame = root.CFrame:Lerp(targetCF, 0.3)

    -- Set velocity to 0 to prevent falling when gravity is 0
    local vel = root:FindFirstChild("Velocity")
    if vel then
        vel.Velocity = Vector3.new(0, 0, 0)
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
        else
            Workspace.Gravity = OriginalGravity
        end
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

-- Cleanup on script destroy (optional safety)
LocalPlayer.CharacterRemoving:Connect(function()
    if AutoFarm then
        Workspace.Gravity = OriginalGravity
    end
end)
