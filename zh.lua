local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Hitbox Aura Fixed",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Toggle = false
local ShowHitbox = false
local Range = 20
local TargetMode = "Player" -- Player / NPC / All

-- 🔍 เช็ค target แบบละเอียด
local function IsTarget(model)
    local hum = model:FindFirstChild("Humanoid")
    local plr = Players:GetPlayerFromCharacter(model)

    if not hum or model == LocalPlayer.Character then return false end

    if TargetMode == "Player" then
        return plr ~= nil
    elseif TargetMode == "NPC" then
        return plr == nil
    elseif TargetMode == "All" then
        return true
    end

    return false
end

-- 🎯 ตี
local function HitTarget(model)
    local hum = model:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 then
        hum:TakeDamage(10)
    end
end

-- 👁️ แสดง hitbox
local function ApplyHitboxVisual(model)
    if not ShowHitbox then return end

    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("HitboxVisual") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "HitboxVisual"
        box.Adornee = hrp
        box.Size = Vector3.new(5,5,5)
        box.Color3 = Color3.fromRGB(255,0,0)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Parent = hrp
    end
end

-- ❌ ลบ hitbox
local function RemoveHitboxVisual(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("HitboxVisual") then
        hrp.HitboxVisual:Destroy()
    end
end

-- 🔁 Loop หลัก
task.spawn(function()
    while true do
        task.wait(0.1)

        if Toggle then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local root = char.HumanoidRootPart

            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and IsTarget(v) then
                    local hrp = v:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude

                        if dist <= Range then
                            HitTarget(v)
                            ApplyHitboxVisual(v)
                        else
                            RemoveHitboxVisual(v)
                        end
                    end
                end
            end
        end
    end
end)

-- 🎛️ UI

Tab:CreateToggle({
    Name = "Hitbox Aura",
    CurrentValue = false,
    Callback = function(v)
        Toggle = v
    end,
})

Tab:CreateToggle({
    Name = "Show Hitbox",
    CurrentValue = false,
    Callback = function(v)
        ShowHitbox = v
        if not v then
            -- ลบทั้งหมด
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "HitboxVisual" then
                    v:Destroy()
                end
            end
        end
    end,
})

Tab:CreateDropdown({
    Name = "Target Mode",
    Options = {"Player", "NPC", "All"},
    CurrentOption = "Player",
    Callback = function(v)
        TargetMode = v
    end,
})

Tab:CreateSlider({
    Name = "Range",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v)
        Range = v
    end,
})
