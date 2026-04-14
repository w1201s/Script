--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- โหลด Orion UI Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- สร้างหน้าต่าง
local Window = OrionLib:MakeWindow({
    Name = "Silent Aim + Fling",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SilentAimFlingConfig",
    IntroEnabled = true,
    IntroText = "Silent Aim & Fling",
    IntroIcon = "rbxassetid://4483345998"
})

-- ==================== SILENT AIM CONFIG ====================
local SilentAimTab = Window:MakeTab({
    Name = "Silent Aim",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- สร้างส่วน Section สำหรับ Silent Aim
SilentAimTab:AddSection({
    Name = "Silent Aim Settings"
})

local SilentAimConfig = {
    Enabled = true,
    Distance = 28,
    TargetMode = "cursor",
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local targetPosition = nil

-- Toggle สำหรับเปิด/ปิด Silent Aim
SilentAimTab:AddToggle({
    Name = "Enable Silent Aim",
    Default = SilentAimConfig.Enabled,
    Callback = function(Value)
        SilentAimConfig.Enabled = Value
        if not Value then
            targetPosition = nil
        end
    end
})

-- Slider สำหรับปรับระยะ Distance
SilentAimTab:AddSlider({
    Name = "Aim Distance",
    Min = 10,
    Max = 100,
    Default = SilentAimConfig.Distance,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        SilentAimConfig.Distance = Value
    end
})

-- Dropdown สำหรับเลือก Target Mode
SilentAimTab:AddDropdown({
    Name = "Target Mode",
    Default = SilentAimConfig.TargetMode,
    Options = {"cursor", "center"},
    Callback = function(Value)
        SilentAimConfig.TargetMode = Value
    end
})

-- ==================== FLING CONFIG ====================
local FlingTab = Window:MakeTab({
    Name = "Fling",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- สร้างส่วน Section สำหรับ Fling
FlingTab:AddSection({
    Name = "Fling Settings"
})

local FlingConfig = {
    Enabled = true,
    Strength = 850,
}

local Debris = game:GetService("Debris")

-- Toggle สำหรับเปิด/ปิด Fling
FlingTab:AddToggle({
    Name = "Enable Fling",
    Default = FlingConfig.Enabled,
    Callback = function(Value)
        FlingConfig.Enabled = Value
    end
})

-- Slider สำหรับปรับ Fling Strength
FlingTab:AddSlider({
    Name = "Fling Strength",
    Min = 100,
    Max = 2000,
    Default = FlingConfig.Strength,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 50,
    ValueName = "power",
    Callback = function(Value)
        FlingConfig.Strength = Value
    end
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
OrionLib:MakeNotification({
    Name = "Script Loaded",
    Content = "Silent Aim & Fling loaded successfully!",
    Image = "rbxassetid://4483345998",
    Time = 3
})

-- เริ่มต้น Orion UI
OrionLib:Init()
