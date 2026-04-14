--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- โหลด Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- สร้างหน้าต่าง
local Window = Rayfield:CreateWindow({
    Name = "Silent Aim + Fling",
    LoadingTitle = "Silent Aim & Fling Script",
    LoadingSubtitle = "by You",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SilentAimFlingConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- ==================== SILENT AIM CONFIG ====================
local SilentAimTab = Window:CreateTab("Silent Aim", 4483362458)

-- Section สำหรับ Silent Aim Settings
local SilentAimSection = SilentAimTab:CreateSection("Silent Aim Settings")

local SilentAimConfig = {
    Enabled = true,
    Distance = 28,
    TargetMode = "cursor", -- "cursor" = closest target to cursor or "center" = closest target to center of your screen
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local targetPosition = nil

-- Toggle สำหรับเปิด/ปิด Silent Aim
SilentAimTab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = SilentAimConfig.Enabled,
    Flag = "SilentAimEnabled",
    Callback = function(Value)
        SilentAimConfig.Enabled = Value
        if not Value then
            targetPosition = nil
        end
    end,
})

-- Slider สำหรับปรับระยะ Distance
SilentAimTab:CreateSlider({
    Name = "Aim Distance",
    Range = {10, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = SilentAimConfig.Distance,
    Flag = "AimDistance",
    Callback = function(Value)
        SilentAimConfig.Distance = Value
    end,
})

-- Dropdown สำหรับเลือก Target Mode
SilentAimTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"cursor", "center"},
    CurrentOption = {SilentAimConfig.TargetMode},
    MultipleOptions = false,
    Flag = "TargetMode",
    Callback = function(Options)
        SilentAimConfig.TargetMode = Options[1]
    end,
})

-- ==================== FLING CONFIG ====================
local FlingTab = Window:CreateTab("Fling", 4483362458)

-- Section สำหรับ Fling Settings
local FlingSection = FlingTab:CreateSection("Fling Settings")

local FlingConfig = {
    Enabled = true,
    Strength = 850,
}

local Debris = game:GetService("Debris")

-- Toggle สำหรับเปิด/ปิด Fling
FlingTab:CreateToggle({
    Name = "Enable Fling",
    CurrentValue = FlingConfig.Enabled,
    Flag = "FlingEnabled",
    Callback = function(Value)
        FlingConfig.Enabled = Value
    end,
})

-- Slider สำหรับปรับ Fling Strength
FlingTab:CreateSlider({
    Name = "Fling Strength",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "power",
    CurrentValue = FlingConfig.Strength,
    Flag = "FlingStrength",
    Callback = function(Value)
        FlingConfig.Strength = Value
    end,
})

-- ==================== SILENT AIM LOGIC ====================
local function updateTarget()
    if not SilentAimConfig.Enabled then
        targetPosition = nil
        return
    end
    local referencePos
    if SilentAimConfig.TargetMode == "cursor" then
        referencePos = UserInputService:GetMouseLocation()
    else
        referencePos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    end
    if not referencePos then return end
    local closestPart = nil
    local minScreenDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    if targetPart then
                        local worldDist = (targetPart.Position - camera.CFrame.Position).Magnitude
                        if worldDist <= SilentAimConfig.Distance then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local screenDist = (screenVec - referencePos).Magnitude
                                if screenDist < minScreenDist then
                                    minScreenDist = screenDist
                                    closestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if closestPart then
        targetPosition = closestPart.Position
    else
        targetPosition = nil
    end
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if SilentAimConfig.Enabled and targetPosition and self == Workspace and method == "Raycast" then
        local args = {...}
        if typeof(args[1]) == "Vector3" then
            local origin = args[1]
            local newDir = (targetPosition - origin).Unit * SilentAimConfig.Distance
            args[2] = newDir
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end))

RunService.RenderStepped:Connect(updateTarget)

-- ==================== FLING LOGIC ====================
Workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local partInfo = model:FindFirstChild("GrabPart")
        if not partInfo then return end

        local weld = partInfo:FindFirstChild("WeldConstraint")
        if not weld or not weld.Part1 then return end

        local part = weld.Part1
        local velocity = Instance.new("BodyVelocity")
        velocity.Parent = part

        model:GetPropertyChangedSignal("Parent"):Connect(function()
            if not model.Parent then
                if FlingConfig.Enabled then
                    velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    velocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * FlingConfig.Strength
                else
                    velocity.MaxForce = Vector3.zero
                end
                Debris:AddItem(velocity, 1)
            end
        end)
    end
end)

-- แจ้งเตือนเมื่อโหลดเสร็จ
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Silent Aim & Fling loaded successfully!",
    Duration = 3,
})
