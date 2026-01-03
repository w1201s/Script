function load()
print("Plz rate this 0/10")
warn("made by w1201s with heart")    
end
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
--dont change anything until you know what you do
WindUI.Services.junkiedev = {
    Name = "Junkie Development",
    Icon = "bug-off",
    Args = { "ServiceId", "ApiKey", "Provider" },
    New = function(ServiceId, ApiKey, Provider)
        JunkieProtected.API_KEY = ApiKey
        JunkieProtected.PROVIDER = Provider
        JunkieProtected.SERVICE_ID = ServiceId

        local function ValidateKey(key)
            if not key or key == "" then
                print("❌ No key provided!")
                game.Players.LocalPlayer:Kick("No key provided. Please get a key.")
                return false
            end

            local keylessCheck = JunkieProtected.IsKeylessMode()
            if keylessCheck and keylessCheck.keyless_mode then
                print("Keyless mode enabled - Starting script...")
                return true
            end

            local result = JunkieProtected.ValidateKey({ Key = key })
            if result == "valid" then
                print("Key is valid! Starting script...")
                load()
                
                if _G.JD_IsPremium then
                    print("🌟 Premium user detected!")
                else
                    print("📝 Standard user")
                end

        local function copyLink()
            local link = JunkieProtected.GetKeyLink()
            print("Get your key: " .. link)
            if setclipboard then
                setclipboard(link)
            end
        end

        return {
            Verify = ValidateKey,
            Copy = copyLink
        }
    end
}
                
                return true
            else
                local keyLink = JunkieProtected.GetKeyLink()
                print("❌ Invalid key!")
                game.Players.LocalPlayer:Kick("Invalid key. Get one from: " .. keyLink)
                return false
            end
        end

--//CONTIUNE HERE!!

local Window = WindUI:CreateWindow({
    Title = "Venus v0.5(Universal)",
    Icon = "door-open",
    Author = "by w1201s",
    Folder = "Venus",
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
    KeySystem = {                                                               
        Note = "Do the keysystem now Btw i add universal so you can play in different map but now much game support sad",                     
        API = {                                                       
            { 
                Type = "junkiedev",
                ServiceId = "Venus",
                ApiKey = "c64fd71a-d263-4461-8901-712150e4ee81",
                Provider = "Venus",
            }    
        }
    }
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Tab = Window:Tab({
    Title = "Main",
    Icon = "house", 
    Locked = false,
})

local Button = Tab:Button({
    Title = "Please Read This if u want to use universal script",
    Desc = "Read here",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://github.com/w1201s/Script/raw/refs/heads/main/Read%20note.lua"))()
    end
})


local Button = Tab:Button({
    Title = "I Need universal script Please Read",
    Desc = "Here universal script Please read support game",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/w1201s/Script/refs/heads/main/venus%20hub%20universal.lua"))()
    end
})

local Button = Tab:Button({
    Title = "I need aimbot script",
    Desc = "Here",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/w1201s/Script/refs/heads/main/Aimbot'))()
    end
})

local Button = Tab:Button({
    Title = "Infinite yield",
    Desc = "Admin command script work in most game",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

local Button = Tab:Button({
    Title = "Remote spy",
    Desc = "Roblox script remote(OP if u know how to use)",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end
})

local WalkSpeedValue = 16
local JumpPowerValue = 50


local WalkSpeedLooping = false
local JumpPowerLooping = false

Tab:Slider({
    Title = "WalkSpeed",
    Desc = "More speed = faster trust",
    Step = 1,
    Value = {
        Min = 16,
        Max = 500,
        Default = 16,
    },
    Callback = function(value)
        WalkSpeedValue = value
        if WalkSpeedLooping and Humanoid then
            Humanoid.WalkSpeed = WalkSpeedValue
        end
    end
})

Tab:Slider({
    Title = "JumpPower",
    Desc = "Kangaroo",
    Step = 1,
    Value = {
        Min = 50,
        Max = 500,
        Default = 50,
    },
    Callback = function(value)
        JumpPowerValue = value
        if JumpPowerLooping and Humanoid then
            Humanoid.JumpPower = JumpPowerValue
        end
    end
})

Tab:Toggle({
    Title = "WalkSpeed",
    Desc = "Yes",
    Icon = "arrow-up",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        WalkSpeedLooping = state
        if not state and Humanoid then
            Humanoid.WalkSpeed = 16 -- คืนค่า default
        end
    end
})

Tab:Toggle({
    Title = "JumpPower",
    Desc = "Ok",
    Icon = "arrow-up",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        JumpPowerLooping = state
        if not state and Humanoid then
            Humanoid.JumpPower = 50 -- คืนค่า default
        end
    end
})

-- Loop ตรวจสอบตัวละครใหม่ทุกครั้งที่ respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")

    spawn(function()
        while WalkSpeedLooping or JumpPowerLooping do
            if Humanoid then
                if WalkSpeedLooping then Humanoid.WalkSpeed = WalkSpeedValue end
                if JumpPowerLooping then Humanoid.JumpPower = JumpPowerValue end
            end
            task.wait(0.1)
        end
    end)
end)

-- Loop ปรับค่าเรื่อย ๆ ขณะอยู่ในเกม
spawn(function()
    while true do
        if WalkSpeedLooping and Humanoid then Humanoid.WalkSpeed = WalkSpeedValue end
        if JumpPowerLooping and Humanoid then Humanoid.JumpPower = JumpPowerValue end
        task.wait(0.1)
    end
end)
