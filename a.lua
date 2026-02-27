--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// CONFIGURATION
local CONFIG = {
    Aimbot = {
        Enabled = false,
        Mode = "FOV", -- "FOV", "Nearest", "FOV+Nearest"
        TeamCheck = false,
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
        Enabled = false,
        MaxDistance = 1000,
        TextSize = 13,
        TextColor = Color3.fromRGB(255, 50, 50),
        AllyColor = Color3.fromRGB(50, 255, 50),
        BoxColor = Color3.fromRGB(255, 0, 0),
        ShowName = false,
        ShowHealth = false,
        ShowDistance = false,
        ShowWeapon = false,
        TeamCheck = false,
        BoxESP = false,
        TracerESP = false,
        TracerPosition = "Bottom",
        TracerOutOfScreen = true, -- NEW: Draw to screen edge when off-screen
        Chams = false,
        UseRGB = false,
        RGBSpeed = 5
    },
    
    Player = {
        InfJump = false,
        WalkSpeed = 16,
        WalkSpeedEnabled = false,
        JumpPower = 50, -- Actually JumpHeight
        JumpPowerEnabled = false,
        OrbitEnabled = false,
        OrbitTarget = "All", -- "All" or specific player name
        OrbitDistance = 10,
        OrbitSpeed = 1
    },
    
    Mobile = {
        LockButtonEnabled = false,
        LockButtonPosition = UDim2.new(0.8, 0, 0.5, 0)
    },
    
    UI = {
        MainColor = Color3.fromRGB(0, 170, 255)
    }
}

--// VARIABLES
local ESPObjects = {}
local SharedHue = 0 -- Shared RGB hue for FOV and ESP
local FOVCircle = Drawing.new("Circle")
local MobileLockButton = nil
local OrbitConnection = nil
local InfJumpConnection = nil

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
    
    -- NEW: Tracer for out-of-screen targets
    local edgeTracer = Drawing.new("Line")
    edgeTracer.Thickness = 2
    edgeTracer.Visible = false
    espData.Drawings.EdgeTracer = edgeTracer
    
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
            displayColor = Color3.fromHSV(SharedHue, 1, 1)
        else
            if isTargeted then
                displayColor = Color3.fromRGB(255, 0, 255)
            else
                displayColor = isFriendly and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor
            end
        end
        
        for _, dr in pairs(espData.Drawings) do
            if typeof(dr) == "table" and dr.Color then
                dr.Color = displayColor
            end
        end
        
        local headPos, headOnScreen = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
        
        -- Handle off-screen tracer
        if CONFIG.ESP.TracerOutOfScreen and not (headOnScreen or rootOnScreen) then
            -- Calculate edge position
            local screenSize = Camera.ViewportSize
            local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
            local dir = (rootPos - center)
            if dir.Magnitude > 0 then
                dir = dir.Unit
                
                -- Find intersection with screen edge
                local edgePos = center + dir * math.min(screenSize.X, screenSize.Y) / 2
                edgePos = Vector2.new(
                    math.clamp(edgePos.X, 0, screenSize.X),
                    math.clamp(edgePos.Y, 0, screenSize.Y)
                )
                
                local tracerStart = center
                if CONFIG.ESP.TracerPosition == "Top" then
                    tracerStart = Vector2.new(screenSize.X / 2, 0)
                elseif CONFIG.ESP.TracerPosition == "Left" then
                    tracerStart = Vector2.new(0, screenSize.Y / 2)
                elseif CONFIG.ESP.TracerPosition == "Right" then
                    tracerStart = Vector2.new(screenSize.X, screenSize.Y / 2)
                elseif CONFIG.ESP.TracerPosition == "Bottom" then
                    tracerStart = Vector2.new(screenSize.X / 2, screenSize.Y)
                end
                
                espData.Drawings.EdgeTracer.From = tracerStart
                espData.Drawings.EdgeTracer.To = edgePos
                espData.Drawings.EdgeTracer.Color = displayColor
                espData.Drawings.EdgeTracer.Visible = CONFIG.ESP.TracerESP
            end
            espData.Drawings.Tracer.Visible = false
        else
            espData.Drawings.EdgeTracer.Visible = false
            
            if headOnScreen or rootOnScreen then
                local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                if CONFIG.ESP.TracerPosition == "Top" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
                elseif CONFIG.ESP.TracerPosition == "Left" then
                    tracerStart = Vector2.new(0, Camera.ViewportSize.Y / 2)
                elseif CONFIG.ESP.TracerPosition == "Right" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
                end
                
                espData.Drawings.Tracer.From = tracerStart
                espData.Drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                espData.Drawings.Tracer.Visible = CONFIG.ESP.TracerESP
            else
                espData.Drawings.Tracer.Visible = false
            end
        end
        
        -- Rest of ESP (boxes, names, etc.)
        local boxHeight = math.abs(headPos.Y - rootPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
        
        if CONFIG.ESP.ShowName and (headOnScreen or rootOnScreen) then
            local tag = isTargeted and " [TARGET]" or isAlly and " [ALLY]" or isTeammate and " [TEAM]" or " [ENEMY]"
            espData.Drawings.Name.Text = player.Name .. tag
            espData.Drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            espData.Drawings.Name.Visible = true
        else
            espData.Drawings.Name.Visible = false
        end
        
        if CONFIG.ESP.ShowHealth and (headOnScreen or rootOnScreen) then
            local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            espData.Drawings.Health.Text = hpPercent .. " HP"
            espData.Drawings.Health.Color = Color3.fromRGB(255 - (hpPercent * 2.55), hpPercent * 2.55, 0)
            espData.Drawings.Health.Position = Vector2.new(headPos.X, headPos.Y - 35)
            espData.Drawings.Health.Visible = true
        else
            espData.Drawings.Health.Visible = false
        end
        
        if CONFIG.ESP.ShowDistance and (headOnScreen or rootOnScreen) then
            espData.Drawings.Distance.Text = math.floor(distance) .. "m"
            espData.Drawings.Distance.Position = Vector2.new(headPos.X, rootPos.Y + 5)
            espData.Drawings.Distance.Visible = true
        else
            espData.Drawings.Distance.Visible = false
        end
        
        if CONFIG.ESP.BoxESP and (headOnScreen or rootOnScreen) then
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
        
        if CONFIG.ESP.Chams then
            if not espData.Highlight or espData.Highlight.Parent ~= character then
                if espData.Highlight then espData.Highlight:Destroy() end
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.FillColor = displayColor
                espData.Highlight.OutlineColor = Color3.new(1, 1, 1)
                espData.Highlight.FillTransparency = 0.5
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

--// AIMBOT LOGIC - 3 MODES
local function GetDistanceToMouse(player)
    local character = GetCharacter(player)
    if not character then return math.huge end
    local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
    if not targetPart then return math.huge end
    
    local screenPos, onScreen, depth = WorldToScreen(targetPart.Position)
    if not onScreen then return math.huge end
    
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude, depth
end

local function GetTarget()
    local mode = CONFIG.Aimbot.Mode
    
    -- Get valid targets first
    local validTargets = {}
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
        
        local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
        if distance > CONFIG.Aimbot.MaxDistance then continue end
        
        table.insert(validTargets, {
            Player = player,
            Part = targetPart,
            Distance3D = distance,
            ScreenPos, OnScreen, Depth = WorldToScreen(targetPart.Position)
        })
    end
    
    if #validTargets == 0 then return nil end
    
    -- Mode: FOV (closest to center of screen within FOV)
    if mode == "FOV" then
        local closest = nil
        local shortest = CONFIG.Aimbot.FOV
        for _, t in ipairs(validTargets) do
            if not t.OnScreen then continue end
            local dist2D = (Vector2.new(t.ScreenPos.X, t.ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if dist2D < shortest then
                shortest = dist2D
                closest = t.Player
            end
        end
        return closest
    end
    
    -- Mode: Nearest (closest 3D distance)
    if mode == "Nearest" then
        local nearest = nil
        local shortestDist = math.huge
        for _, t in ipairs(validTargets) do
            if t.Distance3D < shortestDist then
                shortestDist = t.Distance3D
                nearest = t.Player
            end
        end
        return nearest
    end
    
    -- Mode: FOV+Nearest (must be in FOV, then pick nearest 3D)
    if mode == "FOV+Nearest" then
        local candidates = {}
        for _, t in ipairs(validTargets) do
            if not t.OnScreen then continue end
            local dist2D = (Vector2.new(t.ScreenPos.X, t.ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if dist2D <= CONFIG.Aimbot.FOV then
                table.insert(candidates, t)
            end
        end
        
        if #candidates == 0 then return nil end
        
        -- Sort by 3D distance
        table.sort(candidates, function(a, b) return a.Distance3D < b.Distance3D end)
        return candidates[1].Player
    end
    
    return nil
end

--// MOBILE LOCK BUTTON
local function CreateMobileButton()
    if MobileLockButton then MobileLockButton:Destroy() end
    
    local button = Instance.new("ScreenGui")
    button.Name = "MobileLockButton"
    button.Parent = CoreGui
    button.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 60, 0, 60)
    frame.Position = CONFIG.Mobile.LockButtonPosition
    frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = button
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "LOCK"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local locked = false
    local lockTarget = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            locked = not locked
            
            if locked then
                -- Lock onto nearest
                lockTarget = GetTarget()
                if lockTarget then
                    frame.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    label.Text = "UNLOCK"
                else
                    locked = false
                end
            else
                lockTarget = nil
                frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                label.Text = "LOCK"
            end
        end
    end)
    
    -- Update position to config when dragged
    frame:GetPropertyChangedSignal("Position"):Connect(function()
        CONFIG.Mobile.LockButtonPosition = frame.Position
    end)
    
    MobileLockButton = button
    
    -- Return lock function
    return function()
        if locked and lockTarget then
            local char = GetCharacter(lockTarget)
            if char then
                local part = char:FindFirstChild(CONFIG.Aimbot.TargetPart)
                if part then
                    return part.Position
                end
            end
        end
        return nil
    end
end

local function DestroyMobileButton()
    if MobileLockButton then
        MobileLockButton:Destroy()
        MobileLockButton = nil
    end
end

--// ORBIT CAMERA
local function StartOrbit()
    if OrbitConnection then return end
    
    OrbitConnection = RunService.RenderStepped:Connect(function()
        if not CONFIG.Player.OrbitEnabled then return end
        
        local targetPos = nil
        
        if CONFIG.Player.OrbitTarget == "All" then
            -- Orbit around average position of all players
            local totalPos = Vector3.new(0, 0, 0)
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = GetCharacter(p)
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        totalPos = totalPos + char.HumanoidRootPart.Position
                        count = count + 1
                    end
                end
            end
            if count > 0 then
                targetPos = totalPos / count
            end
        else
            -- Orbit specific player
            local target = GetPlayerByName(CONFIG.Player.OrbitTarget)
            if target then
                local char = GetCharacter(target)
                if char and char:FindFirstChild("HumanoidRootPart") then
                    targetPos = char.HumanoidRootPart.Position
                end
            end
        end
        
        if targetPos then
            local time = tick() * CONFIG.Player.OrbitSpeed
            local dist = CONFIG.Player.OrbitDistance
            local offset = Vector3.new(
                math.cos(time) * dist,
                math.sin(time * 0.5) * dist * 0.3 + 5, -- Slight up/down
                math.sin(time) * dist
            )
            
            Camera.CFrame = CFrame.new(targetPos + offset, targetPos)
        end
    end)
end

local function StopOrbit()
    if OrbitConnection then
        OrbitConnection:Disconnect()
        OrbitConnection = nil
    end
end

--// RAYFIELD UI
local Window = Rayfield:CreateWindow({
    Name = "Venus x",
    LoadingTitle = "Venus x Loading",
    LoadingSubtitle = "by w1201s",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VenusX",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

--// TABS
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local PlayersTab = Window:CreateTab("Players", 4483362458)
local ColorsTab = Window:CreateTab("Colors", 4483362458)

--// AIMBOT TAB
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = CONFIG.Aimbot.Enabled,
    Flag = "AimbotEnabled",
    Callback = function(v) CONFIG.Aimbot.Enabled = v end
})

AimbotTab:CreateDropdown({
    Name = "Mode",
    Options = {"FOV", "Nearest", "FOV+Nearest"},
    CurrentOption = CONFIG.Aimbot.Mode,
    Flag = "AimbotMode",
    Callback = function(v) CONFIG.Aimbot.Mode = v end
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = CONFIG.Aimbot.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(v) CONFIG.Aimbot.TeamCheck = v end
})

AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = CONFIG.Aimbot.WallCheck,
    Flag = "WallCheck",
    Callback = function(v) CONFIG.Aimbot.WallCheck = v end
})

AimbotTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = CONFIG.Aimbot.ShowFOV,
    Flag = "ShowFOV",
    Callback = function(v) CONFIG.Aimbot.ShowFOV = v end
})

AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 400},
    Increment = 10,
    Suffix = "px",
    CurrentValue = CONFIG.Aimbot.FOV,
    Flag = "FOVSize",
    Callback = function(v) CONFIG.Aimbot.FOV = v end
})

AimbotTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 5000},
    Increment = 50,
    Suffix = "m",
    CurrentValue = CONFIG.Aimbot.MaxDistance,
    Flag = "MaxDistance",
    Callback = function(v) CONFIG.Aimbot.MaxDistance = v end
})

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = CONFIG.Aimbot.TargetPart,
    Flag = "TargetPart",
    Callback = function(v) CONFIG.Aimbot.TargetPart = v end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 10},
    Increment = 0.5,
    Suffix = "",
    CurrentValue = CONFIG.Aimbot.Smoothness,
    Flag = "Smoothness",
    Callback = function(v) CONFIG.Aimbot.Smoothness = v end
})

-- Mobile Button Toggle
AimbotTab:CreateToggle({
    Name = "Mobile Lock Button",
    CurrentValue = CONFIG.Mobile.LockButtonEnabled,
    Flag = "MobileButton",
    Callback = function(v)
        CONFIG.Mobile.LockButtonEnabled = v
        if v then
            CreateMobileButton()
        else
            DestroyMobileButton()
        end
    end
})

--// ESP TAB
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = CONFIG.ESP.Enabled,
    Flag = "ESPEnabled",
    Callback = function(v) CONFIG.ESP.Enabled = v end
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = CONFIG.ESP.TeamCheck,
    Flag = "ESPTeamCheck",
    Callback = function(v) CONFIG.ESP.TeamCheck = v end
})

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = CONFIG.ESP.BoxESP,
    Flag = "BoxESP",
    Callback = function(v) CONFIG.ESP.BoxESP = v end
})

ESPTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = CONFIG.ESP.TracerESP,
    Flag = "TracerESP",
    Callback = function(v) CONFIG.ESP.TracerESP = v end
})

ESPTab:CreateToggle({
    Name = "Tracer When Off-Screen",
    CurrentValue = CONFIG.ESP.TracerOutOfScreen,
    Flag = "TracerOutOfScreen",
    Callback = function(v) CONFIG.ESP.TracerOutOfScreen = v end
})

ESPTab:CreateDropdown({
    Name = "Tracer Position",
    Options = {"Bottom", "Top", "Left", "Right"},
    CurrentOption = CONFIG.ESP.TracerPosition,
    Flag = "TracerPosition",
    Callback = function(v) CONFIG.ESP.TracerPosition = v end
})

ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = CONFIG.ESP.Chams,
    Flag = "Chams",
    Callback = function(v) CONFIG.ESP.Chams = v end
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = CONFIG.ESP.ShowName,
    Flag = "ShowNames",
    Callback = function(v) CONFIG.ESP.ShowName = v end
})

ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = CONFIG.ESP.ShowHealth,
    Flag = "ShowHealth",
    Callback = function(v) CONFIG.ESP.ShowHealth = v end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = CONFIG.ESP.ShowDistance,
    Flag = "ShowDistance",
    Callback = function(v) CONFIG.ESP.ShowDistance = v end
})

ESPTab:CreateToggle({
    Name = "Show Weapon",
    CurrentValue = CONFIG.ESP.ShowWeapon,
    Flag = "ShowWeapon",
    Callback = function(v) CONFIG.ESP.ShowWeapon = v end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 5000},
    Increment = 100,
    Suffix = "m",
    CurrentValue = CONFIG.ESP.MaxDistance,
    Flag = "ESPMaxDistance",
    Callback = function(v) CONFIG.ESP.MaxDistance = v end
})

--// PLAYERS TAB
PlayersTab:CreateSection("Movement")

PlayersTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = CONFIG.Player.InfJump,
    Flag = "InfJump",
    Callback = function(v)
        CONFIG.Player.InfJump = v
        if v then
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = GetCharacter(LocalPlayer)
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if InfJumpConnection then
                InfJumpConnection:Disconnect()
                InfJumpConnection = nil
            end
        end
    end
})

PlayersTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = CONFIG.Player.WalkSpeedEnabled,
    Flag = "WalkSpeedToggle",
    Callback = function(v)
        CONFIG.Player.WalkSpeedEnabled = v
        local char = GetCharacter(LocalPlayer)
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = v and CONFIG.Player.WalkSpeed or 16
            end
        end
    end
})

PlayersTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = CONFIG.Player.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(v)
        CONFIG.Player.WalkSpeed = v
        if CONFIG.Player.WalkSpeedEnabled then
            local char = GetCharacter(LocalPlayer)
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = v
                end
            end
        end
    end
})

PlayersTab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = CONFIG.Player.JumpPowerEnabled,
    Flag = "JumpPowerToggle",
    Callback = function(v)
        CONFIG.Player.JumpPowerEnabled = v
        local char = GetCharacter(LocalPlayer)
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Use JumpHeight instead of deprecated JumpPower
                humanoid.JumpHeight = v and CONFIG.Player.JumpPower / 10 or 5
            end
        end
    end
})

PlayersTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = CONFIG.Player.JumpPower,
    Flag = "JumpPower",
    Callback = function(v)
        CONFIG.Player.JumpPower = v
        if CONFIG.Player.JumpPowerEnabled then
            local char = GetCharacter(LocalPlayer)
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpHeight = v / 10
                end
            end
        end
    end
})

PlayersTab:CreateSection("Orbit Camera")

PlayersTab:CreateToggle({
    Name = "Enable Orbit",
    CurrentValue = CONFIG.Player.OrbitEnabled,
    Flag = "OrbitEnabled",
    Callback = function(v)
        CONFIG.Player.OrbitEnabled = v
        if v then
            StartOrbit()
        else
            StopOrbit()
        end
    end
})

PlayersTab:CreateDropdown({
    Name = "Orbit Target",
    Options = {"All"},
    CurrentOption = CONFIG.Player.OrbitTarget,
    Flag = "OrbitTarget",
    Callback = function(v) CONFIG.Player.OrbitTarget = v end
})

PlayersTab:CreateSlider({
    Name = "Orbit Distance",
    Range = {5, 100},
    Increment = 1,
    Suffix = "m",
    CurrentValue = CONFIG.Player.OrbitDistance,
    Flag = "OrbitDistance",
    Callback = function(v) CONFIG.Player.OrbitDistance = v end
})

PlayersTab:CreateSlider({
    Name = "Orbit Speed",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = CONFIG.Player.OrbitSpeed,
    Flag = "OrbitSpeed",
    Callback = function(v) CONFIG.Player.OrbitSpeed = v end
})

PlayersTab:CreateSection("Target & Ally")

PlayersTab:CreateToggle({
    Name = "Use Target List",
    CurrentValue = CONFIG.Aimbot.UseTargetList,
    Flag = "UseTargetList",
    Callback = function(v) CONFIG.Aimbot.UseTargetList = v end
})

local targetDropdown = PlayersTab:CreateDropdown({
    Name = "Target Players",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "TargetDropdown",
    Callback = function(v)
        CONFIG.Aimbot.TargetList = v
    end
})

PlayersTab:CreateButton({
    Name = "🔄 Refresh Target List",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        targetDropdown:Refresh(names)
        Rayfield:Notify({
            Title = "Target List",
            Content = #names .. " players",
            Duration = 2
        })
    end
})

PlayersTab:CreateToggle({
    Name = "Use Ally List",
    CurrentValue = CONFIG.Aimbot.UseAllyList,
    Flag = "UseAllyList",
    Callback = function(v) CONFIG.Aimbot.UseAllyList = v end
})

local allyDropdown = PlayersTab:CreateDropdown({
    Name = "Ally Players",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AllyDropdown",
    Callback = function(v)
        CONFIG.Aimbot.AllyList = v
    end
})

PlayersTab:CreateButton({
    Name = "🔄 Refresh Ally List",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        allyDropdown:Refresh(names)
        Rayfield:Notify({
            Title = "Ally List",
            Content = #names .. " players",
            Duration = 2
        })
    end
})

--// COLORS TAB
ColorsTab:CreateSection("RGB Settings")

ColorsTab:CreateToggle({
    Name = "Sync FOV + ESP RGB",
    CurrentValue = CONFIG.ESP.UseRGB,
    Flag = "SyncRGB",
    Callback = function(v)
        CONFIG.ESP.UseRGB = v
        CONFIG.Aimbot.FOVUseRGB = v
    end
})

ColorsTab:CreateSlider({
    Name = "RGB Speed",
    Range = {1, 20},
    Increment = 0.5,
    Suffix = "",
    CurrentValue = CONFIG.ESP.RGBSpeed,
    Flag = "RGBSpeed",
    Callback = function(v) CONFIG.ESP.RGBSpeed = v end
})

ColorsTab:CreateSection("Colors")

ColorsTab:CreateColorPicker({
    Name = "Enemy Color",
    Color = CONFIG.ESP.TextColor,
    Flag = "EnemyColor",
    Callback = function(c) CONFIG.ESP.TextColor = c end
})

ColorsTab:CreateColorPicker({
    Name = "Ally Color",
    Color = CONFIG.ESP.AllyColor,
    Flag = "AllyColor",
    Callback = function(c) CONFIG.ESP.AllyColor = c end
})

ColorsTab:CreateColorPicker({
    Name = "FOV Color",
    Color = CONFIG.Aimbot.FOVColor,
    Flag = "FOVColor",
    Callback = function(c) CONFIG.Aimbot.FOVColor = c end
})

--// MAIN LOOP
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64

local MobileGetLock = nil

RunService.RenderStepped:Connect(function()
    local deltaTime = task.wait()
    
    -- Shared RGB
    if CONFIG.ESP.UseRGB or CONFIG.Aimbot.FOVUseRGB then
        SharedHue = (SharedHue + deltaTime * CONFIG.ESP.RGBSpeed * 0.1) % 1
        local color = Color3.fromHSV(SharedHue, 1, 1)
        FOVCircle.Color = color
    else
        FOVCircle.Color = CONFIG.Aimbot.FOVColor
    end
    
    -- FOV Circle
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = CONFIG.Aimbot.FOV
    FOVCircle.Visible = CONFIG.Aimbot.Enabled and CONFIG.Aimbot.ShowFOV and 
        (CONFIG.Aimbot.Mode == "FOV" or CONFIG.Aimbot.Mode == "FOV+Nearest")
    
    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] then CreateESP(player) end
            ESPObjects[player].Update(deltaTime)
        end
    end
    
    for player, _ in pairs(ESPObjects) do
        if not player or not player.Parent then RemoveESP(player) end
    end
    
    -- AIMBOT
    if CONFIG.Aimbot.Enabled then
        local target = nil
        
        -- Check mobile button lock
        if MobileGetLock then
            local lockPos = MobileGetLock()
            if lockPos then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockPos)
                return -- Skip normal aimbot if mobile locked
            end
        end
        
        target = GetTarget()
        if target then
            local character = GetCharacter(target)
            local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
            if targetPart then
                -- INSTANT LOCK - No delay, direct CFrame
                if CONFIG.Aimbot.Smoothness <= 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                else
                    local smooth = math.clamp(1 - (CONFIG.Aimbot.Smoothness / 10), 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(
                        CFrame.new(Camera.CFrame.Position, targetPart.Position), 
                        smooth
                    )
                end
            end
        end
    end
    
    -- Auto WalkSpeed/JumpHeight
    local char = GetCharacter(LocalPlayer)
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if CONFIG.Player.WalkSpeedEnabled and humanoid.WalkSpeed ~= CONFIG.Player.WalkSpeed then
                humanoid.WalkSpeed = CONFIG.Player.WalkSpeed
            end
            if CONFIG.Player.JumpPowerEnabled and math.abs(humanoid.JumpHeight - (CONFIG.Player.JumpPower / 10)) > 0.1 then
                humanoid.JumpHeight = CONFIG.Player.JumpPower / 10
            end
        end
    end
end)

--// INIT
task.spawn(function()
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    task.wait(1)
    
    -- Setup mobile button if enabled
    if CONFIG.Mobile.LockButtonEnabled then
        MobileGetLock = CreateMobileButton()
    end
    
    -- Refresh dropdowns
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    targetDropdown:Refresh(names)
    allyDropdown:Refresh(names)
    
    -- Update orbit target options
    local orbitOptions = {"All"}
    for _, n in ipairs(names) do table.insert(orbitOptions, n) end
    
    print("✅ Venus x Rayfield Loaded!")
end)
