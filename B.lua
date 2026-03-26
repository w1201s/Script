--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--// UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ULTIMATE SYSTEM",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Fixed",
    ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Main", 4483362458)

--// VARIABLES
local AutoFarm = false
local AutoActivate = false
local LobbyMode = false

local TargetNPC = true
local TargetPlayer = true
local TargetSelf = false

local MaxDistance = 100
local Mode = "Behind"
local Distance = 5
local MoveSpeed = 300
local OrbitSpeed = 0.05

local CurrentTarget = nil
local TargetTime = 0
local StayDuration = 2

local oldGravity = Workspace.Gravity
local angle = 0

-- POSITIONS
local LobbyTweenPos = Vector3.new(-36, 280, 110)
local LobbySafePos = Vector3.new(-36, 300, 110)
local NoTargetPos = Vector3.new(-32, 70, 242)

--// FUNCTIONS

local function getTool()
    local char = player.Character
    if not char then return end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then
            return v
        end
    end
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- 🔥 VALIDATE TARGET (FIX BUG)
local function isTargetValid(target, root)
    if not target or not target.Parent then return false end

    local hum = target.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if target.Position.Y <= -50 then return false end
    if LobbyMode and target.Position.Y < 280 then return false end

    local dist = (target.Position - root.Position).Magnitude
    if dist > MaxDistance then return false end

    return true
end

local function getAllTargets()
    local list = {}

    local char = player.Character
    if not char then return list end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return list end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name ~= "R6n_w1201s" then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                if hrp.Position.Y <= -50 then continue end
                if LobbyMode and hrp.Position.Y < 280 then continue end

                local dist = (hrp.Position - root.Position).Magnitude
                if dist > MaxDistance then continue end

                local isPlayer = isPlayerCharacter(obj)

                if isPlayer then
                    if obj == char and not TargetSelf then continue end
                    if obj ~= char and not TargetPlayer then continue end
                else
                    if not TargetNPC then continue end
                end

                table.insert(list, hrp)
            end
        end
    end

    return list
end

local function getPosition(target)
    if Mode == "Behind" then
        return target.CFrame * CFrame.new(0, 0, Distance)
    elseif Mode == "Above" then
        return target.CFrame * CFrame.new(0, Distance, 0)
    elseif Mode == "Under" then
        return target.CFrame * CFrame.new(0, -Distance, 0)
    elseif Mode == "Orbit" then
        angle += OrbitSpeed
        return target.CFrame * CFrame.new(math.cos(angle)*Distance, 0, math.sin(angle)*Distance)
    end
end

-- STABLE SPEED
local function tweenTo(root, cf)
    local dist = (root.Position - cf.Position).Magnitude
    local time = dist / MoveSpeed

    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = cf
    })
    tween:Play()
end

--// LOOP
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if AutoFarm then
        Workspace.Gravity = 0

        -- LOBBY
        if LobbyMode then
            if (root.Position - LobbySafePos).Magnitude > 5 then
                tweenTo(root, CFrame.new(LobbyTweenPos))
                return
            end

            if root.Position.Y < 290 then
                root.CFrame = CFrame.new(LobbySafePos)
                return
            end
        end

        -- 🔥 FIX: validate target every frame
        if not isTargetValid(CurrentTarget, root) then
            CurrentTarget = nil
        end

        -- SELECT TARGET
        if not CurrentTarget or tick() - TargetTime > StayDuration then
            local targets = getAllTargets()

            if #targets > 0 then
                CurrentTarget = targets[math.random(1, #targets)]
                TargetTime = tick()
            else
                CurrentTarget = nil
            end
        end

        -- NO TARGET
        if not CurrentTarget then
            tweenTo(root, CFrame.new(NoTargetPos))
            return
        end

        -- MOVE
        local pos = getPosition(CurrentTarget)
        if pos then
            tweenTo(root, pos)
        end

    else
        Workspace.Gravity = oldGravity
    end

    -- AUTO ACTIVATE
    if AutoActivate then
        local tool = getTool()
        if tool then
            tool:Activate()
        end
    end
end)

--// UI

Tab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v
        if not v then Workspace.Gravity = oldGravity end
    end
})

Tab:CreateToggle({
    Name = "Auto Activate Tool",
    CurrentValue = false,
    Callback = function(v)
        AutoActivate = v
    end
})

Tab:CreateToggle({
    Name = "Lobby Mode",
    CurrentValue = false,
    Callback = function(v)
        LobbyMode = v

        if not v then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(root.Position.X, 280, root.Position.Z)
                end
            end
        end
    end
})

Tab:CreateToggle({
    Name = "Target NPC",
    CurrentValue = true,
    Callback = function(v) TargetNPC = v end
})

Tab:CreateToggle({
    Name = "Target Player",
    CurrentValue = true,
    Callback = function(v) TargetPlayer = v end
})

Tab:CreateToggle({
    Name = "Target Self",
    CurrentValue = false,
    Callback = function(v) TargetSelf = v end
})

Tab:CreateSlider({
    Name = "Max Distance",
    Range = {1, 10000},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v) MaxDistance = v end
})

Tab:CreateDropdown({
    Name = "Position Mode",
    Options = {"Behind", "Above", "Under", "Orbit"},
    CurrentOption = "Behind",
    Callback = function(opt) Mode = opt end
})

Tab:CreateSlider({
    Name = "Distance",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) Distance = v end
})

Tab:CreateSlider({
    Name = "Move Speed",
    Range = {10, 1000},
    Increment = 10,
    CurrentValue = 300,
    Callback = function(v) MoveSpeed = v end
})

Tab:CreateSlider({
    Name = "Orbit Speed",
    Range = {0.01, 0.2},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(v) OrbitSpeed = v end
})
