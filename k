local service = 16008;
local secret = "7693a2f6-72dc-4c53-b421-2676a8e26740";
local useNonce = true;
local onMessage = function(message)  game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", { Text = message; }) end;

repeat task.wait(1) until game:IsLoaded() or game.Players.LocalPlayer;

local requestSending = false;
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = setclipboard or toclipboard, request or http_request, string.char, tostring, string.sub, os.time, math.random, math.floor, gethwid or function() return game:GetService("Players").LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0;
local HttpService = game:GetService("HttpService")

function lEncode(data)
    return HttpService:JSONEncode(data)
end
function lDecode(data)
    return HttpService:JSONDecode(data)
end
local function lDigest(input)
    local inputStr = tostring(input)
    local hash = {}
    for i = 1, #inputStr do
        table.insert(hash, string.byte(inputStr, i))
    end
    local hashHex = ""
    for _, byte in ipairs(hash) do
        hashHex = hashHex .. string.format("%02x", byte)
    end
    return hashHex
end

local host = "https://api.platoboost.com";
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
});
if hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net";
end

function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetHwid())
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        });

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body);
            if decoded.success == true then
                cachedLink = decoded.data.url;
                cachedTime = fOsTime();
                return true, cachedLink;
            else
                onMessage(decoded.message);
                return false, decoded.message;
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again.";
            onMessage(msg);
            return false, msg;
        end

        local msg = "Failed to cache link.";
        onMessage(msg);
        return false, msg;
    else
        return true, cachedLink;
    end
end

cacheLink();

local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

for _ = 1, 5 do
    local oNonce = generateNonce();
    task.wait(0.2)
    if generateNonce() == oNonce then
        local msg = "platoboost nonce error.";
        onMessage(msg);
        error(msg);
    end
end

local copyLink = function()
    local success, link = cacheLink();
    if success then
        fSetClipboard(link);
        onMessage("Link copied to clipboard!");
    end
end

local redeemKey = function(key)
    local nonce = generateNonce();
    local endpoint = host .. "/public/redeem/" .. fToString(service);
    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }
    if useNonce then
        body.nonce = nonce;
    end
    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true;
                    else
                        onMessage("failed to verify integrity.");
                        return false;
                    end    
                else
                    return true;
                end
            else
                onMessage("key is invalid.");
                return false;
            end
        else
            if fStringSub(decoded.message, 1, 27) == "unique constraint violation" then
                onMessage("you already have an active key, please wait for it to expire before redeeming it.");
                return false;
            else
                onMessage(decoded.message);
                return false;
            end
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false; 
    end
end

local verifyKey = function(key)
    if requestSending == true then
        onMessage("a request is already being sent, please slow down.");
        return false;
    else
        requestSending = true;
    end

    local nonce = generateNonce();
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;
    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end
    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    requestSending = false;

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success == true then
            if decoded.data.valid == true then
                return true;
            else
                if fStringSub(key, 1, 5) == "FREE_" then
                    return redeemKey(key);
                else
                    onMessage("key is invalid.");
                    return false;
                end
            end
        else
            onMessage(decoded.message);
            return false;
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false;
    end
end

-- Modern UI with Orange Theme
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    
    -- Color Scheme (Orange Theme)
    local Colors = {
        Background = Color3.fromRGB(25, 25, 30),
        Topbar = Color3.fromRGB(35, 35, 40),
        Primary = Color3.fromRGB(255, 140, 50), -- Orange
        PrimaryHover = Color3.fromRGB(255, 160, 70),
        Secondary = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        InputBg = Color3.fromRGB(40, 40, 45),
        CloseHover = Color3.fromRGB(255, 80, 80),
        Discord = Color3.fromRGB(88, 101, 242)
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModernKeySystem"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame with rounded corners
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    MainFrame.Size = UDim2.new(0, 400, 0, 280)
    MainFrame.ClipsDescendants = true
    
    -- Corner radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = -1
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = MainFrame
    Topbar.BackgroundColor3 = Colors.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 12)
    TopbarCorner.Parent = Topbar
    
    -- Fix topbar corners
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Parent = Topbar
    TopbarFix.BackgroundColor3 = Colors.Topbar
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
    TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = Topbar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "KEY SYSTEM"
    Title.TextColor3 = Colors.Primary
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Parent = Topbar
    CloseBtn.BackgroundColor3 = Colors.Secondary
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -12)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Colors.Text
    CloseBtn.TextSize = 14
    CloseBtn.AutoButtonColor = false
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.Size = UDim2.new(1, 0, 1, -45)
    
    -- Key Input Box
    local InputBox = Instance.new("Frame")
    InputBox.Parent = Content
    InputBox.BackgroundColor3 = Colors.InputBg
    InputBox.BorderSizePixel = 0
    InputBox.Position = UDim2.new(0.5, -170, 0, 25)
    InputBox.Size = UDim2.new(0, 340, 0, 50)
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputBox
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Parent = InputBox
    InputStroke.Color = Colors.Primary
    InputStroke.Thickness = 1.5
    InputStroke.Transparency = 0.7
    
    local TextBox = Instance.new("TextBox")
    TextBox.Parent = InputBox
    TextBox.BackgroundTransparency = 1
    TextBox.Position = UDim2.new(0, 15, 0, 0)
    TextBox.Size = UDim2.new(1, -30, 1, 0)
    TextBox.Font = Enum.Font.GothamSemibold
    TextBox.PlaceholderText = "Enter your key here..."
    TextBox.PlaceholderColor3 = Colors.TextDark
    TextBox.Text = ""
    TextBox.TextColor3 = Colors.Text
    TextBox.TextSize = 14
    TextBox.ClearTextOnFocus = false
    
    -- Button Container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Parent = Content
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(0.5, -170, 0, 95)
    ButtonContainer.Size = UDim2.new(0, 340, 0, 45)
    
    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.Parent = ButtonContainer
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 12)
    
    -- Get Key Button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKey"
    GetKeyBtn.Parent = ButtonContainer
    GetKeyBtn.BackgroundColor3 = Colors.Secondary
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Size = UDim2.new(0, 160, 0, 40)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Text = "GET KEY"
    GetKeyBtn.TextColor3 = Colors.Text
    GetKeyBtn.TextSize = 14
    GetKeyBtn.AutoButtonColor = false
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn
    
    -- Enter Key Button (Submit)
    local EnterKeyBtn = Instance.new("TextButton")
    EnterKeyBtn.Name = "EnterKey"
    EnterKeyBtn.Parent = ButtonContainer
    EnterKeyBtn.BackgroundColor3 = Colors.Primary
    EnterKeyBtn.BorderSizePixel = 0
    EnterKeyBtn.Size = UDim2.new(0, 160, 0, 40)
    EnterKeyBtn.Font = Enum.Font.GothamBold
    EnterKeyBtn.Text = "SUBMIT"
    EnterKeyBtn.TextColor3 = Colors.Text
    EnterKeyBtn.TextSize = 14
    EnterKeyBtn.AutoButtonColor = false
    
    local EnterKeyCorner = Instance.new("UICorner")
    EnterKeyCorner.CornerRadius = UDim.new(0, 8)
    EnterKeyCorner.Parent = EnterKeyBtn
    
    -- Discord Button (Bottom)
    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Name = "Discord"
    DiscordBtn.Parent = Content
    DiscordBtn.BackgroundColor3 = Colors.Discord
    DiscordBtn.BorderSizePixel = 0
    DiscordBtn.Position = UDim2.new(0.5, -100, 0, 160)
    DiscordBtn.Size = UDim2.new(0, 200, 0, 40)
    DiscordBtn.Font = Enum.Font.GothamBold
    DiscordBtn.Text = "JOIN DISCORD"
    DiscordBtn.TextColor3 = Colors.Text
    DiscordBtn.TextSize = 14
    DiscordBtn.AutoButtonColor = false
    
    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 8)
    DiscordCorner.Parent = DiscordBtn
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = Content
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0, 215)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Colors.Primary
    StatusLabel.TextSize = 12
    
    -- Animation Functions
    local function Tween(object, properties, duration)
        local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
        tween:Play()
        return tween
    end
    
    local function ButtonHover(btn, originalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
            Tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 4)}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = originalColor}, 0.2)
            Tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 4, btn.Size.Y.Scale, btn.Size.Y.Offset - 4)}, 0.2)
        end)
    end
    
    -- Apply hover effects
    ButtonHover(GetKeyBtn, Colors.Secondary, Color3.fromRGB(55, 55, 60))
    ButtonHover(EnterKeyBtn, Colors.Primary, Colors.PrimaryHover)
    ButtonHover(DiscordBtn, Colors.Discord, Color3.fromRGB(110, 125, 255))
    
    -- Close button hover
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Colors.CloseHover}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Colors.Secondary}, 0.2)
    end)
    
    -- Input focus effects
    TextBox.Focused:Connect(function()
        Tween(InputStroke, {Transparency = 0}, 0.2)
    end)
    TextBox.FocusLost:Connect(function()
        Tween(InputStroke, {Transparency = 0.7}, 0.2)
    end)
    
    -- Draggable functionality
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
    end
    
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Intro Animation
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 400, 0, 0)
    MainFrame.BackgroundTransparency = 1
    
    Tween(MainFrame, {Size = UDim2.new(0, 400, 0, 280), BackgroundTransparency = 0}, 0.5)
    task.wait(0.1)
    
    -- Close function
    local function CloseUI()
        Tween(MainFrame, {Size = UDim2.new(0, 400, 0, 0), BackgroundTransparency = 1}, 0.4)
        task.wait(0.4)
        ScreenGui:Destroy()
    end
    
    -- Button Functions
    CloseBtn.MouseButton1Click:Connect(CloseUI)
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        -- Click animation
        Tween(GetKeyBtn, {Size = UDim2.new(0, 156, 0, 36)}, 0.1)
        task.wait(0.1)
        Tween(GetKeyBtn, {Size = UDim2.new(0, 160, 0, 40)}, 0.1)
        copyLink()
        StatusLabel.Text = "Link copied to clipboard!"
        task.wait(2)
        StatusLabel.Text = ""
    end)
    
    EnterKeyBtn.MouseButton1Click:Connect(function()
        -- Click animation
        Tween(EnterKeyBtn, {Size = UDim2.new(0, 156, 0, 36)}, 0.1)
        task.wait(0.1)
        Tween(EnterKeyBtn, {Size = UDim2.new(0, 160, 0, 40)}, 0.1)
        
        local key = TextBox.Text
        if key and key ~= "" then
            StatusLabel.Text = "Verifying..."
            local success = verifyKey(key)
            if success then
                StatusLabel.Text = "Success! Loading..."
                Tween(MainFrame, {Size = UDim2.new(0, 400, 0, 0), BackgroundTransparency = 1}, 0.5)
                task.wait(0.5)
                ScreenGui:Destroy()
                loadstring(game:HttpGet("https://pastebin.com/raw/DTrES0c6"))()
            else
                StatusLabel.Text = "Invalid key!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                task.wait(0.5)
                StatusLabel.TextColor3 = Colors.Primary
                task.wait(1.5)
                StatusLabel.Text = ""
            end
        else
            StatusLabel.Text = "Please enter a key!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            task.wait(1.5)
            StatusLabel.TextColor3 = Colors.Primary
            StatusLabel.Text = ""
        end
    end)
    
    DiscordBtn.MouseButton1Click:Connect(function()
        Tween(DiscordBtn, {Size = UDim2.new(0, 196, 0, 36)}, 0.1)
        task.wait(0.1)
        Tween(DiscordBtn, {Size = UDim2.new(0, 200, 0, 40)}, 0.1)
        -- Replace with your Discord invite
        fSetClipboard("https://discord.gg/yourinvite")
        StatusLabel.Text = "Discord link copied!"
        task.wait(2)
        StatusLabel.Text = ""
    end)
end)
