--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// LOAD WINDUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// CONFIGURATION
local CONFIG = {
    Aimbot = {
        Enabled = false,
        Mode = "Normal", -- "Normal" or "Target"
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0,
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
        TracerPosition = "Bottom",
        Chams = true,
        UseRGB = false,
        RGBSpeed = 5
    },
    
    UI = {
        MainColor = Color3.fromRGB(0, 170, 255)
    }
}

--// VARIABLES
local ESPObjects = {}
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

local function GetPlayerByName(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name then return p end
    end
    return nil
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
        local isTargeted = CONFIG.Aimbot.UseTargetList and IsInTargetList(player)
        local isFriendly = isTeammate or isAlly
        
        local displayColor
        if CONFIG.ESP.UseRGB then
            ESPHue = (ESPHue + deltaTime * CONFIG.ESP.RGBSpeed * 0.1) % 1
            displayColor = Color3.fromHSV(ESPHue, 1, 1)
        else
            if isTargeted then
                displayColor = Color3.fromRGB(255, 0, 255) -- Magenta for targets
            else
                displayColor = isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor
            end
        end
        
        espData.Drawings.Name.Color = displayColor
        espData.Drawings.Box.Color = displayColor
        espData.Drawings.FilledBox.Color = displayColor
        espData.Drawings.Tracer.Color = displayColor
        
        local headPos, headOnScreen = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
        
        if not headOnScreen and not rootOnScreen then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if espData.Highlight then espData.Highlight.Enabled = false end
            return
        end
        
        local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        if CONFIG.ESP.TracerPosition == "Top" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
        elseif CONFIG.ESP.TracerPosition == "Left" then
            tracerStart = Vector2.new(0, Camera.ViewportSize.Y / 2)
        elseif CONFIG.ESP.TracerPosition == "Right" then
            tracerStart = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
        end
        
        local boxHeight = math.abs(headPos.Y - rootPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
        
        if CONFIG.ESP.ShowName then
            local tag = ""
            if isTargeted then
                tag = " [TARGET]"
            elseif isAlly then
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
            espData.Drawings.Tracer.From = tracerStart
            espData.Drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            espData.Drawings.Tracer.Visible = true
        else
            espData.Drawings.Tracer.Visible = false
        end
        
        if CONFIG.ESP.Chams then
            if not espData.Highlight or espData.Highlight.Parent ~= character then
                if espData.Highlight then espData.Highlight:Destroy() end
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.FillColor = displayColor
                espData.Highlight.OutlineColor = Color3.new(1, 1, 1)
                espData.Highlight.FillTransparency = 0.5
                espData.Highlight.OutlineTransparency = 0
                espData.Highlight.Parent = character
            end
            espData.Highlight.Enabled = true
            espData.Highlight.FillColor = displayColor
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

--// AIMBOT LOGIC - HARD LOCK TARGET MODE
local function GetTarget()
    -- TARGET MODE: Hard Lock - No FOV, No OnScreen, pure lock
    if CONFIG.Aimbot.Mode == "Target" and CONFIG.Aimbot.UseTargetList then
        for _, targetName in ipairs(CONFIG.Aimbot.TargetList) do
            local player = GetPlayerByName(targetName)
            if player and player ~= LocalPlayer then
                if IsAlive(GetCharacter(player)) then
                    if CONFIG.Aimbot.TeamCheck and IsTeammate(player) then continue end
                    if CONFIG.Aimbot.UseAllyList and IsInAllyList(player) then continue end
                    
                    local character = GetCharacter(player)
                    local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
                    if targetPart then
                        -- Only wall check and distance
                        if CONFIG.Aimbot.WallCheck and not IsVisible(targetPart) then continue end
                        
                        local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
                        if distance <= CONFIG.Aimbot.MaxDistance then
                            return player -- LOCKED! No FOV, no OnScreen!
                        end
                    end
                end
            end
        end
        return nil
    end
    
    -- NORMAL MODE: Use FOV + OnScreen
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
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    return closestPlayer
end

--// WINDUI SETUP
local Window = WindUI:CreateWindow({
    Title = "Combat System",
    Icon = "sword",
    Author = "by Kimi",
    Folder = "CombatSystem",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(400, 300),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    Transparent = true
})

--// TABS
local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "target"
})

local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "eye"
})

local PlayersTab = Window:Tab({
    Title = "Players",
    Icon = "users"
})

local ColorsTab = Window:Tab({
    Title = "Colors",
    Icon = "palette"
})

--// AIMBOT TAB
AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Desc = "Toggle aimbot on/off",
    Value = CONFIG.Aimbot.Enabled,
    Callback = function(v) CONFIG.Aimbot.Enabled = v end
})

AimbotTab:Dropdown({
    Title = "Mode",
    Desc = "Normal = FOV circle | Target = Hard Lock (No FOV, follows everywhere)",
    Values = {"Normal", "Target"},
    Value = CONFIG.Aimbot.Mode,
    Callback = function(v) 
        CONFIG.Aimbot.Mode = v 
        WindUI:Notify({
            Title = "Mode: " .. v,
            Content = v == "Target" and "🔒 HARD LOCK: Follows target everywhere!" or "📍 Normal: Uses FOV circle",
            Duration = 3,
            Icon = v == "Target" and "lock" or "target"
        })
    end
})

AimbotTab:Toggle({
    Title = "Team Check",
    Desc = "Ignore teammates",
    Value = CONFIG.Aimbot.TeamCheck,
    Callback = function(v) CONFIG.Aimbot.TeamCheck = v end
})

AimbotTab:Toggle({
    Title = "Wall Check",
    Desc = "Check visibility (disable for true silent aim)",
    Value = CONFIG.Aimbot.WallCheck,
    Callback = function(v) CONFIG.Aimbot.WallCheck = v end
})

AimbotTab:Toggle({
    Title = "Show FOV",
    Desc = "Show FOV circle (Normal mode only)",
    Value = CONFIG.Aimbot.ShowFOV,
    Callback = function(v) CONFIG.Aimbot.ShowFOV = v end
})

AimbotTab:Slider({
    Title = "FOV Size",
    Desc = "FOV radius (Normal mode only)",
    Step = 10,
    Value = {Min = 50, Max = 400, Default = CONFIG.Aimbot.FOV},
    Callback = function(v) CONFIG.Aimbot.FOV = v end
})

AimbotTab:Slider({
    Title = "Max Distance",
    Desc = "Maximum lock distance",
    Step = 50,
    Value = {Min = 100, Max = 5000, Default = CONFIG.Aimbot.MaxDistance},
    Callback = function(v) CONFIG.Aimbot.MaxDistance = v end
})

AimbotTab:Dropdown({
    Title = "Target Part",
    Desc = "Aim at body part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Value = CONFIG.Aimbot.TargetPart,
    Callback = function(v) CONFIG.Aimbot.TargetPart = v end
})

AimbotTab:Slider({
    Title = "Smoothness",
    Desc = "Aim smoothing (0 = instant, only for Normal)",
    Step = 0.5,
    Value = {Min = 0, Max = 10, Default = CONFIG.Aimbot.Smoothness},
    Callback = function(v) CONFIG.Aimbot.Smoothness = v end
})

--// ESP TAB
ESPTab:Toggle({
    Title = "Enable ESP",
    Desc = "Toggle ESP on/off",
    Value = CONFIG.ESP.Enabled,
    Callback = function(v) CONFIG.ESP.Enabled = v end
})

ESPTab:Toggle({
    Title = "Team Check",
    Desc = "Different color for teammates",
    Value = CONFIG.ESP.TeamCheck,
    Callback = function(v) CONFIG.ESP.TeamCheck = v end
})

ESPTab:Toggle({
    Title = "Box ESP",
    Desc = "Show box around players",
    Value = CONFIG.ESP.BoxESP,
    Callback = function(v) CONFIG.ESP.BoxESP = v end
})

ESPTab:Toggle({
    Title = "Tracer ESP",
    Desc = "Show lines to players",
    Value = CONFIG.ESP.TracerESP,
    Callback = function(v) CONFIG.ESP.TracerESP = v end
})

ESPTab:Dropdown({
    Title = "Tracer Position",
    Desc = "Where tracer starts",
    Values = {"Bottom", "Top", "Left", "Right"},
    Value = CONFIG.ESP.TracerPosition,
    Callback = function(v) CONFIG.ESP.TracerPosition = v end
})

ESPTab:Toggle({
    Title = "Chams",
    Desc = "Highlight through walls",
    Value = CONFIG.ESP.Chams,
    Callback = function(v) CONFIG.ESP.Chams = v end
})

ESPTab:Toggle({
    Title = "Show Names",
    Desc = "Display player names",
    Value = CONFIG.ESP.ShowName,
    Callback = function(v) CONFIG.ESP.ShowName = v end
})

ESPTab:Toggle({
    Title = "Show Health",
    Desc = "Display health",
    Value = CONFIG.ESP.ShowHealth,
    Callback = function(v) CONFIG.ESP.ShowHealth = v end
})

ESPTab:Toggle({
    Title = "Show Distance",
    Desc = "Display distance",
    Value = CONFIG.ESP.ShowDistance,
    Callback = function(v) CONFIG.ESP.ShowDistance = v end
})

ESPTab:Toggle({
    Title = "Show Weapon",
    Desc = "Display weapon",
    Value = CONFIG.ESP.ShowWeapon,
    Callback = function(v) CONFIG.ESP.ShowWeapon = v end
})

ESPTab:Slider({
    Title = "Max Distance",
    Desc = "Maximum ESP distance",
    Step = 100,
    Value = {Min = 100, Max = 5000, Default = CONFIG.ESP.MaxDistance},
    Callback = function(v) CONFIG.ESP.MaxDistance = v end
})

--// PLAYERS TAB
PlayersTab:Section({Title = "Target System", Opened = true})

PlayersTab:Toggle({
    Title = "Use Target List",
    Desc = "Enable Target mode (required for Hard Lock)",
    Value = CONFIG.Aimbot.UseTargetList,
    Callback = function(v) 
        CONFIG.Aimbot.UseTargetList = v 
        WindUI:Notify({
            Title = "Target List " .. (v and "ON" or "OFF"),
            Content = v and "Select targets below for Hard Lock" or "Disabled",
            Duration = 2,
            Icon = v and "check" or "x"
        })
    end
})

local targetDropdown = PlayersTab:Dropdown({
    Title = "Target Players",
    Desc = "Select for Hard Lock (magenta [TARGET] in ESP)",
    Values = {},
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        CONFIG.Aimbot.TargetList = selected
    end
})

PlayersTab:Button({
    Title = "🔄 Refresh Target List",
    Desc = "Update player list",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        targetDropdown:Refresh(names)
        WindUI:Notify({
            Title = "Target List",
            Content = #names .. " players",
            Duration = 2,
            Icon = "refresh-cw"
        })
    end
})

PlayersTab:Section({Title = "Ally System", Opened = false})

PlayersTab:Toggle({
    Title = "Use Ally List",
    Desc = "Ignore selected allies",
    Value = CONFIG.Aimbot.UseAllyList,
    Callback = function(v) CONFIG.Aimbot.UseAllyList = v end
})

local allyDropdown = PlayersTab:Dropdown({
    Title = "Ally Players",
    Desc = "Select to ignore",
    Values = {},
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        CONFIG.Aimbot.AllyList = selected
    end
})

PlayersTab:Button({
    Title = "🔄 Refresh Ally List",
    Desc = "Update player list",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        allyDropdown:Refresh(names)
        WindUI:Notify({
            Title = "Ally List",
            Content = #names .. " players",
            Duration = 2,
            Icon = "refresh-cw"
        })
    end
})

--// COLORS TAB
ColorsTab:Section({Title = "ESP Colors", Opened = true})

ColorsTab:Toggle({
    Title = "ESP RGB Mode",
    Desc = "Rainbow cycling",
    Value = CONFIG.ESP.UseRGB,
    Callback = function(v) CONFIG.ESP.UseRGB = v end
})

ColorsTab:Slider({
    Title = "RGB Speed",
    Desc = "Cycling speed",
    Step = 0.5,
    Value = {Min = 1, Max = 20, Default = CONFIG.ESP.RGBSpeed},
    Callback = function(v) CONFIG.ESP.RGBSpeed = v end
})

ColorsTab:Colorpicker({
    Title = "Enemy Color",
    Desc = "For enemies",
    Default = CONFIG.ESP.TextColor,
    Callback = function(c) CONFIG.ESP.TextColor = c end
})

ColorsTab:Colorpicker({
    Title = "Ally Color",
    Desc = "For allies",
    Default = CONFIG.ESP.AllyColor,
    Callback = function(c) CONFIG.ESP.AllyColor = c end
})

ColorsTab:Colorpicker({
    Title = "Box Color",
    Desc = "Box color",
    Default = CONFIG.ESP.BoxColor,
    Callback = function(c) CONFIG.ESP.BoxColor = c end
})

ColorsTab:Section({Title = "FOV Colors", Opened = false})

ColorsTab:Toggle({
    Title = "FOV RGB Mode",
    Desc = "Rainbow FOV",
    Value = CONFIG.Aimbot.FOVUseRGB,
    Callback = function(v) CONFIG.Aimbot.FOVUseRGB = v end
})

ColorsTab:Colorpicker({
    Title = "FOV Circle Color",
    Desc = "FOV color",
    Default = CONFIG.Aimbot.FOVColor,
    Callback = function(c) CONFIG.Aimbot.FOVColor = c end
})

--// MAIN LOOP
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    local deltaTime = task.wait()
    
    -- FOV RGB
    if CONFIG.Aimbot.FOVUseRGB then
        FOVHue = (FOVHue + deltaTime * CONFIG.ESP.RGBSpeed * 0.1) % 1
        FOVCircle.Color = Color3.fromHSV(FOVHue, 1, 1)
    else
        FOVCircle.Color = CONFIG.Aimbot.FOVColor
    end
    
    -- FOV Circle (Normal mode only)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = CONFIG.Aimbot.FOV
    FOVCircle.Visible = CONFIG.Aimbot.Enabled and CONFIG.Aimbot.ShowFOV and CONFIG.Aimbot.Mode == "Normal"
    
    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] then CreateESP(player) end
            ESPObjects[player].Update(deltaTime)
        end
    end
    
    -- Cleanup
    for player, _ in pairs(ESPObjects) do
        if not player or not player.Parent then RemoveESP(player) end
    end
    
    -- AIMBOT
    if CONFIG.Aimbot.Enabled then
        local target = GetTarget()
        if target then
            local character = GetCharacter(target)
            local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
            if targetPart then
                if CONFIG.Aimbot.Mode == "Target" then
                    -- HARD LOCK: Instant, no smoothness, follows everywhere
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                else
                    -- Normal mode
                    if CONFIG.Aimbot.Smoothness <= 0 then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    else
                        local smoothFactor = math.clamp(1 - (CONFIG.Aimbot.Smoothness / 10), 0.01, 1) * 0.5
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), smoothFactor)
                    end
                end
            end
        end
    end
end)

--// INIT
task.spawn(function()
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    task.wait(1)
    
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    targetDropdown:Refresh(names)
    allyDropdown:Refresh(names)
    
    WindUI:Notify({
        Title = "🔒 Combat System Loaded",
        Content = "Hard Lock Target Mode Ready!",
        Duration = 3,
        Icon = "zap"
    })
end)

print("✅ Combat System Loaded!")
print("🔒 Target Mode = Hard Lock (No FOV, follows everywhere)")
