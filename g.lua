--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// DETECT DEVICE TYPE
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsPC = not IsMobile

print("Device detected:", IsMobile and "MOBILE" or "PC")

--// CONFIGURATION
local CONFIG = {
    -- Aimbot Settings
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        InstantLock = true,
        Smoothness = 0,
        FOV = 150,
        MaxDistance = 1000,
        TargetPart = "Head",
        -- PC uses keys, Mobile uses buttons
        Mode = IsMobile and "Button" or "Key", -- "Key" for PC, "Button" for Mobile
        TriggerKey = Enum.KeyCode.E, -- For PC Key mode
        TriggerButton = nil, -- Will be created for Mobile
        LockPosition = nil -- For mobile position lock
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
local MobileAimButton = nil
local ScreenGui = nil

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

-- FIXED: Get closest player to CENTER OF SCREEN (not mouse)
local function GetClosestPlayerToCenter()
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
        
        -- Distance from CENTER OF SCREEN (not mouse)
        local distance = (screenPos - screenCenter).Magnitude
        
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

--// ESP SYSTEM (Same as before, optimized)
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local espData = {
        Player = player,
        Drawings = {}
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
        
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > CONFIG.ESP.MaxDistance then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        local isTeammate = IsTeammate(player)
        local color = (CONFIG.ESP.TeamCheck and isTeammate) and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor
        
        nameText.Color = color
        box.Color = CONFIG.ESP.BoxColor
        filledBox.Color = CONFIG.ESP.BoxColor
        tracer.Color = CONFIG.ESP.BoxColor
        
        if CONFIG.ESP.TeamCheck and isTeammate then
            box.Color = CONFIG.ESP.AllyColor
            filledBox.Color = CONFIG.ESP.AllyColor
            tracer.Color = CONFIG.ESP.AllyColor
        end
        
        local headPos, headOnScreen = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
        
        if not headOnScreen and not rootOnScreen then
            for _, drawing in pairs(espData.Drawings) do
                drawing.Visible = false
            end
            if highlight then highlight.Enabled = false end
            return
        end
        
        local boxHeight = math.abs(headPos.Y - rootPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
        
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
            weaponText.Text = GetWeaponName(character)
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

--// UI CREATION - COMPACT & MOBILE FRIENDLY
local function CreateUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- SMALLER MAIN FRAME (260x320 instead of 320x400)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar (smaller)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 15)
    TitleFix.Position = UDim2.new(0, 0, 1, -15)
    TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚔️ COMBAT"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -33, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Tab Container (horizontal, compact)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -16, 0, 32)
    TabContainer.Position = UDim2.new(0, 8, 0, 42)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, -16, 1, -82)
    ContentContainer.Position = UDim2.new(0, 8, 0, 78)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentContainer
    
    --// TOGGLE BUTTON (Outside UI)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleUI"
    ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    ToggleBtn.Text = "⚔️"
    ToggleBtn.TextSize = 20
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ScreenGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleBtn
    
    --// MOBILE AIM BUTTON (Only for mobile)
    if IsMobile then
        MobileAimButton = Instance.new("TextButton")
        MobileAimButton.Name = "MobileAim"
        MobileAimButton.Size = UDim2.new(0, 70, 0, 70)
        MobileAimButton.Position = UDim2.new(1, -90, 1, -90)
        MobileAimButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        MobileAimButton.Text = "AIM"
        MobileAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MobileAimButton.TextSize = 18
        MobileAimButton.Font = Enum.Font.GothamBold
        MobileAimButton.Visible = false -- Hidden by default, shown when aimbot enabled
        MobileAimButton.Parent = ScreenGui
        
        local MobileCorner = Instance.new("UICorner")
        MobileCorner.CornerRadius = UDim.new(1, 0)
        MobileCorner.Parent = MobileAimButton
        
        local MobileStroke = Instance.new("UIStroke")
        MobileStroke.Color = Color3.fromRGB(255, 255, 255)
        MobileStroke.Thickness = 3
        MobileStroke.Parent = MobileAimButton
        
        -- Dragging for mobile aim button
        local aimDragging = false
        local aimDragStart = nil
        local aimStartPos = nil
        
        MobileAimButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                -- Check if it's a tap (quick touch) or drag
                aimDragging = true
                aimDragStart = input.Position
                aimStartPos = MobileAimButton.Position
                
                task.delay(0.2, function()
                    if aimDragging and (input.Position - aimDragStart).Magnitude < 10 then
                        -- It's a tap - activate aimbot
                        aimDragging = false
                    end
                end)
            end
        end)
        
        MobileAimButton.InputChanged:Connect(function(input)
            if aimDragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - aimDragStart
                if delta.Magnitude > 10 then -- Actually dragging
                    MobileAimButton.Position = UDim2.new(
                        aimStartPos.X.Scale,
                        aimStartPos.X.Offset + delta.X,
                        aimStartPos.Y.Scale,
                        aimStartPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
        
        MobileAimButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                if aimDragging then
                    -- Was dragging, don't activate
                    aimDragging = false
                else
                    -- Was tap, activate aimbot toggle
                    AimbotActive = not AimbotActive
                    MobileAimButton.BackgroundColor3 = AimbotActive and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                end
            end
        end)
        
        CONFIG.Aimbot.TriggerButton = MobileAimButton
    end
    
    --// ANIMATION FUNCTIONS
    local function AnimateIn(obj)
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Visible = true
        CreateTween(obj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 320)
        }):Play()
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
        CreateTween(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale, originalSize.Y.Offset * 0.9)
        }):Play()
        task.delay(0.1, function()
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
        tabBtn.Size = UDim2.new(0, 75, 0, 26)
        tabBtn.Position = UDim2.new(0, #Tabs * 80 + 5, 0.5, -13)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.Text = icon .. " " .. name
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabBtn.TextSize = 11
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 5)
        tabCorner.Parent = tabBtn
        
        local content = Instance.new("ScrollingFrame")
        content.Name = name .. "Content"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        content.Visible = false
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.Parent = ContentContainer
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = content
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = content
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)
        
        tabBtn.MouseButton1Click:Connect(function()
            if CurrentTab == content then return end
            
            if CurrentTab then
                CurrentTab.Visible = false
            end
            
            for _, t in ipairs(Tabs) do
                t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            content.Visible = true
            content.Position = UDim2.new(0, 0, 0, 10)
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
    
    --// UI ELEMENTS (COMPACT)
    local function CreateToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 44, 0, 22)
        toggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 11
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 11)
        toggleCorner.Parent = toggleBtn
        
        local enabled = default
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            ButtonPress(toggleBtn)
            
            toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
            toggleBtn.Text = enabled and "ON" or "OFF"
            
            if callback then callback(enabled) end
        end)
        
        return frame
    end
    
    local function CreateSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 6)
        sliderBg.Position = UDim2.new(0, 10, 0, 32)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 3)
        bgCorner.Parent = sliderBg
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
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
            knob.Position = UDim2.new(pos, -6, 0.5, -6)
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
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 0, 36)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0, 100, 0, 26)
        dropBtn.Position = UDim2.new(1, -110, 0.5, -13)
        dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropBtn.Text = default
        dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropBtn.TextSize = 11
        dropBtn.Font = Enum.Font.GothamSemibold
        dropBtn.Parent = frame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 5)
        dropCorner.Parent = dropBtn
        
        local expanded = false
        
        dropBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ButtonPress(dropBtn)
            
            local targetSize = expanded and UDim2.new(1, 0, 0, 36 + #options * 30) or UDim2.new(1, 0, 0, 36)
            CreateTween(frame, TweenInfo.new(0.2), {Size = targetSize}):Play()
        end)
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -20, 0, 26)
            optBtn.Position = UDim2.new(0, 10, 0, 36 + (i-1) * 30)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = frame
            
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 5)
            optCorner.Parent = optBtn
            
            optBtn.MouseButton1Click:Connect(function()
                dropBtn.Text = option
                expanded = false
                CreateTween(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 36)}):Play()
                if callback then callback(option) end
            end)
        end
        
        return frame
    end
    
    --// CREATE TABS
    
    -- AIMBOT TAB (First)
    local AimbotTab = CreateTab("Aimbot", "🎯")
    
    CreateToggle(AimbotTab, "Enable Aimbot", CONFIG.Aimbot.Enabled, function(val)
        CONFIG.Aimbot.Enabled = val
        if MobileAimButton then
            MobileAimButton.Visible = val
        end
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
    
    CreateSlider(AimbotTab, "FOV Size", 50, 400, CONFIG.Aimbot.FOV, function(val)
        CONFIG.Aimbot.FOV = val
    end)
    
    CreateSlider(AimbotTab, "Max Distance", 100, 2000, CONFIG.Aimbot.MaxDistance, function(val)
        CONFIG.Aimbot.MaxDistance = val
    end)
    
    CreateDropdown(AimbotTab, "Target", {"Head", "HumanoidRootPart", "Torso"}, CONFIG.Aimbot.TargetPart, function(val)
        CONFIG.Aimbot.TargetPart = val
    end)
    
    -- MODE DROPDOWN: Key for PC, Button for Mobile
    local modeOptions = IsMobile and {"Button", "Position Lock"} or {"Key", "Button"}
    CreateDropdown(AimbotTab, "Mode", modeOptions, CONFIG.Aimbot.Mode, function(val)
        CONFIG.Aimbot.Mode = val
        
        -- Show/hide mobile button based on mode
        if IsMobile and MobileAimButton then
            MobileAimButton.Visible = CONFIG.Aimbot.Enabled and (val == "Button")
        end
    end)
    
    -- SETTINGS TAB (Second)
    local SettingsTab = CreateTab("Settings", "⚙️")
    
    -- Only show key selection for PC or if Button mode selected
    if IsPC then
        CreateDropdown(SettingsTab, "Aim Key", {"E", "Q", "LeftCtrl", "LeftShift"}, "E", function(val)
            local keyMap = {
                E = Enum.KeyCode.E,
                Q = Enum.KeyCode.Q,
                LeftCtrl = Enum.KeyCode.LeftControl,
                LeftShift = Enum.KeyCode.LeftShift
            }
            CONFIG.Aimbot.TriggerKey = keyMap[val]
        end)
    end
    
    CreateSlider(SettingsTab, "Smoothness", 0, 10, CONFIG.Aimbot.Smoothness * 10, function(val)
        if not CONFIG.Aimbot.InstantLock then
            CONFIG.Aimbot.Smoothness = val / 10
        end
    end)
    
    -- ESP TAB (Third)
    local ESPTab = CreateTab("ESP", "👁️")
    
    CreateToggle(ESPTab, "Enable ESP", CONFIG.ESP.Enabled, function(val)
        CONFIG.ESP.Enabled = val
    end)
    
    CreateToggle(ESPTab, "Team Check", CONFIG.ESP.TeamCheck, function(val)
        CONFIG.ESP.TeamCheck = val
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
    
    CreateToggle(ESPTab, "Show Names", CONFIG.ESP.ShowName, function(val)
        CONFIG.ESP.ShowName = val
    end)
    
    CreateToggle(ESPTab, "Show Health", CONFIG.ESP.ShowHealth, function(val)
        CONFIG.ESP.ShowHealth = val
    end)
    
    CreateToggle(ESPTab, "Show Distance", CONFIG.ESP.ShowDistance, function(val)
        CONFIG.ESP.ShowDistance = val
    end)
    
    CreateSlider(ESPTab, "Max Distance", 100, 3000, CONFIG.ESP.MaxDistance, function(val)
        CONFIG.ESP.MaxDistance = val
    end)
    
    --// DRAGGING SYSTEM
    local function EnableDragging(frame, handle)
        handle = handle or frame
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = frame
                DragStart = input.Position
                StartPos = frame.Position
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
        AnimateOut(MainFrame)
        UIVisible = false
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    --// FOV CIRCLE - CENTER OF SCREEN
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(0, 170, 255)
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    
    --// MAIN LOOPS
    
    -- RenderStepped for ESP and Aimbot
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle at CENTER of screen
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = CONFIG.Aimbot.FOV
        FOVCircle.Visible = CONFIG.Aimbot.Enabled
        
        -- Update ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not ESPObjects[player] then
                    CreateESP(player)
                end
                ESPObjects[player].Update()
            end
        end
        
        -- Cleanup
        for player, _ in pairs(ESPObjects) do
            if not player or not player.Parent then
                RemoveESP(player)
            end
        end
        
        -- AIMBOT LOGIC - CENTER BASED
        if CONFIG.Aimbot.Enabled and AimbotActive then
            local target = GetClosestPlayerToCenter()
            
            if target then
                CurrentTarget = target
                local character = GetCharacter(target)
                local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
                
                if targetPart then
                    if CONFIG.Aimbot.InstantLock then
                        -- INSTANT LOCK to target
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    else
                        -- Smooth lock
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, CONFIG.Aimbot.Smoothness)
                    end
                end
            else
                CurrentTarget = nil
            end
        end
    end)
    
    -- INPUT HANDLING - PC vs Mobile
    if IsPC then
        -- PC: Use keys
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if CONFIG.Aimbot.Mode == "Key" then
                if input.KeyCode == CONFIG.Aimbot.TriggerKey then
                    AimbotActive = true
                end
            elseif CONFIG.Aimbot.Mode == "Button" then
                -- Even on PC, can use toggle mode
                if input.KeyCode == CONFIG.Aimbot.TriggerKey then
                    AimbotActive = not AimbotActive
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if CONFIG.Aimbot.Mode == "Key" then
                if input.KeyCode == CONFIG.Aimbot.TriggerKey then
                    AimbotActive = false
                end
            end
            -- In Button mode, we toggle so we don't auto-release
        end)
    end
    
    --// INITIALIZATION
    if Tabs[1] then
        Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1].Content
    end
    
    -- Animate in
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    AnimateIn(MainFrame)
    
    -- Cleanup
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
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    local ui = CreateUI()
    ui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    print("✅ Combat System Loaded!")
    print("Device:", IsMobile and "Mobile" or "PC")
    print("Mode:", CONFIG.Aimbot.Mode)
end)

if not success then
    warn("❌ Error:", result)
end
