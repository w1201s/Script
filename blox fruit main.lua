local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "My Super Hub",
    Icon = "door-open", -- lucide icon. optional
    Author = "by .ftgs and .ftgs", -- optional
})

local AFKOptions = {}

local Discord = Window:MakeTab({"Discord", "Info"})
Discord:AddDiscordInvite({
    Name = "redz Hub | Community",
    Description = "Join our discord community to receive information about the next update",
    Logo = "rbxassetid://15298567397",
    Invite = "https://discord.gg/7aR7kNVt4g"
})

local Tab = Window:Tab({
    Title = "Tab Title",
    Icon = "bird", -- optional
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "Toggledasd",
    Desc = "Toggle Description",
    Icon = "bird",
    Type = "Checkbox",
    Callback = function(Value)
        getgenv().AutoFarm_Level = Value
        if Value then AutoFarm_Level() end
    end,
})

local Dropdown = Tab:Dropdown({
    Title = "Farm Tool",
    Desc = "Dropdown Description",
    Values = { "Melee", "Sword", "Blox Fruit" },
    Value = "Melee",
    Callback = function(Value) 
        getgenv().FarmTool = Value
    end
})



if Sea3 then
    local AutoSea = Window:MakeTab({"Sea", "Waves"})
    AutoSea:AddSection({"Kitsune"})
    local KILabel = AutoSea:AddParagraph({"Kitsune Island : not spawn"})

    AutoSea:AddToggle({
        Name = "Auto Kitsune Island",
        Callback = function(Value)
            getgenv().AutoKitsuneIsland = Value
            if Value then
                AutoKitsuneIsland() -- ต้องมีฟังก์ชัน AutoKitsuneIsland() ไว้เรียก
            end
        end
    })

    AutoSea:AddToggle({
        Name = "Auto Trade Azure Ember",
        Callback = function(Value)
            getgenv().TradeAzureEmber = Value
            task.spawn(function()
                local Modules = ReplicatedStorage:WaitForChild("Modules", 9e9)
                local Net = Modules:WaitForChild("Net", 9e9)
                local KitsuneRemote = Net:WaitForChild("RF/KitsuneStatuePray", 9e9)
                while getgenv().TradeAzureEmber do
                    task.wait(1)
                    KitsuneRemote:InvokeServer()
                end
            end)
        end
    })

    task.spawn(function()
        local Map = workspace:WaitForChild("Map", 9e9)
        while task.wait() do
            if Map:FindFirstChild("KitsuneIsland") then
                local plrPP = Player.Character and Player.Character.PrimaryPart
                if plrPP then
                    local Distance = math.floor((plrPP.Position - Map.KitsuneIsland.WorldPivot.p).Magnitude / 3)
                    KILabel:SetTitle("Kitsune Island : Spawned | Distance : " .. tostring(Distance))
                end
            else
                KILabel:SetTitle("Kitsune Island : not Spawn")
            end
        end
    end)
end

AutoSea:AddSection({"Sea"})

AutoSea:AddToggle({
    Name = "Auto Farm Sea",
    Callback = function(Value)
        getgenv().AutoFarmSea = Value
        if Value then
            AutoFarmSea() -- ต้องมีฟังก์ชัน AutoFarmSea() ไว้เรียก
        end
    end
})

AutoSea:AddButton({
    Name = "Buy New Boat",
    Callback = function()
        BuyNewBoat() -- ต้องมีฟังก์ชัน BuyNewBoat() ไว้เรียก
    end
})

AutoSea:AddSection({"Material"})

AutoSea:AddToggle({
    Name = "Auto Wood Planks",
    Value = false,
    Callback = function(Value)
        getgenv().AutoWoodPlanks = Value

        task.spawn(function()
            local Map = workspace:WaitForChild("Map", 9e9)
            local BoatCastle = Map:WaitForChild("Boat Castle", 9e9)

            local function TreeModel()
                for _, Model in pairs(BoatCastle["IslandModel"]:GetChildren()) do
                    if Model.Name == "Model" and Model:FindFirstChild("Tree") then
                        return Model
                    end
                end
            end

            local function GetTree()
                local Tree = TreeModel()
                if Tree then
                    local Nearest = math.huge
                    local selected
                    local plrPP = Player.Character and Player.Character.PrimaryPart
                    for _, tree in pairs(Tree:GetChildren()) do
                        if tree.PrimaryPart and tree.PrimaryPart.Anchored then
                            if plrPP and (plrPP.Position - tree.PrimaryPart.Position).Magnitude < Nearest then
                                Nearest = (plrPP.Position - tree.PrimaryPart.Position).Magnitude
                                selected = tree
                            end
                        end
                    end
                    return selected
                end
            end

            local RandomEquip = ""
            while getgenv().AutoWoodPlanks do
                if VerifyToolTip("Melee") then
                    RandomEquip = "Melee"
                    task.wait(2)
                end
                if VerifyToolTip("Blox Fruit") then
                    RandomEquip = "Blox Fruit"
                    task.wait(3)
                end
                if VerifyToolTip("Sword") then
                    RandomEquip = "Sword"
                    task.wait(2)
                end
                if VerifyToolTip("Gun") then
                    RandomEquip = "Gun"
                    task.wait(2)
                end
            end
        end)
    end
})

-- Auto Wood Planks Loop
task.spawn(function()
    while getgenv().AutoWoodPlanks do
        task.wait()
        local Tree = GetTree()
        EquipToolTip(RandomEquip) -- ต้องมีฟังก์ชัน EquipToolTip(toolName)

        if Tree and Tree.PrimaryPart then
            PlayerTP(Tree.PrimaryPart.CFrame) -- ต้องมีฟังก์ชัน PlayerTP(CFrame)

            local plrPP = Player.Character and Player.Character.PrimaryPart
            if plrPP and (plrPP.Position - Tree.PrimaryPart.Position).Magnitude < 10 then
                -- ใช้สกิลตามที่เปิดไว้
                if getgenv().SeaSkillZ then KeyboardPress("Z") end
                if getgenv().SeaSkillX then KeyboardPress("X") end
                if getgenv().SeaSkillC then KeyboardPress("C") end
                if getgenv().SeaSkillV then KeyboardPress("V") end
                if getgenv().SeaSkillF then KeyboardPress("F") end
                if getgenv().SeaAimBotSkill then AimBotPart(Tree.PrimaryPart) end
            end
        end
    end
end)

-- Panic Mode Section
AutoSea:AddSection({"Panic Mode"})

AutoSea:AddSlider({
    Name = "Select Health",
    Min = 20,
    Max = 70,
    Default = 25,
    Callback = function(Value)
        getgenv().HealthPanic = Value
    end
})

AutoSea:AddToggle({
    Name = "Panic Mode",
    Value = true,
    Callback = function(Value)
        getgenv().PanicMode = Value
    end,
    Flag = "Sea/PanicMode"
})

-- Farm Select Section
AutoSea:AddSection({"Farm Select"})
AutoSea:AddParagraph({"Fish"})

AutoSea:AddToggle({
    Name = "Terrorshark",
    Flag = "Sea/TerrorShark",
    Default = true,
    Callback = function(Value)
        getgenv().Terrorshark = Value
    end
})

AutoSea:AddToggle({
    Name = "Piranha",
    Flag = "Sea/Piranha",
    Default = true,
    Callback = function(Value)
        getgenv().Piranha = Value
    end
})

AutoSea:AddToggle({
    Name = "Fish Crew Member",
    Flag = "Sea/FishCrewMember",
    Default = true,
    Callback = function(Value)
        getgenv().FishCrewMember = Value
    end
})

AutoSea:AddToggle({
    Name = "Shark",
    Flag = "Sea/Shark",
    Default = true,
    Callback = function(Value)
        getgenv().Shark = Value
    end
})

AutoSea:AddParagraph({"Boats"})

AutoSea:AddToggle({
    Name = "Pirate Brigade",
    Flag = "Sea/PirateBrigade",
    Default = true,
    Callback = function(Value)
        getgenv().PirateBrigade = Value
    end
})

AutoSea:AddToggle({
    Name = "Pirate Grand Brigade",
    Flag = "Sea/PirateGrandBrigade",
    Default = true,
    Callback = function(Value)
        getgenv().PirateGrandBrigade = Value
    end
})

AutoSea:AddToggle({
    Name = "Fish Boat",
    Flag = "Sea/FishBoat",
    Default = true,
    Callback = function(Value)
        getgenv().FishBoat = Value
    end
})

-- Skill Section
AutoSea:AddSection({"Skill"})

AutoSea:AddToggle({
    Name = "AimBot Skill Enemie",
    Flag = "Mastery/Aimbot",
    Default = true,
    Callback = function(Value)
        getgenv().SeaAimBotSkill = Value
    end
})

AutoSea:AddToggle({
    Name = "Skill Z",
    Flag = "Mastery/Z",
    Default = true,
    Callback = function(Value)
        getgenv().SeaSkillZ = Value
    end
})

AutoSea:AddToggle({
    Name = "Skill X",
    Flag = "Mastery/X",
    Default = true,
    Callback = function(Value)
        getgenv().SeaSkillX = Value
    end
})

AutoSea:AddToggle({
    Name = "Skill C",
    Flag = "Mastery/C",
    Default = true,
    Callback = function(Value)
        getgenv().SeaSkillC = Value
    end
})

AutoSea:AddToggle({
    Name = "Skill V",
    Flag = "Mastery/V",
    Default = true,
    Callback = function(Value)
        getgenv().SeaSkillV = Value
    end
})

AutoSea:AddToggle({
    Name = "Skill F",
    Flag = "Mastery/F",
    Default = true,
    Callback = function(Value)
        getgenv().SeaSkillF = Value
    end
})

-- NPC Teleport Section
AutoSea:AddSection({"NPCs"})

AutoSea:AddToggle({
    Name = "Teleport To Shark Hunter",
    Callback = function(Value)
        getgenv().NPCtween = Value
        task.spawn(function()
            while getgenv().NPCtween do
                task.wait()
                PlayerTP(CFrame.new(-16526, 108, 752))
            end
        end)
    end
})

AutoSea:AddToggle({
    Name = "Teleport To Beast Hunter",
    Callback = function(Value)
        getgenv().NPCtween = Value
        task.spawn(function()
            while getgenv().NPCtween do
                task.wait()
                PlayerTP(CFrame.new(-16281, 73, 263))
            end
        end)
    end
})

-- Teleport to Spy
AutoSea:AddToggle({
    Name = "Teleport To Spy",
    Callback = function(Value)
        getgenv().NPCtween = Value
        task.spawn(function()
            while getgenv().NPCtween do
                task.wait()
                PlayerTP(CFrame.new(-16471, 528, 539)) -- ต้องมีฟังก์ชัน PlayerTP(CFrame)
            end
        end)
    end
})

-- Config Section
AutoSea:AddSection({"Configs"})

-- Dropdown: Tween Sea Level
AutoSea:AddDropdown({
    Name = "Tween Sea Level",
    Options = {"1", "2", "3", "4", "5", "6", "inf"},
    Default = "6",
    Flag = "Sea/SeaLevel",
    Callback = function(Value)
        getgenv().SeaLevelTP = Value
    end
})

-- Slider: Boat Tween Speed
AutoSea:AddSlider({
    Name = "Boat Tween Speed",
    Min = 100,
    Max = 300,
    Increase = 10,
    Default = 250,
    Flag = "Sea/BoatSpeed",
    Callback = function(Value)
        getgenv().SeaBoatSpeed = Value
    end
})

-- Mirage / Race Tab (Only if owner and Sea3)
if Sea3 and IsOwner then
    local MirageTab = Window:MakeTab({"Race V4", ""})

    -- Auto Lever / Stone Puzzle
    MirageTab:AddToggle({
        Name = "Auto Pull Lever",
        Value = false,
        Callback = function(Value) end
    })

    MirageTab:AddToggle({
        Name = "Auto Stone Puzzle",
        Value = false,
        Callback = function(Value) end
    })

    -- Auto Mirage
    MirageTab:AddSection({"Auto Mirage"})
    MirageTab:AddToggle({
        Name = "Auto Find Mirage",
        Value = false,
        Callback = function(Value) end
    })

    MirageTab:AddToggle({
        Name = "Auto Gear Puzzle",
        Value = false,
        Callback = function(Value)
            getgenv().AutoMiragePuzzle = Value
            local function LookToMoon()
                local MoonDirection = Lighting:GetMoonDirection()
                local LookToPos = Camera.CFrame.Position + MoonDirection * 100
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, LookToPos)
            end

            local Connection
            if Value then
                Connection = RunService.Heartbeat:Connect(LookToMoon)
                task.spawn(function()
                    while getgenv().AutoMiragePuzzle do
                        task.wait()
                    end
                end)
            elseif Connection then
                Connection:Disconnect()
            end
        end
    })

    -- Auto Race
    MirageTab:AddSection({"Auto Race"})
    MirageTab:AddToggle({
        Name = "Auto Finish Trial",
        Value = false,
        Callback = function(Value)
            getgenv().AutoFinishTrial = Value

            task.spawn(function()
                local PlayerRace
                task.spawn(function()
                    while getgenv().AutoFinishTrial do
                        task.wait()
                        PlayerRace = Player.Data.Race.Value
                    end
                end)

                while getgenv().AutoFinishTrial do
                    task.wait()
                    if PlayerRace and typeof(PlayerRace) == "string" then
                        if PlayerRace == "Cyborg" then
                            PlayerTP(CFrame.new(28654, 14898, -30))
                        elseif PlayerRace == "Ghoul" or PlayerRace == "Human" then
                            KillAura() -- ต้องมีฟังก์ชัน KillAura()
                        elseif PlayerRace == "Mink" then
                            for _, part in pairs(workspace:GetDescendants()) do
                                if part.Name == "StartPoint" then
                                    PlayerTP(part.CFrame)
                                end
                            end
                        elseif PlayerRace == "Skypiea" then
                            pcall(function()
                                for _, part in pairs(workspace.Map.SkyTrial.Model:GetDescendants()) do
                                    if part.Name == "snowisland_Cylinder.081" then
                                        PlayerTP(part.CFrame)
                                    end
                                end
                            end)
                        end
                    end
                end
            end)
        end
    })
end

-- Quests / Items Tab
local QuestsTabs = Window:MakeTab({"Quests/Items", "Swords"})

-- Fruits / Raid Tab
local FruitAndRaid = Window:MakeTab({"Fruit/Raid", "Cherry"})

-- Stats Tab (เฉพาะถ้าผู้เล่นยังไม่ถึง MaxLevel)
if PlayerLevel.Value < MaxLevel then
    local StatsTab = Window:MakeTab({"Stats", "signal"})

    local PointsSlider = 1
    local Melee, Defense, Sword, Gun, DemonFruit = true, true, true, true, true

    -- ฟังก์ชันเพิ่ม Stat
    local function AddStats(stat)
        if Player.Data.Points.Value >= 1 then
            local Points = math.clamp(PointsSlider, 1, Player.Data.Points.Value)
            FireRemote("AddPoint", stat, Points)
        end
    end

    -- AutoStats Loop
    local function AutoStats()
        while getgenv().AutoStats do
            task.wait()
            if Melee then AddStats("Melee") end
            if Defense then AddStats("Defense") end
            if Sword then AddStats("Sword") end
            if Gun then AddStats("Gun") end
            if DemonFruit then AddStats("Demon Fruit") end
        end
    end

    -- UI: AutoStats Toggle
    StatsTab:AddToggle({
        Name = "Auto Stats",
        Flag = "Stats/AutoStats",
        Callback = function(Value)
            getgenv().AutoStats = Value
            if Value then
                task.spawn(AutoStats)
            end
        end
    })

    -- UI: Points Slider
    StatsTab:AddSlider({
        Name = "Select Points",
        Flag = "Stats/SelectPoints",
        Min = 1,
        Max = 100,
        Increase = 1,
        Default = 1,
        Callback = function(Value)
            PointsSlider = Value
        end
    })

    -- Section: Select Stats
    StatsTab:AddSection({"Select Stats"})
    StatsTab:AddToggle({Name = "Melee", Callback = function(Value) Melee = Value end})
    StatsTab:AddToggle({Name = "Defense", Callback = function(Value) Defense = Value end})
    StatsTab:AddToggle({Name = "Sword", Callback = function(Value) Sword = Value end})
    StatsTab:AddToggle({Name = "Gun", Callback = function(Value) Gun = Value end})
    StatsTab:AddToggle({Name = "Demon Fruit", Callback = function(Value) DemonFruit = Value end})
end

-- Teleport Tab
local Teleport = Window:MakeTab({"Teleport", "Locate"})

-- Visual Tab
local Visual = Window:MakeTab({"Visual", "User"})

-- Shop Tab
local Shop = Window:MakeTab({"Shop", "ShoppingCart"})

-- Misc Tab
local Misc = Window:MakeTab({"Misc", "Settings"})



-- Multi Farm Toggle (เฉพาะ Sea3)
if PlayerLevel.Value >= MaxLevel and Sea3 then
    MainFarm:AddToggle({
        Name = "Start Multi Farm < BETA >",
        Callback = function(Value)
            for _, Val in pairs(AFKOptions) do
                task.spawn(function()
                    Val:Set(Value)
                end)
            end
        end
    })
end

-- MainFarm Section: Farm Toggles

local Toggle = Tab:Toggle({
    Title = "Toggledasd",
    Desc = "Toggle Description",
    Icon = "bird",
    Type = "Checkbox",
    Callback = function(Value)
        getgenv().AutoFarm_Level = Value
        if Value then AutoFarm_Level() end
    end,
})


MainFarm:AddToggle({
    Name = "Auto Farm Nearest",
    Value = false,
    Callback = function(Value)
        getgenv().AutoFarmNearest = Value
        if Value then AutoFarmNearest() end
    end
})

-- Conditional Toggles for Sea3 / Sea2
if Sea3 then
    table.insert(AFKOptions, MainFarm:AddToggle({
        Name = "Auto Pirates Sea",
        Value = false,
        Callback = function(Value)
            getgenv().AutoPiratesSea = Value
            if Value then AutoPiratesSea() end
        end
    }))
elseif Sea2 then
    MainFarm:AddToggle({
        Name = "Auto Factory",
        Value = false,
        Callback = function(Value)
            getgenv().AutoFactory = Value
            if Value then AutoFactory() end
        end
    })
end

-- Auto Gift System
MainFarm:AddToggle({
    Name = "Auto Gift",
    Value = false,
    Callback = function(Value)
        getgenv().AutoGift = Value
        task.spawn(function()
            local function GetGift()
                for _, part in pairs(workspace["_WorldOrigin"]:GetChildren()) do
                    if part.Name == "Present" and part:FindFirstChild("Box") and part.Box:FindFirstChild("ProximityPrompt") then
                        return part, part.Box.ProximityPrompt
                    end
                end
            end

            while getgenv().AutoGift do
                task.wait()
                local Gift, Prompt = GetGift()
                if Gift and Gift.PrimaryPart then
                    PlayerTP(Gift.PrimaryPart.CFrame)
                    if Prompt then
                        fireproximityprompt(Prompt)
                    end
                elseif getgenv().TimeToGift < 90 then
                    if Sea3 then
                        PlayerTP(CFrame.new(-1076, 14, -14437))
                    elseif Sea2 then
                        PlayerTP(CFrame.new(-5219, 15, 1532))
                    elseif Sea1 then
                        PlayerTP(CFrame.new(1007, 15, -3805))
                    end
                end
            end
        end)
    end
})

-- ==== MainFarm Sea / Boss / Material / Mastery / Skill ====
if Sea3 then
    MainFarm:AddSection({"Bone"})

    table.insert(AFKOptions, MainFarm:AddToggle({
        Name = "Auto Farm Bone",
        Callback = function(Value)
            getgenv().AutoFarmBone = Value
            if Value then AutoFarmBone() end
        end
    }))

    table.insert(AFKOptions, MainFarm:AddToggle({
        Name = "Auto Hallow Scythe",
        Callback = function(Value)
            getgenv().AutoSoulReaper = Value
            if Value then AutoSoulReaper() end
        end
    }))

    table.insert(AFKOptions, MainFarm:AddToggle({
        Name = "Auto Trade Bone",
        Callback = function(Value)
            getgenv().AutoTradeBone = Value
            task.spawn(function()
                while getgenv().AutoTradeBone do
                    task.wait()
                    FireRemote("Bones", "Buy", 1, 1)
                end
            end)
        end
    }))
elseif Sea2 then
    MainFarm:AddSection({"Ectoplasm"})
    MainFarm:AddToggle({
        Name = "Auto Farm Ectoplasm",
        Callback = function(Value)
            getgenv().AutoFarmEctoplasm = Value
            if Value then AutoFarmEctoplasm() end
        end
    })
end

-- Chest Section
MainFarm:AddSection({"Chest"})
MainFarm:AddToggle({
    Name = "Auto Chest <Tween>",
    Callback = function(Value)
        getgenv().AutoChestTween = Value
        if Value then AutoChestTween() end
    end
})
MainFarm:AddToggle({
    Name = "Auto Chest <Bypass>",
    Callback = function(Value)
        getgenv().AutoChestBypass = Value
        if Value then AutoChestBypass() end
    end
})

-- Boss Section
MainFarm:AddSection({"Bosses"})
MainFarm:AddButton({
    Name = "Update Boss List",
    Callback = function()
        pcall(UpdateBossList)
    end
})

local BossList = MainFarm:AddDropdown({
    Name = "Boss List",
    Callback = function(Value)
        getgenv().BossSelected = Value
    end
})

function UpdateBossList()
    local NewOptions = {}
    for _, NameBoss in pairs(BossListT) do
        if VerifyNPC(NameBoss) then
            table.insert(NewOptions, NameBoss)
        end
    end
    BossList:Set(NewOptions, true)
end
UpdateBossList()

MainFarm:AddToggle({
    Name = "Auto Farm Boss Selected",
    Callback = function(Value)
        getgenv().AutoFarmBossSelected = Value
        if Value then AutoFarmBossSelected() end
    end
})
MainFarm:AddToggle({
    Name = "Auto Farm All Boss",
    Callback = function(Value)
        getgenv().KillAllBosses = Value
        if Value then KillAllBosses() end
    end
})
MainFarm:AddToggle({
    Name = "Take Quest",
    Default = true,
    Callback = function(Value)
        getgenv().TakeQuestBoss = Value
    end
})
MainFarm:AddButton({
    Name = "Server HOP",
    Callback = function()
        ServerHop()
    end
})

-- Material Section
MainFarm:AddSection({"Material"})
local MaterialList = {}
if Sea1 then
    MaterialList = {"Angel Wings", "Leather + Scrap Metal", "Magma Ore", "Fish Tail"}
elseif Sea2 then
    MaterialList = {"Leather + Scrap Metal", "Magma Ore", "Mystic Droplet", "Radiactive Material", "Vampire Fang"}
elseif Sea3 then
    MaterialList = {"Leather + Scrap Metal", "Fish Tail", "Gunpowder", "Mini Tusk", "Conjured Cocoa", "Dragon Scale"}
end

MainFarm:AddDropdown({
    Name = "Material List",
    Options = MaterialList,
    Flag = "Material/Selected",
    Callback = function(Value)
        getgenv().MaterialSelected = Value
    end
})
MainFarm:AddToggle({
    Name = "Auto Farm Material",
    Callback = function(Value)
        getgenv().AutoFarmMaterial = Value
        if Value then AutoFarmMaterial() end
    end
})

-- Mastery Section
MainFarm:AddSection({"Mastery"})
MainFarm:AddSlider({
    Name = "Select Health",
    Min = 10,
    Max = 100,
    Default = 25,
    Callback = function(Value)
        getgenv().HealthSkill = Value
    end
})
MainFarm:AddDropdown({
    Name = "Select Tool",
    Options = {"Blox Fruit"},
    Default = "Blox Fruit",
    Callback = function(Value)
        getgenv().ToolMastery = Value
    end
})
MainFarm:AddToggle({
    Name = "Auto Farm Mastery",
    Callback = function(Value)
        getgenv().AutoFarmMastery = Value
        if Value then AutoFarmMastery() end
    end
})

-- Skill Section
MainFarm:AddSection({"Skill"})
local SkillToggles = { "Z", "X", "C", "V", "F" }
for _, skill in ipairs(SkillToggles) do
    MainFarm:AddToggle({
        Name = "Skill " .. skill,
        Flag = "Sea/"..skill,
        Default = true,
        Callback = function(Value)
            getgenv()["Skill"..skill] = Value
        end
    })
end
MainFarm:AddToggle({
    Name = "AimBot Skill Enemie",
    Flag = "Sea/Aimbot",
    Default = true,
    Callback = function(Value)
        getgenv().AimBotSkill = Value
    end
})

-- Fruits Section
FruitAndRaid:AddSection({"Fruits"})
local Fruit_BlackList = {}
FruitAndRaid:AddToggle({
    Name = "Auto Store Fruits",
    Flag = "Fruits/AutoStore",
    Callback = function(Value)
        getgenv().AutoStoreFruits = Value
        task.spawn(function()
            local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
            while getgenv().AutoStoreFruits do
                task.wait()
                local plrBag = Player.Backpack
                local plrChar = Player.Character
                if plrChar then
                    for _, Fruit in pairs(plrChar:GetChildren()) do
                        if Fruit:IsA("Tool") and Fruit:FindFirstChild("Fruit") and not table.find(Fruit_BlackList, Fruit.Name) then
                            if Remote:InvokeServer("StoreFruit", Get_Fruit(Fruit.Name), Fruit) ~= true then
                                table.insert(Fruit_BlackList, Fruit.Name)
                            end
                        end
                    end
                end
                for _, Fruit in pairs(plrBag:GetChildren()) do
                    if Fruit:IsA("Tool") and Fruit:FindFirstChild("Fruit") and not table.find(Fruit_BlackList, Fruit.Name) then
                        if Remote:InvokeServer("StoreFruit", Get_Fruit(Fruit.Name), Fruit) ~= true then
                            table.insert(Fruit_BlackList, Fruit.Name)
                        end
                    end
                end
            end
        end)
    end
})

-- ==== Fruits Section ====
table.insert(AFKOptions, FruitAndRaid:AddToggle({
    Name = "Teleport to Fruits",
    Flag = "Fruits/Teleport",
    Callback = function(Value)
        getgenv().TeleportToFruit = Value
        task.spawn(function()
            while getgenv().TeleportToFruit do
                task.wait()
                if Configure("Fruit") then
                    getgenv().TeleportingToFruit = false
                else
                    local Fruit = FruitFind()
                    if Fruit then
                        PlayerTP(Fruit.CFrame)
                        getgenv().TeleportingToFruit = true
                    else
                        getgenv().TeleportingToFruit = false
                    end
                end
            end
        end)
    end
}))

FruitAndRaid:AddToggle({
    Name = "Auto Random Fruit",
    Flag = "Fruits/AutoRandom",
    Callback = function(Value)
        getgenv().AutoRandomFruit = Value
        task.spawn(function()
            while getgenv().AutoRandomFruit do
                task.wait(1)
                FireRemote("Cousin", "Buy")
            end
        end)
    end
})

-- ==== Raid Section ====
FruitAndRaid:AddSection({"Raid"})
if Sea1 then
    FruitAndRaid:AddParagraph({"Only on Sea 2 and 3"})
elseif Sea2 or Sea3 then
    local Raids_Chip = {}
    local Raids = require(ReplicatedStorage.Raids)
    for _, b in pairs(Raids.advancedRaids) do table.insert(Raids_Chip, b) end
    for _, b in pairs(Raids.raids) do table.insert(Raids_Chip, b) end

    FruitAndRaid:AddDropdown({
        Name = "Select Raid",
        Options = Raids_Chip,
        Flag = "Raid/SelectedChip",
        Callback = function(Value)
            getgenv().SelectRaidChip = Value
        end
    })

    FruitAndRaid:AddToggle({
        Name = "Auto Farm Raid",
        Callback = function(Value)
            getgenv().AutoFarmRaid = Value

            task.spawn(function()
                local Islands = workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations")
                local function GetIsland(Name)
                    local plrChar = Player and Player.Character
                    local plrPP = plrChar and plrChar.PrimaryPart
                    for _, island in pairs(Islands:GetChildren()) do
                        if island.Name == Name and plrPP and (island.Position - plrPP.Position).Magnitude < 3000 then
                            return island
                        end
                    end
                end

                while getgenv().AutoFarmRaid do
                    task.wait(0.5)
                    if not Configure("Raid") then
                        FireRemote("Awakener", "Check")
                        FireRemote("Awakener", "Awaken")
                    end

                    if getgenv().SelectRaidChip == "Rumble" then
                        FireRemote("ThunderGodTalk", true)
                    end

                    if not Configure("Raid") then
                        local plrChar = Player.Character
                        if plrChar and plrChar:FindFirstChild("PrimaryPart") then
                            local islands = {"Island 5","Island 4","Island 3","Island 2","Island 1"}
                            for _, islName in ipairs(islands) do
                                local isl = GetIsland(islName)
                                if isl then
                                    getgenv().FarmingRaid = true
                                    PlayerTP(isl.CFrame + Vector3.new(0,70,0))
                                    break
                                end
                            end
                        else
                            getgenv().FarmingRaid = false
                        end
                    else
                        getgenv().FarmingRaid = false
                    end
                end
            end)
        end
    })

    FruitAndRaid:AddToggle({
        Name = "Auto Buy Chip",
        Default = false,
        Callback = function(Value)
            getgenv().AutoBuyChip = Value
            task.spawn(function()
                while getgenv().AutoBuyChip do
                    task.wait()
                    if not VerifyTool("Special Microchip") then
                        FireRemote("RaidsNpc", "Select", getgenv().SelectRaidChip)
                        task.wait(1)
                    end
                end
            end)
        end
    })
end

-- ==== Quests Tabs ====
if Sea1 then
    QuestsTabs:AddSection({"Second Sea"})
    QuestsTabs:AddToggle({
        Name = "Auto Second Sea",
        Callback = function(Value)
            getgenv().AutoSecondSea = Value
            AutoSecondSea()
        end
    })

    QuestsTabs:AddSection({"Saber"})
    QuestsTabs:AddToggle({
        Name = "Auto Unlock Saber <Level +200>",
        Callback = function(Value)
            getgenv().AutoUnlockSaber = Value
            AutoUnlockSaber()
        end
    })

    QuestsTabs:AddSection({"God Boss"})
    QuestsTabs:AddToggle({
        Name = "Auto Pole V1",
        Callback = function(Value)
            getgenv().AutoEnelBossPole = Value
            AutoEnelBossPole()
        end
    })

    QuestsTabs:AddSection({"The Saw"})
    QuestsTabs:AddToggle({
        Name = "Auto Saw Sword",
        Callback = function(Value)
            getgenv().AutoSawBoss = Value
            AutoSawBoss()
        end
    })
elseif Sea2 then
    QuestsTabs:AddSection({"Third Sea"})
    QuestsTabs:AddToggle({
        Name = "Auto Third Sea",
        Callback = function(Value)
            getgenv().AutoThirdSea = Value
            AutoThirdSea()
        end
    })

    QuestsTabs:AddToggle({
        Name = "Auto Kill Don Swan",
        Callback = function(Value)
            getgenv().AutoKillDonSwan = Value
            AutoKillDonSwan()
        end
    })

    QuestsTabs:AddToggle({
        Name = "Auto Don Swan Hop",
        Callback = function(Value)
            getgenv().AutoDonSwanHop = Value
        end
    })

    -- Bartilo
    QuestsTabs:AddSection({"Bartilo Quest"})
    QuestsTabs:AddToggle({
        Name = "Auto Bartilo Quest",
        Callback = function(Value)
            getgenv().AutoBartiloQuest = Value
            AutoBartiloQuest()
        end
    })

    -- Rengoku
    QuestsTabs:AddSection({"Rengoku"})
    QuestsTabs:AddToggle({
        Name = "Auto Rengoku",
        Callback = function(Value)
            getgenv().AutoRengoku = Value
            AutoRengoku()
        end
    })
    QuestsTabs:AddToggle({
        Name = "Auto Rengoku Hop",
        Callback = function(Value)
            getgenv().AutoRengokuHop = Value
        end
    })
end

-- ==== Tushita Section ====
QuestsTabs:AddToggle({
    Name = "Auto Elite Hunter Hop",
    Callback = function(Value)
        getgenv().AutoEliteHunterHop = Value
    end
})

QuestsTabs:AddSection({"Tushita"})
local LabelRipIndra = QuestsTabs:AddParagraph({"Rip Indra Stats : not Spawn"})
task.spawn(function()
    while task.wait(0.5) do
        if VerifyNPC("rip_indra True Form") then
            LabelRipIndra:SetTitle("Rip Indra Stats : Spawned")
        else
            LabelRipIndra:SetTitle("Rip Indra Stats : not Spawn")
        end
    end
end)

QuestsTabs:AddToggle({
    Name = "Auto Tushita",
    Callback = function(Value)
        getgenv().AutoTushita = Value
        task.spawn(function()
            local Map = workspace:WaitForChild("Map", 9e9)
            local Turtle = Map:WaitForChild("Turtle", 9e9)
            local QuestTorches = Turtle:WaitForChild("QuestTorches", 9e9)

            local Active = {false,false,false,false,false}

            while getgenv().AutoTushita do
                task.wait()
                if not Turtle:FindFirstChild("TushitaGate") then
                    local Enemie = Enemies:FindFirstChild("Longma")
                    if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                        PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                        pcall(function() PlayerClick(); ActiveHaki(); EquipTool() end)
                    else
                        PlayerTP(CFrame.new(-10218, 333, -9444))
                    end
                elseif VerifyNPC("rip_indra True Form") then
                    if not VerifyTool("Holy Torch") then
                        PlayerTP(CFrame.new(5152, 142, 912))
                    else
                        local Torches = {}
                        for i = 1, 5 do
                            Torches[i] = QuestTorches:FindFirstChild("Torch"..i)
                        end
                        for i, torch in ipairs(Torches) do
                            local enabled = torch and torch:FindFirstChild("Particles") and torch.Particles:FindFirstChild("PointLight") and not torch.Particles.PointLight.Enabled
                            if not Active[i] and enabled then
                                PlayerTP(torch.CFrame)
                                Active[i] = true
                                break
                            end
                        end
                    end
                else
                    local NPC = "EliteBossVerify"
                    if VerifyQuest("Diablo") then NPC = "Diablo"
                    elseif VerifyQuest("Deandre") then NPC = "Deandre"
                    elseif VerifyQuest("Urban") then NPC = "Urban"
                    else task.spawn(function() FireRemote("EliteHunter") end) end

                    local EliteBoss = GetEnemies({NPC})
                    if EliteBoss and EliteBoss:FindFirstChild("HumanoidRootPart") then
                        PlayerTP(EliteBoss.HumanoidRootPart.CFrame + getgenv().FarmPos)
                        pcall(function() PlayerClick(); ActiveHaki(); EquipTool() end)
                    elseif not VerifyNPC("Deandre") and not VerifyNPC("Diablo") and not VerifyNPC("Urban") then
                        if getgenv().AutoTushitaHop then ServerHop() end
                    end
                end
            end
        end)
    end
})

QuestsTabs:AddToggle({
    Name = "Auto Tushita Hop",
    Callback = function(Value)
        getgenv().AutoTushitaHop = Value
    end
})

-- ==== Cake Prince + Dough King ====
QuestsTabs:AddSection({"Cake Prince + Dough King"})
local CakeLabel = QuestsTabs:AddParagraph({"Stats : 0"})

task.spawn(function()
    while task.wait(1) do
        if VerifyNPC("Dough King") then
            CakeLabel:SetTitle("Stats : Spawned | Dough King")
        elseif VerifyNPC("Cake Prince") then
            CakeLabel:SetTitle("Stats : Spawned | Cake Prince")
        else
            local EnemiesCake = FireRemote("CakePrinceSpawner", true)
            CakeLabel:SetTitle("Stats : " .. tostring(EnemiesCake):gsub("%D",""))
        end
    end
end)

local CakePrinceToggle = QuestsTabs:AddToggle({
    Name = "Auto Cake Prince",
    Default = false,
    Callback = function(Value)
        getgenv().AutoCakePrince = Value
        AutoCakePrince()
    end
})

local DoughKingToggle = QuestsTabs:AddToggle({
    Name = "Auto Dough King",
    Default = false,
    Callback = function(Value)
        getgenv().AutoDoughKing = Value
        AutoDoughKing()
    end
})

-- Mutual exclusion
CakePrinceToggle:Callback(function() DoughKingToggle:Set(false) end)
DoughKingToggle:Callback(function() CakePrinceToggle:Set(false) end)

-- ==== Rip Indra Legendary Haki ====
QuestsTabs:AddSection({"Rip Indra"})
local ActiveButtonToggle = QuestsTabs:AddToggle({
    Name = "Auto Active Button Haki Color",
    Default = false,
    Callback = function(Value)
        getgenv().RipIndraLegendaryHaki = Value
        task.spawn(function()
            while getgenv().RipIndraLegendaryHaki do
                task.wait()
                local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                if plrChar then
                    local pos = plrChar.Position
                    if (pos - Vector3.new(-5415,314,-2212)).Magnitude < 5 then
                        FireRemote("activateColor","Pure Red")
                    elseif (pos - Vector3.new(-4972,336,-3720)).Magnitude < 5 then
                        FireRemote("activateColor","Snow White")
                    elseif (pos - Vector3.new(-5420,1089,-2667)).Magnitude < 5 then
                        FireRemote("activateColor","Winter Sky")
                    end
                end
            end
        end)
    end
})

local RipIndraToggle = QuestsTabs:AddToggle({
    Name = "Auto Rip Indra",
    Default = false,
    Callback = function(Value)
        getgenv().AutoRipIndra = Value
        AutoRipIndra()
    end
})

RipIndraToggle:Callback(function() ActiveButtonToggle:Set(false) end)
ActiveButtonToggle:Callback(function() RipIndraToggle:Set(false) end)

-- ==== Musketeer Hat ====
QuestsTabs:AddSection({"Musketeer Hat"})
QuestsTabs:AddToggle({
    Name = "Auto Musketeer Hat",
    Callback = function(Value)
        getgenv().AutoMusketeerHat = Value
        AutoMusketeerHat()
    end
})

-- ==== Server Hop Button ====
QuestsTabs:AddButton({
    Name = "Server HOP",
    Callback = function()
        ServerHop()
    end
})

-- ==== Fighting Style Section ====
if Sea2 or Sea3 then
    QuestsTabs:AddSection({"Fighting Style"})
    QuestsTabs:AddToggle({
        Name = "Auto Death Step",
        Callback = function(Value)
            getgenv().AutoDeathStep = Value
            task.spawn(function()
                local MasteryBlackLeg = 0
                local KeyFind = false

                local function GetProxyNPC()
                    local Distance = math.huge
                    local NPC = nil
                    local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                    for _, npc in pairs(Enemies:GetChildren()) do
                        if npc.Name == "Reborn Skeleton" or npc.Name == "Living Zombie" or npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water Fighter" then
                            if plrChar and npc and npc:FindFirstChild("HumanoidRootPart") and (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
                                Distance = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                                NPC = npc
                            end
                        end
                    end
                    return NPC
                end

                while getgenv().AutoDeathStep do
                    task.wait()
                    if VerifyTool("Black Leg") then
                        MasteryBlackLeg = GetToolLevel("Black Leg")
                    end

                    if MasteryBlackLeg >= 400 and Sea3 then
                        FireRemote("TravelDressrosa")
                    end

                    if KeyFind then
                        FireRemote("BuyDeathStep")
                    end

                    if VerifyTool("Death Step") then
                        EquipToolName("Death Step")
                    elseif MasteryBlackLeg >= 400 then
                        local Enemie = Enemies:FindFirstChild("Awakened Ice Admiral")
                        if VerifyTool("Library Key") then
                            KeyFind = true
                            EquipToolName("Library Key")
                            PlayerTP(CFrame.new(6373,293,-6839))
                        elseif Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                            PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                            pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie) end)
                        else
                            PlayerTP(CFrame.new(6473,297,-6944))
                        end
                    elseif not VerifyTool("Black Leg") and MasteryBlackLeg < 400 then
                        FireRemote("BuyBlackLeg")
                    elseif VerifyTool("Black Leg") and MasteryBlackLeg < 400 then
                        EquipToolName("Black Leg")
                        local Enemie = GetProxyNPC()
                        if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                            PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                            pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie) end)
                        else
                            if Sea3 then
                                PlayerTP(CFrame.new(-9513,164,5786))
                            else
                                PlayerTP(CFrame.new(-3350,282,-10527))
                            end
                        end
                    end
                end
            end)
        end
    })
end

-- ==== Auto Electric Claw ====
QuestsTabs:AddToggle({
    Name = "Auto Electric Claw <BETA>",
    Callback = function(Value)
        getgenv().AutoElectricClaw = Value
        task.spawn(function()
            local MasteryElectro = 0
            local MasteryElectricClaw = 0

            local function GetProxyNPC()
                local Distance = math.huge
                local NPC = nil
                local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                for _, npc in pairs(Enemies:GetChildren()) do
                    if npc.Name == "Reborn Skeleton" or npc.Name == "Living Zombie" or npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water Fighter" then
                        if plrChar and npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                            if dist <= Distance then
                                Distance = dist
                                NPC = npc
                            end
                        end
                    end
                end
                return NPC
            end

            while getgenv().AutoElectricClaw do task.wait()
                if VerifyTool("Electro") then
                    MasteryElectro = GetToolLevel("Electro")
                elseif VerifyTool("Electric Claw") then
                    MasteryElectricClaw = GetToolLevel("Electric Claw")
                end

                if MasteryElectro < 400 then
                    if not VerifyTool("Electro") then FireRemote("BuyElectro")
                    else EquipToolName("Electro") end
                elseif MasteryElectricClaw < 600 then
                    if not VerifyTool("Electric Claw") then FireRemote("BuyElectricClaw")
                    else EquipToolName("Electric Claw") end
                end

                local Enemie = GetProxyNPC()
                if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                    PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                    pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie) end)
                else
                    if Sea3 then
                        PlayerTP(CFrame.new(-9513,164,5786))
                    else
                        PlayerTP(CFrame.new(-3350,282,-10527))
                    end
                end
            end
        end)
    end
})

-- ==== Auto Sharkman Karate ====
QuestsTabs:AddToggle({
    Name = "Auto Sharkman Karate",
    Callback = function(Value)
        getgenv().AutoSharkmanKarate = Value
        task.spawn(function()
            local MasteryFishmanKarate = 0
            local MasterySharkmanKarate = 0
            local SharkmanStats = 0

            task.spawn(function()
                while getgenv().AutoSharkmanKarate do task.wait()
                    SharkmanStats = FireRemote("BuySharkmanKarate", true)
                end
            end)

            while getgenv().AutoSharkmanKarate do task.wait()
                if VerifyTool("Fishman Karate") then
                    MasteryFishmanKarate = GetToolLevel("Fishman Karate")
                elseif VerifyTool("Sharkman Karate") then
                    MasterySharkmanKarate = GetToolLevel("Sharkman Karate")
                end

                if SharkmanStats == 1 then
                    FireRemote("BuySharkmanKarate")
                elseif VerifyTool("Sharkman Karate") then
                    EquipToolName("Sharkman Karate")
                    local Enemie = Enemies:FindFirstChild("Water Fighter")
                    if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                        PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                        pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie,true) end)
                    else
                        TweenNPCSpawn({
                            CFrame.new(-3339,290,-10412),
                            CFrame.new(-3518,290,-10419),
                            CFrame.new(-3536,290,-10607),
                            CFrame.new(-3345,280,-10667)
                        }, "Water Fighter")
                    end
                elseif VerifyTool("Water Key") and MasteryFishmanKarate >= 400 then
                    FireRemote("BuySharkmanKarate", true)
                elseif not VerifyTool("Water Key") and MasteryFishmanKarate >= 400 then
                    local Enemie = Enemies:FindFirstChild("Water Fighter")
                    if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                        PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                        pcall(function() PlayerClick(); ActiveHaki(); EquipTool(); BringNPC(Enemie,true) end)
                    else
                        TweenNPCSpawn({
                            CFrame.new(-3339,290,-10412),
                            CFrame.new(-3518,290,-10419),
                            CFrame.new(-3536,290,-10607),
                            CFrame.new(-3345,280,-10667)
                        }, "Water Fighter")
                    end
                elseif not VerifyTool("Fishman Karate") and MasteryFishmanKarate < 400 then
                    FireRemote("BuyFishmanKarate")
                elseif VerifyTool("Fishman Karate") and MasteryFishmanKarate < 400 then
                    EquipToolName("Fishman Karate")
                    local Enemie = Enemies:FindFirstChild("Water Fighter")
                    if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                        PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                        pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie,true) end)
                    else
                        TweenNPCSpawn({
                            CFrame.new(-3339,290,-10412),
                            CFrame.new(-3518,290,-10419),
                            CFrame.new(-3536,290,-10607),
                            CFrame.new(-3345,280,-10667)
                        }, "Water Fighter")
                    end
                end
            end
        end)
    end
})

-- ==== Auto Dragon Talon ====
QuestsTabs:AddToggle({
    Name = "Auto Dragon Talon",
    Callback = function(Value)
        getgenv().AutoDragonTalon = Value
        task.spawn(function()
            local MasteryDragonClaw = 0
            local FireEssence = false

            local function GetProxyNPC()
                local Distance = math.huge
                local NPC = nil
                local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                for _, npc in pairs(Enemies:GetChildren()) do
                    if npc.Name == "Reborn Skeleton" or npc.Name == "Living Zombie" or npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water Fighter" then
                        if plrChar and npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                            if dist <= Distance then
                                Distance = dist
                                NPC = npc
                            end
                        end
                    end
                end
                return NPC
            end

            task.spawn(function()
                while getgenv().AutoDragonTalon do task.wait()
                    if not VerifyTool("Fire Essence") then
                        FireRemote("Bones", "Buy", 1, 1)
                    else
                        FireRemote("BuyDragonTalon", true)
                        FireEssence = true
                    end
                end
            end)

            while getgenv().AutoDragonTalon do task.wait()
                if VerifyTool("Dragon Claw") then
                    MasteryDragonClaw = GetToolLevel("Dragon Claw")
                end

                if MasteryDragonClaw >= 400 and Sea2 then
                    FireRemote("TravelZou")
                end

                if FireEssence and MasteryDragonClaw >= 400 then
                    FireRemote("BuyDragonTalon")
                elseif not VerifyTool("Dragon Claw") or MasteryDragonClaw < 400 then
                    FireRemote("BlackbeardReward", "DragonClaw", "DragonClaw", "1")
                    FireRemote("BlackbeardReward", "DragonClaw", "DragonClaw", "2")
                    if VerifyTool("Dragon Claw") then EquipToolName("Dragon Claw") end
                end

                local Enemie = GetProxyNPC()
                if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                    PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                    pcall(function() PlayerClick(); ActiveHaki(); BringNPC(Enemie) end)
                else
                    if Sea3 then
                        PlayerTP(CFrame.new(-9513,164,5786))
                    else
                        PlayerTP(CFrame.new(-3350,282,-10527))
                    end
                end
            end
        end)
    end
})

-- Auto Superhuman + Godhuman Script

-- ฟังก์ชันหา NPC ใกล้ตัว
local function GetProxyNPC()
    local Distance = math.huge
    local NPC = nil
    local plrChar = Player and Player.Character and Player.Character.PrimaryPart
    for _, npc in pairs(Enemies:GetChildren()) do
        if npc.Name == "Reborn Skeleton" 
        or npc.Name == "Living Zombie" 
        or npc.Name == "Demonic Soul" 
        or npc.Name == "Posessed Mummy" 
        or npc.Name == "Water Fighter" then
            if plrChar and npc:FindFirstChild("HumanoidRootPart") then
                local mag = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                if mag < Distance then
                    Distance = mag
                    NPC = npc
                end
            end
        end
    end
    return NPC
end

-- ==================== Auto Superhuman ====================
QuestsTabs:AddToggle({
    Name = "Auto Superhuman",
    Callback = function(Value)
        getgenv().AutoSuperhuman = Value
        task.spawn(function()
            while getgenv().AutoSuperhuman do task.wait()
                -- Mastery
                local MasteryBlackLeg = VerifyTool("Black Leg") and GetToolLevel("Black Leg") or 0
                local MasteryElectro = VerifyTool("Electro") and GetToolLevel("Electro") or 0
                local MasteryFishmanKarate = VerifyTool("Fishman Karate") and GetToolLevel("Fishman Karate") or 0
                local MasteryDragonClaw = VerifyTool("Dragon Claw") and GetToolLevel("Dragon Claw") or 0
                local MasterySuperhuman = VerifyTool("Superhuman") and GetToolLevel("Superhuman") or 0

                -- Buy / Equip
                if MasteryBlackLeg < 300 then
                    if not VerifyTool("Black Leg") then FireRemote("BuyBlackLeg") else EquipToolName("Black Leg") end
                elseif MasteryElectro < 300 then
                    if not VerifyTool("Electro") then FireRemote("BuyElectro") else EquipToolName("Electro") end
                elseif MasteryFishmanKarate < 300 then
                    if not VerifyTool("Fishman Karate") then FireRemote("BuyFishmanKarate") else EquipToolName("Fishman Karate") end
                elseif MasteryDragonClaw < 300 then
                    if not VerifyTool("Dragon Claw") then
                        FireRemote("BlackbeardReward","DragonClaw","1")
                        FireRemote("BlackbeardReward","DragonClaw","2")
                    else EquipToolName("Dragon Claw") end
                elseif MasterySuperhuman < 600 then
                    if not VerifyTool("Superhuman") then FireRemote("BuySuperhuman") else EquipToolName("Superhuman") end
                end

                -- Fight NPC
                local Enemie = GetProxyNPC()
                if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                    PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                    pcall(function() PlayerClick() ActiveHaki() BringNPC(Enemie) end)
                else
                    if Sea3 then
                        PlayerTP(CFrame.new(-9513, 164, 5786))
                    else
                        PlayerTP(CFrame.new(-3350, 282, -10527))
                    end
                end
            end
        end)
    end
})

-- ==================== Auto Godhuman ====================
QuestsTabs:AddToggle({
    Name = "Auto God Human",
    Callback = function(Value)
        getgenv().AutoGodHuman = Value
        task.spawn(function()
            local MasteryStyles = {
                "Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman",
                "Death Step", "Electric Claw", "Sharkman Karate", "Dragon Talon", "Godhuman"
            }

            while getgenv().AutoGodHuman do task.wait()
                if Sea2 then FireRemote("TravelZou") end

                local MaxMastery = getgenv().AutoMasteryValue or 600
                for _, style in pairs(MasteryStyles) do
                    local lvl = VerifyTool(style) and GetToolLevel(style) or 0
                    if lvl < MaxMastery then
                        if not VerifyTool(style) then
                            if style == "Dragon Claw" then
                                FireRemote("BlackbeardReward","DragonClaw","1")
                                FireRemote("BlackbeardReward","DragonClaw","2")
                            else
                                BuyFightStyle("Buy"..style)
                            end
                        else
                            EquipToolName(style)
                        end
                    end
                end

                -- Fight NPC
                local Enemie = GetProxyNPC()
                if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                    PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                    pcall(function() PlayerClick() ActiveHaki() BringNPC(Enemie) end)
                else
                    PlayerTP(CFrame.new(-9513, 164, 5786))
                end
            end
        end)
    end
})

-- ==================== Auto Godhuman / Fighting Styles ====================

QuestsTabs:AddToggle({
    Name = "Auto God Human",
    Callback = function(Value)
        getgenv().AutoGodHuman = Value
        task.spawn(function()
            local MasteryStyles = {
                "Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman",
                "Death Step", "Electric Claw", "Sharkman Karate", "Dragon Talon", "Godhuman"
            }

            while getgenv().AutoGodHuman do task.wait()
                if Sea2 then
                    FireRemote("TravelZou")
                end

                -- ตรวจสอบ mastery แต่ละสไตล์
                local MaxMastery = getgenv().AutoMasteryValue or 400
                for _, style in pairs(MasteryStyles) do
                    local lvl = VerifyTool(style) and GetToolLevel(style) or 0
                    if lvl < MaxMastery then
                        if not VerifyTool(style) then
                            if style == "Dragon Claw" then
                                FireRemote("BlackbeardReward","DragonClaw","1")
                                FireRemote("BlackbeardReward","DragonClaw","2")
                            else
                                BuyFightStyle("Buy"..style)
                            end
                        else
                            EquipToolName(style)
                        end
                    end
                end

                -- หา NPC ใกล้ตัวแล้ววาร์ป + ตี
                local function GetProxyNPC()
                    local Distance = math.huge
                    local NPC = nil
                    local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                    for _, npc in pairs(Enemies:GetChildren()) do
                        if npc.Name == "Reborn Skeleton"
                        or npc.Name == "Living Zombie"
                        or npc.Name == "Demonic Soul"
                        or npc.Name == "Posessed Mummy" then
                            if plrChar and npc:FindFirstChild("HumanoidRootPart") then
                                local mag = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                                if mag < Distance then
                                    Distance = mag
                                    NPC = npc
                                end
                            end
                        end
                    end
                    return NPC
                end

                local Enemie = GetProxyNPC()
                if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                    PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                    pcall(function()
                        PlayerClick()
                        ActiveHaki()
                        BringNPC(Enemie)
                    end)
                else
                    -- ถ้าไม่มี NPC วาร์ปไปจุด default
                    PlayerTP(CFrame.new(-9513, 164, 5786))
                end
            end
        end)
    end
})

-- ==================== Auto Mastery All Fighting Styles ====================

if Sea3 then
    QuestsTabs:AddSection({ "Auto Mastery All" })

    -- Slider สำหรับเลือก Max Mastery
    QuestsTabs:AddSlider({
        Name = "Select Mastery",
        Min = 100,
        Max = 600,
        Default = 600,
        Flag = "FMastery/Selected",
        Callback = function(Value)
            getgenv().AutoMasteryValue = Value
        end
    })

    table.insert(AFKOptions, QuestsTabs:AddToggle({
        Name = "Auto Mastery All Fighting Styles",
        Callback = function(Value)
            getgenv().AutoMasteryFightingStyle = Value
            task.spawn(function()
                local MasteryStyles = {
                    "Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman",
                    "Death Step", "Electric Claw", "Sharkman Karate", "Dragon Talon", "Godhuman",
                    "Sanguine Art"
                }

                local function GetProxyNPC()
                    local Distance = math.huge
                    local NPC = nil
                    local plrChar = Player and Player.Character and Player.Character.PrimaryPart
                    for _, npc in pairs(Enemies:GetChildren()) do
                        if npc.Name == "Reborn Skeleton"
                        or npc.Name == "Living Zombie"
                        or npc.Name == "Demonic Soul"
                        or npc.Name == "Posessed Mummy" then
                            if plrChar and npc:FindFirstChild("HumanoidRootPart") then
                                local mag = (plrChar.Position - npc.HumanoidRootPart.Position).Magnitude
                                if mag < Distance then
                                    Distance = mag
                                    NPC = npc
                                end
                            end
                        end
                    end
                    return NPC
                end

                while getgenv().AutoMasteryFightingStyle do task.wait()
                    local MaxMastery = getgenv().AutoMasteryValue or 600

                    -- Loop ผ่านทุกสกิล
                    for _, style in pairs(MasteryStyles) do
                        local lvl = VerifyTool(style) and GetToolLevel(style) or 0
                        if lvl < MaxMastery then
                            if not VerifyTool(style) then
                                if style == "Dragon Claw" then
                                    FireRemote("BlackbeardReward", "DragonClaw", "1")
                                    FireRemote("BlackbeardReward", "DragonClaw", "2")
                                else
                                    BuyFightStyle("Buy"..style:gsub(" ", ""))
                                end
                            else
                                EquipToolName(style)
                            end
                        end
                    end

                    -- ถ้าไม่ใช่ AutoFarm_Level/Bone/Ectoplasm ให้ฟาร์ม NPC
                    if not getgenv().AutoFarm_Level and not getgenv().AutoFarmBone and not getgenv().AutoFarmEctoplasm then
                        local Enemie = GetProxyNPC()
                        if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
                            PlayerTP(Enemie.HumanoidRootPart.CFrame + getgenv().FarmPos)
                            pcall(function()
                                PlayerClick()
                                ActiveHaki()
                                BringNPC(Enemie)
                            end)
                        else
                            -- จุด default ถ้าไม่มี NPC
                            PlayerTP(CFrame.new(-9513, 164, 5786))
                        end
                    end
                end
            end)
        end
    }))
end

