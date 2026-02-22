--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIGURATION
local CONFIG = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0, -- 0 = instant, 10 = very smooth
        FOV = 150,
        ShowFOV = true,
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
        Chams = true
    }
}

--// VARIABLES
local ESPObjects = {}
local CurrentTarget = nil
local UIVisible = true
local Dragging = nil
local DragStart = nil
local StartPos = nil
local TargetDropdownFrame = nil
local AllyDropdownFrame = nil
local TargetDropdownBtn = nil
local AllyDropdownBtn = nil
local TargetExpanded = false
local AllyExpanded = false

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
        if targetName == player.Name then
            return true
        end
    end
    return false
end

local function IsInAllyList(player)
    for _, allyName in ipairs(CONFIG.Aimbot.AllyList) do
        if allyName == player.Name then
            return true
        end
    end
    return false
end

local function GetClosestPlayerToCenter()
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
    
    espData.Update = function()
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
        
        local isTeammate = IsTeammate(player)
        local isAlly = IsInAllyList(player)
        local color = (CONFIG.ESP.TeamCheck and (isTeammate or isAlly)) and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor
        
        espData.Drawings.Name.Color = color
        espData.Drawings.Box.Color = CONFIG.ESP.BoxColor
        espData.Drawings.FilledBox.Color = CONFIG.ESP.BoxColor
        espData.Drawings.Tracer.Color = CONFIG.ESP.BoxColor
        
        if CONFIG.ESP.TeamCheck and (isTeammate or isAlly) then
            espData.Drawings.Box.Color = CONFIG.ESP.AllyColor
            espData.Drawings.FilledBox.Color = CONFIG.ESP.AllyColor
            espData.Drawings.Tracer.Color = CONFIG.ESP.AllyColor
        end
        
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
            local allyTag = isAlly and " [ALLY]" or (isTeammate and " [TEAM]" or " [ENEMY]")
            espData.Drawings.Name.Text = player.Name .. allyTag
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
                espData.Highlight.FillColor = (isTeammate or isAlly) and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor
                espData.Highlight.OutlineColor = Color3.new(1, 1, 1)
                espData.Highlight.FillTransparency = 0.5
                espData.Highlight.OutlineTransparency = 0
                espData.Highlight.Parent = character
            end
            espData.Highlight.Enabled = true
            espData.Highlight.FillColor = (isTeammate or isAlly) and CONFIG.ESP.AllyColor or CONFIG.ESP.BoxColor
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

--// REFRESH PLAYER DROPDOWNS
local function RefreshPlayerDropdowns()
    if TargetDropdownFrame then
        local scrollFrame = TargetDropdownFrame:FindFirstChild("ScrollFrame")
        if scrollFrame then
            -- Clear old options
            for _, child in ipairs(scrollFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Add new options
            local players = Players:GetPlayers()
            local yOffset = 0
            
            for _, player in ipairs(players) do
                if player == LocalPlayer then continue end
                
                local optBtn = Instance.new("TextButton")
                optBtn.Name = player.Name .. "Option"
                optBtn.Size = UDim2.new(1, -10, 0, 28)
                optBtn.Position = UDim2.new(0, 5, 0, yOffset)
                optBtn.BackgroundColor3 = IsInTargetList(player) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
                optBtn.Text = GetPlayerDisplayText(player)
                optBtn.TextColor3 = IsInTargetList(player) and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
                optBtn.TextSize = 10
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextTruncate = Enum.TextTruncate.AtEnd
                optBtn.Parent = scrollFrame
                
                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 5)
                optCorner.Parent = optBtn
                
                optBtn.MouseButton1Click:Connect(function()
                    local isSelected = IsInTargetList(player)
                    
                    if isSelected then
                        for i, name in ipairs(CONFIG.Aimbot.TargetList) do
                            if name == player.Name then
                                table.remove(CONFIG.Aimbot.TargetList, i)
                                break
                            end
                        end
                        optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    else
                        table.insert(CONFIG.Aimbot.TargetList, player.Name)
                        optBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                        optBtn.TextColor3 = Color3.new(1, 1, 1)
                    end
                    
                    local count = #CONFIG.Aimbot.TargetList
                    TargetDropdownBtn.Text = count > 0 and (count .. " selected") or "Select targets"
                end)
                
                yOffset = yOffset + 30
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
        end
    end
    
    if AllyDropdownFrame then
        local scrollFrame = AllyDropdownFrame:FindFirstChild("ScrollFrame")
        if scrollFrame then
            for _, child in ipairs(scrollFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            local players = Players:GetPlayers()
            local yOffset = 0
            
            for _, player in ipairs(players) do
                if player == LocalPlayer then continue end
                
                local optBtn = Instance.new("TextButton")
                optBtn.Name = player.Name .. "AllyOption"
                optBtn.Size = UDim2.new(1, -10, 0, 28)
                optBtn.Position = UDim2.new(0, 5, 0, yOffset)
                optBtn.BackgroundColor3 = IsInAllyList(player) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(45, 45, 45)
                optBtn.Text = GetPlayerDisplayText(player)
                optBtn.TextColor3 = IsInAllyList(player) and Color3.new(0, 0, 0) or Color3.fromRGB(200, 200, 200)
                optBtn.TextSize = 10
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextTruncate = Enum.TextTruncate.AtEnd
                optBtn.Parent = scrollFrame
                
                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 5)
                optCorner.Parent = optBtn
                
                optBtn.MouseButton1Click:Connect(function()
                    local isSelected = IsInAllyList(player)
                    
                    if isSelected then
                        for i, name in ipairs(CONFIG.Aimbot.AllyList) do
                            if name == player.Name then
                                table.remove(CONFIG.Aimbot.AllyList, i)
                                break
                            end
                        end
                        optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    else
                        table.insert(CONFIG.Aimbot.AllyList, player.Name)
                        optBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                        optBtn.TextColor3 = Color3.new(0, 0, 0)
                    end
                    
                    local count = #CONFIG.Aimbot.AllyList
                    AllyDropdownBtn.Text = count > 0 and (count .. " allies") or "Select allies"
                end)
                
                yOffset = yOffset + 30
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
        end
    end
end

--// UI CREATION
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
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
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
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
    TitleText.Size = UDim2.new(1, -50, 1, 0)
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
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 0, 28)
    TabContainer.Position = UDim2.new(0, 8, 0, 38)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -16, 1, -74)
    ContentContainer.Position = UDim2.new(0, 8, 0, 70)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentContainer
    
    -- Toggle Button (Outside)
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
    
    --// ANIMATION FUNCTIONS
    local function AnimateIn(obj)
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Visible = true
        TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 420)
        }):Play()
    end
    
    local function AnimateOut(obj)
        local tween = TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween.Completed:Connect(function()
            obj.Visible = false
        end)
        tween:Play()
    end
    
    local function ButtonPress(btn)
        local originalSize = btn.Size
        TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale, originalSize.Y.Offset * 0.9)
        }):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.1), {
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
        tabBtn.Size = UDim2.new(0, 65, 0, 22)
        tabBtn.Position = UDim2.new(0, #Tabs * 70 + 4, 0.5, -11)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.Text = icon .. " " .. name
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabBtn.TextSize = 10
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
        layout.Padding = UDim.new(0, 6)
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
            TweenService:Create(content, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            CurrentTab = content
        end)
        
        table.insert(Tabs, {Button = tabBtn, Content = content})
        return content
    end
    
    --// UI ELEMENTS
    local function CreateToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
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
        toggleBtn.Size = UDim2.new(0, 42, 0, 20)
        toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 11
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
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
        frame.Size = UDim2.new(1, 0, 0, 48)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 4)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 6)
        sliderBg.Position = UDim2.new(0, 10, 0, 30)
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
    
    -- Multi-select dropdown with SCROLLING and TOGGLE close
    local function CreateMultiDropdown(parent, text, isTarget)
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
        label.Size = UDim2.new(0.3, 0, 0, 36)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Name = "DropBtn"
        dropBtn.Size = UDim2.new(0, 120, 0, 24)
        dropBtn.Position = UDim2.new(0.35, 0, 0.5, -12)
        dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropBtn.Text = isTarget and "Select targets" or "Select allies"
        dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropBtn.TextSize = 10
        dropBtn.Font = Enum.Font.GothamSemibold
        dropBtn.TextTruncate = Enum.TextTruncate.AtEnd
        dropBtn.Parent = frame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 5)
        dropCorner.Parent = dropBtn
        
        local refreshBtn = Instance.new("TextButton")
        refreshBtn.Name = "RefreshBtn"
        refreshBtn.Size = UDim2.new(0, 30, 0, 24)
        refreshBtn.Position = UDim2.new(1, -38, 0.5, -12)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        refreshBtn.Text = "🔄"
        refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshBtn.TextSize = 14
        refreshBtn.Font = Enum.Font.GothamBold
        refreshBtn.Parent = frame
        
        local refreshCorner = Instance.new("UICorner")
        refreshCorner.CornerRadius = UDim.new(0, 5)
        refreshCorner.Parent = refreshBtn
        
        -- SCROLLING FRAME for dropdown options
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ScrollFrame"
        scrollFrame.Size = UDim2.new(1, -10, 1, -40)
        scrollFrame.Position = UDim2.new(0, 5, 0, 38)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible = false -- Hidden when collapsed
        scrollFrame.ZIndex = 10
        scrollFrame.Parent = frame
        
        -- Toggle function
        local function ToggleDropdown()
            if isTarget then
                TargetExpanded = not TargetExpanded
            else
                AllyExpanded = not AllyExpanded
            end
            
            local expanded = isTarget and TargetExpanded or AllyExpanded
            
            if expanded then
                -- Open - show scroll frame
                scrollFrame.Visible = true
                frame.Size = UDim2.new(1, 0, 0, 200) -- Expanded height
                dropBtn.Text = isTarget and "▼ Close" or "▼ Close"
            else
                -- Close - hide scroll frame
                scrollFrame.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 36) -- Collapsed height
                local count = isTarget and #CONFIG.Aimbot.TargetList or #CONFIG.Aimbot.AllyList
                dropBtn.Text = count > 0 and (count .. (isTarget and " selected" or " allies")) or (isTarget and "Select targets" or "Select allies")
            end
            
            TweenService:Create(frame, TweenInfo.new(0.2), {
                Size = expanded and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 36)
            }):Play()
        end
        
        dropBtn.MouseButton1Click:Connect(function()
            ButtonPress(dropBtn)
            ToggleDropdown()
        end)
        
        refreshBtn.MouseButton1Click:Connect(function()
            ButtonPress(refreshBtn)
            RefreshPlayerDropdowns()
            refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            task.delay(0.3, function()
                refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            end)
        end)
        
        if isTarget then
            TargetDropdownFrame = frame
            TargetDropdownBtn = dropBtn
        else
            AllyDropdownFrame = frame
            AllyDropdownBtn = dropBtn
        end
        
        return frame
    end
    
    local function CreateDropdown(parent, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 34)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 0, 34)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0, 120, 0, 24)
        dropBtn.Position = UDim2.new(1, -130, 0.5, -12)
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
            
            local targetSize = expanded and UDim2.new(1, 0, 0, 34 + #options * 28) or UDim2.new(1, 0, 0, 34)
            TweenService:Create(frame, TweenInfo.new(0.2), {Size = targetSize}):Play()
        end)
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -18, 0, 24)
            optBtn.Position = UDim2.new(0, 9, 0, 34 + (i-1) * 28)
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
                TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 34)}):Play()
                if callback then callback(option) end
            end)
        end
        
        return frame
    end
    
    --// CREATE 4 TABS
    
    -- 1. AIMBOT TAB
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
    
    CreateToggle(AimbotTab, "Show FOV", CONFIG.Aimbot.ShowFOV, function(val)
        CONFIG.Aimbot.ShowFOV = val
    end)
    
    CreateSlider(AimbotTab, "FOV Size", 50, 400, CONFIG.Aimbot.FOV, function(val)
        CONFIG.Aimbot.FOV = val
    end)
    
    CreateSlider(AimbotTab, "Max Distance", 100, 2000, CONFIG.Aimbot.MaxDistance, function(val)
        CONFIG.Aimbot.MaxDistance = val
    end)
    
    CreateDropdown(AimbotTab, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, CONFIG.Aimbot.TargetPart, function(val)
        CONFIG.Aimbot.TargetPart = val
    end)
    
    -- 2. ESP TAB
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
    
    CreateSlider(ESPTab, "Max Distance", 100, 3000, CONFIG.ESP.MaxDistance, function(val)
        CONFIG.ESP.MaxDistance = val
    end)
    
    -- 3. EXTRA TAB
    local ExtraTab = CreateTab("Extra", "✨")
    
    local AimbotSettingsLabel = Instance.new("TextLabel")
    AimbotSettingsLabel.Size = UDim2.new(1, 0, 0, 25)
    AimbotSettingsLabel.BackgroundTransparency = 1
    AimbotSettingsLabel.Text = "⚙️ AIMBOT SETTINGS"
    AimbotSettingsLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    AimbotSettingsLabel.TextSize = 14
    AimbotSettingsLabel.Font = Enum.Font.GothamBold
    AimbotSettingsLabel.Parent = ExtraTab
    
    -- FIXED: Smoothness 0 = instant, 10 = smooth
    CreateSlider(ExtraTab, "Smoothness (0-10)", 0, 10, CONFIG.Aimbot.Smoothness, function(val)
        CONFIG.Aimbot.Smoothness = val
    end)
    
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(1, -20, 0, 2)
    Separator.Position = UDim2.new(0, 10, 0, 0)
    Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Separator.BorderSizePixel = 0
    Separator.Parent = ExtraTab
    
    local SepCorner = Instance.new("UICorner")
    SepCorner.CornerRadius = UDim.new(0, 1)
    SepCorner.Parent = Separator
    
    local AllySectionLabel = Instance.new("TextLabel")
    AllySectionLabel.Size = UDim2.new(1, 0, 0, 25)
    AllySectionLabel.BackgroundTransparency = 1
    AllySectionLabel.Text = "🛡️ ALLY & TARGET"
    AllySectionLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    AllySectionLabel.TextSize = 14
    AllySectionLabel.Font = Enum.Font.GothamBold
    AllySectionLabel.Parent = ExtraTab
    
    CreateToggle(ExtraTab, "Use Target List", CONFIG.Aimbot.UseTargetList, function(val)
        CONFIG.Aimbot.UseTargetList = val
    end)
    
    CreateMultiDropdown(ExtraTab, "Targets", true)
    
    CreateToggle(ExtraTab, "Use Ally List", CONFIG.Aimbot.UseAllyList, function(val)
        CONFIG.Aimbot.UseAllyList = val
    end)
    
    CreateMultiDropdown(ExtraTab, "Allies", false)
    
    -- 4. SETTINGS TAB
    local SettingsTab = CreateTab("Settings", "🔧")
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 60)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Combat System v2.0\nMade for Roblox\nAuto-aimbot & ESP"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = SettingsTab
    
    CreateToggle(SettingsTab, "Show UI Toggle Button", true, function(val)
        ToggleBtn.Visible = val
    end)
    
    --// INITIALIZE DROPDOWNS
    RefreshPlayerDropdowns()
    
    --// PLAYER EVENTS
    Players.PlayerAdded:Connect(function()
        task.delay(0.5, RefreshPlayerDropdowns)
    end)
    
    Players.PlayerRemoving:Connect(function()
        task.delay(0.5, RefreshPlayerDropdowns)
    end)
    
    --// DRAGGING
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
            Dragging.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = nil
        end
    end)
    
    --// TOGGLE UI
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
    
    --// CLOSE
    CloseBtn.MouseButton1Click:Connect(function()
        ButtonPress(CloseBtn)
        AnimateOut(MainFrame)
        UIVisible = false
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    --// FOV CIRCLE
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(0, 170, 255)
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    
    --// MAIN LOOP - FIXED SMOOTHNESS
    RunService.RenderStepped:Connect(function()
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = CONFIG.Aimbot.FOV
        FOVCircle.Visible = CONFIG.Aimbot.Enabled and CONFIG.Aimbot.ShowFOV
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not ESPObjects[player] then
                    CreateESP(player)
                end
                ESPObjects[player].Update()
            end
        end
        
        for player, _ in pairs(ESPObjects) do
            if not player or not player.Parent then
                RemoveESP(player)
            end
        end
        
        if CONFIG.Aimbot.Enabled then
            local target = GetClosestPlayerToCenter()
            
            if target then
                CurrentTarget = target
                local character = GetCharacter(target)
                local targetPart = character:FindFirstChild(CONFIG.Aimbot.TargetPart)
                
                if targetPart then
                    -- FIXED: 0 = instant, higher = smoother
                    if CONFIG.Aimbot.Smoothness <= 0 then
                        -- Instant snap
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    else
                        -- Smooth - convert 0-10 to 0.01-0.5 lerp factor
                        -- Higher smoothness = slower/more smooth
                        local smoothFactor = 0.5 - (CONFIG.Aimbot.Smoothness * 0.05) -- 0=0.5, 10=0.0
                        smoothFactor = math.max(0.01, smoothFactor) -- Minimum 0.01
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
                    end
                end
            else
                CurrentTarget = nil
            end
        end
    end)
    
    --// INIT
    if Tabs[1] then
        Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1].Content
    end
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    AnimateIn(MainFrame)
    
    ScreenGui.Destroying:Connect(function()
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
        FOVCircle:Remove()
    end)
    
    return ScreenGui
end

--// START
local success, result = pcall(function()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    local ui = CreateUI()
    ui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    print("✅ Combat System Loaded!")
    print("🎯 Smoothness: 0=instant, 10=smooth")
    print("📜 Dropdown: Click to open, click again to close")
    print("📜 Dropdown: Can scroll to see all players")
end)

if not success then
    warn("❌ Error:", result)
end
