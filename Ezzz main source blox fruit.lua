--// FARM LEFT
local Farm_Left = Tab.Tab_2:addSection()--// LEVEL FARM
local Level_Farm = Farm_Left:addMenu('#Level Farm')
Level_Farm:addToggle('Level Farm Quest', LevelFarmQuest, function(Value)
    LevelFarmQuest = Value
    _G.SelectMonster  = nil
    CancelTween(LevelFarmQuest)
end)
Level_Farm:addToggle('Level Farm No Quest', LevelFarmNoQuest, function(Value)
    LevelFarmNoQuest = Value
    _G.SelectMonster  = nil
    CancelTween(LevelFarmNoQuest)
end)
spawn(function()
    while task.wait() do
        if LevelFarmQuest then
            pcall(function()
                CheckLevel()
                if not 
string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.Q
uestTitle.Title.Text, NameMon) or 
game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false then
game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                    if ByPassTP then
                        BTP(CFrameQ)
                    elseif not ByPassTP then
                        Tween(CFrameQ)
                    end
                    if (CFrameQ.Position - 
game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        wait(1)
game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", 
NameQuest, QuestLv)
                    end
                elseif 
string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.Q
uestTitle.Title.Text, NameMon) or 
game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                    if game:GetService("Workspace").Enemies:FindFirstChild(Ms) then
                        for i,v in 
pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and 
v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                if v.Name == Ms then
                                    repeat 
game:GetService("RunService").Heartbeat:wait()
                                        EquipTool(SelectWeapon)
                                        Tween(v.HumanoidRootPart.CFrame * 
Farm_Mode)
Vector3.new(60,60,60)
v.HumanoidRootPart.CFrame
v.Humanoid.Health <= 0 or not 
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = 
                                        v.HumanoidRootPart.Transparency = 1
                                        Level_Farm_Name = v.Name
                                        Level_Farm_CFrame = 
                                        AutoClick()
                                    until not LevelFarmQuest or not v.Parent or 
game:GetService("Workspace").Enemies:FindFirstChild(v.Name) or 
game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                end
                            end
                        end
                    else
                        Tween(CFrameMon)
                    end
                end
            end)
        end
    end
end)
spawn(function()
    while task.wait() do
        if LevelFarmNoQuest then
            pcall(function()
                CheckLevel()
                if game.Workspace.Enemies:FindFirstChild(Ms) then
                    for i,v in pairs (game.Workspace.Enemies:GetChildren()) do
                        if v.Name == Ms then
                            if v:FindFirstChild("Humanoid") and 
v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat 
game:GetService("RunService").Heartbeat:wait()
                                    EquipTool(SelectWeapon)
                                    Tween(v.HumanoidRootPart.CFrame * Farm_Mode)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                                    v.HumanoidRootPart.Transparency = 1
                                    Level_Farm_Name = v.Name
                                    Level_Farm_CFrame = v.HumanoidRootPart.CFrame
                                    AutoClick()
                                until not LevelFarmNoQuest or not v.Parent or 
v.Humanoid.Health <= 0 or not 
game:GetService("Workspace").Enemies:FindFirstChild(v.Name)
                            end
                        end
                    end
                else
                    if ByPassTP then
                        BTP(CFrameMon)
                    elseif not ByPassTP then
                        Tween(CFrameMon)
                    end
                end
            end)
        end
    end
end)
