-- Hitbox Expander - No Flicker, No Self Hitbox
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
local HitboxSize = 10
local HitboxTransparency = 0.5
local HitboxColor = Color3.fromRGB(255, 0, 0)
local TeamCheck = true

-- Storage for hitbox parts
local HitboxParts = {}
local LocalCharacter = nil

-- EXACT path to ignore
local IGNORE_PATH = nil
task.spawn(function()
    pcall(function()
        IGNORE_PATH = workspace:WaitForChild("Everything"):WaitForChild("Map"):WaitForChild("Npc"):WaitForChild("R6n_w1201s")
    end)
end)

-- Enable Toggle
MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then
            -- Destroy all hitbox parts
            for _, hitbox in pairs(HitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox:Destroy()
                end
            end
            table.clear(HitboxParts)
        end
    end
})

-- Size Slider
MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 10,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Value
        -- Update existing hitboxes immediately
        for _, hitbox in pairs(HitboxParts) do
            if hitbox then
                hitbox.Size = Vector3.new(Value, Value, Value)
            end
        end
    end
})

-- Transparency Slider
MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        HitboxTransparency = Value
        for _, hitbox in pairs(HitboxParts) do
            if hitbox then
                hitbox.Transparency = Value
            end
        end
    end
})

-- Color Picker
MainTab:CreateColorPicker({
    Name = "Hitbox Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "HitboxColor",
    Callback = function(Color)
        HitboxColor = Color
        for _, hitbox in pairs(HitboxParts) do
            if hitbox then
                hitbox.Color = Color
            end
        end
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

-- Update local character reference
local function updateLocalChar()
    local player = game.Players.LocalPlayer
    if player then
        LocalCharacter = player.Character
        player.CharacterAdded:Connect(function(char)
            LocalCharacter = char
        end)
    end
end
updateLocalChar()

-- Function: Check if object is inside ignored path
local function isIgnored(obj)
    if not IGNORE_PATH then return false end
    local current = obj
    while current do
        if current == IGNORE_PATH then
            return true
        end
        current = current.Parent
    end
    return false
end

-- Function: Check if is local player
local function isLocalPlayer(character)
    if not LocalCharacter then return false end
    return character == LocalCharacter
end

-- Function: Get Humanoid from character
local function getHumanoid(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChildOfClass("Humanoid")
end

-- Function: Create hitbox for character
local function createHitbox(character)
    if not HitboxEnabled then return end
    if not character or not character.Parent then return end
    
    -- Skip self
    if isLocalPlayer(character) then return end
    
    -- Ignore check
    if isIgnored(character) then return end
    
    -- Must have humanoid
    local humanoid = getHumanoid(character)
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Team check
    if TeamCheck then
        local localPlayer = game.Players.LocalPlayer
        local player = game.Players:GetPlayerFromCharacter(character)
        if player and localPlayer and player.Team == localPlayer.Team then
            return
        end
    end
    
    -- Get target part
    local targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not targetPart then return end
    
    -- Check if already has hitbox
    if HitboxParts[character] then return end
    
    -- Create hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "ExpandedHitbox"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Material = Enum.Material.ForceField -- Smoother visual
    hitbox.CanCollide = false
    hitbox.CanQuery = true
    hitbox.Massless = true
    hitbox.Anchored = false
    
    -- Size and appearance
    hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    hitbox.Transparency = HitboxTransparency
    hitbox.Color = HitboxColor
    
    -- Parent to character (not target part) to avoid jitter
    hitbox.Parent = character
    
    -- Weld to target part (smooth follow)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = targetPart
    weld.Parent = hitbox
    
    -- Center the hitbox on target
    hitbox.CFrame = targetPart.CFrame
    
    HitboxParts[character] = hitbox
    
    -- Auto cleanup on death
    humanoid.Died:Connect(function()
        if HitboxParts[character] then
            HitboxParts[character]:Destroy()
            HitboxParts[character] = nil
        end
    end)
end

-- Cleanup function
local function cleanupHitbox(character)
    if HitboxParts[character] then
        HitboxParts[character]:Destroy()
        HitboxParts[character] = nil
    end
end

-- Use RunService for smooth updates (no flicker)
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    if not HitboxEnabled then return end
    
    -- Clean up invalid hitboxes
    for char, hitbox in pairs(HitboxParts) do
        if not char or not char.Parent or not hitbox or not hitbox.Parent then
            if hitbox then hitbox:Destroy() end
            HitboxParts[char] = nil
        else
            -- Check if humanoid still alive
            local humanoid = getHumanoid(char)
            if not humanoid or humanoid.Health <= 0 then
                hitbox:Destroy()
                HitboxParts[char] = nil
            end
        end
    end
    
    -- Create hitboxes for new characters
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not HitboxParts[obj] then
            local humanoid = getHumanoid(obj)
            if humanoid and humanoid.Health > 0 then
                createHitbox(obj)
            end
        end
    end
end)

-- Handle new spawns
workspace.DescendantAdded:Connect(function(obj)
    if not HitboxEnabled then return end
    if obj:IsA("Model") then
        task.delay(0.1, function() -- Small delay for humanoid to load
            local humanoid = getHumanoid(obj)
            if humanoid and humanoid.Health > 0 then
                createHitbox(obj)
            end
        end)
    end
end)

-- Cleanup on remove
workspace.DescendantRemoving:Connect(function(obj)
    if HitboxParts[obj] then
        HitboxParts[obj]:Destroy()
        HitboxParts[obj] = nil
    end
end)

Rayfield:Notify({
    Title = "Hitbox Loaded",
    Content = "No flicker | No self hitbox | Smooth",
    Duration = 5
})
