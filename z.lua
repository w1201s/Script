-- Hitbox Expander Script with Rayfield UI
-- No collision issues - CanCollide is always false

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
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Variables
local HitboxEnabled = false
local HitboxSize = 5
local HitboxTransparency = 0.7
local HitboxColor = Color3.fromRGB(255, 0, 0)
local TeamCheck = true
local TargetPart = "HumanoidRootPart" -- Options: HumanoidRootPart, Head, Torso

-- Target Part Dropdown
MainTab:CreateDropdown({
    Name = "Target Part",
    Options = {"HumanoidRootPart", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"},
    CurrentOption = "HumanoidRootPart",
    Flag = "TargetPart",
    Callback = function(Option)
        TargetPart = Option
    end
})

-- Enable/Disable Toggle
MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then
            -- Reset all hitboxes when disabled
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local part = player.Character:FindFirstChild(TargetPart)
                    if part then
                        part.Size = part:GetAttribute("OriginalSize") or part.Size
                        part.Transparency = part:GetAttribute("OriginalTransparency") or 1
                        part.Color = part:GetAttribute("OriginalColor") or part.Color
                    end
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

-- Team Check Toggle
MainTab:CreateToggle({
    Name = "Team Check (Ignore Teammates)",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(Value)
        TeamCheck = Value
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Visual Only Mode (Safer)
SettingsTab:CreateToggle({
    Name = "Visual Only Mode (No Size Change)",
    CurrentValue = false,
    Flag = "VisualOnly",
    Callback = function(Value)
        -- This would require separate logic, currently just placeholder
    end
})

-- Credits
SettingsTab:CreateParagraph({
    Title = "Credits",
    Content = "Made for Roblox games\nNo collision issues - Safe to use"
})

-- Main Loop
task.spawn(function()
    while task.wait(0.1) do
        if HitboxEnabled then
            local localPlayer = game.Players.LocalPlayer
            
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    -- Team check
                    if TeamCheck and player.Team == localPlayer.Team then
                        continue
                    end
                    
                    local character = player.Character
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    if humanoid and humanoid.Health > 0 then
                        local target = character:FindFirstChild(TargetPart)
                        
                        if target then
                            -- Store original properties if not stored
                            if not target:GetAttribute("OriginalSize") then
                                target:SetAttribute("OriginalSize", target.Size)
                                target:SetAttribute("OriginalTransparency", target.Transparency)
                                target:SetAttribute("OriginalColor", target.Color)
                            end
                            
                            -- Apply hitbox modifications
                            target.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                            target.Transparency = HitboxTransparency
                            target.Color = HitboxColor
                            target.Material = Enum.Material.Neon
                            
                            -- CRITICAL: No collision settings
                            target.CanCollide = false
                            target.CanQuery = true -- Still allows raycast detection
                            target.Massless = true -- No physics issues
                        end
                    end
                end
            end
        end
    end
end)

-- Handle new players joining
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if HitboxEnabled then
            task.wait(1) -- Wait for character to load
            local target = char:WaitForChild(TargetPart, 5)
            if target then
                target:SetAttribute("OriginalSize", target.Size)
                target:SetAttribute("OriginalTransparency", target.Transparency)
                target:SetAttribute("OriginalColor", target.Color)
            end
        end
    end)
end)

-- Reset on death (optional cleanup)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    -- Optional: Auto-disable on respawn
    -- HitboxEnabled = false
    -- Rayfield:Notify({Title = "Hitbox", Content = "Disabled on respawn", Duration = 3})
end)

Rayfield:Notify({
    Title = "Hitbox Loaded",
    Content = "Press the toggle to enable",
    Duration = 5
})
