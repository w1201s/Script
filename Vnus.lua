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

