-- Modern Black/White Key System UI for Roblox
-- Created based on user specifications

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CORRECT_KEY = "Venusf"
local DISCORD_LINK = "https://discord.gg/4DzKBt62YB"
local SCRIPT_URL = "https://raw.githubusercontent.com/w1201s/Script/refs/heads/main/ftop.lua"

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernKeySystem"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "KeyFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Fix bottom corners of title bar
local titleBottomFix = Instance.new("Frame")
titleBottomFix.Name = "BottomFix"
titleBottomFix.Size = UDim2.new(1, 0, 0.5, 0)
titleBottomFix.Position = UDim2.new(0, 0, 0.5, 0)
titleBottomFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBottomFix.BorderSizePixel = 0
titleBottomFix.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "Title"
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0, 20, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "KEY SYSTEM"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Cool X Button (First)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -46, 0.5, -18)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(20, 20, 20)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Close button hover effects
closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        TextColor3 = Color3.fromRGB(20, 20, 20)
    }):Play()
end)

closeButton.MouseButton1Click:Connect(function()
    -- Close animation
    local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Wait()
    screenGui:Destroy()
end)

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -40, 1, -70)
contentFrame.Position = UDim2.new(0, 20, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Text Box (Second)
local textBoxFrame = Instance.new("Frame")
textBoxFrame.Name = "TextBoxFrame"
textBoxFrame.Size = UDim2.new(1, 0, 0, 45)
textBoxFrame.Position = UDim2.new(0, 0, 0, 0)
textBoxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBoxFrame.BorderSizePixel = 0
textBoxFrame.Parent = contentFrame

local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 8)
textBoxCorner.Parent = textBoxFrame

local textBox = Instance.new("TextBox")
textBox.Name = "KeyInput"
textBox.Size = UDim2.new(1, -20, 1, -10)
textBox.Position = UDim2.new(0, 10, 0, 5)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.PlaceholderText = "Enter Key Here..."
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBox.TextSize = 14
textBox.Font = Enum.Font.Gotham
textBox.ClearTextOnFocus = false
textBox.Parent = textBoxFrame

-- Get Key Button (Third) - Discord
local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"
getKeyButton.Size = UDim2.new(1, 0, 0, 45)
getKeyButton.Position = UDim2.new(0, 0, 0, 60)
getKeyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
getKeyButton.Text = "GET KEY (DISCORD)"
getKeyButton.TextColor3 = Color3.fromRGB(20, 20, 20)
getKeyButton.TextSize = 14
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.Parent = contentFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 8)
getKeyCorner.Parent = getKeyButton

-- Get Key hover effects
getKeyButton.MouseEnter:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    }):Play()
end)

getKeyButton.MouseLeave:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

getKeyButton.MouseButton1Click:Connect(function()
    -- Copy Discord link to clipboard
    if setclipboard then
        setclipboard(DISCORD_LINK)
        getKeyButton.Text = "LINK COPIED!"
        wait(1.5)
        getKeyButton.Text = "GET KEY (DISCORD)"
    end
end)

-- Submit Button
local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(1, 0, 0, 45)
submitButton.Position = UDim2.new(0, 0, 0, 115)
submitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
submitButton.Text = "SUBMIT KEY"
submitButton.TextColor3 = Color3.fromRGB(20, 20, 20)
submitButton.TextSize = 14
submitButton.Font = Enum.Font.GothamBold
submitButton.Parent = contentFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 8)
submitCorner.Parent = submitButton

-- Submit hover effects
submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    }):Play()
end)

submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

-- Note Label (Last)
local noteLabel = Instance.new("TextLabel")
noteLabel.Name = "Note"
noteLabel.Size = UDim2.new(1, 0, 0, 40)
noteLabel.Position = UDim2.new(0, 0, 1, -40)
noteLabel.BackgroundTransparency = 1
noteLabel.Text = "Key in discord: Venusf"
noteLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
noteLabel.TextSize = 12
noteLabel.Font = Enum.Font.Gotham
noteLabel.TextWrapped = true
noteLabel.Parent = contentFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 165)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = contentFrame

-- Key validation function
local function validateKey()
    local enteredKey = textBox.Text:gsub("%s+", "") -- Remove spaces
    
    if enteredKey == "" then
        statusLabel.Text = "Please enter a key!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    if enteredKey == CORRECT_KEY then
        -- Success!
        statusLabel.Text = "Key Valid! Loading script..."
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        
        -- Success animation
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(30, 50, 30)
        }):Play()
        
        wait(0.5)
        
        -- Destroy UI
        screenGui:Destroy()
        
        -- Load script
        loadstring(game:HttpGet(SCRIPT_URL))()
    else
        -- Invalid key
        statusLabel.Text = "Invalid Key!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        -- Shake animation
        local originalPos = mainFrame.Position
        for i = 1, 5 do
            mainFrame.Position = originalPos + UDim2.new(0, math.random(-10, 10), 0, 0)
            wait(0.03)
        end
        mainFrame.Position = originalPos
    end
end

submitButton.MouseButton1Click:Connect(validateKey)
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateKey()
    end
end)

-- Intro animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 400, 0, 300),
    Position = UDim2.new(0.5, -200, 0.5, -150)
}):Play()

print("Modern Key System UI Loaded!")
