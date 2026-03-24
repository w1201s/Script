local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Hitbox Aura",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Toggle = false
local Range = 20

-- function เช็ค layer
local function IsTarget(obj)
    if obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
        return true
    end
    return false
end

-- ฟังก์ชันตี
local function HitTarget(target)
    local humanoid = target:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:TakeDamage(10) -- ปรับดาเมจได้
    end
end

-- loop หลัก
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggle then
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local root = char.HumanoidRootPart

            for _, v in pairs(workspace:GetDescendants()) do
                if IsTarget(v) then
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist <= Range then
                            HitTarget(v)
                        end
                    end
                end
            end
        end
    end
end)

-- UI Toggle
Tab:CreateToggle({
    Name = "Hitbox Aura",
    CurrentValue = false,
    Callback = function(Value)
        Toggle = Value
    end,
})

-- Slider ระยะ
Tab:CreateSlider({
    Name = "Range",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(Value)
        Range = Value
    end,
})
