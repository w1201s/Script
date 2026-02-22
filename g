--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// CONFIGURATION
local CONFIG = {
    -- Aimbot Settings
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        InstantLock = true,
        Smoothness = 0, -- 0 = instant, higher = smoother
        FOV = 200,
        MaxDistance = 1000,
        TargetPart = "Head", -- Head, HumanoidRootPart, Torso
        TriggerKey = Enum.UserInputType.MouseButton2, -- Right click
        MobileTrigger = Enum.UserInputType.Touch -- For mobile
    },
    
    -- ESP Settings
    ESP = {
        Enabled = true,
        MaxDistance = 1000,
        TextSize = 14,
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
        Chams = true
    }
}

--// VARIABLES
local ESPObjects = {}
local CurrentTarget = nil
local AimbotActive = false
local UIVisible = true
local Dragging = nil
local DragStart = nil
local StartPos = nil

--// UTILITY FUNCTIONS
local function CreateTween(obj, info, properties)
    return TweenService:Create(obj, info, properties)
end

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
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = CONFIG.Aimbot.FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(GetCharacter(player)) then continue end
        
        if CONFIG.Aimbot.TeamCheck and IsTeammate(player) then continue end
        
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

--// ESP SYSTEM
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local espData = {
        Player = player,
        Drawings = {},
        Connections = {}
    }
    
    -- Name
    local nameText = Drawing.new("Text")
    nameText.Center = true
    nameText.Outline = true
    nameText.Size = CONFIG.ESP.TextSize
    espData.Drawings.Name = nameText
    
    -- Health
    local healthText = Drawing.new("Text")
    healthText.Center = true
    healthText.Outline = true
    healthText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Health = healthText
    
    -- Distance
    local distText = Drawing.new("Text")
    distText.Center = true
    distText.Outline = true
    distText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Distance = distText
    
    -- Weapon
    local weaponText = Drawing.new("Text")
    weaponText.Center = true
    weaponText.Outline = true
    weaponText.Size = CONFIG.ESP.TextSize - 2
    espData.Drawings.Weapon = weaponText
    
    -- Box
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    espData.Drawings.Box = box
    
    -- Filled Box
    local filledBox = Drawing.new("Square")
    filledBox.Thickness = 1
    filledBox.Filled = true
    filledBox.Transparency = 0.2
    filledBox.Visible = false
    espData.Drawings.FilledBox = filledBox
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    espData.Drawings.Tracer = tracer
    
    -- Chams Highlight
    local highlight = nil
    
    espData.Update = function()
        if not CONFIG.ESP.Enabled then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        local character = GetCharacter(player)
        if not IsAlive(character) then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        -- Distance check
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > CONFIG.ESP.MaxDistance then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        -- Team check for colors
        local isTeammate = IsTeammate(player)
        if CONFIG.ESP.TeamCheck and isTeammate then
            nameText.Color = CONFIG.ESP.AllyColor
            box.Color = CONFIG.ESP.AllyColor
            filledBox.Color = CONFIG.ESP.AllyColor
            tracer.Color = CONFIG.ESP.AllyColor
        else
            nameText.Color = CONFIG.ESP.TextColor
            box.Color = CONFIG.ESP.BoxColor
            filledBox.Color = CONFIG.ESP.BoxColor
            tracer.Color = CONFIG.ESP.BoxColor
        end
        
        -- Screen position
        local headPos, headOnScreen = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
        
        if not headOnScreen and not rootOnScreen then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        -- Calculate box
        local boxHeight = math.abs(headPos.Y - rootPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
        
        -- Update drawings
        if CONFIG.ESP.ShowName then
            nameText.Text = player.Name .. (isTeammate and " [ALLY]" or " [ENEMY]")
            nameText.Position = Vector2.new(headPos.X, headPos.Y - 20)
            nameText.Visible = true
        else
            nameText.Visible = false
        end
        
        if CONFIG.ESP.ShowHealth then
            local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            healthText.Text = hpPercent .. " HP"
            healthText.Color = Color3.fromRGB(255 - (hpPercent * 2.55), hpPercent * 2.55, 0)
            healthText.Position = Vector2.new(headPos.X, headPos.Y - 35)
            healthText.Visible = true
        else
            healthText.Visible = false
        end
        
        if CONFIG.ESP.ShowDistance then
            distText.Text = math.floor(distance) .. "m"
            distText.Position = Vector2.new(headPos.X, rootPos.Y + 5)
            distText.Visible = true
        else
            distText.Visible = false
        end
        
        if CONFIG.ESP.ShowWeapon then
            weaponText.Text = "Weapon: " .. GetWeaponName(character)
            weaponText.Position = Vector2.new(headPos.X, rootPos.Y + 20)
            weaponText.Visible = true
        else
            weaponText.Visible = false
        end
        
        if CONFIG.ESP.BoxESP then
            box.Size = Vector2.new(boxWidth, boxHeight)
            box.Position = boxPos
            box.Visible = true
            
            filledBox.Size = Vector2.new(boxWidth, boxHeight)
            filledBox.Position = boxPos
            filledBox.Visible = CONFIG.ESP.Chams
        else
            box.Visible = false
            filledBox.Visible = false
        end
        
        if CONFIG.ESP.TracerESP then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            tracer.From = screenCenter
            tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            tracer.Visible = true
        else
            tracer.Visible = false
        end
        
        -- Chams
        if CONFIG.ESP.Chams then
            if not highlight or highlight.Parent ~= character then
                if highlight then highlight:Destroy() end
                highlight = Instance.new("Highlight")
                highlight.FillColor = isTeammate and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = character
            end
            highlight.Enabled = true
            highlight.FillColor = isTeammate and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor
        elseif highlight then
            highlight.Enabled = false
        end
    end
    
    espData.Cleanup = function()
        for _, drawing in pairs(espData.Drawings) do
            drawing:Remove()
        end
        if highlight then highlight:Destroy() end
        for _, conn in pairs(espData.Connections) do
            conn:Disconnect()
        end
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

--// UI CREATION (Lightweight & Animated)
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Mobile support detection
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Fix corner for title bar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 20)
    TitleFix.Position = UDim2.new(0, 0, 1, -20)
    TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚔️ COMBAT MASTER"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Version
    local VersionText = Instance.new("TextLabel")
    VersionText.Name = "Version"
    VersionText.Size = UDim2.new(0, 50, 0, 20)
    VersionText.Position = UDim2.new(0, 15, 0.5, 5)
    VersionText.BackgroundTransparency = 1
    VersionText.Text = "v2.0"
    VersionText.TextColor3 = Color3.fromRGB(150, 150, 150)
    VersionText.TextSize = 12
    VersionText.Font = Enum.Font.Gotham
    VersionText.TextXAlignment = Enum.TextXAlignment.Left
    VersionText.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 0, 40)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, -20, 1, -105)
    ContentContainer.Position = UDim2.new(0, 10, 0, 100)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer
    
    --// TOGGLE BUTTON (Outside UI - Draggable)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleUI"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    ToggleBtn.Text = "⚔️"
    ToggleBtn.TextSize = 24
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ScreenGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0) -- Circle
    ToggleCorner.Parent = ToggleBtn
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleBtn
    
    -- Toggle Button Shadow
    local ToggleShadow = Instance.new("ImageLabel")
    ToggleShadow.Name = "Shadow"
    ToggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleShadow.BackgroundTransparency = 1
    ToggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleShadow.Size = UDim2.new(1, 20, 1, 20)
    ToggleShadow.ZIndex = -1
    ToggleShadow.Image = "rbxassetid://5554236805"
    ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ToggleShadow.ImageTransparency = 0.4
    ToggleShadow.ScaleType = Enum.ScaleType.Slice
    ToggleShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    ToggleShadow.Parent = ToggleBtn
    
    --// ANIMATION FUNCTIONS
    local function AnimateIn(obj)
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Visible = true
        local tween = CreateTween(obj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 320, 0, 400)
        })
        tween:Play()
    end
    
    local function AnimateOut(obj, callback)
        local tween = CreateTween(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween.Completed:Connect(function()
            obj.Visible = false
            if callback then callback() end
        end)
        tween:Play()
    end
    
    local function ButtonPress(btn)
        local originalSize = btn.Size
        local tween = CreateTween(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, originalSize.Y.Scale, originalSize.Y.Offset * 0.95)
        })
        tween:Play()
        tween.Completed:Connect(function()
            CreateTween(btn, TweenInfo.new(0.1), {
                Size = originalSize
            }):Play()
        end)
    end
    
    --// TAB SYSTEM
    local Tabs = {}
    local CurrentTab = nil
    
    local function CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Size = UDim2.new(0, 100, 0, 30)
        tabBtn.Position = UDim2.new(0, #Tabs * 105 + 5, 0.5, -15)
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabBtn.Text = icon .. " " .. name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.TextSize = 12
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn
        
        local content = Instance.new("ScrollingFrame")
        content.Name = name .. "Content"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        content.Visible = false
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.Parent = ContentContainer
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = content
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = content
        
        -- Auto update canvas size
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        
        tabBtn.MouseButton1Click:Connect(function()
            ButtonPress(tabBtn)
            if CurrentTab == content then return end
            
            -- Animate out current
            if CurrentTab then
                CurrentTab.Visible = false
            end
            
            -- Update tab colors
            for _, t in ipairs(Tabs) do
                t.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Show new tab with animation
            content.Visible = true
            content.Position = UDim2.new(0, 0, 0, 20)
            content.BackgroundTransparency = 0.5
            CreateTween(content, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            
            CurrentTab = content
        end)
        
        table.insert(Tabs, {Button = tabBtn, Content = content})
        return content
    end
    
    --// UI ELEMENTS CREATOR
    local function CreateToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "Toggle"
        toggleBtn.Size = UDim2.new(0, 50, 0, 26)
        toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 13)
        toggleCorner.Parent = toggleBtn
        
        local enabled = default
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            ButtonPress(toggleBtn)
            
            local targetColor = enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
            local targetText = enabled and "ON" or "OFF"
            
            CreateTween(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
            toggleBtn.Text = targetText
            
            if callback then callback(enabled) end
        end)
        
        return frame
    end
    
    local function CreateSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 25)
        label.Position = UDim2.new(0, 15, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Name = "SliderBg"
        sliderBg.Size = UDim2.new(1, -30, 0, 8)
        sliderBg.Position = UDim2.new(0, 15, 0, 40)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 4)
        bgCorner.Parent = sliderBg
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 4)
        fillCorner.Parent = fill
        
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = sliderBg
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0.5, 0)
        knobCorner.Parent = knob
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -8, 0.5, -8)
            valueLabel.Text = tostring(value)
            
            if callback then callback(value) end
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return frame
    end
    
    local function CreateDropdown(parent, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0, 45)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0, 120, 0, 30)
        dropBtn.Position = UDim2.new(1, -135, 0.5, -15)
        dropBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropBtn.Text = default
        dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropBtn.TextSize = 12
        dropBtn.Font = Enum.Font.GothamSemibold
        dropBtn.Parent = frame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 6)
        dropCorner.Parent = dropBtn
        
        local expanded = false
        
        dropBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ButtonPress(dropBtn)
            
            local targetSize = expanded and UDim2.new(1, 0, 0, 45 + #options * 35) or UDim2.new(1, 0, 0, 45)
            CreateTween(frame, TweenInfo.new(0.2), {
                Size = targetSize
            }):Play()
        end)
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -30, 0, 30)
            optBtn.Position = UDim2.new(0, 15, 0, 45 + (i-1) * 35)
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.TextSize = 12
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = frame
            
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 6)
            optCorner.Parent = optBtn
            
            optBtn.MouseButton1Click:Connect(function()
                dropBtn.Text = option
                expanded = false
                CreateTween(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 45)
                }):Play()
                if callback then callback(option) end
            end)
        end
        
        return frame
    end
    
    --// CREATE TABS AND CONTENT
    
    -- AIMBOT TAB (First)
    local AimbotTab = CreateTab("Aimbot", "🎯")
    
    CreateToggle(AimbotTab, "Enable Aimbot", CONFIG.Aimbot.Enabled, function(val)
        CONFIG.Aimbot.Enabled = val
    end)
    
    CreateToggle(AimbotTab, "Team Check", CONFIG.Aimbot.TeamCheck, function(val)
        CONFIG.Aimbot.TeamCheck = val
    end)
    
    CreateToggle(AimbotTab, "Wall Check", CONFIG.Aimbot.WallCheck, function(val)
        CONFIG.Aimbot.WallCheck = val
    end)
    
    CreateToggle(AimbotTab, "Instant Lock", CONFIG.Aimbot.InstantLock, function(val)
        CONFIG.Aimbot.InstantLock = val
        CONFIG.Aimbot.Smoothness = val and 0 or 0.1
    end)
    
    CreateSlider(AimbotTab, "FOV Size", 50, 500, CONFIG.Aimbot.FOV, function(val)
        CONFIG.Aimbot.FOV = val
    end)
    
    CreateSlider(AimbotTab, "Max Distance", 100, 2000, CONFIG.Aimbot.MaxDistance, function(val)
        CONFIG.Aimbot.MaxDistance = val
    end)
    
    CreateDropdown(AimbotTab, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, CONFIG.Aimbot.TargetPart, function(val)
        CONFIG.Aimbot.TargetPart = val
    end)
    
    -- AIMBOT SETTINGS TAB (Second)
    local SettingsTab = CreateTab("Settings", "⚙️")
    
    CreateToggle(SettingsTab, "Show FOV Circle", true, function(val)
        -- Implement FOV circle visibility
    end)
    
    CreateSlider(SettingsTab, "Smoothness", 0, 1, CONFIG.Aimbot.Smoothness * 10, function(val)
        if not CONFIG.Aimbot.InstantLock then
            CONFIG.Aimbot.Smoothness = val / 10
        end
    end)
    
    CreateDropdown(SettingsTab, "Aim Key", {"RightClick", "LeftClick", "E", "Q"}, "RightClick", function(val)
        local keyMap = {
            RightClick = Enum.UserInputType.MouseButton2,
            LeftClick = Enum.UserInputType.MouseButton1,
            E = Enum.KeyCode.E,
            Q = Enum.KeyCode.Q
        }
        CONFIG.Aimbot.TriggerKey = keyMap[val]
    end)
    
    -- ESP TAB (Third)
    local ESPTab = CreateTab("ESP", "👁️")
    
    CreateToggle(ESPTab, "Enable ESP", CONFIG.ESP.Enabled, function(val)
        CONFIG.ESP.Enabled = val
    end)
    
    CreateToggle(ESPTab, "Team Check", CONFIG.ESP.TeamCheck, function(val)
        CONFIG.ESP.TeamCheck = val
    end)
    
    CreateToggle(ESPTab, "Show Names", CONFIG.ESP.ShowName, function(val)
        CONFIG.ESP.ShowName = val
    end)
    
    CreateToggle(ESPTab, "Show Health", CONFIG.ESP.ShowHealth, function(val)
        CONFIG.ESP.ShowHealth = val
    end)
    
    CreateToggle(ESPTab, "Show Distance", CONFIG.ESP.ShowDistance, function(val)
        CONFIG.ESP.ShowDistance = val
    end)
    
    CreateToggle(ESPTab, "Show Weapon", CONFIG.ESP.ShowWeapon, function(val)
        CONFIG.ESP.ShowWeapon = val
    end)
    
    CreateToggle(ESPTab, "Box ESP", CONFIG.ESP.BoxESP, function(val)
        CONFIG.ESP.BoxESP = val
    end)
    
    CreateToggle(ESPTab, "Tracer ESP", CONFIG.ESP.TracerESP, function(val)
        CONFIG.ESP.TracerESP = val
    end)
    
    CreateToggle(ESPTab, "Chams", CONFIG.ESP.Chams, function(val)
        CONFIG.ESP.Chams = val
    end)
    
    CreateSlider(ESPTab, "Max ESP Distance", 100, 3000, CONFIG.ESP.MaxDistance, function(val)
        CONFIG.ESP.MaxDistance = val
    end)
    
    --// DRAGGING SYSTEM (PC & Mobile)
    local function EnableDragging(frame, handle)
        handle = handle or frame
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = frame
                DragStart = input.Position
                StartPos = frame.Position
                
                -- Visual feedback
                CreateTween(frame, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                }):Play()
            end
        end)
    end
    
    EnableDragging(MainFrame, TitleBar)
    EnableDragging(ToggleBtn)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            Dragging.Position = UDim2.new(
                StartPos.X.Scale, 
                StartPos.X.Offset + delta.X, 
                StartPos.Y.Scale, 
                StartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Dragging == MainFrame then
                CreateTween(Dragging, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                }):Play()
            end
            Dragging = nil
        end
    end)
    
    --// TOGGLE UI BUTTON
    ToggleBtn.MouseButton1Click:Connect(function()
        ButtonPress(ToggleBtn)
        UIVisible = not UIVisible
        
        if UIVisible then
            MainFrame.Visible = true
            AnimateIn(MainFrame)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        else
            AnimateOut(MainFrame)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    
    --// CLOSE BUTTON
    CloseBtn.MouseButton1Click:Connect(function()
        ButtonPress(CloseBtn)
        AnimateOut(MainFrame, function()
            -- Optional: fully destroy or just hide
        end)
        UIVisible = false
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    --// FOV CIRCLE (Drawing)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = true
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(0, 170, 255)
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    
    --// MAIN LOOPS
    -- ESP Update
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- +36 for GUI inset
        FOVCircle.Radius = CONFIG.Aimbot.FOV
        FOVCircle.Visible = CONFIG.Aimbot.Enabled
        
        -- Update ESP for all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not ESPObjects[player] then
                    CreateESP(player)
                end
                ESPObjects[player].Update()
            end
        end
        
        -- Cleanup disconnected players
        for player, _ in pairs(ESPObjects) do
            if not player or not player.Parent then
                RemoveESP(player)
            end
        end
    end)
    
    -- Aimbot Logic
    RunService.RenderStepped:Connect(function()
        if not CONFIG.Aimbot.Enabled then return end
        
        if AimbotActive then
            local target = GetClosestPlayerToMouse()
            
            if target then
                local character = GetCharacter(target)
                local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
                
                if targetPart then
                    if CONFIG.Aimbot.InstantLock then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    else
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, CONFIG.Aimbot.Smoothness)
                    end
                end
            end
        end
    end)
    
    -- Input Handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Aimbot activation
        if input.UserInputType == CONFIG.Aimbot.TriggerKey or input.KeyCode == (typeof(CONFIG.Aimbot.TriggerKey) == "EnumItem" and CONFIG.Aimbot.TriggerKey.EnumType == Enum.KeyCode and CONFIG.Aimbot.TriggerKey) then
            AimbotActive = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == CONFIG.Aimbot.TriggerKey or input.KeyCode == (typeof(CONFIG.Aimbot.TriggerKey) == "EnumItem" and CONFIG.Aimbot.TriggerKey.EnumType == Enum.KeyCode and CONFIG.Aimbot.TriggerKey) then
            AimbotActive = false
        end
    end)
    
    --// INITIALIZATION
    -- Select first tab
    if Tabs[1] then
        Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1].Content
    end
    
    -- Animate in
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    AnimateIn(MainFrame)
    
    -- Cleanup on destroy
    ScreenGui.Destroying:Connect(function()
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
        FOVCircle:Remove()
    end)
    
    return ScreenGui
end

--// INITIALIZE
local success, result = pcall(function()
    -- Wait for player to load
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    -- Create UI
    local ui = CreateUI()
    ui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    print("✅ Combat System Loaded Successfully!")
    print("🎯 Aimbot: Hold Right Click to lock on")
    print("👁️ ESP: Active with all features")
    print("⚙️ UI: Drag tabs to move, use ⚔️ button to toggle")
end)

if not success then
    warn("❌ Error loading Combat System:", result)
end
