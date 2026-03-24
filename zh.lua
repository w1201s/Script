local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Universal Hitbox",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by you",
})

local Tab = Window:CreateTab("Main", 4483362458)

local Enabled = false

-- 👁️ ใส่ hitbox (Highlight)
local function AddHitbox(model)
    if model:FindFirstChild("HitboxHighlight") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "HitboxHighlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0
    hl.Adornee = model
    hl.Parent = model
end

-- ❌ ลบ hitbox
local function RemoveHitbox(model)
    local hl = model:FindFirstChild("HitboxHighlight")
    if hl then
        hl:Destroy()
    end
end

-- 🔁 Loop ใส่ทุกตัวที่มี Humanoid
task.spawn(function()
    while true do
        task.wait(0.2)

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
                if Enabled then
                    AddHitbox(v)
                else
                    RemoveHitbox(v)
                end
            end
        end
    end
end)

-- UI Toggle
Tab:CreateToggle({
    Name = "Enable Hitbox For All Humanoids",
    CurrentValue = false,
    Callback = function(v)
        Enabled = v

        if not v then
            -- ลบทั้งหมดทันที
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Highlight") and v.Name == "HitboxHighlight" then
                    v:Destroy()
                end
            end
        end
    end,
})
