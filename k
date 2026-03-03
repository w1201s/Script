
# Creating a simplified Venus X Key System with Venus planet colors (orange/yellow/cream)
# Removing extra features, keeping only essentials

simplified_venus_ui = '''-------------------------------------------------------------------------------
--! VENUS X KEY SYSTEM - SIMPLIFIED (VENUS PLANET EDITION)
--! Orange/Yellow theme inspired by Venus
-------------------------------------------------------------------------------

--! Paste your Platoboost API here

-------------------------------------------------------------------------------
--! CONFIGURATION
-------------------------------------------------------------------------------

local Config = {
    DiscordInvite = "https://discord.gg/yourserver",
    Colors = {
        Background = Color3.fromRGB(45, 25, 15),      -- Dark brown
        Primary = Color3.fromRGB(255, 140, 50),       -- Venus Orange
        Secondary = Color3.fromRGB(255, 200, 80),     -- Yellow
        Accent = Color3.fromRGB(255, 235, 180),       -- Cream
        Discord = Color3.fromRGB(88, 101, 242)
    }
}

-------------------------------------------------------------------------------
--! UI CREATION
-------------------------------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove existing
if PlayerGui:FindFirstChild("VenusX") then
    PlayerGui.VenusX:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VenusX"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Config.Colors.Background
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -200, 0.5, -180)
Main.Size = UDim2.new(0, 400, 0, 360)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

-- Orange Glow Border
local Glow = Instance.new("UIStroke", Main)
Glow.Color = Config.Colors.Primary
Glow.Thickness = 3
Glow.Transparency = 0.3

-- Title: VENUS
local Title = Instance.new("TextLabel", Main)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 25)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBlack
Title.Text = "VENUS"
Title.TextColor3 = Config.Colors.Primary
Title.TextSize = 48

-- Subtitle
local Sub = Instance.new("TextLabel", Main)
Sub.BackgroundTransparency = 1
Sub.Position = UDim2.new(0, 0, 0, 70)
Sub.Size = UDim2.new(1, 0, 0, 20)
Sub.Font = Enum.Font.Gotham
Sub.Text = "KEY SYSTEM"
Sub.TextColor3 = Config.Colors.Accent
Sub.TextSize = 14
Sub.TextTransparency = 0.5

-- Key Input
local Input = Instance.new("TextBox", Main)
Input.BackgroundColor3 = Color3.fromRGB(30, 15, 10)
Input.Position = UDim2.new(0.5, -160, 0, 110)
Input.Size = UDim2.new(0, 320, 0, 45)
Input.Font = Enum.Font.GothamSemibold
Input.PlaceholderText = "Enter key..."
Input.Text = ""
Input.TextColor3 = Config.Colors.Accent
Input.TextSize = 15

Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 10)

local InputStroke = Instance.new("UIStroke", Input)
InputStroke.Color = Config.Colors.Primary
InputStroke.Thickness = 1

-- Get Key Button
local GetKey = Instance.new("TextButton", Main)
GetKey.BackgroundColor3 = Config.Colors.Primary
GetKey.Position = UDim2.new(0.05, 0, 0, 170)
GetKey.Size = UDim2.new(0.425, 0, 0, 45)
GetKey.Font = Enum.Font.GothamBold
GetKey.Text = "GET KEY"
GetKey.TextColor3 = Color3.fromRGB(0, 0, 0)
GetKey.TextSize = 14

Instance.new("UICorner", GetKey).CornerRadius = UDim.new(0, 10)

-- Enter Key Button
local EnterKey = Instance.new("TextButton", Main)
EnterKey.BackgroundColor3 = Config.Colors.Secondary
EnterKey.Position = UDim2.new(0.525, 0, 0, 170)
EnterKey.Size = UDim2.new(0.425, 0, 0, 45)
EnterKey.Font = Enum.Font.GothamBold
EnterKey.Text = "ENTER KEY"
EnterKey.TextColor3 = Color3.fromRGB(0, 0, 0)
EnterKey.TextSize = 14

Instance.new("UICorner", EnterKey).CornerRadius = UDim.new(0, 10)

-- Discord Button (Centered below)
local Discord = Instance.new("TextButton", Main)
Discord.BackgroundColor3 = Config.Colors.Discord
Discord.Position = UDim2.new(0.5, -80, 0, 230)
Discord.Size = UDim2.new(0, 160, 0, 40)
Discord.Font = Enum.Font.GothamBold
Discord.Text = "DISCORD"
Discord.TextColor3 = Color3.fromRGB(255, 255, 255)
Discord.TextSize = 13

Instance.new("UICorner", Discord).CornerRadius = UDim.new(0, 10)

-- Status Text
local Status = Instance.new("TextLabel", Main)
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 20, 0, 290)
Status.Size = UDim2.new(1, -40, 0, 50)
Status.Font = Enum.Font.GothamSemibold
Status.Text = ""
Status.TextColor3 = Config.Colors.Accent
Status.TextSize = 13
Status.TextWrapped = true

-------------------------------------------------------------------------------
--! FUNCTIONALITY
-------------------------------------------------------------------------------

local function ShowStatus(text, isError)
    Status.Text = text
    Status.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or Config.Colors.Accent
    
    delay(4, function()
        if Status.Parent then
            Status.Text = ""
        end
    end)
end

-- Button Effects
local function HoverEffect(btn, originalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

HoverEffect(GetKey, Config.Colors.Primary, Color3.fromRGB(255, 170, 80))
HoverEffect(EnterKey, Config.Colors.Secondary, Color3.fromRGB(255, 220, 120))
HoverEffect(Discord, Config.Colors.Discord, Color3.fromRGB(110, 125, 255))

-- Get Key
GetKey.MouseButton1Click:Connect(function()
    GetKey.Text = "..."
    local success = copyLink()
    GetKey.Text = "GET KEY"
    ShowStatus(success and "Link copied!" or "Failed", not success)
end)

-- Enter Key
EnterKey.MouseButton1Click:Connect(function()
    local key = Input.Text:gsub("%s+", "")
    if key == "" then
        ShowStatus("Enter a key!", true)
        return
    end
    
    EnterKey.Text = "..."
    local valid = verifyKey(key)
    EnterKey.Text = "ENTER KEY"
    
    if valid then
        ShowStatus("Success! Loading...")
        wait(1)
        ScreenGui:Destroy()
        -- Load main script here
    else
        ShowStatus("Invalid key!", true)
    end
end)

-- Discord
Discord.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.DiscordInvite)
        ShowStatus("Discord copied!")
    end
end)

-- Enter key support
Input.FocusLost:Connect(function(enter)
    if enter then EnterKey.MouseButton1Click:Fire() end
end)

print("[VENUS] Loaded")
'''

print("=" * 60)
print("🪐 VENUS X - SIMPLIFIED (ORANGE EDITION)")
print("=" * 60)
print("\n🎨 VENUS COLORS:")
print("-" * 60)
print("• Background: Dark Brown (RGB: 45, 25, 15)")
print("• Primary: Venus Orange (RGB: 255, 140, 50)")
print("• Secondary: Yellow (RGB: 255, 200, 80)")
print("• Accent: Cream (RGB: 255, 235, 180)")
print("\n🗑️ REMOVED FEATURES:")
print("-" * 60)
print("• Complex gradient animations")
print("• Particle effects")
print("• Rotating borders")
print("• Detailed status box styling")
print("• Emoji icons")
print("• Footer text")
print("• Elaborate intro animation")
print("\n✅ KEPT FEATURES:")
print("-" * 60)
print("• Clean orange Venus theme")
print("• 3 buttons (Get Key, Enter Key, Discord)")
print("• Key input textbox")
print("• Simple status messages")
print("• Button hover effects")
print("• Enter key support")
print("=" * 60)
