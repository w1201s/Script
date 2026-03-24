-- Hitbox Expander - Humanoid ONLY, ignores specific path
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Hitbox Expander",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by we fucking dead",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HitboxConfig",
        FileName = "Settings"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- Variables
local HitboxEnabled = false
local HitboxSize = 5
local HitboxTransparency = 0.7
local HitboxColor = Color3.fromRGB(255, 0, 0)
local TeamCheck = true

-- EXACT path to ignore
local IGNORE_PATH = workspace:WaitForChild("Everything"):WaitForChild("Map"):WaitForChild("Npc"):WaitForChild("R6n_w1201s")

-- Enable Toggle
MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then
            -- Reset all
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj:GetAttribute("HitboxExpanded") then
                    obj.Size = obj:GetAttribute("OriginalSize")
                    obj.Transparency = obj:GetAttribute("OriginalTransparency")
                    obj.Color = obj:GetAttribute("OriginalColor")
                    obj.Material = obj:GetAttribute("OriginalMaterial")
                    obj:SetAttribute("HitboxExpanded", nil)
                end
            end
        end
    end
})

-- Size Slider
MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 50},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 5,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Value
    end
})

-- Transparency Slider
MainTab:CreateSlider({
    Name = "Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.7,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        HitboxTransparency = Value
    end
})

-- Color Picker
MainTab:CreateColorPicker({
    Name = "Hitbox Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "HitboxColor",
    Callback = function(Color)
        HitboxColor = Color
    end
})

-- Team Check
MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(Value)
        TeamCheck = Value
    end
})

-- Function: Check if object is or is inside ignored path
local function isIgnored(obj)
    local current = obj
    while current do
        if current == IGNORE_PATH then
            return true
        end
        current = current.Parent
    end
    return false
end

-- Function: Get Humanoid from part (MUST have humanoid)
local function getHumanoid(part)
    if not part or not part:IsA("BasePart") then return nil end
    
    -- Check parent
    if part.Parent then
        local hum = part.Parent:FindFirstChildOfClass("Humanoid")
        if hum then return hum end
        
        -- Check grandparent (for R15 rigs)
        if part.Parent.Parent then
            hum = part.Parent.Parent:FindFirstChildOfClass("Humanoid")
            if hum then return hum end
        end
    end
    
    return nil
end

-- Function: Get target part from character (HumanoidRootPart or Head)
local function getTargetPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

-- Main Loop
task.spawn(function()
    while task.wait(0.1) do
        if not HitboxEnabled then continue end
        
        local localPlayer = game.Players.LocalPlayer
        
        -- Scan workspace for humanoids
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not obj:IsA("BasePart") then continue end
            
            -- Skip ignored path completely
            if isIgnored(obj) then continue end
            
            -- MUST have humanoid - strict check
            local humanoid = getHumanoid(obj)
            if not humanoid or humanoid.Health <= 0 then continue end
            
            -- Get the character model
            local character = humanoid.Parent
            if not character then continue end
            
            -- Only process the main target part (HRP or Head)
            local targetPart = getTargetPart(character)
            if obj ~= targetPart then continue end
            
            -- Team check for players only
            if TeamCheck and localPlayer then
                local player = game.Players:GetPlayerFromCharacter(character)
                if player and player.Team == localPlayer.Team then
                    continue
                end
            end
            
            -- Store original if first time
            if not obj:GetAttribute("HitboxExpanded") then
                obj:SetAttribute("OriginalSize", obj.Size)
                obj:SetAttribute("OriginalTransparency", obj.Transparency)
                obj:SetAttribute("OriginalColor", obj.Color)
                obj:SetAttribute("OriginalMaterial", obj.Material)
                obj:SetAttribute("HitboxExpanded", true)
            end
            
            -- Apply hitbox
            obj.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            obj.Transparency = HitboxTransparency
            obj.Color = HitboxColor
            obj.Material = Enum.Material.Neon
            obj.CanCollide = false
            obj.CanQuery = true
            obj.Massless = true
        end
    end
end)

-- Handle new spawns
workspace.DescendantAdded:Connect(function(obj)
    if HitboxEnabled and obj:IsA("BasePart") and (obj.Name == "HumanoidRootPart" or obj.Name == "Head") then
        -- Let main loop handle it
    end
end)

Rayfield:Notify({
    Title = "Hitbox Loaded",
    Content = "Humanoid ONLY | Ignoring R6n_w1201s",
    Duration = 5
})
