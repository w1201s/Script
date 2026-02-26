--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIG
local CONFIG = {
    Aimbot = {
        Enabled = false, Mode = "Normal", TeamCheck = true, WallCheck = true,
        Smoothness = 0, FOV = 150, ShowFOV = true,
        FOVColor = Color3.fromRGB(0, 170, 255), FOVUseRGB = false,
        MaxDistance = 1000, TargetPart = "Head",
        UseTargetList = false, UseAllyList = false,
        TargetList = {}, AllyList = {},
        InstantLock = nil -- NEW: Instant lock target
    },
    ESP = {
        Enabled = true, MaxDistance = 1000, TextSize = 13,
        TextColor = Color3.fromRGB(255, 50, 50), AllyColor = Color3.fromRGB(50, 255, 50),
        BoxColor = Color3.fromRGB(255, 0, 0), ShowName = true, ShowHealth = true,
        ShowDistance = true, ShowWeapon = true, TeamCheck = true,
        BoxESP = true, TracerESP = true, TracerPosition = "Bottom", -- NEW: Bottom/Top/Left/Right
        Chams = true, UseRGB = false, RGBSpeed = 5
    },
    UI = { MainColor = Color3.fromRGB(0, 170, 255) }
}

--// VARS
local ESPObjects = {}
local UIVisible = true
local Dragging, DragStart, StartPos = nil, nil, nil
local ExpandedDropdowns = {}

--// UTILS
local function GetChar(p) return p and p.Character end
local function IsAlive(c) 
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 
end
local function IsTeam(p) return p.Team == LocalPlayer.Team end
local function GetWeapon(c) 
    local t = c:FindFirstChildOfClass("Tool") 
    return t and t.Name or "None" 
end
local function WTS(pos)
    local s, o = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), o, s.Z
end
local function IsVis(part)
    if not CONFIG.Aimbot.WallCheck then return true end
    local r = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, 
        RaycastParams.new({FilterDescendantsInstances = {LocalPlayer.Character}, FilterType = Enum.RaycastFilterType.Blacklist}))
    return not r or r.Instance:FindFirstAncestorOfClass("Model") == part.Parent
end

--// ESP SYSTEM
local function CreateESP(p)
    if ESPObjects[p] then return end
    local d = {Player = p, Drawings = {}, Highlight = nil}
    
    local function newDrawing(t, props)
        local dr = Drawing.new(t)
        for k,v in pairs(props) do dr[k] = v end
        return dr
    end
    
    d.Drawings.Name = newDrawing("Text", {Center = true, Outline = true, Size = CONFIG.ESP.TextSize})
    d.Drawings.Health = newDrawing("Text", {Center = true, Outline = true, Size = CONFIG.ESP.TextSize - 2})
    d.Drawings.Dist = newDrawing("Text", {Center = true, Outline = true, Size = CONFIG.ESP.TextSize - 2})
    d.Drawings.Weapon = newDrawing("Text", {Center = true, Outline = true, Size = CONFIG.ESP.TextSize - 2})
    d.Drawings.Box = newDrawing("Square", {Thickness = 1.5, Filled = false, Visible = false})
    d.Drawings.Filled = newDrawing("Square", {Thickness = 1, Filled = true, Transparency = 0.2, Visible = false})
    d.Drawings.Tracer = newDrawing("Line", {Thickness = 1, Visible = false})
    
    d.Update = function(dt)
        if not CONFIG.ESP.Enabled then
            for _,dr in pairs(d.Drawings) do dr.Visible = false end
            if d.Highlight then d.Highlight.Enabled = false end
            return
        end
        
        local c = GetChar(p)
        if not IsAlive(c) then
            for _,dr in pairs(d.Drawings) do dr.Visible = false end
            if d.Highlight then d.Highlight.Enabled = false end
            return
        end
        
        local h, root, head = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Head")
        if not (h and root and head) then return end
        
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > CONFIG.ESP.MaxDistance then
            for _,dr in pairs(d.Drawings) do dr.Visible = false end
            if d.Highlight then d.Highlight.Enabled = false end
            return
        end
        
        local isFriend = (CONFIG.ESP.TeamCheck and IsTeam(p)) or (CONFIG.Aimbot.UseAllyList and table.find(CONFIG.Aimbot.AllyList, p.Name))
        local col = CONFIG.ESP.UseRGB and Color3.fromHSV((tick() * CONFIG.ESP.RGBSpeed * 0.1) % 1, 1, 1) or 
            (isFriend and CONFIG.ESP.AllyColor or CONFIG.ESP.TextColor)
        
        local headPos, headOn = WTS(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOn = WTS(root.Position - Vector3.new(0, 3, 0))
        
        if not (headOn or rootOn) then
            for _,dr in pairs(d.Drawings) do dr.Visible = false end
            return
        end
        
        -- Tracer Position
        local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Bottom default
        if CONFIG.ESP.TracerPosition == "Top" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
        elseif CONFIG.ESP.TracerPosition == "Left" then
            tracerStart = Vector2.new(0, Camera.ViewportSize.Y / 2)
        elseif CONFIG.ESP.TracerPosition == "Right" then
            tracerStart = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
        end
        
        local boxH = math.abs(headPos.Y - rootPos.Y)
        local boxW = boxH * 0.6
        local boxPos = Vector2.new(headPos.X - boxW / 2, headPos.Y)
        
        -- Update drawings
        d.Drawings.Name.Color = col
        d.Drawings.Box.Color = col
        d.Drawings.Filled.Color = col
        d.Drawings.Tracer.Color = col
        
        if CONFIG.ESP.ShowName then
            d.Drawings.Name.Text = p.Name .. (isFriend and " [ALLY]" or " [ENEMY]")
            d.Drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            d.Drawings.Name.Visible = true
        else d.Drawings.Name.Visible = false end
        
        if CONFIG.ESP.ShowHealth then
            local hp = math.floor((h.Health / h.MaxHealth) * 100)
            d.Drawings.Health.Text = hp .. " HP"
            d.Drawings.Health.Color = Color3.fromRGB(255 - hp * 2.55, hp * 2.55, 0)
            d.Drawings.Health.Position = Vector2.new(headPos.X, headPos.Y - 35)
            d.Drawings.Health.Visible = true
        else d.Drawings.Health.Visible = false end
        
        if CONFIG.ESP.ShowDistance then
            d.Drawings.Dist.Text = math.floor(dist) .. "m"
            d.Drawings.Dist.Position = Vector2.new(headPos.X, rootPos.Y + 5)
            d.Drawings.Dist.Visible = true
        else d.Drawings.Dist.Visible = false end
        
        if CONFIG.ESP.ShowWeapon then
            d.Drawings.Weapon.Text = GetWeapon(c)
            d.Drawings.Weapon.Position = Vector2.new(headPos.X, rootPos.Y + 20)
            d.Drawings.Weapon.Visible = true
        else d.Drawings.Weapon.Visible = false end
        
        if CONFIG.ESP.BoxESP then
            d.Drawings.Box.Size = Vector2.new(boxW, boxH)
            d.Drawings.Box.Position = boxPos
            d.Drawings.Box.Visible = true
            d.Drawings.Filled.Size = Vector2.new(boxW, boxH)
            d.Drawings.Filled.Position = boxPos
            d.Drawings.Filled.Visible = CONFIG.ESP.Chams
        else
            d.Drawings.Box.Visible = false
            d.Drawings.Filled.Visible = false
        end
        
        if CONFIG.ESP.TracerESP then
            d.Drawings.Tracer.From = tracerStart
            d.Drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            d.Drawings.Tracer.Visible = true
        else d.Drawings.Tracer.Visible = false end
        
        if CONFIG.ESP.Chams then
            if not d.Highlight or d.Highlight.Parent ~= c then
                if d.Highlight then d.Highlight:Destroy() end
                d.Highlight = Instance.new("Highlight", c)
                d.Highlight.OutlineColor = Color3.new(1, 1, 1)
                d.Highlight.FillTransparency = 0.5
            end
            d.Highlight.Enabled = true
            d.Highlight.FillColor = col
        elseif d.Highlight then d.Highlight.Enabled = false end
    end
    
    d.Cleanup = function()
        for _,dr in pairs(d.Drawings) do dr:Remove() end
        if d.Highlight then d.Highlight:Destroy() end
    end
    
    ESPObjects[p] = d
end

local function RemoveESP(p)
    if ESPObjects[p] then ESPObjects[p].Cleanup(); ESPObjects[p] = nil end
end

--// AIMBOT LOGIC
local function GetTarget()
    local mode = CONFIG.Aimbot.Mode
    -- Instant Lock priority
    if CONFIG.Aimbot.InstantLock and IsAlive(GetChar(CONFIG.Aimbot.InstantLock)) then
        local c = GetChar(CONFIG.Aimbot.InstantLock)
        local part = c:FindFirstChild(CONFIG.Aimbot.TargetPart)
        if part and (not CONFIG.Aimbot.WallCheck or IsVis(part)) then
            local _, onScreen, depth = WTS(part.Position)
            if onScreen and depth <= CONFIG.Aimbot.MaxDistance then
                return CONFIG.Aimbot.InstantLock
            end
        end
    end
    
    local closest, shortest = nil, (mode == "Lock" and math.huge or CONFIG.Aimbot.FOV)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(GetChar(p)) then continue end
        if CONFIG.Aimbot.TeamCheck and IsTeam(p) then continue end
        if CONFIG.Aimbot.UseAllyList and table.find(CONFIG.Aimbot.AllyList, p.Name) then continue end
        if CONFIG.Aimbot.UseTargetList and not table.find(CONFIG.Aimbot.TargetList, p.Name) then continue end
        
        local c = GetChar(p)
        local part = c:FindFirstChild(CONFIG.Aimbot.TargetPart)
        if not part then continue end
        if CONFIG.Aimbot.WallCheck and not IsVis(part) then continue end
        
        local pos, onScreen, depth = WTS(part.Position)
        if not onScreen or depth > CONFIG.Aimbot.MaxDistance then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < shortest then
            shortest = dist
            closest = p
        end
    end
    return closest
end

--// UI CREATION (COMPACT)
local function CreateUI()
    local sg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "CombatUI"; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mf = Instance.new("Frame", sg)
    mf.Size = UDim2.new(0, 250, 0, 350)
    mf.Position = UDim2.new(0.5, -125, 0.5, -175)
    mf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mf.ClipsDescendants = true
    Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)
    
    -- Color Picker (Separate)
    local cp = Instance.new("Frame", sg)
    cp.Size = UDim2.new(0, 220, 0, 180)
    cp.Position = UDim2.new(0.5, -110, 0.5, -90)
    cp.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    cp.Visible = false; cp.ZIndex = 1000
    Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 10)
    
    -- Title
    local tb = Instance.new("Frame", mf)
    tb.Size = UDim2.new(1, 0, 0, 28)
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
    
    local tf = Instance.new("Frame", tb) -- Fix corner
    tf.Size = UDim2.new(1, 0, 0, 12)
    tf.Position = UDim2.new(0, 0, 1, -12)
    tf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    
    Instance.new("TextLabel", tb).Text = "⚔️ COMBAT"
    
    -- Close
    local cb = Instance.new("TextButton", tb)
    cb.Size = UDim2.new(0, 22, 0, 22)
    cb.Position = UDim2.new(1, -28, 0.5, -11)
    cb.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    cb.Text = "X"
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5)
    
    -- Tabs
    local tc = Instance.new("Frame", mf)
    tc.Size = UDim2.new(1, -12, 0, 26)
    tc.Position = UDim2.new(0, 6, 0, 34)
    tc.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", tc).CornerRadius = UDim.new(0, 6)
    
    local cc = Instance.new("Frame", mf)
    cc.Size = UDim2.new(1, -12, 1, -68)
    cc.Position = UDim2.new(0, 6, 0, 64)
    cc.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    cc.ClipsDescendants = true
    Instance.new("UICorner", cc).CornerRadius = UDim.new(0, 6)
    
    -- Toggle Button
    local tgb = Instance.new("TextButton", sg)
    tgb.Size = UDim2.new(0, 40, 0, 40)
    tgb.Position = UDim2.new(0, 10, 0.5, -20)
    tgb.BackgroundColor3 = CONFIG.UI.MainColor
    tgb.Text = "⚔️"
    Instance.new("UICorner", tgb).CornerRadius = UDim.new(1, 0)
    
    --// UNIFIED DROPDOWN FUNCTION
    local function CreateDropdown(parent, text, options, default, callback, isMulti, isInstant)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, isMulti and 32 or 30)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        f.ClipsDescendants = true
        f.ZIndex = 5
        
        local id = tostring(f)
        ExpandedDropdowns[id] = false
        
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
        
        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(isMulti and 0.25 or 0.4, 0, 0, isMulti and 32 or 30)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        
        -- Header button (click to toggle)
        local hdr = Instance.new("TextButton", f)
        hdr.Name = "Header"
        hdr.Size = UDim2.new(0, isMulti and 100 or 110, 0, 22)
        hdr.Position = UDim2.new(isMulti and 0.3 or 1, isMulti and 0 or -118, 0.5, -11)
        hdr.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        hdr.Text = "▼ " .. (isMulti and (default > 0 and tostring(default) or "Select") or default)
        hdr.TextColor3 = Color3.fromRGB(255, 255, 255)
        hdr.TextSize = 10
        hdr.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 5)
        
        -- ScrollFrame for multi
        local sf
        if isMulti then
            sf = Instance.new("ScrollingFrame", f)
            sf.Size = UDim2.new(1, -8, 1, -36)
            sf.Position = UDim2.new(0, 4, 0, 34)
            sf.BackgroundTransparency = 1
            sf.ScrollBarThickness = 3
            sf.Visible = false
            sf.ZIndex = 100
        end
        
        local function Toggle()
            ExpandedDropdowns[id] = not ExpandedDropdowns[id]
            local exp = ExpandedDropdowns[id]
            
            if exp then
                hdr.Text = "▲"
                f.ZIndex = 100
                if sf then 
                    sf.Visible = true 
                    f.Size = UDim2.new(1, 0, 0, 150)
                else
                    f.Size = UDim2.new(1, 0, 0, 30 + #options * 24)
                end
            else
                local count = isMulti and default or 0
                hdr.Text = "▼ " .. (isMulti and (count > 0 and tostring(count) or "Select") or default)
                f.ZIndex = 5
                if sf then sf.Visible = false end
                f.Size = UDim2.new(1, 0, 0, isMulti and 32 or 30)
            end
            
            TweenService:Create(f, TweenInfo.new(0.2), {Size = exp and (isMulti and UDim2.new(1, 0, 0, 150) or UDim2.new(1, 0, 0, 30 + #options * 24)) or UDim2.new(1, 0, 0, isMulti and 32 or 30)}):Play()
        end
        
        hdr.MouseButton1Click:Connect(Toggle)
        
        -- Options
        if not isMulti then
            for i, opt in ipairs(options) do
                local btn = Instance.new("TextButton", f)
                btn.Size = UDim2.new(1, -14, 0, 22)
                btn.Position = UDim2.new(0, 7, 0, 30 + (i-1) * 24)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                btn.Text = opt
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                btn.TextSize = 10
                btn.ZIndex = 101
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    default = opt
                    ExpandedDropdowns[id] = false
                    hdr.Text = "▼ " .. opt
                    f.ZIndex = 5
                    f.Size = UDim2.new(1, 0, 0, 30)
                    TweenService:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                    if callback then callback(opt) end
                end)
            end
        end
        
        return f, hdr, sf
    end
    
    --// UI ELEMENTS
    local function CreateToggle(parent, text, default, cb)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 26)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
        
        Instance.new("TextLabel", f).Text = text
        
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 38, 0, 18)
        btn.Position = UDim2.new(1, -44, 0.5, -9)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        btn.Text = default and "ON" or "OFF"
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
        
        local en = default
        btn.MouseButton1Click:Connect(function()
            en = not en
            btn.BackgroundColor3 = en and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
            btn.Text = en and "ON" or "OFF"
            if cb then cb(en) end
        end)
        return f
    end
    
    local function CreateSlider(parent, text, min, max, def, cb)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 42)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
        
        local lbl = Instance.new("TextLabel", f)
        lbl.Text = text; lbl.Position = UDim2.new(0, 8, 0, 3)
        
        local val = Instance.new("TextLabel", f)
        val.Text = tostring(def); val.Position = UDim2.new(0.7, 0, 0, 3)
        val.TextColor3 = CONFIG.UI.MainColor
        
        local bg = Instance.new("Frame", f)
        bg.Size = UDim2.new(1, -16, 0, 5)
        bg.Position = UDim2.new(0, 8, 0, 26)
        bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)
        
        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.UI.MainColor
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local knob = Instance.new("Frame", bg)
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((def - min) / (max - min), -5, 0.5, -5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)
        
        local drag = false
        local function upd(inp)
            local pos = math.clamp((inp.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + pos * (max - min))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -5, 0.5, -5)
            val.Text = tostring(v)
            if cb then cb(v) end
        end
        
        bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; upd(i) end end)
        UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
        return f
    end
    
    --// TABS SETUP
    local tabs = {}
    local curTab = nil
    
    local function Tab(name, icon)
        local btn = Instance.new("TextButton", tc)
        btn.Size = UDim2.new(0, 45, 0, 20)
        btn.Position = UDim2.new(0, #tabs * 48 + 3, 0.5, -10)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = icon
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        
        local content = Instance.new("ScrollingFrame", cc)
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 3
        content.Visible = false
        
        local lay = Instance.new("UIListLayout", content)
        lay.Padding = UDim.new(0, 5)
        Instance.new("UIPadding", content).PaddingTop = UDim.new(0, 6)
        
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 12)
        end)
        
        btn.MouseButton1Click:Connect(function()
            if curTab == content then return end
            if curTab then curTab.Visible = false end
            for _, t in ipairs(tabs) do
                t.Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                t.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            btn.BackgroundColor3 = CONFIG.UI.MainColor
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            content.Visible = true
            curTab = content
        end)
        
        table.insert(tabs, {Btn = btn, Content = content})
        return content
    end
    
    --// BUILD TABS
    -- Aimbot
    local ab = Tab("Aimbot", "🎯")
    CreateToggle(ab, "Enable", CONFIG.Aimbot.Enabled, function(v) CONFIG.Aimbot.Enabled = v end)
    CreateDropdown(ab, "Mode", {"Normal", "Lock"}, CONFIG.Aimbot.Mode, function(v) CONFIG.Aimbot.Mode = v end)
    CreateToggle(ab, "Team Check", CONFIG.Aimbot.TeamCheck, function(v) CONFIG.Aimbot.TeamCheck = v end)
    CreateToggle(ab, "Wall Check", CONFIG.Aimbot.WallCheck, function(v) CONFIG.Aimbot.WallCheck = v end)
    CreateToggle(ab, "Show FOV", CONFIG.Aimbot.ShowFOV, function(v) CONFIG.Aimbot.ShowFOV = v end)
    CreateSlider(ab, "FOV", 50, 400, CONFIG.Aimbot.FOV, function(v) CONFIG.Aimbot.FOV = v end)
    CreateSlider(ab, "Max Dist", 100, 2000, CONFIG.Aimbot.MaxDistance, function(v) CONFIG.Aimbot.MaxDistance = v end)
    CreateDropdown(ab, "Target", {"Head", "HumanoidRootPart", "Torso"}, CONFIG.Aimbot.TargetPart, function(v) CONFIG.Aimbot.TargetPart = v end)
    
    -- ESP
    local eb = Tab("ESP", "👁️")
    CreateToggle(eb, "Enable", CONFIG.ESP.Enabled, function(v) CONFIG.ESP.Enabled = v end)
    CreateToggle(eb, "Team Check", CONFIG.ESP.TeamCheck, function(v) CONFIG.ESP.TeamCheck = v end)
    CreateToggle(eb, "Box", CONFIG.ESP.BoxESP, function(v) CONFIG.ESP.BoxESP = v end)
    CreateToggle(eb, "Tracer", CONFIG.ESP.TracerESP, function(v) CONFIG.ESP.TracerESP = v end)
    CreateDropdown(eb, "Tracer Pos", {"Bottom", "Top", "Left", "Right"}, CONFIG.ESP.TracerPosition, function(v) CONFIG.ESP.TracerPosition = v end)
    CreateToggle(eb, "Chams", CONFIG.ESP.Chams, function(v) CONFIG.ESP.Chams = v end)
    CreateToggle(eb, "Names", CONFIG.ESP.ShowName, function(v) CONFIG.ESP.ShowName = v end)
    CreateToggle(eb, "Health", CONFIG.ESP.ShowHealth, function(v) CONFIG.ESP.ShowHealth = v end)
    CreateSlider(eb, "Max Dist", 100, 3000, CONFIG.ESP.MaxDistance, function(v) CONFIG.ESP.MaxDistance = v end)
    
    -- Extra
    local xb = Tab("Extra", "✨")
    CreateSlider(xb, "Smooth", 0, 10, CONFIG.Aimbot.Smoothness, function(v) CONFIG.Aimbot.Smoothness = v end)
    CreateToggle(xb, "Use Target", CONFIG.Aimbot.UseTargetList, function(v) CONFIG.Aimbot.UseTargetList = v end)
    
    -- Multi Dropdown for Target with Instant Lock
    local tFrame, tBtn, tScroll = CreateDropdown(xb, "Target", {}, #CONFIG.Aimbot.TargetList, nil, true)
    
    local function RefreshTargets()
        if not tScroll then return end
        for _, c in ipairs(tScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        local y = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            
            local sel = table.find(CONFIG.Aimbot.TargetList, p.Name)
            local btn = Instance.new("TextButton", tScroll)
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.BackgroundColor3 = sel and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
            btn.Text = "@" .. p.Name
            btn.TextColor3 = sel and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
            btn.TextSize = 10
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            
            -- Click to select AND instant lock
            btn.MouseButton1Click:Connect(function()
                if sel then
                    table.remove(CONFIG.Aimbot.TargetList, table.find(CONFIG.Aimbot.TargetList, p.Name))
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    if CONFIG.Aimbot.InstantLock == p then CONFIG.Aimbot.InstantLock = nil end
                else
                    table.insert(CONFIG.Aimbot.TargetList, p.Name)
                    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    -- INSTANT LOCK
                    CONFIG.Aimbot.InstantLock = p
                end
                
                -- Update header
                local count = #CONFIG.Aimbot.TargetList
                local exp = ExpandedDropdowns[tostring(tFrame)]
                if not exp then
                    tBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                end
                
                -- Close dropdown on select
                ExpandedDropdowns[tostring(tFrame)] = false
                tBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                tFrame.ZIndex = 5
                tScroll.Visible = false
                tFrame.Size = UDim2.new(1, 0, 0, 32)
                TweenService:Create(tFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 32)}):Play()
            end)
            
            y = y + 30
        end
        tScroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)
    end
    
    -- Refresh button
    local trb = Instance.new("TextButton", tFrame)
    trb.Size = UDim2.new(0, 26, 0, 22)
    trb.Position = UDim2.new(1, -32, 0.5, -11)
    trb.BackgroundColor3 = CONFIG.UI.MainColor
    trb.Text = "🔄"
    trb.TextSize = 12
    Instance.new("UICorner", trb).CornerRadius = UDim.new(0, 5)
    trb.MouseButton1Click:Connect(function()
        RefreshTargets()
        trb.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        task.delay(0.3, function() trb.BackgroundColor3 = CONFIG.UI.MainColor end)
    end)
    
    CreateToggle(xb, "Use Ally", CONFIG.Aimbot.UseAllyList, function(v) CONFIG.Aimbot.UseAllyList = v end)
    local aFrame, aBtn, aScroll = CreateDropdown(xb, "Ally", {}, #CONFIG.Aimbot.AllyList, nil, true)
    
    local function RefreshAllies()
        if not aScroll then return end
        for _, c in ipairs(aScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        local y = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            
            local sel = table.find(CONFIG.Aimbot.AllyList, p.Name)
            local btn = Instance.new("TextButton", aScroll)
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.BackgroundColor3 = sel and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(45, 45, 45)
            btn.Text = "@" .. p.Name
            btn.TextColor3 = sel and Color3.new(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            btn.TextSize = 10
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            
            btn.MouseButton1Click:Connect(function()
                if sel then
                    table.remove(CONFIG.Aimbot.AllyList, table.find(CONFIG.Aimbot.AllyList, p.Name))
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                else
                    table.insert(CONFIG.Aimbot.AllyList, p.Name)
                    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                    btn.TextColor3 = Color3.new(0, 0, 0)
                end
                
                local count = #CONFIG.Aimbot.AllyList
                local exp = ExpandedDropdowns[tostring(aFrame)]
                if not exp then
                    aBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                end
                
                -- Close on select
                ExpandedDropdowns[tostring(aFrame)] = false
                aBtn.Text = "▼ " .. (count > 0 and tostring(count) or "Select")
                aFrame.ZIndex = 5
                aScroll.Visible = false
                aFrame.Size = UDim2.new(1, 0, 0, 32)
                TweenService:Create(aFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 32)}):Play()
            end)
            
            y = y + 30
        end
        aScroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)
    end
    
    local arb = Instance.new("TextButton", aFrame)
    arb.Size = UDim2.new(0, 26, 0, 22)
    arb.Position = UDim2.new(1, -32, 0.5, -11)
    arb.BackgroundColor3 = CONFIG.UI.MainColor
    arb.Text = "🔄"
    arb.TextSize = 12
    Instance.new("UICorner", arb).CornerRadius = UDim.new(0, 5)
    arb.MouseButton1Click:Connect(function()
        RefreshAllies()
        arb.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        task.delay(0.3, function() arb.BackgroundColor3 = CONFIG.UI.MainColor end)
    end)
    
    -- Colors
    local cb = Tab("Colors", "🎨")
    CreateToggle(cb, "ESP RGB", CONFIG.ESP.UseRGB, function(v) CONFIG.ESP.UseRGB = v end)
    CreateSlider(cb, "RGB Speed", 1, 20, CONFIG.ESP.RGBSpeed, function(v) CONFIG.ESP.RGBSpeed = v end)
    
    -- Info
    local ib = Tab("Info", "ℹ️")
    local info = Instance.new("TextLabel", ib)
    info.Text = "Combat v4.0\n\n🎯 Instant Lock: Click player in Target dropdown\n👁️ Tracer: Choose position in ESP tab\n📋 Dropdowns: Click header or arrow to toggle"
    info.TextWrapped = true
    
    --// INIT
    RefreshTargets()
    RefreshAllies()
    Players.PlayerAdded:Connect(function() task.delay(0.5, function() RefreshTargets(); RefreshAllies() end) end)
    Players.PlayerRemoving:Connect(function() task.delay(0.5, function() RefreshTargets(); RefreshAllies() end) end)
    
    -- Dragging
    local function Drag(f, h)
        h.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging, DragStart, StartPos = f, i.Position, f.Position
            end
        end)
    end
    Drag(mf, tb)
    Drag(tgb, tgb)
    
    UserInputService.InputChanged:Connect(function(i)
        if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - DragStart
            Dragging.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + d.X, StartPos.Y.Scale, StartPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = nil end end)
    
    -- Toggle UI
    local visible = true
    tgb.MouseButton1Click:Connect(function()
        visible = not visible
        mf.Visible = visible
        tgb.BackgroundColor3 = visible and CONFIG.UI.MainColor or Color3.fromRGB(100, 100, 100)
    end)
    
    cb.MouseButton1Click:Connect(function()
        visible = false
        mf.Visible = false
        tgb.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    --// MAIN LOOP
    local FOV = Drawing.new("Circle")
    FOV.Thickness = 1.5; FOV.Filled = false; FOV.NumSides = 64
    
    RunService.RenderStepped:Connect(function()
        -- FOV
        if CONFIG.Aimbot.FOVUseRGB then
            FOV.Color = Color3.fromHSV((tick() * CONFIG.ESP.RGBSpeed * 0.1) % 1, 1, 1)
        else
            FOV.Color = CONFIG.Aimbot.FOVColor
        end
        FOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOV.Radius = CONFIG.Aimbot.FOV
        FOV.Visible = CONFIG.Aimbot.Enabled and CONFIG.Aimbot.ShowFOV
        
        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if not ESPObjects[p] then CreateESP(p) end
                ESPObjects[p].Update()
            end
        end
        for p, _ in pairs(ESPObjects) do if not p.Parent then RemoveESP(p) end end
        
        -- Aimbot
        if CONFIG.Aimbot.Enabled then
            local t = GetTarget()
            if t then
                local c = GetChar(t)
                local part = c:FindFirstChild(CONFIG.Aimbot.TargetPart)
                if part then
                    if CONFIG.Aimbot.Smoothness <= 0 then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    else
                        local s = math.clamp(1 - CONFIG.Aimbot.Smoothness / 10, 0.01, 1) * 0.5
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), s)
                    end
                end
            end
        end
    end)
    
    -- Init first tab
    if tabs[1] then
        tabs[1].Btn.BackgroundColor3 = CONFIG.UI.MainColor
        tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabs[1].Content.Visible = true
        curTab = tabs[1].Content
    end
    
    return sg
end

--// START
pcall(function()
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    CreateUI()
    print("✅ Combat v4.0 Loaded!")
end)
