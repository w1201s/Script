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
        Mode = "Normal",
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
        Chams = true,
        UseRGB = false,
        RGBSpeed = 5
    },
    
    UI = {
        MainColor = Color3.fromRGB(0, 170, 255),
        BackgroundTransparency = 0
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
local ActiveColorPicker = nil
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

--// REFRESH PLAYER DROPDOWNS
local function RefreshPlayerDropdowns()
    if TargetDropdownFrame then
        local scrollFrame = TargetDropdownFrame:FindFirstChild("ScrollFrame")
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
                optBtn.Name = player.Name .. "Option"
                optBtn.Size = UDim2.new(1, -10, 0, 28)
                optBtn.Position = UDim2.new(0, 5, 0, yOffset)
                optBtn.BackgroundColor3 = IsInTargetList(player) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
                optBtn.Text = GetPlayerDisplayText(player)
                optBtn.TextColor3 = IsInTargetList(player) and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
                optBtn.TextSize = 10
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextTruncate = Enum.TextTruncate.AtEnd
                optBtn.ZIndex = 101
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
                    if not TargetExpanded then
                        TargetDropdownBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                    end
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
                optBtn.ZIndex = 101
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
                    if not AllyExpanded then
                        AllyDropdownBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                    end
                end)
                
                yOffset = yOffset + 30
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
        end
    end
end

--// UI CREATION - COMPACT FOR MOBILE
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- SMALLER MAIN FRAME (250x350 for mobile)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Color Picker Container (OUTSIDE main frame, on top)
    local ColorPickerContainer = Instance.new("Frame")
    ColorPickerContainer.Name = "ColorPickerContainer"
    ColorPickerContainer.Size = UDim2.new(0, 220, 0, 180)
    ColorPickerContainer.Position = UDim2.new(0.5, -110, 0.5, -90)
    ColorPickerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ColorPickerContainer.BorderSizePixel = 0
    ColorPickerContainer.Visible = false
    ColorPickerContainer.ZIndex = 1000 -- HIGHEST
    ColorPickerContainer.Parent = ScreenGui
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 10)
    pickerCorner.Parent = ColorPickerContainer
    
    -- Color Picker Title
    local pickerTitle = Instance.new("TextLabel")
    pickerTitle.Size = UDim2.new(1, 0, 0, 30)
    pickerTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pickerTitle.Text = "🎨 Color Picker"
    pickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    pickerTitle.TextSize = 14
    pickerTitle.Font = Enum.Font.GothamBold
    pickerTitle.ZIndex = 1001
    pickerTitle.Parent = ColorPickerContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = pickerTitle
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 10)
    titleFix.Position = UDim2.new(0, 0, 1, -10)
    titleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleFix.BorderSizePixel = 0
    titleFix.ZIndex = 1001
    titleFix.Parent = pickerTitle
    
    -- Hue Slider
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(1, -20, 0, 25)
    hueSlider.Position = UDim2.new(0, 10, 0, 40)
    hueSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    hueSlider.BorderSizePixel = 0
    hueSlider.ZIndex = 1001
    hueSlider.Parent = ColorPickerContainer
    
    local hueSliderCorner = Instance.new("UICorner")
    hueSliderCorner.CornerRadius = UDim.new(0, 5)
    hueSliderCorner.Parent = hueSlider
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Parent = hueSlider
    
    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.new(0, 12, 1, 8)
    hueKnob.Position = UDim2.new(0, -6, 0, -4)
    hueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueKnob.BorderSizePixel = 0
    hueKnob.ZIndex = 1002
    hueKnob.Parent = hueSlider
    
    -- Preview
    local previewFrame = Instance.new("Frame")
    previewFrame.Size = UDim2.new(1, -20, 0, 50)
    previewFrame.Position = UDim2.new(0, 10, 0, 75)
    previewFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    previewFrame.BorderSizePixel = 0
    previewFrame.ZIndex = 1001
    previewFrame.Parent = ColorPickerContainer
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 8)
    previewCorner.Parent = previewFrame
    
    -- Color Value Label (NEW - Shows RGB values for clarity)
    local colorValueLabel = Instance.new("TextLabel")
    colorValueLabel.Size = UDim2.new(1, -20, 0, 20)
    colorValueLabel.Position = UDim2.new(0, 10, 0, 130)
    colorValueLabel.BackgroundTransparency = 1
    colorValueLabel.Text = "R: 255, G: 0, B: 0"
    colorValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorValueLabel.TextSize = 12
    colorValueLabel.Font = Enum.Font.GothamBold
    colorValueLabel.ZIndex = 1001
    colorValueLabel.Parent = ColorPickerContainer
    
    -- Close Button
    local closePickerBtn = Instance.new("TextButton")
    closePickerBtn.Size = UDim2.new(0, 100, 0, 28)
    closePickerBtn.Position = UDim2.new(0.5, -50, 1, -38)
    closePickerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    closePickerBtn.Text = "Done"
    closePickerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closePickerBtn.TextSize = 14
    closePickerBtn.Font = Enum.Font.GothamBold
    closePickerBtn.ZIndex = 1001
    closePickerBtn.Parent = ColorPickerContainer
    
    local closePickerCorner = Instance.new("UICorner")
    closePickerCorner.CornerRadius = UDim.new(0, 6)
    closePickerCorner.Parent = closePickerBtn
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 12)
    TitleFix.Position = UDim2.new(0, 0, 1, -12)
    TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚔️ COMBAT"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -12, 0, 26)
    TabContainer.Position = UDim2.new(0, 6, 0, 34)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -12, 1, -68)
    ContentContainer.Position = UDim2.new(0, 6, 0, 64)
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
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
    ToggleBtn.BackgroundColor3 = CONFIG.UI.MainColor
    ToggleBtn.Text = "⚔️"
    ToggleBtn.TextSize = 18
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ScreenGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleBtn
    
    --// COLOR PICKER LOGIC
    local currentHue = 0
    local draggingHue = false
    local colorCallback = nil
    
    local function updateColorPicker()
        local newColor = Color3.fromHSV(currentHue, 1, 1)
        previewFrame.BackgroundColor3 = newColor
        hueKnob.Position = UDim2.new(currentHue, -6, 0, -4)
        -- Update RGB text display
        local r = math.floor(newColor.R * 255)
        local g = math.floor(newColor.G * 255)
        local b = math.floor(newColor.B * 255)
        colorValueLabel.Text = string.format("R: %d, G: %d, B: %d", r, g, b)
        if colorCallback then
            colorCallback(newColor)
        end
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            currentHue = pos
            updateColorPicker()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            currentHue = pos
            updateColorPicker()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
        end
    end)
    
    closePickerBtn.MouseButton1Click:Connect(function()
        ColorPickerContainer.Visible = false
        ActiveColorPicker = nil
    end)
    
    --// ANIMATION FUNCTIONS
    local function AnimateIn(obj)
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Visible = true
        TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 350)
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
    
    -- Function to open color picker
    local function OpenColorPicker(title, defaultColor, callback)
        pickerTitle.Text = "🎨 " .. title
        -- Convert defaultColor to HSV to set initial hue
        local h, s, v = Color3.toHSV(defaultColor)
        currentHue = h
        colorCallback = callback
        previewFrame.BackgroundColor3 = defaultColor
        updateColorPicker() -- This will update the knob position and RGB text
        ColorPickerContainer.Visible = true
        ActiveColorPicker = ColorPickerContainer
    end
    
    --// TAB SYSTEM
    local Tabs = {}
    local CurrentTab = nil
    
    local function CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Size = UDim2.new(0, 45, 0, 20)
        tabBtn.Position = UDim2.new(0, #Tabs * 48 + 3, 0.5, -10)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.Text = icon
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabBtn.TextSize = 14
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
        content.ScrollBarImageColor3 = CONFIG.UI.MainColor
        content.Visible = false
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.Parent = ContentContainer
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = content
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = content
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
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
            
            tabBtn.BackgroundColor3 = CONFIG.UI.MainColor
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
    
    --// UI ELEMENTS - COMPACT
    local function CreateToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 26)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 38, 0, 18)
        toggleBtn.Position = UDim2.new(1, -44, 0.5, -9)
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 10
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 9)
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
        frame.Size = UDim2.new(1, 0, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 18)
        label.Position = UDim2.new(0, 8, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 18)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 3)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = CONFIG.UI.MainColor
        valueLabel.TextSize = 11
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -16, 0, 5)
        sliderBg.Position = UDim2.new(0, 8, 0, 26)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 3)
        bgCorner.Parent = sliderBg
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.UI.MainColor
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
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
            knob.Position = UDim2.new(pos, -5, 0.5, -5)
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
    
    -- FIXED: Dropdown now toggles properly with arrow indicator and full width expansion
    local function CreateDropdown(parent, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 5 -- ให้ dropdown อยู่บนสุดเมื่อเปิด
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 0, 30)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0, 110, 0, 22)
        dropBtn.Position = UDim2.new(1, -118, 0.5, -11)
        dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropBtn.Text = "▼ " .. default -- เริ่มต้นมีลูกศรลง
        dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropBtn.TextSize = 10
        dropBtn.Font = Enum.Font.GothamSemibold
        dropBtn.Parent = frame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 5)
        dropCorner.Parent = dropBtn
        
        local expanded = false
        local optionButtons = {}
        
        local function toggleDropdown()
            expanded = not expanded
            ButtonPress(dropBtn)
            
            if expanded then
                -- เปิด: เปลี่ยนเป็นลูกศรขึ้น ▲ และขยายเต็มความกว้าง
                dropBtn.Text = "▲ " .. default
                frame.ZIndex = 100 -- ยกระดับขึ้นมาบนสุด
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 30 + #options * 24)
                }):Play()
            else
                -- ปิด: เปลี่ยนเป็นลูกศรลง ▼ และกลับขนาดเดิม
                dropBtn.Text = "▼ " .. default
                frame.ZIndex = 5 -- คืนค่าระดับเดิม
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 30)
                }):Play()
            end
        end
        
        dropBtn.MouseButton1Click:Connect(toggleDropdown)
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -14, 0, 22)
            optBtn.Position = UDim2.new(0, 7, 0, 30 + (i-1) * 24)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.TextSize = 10
            optBtn.Font = Enum.Font.Gotham
            optBtn.ZIndex = 101 -- ปุ่มตัวเลือกต้องอยู่บนสุดด้วย
            optBtn.Parent = frame
            
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 5)
            optCorner.Parent = optBtn
            
            optBtn.MouseButton1Click:Connect(function()
                default = option
                expanded = false
                dropBtn.Text = "▼ " .. option -- เลือกแล้วกลับเป็นลูกศรลง
                frame.ZIndex = 5
                TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                if callback then callback(option) end
            end)
            
            table.insert(optionButtons, optBtn)
        end
        
        return frame
    end

    -- FIXED: Multi-select dropdown with proper toggle and arrow indicator
    local function CreateMultiDropdown(parent, text, isTarget)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 5 -- เริ่มต้นที่ระดับปกติ
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.25, 0, 0, 32)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Name = "DropBtn"
        dropBtn.Size = UDim2.new(0, 100, 0, 22)
        dropBtn.Position = UDim2.new(0.3, 0, 0.5, -11)
        dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- เริ่มต้นเป็นลูกศรลง ▼
        local count = isTarget and #CONFIG.Aimbot.TargetList or #CONFIG.Aimbot.AllyList
        dropBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
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
        refreshBtn.Size = UDim2.new(0, 26, 0, 22)
        refreshBtn.Position = UDim2.new(1, -32, 0.5, -11)
        refreshBtn.BackgroundColor3 = CONFIG.UI.MainColor
        refreshBtn.Text = "🔄"
        refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshBtn.TextSize = 12
        refreshBtn.Font = Enum.Font.GothamBold
        refreshBtn.ZIndex = 6 -- refresh ต้องอยู่เหนือ frame เสมอ
        refreshBtn.Parent = frame
        
        local refreshCorner = Instance.new("UICorner")
        refreshCorner.CornerRadius = UDim.new(0, 5)
        refreshCorner.Parent = refreshBtn
        
        -- SCROLLING FRAME - ซ่อนไว้ก่อน
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ScrollFrame"
        scrollFrame.Size = UDim2.new(1, -8, 1, -36)
        scrollFrame.Position = UDim2.new(0, 4, 0, 34)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = CONFIG.UI.MainColor
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible = false
        scrollFrame.ZIndex = 100 -- ยกระดับสูงสุดเมื่อเปิด
        scrollFrame.Parent = frame
        
        local function ToggleDropdown()
            if isTarget then
                TargetExpanded = not TargetExpanded
            else
                AllyExpanded = not AllyExpanded
            end
            
            local expanded = isTarget and TargetExpanded or AllyExpanded
            
            if expanded then
                -- เปิด: ลูกศรขึ้น ▲, ยกระดับ ZIndex, ขยายเต็มความกว้าง
                scrollFrame.Visible = true
                frame.ZIndex = 100
                scrollFrame.ZIndex = 101
                refreshBtn.ZIndex = 102 -- refresh ต้องอยู่บนสุดเสมอ
                dropBtn.Text = "▲"
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 150)
                }):Play()
            else
                -- ปิด: ลูกศรลง ▼, คืน ZIndex, ย่อกลับ
                scrollFrame.Visible = false
                frame.ZIndex = 5
                scrollFrame.ZIndex = 100
                refreshBtn.ZIndex = 6
                local count = isTarget and #CONFIG.Aimbot.TargetList or #CONFIG.Aimbot.AllyList
                dropBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 32)
                }):Play()
            end
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
                refreshBtn.BackgroundColor3 = CONFIG.UI.MainColor
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
    
    -- Color picker button (compact)
    local function CreateColorButton(parent, text, defaultColor, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 60, 0, 22)
        colorBtn.Position = UDim2.new(1, -68, 0.5, -11)
        colorBtn.BackgroundColor3 = defaultColor
        colorBtn.Text = "Pick"
        colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        colorBtn.TextSize = 10
        colorBtn.Font = Enum.Font.GothamBold
        colorBtn.Parent = frame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 5)
        colorCorner.Parent = colorBtn
        
        colorBtn.MouseButton1Click:Connect(function()
            OpenColorPicker(text, colorBtn.BackgroundColor3, function(newColor)
                colorBtn.BackgroundColor3 = newColor
                callback(newColor)
            end)
        end)
        
        return frame
    end
    
    --// CREATE 5 TABS
    
    -- 1. AIMBOT TAB
    local AimbotTab = CreateTab("Aimbot", "🎯")
    
    CreateToggle(AimbotTab, "Enable Aimbot", CONFIG.Aimbot.Enabled, function(val)
        CONFIG.Aimbot.Enabled = val
    end)
    
    CreateDropdown(AimbotTab, "Mode", {"Normal", "Lock"}, CONFIG.Aimbot.Mode, function(val)
        CONFIG.Aimbot.Mode = val
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
    
    CreateDropdown(AimbotTab, "Target", {"Head", "HumanoidRootPart", "Torso"}, CONFIG.Aimbot.TargetPart, function(val)
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
    
    CreateToggle(ESPTab, "Names", CONFIG.ESP.ShowName, function(val)
        CONFIG.ESP.ShowName = val
    end)
    
    CreateToggle(ESPTab, "Health", CONFIG.ESP.ShowHealth, function(val)
        CONFIG.ESP.ShowHealth = val
    end)
    
    CreateSlider(ESPTab, "Max Distance", 100, 3000, CONFIG.ESP.MaxDistance, function(val)
        CONFIG.ESP.MaxDistance = val
    end)
    
    -- 3. EXTRA TAB
    local ExtraTab = CreateTab("Extra", "✨")
    
    local AimbotLabel = Instance.new("TextLabel")
    AimbotLabel.Size = UDim2.new(1, 0, 0, 20)
    AimbotLabel.BackgroundTransparency = 1
    AimbotLabel.Text = "⚙️ AIMBOT"
    AimbotLabel.TextColor3 = CONFIG.UI.MainColor
    AimbotLabel.TextSize = 12
    AimbotLabel.Font = Enum.Font.GothamBold
    AimbotLabel.Parent = ExtraTab
    
    CreateSlider(ExtraTab, "Smoothness", 0, 10, CONFIG.Aimbot.Smoothness, function(val)
        CONFIG.Aimbot.Smoothness = val
    end)
    
    local AllyLabel = Instance.new("TextLabel")
    AllyLabel.Size = UDim2.new(1, 0, 0, 20)
    AllyLabel.BackgroundTransparency = 1
    AllyLabel.Text = "🛡️ PLAYERS"
    AllyLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    AllyLabel.TextSize = 12
    AllyLabel.Font = Enum.Font.GothamBold
    AllyLabel.Parent = ExtraTab
    
    CreateToggle(ExtraTab, "Use Target", CONFIG.Aimbot.UseTargetList, function(val)
        CONFIG.Aimbot.UseTargetList = val
    end)
    
    CreateMultiDropdown(ExtraTab, "Target", true)
    
    CreateToggle(ExtraTab, "Use Ally", CONFIG.Aimbot.UseAllyList, function(val)
        CONFIG.Aimbot.UseAllyList = val
    end)
    
    CreateMultiDropdown(ExtraTab, "Ally", false)
    
    -- 4. COLORS TAB
    local ColorsTab = CreateTab("Colors", "🎨")
    
    local ESPColorLabel = Instance.new("TextLabel")
    ESPColorLabel.Size = UDim2.new(1, 0, 0, 20)
    ESPColorLabel.BackgroundTransparency = 1
    ESPColorLabel.Text = "👁️ ESP COLORS"
    ESPColorLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    ESPColorLabel.TextSize = 12
    ESPColorLabel.Font = Enum.Font.GothamBold
    ESPColorLabel.Parent = ColorsTab
    
    CreateToggle(ColorsTab, "ESP RGB", CONFIG.ESP.UseRGB, function(val)
        CONFIG.ESP.UseRGB = val
    end)
    
    CreateSlider(ColorsTab, "RGB Speed", 1, 20, CONFIG.ESP.RGBSpeed, function(val)
        CONFIG.ESP.RGBSpeed = val
    end)
    
    CreateColorButton(ColorsTab, "Enemy", CONFIG.ESP.TextColor, function(color)
        CONFIG.ESP.TextColor = color
    end)
    
    CreateColorButton(ColorsTab, "Ally", CONFIG.ESP.AllyColor, function(color)
        CONFIG.ESP.AllyColor = color
    end)
    
    CreateColorButton(ColorsTab, "Box", CONFIG.ESP.BoxColor, function(color)
        CONFIG.ESP.BoxColor = color
    end)
    
    local FOVColorLabel = Instance.new("TextLabel")
    FOVColorLabel.Size = UDim2.new(1, 0, 0, 20)
    FOVColorLabel.BackgroundTransparency = 1
    FOVColorLabel.Text = "🎯 FOV COLORS"
    FOVColorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    FOVColorLabel.TextSize = 12
    FOVColorLabel.Font = Enum.Font.GothamBold
    FOVColorLabel.Parent = ColorsTab
    
    CreateToggle(ColorsTab, "FOV RGB", CONFIG.Aimbot.FOVUseRGB, function(val)
        CONFIG.Aimbot.FOVUseRGB = val
    end)
    
    CreateColorButton(ColorsTab, "FOV Circle", CONFIG.Aimbot.FOVColor, function(color)
        CONFIG.Aimbot.FOVColor = color
    end)
    
    local UIColorLabel = Instance.new("TextLabel")
    UIColorLabel.Size = UDim2.new(1, 0, 0, 20)
    UIColorLabel.BackgroundTransparency = 1
    UIColorLabel.Text = "🎨 UI COLOR"
    UIColorLabel.TextColor3 = CONFIG.UI.MainColor
    UIColorLabel.TextSize = 12
    UIColorLabel.Font = Enum.Font.GothamBold
    UIColorLabel.Parent = ColorsTab
    
    CreateColorButton(ColorsTab, "Main UI", CONFIG.UI.MainColor, function(color)
        CONFIG.UI.MainColor = color
        ToggleBtn.BackgroundColor3 = color
        for _, tab in ipairs(Tabs) do
            if tab.Content.Visible then
                tab.Button.BackgroundColor3 = color
            end
        end
    end)
    
    -- 5. INFO TAB
    local InfoTab = CreateTab("Info", "ℹ️")
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, 0, 0, 200)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "Combat System v3.1\n\n🎯 Aimbot:\n- Normal: Use FOV\n- Lock: No FOV limit\n\n👁️ ESP:\n- [ALLY] = Ally list or Team\n- [ENEMY] = Normal target\n\n🎨 Colors:\n- RGB mode for rainbow\n- Color picker for custom\n\n✅ Fixed:\n- Dropdowns now toggle\n- Color picker text 100% visible\n- FOV RGB uses speed slider\n\nMade by Kimi"
    InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoText.TextSize = 10
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextWrapped = true
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.Parent = InfoTab
    
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
    EnableDragging(ColorPickerContainer, pickerTitle)
    
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
            ToggleBtn.BackgroundColor3 = CONFIG.UI.MainColor
        else
            AnimateOut(MainFrame)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            -- Close color picker too
            ColorPickerContainer.Visible = false
        end
    end)
    
    --// CLOSE
    CloseBtn.MouseButton1Click:Connect(function()
        ButtonPress(CloseBtn)
        AnimateOut(MainFrame)
        UIVisible = false
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ColorPickerContainer.Visible = false
    end)
    
    --// FOV CIRCLE
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    
    --// MAIN LOOP
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        local deltaTime = tick() - lastUpdate
        lastUpdate = tick()
        
        -- FOV RGB - NOW USES RGB SPEED SLIDER
        if CONFIG.Aimbot.FOVUseRGB then
            -- Use the same speed calculation as ESP RGB but with FOVHue
            FOVHue = (FOVHue + deltaTime * CONFIG.ESP.RGBSpeed * 0.1) % 1
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
    
    --// INIT
    if Tabs[1] then
        Tabs[1].Button.BackgroundColor3 = CONFIG.UI.MainColor
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
    
    print("✅ Combat System v3.1 Loaded!")
    print("📱 Mobile Optimized (250x350)")
    print("🎨 Color Picker on top layer")
    print("🎯 FOV RGB uses RGB Speed slider")
    print("📋 Dropdowns now toggle properly")
end)

if not success then
    warn("❌ Error:", result)
end
