local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Farm + Anti Void",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- 🔻 Anti Void
-- =====================
local AntiVoidEnabled = false
local VoidThickness = 5
local VoidPart = nil

local function CreateVoid()
    if VoidPart then VoidPart:Destroy() end

    VoidPart = Instance.new("Part")
    VoidPart.Size = Vector3.new(10000, VoidThickness, 10000)
    VoidPart.Position = Vector3.new(0, -50, 0)
    VoidPart.Anchored = true
    VoidPart.Transparency = 0.5
    VoidPart.Color = Color3.fromRGB(0,0,0)
    VoidPart.Name = "AntiVoid"
    VoidPart.Parent = workspace
end

-- =====================
-- 🤖 Auto Farm
-- =====================
local AutoFarm = false
local Mode = "Behind" -- Under / Behind / Above
local Distance = 5

local function GetOffset(cf)
    if Mode == "Behind" then
        return cf * CFrame.new(0, 0, Distance)
    elseif Mode == "Under" then
        return cf * CFrame.new(0, -Distance, 0)
    elseif Mode == "Above" then
        return cf * CFrame.new(0, Distance, 0)
    end
end

local function TweenTo(pos)
    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (root.Position - pos.Position).Magnitude
    local time = dist / 50

    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = pos
    })

    tween:Play()
    tween.Completed:Wait()
end

task.spawn(function()
    while true do
        task.wait(0.2)

        if AutoFarm then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") 
                and v.Name ~= "R6n_w1201s" 
                and v:FindFirstChildOfClass("Humanoid") then

                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp and LocalPlayer.Character then
                        local targetCF = GetOffset(hrp.CFrame)
                        TweenTo(targetCF)
                    end
                end
            end
        end
    end
end)

-- =====================
-- 🎛️ UI
-- =====================

-- Anti Void Toggle
Tab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = false,
    Callback = function(v)
        AntiVoidEnabled = v

        if v then
            CreateVoid()
        else
            if VoidPart then VoidPart:Destroy() end
        end
    end,
})

-- Thickness Slider
Tab:CreateSlider({
    Name = "Void Thickness",
    Range = {1,10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        VoidThickness = v
        if AntiVoidEnabled then
            CreateVoid()
        end
    end,
})

-- Auto Farm Toggle
Tab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v
    end,
})

-- Mode Dropdown
Tab:CreateDropdown({
    Name = "Position Mode",
    Options = {"Behind", "Under", "Above"},
    CurrentOption = "Behind",
    Callback = function(v)
        Mode = v
    end,
})

-- Distance Slider
Tab:CreateSlider({
    Name = "Distance",
    Range = {1,20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        Distance = v
    end,
})
