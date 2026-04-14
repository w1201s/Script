--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- โหลด Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ค่าเริ่มต้นปกติ
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

-- สร้างหน้าต่าง
local Window = Rayfield:CreateWindow({
    Name = "Silent Aim + Fling + Freeze",
    LoadingTitle = "Multi-Feature Script",
    LoadingSubtitle = "by You",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "MultiFeatureConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- ==================== SILENT AIM CONFIG ====================
local SilentAimTab = Window:CreateTab("Silent Aim", 4483362458)
local SilentAimSection = SilentAimTab:CreateSection("Silent Aim Settings")

local SilentAimConfig = {
    Enabled = true,
    Distance = 28,
    TargetMode = "cursor",
    FOV = 100,
    ShowFOVCircle = true,
}

local targetPosition = nil

SilentAimTab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = SilentAimConfig.Enabled,
    Flag = "SilentAimEnabled",
    Callback = function(Value)
        SilentAimConfig.Enabled = Value
        if not Value then
            targetPosition = nil
        end
    end,
})

SilentAimTab:CreateSlider({
    Name = "Aim Distance",
    Range = {10, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = SilentAimConfig.Distance,
    Flag = "AimDistance",
    Callback = function(Value)
        SilentAimConfig.Distance = Value
    end,
})

SilentAimTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"cursor", "center"},
    CurrentOption = {SilentAimConfig.TargetMode},
    MultipleOptions = false,
    Flag = "TargetMode",
    Callback = function(Options)
        SilentAimConfig.TargetMode = Options[1]
    end,
})

SilentAimTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = SilentAimConfig.FOV,
    Flag = "FOVRadius",
    Callback = function(Value)
        SilentAimConfig.FOV = Value
    end,
})

SilentAimTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = SilentAimConfig.ShowFOVCircle,
    Flag = "ShowFOVCircle",
    Callback = function(Value)
        SilentAimConfig.ShowFOVCircle = Value
    end,
})

-- ==================== FLING CONFIG ====================
local FlingTab = Window:CreateTab("Fling", 4483362458)
local FlingSection = FlingTab:CreateSection("Fling Settings")

local FlingConfig = {
    Enabled = true,
    Strength = 850,
}

local Debris = game:GetService("Debris")

FlingTab:CreateToggle({
    Name = "Enable Fling",
    CurrentValue = FlingConfig.Enabled,
    Flag = "FlingEnabled",
    Callback = function(Value)
        FlingConfig.Enabled = Value
    end,
})

FlingTab:CreateSlider({
    Name = "Fling Strength",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "power",
    CurrentValue = FlingConfig.Strength,
    Flag = "FlingStrength",
    Callback = function(Value)
        FlingConfig.Strength = Value
    end,
})

-- ==================== INVISIBLE / FAKE SELF CONFIG ====================
local InvisibleTab = Window:CreateTab("Invisible", 4483362458)
local InvisibleSection = InvisibleTab:CreateSection("Invisible / Fake Self Settings")

local InvisibleConfig = {
    Enabled = false,
    FakeSelfTransparency = 0.3,
}

local realCharacter = nil
local fakeCharacter = nil
local fakeHumanoid = nil
local isInvisible = false

InvisibleTab:CreateToggle({
    Name = "Enable Invisible",
    CurrentValue = InvisibleConfig.Enabled,
    Flag = "InvisibleEnabled",
    Callback = function(Value)
        InvisibleConfig.Enabled = Value
        if Value then
            enableInvisible()
        else
            disableInvisible()
        end
    end,
})

InvisibleTab:CreateSlider({
    Name = "Fake Self Transparency",
    Range = {0, 0.9},
    Increment = 0.1,
    Suffix = "alpha",
    CurrentValue = InvisibleConfig.FakeSelfTransparency,
    Flag = "FakeTransparency",
    Callback = function(Value)
        InvisibleConfig.FakeSelfTransparency = Value
        if fakeCharacter then
            for _, part in pairs(fakeCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = Value
                end
            end
        end
    end,
})

function enableInvisible()
    if isInvisible then return end
    isInvisible = true
    
    local char = localPlayer.Character
    if not char then return end
    
    realCharacter = char
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    fakeCharacter = Instance.new("Model")
    fakeCharacter.Name = localPlayer.Name .. "_Fake"
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local clone = part:Clone()
            clone.CanCollide = false
            clone.Transparency = InvisibleConfig.FakeSelfTransparency
            clone.Parent = fakeCharacter
            
            if clone.Name ~= "HumanoidRootPart" then
                local weld = Instance.new("Weld")
                weld.Part0 = clone
                weld.Part1 = part
                weld.C0 = part.CFrame:Inverse() * clone.CFrame
                weld.Parent = clone
            end
        end
    end
    
    fakeHumanoid = Instance.new("Humanoid")
    fakeHumanoid.Parent = fakeCharacter
    
    local hrp = char:WaitForChild("HumanoidRootPart")
    local fakeHrp = fakeCharacter:WaitForChild("HumanoidRootPart")
    fakeHrp.CFrame = hrp.CFrame
    
    fakeCharacter.Parent = Workspace
    
    local offset = Vector3.new(0, -500, 0)
    hrp.CFrame = hrp.CFrame + offset
    
    RunService:BindToRenderStep("SyncFakeCharacter", 1, function()
        if not isInvisible or not fakeCharacter or not realCharacter then return end
        
        local realHrp = realCharacter:FindFirstChild("HumanoidRootPart")
        local fakeHrp = fakeCharacter:FindFirstChild("HumanoidRootPart")
        
        if realHrp and fakeHrp then
            fakeHrp.CFrame = realHrp.CFrame + Vector3.new(0, 500, 0)
            fakeHrp.Velocity = realHrp.Velocity
        end
    end)
end

function disableInvisible()
    if not isInvisible then return end
    isInvisible = false
    
    RunService:UnbindFromRenderStep("SyncFakeCharacter")
    
    if realCharacter and fakeCharacter then
        local realHrp = realCharacter:FindFirstChild("HumanoidRootPart")
        local fakeHrp = fakeCharacter:FindFirstChild("HumanoidRootPart")
        
        if realHrp and fakeHrp then
            realHrp.CFrame = fakeHrp.CFrame
        end
    end
    
    if fakeCharacter then
        fakeCharacter:Destroy()
        fakeCharacter = nil
    end
    
    realCharacter = nil
end

-- ==================== MOVEMENT CONFIG ====================
local MovementTab = Window:CreateTab("Movement", 4483362458)

-- ==================== WALKSPEED SECTION ====================
local WalkSpeedSection = MovementTab:CreateSection("WalkSpeed Settings")

local WalkSpeedConfig = {
    Enabled = false,
    Value = 50,
}

-- Toggle WalkSpeed
MovementTab:CreateToggle({
    Name = "Enable Custom WalkSpeed",
    CurrentValue = WalkSpeedConfig.Enabled,
    Flag = "WalkSpeedEnabled",
    Callback = function(Value)
        WalkSpeedConfig.Enabled = Value
        updateWalkSpeed()
    end,
})

-- Slider WalkSpeed
MovementTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = WalkSpeedConfig.Value,
    Flag = "WalkSpeedValue",
    Callback = function(Value)
        WalkSpeedConfig.Value = Value
        if WalkSpeedConfig.Enabled then
            updateWalkSpeed()
        end
    end,
})

function updateWalkSpeed()
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if WalkSpeedConfig.Enabled then
        humanoid.WalkSpeed = WalkSpeedConfig.Value
    else
        humanoid.WalkSpeed = DEFAULT_WALKSPEED
    end
end

-- ==================== JUMPPOWER SECTION ====================
local JumpPowerSection = MovementTab:CreateSection("JumpPower Settings")

local JumpPowerConfig = {
    Enabled = false,
    Value = 100,
}

-- Toggle JumpPower
MovementTab:CreateToggle({
    Name = "Enable Custom JumpPower",
    CurrentValue = JumpPowerConfig.Enabled,
    Flag = "JumpPowerEnabled",
    Callback = function(Value)
        JumpPowerConfig.Enabled = Value
        updateJumpPower()
    end,
})

-- Slider JumpPower
MovementTab:CreateSlider({
    Name = "JumpPower Value",
    Range = {50, 200},
    Increment = 1,
    Suffix = "power",
    CurrentValue = JumpPowerConfig.Value,
    Flag = "JumpPowerValue",
    Callback = function(Value)
        JumpPowerConfig.Value = Value
        if JumpPowerConfig.Enabled then
            updateJumpPower()
        end
    end,
})

function updateJumpPower()
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if JumpPowerConfig.Enabled then
        humanoid.JumpPower = JumpPowerConfig.Value
    else
        humanoid.JumpPower = DEFAULT_JUMPPOWER
    end
end

-- ==================== OTHER MOVEMENT ====================
local OtherSection = MovementTab:CreateSection("Other Movement")

local MovementConfig = {
    InfiniteJump = false,
    NoClip = false,
}

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = MovementConfig.InfiniteJump,
    Flag = "InfiniteJump",
    Callback = function(Value)
        MovementConfig.InfiniteJump = Value
    end,
})

MovementTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = MovementConfig.NoClip,
    Flag = "NoClip",
    Callback = function(Value)
        MovementConfig.NoClip = Value
    end,
})

-- ==================== FREEZE SYSTEM ====================
local FreezeTab = Window:CreateTab("Freeze", 4483362458)
local FreezeSection = FreezeTab:CreateSection("Freeze Settings")

local FreezeConfig = {
    Enabled = false,
    Keybind = Enum.KeyCode.F,
    IsFrozen = false,
}

local freezeUI = nil
local freezeButton = nil
local freezeConnection = nil
local anchorPart = nil

FreezeTab:CreateToggle({
    Name = "Enable Freeze System",
    CurrentValue = FreezeConfig.Enabled,
    Flag = "FreezeSystemEnabled",
    Callback = function(Value)
        FreezeConfig.Enabled = Value
        if Value then
            createFreezeUI()
        else
            destroyFreezeUI()
        end
    end,
})

FreezeTab:CreateKeybind({
    Name = "Freeze Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "FreezeKeybind",
    Callback = function(Keybind)
        FreezeConfig.Keybind = Keybind
    end,
})

FreezeTab:CreateLabel("Press keybind to toggle freeze state")

function createFreezeUI()
    if freezeUI then return end
    
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    
    freezeUI = Instance.new("ScreenGui")
    freezeUI.Name = "FreezeUI"
    freezeUI.Parent = playerGui
    freezeUI.ResetOnSpawn = false
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "FreezeButtonFrame"
    buttonFrame.Size = UDim2.new(0, 120, 0, 50)
    buttonFrame.Position = UDim2.new(0.5, -60, 0.8, 0)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Active = true
    buttonFrame.Draggable = true
    buttonFrame.Parent = freezeUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = buttonFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = buttonFrame
    
    freezeButton = Instance.new("TextButton")
    freezeButton.Name = "FreezeToggleButton"
    freezeButton.Size = UDim2.new(1, 0, 1, 0)
    freezeButton.BackgroundTransparency = 1
    freezeButton.Text = "Freeze: OFF"
    freezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeButton.TextSize = 16
    freezeButton.Font = Enum.Font.GothamBold
    freezeButton.Parent = buttonFrame
    
    FreezeConfig.IsFrozen = false
    
    freezeButton.MouseButton1Click:Connect(function()
        toggleFreeze()
    end)
    
    freezeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == FreezeConfig.Keybind then
            toggleFreeze()
        end
    end)
end

function destroyFreezeUI()
    if freezeUI then
        freezeUI:Destroy()
        freezeUI = nil
        freezeButton = nil
    end
    
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    
    if FreezeConfig.IsFrozen then
        unfreezeCharacter()
    end
end

function toggleFreeze()
    FreezeConfig.IsFrozen = not FreezeConfig.IsFrozen
    
    if FreezeConfig.IsFrozen then
        freezeCharacter()
    else
        unfreezeCharacter()
    end
    
    if freezeButton then
        if FreezeConfig.IsFrozen then
            freezeButton.Text = "Freeze: ON"
            freezeButton.Parent.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        else
            freezeButton.Text = "Freeze: OFF"
            freezeButton.Parent.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
end

function freezeCharacter()
    local char = localPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    anchorPart = Instance.new("Part")
    anchorPart.Name = "FreezeAnchor"
    anchorPart.Size = Vector3.new(1, 1, 1)
    anchorPart.Position = hrp.Position
    anchorPart.Anchored = true
    anchorPart.Transparency = 1
    anchorPart.CanCollide = false
    anchorPart.Parent = Workspace
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = anchorPart
    weld.Parent = hrp
    
    hrp.Velocity = Vector3.zero
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

function unfreezeCharacter()
    if anchorPart then
        anchorPart:Destroy()
        anchorPart = nil
    end
    
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if WalkSpeedConfig.Enabled then
            humanoid.WalkSpeed = WalkSpeedConfig.Value
        else
            humanoid.WalkSpeed = DEFAULT_WALKSPEED
        end
        
        if JumpPowerConfig.Enabled then
            humanoid.JumpPower = JumpPowerConfig.Value
        else
            humanoid.JumpPower = DEFAULT_JUMPPOWER
        end
    end
end

-- ==================== CHARACTER SPAWN HANDLER ====================
localPlayer.CharacterAdded:Connect(function(char)
    -- รอ Humanoid โหลด
    local humanoid = char:WaitForChild("Humanoid")
    
    -- อัปเดตค่าตาม Toggle ที่เปิดอยู่
    if WalkSpeedConfig.Enabled then
        humanoid.WalkSpeed = WalkSpeedConfig.Value
    else
        humanoid.WalkSpeed = DEFAULT_WALKSPEED
    end
    
    if JumpPowerConfig.Enabled then
        humanoid.JumpPower = JumpPowerConfig.Value
    else
        humanoid.JumpPower = DEFAULT_JUMPPOWER
    end
end)

-- ==================== NOCLIP ====================
RunService.Stepped:Connect(function()
    if MovementConfig.NoClip then
        local char = localPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ==================== INFINITE JUMP ====================
UserInputService.JumpRequest:Connect(function()
    if MovementConfig.InfiniteJump then
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ==================== FOV CIRCLE ====================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.5
fovCircle.Filled = false
fovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    if SilentAimConfig.TargetMode == "center" and SilentAimConfig.ShowFOVCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        fovCircle.Radius = SilentAimConfig.FOV
    else
        fovCircle.Visible = false
    end
end)

-- ==================== SILENT AIM LOGIC ====================
local function updateTarget()
    if not SilentAimConfig.Enabled then
        targetPosition = nil
        return
    end
    
    local referencePos
    local maxDist
    
    if SilentAimConfig.TargetMode == "cursor" then
        referencePos = UserInputService:GetMouseLocation()
        maxDist = math.huge
    else
        referencePos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        maxDist = SilentAimConfig.FOV
    end
    
    if not referencePos then return end
    
    local closestPart = nil
    local minScreenDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    if targetPart then
                        local worldDist = (targetPart.Position - camera.CFrame.Position).Magnitude
                        if worldDist <= SilentAimConfig.Distance then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local screenDist = (screenVec - referencePos).Magnitude
                                
                                if SilentAimConfig.TargetMode == "center" and screenDist > SilentAimConfig.FOV then
                                    continue
                                end
                                
                                if screenDist < minScreenDist then
                                    minScreenDist = screenDist
                                    closestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if closestPart then
        targetPosition = closestPart.Position
    else
        targetPosition = nil
    end
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if SilentAimConfig.Enabled and targetPosition and self == Workspace and method == "Raycast" then
        local args = {...}
        if typeof(args[1]) == "Vector3" then
            local origin = args[1]
            local newDir = (targetPosition - origin).Unit * SilentAimConfig.Distance
            args[2] = newDir
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end))

RunService.RenderStepped:Connect(updateTarget)

-- ==================== FLING LOGIC ====================
Workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local partInfo = model:FindFirstChild("GrabPart")
        if not partInfo then return end

        local weld = partInfo:FindFirstChild("WeldConstraint")
        if not weld or not weld.Part1 then return end

        local part = weld.Part1
        local velocity = Instance.new("BodyVelocity")
        velocity.Parent = part

        model:GetPropertyChangedSignal("Parent"):Connect(function()
            if not model.Parent then
                if FlingConfig.Enabled then
                    velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    velocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * FlingConfig.Strength
                else
                    velocity.MaxForce = Vector3.zero
                end
                Debris:AddItem(velocity, 1)
            end
        end)
    end
end)

-- แจ้งเตือนเมื่อโหลดเสร็จ
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "All features loaded successfully!",
    Duration = 3,
})
