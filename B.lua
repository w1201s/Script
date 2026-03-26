--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--// UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ULTIMATE SYSTEM FINAL REAL",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "No Bug Version",
    ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Main", 4483362458)

--// VARIABLES
local AutoFarm = false
local AutoActivate = false
local LobbyMode = false
local AntiVoid = false

local TargetNPC = true
local TargetPlayer = true
local TargetSelf = false

local Mode = "Behind"
local Distance = 5
local MoveSpeed = 300

local CurrentTarget = nil
local TargetTime = 0
local StayDuration = 2

local oldGravity = Workspace.Gravity
local VoidPart = nil

local currentTween = nil
local lastGoal = nil

-- POSITIONS
local LobbyTweenPos = Vector3.new(-36, 280, 110)
local LobbySafePos = Vector3.new(-36, 300, 110)
local NoTargetPos = Vector3.new(-32, 70, 242)

--// FUNCTIONS

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart")
end

local function getHumanoid(model)
    return model:FindFirstChildOfClass("Humanoid")
end

local function getTool()
    local char = player.Character
    if not char then return end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then return v end
    end
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- VALID TARGET
local function isTargetValid(target)
    if not target or not target.Parent then return false end

    local hum = target.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if target.Position.Y <= -50 then return false end
    if LobbyMode and target.Position.Y < 280 then return false end

    return true
end

-- GET TARGETS
local function getAllTargets()
    local list = {}

    local char = player.Character
    if not char then return list end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name ~= "R6n_w1201s" then

            local root = getRoot(obj)
            local hum = getHumanoid(obj)

            if not hum or hum.Health <= 0 then continue end

            if root then
                if root.Position.Y <= -50 then continue end
                if LobbyMode and root.Position.Y < 280 then continue end

                local isPlayer = isPlayerCharacter(obj)

                if isPlayer then
                    if obj == char and not TargetSelf then continue end
                    if obj ~= char and not TargetPlayer then continue end
                else
                    if not TargetNPC then continue end
                end

                table.insert(list, root)
            end
        end
    end

    return list
end

-- POSITION SYSTEM (FIXED)
local function getPosition(target, root)
    local pos = target.Position

    if Mode == "Behind" then
        local dir = (pos - root.Position).Unit
        return CFrame.new(pos - dir * Distance)

    elseif Mode == "Above" then
        return CFrame.new(pos + Vector3.new(0, Distance, 0))

    elseif Mode == "Under" then
        return CFrame.new(pos + Vector3.new(0, -Distance, 0))
    end
end

-- FIXED TWEEN (NO SPAM)
local function tweenTo(root, cf)
    if lastGoal and (lastGoal.Position - cf.Position).Magnitude < 1 then return end
    lastGoal = cf

    if currentTween then
        currentTween:Cancel()
    end

    local dist = (root.Position - cf.Position).Magnitude
    local time = dist / MoveSpeed

    currentTween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = cf
    })

    currentTween:Play()
end

-- ANTI VOID
local function createVoid()
    if VoidPart then return end

    local p = Instance.new("Part")
    p.Size = Vector3.new(5000, 2, 5000)
    p.Position = Vector3.new(0, -50, 0)
    p.Anchored = true
    p.Parent = Workspace

    VoidPart = p
end

local function removeVoid()
    if VoidPart then
        VoidPart:Destroy()
        VoidPart = nil
    end
end

--// LOOP
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if AutoFarm then
        Workspace.Gravity = 0

        if root.Position.Y <= -50 then
            CurrentTarget = nil
            tweenTo(root, CFrame.new(NoTargetPos))
            return
        end

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

        if not isTargetValid(CurrentTarget) then
            CurrentTarget = nil
        end

        if not CurrentTarget or tick() - TargetTime > StayDuration then
            local targets = getAllTargets()

            if #targets > 0 then
                CurrentTarget = targets[math.random(1, #targets)]
                TargetTime = tick()
            else
                CurrentTarget = nil
            end
        end

        if not CurrentTarget then
            tweenTo(root, CFrame.new(NoTargetPos))
            return
        end

        local pos = getPosition(CurrentTarget, root)
        if pos then
            tweenTo(root, pos)
        end

    else
        Workspace.Gravity = oldGravity
    end

    if AutoActivate then
        local tool = getTool()
        if tool then tool:Activate() end
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
    Name = "Anti Void",
    CurrentValue = false,
    Callback = function(v)
        if v then createVoid() else removeVoid() end
    end
})

Tab:CreateToggle({
    Name = "Lobby Mode",
    CurrentValue = false,
    Callback = function(v)
        LobbyMode = v
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

Tab:CreateDropdown({
    Name = "Position Mode",
    Options = {"Behind", "Above", "Under"},
    CurrentOption = "Behind",
    Callback = function(opt)
        Mode = opt
    end
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
