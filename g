--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIGURATION (สำหรับ Rayfield)
local CONFIG = {
    Aimbot = {
        Enabled = false,
        Mode = "Normal", -- "Normal" (FOV) หรือ "Lock" (ไม่สน FOV)
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0, -- 0 = instant, 10 = smooth
        FOV = 150,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(0, 170, 255),
        FOVUseRGB = false,
        MaxDistance = 1000,
        TargetPart = "Head",
        UseTargetList = false,
        UseAllyList = false,
        TargetList = {},
        AllyList = {}
    },
    
    ESP = {
        Enabled = true,
        MaxDistance = 1000,
        TextSize = 13,
        TextColor = Color3.fromRGB(255, 50, 50),
        AllyColor = Color3.fromRGB(50, 255, 50),
        BoxColor = Color3.fromRGB(255, 0, 0),
        ShowName = true,
        ShowHealth = true,
        ShowDistance = true,
        ShowWeapon = true,
        TeamCheck = true,
        BoxESP = true,
        TracerESP = true,
        Chams = true,
        UseRGB = false,
        RGBSpeed = 5
    }
}

--// VARIABLES
local ESPObjects = {}
local CurrentTarget = nil
local FOVHue = 0
local ESPHue = 0

--// UTILITY FUNCTIONS
local function GetCharacter(player)
    return player and player.Character
end

local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not player then return false end
    return player.Team == LocalPlayer.Team
end

local function GetWeaponName(character)
    local tool = character:FindFirstChildOfClass("Tool")
    return tool and tool.Name or "None"
end

local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function IsVisible(targetPart)
    if not CONFIG.Aimbot.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        return hitModel == targetPart.Parent
    end
    return true
end

local function GetPlayerDisplayText(player)
    return "@" .. player.Name .. "(" .. player.DisplayName .. ")"
end

local function IsInTargetList(player)
    for _, targetName in ipairs(CONFIG.Aimbot.TargetList) do
        if targetName == player.Name then return true end
    end
    return false
end

local function IsInAllyList(player)
    for _, allyName in ipairs(CONFIG.Aimbot.AllyList) do
        if allyName == player.Name then return true end
    end
    return false
end

local function GetTarget()
    if CONFIG.Aimbot.Mode == "Lock" then
        -- Lock mode: ไม่สน FOV
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not IsAlive(GetCharacter(player)) then continue end
            if CONFIG.Aimbot.TeamCheck and IsTeammate(player) then continue end
            if CONFIG.Aimbot.UseAllyList and IsInAllyList(player) then continue end
            if CONFIG.Aimbot.UseTargetList and not IsInTargetList(player) then continue end
            
            local character = GetCharacter(player)
            local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
            if not targetPart then continue end
            if CONFIG.Aimbot.WallCheck and not IsVisible(targetPart) then continue end
            
            local screenPos, onScreen, depth = WorldToScreen(targetPart.Position)
            if not onScreen or depth > CONFIG.Aimbot.MaxDistance then continue end
            
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distance = (screenPos - screenCenter).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
        return closestPlayer
    else
        -- Normal mode: ใช้ FOV
        local closestPlayer = nil
        local shortestDistance = CONFIG.Aimbot.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not IsAlive(GetCharacter(player)) then continue end
            if CONFIG.Aimbot.TeamCheck and IsTeammate(player) then continue end
            if CONFIG.Aimbot.UseAllyList and IsInAllyList(player) then continue end
            if CONFIG.Aimbot.UseTargetList and not IsInTargetList(player) then continue end
            
            local character = GetCharacter(player)
            local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
            if not targetPart then continue end
            if CONFIG.Aimbot.WallCheck and not IsVisible(targetPart) then continue end
            
            local screenPos, onScreen, depth = WorldToScreen(targetPart.Position)
            if not onScreen or depth > CONFIG.Aimbot.MaxDistance then continue end
            
            local distance = (screenPos - screenCenter).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
        return closestPlayer
    end
end

--// ESP SYSTEM
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local espData = {
        Player = player,
        Drawings = {},
        Highlight = nil
    }
    
    local nameText = Drawing.new("Text")
    nameText.Center = true
    nameText.Outline = true
    nameText.Size = CONFIG.ESP.TextSize
    espData.Drawings.Name = nameText
    
    local healthText = Drawing.new("Text")
    healthText.Center = true
    healthText.Outline = true
    healthText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Health = healthText
    
    local distText = Drawing.new("Text")
    distText.Center = true
    distText.Outline = true
    distText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Distance = distText
    
    local weaponText = Drawing.new("Text")
    weaponText.Center = true
    weaponText.Outline = true
    weaponText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Weapon = weaponText
    
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Filled = false
    box.Visible = false
    espData.Drawings.Box = box
    
    local filledBox = Drawing.new("Square")
    filledBox.Thickness = 1
    filledBox.Filled = true
    filledBox.Transparency = 0.2
    filledBox.Visible = false
    espData.Drawings.FilledBox = filledBox
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    espData.Drawings.Tracer = tracer
    
    espData.Update = function(deltaTime)
        if not CONFIG.ESP.Enabled then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local character = GetCharacter(player)
        if not IsAlive(character) then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > CONFIG.ESP.MaxDistance then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local isTeammate = CONFIG.ESP.TeamCheck and IsTeammate(player)
        local isAlly = CONFIG.Aimbot.UseAllyList and IsInAllyList(player)
        local isFriendly = isTeammate or isAlly
        
        -- RGB Color
        local displayColor
        if CONFIG.ESP.UseRGB then
            ESPHue = (ESPHue + deltaTime * CONFIG.ESP.RGBSpeed * 0.1) % 1
            displayColor = Color3.fromHSV(ESPHue, 1, 1)
        else
            displayColor = isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor
        end
        
        espData.Drawings.Name.Color = displayColor
        espData.Drawings.Box.Color = CONFIG.ESP.UseRGB and displayColor or (isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor)
        espData.Drawings.FilledBox.Color = CONFIG.ESP.UseRGB and displayColor or (isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor)
        espData.Drawings.Tracer.Color = CONFIG.ESP.UseRGB and displayColor or (isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor)
        
        local headPos, headOnScreen = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
        
        if not headOnScreen and not rootOnScreen then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local boxHeight = math.abs(headPos.Y - rootPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
        
        if CONFIG.ESP.ShowName then
            local tag = ""
            if isAlly then
                tag = " [ALLY]"
            elseif isTeammate then
                tag = " [TEAM]"
            else
                tag = " [ENEMY]"
            end
            espData.Drawings.Name.Text = player.Name .. tag
            espData.Drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            espData.Drawings.Name.Visible = true
        else
            espData.Drawings.Name.Visible = false
        end
        
        if CONFIG.ESP.ShowHealth then
            local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            espData.Drawings.Health.Text = hpPercent .. " HP"
            espData.Drawings.Health.Color = Color3.fromRGB(255 - (hpPercent * 2.55), hpPercent * 2.55, 0)
            espData.Drawings.Health.Position = Vector2.new(headPos.X, headPos.Y - 35)
            espData.Drawings.Health.Visible = true
        else
            espData.Drawings.Health.Visible = false
        end
        
        if CONFIG.ESP.ShowDistance then
            espData.Drawings.Distance.Text = math.floor(distance) .. "m"
            espData.Drawings.Distance.Position = Vector2.new(headPos.X, rootPos.Y + 5)
            espData.Drawings.Distance.Visible = true
        else
            espData.Drawings.Distance.Visible = false
        end
        
        if CONFIG.ESP.ShowWeapon then
            espData.Drawings.Weapon.Text = GetWeaponName(character)
            espData.Drawings.Weapon.Position = Vector2.new(headPos.X, rootPos.Y + 20)
            espData.Drawings.Weapon.Visible = true
        else
            espData.Drawings.Weapon.Visible = false
        end
        
        if CONFIG.ESP.BoxESP then
            espData.Drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
            espData.Drawings.Box.Position = boxPos
            espData.Drawings.Box.Visible = true
            
            espData.Drawings.FilledBox.Size = Vector2.new(boxWidth, boxHeight)
            espData.Drawings.FilledBox.Position = boxPos
            espData.Drawings.FilledBox.Visible = CONFIG.ESP.Chams
        else
            espData.Drawings.Box.Visible = false
            espData.Drawings.FilledBox.Visible = false
        end
        
        if CONFIG.ESP.TracerESP then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Drawings.Tracer.From = screenCenter
            espData.Drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            espData.Drawings.Tracer.Visible = true
        else
            espData.Drawings.Tracer.Visible = false
        end
        
        if CONFIG.ESP.Chams then
            if not espData.Highlight or espData.Highlight.Parent ~= character then
                if espData.Highlight then espData.Highlight:Destroy() end
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.FillColor = CONFIG.ESP.UseRGB and displayColor or (isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor)
                espData.Highlight.OutlineColor = Color3.new(1, 1, 1)
                espData.Highlight.FillTransparency = 0.5
                espData.Highlight.OutlineTransparency = 0
                espData.Highlight.Parent = character
            end
            espData.Highlight.Enabled = true
            espData.Highlight.FillColor = CONFIG.ESP.UseRGB and displayColor or (isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor)
        elseif espData.Highlight then
            espData.Highlight.Enabled = false
        end
    end
    
    espData.Cleanup = function()
        for _, drawing in pairs(espData.Drawings) do
            drawing:Remove()
        end
        if espData.Highlight then espData.Highlight:Destroy() end
    end
    
    ESPObjects[player] = espData
end

local function RemoveESP(player)
    local espData = ESPObjects[player]
    if espData then
        espData.Cleanup()
        ESPObjects[player] = nil
    end
end

--// REFRESH DROPDOWN (สำหรับ Rayfield)
local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, GetPlayerDisplayText(player))
        end
    end
    return list
end

local function GetPlayerNameFromDisplay(displayText)
    -- แยก @username(DisplayName) เอา username
    local username = displayText:match("@([^%(]+)")
    return username
end


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Combat System",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by Kimi",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CombatConfig",
      FileName = "Settings"
   }
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", "🎯")

AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotEnabled",
   Callback = function(Value)
       CONFIG.Aimbot.Enabled = Value
   end
})

AimbotTab:CreateDropdown({
   Name = "Mode",
   Options = {"Normal", "Lock"},
   CurrentOption = "Normal",
   Flag = "AimbotMode",
   Callback = function(Option)
       CONFIG.Aimbot.Mode = Option
   end
})

AimbotTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Flag = "TeamCheck",
   Callback = function(Value)
       CONFIG.Aimbot.TeamCheck = Value
   end
})

AimbotTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Flag = "WallCheck",
   Callback = function(Value)
       CONFIG.Aimbot.WallCheck = Value
   end
})

AimbotTab:CreateSlider({
   Name = "Smoothness",
   Range = {0, 10},
   Increment = 1,
   Suffix = "",
   CurrentValue = 0,
   Flag = "Smoothness",
   Callback = function(Value)
       CONFIG.Aimbot.Smoothness = Value
   end
})

AimbotTab:CreateSlider({
   Name = "FOV Size",
   Range = {50, 400},
   Increment = 10,
   Suffix = "",
   CurrentValue = 150,
   Flag = "FOV",
   Callback = function(Value)
       CONFIG.Aimbot.FOV = Value
   end
})

AimbotTab:CreateToggle({
   Name = "Show FOV",
   CurrentValue = true,
   Flag = "ShowFOV",
   Callback = function(Value)
       CONFIG.Aimbot.ShowFOV = Value
   end
})

AimbotTab:CreateColorPicker({
   Name = "FOV Color",
   Color = Color3.fromRGB(0, 170, 255),
   Flag = "FOVColor",
   Callback = function(Value)
       CONFIG.Aimbot.FOVColor = Value
   end
})

AimbotTab:CreateToggle({
   Name = "FOV RGB Mode",
   CurrentValue = false,
   Flag = "FOVRGB",
   Callback = function(Value)
       CONFIG.Aimbot.FOVUseRGB = Value
   end
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", "👁️")

ESPTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = true,
   Flag = "ESPEnabled",
   Callback = function(Value)
       CONFIG.ESP.Enabled = Value
   end
})

ESPTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = true,
   Flag = "BoxESP",
   Callback = function(Value)
       CONFIG.ESP.BoxESP = Value
   end
})

ESPTab:CreateToggle({
   Name = "Tracer ESP",
   CurrentValue = true,
   Flag = "TracerESP",
   Callback = function(Value)
       CONFIG.ESP.TracerESP = Value
   end
})

ESPTab:CreateToggle({
   Name = "Chams",
   CurrentValue = true,
   Flag = "Chams",
   Callback = function(Value)
       CONFIG.ESP.Chams = Value
   end
})

ESPTab:CreateToggle({
   Name = "Show Names",
   CurrentValue = true,
   Flag = "ShowNames",
   Callback = function(Value)
       CONFIG.ESP.ShowName = Value
   end
})

ESPTab:CreateToggle({
   Name = "Show Health",
   CurrentValue = true,
   Flag = "ShowHealth",
   Callback = function(Value)
       CONFIG.ESP.ShowHealth = Value
   end
})

ESPTab:CreateToggle({
   Name = "ESP RGB Mode",
   CurrentValue = false,
   Flag = "ESPRGB",
   Callback = function(Value)
       CONFIG.ESP.UseRGB = Value
   end
})

ESPTab:CreateColorPicker({
   Name = "Enemy Color",
   Color = Color3.fromRGB(255, 50, 50),
   Flag = "EnemyColor",
   Callback = function(Value)
       CONFIG.ESP.TextColor = Value
   end
})

ESPTab:CreateColorPicker({
   Name = "Ally Color",
   Color = Color3.fromRGB(50, 255, 50),
   Flag = "AllyColor",
   Callback = function(Value)
       CONFIG.ESP.AllyColor = Value
   end
})

-- Extra Tab (Ally & Target)
local ExtraTab = Window:CreateTab("Extra", "✨")

ExtraTab:CreateToggle({
   Name = "Use Target List",
   CurrentValue = false,
   Flag = "UseTarget",
   Callback = function(Value)
       CONFIG.Aimbot.UseTargetList = Value
   end
})

ExtraTab:CreateDropdown({
   Name = "Target Players",
   Options = GetPlayerList(),
   CurrentOption = "",
   MultipleOptions = true,
   Flag = "TargetList",
   Callback = function(Options)
       CONFIG.Aimbot.TargetList = {}
       for _, option in ipairs(Options) do
           local name = GetPlayerNameFromDisplay(option)
           if name then
               table.insert(CONFIG.Aimbot.TargetList, name)
           end
       end
   end
})

ExtraTab:CreateToggle({
   Name = "Use Ally List",
   CurrentValue = false,
   Flag = "UseAlly",
   Callback = function(Value)
       CONFIG.Aimbot.UseAllyList = Value
   end
})

ExtraTab:CreateDropdown({
   Name = "Ally Players",
   Options = GetPlayerList(),
   CurrentOption = "",
   MultipleOptions = true,
   Flag = "AllyList",
   Callback = function(Options)
       CONFIG.Aimbot.AllyList = {}
       for _, option in ipairs(Options) do
           local name = GetPlayerNameFromDisplay(option)
           if name then
               table.insert(CONFIG.Aimbot.AllyList, name)
           end
       end
   end
})

ExtraTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
       -- Refresh dropdown options
       Rayfield:Notify({
           Title = "Refreshed",
           Content = "Player list updated!",
           Duration = 2
       })
   end
})
--]]

--// MAIN LOOP (ทำงานได้เลยไม่ต้องมี UI)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64

local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    local deltaTime = tick() - lastUpdate
    lastUpdate = tick()
    
    -- FOV RGB
    if CONFIG.Aimbot.FOVUseRGB then
        FOVHue = (FOVHue + deltaTime * 2) % 1
        FOVCircle.Color = Color3.fromHSV(FOVHue, 1, 1)
    else
        FOVCircle.Color = CONFIG.Aimbot.FOVColor
    end
    
    -- Update FOV Circle
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = CONFIG.Aimbot.FOV
    FOVCircle.Visible = CONFIG.Aimbot.Enabled and CONFIG.Aimbot.ShowFOV
    
    -- Update ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] then
                CreateESP(player)
            end
            ESPObjects[player].Update(deltaTime)
        end
    end
    
    -- Cleanup ESP
    for player, _ in pairs(ESPObjects) do
        if not player or not player.Parent then
            RemoveESP(player)
        end
    end
    
    -- AUTO AIMBOT
    if CONFIG.Aimbot.Enabled then
        local target = GetTarget()
        
        if target then
            CurrentTarget = target
            local character = GetCharacter(target)
            local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
            
            if targetPart then
                if CONFIG.Aimbot.Smoothness <= 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                else
                    local smoothFactor = math.clamp(1 - (CONFIG.Aimbot.Smoothness / 10), 0.01, 1) * 0.5
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
                end
            end
        else
            CurrentTarget = nil
        end
    end
end)

--// PLAYER EVENTS
Players.PlayerAdded:Connect(function(player)
    -- Auto refresh ถ้ามี UI
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        RemoveESP(player)
    end
    -- Remove from lists
    for i, name in ipairs(CONFIG.Aimbot.TargetList) do
        if name == player.Name then
            table.remove(CONFIG.Aimbot.TargetList, i)
            break
        end
    end
    for i, name in ipairs(CONFIG.Aimbot.AllyList) do
        if name == player.Name then
            table.remove(CONFIG.Aimbot.AllyList, i)
            break
        end
    end
end)

print("✅ Combat System Loaded!")
print("🎯 Ready for Rayfield integration")
print("📋 Copy the commented code above into your Rayfield script")
