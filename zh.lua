local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Hitbox Others Only",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local HitboxSize = 5

local OriginalSizes = {}

-- 📦 ใส่ hitbox (เฉพาะคนอื่น)
local function ApplyHitbox(model)
    if model == LocalPlayer.Character then return end -- 🔥 กันตัวเรา

    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not OriginalSizes[hrp] then
        OriginalSizes[hrp] = hrp.Size
    end

    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    hrp.Transparency = 0.7
    hrp.CanCollide = false
end

-- 🔄 คืนค่าเดิม
local function ResetHitbox(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if OriginalSizes[hrp] then
        hrp.Size = OriginalSizes[hrp]
    end

    hrp.Transparency = 0
end

-- 🔁 Loop
task.spawn(function()
    while true do
        task.wait(0.2)

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
                if Enabled then
                    ApplyHitbox(v)
                else
                    ResetHitbox(v)
                end
            end
        end
    end
end)

-- 🎛️ UI

Tab:CreateToggle({
    Name = "Enable Hitbox (Others Only)",
    CurrentValue = false,
    Callback = function(v)
        Enabled = v

        if not v then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    ResetHitbox(v)
                end
            end
        end
    end,
})

Tab:CreateSlider({
    Name = "Hitbox Size (stud)",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        HitboxSize = v
    end,
})
