--// =====================================================
--// SERVICES
--// =====================================================
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Events = Rep:WaitForChild("Events")

--// =====================================================
--// SAFE CHARACTER
--// =====================================================
local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHumanoid()
    return GetChar():WaitForChild("Humanoid")
end

local function GetHRP()
    return GetChar():WaitForChild("HumanoidRootPart")
end

--// =====================================================
--// CFRAMES
--// =====================================================
local MID_CFRAME   = CFrame.new(-76, 23, 14)
local SPAWN_CFRAME = CFrame.new(-76, 23, 14)
local END_CFRAME   = CFrame.new(5, 56, -1047)

--// =====================================================
--// STATES
--// =====================================================
local Toggles = {
    AutoSpeed = false,
    AutoCarry = false,
    AutoPlace = false,
    AutoSell = false,
    AutoCollectMoney = false,
    AutoCollectPresent = false,
    AutoRebirth = false
}

local PlayerState = {
    EnableWS = false,
    WalkSpeed = 16,
    EnableJP = false,
    JumpPower = 50,
    InfJump = false,
    InstantPrompt = false
}

local Collecting = false
local SelectedPlatform = "Platform1"
local LuckyMode = "Epic Block"
local BlacklistPresent = {}

--// =====================================================
--// LISTS
--// =====================================================
local Platforms = {}
for i = 1,100 do Platforms[#Platforms+1] = "Platform"..i end

local LuckyList = { "Epic Block", "Legendary Block", "Both" }

local PresentPriority = {
    "RainbowPresent",
    "SecretPresent",
    "MythicPresent",
    "LegendaryPresent",
    "EpicPresent",
    "LavaPresent",
    "GoldPersent",
    "RarePresent",
    "BasicPresent"
}

--// =====================================================
--// WIND UI
--// =====================================================
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "Venus X",
    Icon = "zap", -- lucide icon
    Author = "by w1201s W retired",
    Folder = "retired w",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
 
    --       remove this all, 
    -- !  ↓  if you DON'T need the key system
    KeySystem = { 
        -- ↓ Optional. You can remove it.
        Key = { "Venus", "67 boi" },
        
        Note = "join our discord for key link is press get key.",
        
        -- ↓ Optional. You can remove it.
        URL = "https://discord.com/invite/4DzKBt62YB",
        
        -- ↓ Optional. You can remove it.
        SaveKey = false, -- automatically save and load the key.
    },
})
local TabMain   = Window:Tab({ Title = "Main",   Icon = "home" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabBuy    = Window:Tab({ Title = "Auto Buy", Icon = "shopping-cart" })
local TabExtra  = Window:Tab({ Title = "Extra",  Icon = "plus" })

--// =====================================================
--// MAIN TAB
--// =====================================================
TabMain:Toggle({
    Title = "Auto Present",
    Value = false,
    Callback = function(v)
        Toggles.AutoCollectPresent = v
    end
})

TabMain:Dropdown({
    Title = "Blacklist Present",
    Values = PresentPriority,
    Multi = true,
    AllowNone = true,
    Callback = function(list)
        BlacklistPresent = {}
        for _,v in ipairs(list) do
            BlacklistPresent[v] = true
        end
    end
})

TabMain:Toggle({
    Title = "Auto Collect Money",
    Value = false,
    Callback = function(v)
        Toggles.AutoCollectMoney = v
    end
})

TabMain:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(v)
        Toggles.AutoRebirth = v
    end
})

--// =====================================================
--// PLAYER TAB
--// =====================================================
TabPlayer:Toggle({
    Title = "Speed hax",
    Value = false,
    Callback = function(v)
        PlayerState.EnableWS = v
    end
})

TabPlayer:Slider({
    Title = "WalkSpeed hax",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(v)
        PlayerState.WalkSpeed = v
    end
})

TabPlayer:Toggle({
    Title = "kangaroo power hax",
    Value = false,
    Callback = function(v)
        PlayerState.EnableJP = v
    end
})

TabPlayer:Slider({
    Title = "JumpPower hax",
    Step = 1,
    Value = { Min = 50, Max = 200, Default = 50 },
    Callback = function(v)
        PlayerState.JumpPower = v
    end
})

TabPlayer:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v)
        PlayerState.InfJump = v
    end
})

TabPlayer:Toggle({
    Title = "Instant Proximity Prompt",
    Desc = "no hold ez",
    Value = false,
    Callback = function(v)
        PlayerState.InstantPrompt = v
    end
})

TabPlayer:Button({
    Title = "TP Back To Spawn",
    Callback = function()
        GetHRP().CFrame = SPAWN_CFRAME
    end
})

TabPlayer:Button({
    Title = "TP To End",
    Callback = function()
        GetHRP().CFrame = END_CFRAME
    end
})

--// =====================================================
--// AUTO BUY TAB
--// =====================================================
TabBuy:Toggle({
    Title = "Auto Buy Speed",
    Value = false,
    Callback = function(v)
        Toggles.AutoSpeed = v
    end
})

TabBuy:Toggle({
    Title = "Auto Buy Carry",
    Value = false,
    Callback = function(v)
        Toggles.AutoCarry = v
    end
})

--// =====================================================
--// EXTRA TAB
--// =====================================================
TabExtra:Toggle({
    Title = "Auto Place Lucky Block",
    Value = false,
    Callback = function(v)
        Toggles.AutoPlace = v
    end
})

TabExtra:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(v)
        Toggles.AutoSell = v
    end
})

TabExtra:Dropdown({
    Title = "Lucky Block Mode",
    Values = LuckyList,
    Value = "Epic Block",
    Callback = function(v)
        LuckyMode = v
    end
})

TabExtra:Dropdown({
    Title = "Platform",
    Values = Platforms,
    Value = "Platform1",
    Callback = function(v)
        SelectedPlatform = v
    end
})

--// =====================================================
--// LOGIC
--// =====================================================
local switch = false
local function GetLucky()
    if LuckyMode == "Both" then
        switch = not switch
        return switch and "Epic Block" or "Legendary Block"
    end
    return LuckyMode
end

local function EquipLucky(name)
    local tool = LP.Backpack:FindFirstChild(name)
    if tool then
        GetHumanoid():EquipTool(tool)
        return true
    end
end

local function FindBestPresent()
    for _,name in ipairs(PresentPriority) do
        if not BlacklistPresent[name] then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == name then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        return obj, prompt
                    end
                end
            end
        end
    end
end

--// =====================================================
--// MAIN LOOP
--// =====================================================
task.spawn(function()
    while task.wait(0.1) do
        local hum = GetHumanoid()

        if PlayerState.EnableWS then
            hum.WalkSpeed = PlayerState.WalkSpeed
        end

        if PlayerState.EnableJP then
            hum.JumpPower = PlayerState.JumpPower
        end

        if Toggles.AutoSpeed then
            Events.SpeedEvent:FireServer("Speed10")
        end

        if Toggles.AutoCarry then
            Events.CarryEvent:FireServer()
        end

        if Toggles.AutoPlace then
            if EquipLucky(GetLucky()) then
                Events.PlaceBrainrot:FireServer(SelectedPlatform, "Block")
            end
        end

        if Toggles.AutoSell then
            Events.Sell:FireServer(SelectedPlatform)
        end

        if Toggles.AutoCollectMoney then
            for i = 1,100 do
                Events.Collect:FireServer("Platform"..i)
            end
        end

        if Toggles.AutoRebirth then
            Events.Rebirth:FireServer()
        end
    end
end)

--// =====================================================
--// PRESENT LOOP
--// =====================================================
task.spawn(function()
    while task.wait(0.15) do
        if Toggles.AutoCollectPresent and not Collecting then
            Collecting = true

            local hrp = GetHRP()
            local present, prompt = FindBestPresent()

            if present and prompt then
                hrp.CFrame = present:GetPivot()
                task.wait(0.05)
                fireproximityprompt(prompt)
                task.wait(0.05)
                hrp.CFrame = MID_CFRAME
            end

            Collecting = false
        end
    end
end)

--// =====================================================
--// INFINITE JUMP
--// =====================================================
UIS.JumpRequest:Connect(function()
    if PlayerState.InfJump then
        GetHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// =====================================================
--// INSTANT PROMPT SYSTEM
--// =====================================================
local PromptCache = {}

task.spawn(function()
    while task.wait(0.3) do
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if PromptCache[obj] == nil then
                    PromptCache[obj] = obj.HoldDuration
                end

                if PlayerState.InstantPrompt then
                    obj.HoldDuration = 0
                else
                    obj.HoldDuration = PromptCache[obj]
                end
            end
        end
    end
end)
