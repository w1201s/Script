
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- สร้างหน้าต่าง
local Window = Rayfield:CreateWindow({
    Name = "Ftap by venus",
    LoadingTitle = "Tuff venus",
    LoadingSubtitle = "by w1201s",
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
    FOV = 100, -- FOV สำหรับ Center Mode
    ShowFOVCircle = true,
}

local targetPosition = nil

-- Toggle Silent Aim
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

-- Slider Distance
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

-- Dropdown Target Mode
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

-- Slider FOV (สำหรับ Center Mode)
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

-- Toggle Show FOV Circle
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

-- ฟังก์ชัน Invisible
function enableInvisible()
    if isInvisible then return end
    isInvisible = true
    
    local char = localPlayer.Character
    if not char then return end
    
    realCharacter = char
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- สร้าง Fake Character
    fakeCharacter = Instance.new("Model")
    fakeCharacter.Name = localPlayer.Name .. "_Fake"
    
    -- คัดลอกทุกส่วนของตัวละคร
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local clone = part:Clone()
            clone.CanCollide = false
            clone.Transparency = InvisibleConfig.FakeSelfTransparency
            clone.Parent = fakeCharacter
            
            -- Weld กับ HumanoidRootPart ของ fake
            if clone.Name ~= "HumanoidRootPart" then
                local weld = Instance.new("Weld")
                weld.Part0 = clone
                weld.Part1 = part
                weld.C0 = part.CFrame:Inverse() * clone.CFrame
                weld.Parent = clone
            end
        end
    end
    
    -- สร้าง Humanoid ปลอม
    fakeHumanoid = Instance.new("Humanoid")
    fakeHumanoid.Parent = fakeCharacter
    
    -- ตั้งตำแหน่ง Fake Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local fakeHrp = fakeCharacter:WaitForChild("HumanoidRootPart")
    fakeHrp.CFrame = hrp.CFrame
    
    fakeCharacter.Parent = Workspace
    
    -- ย้ายตัวจริงลงใต้ดิน
    local offset = Vector3.new(0, -500, 0)
    hrp.CFrame = hrp.CFrame + offset
    
    -- ซิงค์การเคลื่อนไหว
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
    
    -- ย้ายตัวจริงกลับขึ้นมา
    if realCharacter and fakeCharacter then
        local realHrp = realCharacter:FindFirstChild("HumanoidRootPart")
        local fakeHrp = fakeCharacter:FindFirstChild("HumanoidRootPart")
        
        if realHrp and fakeHrp then
            realHrp.CFrame = fakeHrp.CFrame
        end
    end
    
    -- ลบ Fake Character
    if fakeCharacter then
        fakeCharacter:Destroy()
        fakeCharacter = nil
    end
    
    realCharacter = nil
end

-- ==================== MOVEMENT CONFIG ====================
local MovementTab = Window:CreateTab("Movement", 4483362458)
local MovementSection = MovementTab:CreateSection("Movement Settings")

local MovementConfig = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
}

-- WalkSpeed
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = MovementConfig.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(Value)
        MovementConfig.WalkSpeed = Value
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end,
})

-- JumpPower
MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "power",
    CurrentValue = MovementConfig.JumpPower,
    Flag = "JumpPower",
    Callback = function(Value)
        MovementConfig.JumpPower = Value
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end,
})

-- Infinite Jump
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = MovementConfig.InfiniteJump,
    Flag = "InfiniteJump",
    Callback = function(Value)
        MovementConfig.InfiniteJump = Value
    end,
})

-- Fly
MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = MovementConfig.Fly,
    Flag = "FlyEnabled",
    Callback = function(Value)
        MovementConfig.Fly = Value
        if Value then
            enableFly()
        else
            disableFly()
        end
    end,
})

-- Fly Speed
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = MovementConfig.FlySpeed,
    Flag = "FlySpeed",
    Callback = function(Value)
        MovementConfig.FlySpeed = Value
    end,
})

-- NoClip
MovementTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = MovementConfig.NoClip,
    Flag = "NoClip",
    Callback = function(Value)
        MovementConfig.NoClip = Value
    end,
})

-- ==================== FLY SYSTEM ====================
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil

function enableFly()
    local char = localPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.P = 1e4
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not MovementConfig.Fly then return end
        
        local direction = Vector3.zero
        
        -- PC Controls (WASD/Space/Q)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        -- Mobile Controls (Touch)
        local touch = UserInputService:GetTouchEnabled()
        if touch then
            -- สร้าง Mobile Fly UI ถ้ายังไม่มี
            createMobileFlyUI()
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * MovementConfig.FlySpeed
        end
        
        if flyBodyVelocity then
            flyBodyVelocity.Velocity = direction
        end
        if flyBodyGyro then
            flyBodyGyro.CFrame = camera.CFrame
        end
    end)
end

function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    removeMobileFlyUI()
end

-- Mobile Fly UI
local mobileFlyFrame = nil

function createMobileFlyUI()
    if mobileFlyFrame then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlyMobileUI"
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    mobileFlyFrame = Instance.new("Frame")
    mobileFlyFrame.Size = UDim2.new(0, 200, 0, 200)
    mobileFlyFrame.Position = UDim2.new(1, -220, 1, -220)
    mobileFlyFrame.BackgroundTransparency = 0.5
    mobileFlyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mobileFlyFrame.Parent = screenGui
    
    local upButton = Instance.new("TextButton")
    upButton.Size = UDim2.new(0.3, 0, 0.3, 0)
    upButton.Position = UDim2.new(0.35, 0, 0, 0)
    upButton.Text = "↑"
    upButton.Parent = mobileFlyFrame
    
    local downButton = Instance.new("TextButton")
    downButton.Size = UDim2.new(0.3, 0, 0.3, 0)
    downButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    downButton.Text = "↓"
    downButton.Parent = mobileFlyFrame
    
    local leftButton = Instance.new("TextButton")
    leftButton.Size = UDim2.new(0.3, 0, 0.3, 0)
    leftButton.Position = UDim2.new(0, 0, 0.35, 0)
    leftButton.Text = "←"
    leftButton.Parent = mobileFlyFrame
    
    local rightButton = Instance.new("TextButton")
    rightButton.Size = UDim2.new(0.3, 0, 0.3, 0)
    rightButton.Position = UDim2.new(0.7, 0, 0.35, 0)
    rightButton.Text = "→"
    rightButton.Parent = mobileFlyFrame
    
    -- Touch handlers
    local flyDirection = Vector3.zero
    
    upButton.InputBegan:Connect(function()
        flyDirection = Vector3.new(0, 1, 0) * MovementConfig.FlySpeed
    end)
    upButton.InputEnded:Connect(function()
        flyDirection = Vector3.zero
    end)
    
    downButton.InputBegan:Connect(function()
        flyDirection = Vector3.new(0, -1, 0) * MovementConfig.FlySpeed
    end)
    downButton.InputEnded:Connect(function()
        flyDirection = Vector3.zero
    end)
end

function removeMobileFlyUI()
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local flyUI = playerGui:FindFirstChild("FlyMobileUI")
        if flyUI then
            flyUI:Destroy()
        end
    end
    mobileFlyFrame = nil
end

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
        maxDist = SilentAimConfig.FOV -- ใช้ FOV เป็นระยะจำกัด
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
                                
                                -- เช็คว่าอยู่ใน FOV หรือไม่ (สำหรับ Center Mode)
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
