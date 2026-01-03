local redzlib =
loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV5/main/
Source.Lua"))()
local Window = redzlib:MakeWindow({
  Title = "redz Hub "redz Hub : Blox Fruits", Fruits",
  SubTitle SubTitle = "by redz9999", redz9999",
  SaveFolder = SaveFolder = "redz Hub "redz Hub | Blox Fruits.lua" Fruits.lua"
})
local AFKOptions = {}
local Discord = Window:MakeTab({"Discord", "Info"})
Discord:AddDiscordInvite({
  Name = "redz Hub | Community", Community",
  Description = Description = "Join our "Join our discord community discord community to receive to receive information about information about the next the next
update",
  Logo = "rbxassetid://15298567397" "rbxassetid://15298567397",
  Invite = "https://discord.gg/7aR7 "https://discord.gg/7aR7kNVt4g" kNVt4g"
})
local MainFarm = Window:MakeTab({"Farm", "Home"})
if Sea3 then
  local AutoSea AutoSea = Window:MakeTab({"Sea", Window:MakeTab({"Sea", "Waves"}) "Waves"})
  AutoSea:AddSection({"Kitsune"})
  local KILabel = KILabel = AutoSea:AddParagraph({"Kit AutoSea:AddParagraph({"Kitsune Island : not spawn"}) spawn"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Auto Kitsune Kitsune Island",Callback = Island",Callback = function(Value) function(Value)
  getgenv().AutoKitsuneIslan getgenv().AutoKitsuneIsland = Value;AutoKitsune Value;AutoKitsuneIsland() Island(   end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Auto Trade Azure Trade Azure Ember",Callback = Ember",Callback = function(Value) function(Value)
  getgenv().TradeAzureEmber getgenv().TradeAzureEmber = Value
  task.spawn(function()
  local Modules Modules = ReplicatedStorage:WaitForCh ReplicatedStorage:WaitForChild("Modules", ild("Modules", 9e9)
  local Net = Modules:WaitForChild("Net" Modules:WaitForChild("Net", 9e9)
  local KitsuneRemote KitsuneRemote = Net:WaitForChild("RF/Kits Net:WaitForChild("RF/KitsuneStatuePray", uneStatuePray", 9e9)
while getgenv().TradeAzureEmber do task.wait(1)
  KitsuneRemote:InvokeServer()
  end
  end)
  end})
  task.spawn(function()
  local Map = workspace:WaitForChild("Map" workspace:WaitForChild("Map", 9e9)
  task.spawn(function()
  while task.wait() task.wait() do
  if Map:FindFirstChild("Kits Map:FindFirstChild("KitsuneIsland") uneIsland") then
  local plrPP = Player.Character Player.Character and Player.Character.PrimaryPar Player.Character.PrimaryPart
  if plrPP then
  Distance Distance = tostring(math.floor((plrPP tostring(math.floor((plrPP.Position .Position -
Map.KitsuneIsland.WorldPivot.p).Magnitude / 3))
  end
  end
  end
  end)
while task.wait() do
  if Map:FindFirstChild("Kitsun Map:FindFirstChild("KitsuneIsland") eIsland") then
  KILabel:SetTitle("Kitsune KILabel:SetTitle("Kitsune Island : Spawned Spawned | Distance Distance : " .. Distance) Distance)
  else   KILabel:SetTitle("Kitsune KILabel:SetTitle("Kitsune Island : not Spawn") Spawn")
  end
  end
  end)
  AutoSea:AddSection({"Sea"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Auto Farm Sea",Callback = Sea",Callback = function(Value) function(Value)
  getgenv().AutoFarmSea getgenv().AutoFarmSea = Value;AutoFarmSea() Value;AutoFarmSea()
  end})
  AutoSea:AddButton({Name = AutoSea:AddButton({Name = "Buy New Boat",Callback = Boat",Callback = function() function()
  BuyNewBoat()
  end})
  AutoSea:AddSection({"Material"})
  AutoSea:AddToggle({"Auto AutoSea:AddToggle({"Auto Wood Planks", Planks", false, function(Value) function(Value)
  getgenv().AutoWoodPlanks getgenv().AutoWoodPlanks = Value
  task.spawn(function()
  local Map = workspace:WaitForChild("Ma workspace:WaitForChild("Map", 9e9)
  local BoatCastle BoatCastle = Map:WaitForChild("Boat Map:WaitForChild("Boat Castle", Castle", 9e9)
local function TreeModel()
  for _,Model _,Model in pairs(BoatCastle["IslandMo pairs(BoatCastle["IslandModel"]:GetChildren()) del"]:GetChildren()) do
  if Model.Name Model.Name == "Model" "Model" and Model:FindFirstChild("Tr Model:FindFirstChild("Tree") then
  return Model
  end
  end
  end
local function GetTree()
  local Tree = TreeModel() TreeModel()   if Tree then
  local Nearest Nearest = math.huge math.huge
  local selected selected
  for _,tree in pairs(Tree:GetChildren()) pairs(Tree:GetChildren()) do
  local plrPP = Player.Character Player.Character and Player.Character.PrimaryP Player.Character.PrimaryPart
  if tree and tree.PrimaryPart tree.PrimaryPart and tree.PrimaryPart.Anchored tree.PrimaryPart.Anchored then
  if plrPP and (plrPP.Position (plrPP.Position - tree.PrimaryPart.Position). tree.PrimaryPart.Position).Magnitude Magnitude <
Nearest then
  Nearest Nearest = (plrPP.Position (plrPP.Position - tree.PrimaryPart.Position).M tree.PrimaryPart.Position).Magnitude agnitude
  selected selected = tree
  end
  end
  end
  return selected selected
  end
  end
local RandomEquip = ""
  task.spawn(function()
  while getgenv().AutoWoodPlanks getgenv().AutoWoodPlanks do
  if VerifyToolTip("Melee") VerifyToolTip("Melee") then
  RandomEquip RandomEquip = "Melee"task.wait(2) "Melee"task.wait(2)
  end
  if VerifyToolTip("Blox VerifyToolTip("Blox Fruit") Fruit") then
  RandomEquip RandomEquip = "Blox Fruit"task.wait(3) Fruit"task.wait(3)
  end
  if VerifyToolTip("Sword") VerifyToolTip("Sword") then
  RandomEquip RandomEquip = "Sword"task.wait(2) "Sword"task.wait(2)
  end
  if VerifyToolTip("Gun") VerifyToolTip("Gun") then
  RandomEquip RandomEquip = "Gun"task.wait(2) "Gun"task.wait(2)   end
  end
  end)
while getgenv().AutoWoodPlanks do task.wait()
  local Tree = GetTree()EquipToolTip(Random GetTree()EquipToolTip(RandomEquip)
if Tree and Tree.PrimaryPart then
  PlayerTP(Tree.PrimaryPart.CFrame)
  local plrPP = Player.Character Player.Character and Player.Character.PrimaryPar Player.Character.PrimaryPart
  if plrPP and (plrPP.Position (plrPP.Position - Tree.PrimaryPart.Position) Tree.PrimaryPart.Position).Magnitude .Magnitude < 10
then
  if getgenv().SeaSkillZ getgenv().SeaSkillZ then
  KeyboardPress("Z")
  end
  if getgenv().SeaSkillX getgenv().SeaSkillX then
  KeyboardPress("X")
  end
  if getgenv().SeaSkillC getgenv().SeaSkillC then
  KeyboardPress("C")
  end
  if getgenv().SeaSkillV getgenv().SeaSkillV then
  KeyboardPress("V")
  end
  if getgenv().SeaSkillF getgenv().SeaSkillF then
  KeyboardPress("F")
  end
  if getgenv().SeaAimBotSkill getgenv().SeaAimBotSkill then   AimBotPart(Tree.PrimaryPart)
  end
  end
  end
  end
  end)
  end})
  AutoSea:AddSection({"Panic AutoSea:AddSection({"Panic Mode"}) Mode"})
  AutoSea:AddSlider({Name = AutoSea:AddSlider({Name = "Select Health",Min "Select Health",Min = 20,Max = 20,Max = 70,Default = 70,Default = 25,Callback = 25,Callback
= function(Value)
  getgenv().HealthPanic getgenv().HealthPanic = Value
  end})
  AutoSea:AddToggle({"Panic AutoSea:AddToggle({"Panic Mode", true, function(Value) function(Value)
  getgenv().PanicMode getgenv().PanicMode = Value
  end, "Sea/PanicMode"}) "Sea/PanicMode"})
  AutoSea:AddSection({"Farm AutoSea:AddSection({"Farm Select"}) Select"})
  AutoSea:AddParagraph({"Fish"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Terrorshark", Flag "Terrorshark", Flag = "Sea/TerrorShark", Default "Sea/TerrorShark", Default =
true,Callback = function(Value)
  getgenv().Terrorshark getgenv().Terrorshark = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Piranha", Flag "Piranha", Flag = "Sea/Piranha", Default "Sea/Piranha", Default =
true,Callback = function(Value)
  getgenv().Piranha getgenv().Piranha = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Fish Crew Member", Flag Member", Flag = "Sea/FishCrewMember", "Sea/FishCrewMember",
Default = true,Callback = function(Value)
  getgenv().FishCrewMember getgenv().FishCrewMember = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Shark", Flag "Shark", Flag = "Sea/Shark", = "Sea/Shark", Default = Default = true,Callback = true,Callback =
function(Value)   getgenv().Shark getgenv().Shark = Value
  end})
  AutoSea:AddParagraph({"Boats"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Pirate Brigade", "Pirate Brigade", Flag = "Sea/PirateBrigade", Default "Sea/PirateBrigade", Default =
true,Callback = function(Value)
  getgenv().PirateBrigade getgenv().PirateBrigade = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Pirate "Pirate Grand Brigade", Brigade", Flag =
"Sea/PirateGrandBrigade", Default = true,Callback = function(Value)
  getgenv().PirateGrandBriga getgenv().PirateGrandBrigade = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Fish Boat", "Fish Boat", Flag = "Sea/FishBoat", Default "Sea/FishBoat", Default =
true,Callback = function(Value)
  getgenv().FishBoat getgenv().FishBoat = Value
  end})
  --[[AddTextLabel(AutoSea, --[[AddTextLabel(AutoSea, {"Sea Beast"}) Beast"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Sea Beast",Default = Beast",Default = true,Callback = true,Callback = function(Value) function(Value)
  getgenv().SeaBeast getgenv().SeaBeast = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Triple Sea "Triple Sea Beast",Default = Beast",Default = true,Callback = true,Callback =
function(Value)
  getgenv().SeaBeastTriple getgenv().SeaBeastTriple = Value
  end})]]
  AutoSea:AddSection({"Skill"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "AimBot Skill "AimBot Skill Enemie", Flag Enemie", Flag = "Mastery/Aimbot", = "Mastery/Aimbot", Default Default
= true,Callback = function(Value)
  getgenv().SeaAimBotSkill getgenv().SeaAimBotSkill = Value
  end})   AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Skill Z", "Skill Z", Flag = "Mastery/Z", Default "Mastery/Z", Default = true,Callback true,Callback
= function(Value)
  getgenv().SeaSkillZ getgenv().SeaSkillZ = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Skill X", "Skill X", Flag = "Mastery/X", Default "Mastery/X", Default = true,Callback true,Callback
= function(Value)
  getgenv().SeaSkillX getgenv().SeaSkillX = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Skill C", "Skill C", Flag = "Mastery/C", Default "Mastery/C", Default = true,Callback true,Callback
= function(Value)
  getgenv().SeaSkillC getgenv().SeaSkillC = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Skill V", "Skill V", Flag = "Mastery/V", Default "Mastery/V", Default = true,Callback true,Callback
= function(Value)
  getgenv().SeaSkillV getgenv().SeaSkillV = Value
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Skill F", "Skill F", Flag = "Mastery/F", Callback "Mastery/F", Callback =
function(Value)
  getgenv().SeaSkillF getgenv().SeaSkillF = Value
  end})
  AutoSea:AddSection({"NPCs"})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Teleport To "Teleport To Shark Hunter",Callback = Hunter",Callback = function(Value) function(Value)
  getgenv().NPCtween getgenv().NPCtween = Value
  task.spawn(function()
  while getgenv().NPCtween getgenv().NPCtween do task.wait() task.wait()
  PlayerTP(CFrame.new(-16526, PlayerTP(CFrame.new(-16526, 108, 752))
  end
  end)
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Teleport To "Teleport To Beast Hunter",Callback = Hunter",Callback = function(Value) function(Value)
  getgenv().NPCtween getgenv().NPCtween = Value   task.spawn(function()
  while getgenv().NPCtween getgenv().NPCtween do task.wait() task.wait()
  PlayerTP(CFrame.new(-16281, PlayerTP(CFrame.new(-16281, 73, 263))
  end
  end)
  end})
  AutoSea:AddToggle({Name = AutoSea:AddToggle({Name = "Teleport "Teleport To Spy",Callback = Spy",Callback = function(Value) function(Value)
  getgenv().NPCtween getgenv().NPCtween = Value
  task.spawn(function()
  while getgenv().NPCtween getgenv().NPCtween do task.wait() task.wait()
  PlayerTP(CFrame.new(-16471, PlayerTP(CFrame.new(-16471, 528, 539))
  end
  end)
  end})
  AutoSea:AddSection({"Configs"})
  AutoSea:AddDropdown({
  Name = "Tween Sea Level", Level",
  Options Options = {"1", "2", "3", "4", "5", "6", "inf"}, "inf"},
  Default Default = {"6"},
  Flag = "Sea/SeaLevel", "Sea/SeaLevel",
  Callback Callback = function(Value) function(Value)
  getgenv().SeaLevelTP getgenv().SeaLevelTP = Value
  end
  })
  AutoSea:AddSlider({
  Name = "Boat Tween Speed", Speed",
  Min = 100,
  Max = 300,   Increase Increase = 10,
  Default Default = 250,
  Flag = "Sea/BoatSpeed", "Sea/BoatSpeed",
  Callback Callback = function(Value) function(Value)
  getgenv().SeaBoatSpeed getgenv().SeaBoatSpeed = Value
  end
  })
end
if Sea3 and IsOwner then
  local MirageTab MirageTab = Window:MakeTab({"Race V4", Window:MakeTab({"Race V4", ""})
MirageTab:AddToggle({"Auto Pull Lever", false, function(Value)
end})
MirageTab:AddToggle({"Auto Stone Puzzle", false, function(Value)
end})
MirageTab:AddSection({"Auto Mirage"})
MirageTab:AddToggle({"Auto Find Mirage", false, function(Value)
end})
MirageTab:AddToggle({"Auto Gear Puzzle", false, function(Value)
  getgenv().AutoMiragePuzzle getgenv().AutoMiragePuzzle = Value
local function GetGear()
end
local function LookToMoon()
  local MoonDirection MoonDirection = Lighting:GetMoonDirection Lighting:GetMoonDirection()
  local LookToPos LookToPos = Camera.CFrame.p Camera.CFrame.p + moonDir moonDir * 100
  Camera.CFrame Camera.CFrame = CFrame.lookAt(Camera.CFrame CFrame.lookAt(Camera.CFrame.p, LookToPos0) LookToPos0)
  end
local Connection = RunService.Heartbeat:Connect(LookToMoon)
  while getgenv().AutoMiragePuzzl getgenv().AutoMiragePuzzle do task.wait()end task.wait()end
  if Connection Connection then
  Connection:Disconnect()
  end
  end})
MirageTab:AddSection({"Auto Race"})
MirageTab:AddToggle({"Auto Finish Trial", false, function(Value)
  getgenv().AutoFinishTrial getgenv().AutoFinishTrial = Value
  task.spawn(function()
  local PlayerRace PlayerRace
  task.spawn(function()
  while getgenv().AutoFinishTrial getgenv().AutoFinishTrial do task.wait() task.wait()
  PlayerRace PlayerRace = Player.Data.Race.Value Player.Data.Race.Value
  end
  end)
while getgenv().AutoFinishTrial do task.wait()
  if PlayerRace PlayerRace and typeof(PlayerRace) typeof(PlayerRace) == "string" "string" then   if PlayerRace PlayerRace == "Cyborg" "Cyborg" then
  PlayerTP(CFrame.new(28654, PlayerTP(CFrame.new(28654, 14898, -30))
  elseif PlayerRace PlayerRace == "Ghoul" "Ghoul" then
  KillAura()
  elseif PlayerRace PlayerRace == "Human" "Human" then
  KillAura()
  elseif PlayerRace PlayerRace == "Mink" then
  for _,part in pairs(workspace:GetDescenda pairs(workspace:GetDescendants()) do
  if part.Name part.Name == "StartPoint" "StartPoint" then
  PlayerTP(part.CFrame)
  end
  end
  elseif PlayerRace PlayerRace == "Skypiea" "Skypiea" then
  pcall(function()
  for _,part in pairs(workspace.Map.SkyTr pairs(workspace.Map.SkyTrial.Model:GetDescendants() ial.Model:GetDescendants()) do
  if part.Name part.Name == "snowisland_Cylinder.081" "snowisland_Cylinder.081" then
  PlayerTP(part.CFrame)
  end
  end
  end)
  end
  end
  end
  end)
  end})
end
local QuestsTabs = Window:MakeTab({"Quests/Items", "Swords"})
local FruitAndRaid = Window:MakeTab({"Fruit/Raid", "Cherry"})
--[[local Informacoes = Window:MakeTab({"Info", "Search"})
Informacoes:AddSection({"Player"})
local Nerd = Informacoes:AddParagraph({"Nerd < Accessories Info >"}) task.spawn(function()
  while task.wait() task.wait() do
  Nerd:SetDesc(FireRemote("Nerd"))
  end
end)]]
if PlayerLevel.Value < MaxLavel then
  local StatsTab StatsTab = Window:MakeTab({"Stats", "signal"}) Window:MakeTab({"Stats", "signal"})
  local PointsSlider, local PointsSlider, Melee, Defense, Melee, Defense, Sword, Gun, Sword, Gun, DemonFruit = DemonFruit = 1
local function AutoStats()
  local function function AddStats(Stats) AddStats(Stats)
  if Player.Data.Points.Value Player.Data.Points.Value >= 1 then
  local Points = math.clamp(PointsSlider, math.clamp(PointsSlider, 1, Player.Data.Points.Value) Player.Data.Points.Value)
  FireRemote("AddPoint", FireRemote("AddPoint", Stats, Points) Points)
end
  end
while getgenv().AutoStats do task.wait()
  if Melee then
  AddStats("Melee")
  end
  if Defense Defense then
  AddStats("Defense")
  end
  if Sword then
  AddStats("Sword")
  end
  if Gun then   AddStats("Gun")
  end
  if DemonFruit DemonFruit then
  AddStats("Demon AddStats("Demon Fruit") Fruit")
  end
  end
  end
StatsTab:AddToggle({
  Name = "Auto Stats", Stats",
  Flag = "Stats/AutoStats", "Stats/AutoStats",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoStats getgenv().AutoStats = Value
  AutoStats()
  end
  })
StatsTab:AddSlider({
  Name = "Select "Select Points", Points",
  Flag = "Stats/SelectPoints", "Stats/SelectPoints",
  Min = 1,
  Max = 100,
  Increase Increase = 1,
  Default Default = 1,
  Callback Callback = function(Value) function(Value)
  PointsSlider PointsSlider = Value
  end
  })
StatsTab:AddSection({"Select Stats"})
StatsTab:AddToggle({Name = "Melee", Flag = "Stats/SelectMelee", Callback =
function(Value)
  Melee = Value
  end})
  StatsTab:AddToggle({Name = StatsTab:AddToggle({Name = "Defense", Flag "Defense", Flag = "Stats/SelectDefense", Callback "Stats/SelectDefense", Callback =
function(Value)
  Defense Defense = Value
  end})
  StatsTab:AddToggle({Name = StatsTab:AddToggle({Name = "Sword", Flag "Sword", Flag = "Stats/SelectSword", Callback "Stats/SelectSword", Callback =
function(Value)
  Sword = Value
  end})
  StatsTab:AddToggle({Name = StatsTab:AddToggle({Name = "Gun", Flag "Gun", Flag = "Stats/SelectGun", Callback "Stats/SelectGun", Callback =
function(Value)
  Gun = Value
  end})
  StatsTab:AddToggle({Name = StatsTab:AddToggle({Name = "Demon Fruit", Fruit", Flag = "Stats/SelectDemonFruit", "Stats/SelectDemonFruit",
Callback = function(Value)
  DemonFruit DemonFruit = Value
  end})
end
local Teleport = Window:MakeTab({"Teleport", "Locate"})
local Visual = Window:MakeTab({"Visual", "User"})
local Shop = Window:MakeTab({"Shop", "ShoppingCart"})
local Misc = Window:MakeTab({"Misc", "Settings"})
MainFarm:AddDropdown({
  Name = "Farm Tool",   Options Options = {"Melee", {"Melee", "Sword", "Sword", "Blox Fruit"}, Fruit"},
  Default Default = {"Melee"}, {"Melee"},
  Flag = "Main/FarmTool", "Main/FarmTool",
  Callback Callback = function(Value) function(Value)
  getgenv().FarmTool getgenv().FarmTool = Value
  end
})
if PlayerLevel.Value >= MaxLavel and Sea3 then
  MainFarm:AddToggle({
  Name = "Start Multi Farm < BETA >",
  Callback Callback = function(Value) function(Value)
  table.foreach(AFKOptions table.foreach(AFKOptions, function(_,Val) function(_,Val)
  task.spawn(function()
  Val:Set(Value)
  end)
  end)
  end
  })
end
MainFarm:AddSection({"Farm"})
MainFarm:AddToggle({"Auto Farm Level", false, function(Value)
  getgenv().AutoFarm_Level getgenv().AutoFarm_Level = Value;AutoFarm_Level() Value;AutoFarm_Level()
end, Description = "Lavel Farm"})
MainFarm:AddToggle({"Auto Farm Nearest", false, function(Value)
  getgenv().AutoFarmNearest getgenv().AutoFarmNearest = Value;AutoFarmNearest Value;AutoFarmNearest()
end})
if Sea3 then
  table.insert(AFKOptions, table.insert(AFKOptions, MainFarm:AddToggle({"Auto MainFarm:AddToggle({"Auto Pirates Pirates Sea", false,
function(Value)
  getgenv().AutoPiratesSea getgenv().AutoPiratesSea = Value;AutoPiratesSea() Value;AutoPiratesSea()
  end}))
elseif Sea2 then
  MainFarm:AddToggle({"Auto MainFarm:AddToggle({"Auto Factory", Factory", false, function(Value) function(Value)
  getgenv().AutoFactory getgenv().AutoFactory = Value;AutoFactory() Value;AutoFactory()
  end})
end
--[[MainFarm:AddSection({"Christmas"})
local TimeLabel = MainFarm:AddLabel({"Text", "Time for next gift : nil"})
task.spawn(function()
  local Counter Counter = workspace:WaitForChild("Co workspace:WaitForChild("Countdown", untdown", 9e9)
  local SurfaceGui SurfaceGui = Counter:WaitForChild("Surfac Counter:WaitForChild("SurfaceGui", 9e9)
  local TextLabel TextLabel = SurfaceGui:WaitForChild( SurfaceGui:WaitForChild("TextLabel", "TextLabel", 9e9)
while task.wait() do
  TimeLabel:SetTitle("Time TimeLabel:SetTitle("Time to Next gift : " .. TextLabel.Text) TextLabel.Text)
if TextLabel.Text ~= "STARTING!" then
  local TimerL, TimerL, Timer = TextLabel.Text:split(":") TextLabel.Text:split(":"), 0
  if tonumber(TimerL[2]) tonumber(TimerL[2]) >= 1 then
  Timer = tonumber(TimerL[2]) tonumber(TimerL[2]) * 60
  end   Timer = Timer + tonumber(TimerL[3]) tonumber(TimerL[3])
getgenv().TimeToGift = Timer
  else
  getgenv().TimeToGift getgenv().TimeToGift = 0
  end
  end
end)
if PlayerLevel.Value >= MaxLavel and Sea3 then
  MainFarm:AddToggle({"Auto MainFarm:AddToggle({"Auto Farm Candy", Candy", false, function(Value) function(Value)
  getgenv().AutoCandy getgenv().AutoCandy = Value
  task.spawn(function()
  local Enemies1 Enemies1 = workspace:WaitForChild("En workspace:WaitForChild("Enemies", emies", 9e9)
  local Enemies2 Enemies2 = ReplicatedStorage ReplicatedStorage
local function GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies1:GetChildren()) do
  if npc.Name npc.Name == "Isle Champion" Champion" or npc.Name npc.Name == "Sun-kissed "Sun-kissed Warrior" Warrior" or
npc.Name == "Island Boy" or npc.Name == "Isle Outlaw" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humanoid npc:FindFirstChild("HumanoidRootPart") RootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end end
  end
  for _,npc in pairs(Enemies2:GetChildren() pairs(Enemies2:GetChildren()) do
  if npc.Name npc.Name == "Isle Champion" Champion" or npc.Name npc.Name == "Sun-kissed "Sun-kissed Warrior" Warrior" or
npc.Name == "Island Boy" or npc.Name == "Isle Outlaw" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humanoid npc:FindFirstChild("HumanoidRootPart") RootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end
  return NPC
  end
while getgenv().AutoCandy do task.wait()
  if Configure("Candy") Configure("Candy") then
  else
  local Enemie = GetProxyNPC() GetProxyNPC()
  if Enemie then
  PlayerTP(Enemie.HumanoidRoot PlayerTP(Enemie.HumanoidRootPart.CFrame Part.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()EquipTool()BringNPC(Enemie,
true)end)
  end
  end
  end
  end)   end})
end
MainFarm:AddToggle({"Auto Gift", false, function(Value)
  getgenv().AutoGift getgenv().AutoGift = Value
  task.spawn(function()
  local function function GetGift() GetGift()
  for _,part in pairs(workspace["_WorldO pairs(workspace["_WorldOrigin"]:GetChildren()) rigin"]:GetChildren()) do
  if part.Name part.Name == "Present" "Present" then
  if part:FindFirstChild("Box") part:FindFirstChild("Box") and
part.Box:FindFirstChild("ProximityPrompt") then
  return part, part.Box.ProximityPrompt part.Box.ProximityPrompt
  end
  end
  end
  end
while getgenv().AutoGift do task.wait()
  local Gift, Prompt = GetGift() GetGift()
if Gift and Gift.PrimaryPart then
  PlayerTP(Gift.PrimaryPart.CFrame)
  if Prompt then
  fireproximityprompt(Prompt)
  end
  elseif getgenv().TimeToGift getgenv().TimeToGift < 90 then
  if Sea3 then
  PlayerTP(CFrame.new(-1076 PlayerTP(CFrame.new(-1076, 14, -14437)) -14437))
  elseif Sea2 then
  PlayerTP(CFrame.new(-5219 PlayerTP(CFrame.new(-5219, 15, 1532))
  elseif Sea1 then   PlayerTP(CFrame.new(1007, PlayerTP(CFrame.new(1007, 15, -3805)) -3805))
  end
  end
  end
  end)
end})]]
if Sea3 then
  MainFarm:AddSection({"Bone"})
table.insert(AFKOptions, MainFarm:AddToggle({
  Name = "Auto Farm Bone",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmBone getgenv().AutoFarmBone = Value
  AutoFarmBone()
  end
  }))
table.insert(AFKOptions, MainFarm:AddToggle({
  Name = "Auto Hallow Scythe", Scythe",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSoulReaper getgenv().AutoSoulReaper = Value
  AutoSoulReaper()
  end
  }))
table.insert(AFKOptions, MainFarm:AddToggle({
  Name = "Auto Trade Bone",   Callback Callback = function(Value) function(Value)
  getgenv().AutoTradeBone getgenv().AutoTradeBone = Value
  while getgenv().AutoTradeBone getgenv().AutoTradeBone do task.wait() task.wait()
  FireRemote("Bones", FireRemote("Bones", "Buy", 1, 1)
  end
  end
  }))
elseif Sea2 then
MainFarm:AddSection({"Ectoplasm"})
MainFarm:AddToggle({
  Name = "Auto Farm Ectoplasm", Ectoplasm",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmEctopl getgenv().AutoFarmEctoplasm = Value
  AutoFarmEctoplasm()
  end
  })
end
MainFarm:AddSection({"Chest"})
MainFarm:AddToggle({
  Name = "Auto Chest < Chest < Tween >",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoChestTween getgenv().AutoChestTween = Value
  AutoChestTween()
  end
})
MainFarm:AddToggle({
  Name = "Auto Chest < Chest < Bypass >", Bypass >",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoChestBypass getgenv().AutoChestBypass = Value
  AutoChestBypass()
  end
})
MainFarm:AddSection({"Bosses"})
MainFarm:AddButton({
  Name = "Update "Update Boss List",
  Callback Callback = function() function()
  pcall(function()UpdateBossList()end)
  end
})
local BossList = MainFarm:AddDropdown({
  Name = "Boss List",
  Callback Callback = function(Value) function(Value)
  getgenv().BossSelected getgenv().BossSelected = Value
  end
})
function UpdateBossList()
  local NewOptions NewOptions = {}
  for ___,NameBoss ___,NameBoss in pairs(BossListT) pairs(BossListT) do
  if VerifyNPC(NameBoss) VerifyNPC(NameBoss) then   table.insert(NewOptions, table.insert(NewOptions, NameBoss) NameBoss)
  end
  end
  BossList:Set(NewOptions, BossList:Set(NewOptions, true)
end
UpdateBossList()
MainFarm:AddToggle({
  Name = "Auto Farm Boss Selected", Selected",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmBossSele getgenv().AutoFarmBossSelected = Value
  AutoFarmBossSelected()
  end
})
MainFarm:AddToggle({
  Name = "Auto Farm All Boss",
  Callback Callback = function(Value) function(Value)
  getgenv().KillAllBosses getgenv().KillAllBosses = Value
  KillAllBosses()
  end
})
MainFarm:AddToggle({
  Name = "Take Quest", Quest",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().TakeQuestBoss getgenv().TakeQuestBoss = Value
  end
})
MainFarm:AddButton({
  Name = "Server "Server HOP",
  Callback Callback = function() function()
  ServerHop()
  end
})
MainFarm:AddSection({"Material"})
local MaterialList = {}
if Sea1 then
  MaterialList MaterialList = {
  "Angel Wings", Wings",
  "Leather "Leather + Scrap Metal", Metal",
  "Magma Ore",
  "Fish Tail"
  }
elseif Sea2 then
  MaterialList MaterialList = {
  "Leather "Leather + Scrap Metal", Metal",
  "Magma Ore",
  "Mystic "Mystic Droplet", Droplet",
  "Radiactive "Radiactive Material", Material",
  "Vampire "Vampire Fang"
  }
elseif Sea3 then
  MaterialList MaterialList = {   "Leather "Leather + Scrap Metal", Metal",
  "Fish Tail",
  "Gunpowder",
  "Mini Tusk",
  "Conjured "Conjured Cocoa", Cocoa",
  "Dragon "Dragon Scale"
  }
end
MainFarm:AddDropdown({
  Name = "Material "Material List",
  Options Options = MaterialList, MaterialList,
  Flag = "Material/Selected", "Material/Selected",
  Callback Callback = function(Value) function(Value)
  getgenv().MaterialSelected getgenv().MaterialSelected = Value
  end
})
MainFarm:AddToggle({
  Name = "Auto Farm Material", Material",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmMaterial getgenv().AutoFarmMaterial = Value
  AutoFarmMaterial()
  end
})
MainFarm:AddSection({"Mastery"})
MainFarm:AddSlider({
  Name = "Select "Select Health", Health",
  Min = 10,   Max = 100,
  Default Default = 25,
  Callback Callback = function(Value) function(Value)
  getgenv().HealthSkill getgenv().HealthSkill = Value
  end
})
MainFarm:AddDropdown({
  Name = "Select "Select Tool",
  Options Options = {"Blox Fruit"}, Fruit"},
  Default Default = {"Blox Fruit"}, Fruit"},
  Callback Callback = function(Value) function(Value)
  getgenv().ToolMastery getgenv().ToolMastery = Value
  end
})
MainFarm:AddToggle({
  Name = "Auto Farm Mastery", Mastery",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmMastery getgenv().AutoFarmMastery = Value
  AutoFarmMastery()
  end
})
MainFarm:AddSection({"Skill"})
MainFarm:AddToggle({
  Name = "AimBot "AimBot Skill Enemie", Enemie",   Flag = "Sea/Aimbot", "Sea/Aimbot",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().AimBotSkill getgenv().AimBotSkill = Value
  end
})
MainFarm:AddToggle({
  Name = "Skill Z",
  Flag = "Sea/Z", "Sea/Z",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().SkillZ getgenv().SkillZ = Value
  end
})
MainFarm:AddToggle({
  Name = "Skill X",
  Flag = "Sea/X", "Sea/X",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().SkillX getgenv().SkillX = Value
  end
})
MainFarm:AddToggle({
  Name = "Skill C",
  Flag = "Sea/C", "Sea/C",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().SkillC getgenv().SkillC = Value   end
})
MainFarm:AddToggle({
  Name = "Skill V",
  Flag = "Sea/V", "Sea/V",
  Default Default = true,
  Callback Callback = function(Value) function(Value)
  getgenv().SkillV getgenv().SkillV = Value
  end
})
MainFarm:AddToggle({
  Name = "Skill F",
  Flag = "Sea/F", "Sea/F",
  Callback Callback = function(Value) function(Value)
  getgenv().SkillF getgenv().SkillF = Value
  end
})
FruitAndRaid:AddSection({"Fruits"})
local Fruit_BlackList = {}
FruitAndRaid:AddToggle({
  Name = "Auto Store Fruits", Fruits",
  Flag = "Fruits/AutoStore", "Fruits/AutoStore",
  Callback Callback = function(Value) function(Value)   getgenv().AutoStoreFruits getgenv().AutoStoreFruits = Value
  task.spawn(function()
  local Remote = ReplicatedStorage:WaitForChi ReplicatedStorage:WaitForChild("Remotes", ld("Remotes",
9e9):WaitForChild("CommF_", 9e9)
while getgenv().AutoStoreFruits do task.wait()
  local plrBag = Player.Backpack Player.Backpack
  local plrChar plrChar = Player.Character Player.Character
  if plrChar plrChar then
  for _,Fruit _,Fruit in pairs(plrChar:GetChildre pairs(plrChar:GetChildren()) do
  if not table.find(Fruit_BlackLis table.find(Fruit_BlackList, Fruit.Name) Fruit.Name) and Fruit:IsA("Tool") Fruit:IsA("Tool")
and Fruit:FindFirstChild("Fruit") then
  if Remote:InvokeServer("StoreF Remote:InvokeServer("StoreFruit", Get_Fruit(Fruit.Name), Get_Fruit(Fruit.Name), Fruit) ~=
true then
  table.insert(Fruit_BlackList table.insert(Fruit_BlackList, Fruit.Name) Fruit.Name)
  end
  end
  end
  end
  for _,Fruit _,Fruit in pairs(plrBag:GetChildren() pairs(plrBag:GetChildren()) do
  if not table.find(Fruit_BlackList, table.find(Fruit_BlackList, Fruit.Name) Fruit.Name) and Fruit:IsA("Tool") Fruit:IsA("Tool") and
Fruit:FindFirstChild("Fruit") then
  if Remote:InvokeServer("Stor Remote:InvokeServer("StoreFruit", eFruit", Get_Fruit(Fruit.Name), Get_Fruit(Fruit.Name), Fruit) ~=
true then
  table.insert(Fruit_BlackLi table.insert(Fruit_BlackList, Fruit.Name) Fruit.Name)
  end
  end
  end
  end
  end)
  end })
table.insert(AFKOptions, FruitAndRaid:AddToggle({
  Name = "Teleport "Teleport to Fruits", Fruits",
  Flag = "Fruits/Teleport", "Fruits/Teleport",
  Callback Callback = function(Value) function(Value)
  getgenv().TeleportToFruit getgenv().TeleportToFruit = Value
  task.spawn(function()
  while getgenv().TeleportToFruit getgenv().TeleportToFruit do task.wait() task.wait()
  if Configure("Fruit") Configure("Fruit") then getgenv().TeleportingToFruit getgenv().TeleportingToFruit = false
  else
  local Fruit = FruitFind() FruitFind()
  if Fruit then
  PlayerTP(Fruit.CFrame)
  getgenv().TeleportingToFruit getgenv().TeleportingToFruit = true
  else
  getgenv().TeleportingToFruit getgenv().TeleportingToFruit = false
  end
  end
  end
  end)
  end
}))
FruitAndRaid:AddToggle({
  Name = "Auto Random Fruit", Fruit",
  Flag = "Fruits/AutoRandom", "Fruits/AutoRandom",
  Callback Callback = function(Value) function(Value)   getgenv().AutoRandomFruit getgenv().AutoRandomFruit = Value
  task.spawn(function()
  while getgenv().AutoRandomFruit getgenv().AutoRandomFruit do task.wait(1) task.wait(1)
  FireRemote("Cousin", FireRemote("Cousin", "Buy")
  end
  end)
  end
})
FruitAndRaid:AddSection({"Raid"})
if Sea1 then FruitAndRaid:AddParagraph({"Only on Sea 2 and 3"})
elseif Sea2 or Sea3 then
  Raids_Chip Raids_Chip = {}
  local Raids = require(ReplicatedStorage.Ra require(ReplicatedStorage.Raids)
table.foreach(Raids.advancedRaids, function(a, b)table.insert(Raids_Chip, b)end)
  table.foreach(Raids.raids, table.foreach(Raids.raids, function(a, function(a, b)table.insert(Raids_Chip, b)table.insert(Raids_Chip, b)end)
FruitAndRaid:AddDropdown({
  Name = "Select "Select Raid",
  Options Options = Raids_Chip, Raids_Chip,
  Flag = "Raid/SelectedChip", "Raid/SelectedChip",
  Callback Callback = function(Value) function(Value)
  getgenv().SelectRaidChip getgenv().SelectRaidChip = Value
  end
  })
FruitAndRaid:AddToggle({
  Name = "Auto Farm Raid",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoFarmRaid getgenv().AutoFarmRaid = Value   task.spawn(function()
  local Islands Islands = workspace:WaitForChild("_ workspace:WaitForChild("_WorldOrigin", WorldOrigin",
9e9):WaitForChild("Locations", 9e9)
local function GetIsland(Island)
  local plrChar plrChar = Player and Player.Character Player.Character
  local plrPP = plrChar plrChar and plrChar.PrimaryPart plrChar.PrimaryPart
for _,island in pairs(Islands:GetChildren()) do
  if island and island.Name island.Name == Island and plrPP and (island.Position (island.Position -
plrPP.Position).Magnitude < 3000 then
  return island
  end
  end
  end
task.spawn(function()
  while getgenv().AutoFarmRaid getgenv().AutoFarmRaid do task.wait(0.5) task.wait(0.5)
  if Configure("Raid") Configure("Raid") then
  else
  FireRemote("Awakener", FireRemote("Awakener", "Check")FireRemote("Awaken "Check")FireRemote("Awakener", "Awaken") "Awaken")
  end
  end
  end)
task.spawn(function()
  while getgenv().AutoFarmRaid getgenv().AutoFarmRaid do task.wait(0.5) task.wait(0.5)
  if getgenv().SelectRaidChip getgenv().SelectRaidChip == "Rumble" "Rumble" then   FireRemote("ThunderGodTalk FireRemote("ThunderGodTalk", true)
  FireRemote("ThunderGodTalk")
  end
  end
  end)
task.spawn(function()
  while getgenv().AutoFarmRaid getgenv().AutoFarmRaid do task.wait() task.wait()
  if Configure("Raid") Configure("Raid") then
  getgenv().FarmingRaid getgenv().FarmingRaid = false
  else
  if Player.PlayerGui.Main.Timer Player.PlayerGui.Main.Timer.Visible .Visible then EquipTool() EquipTool()
  local Island1 Island1 = GetIsland("Island GetIsland("Island 1")
  local Island2 Island2 = GetIsland("Island GetIsland("Island 2")
  local Island3 Island3 = GetIsland("Island GetIsland("Island 3")
  local Island4 Island4 = GetIsland("Island GetIsland("Island 4")
  local Island5 Island5 = GetIsland("Island GetIsland("Island 5")
if Island5 then
  getgenv().FarmingRaid getgenv().FarmingRaid = true
  PlayerTP(Island5.CFrame PlayerTP(Island5.CFrame + Vector3.new(0, Vector3.new(0, 70, 0))
  elseif Island4 Island4 then
  getgenv().FarmingRaid getgenv().FarmingRaid = true
  PlayerTP(Island4.CFrame PlayerTP(Island4.CFrame + Vector3.new(0, Vector3.new(0, 70, 0))
  elseif Island3 Island3 then
  getgenv().FarmingRaid getgenv().FarmingRaid = true
  PlayerTP(Island3.CFrame PlayerTP(Island3.CFrame + Vector3.new(0, Vector3.new(0, 70, 0))
  elseif Island2 Island2 then
  getgenv().FarmingRaid getgenv().FarmingRaid = true
  PlayerTP(Island2.CFrame PlayerTP(Island2.CFrame + Vector3.new(0, Vector3.new(0, 70, 0))
  elseif Island1 Island1 then   getgenv().FarmingRaid getgenv().FarmingRaid = true
  PlayerTP(Island1.CFrame PlayerTP(Island1.CFrame + Vector3.new(0, Vector3.new(0, 70, 0))
  else
  getgenv().FarmingRaid getgenv().FarmingRaid = false
  end
  else
  getgenv().FarmingRaid getgenv().FarmingRaid = false
  end
  end
  end
  end)
while getgenv().AutoFarmRaid do task.wait()
  if Configure("Raid") Configure("Raid") then
  else
  if not Player.PlayerGui.Main.Tim Player.PlayerGui.Main.Timer.Visible er.Visible and VerifyTool("Special VerifyTool("Special
Microchip") then
  if not GetIsland("Island GetIsland("Island 1")
  and not GetIsland("Island GetIsland("Island 2")
  and not GetIsland("Island GetIsland("Island 3")
  and not GetIsland("Island GetIsland("Island 4")
  and not GetIsland("Island GetIsland("Island 5") then
  pcall(function()
  if Sea2 then
fireclickdetector(workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
  repeat task.wait()until task.wait()until GetIsland("Island GetIsland("Island 1")task.wait(1) 1")task.wait(1)
  elseif Sea3 then   fireclickdetector(workspace.Map["Boat
Castle"].RaidSummon2.Button.Main.ClickDetector)
  repeat task.wait()until task.wait()until GetIsland("Island GetIsland("Island 1")task.wait(1) 1")task.wait(1)
  end
  end)
  end
  end
  end
  end
  end)
  getgenv().AutoKillAura getgenv().AutoKillAura = Value
  AutoKillAura()
  end
  })
FruitAndRaid:AddToggle({"Auto Buy Chip", false, function(Value)
  getgenv().AutoBuyChip getgenv().AutoBuyChip = Value
  task.spawn(function()
  while getgenv().AutoBuyChip getgenv().AutoBuyChip do task.wait() task.wait()
  if not VerifyTool("Special VerifyTool("Special Microchip") Microchip") then
  FireRemote("RaidsNpc", FireRemote("RaidsNpc", "Select", "Select", getgenv().SelectRaidChip getgenv().SelectRaidChip)task.wait(1) )task.wait(1)
  end
  end
  end)
  end})
end
if Sea1 then
  QuestsTabs:AddSection({"Seco QuestsTabs:AddSection({"Second Sea"})
QuestsTabs:AddToggle({   Name = "Auto Second Sea",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSecondSea getgenv().AutoSecondSea = Value
  AutoSecondSea()
  end
  })
QuestsTabs:AddSection({"Saber"})
QuestsTabs:AddToggle({
  Name = "Auto Unlock Saber < Level +200 >",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoUnlockSabe getgenv().AutoUnlockSaber = Value
  AutoUnlockSaber()
  end
  })
QuestsTabs:AddSection({"God Boss"})
QuestsTabs:AddToggle({
  Name = "Auto Pole V1",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoEnelBossPo getgenv().AutoEnelBossPole = Value
  AutoEnelBossPole()
  end
  })
QuestsTabs:AddSection({"The Saw"})
QuestsTabs:AddToggle({
  Name = "Auto Saw Sword", Sword",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSawBoss getgenv().AutoSawBoss = Value
  AutoSawBoss()
  end
  })
elseif Sea2 then
  QuestsTabs:AddSection({"Thir QuestsTabs:AddSection({"Third Sea"})
QuestsTabs:AddToggle({
  Name = "Auto Third Sea",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoThirdSea getgenv().AutoThirdSea = Value
  AutoThirdSea()
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Kill Don Swan",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoKillDonSwa getgenv().AutoKillDonSwan = Value
  AutoKillDonSwan()
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Don Swan Hop",
  Callback Callback = function(Value) function(Value)   getgenv().AutoDonSwanHop getgenv().AutoDonSwanHop = Value
  end
  })
QuestsTabs:AddSection({"Bartilo Quest"})
QuestsTabs:AddToggle({
  Name = "Auto Bartilo Bartilo Quest", Quest",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoBartiloQue getgenv().AutoBartiloQuest = Value
  AutoBartiloQuest()
  end
  })
QuestsTabs:AddSection({"Rengoku"})
QuestsTabs:AddToggle({
  Name = "Auto Rengoku", Rengoku",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoRengoku getgenv().AutoRengoku = Value
  AutoRengoku()
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Rengoku Rengoku Hop",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoRengokuHop getgenv().AutoRengokuHop = Value   end
  })
QuestsTabs:AddSection({"Legendary Sword"})
QuestsTabs:AddToggle({"Auto Buy Legendary Sword", false, function(Value)
  getgenv().AutoLegendarySwo getgenv().AutoLegendarySword = Value
  task.spawn(function()
  while getgenv().AutoLegendarySword getgenv().AutoLegendarySword do task.wait(0.5) task.wait(0.5)
  FireRemote("LegendarySwordD FireRemote("LegendarySwordDealer", ealer", "1")
  FireRemote("LegendarySwordD FireRemote("LegendarySwordDealer", ealer", "2")
  FireRemote("LegendarySwordD FireRemote("LegendarySwordDealer", ealer", "3")
  end
  end)
  end, "Buy/LegendarySword",}) "Buy/LegendarySword",})
QuestsTabs:AddToggle({
  Name = "Auto Buy True Triple Katana", Katana",
  Flag = "Buy/TTK", "Buy/TTK",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoTTK getgenv().AutoTTK = Value
  task.spawn(function()
  while getgenv().AutoTTK getgenv().AutoTTK do task.wait() task.wait()
  FireRemote("MysteriousMan FireRemote("MysteriousMan", "1")
  FireRemote("MysteriousMan FireRemote("MysteriousMan", "2")
  end
  end)
  end
  })
QuestsTabs:AddSection({"Race"})
QuestsTabs:AddToggle({
  Name = "Auto Evo Race V2",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoRaceV2 getgenv().AutoRaceV2 = Value
  AutoRaceV2()
  end
  })
QuestsTabs:AddSection({"Cursed Captain"})
QuestsTabs:AddToggle({
  Name = "Auto Cursed Captain", Captain",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoCursedCapt getgenv().AutoCursedCaptain = Value
  AutoCursedCaptain()
  end
  })
QuestsTabs:AddSection({"Dark Beard"})
QuestsTabs:AddToggle({
  Name = "Auto Dark Beard", Beard",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoDarkbeard getgenv().AutoDarkbeard = Value
  AutoDarkbeard()
  end
  })
QuestsTabs:AddSection({"Law"})
QuestsTabs:AddToggle({
  Name = "Auto Buy Law Chip",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoBuyLawChip getgenv().AutoBuyLawChip = Value
  task.spawn(function()
  while getgenv().AutoBuyLawChip getgenv().AutoBuyLawChip do task.wait() task.wait()
  if not VerifyNPC("Order") VerifyNPC("Order") and not VerifyTool("Microchip") VerifyTool("Microchip") then
  FireRemote("BlackbeardRewar FireRemote("BlackbeardReward", "Microchip", "Microchip", "2")
end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Start Law Raid",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoStartLawRa getgenv().AutoStartLawRaid = Value
  task.spawn(function()
  while getgenv().AutoStartLawRaid getgenv().AutoStartLawRaid do task.wait() task.wait()
  if not VerifyNPC("Order") VerifyNPC("Order") and VerifyTool("Microchip") VerifyTool("Microchip") then
  pcall(function()
fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
  end)
end
  end
  end)   end
  })
QuestsTabs:AddToggle({
  Name = "Auto Kill Law Boss",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoKillLawBos getgenv().AutoKillLawBoss = Value
  AutoKillLawBoss()
  end
  })
elseif Sea3 then
  QuestsTabs:AddSection({"Elit QuestsTabs:AddSection({"Elite Hunter"}) Hunter"})
local LabelElite = QuestsTabs:AddParagraph({"Elite Stats : not Spawn"})
  local LabelElit3 = LabelElit3 = QuestsTabs:AddParagraph({"El QuestsTabs:AddParagraph({"Elite Hunter progress : progress : 0"})
task.spawn(function()
  while task.wait() task.wait() do
  if VerifyNPC("Urban") VerifyNPC("Urban") or VerifyNPC("Deandre") VerifyNPC("Deandre") or VerifyNPC("Diablo") VerifyNPC("Diablo") then
  LabelElite:SetTitle("Elite LabelElite:SetTitle("Elite Stats : Spawned") Spawned")
  else
  LabelElite:SetTitle("Elite LabelElite:SetTitle("Elite Stats : not Spawn") Spawn")
  end
  end
  end)
if not IsOwner then   task.spawn(function()
  while task.wait(1) task.wait(1) do
  LabelElit3:SetTitle("Elite LabelElit3:SetTitle("Elite Hunter progress progress : " .. FireRemote("EliteHunter", FireRemote("EliteHunter",
"Progress"))
  end
  end)
  end
table.insert(AFKOptions, QuestsTabs:AddToggle({
  Name = "Auto Elite Hunter", Hunter",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoEliteHunte getgenv().AutoEliteHunter = Value
  AutoEliteHunter()
  end
  }))
table.insert(AFKOptions, QuestsTabs:AddToggle({
  Name = "Auto Collect Collect Yama < Need 30 >",
  Flag = "Collect/Yama", "Collect/Yama",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoCollectYam getgenv().AutoCollectYama = Value
  task.spawn(function()
  while getgenv().AutoCollectYama getgenv().AutoCollectYama do task.wait() task.wait()
  pcall(function()
  if FireRemote("EliteHunter", FireRemote("EliteHunter", "Progress") "Progress") >= 30 then
fireclickdetector(workspace.Map.Waterfall.SealedKatana.Handle.ClickDetector)
  end
  end)
  end
  end)   end
  }))
QuestsTabs:AddToggle({
  Name = "Auto Elite Hunter Hop",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoEliteHunte getgenv().AutoEliteHunterHop = Value
  end
  })
QuestsTabs:AddSection({"Tushita"})
local LabelRipIndra = QuestsTabs:AddParagraph({"Rip Indra Stats : not Spawn"})
task.spawn(function()
  while task.wait(0.5) task.wait(0.5) do
  if VerifyNPC("rip_indra VerifyNPC("rip_indra True Form") then
  LabelRipIndra:SetTitle("Rip LabelRipIndra:SetTitle("Rip Indra Stats : Spawned") Spawned")
  else
  LabelRipIndra:SetTitle("Rip LabelRipIndra:SetTitle("Rip Indra Stats : not Spawn") Spawn")
  end
  end
  end)
QuestsTabs:AddToggle({
  Name = "Auto Tushita", Tushita",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoTushita getgenv().AutoTushita = Value   task.spawn(function()
  local Map = workspace:WaitForChild(" workspace:WaitForChild("Map", 9e9)
  local Turtle = Map:WaitForChild("Turtle", Map:WaitForChild("Turtle", 9e9)
  local QuestTorches QuestTorches = Turtle:WaitForChild("Que Turtle:WaitForChild("QuestTorches", stTorches", 9e9)
local Active1 = false
  local Active2 Active2 = false
  local Active3 Active3 = false
  local Active4 Active4 = false
  local Active5 Active5 = false
while getgenv().AutoTushita do task.wait()
  if not Turtle:FindFirstChild("Tush Turtle:FindFirstChild("TushitaGate") itaGate") then
  local Enemie = Enemies:FindFirstChild("Lo Enemies:FindFirstChild("Longma")
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()EquipTool()end)
  else
  PlayerTP(CFrame.new(-10218 PlayerTP(CFrame.new(-10218, 333, -9444)) -9444))
  end
  elseif VerifyNPC("rip_indra VerifyNPC("rip_indra True Form") then
  if not VerifyTool("Holy VerifyTool("Holy Torch") Torch") then
  PlayerTP(CFrame.new(5152, PlayerTP(CFrame.new(5152, 142, 912))
  else
  local Torch1 = QuestTorches:FindFirstCh QuestTorches:FindFirstChild("Torch1") ild("Torch1")
  local Torch2 = QuestTorches:FindFirstCh QuestTorches:FindFirstChild("Torch2") ild("Torch2")
  local Torch3 = QuestTorches:FindFirstCh QuestTorches:FindFirstChild("Torch3") ild("Torch3")
  local Torch4 = QuestTorches:FindFirstCh QuestTorches:FindFirstChild("Torch4") ild("Torch4")
  local Torch5 = QuestTorches:FindFirstCh QuestTorches:FindFirstChild("Torch5") ild("Torch5")
local args1 = Torch1 and Torch1:FindFirstChild("Particles")
  and Torch1.Particles:FindFirst Torch1.Particles:FindFirstChild("PointLight") Child("PointLight") and not
Torch1.Particles.PointLight.Enabled
  local args2 = Torch2 and Torch2:FindFirstChild("P Torch2:FindFirstChild("Particles") articles")
  and Torch2.Particles:FindFirst Torch2.Particles:FindFirstChild("PointLight") Child("PointLight") and not
Torch2.Particles.PointLight.Enabled
  local args3 = Torch3 and Torch3:FindFirstChild("P Torch3:FindFirstChild("Particles") articles")
  and Torch3.Particles:FindFirst Torch3.Particles:FindFirstChild("PointLight") Child("PointLight") and not
Torch3.Particles.PointLight.Enabled
  local args4 = Torch4 and Torch4:FindFirstChild("P Torch4:FindFirstChild("Particles") articles")
  and Torch4.Particles:FindFirst Torch4.Particles:FindFirstChild("PointLight") Child("PointLight") and not
Torch4.Particles.PointLight.Enabled
  local args5 = Torch5 and Torch5:FindFirstChild("P Torch5:FindFirstChild("Particles") articles")
  and Torch5.Particles:FindFirst Torch5.Particles:FindFirstChild("PointLight") Child("PointLight") and not
Torch5.Particles.PointLight.Enabled
if not Active1 and args1 then
  PlayerTP(Torch1.CFrame)
  elseif not Active2 Active2 and args2 then
  PlayerTP(Torch2.CFrame)Activ PlayerTP(Torch2.CFrame)Active1 = true
  elseif not Active3 Active3 and args3 then
  PlayerTP(Torch3.CFrame)Activ PlayerTP(Torch3.CFrame)Active2 = true
  elseif not Active4 Active4 and args4 then
  PlayerTP(Torch4.CFrame)Activ PlayerTP(Torch4.CFrame)Active3 = true
  elseif not Active5 Active5 and args5 then
  PlayerTP(Torch5.CFrame)Activ PlayerTP(Torch5.CFrame)Active4 = true
  else
  Active5 Active5 = true   end
  end
  else
  if VerifyTool("God's VerifyTool("God's Chalice") Chalice") then
  EquipToolName("God's EquipToolName("God's Chalice") Chalice")
  PlayerTP(CFrame.new(-5561, PlayerTP(CFrame.new(-5561, 314, -2663)) -2663))
  else
  local NPC = "EliteBossVerify"QuestVisib "EliteBossVerify"QuestVisible()
if VerifyQuest("Diablo") then
  NPC = "Diablo" "Diablo"
  elseif VerifyQuest("Deandre") VerifyQuest("Deandre") then
  NPC = "Deandre" "Deandre"
  elseif VerifyQuest("Urban") VerifyQuest("Urban") then
  NPC = "Urban" "Urban"
  else
  task.spawn(function()FireRemote("EliteHunter")end)
  end
local EliteBoss = GetEnemies({NPC})
if EliteBoss and EliteBoss:FindFirstChild("HumanoidRootPart") then
  PlayerTP(EliteBoss.HumanoidR PlayerTP(EliteBoss.HumanoidRootPart.CFrame ootPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()EquipTool()end)
  elseif not VerifyNPC("Deandre") VerifyNPC("Deandre") and not VerifyNPC("Diablo") VerifyNPC("Diablo") and not
VerifyNPC("Urban") then
  if getgenv().AutoTushitaHop getgenv().AutoTushitaHop then
  ServerHop()
  end
  end
  end
end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Tushita Tushita Hop",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoTushitaHop getgenv().AutoTushitaHop = Value
  end
  })
QuestsTabs:AddSection({"Cake Prince + Dough King"})
local CakeLabel = QuestsTabs:AddParagraph({"Stats : 0"})
if not IsOwner then
  task.spawn(function()
  while task.wait(1) task.wait(1) do
  if VerifyNPC("Dough VerifyNPC("Dough King") then
  CakeLabel:SetTitle("Stats CakeLabel:SetTitle("Stats : Spawned Spawned | Dough King")
  elseif VerifyNPC("Cake VerifyNPC("Cake Prince") Prince") then
  CakeLabel:SetTitle("Stats CakeLabel:SetTitle("Stats : Spawned Spawned | Cake Prince") Prince")
  else
  local EnemiesCake EnemiesCake = FireRemote("CakePrinceSpawne FireRemote("CakePrinceSpawner", true)
  CakeLabel:SetTitle("Stats CakeLabel:SetTitle("Stats : " .. string.gsub(tostring(Ene string.gsub(tostring(EnemiesCake), miesCake), "%D",
""))   end
  end
  end)
  end
local CakePrinceToggle = QuestsTabs:AddToggle({"Auto Cake Prince", false,
function(Value)
  getgenv().AutoCakePrince getgenv().AutoCakePrince = Value
  AutoCakePrince()
  end})
local DoughKingToggle = QuestsTabs:AddToggle({"Auto Dough King", false,
function(Value)
  getgenv().AutoDoughKing getgenv().AutoDoughKing = Value
  AutoDoughKing()
  end})
CakePrinceToggle:Callback(function()DoughKingToggle:Set(false)end)
  DoughKingToggle:Callback(function()CakePrinceToggle:Set(false)end)
QuestsTabs:AddSection({"Rip Indra"})
local ActiveButtonToggle = QuestsTabs:AddToggle({"Auto Active Button Haki Color",
false, function(Value)
  getgenv().RipIndraLegendar getgenv().RipIndraLegendaryHaki = Value
  task.spawn(function()
  while getgenv().RipIndraLegendaryH getgenv().RipIndraLegendaryHaki do task.wait() task.wait()
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
  if (plrChar.Position (plrChar.Position - Vector3.new(-5415, Vector3.new(-5415, 314, -2212)).Magnitude -2212)).Magnitude < 5 then
  FireRemote("activateColor FireRemote("activateColor", "Pure Red")
  elseif (plrChar.Position (plrChar.Position - Vector3.new(-4972, Vector3.new(-4972, 336, -3720)).Magnitude -3720)).Magnitude < 5
then
  FireRemote("activateColor FireRemote("activateColor", "Snow White") White")
  elseif (plrChar.Position (plrChar.Position - Vector3.new(-5420, Vector3.new(-5420, 1089, -2667)).Magnitude -2667)).Magnitude < 5
then
  FireRemote("activateColor FireRemote("activateColor", "Winter "Winter Sky")
  end
  end
  end)
task.spawn(function()
  while getgenv().RipIndraLegendaryH getgenv().RipIndraLegendaryHaki do task.wait() task.wait()
  if not getgenv().AutoFarm_Level getgenv().AutoFarm_Level and not getgenv().AutoFarmBone getgenv().AutoFarmBone and not
getgenv().AutoCakePrince then
  if GetButton() GetButton() then
  PlayerTP(GetButton().CFrame)
  elseif not GetButton() GetButton() and not getgenv().AutoRipIndra getgenv().AutoRipIndra then
  PlayerTP(CFrame.new(-5119, PlayerTP(CFrame.new(-5119, 315, -2964)) -2964))
  end
  end
  end
  end)
  end})
local RipIndraToggle = QuestsTabs:AddToggle({"Auto Rip Indra", false,
function(Value)
  getgenv().AutoRipIndra getgenv().AutoRipIndra = Value
  AutoRipIndra()   end})
RipIndraToggle:Callback(function()ActiveButtonToggle:Set(false)end)
  ActiveButtonToggle:Callback(function()RipIndraToggle:Set(false)end)
--[[QuestsTabs:AddSection({"Ken Haki"})
QuestsTabs:AddToggle({
  Name = "Auto Ken Haki V2",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoKenV2 getgenv().AutoKenV2 = Value
  AutoKenV2()
  end
  })]]
QuestsTabs:AddSection({"Musketeer Hat"})
QuestsTabs:AddToggle({
  Name = "Auto Musketeer Musketeer Hat",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoMusketeerH getgenv().AutoMusketeerHat = Value
  AutoMusketeerHat()
  end
  })
QuestsTabs:AddButton({
  Name = "Server "Server HOP",
  Callback Callback = function() function()
  ServerHop()
  end
  })
end
if Sea2 or Sea3 then
  QuestsTabs:AddSection({"Figh QuestsTabs:AddSection({"Fighting Style"}) Style"})
QuestsTabs:AddToggle({
  Name = "Auto Death Step",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoDeathStep getgenv().AutoDeathStep = Value
  task.spawn(function()
  local MasteryBlackLeg MasteryBlackLeg = 0
  local KeyFind KeyFind = false
local function GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water
Fighter" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc   end
  end
  end
  return NPC
  end
while getgenv().AutoDeathStep do task.wait()
  if VerifyTool("Black VerifyTool("Black Leg") then
  MasteryBlackLeg MasteryBlackLeg = GetToolLevel("Black GetToolLevel("Black Leg")
  end
if MasteryBlackLeg >= 400 and Sea3 then
  FireRemote("TravelDressrosa")
  end
if KeyFind then
  FireRemote("BuyDeathStep")
  end
if VerifyTool("Death Step") then
  EquipToolName("Death EquipToolName("Death Step")
  elseif MasteryBlackLeg MasteryBlackLeg >= 400 then
  local Enemie = Enemies:FindFirstChild("Aw Enemies:FindFirstChild("Awakened Ice Admiral") Admiral")
if VerifyTool("Library Key") then
  KeyFind KeyFind = true
  EquipToolName("Library EquipToolName("Library Key")
  PlayerTP(CFrame.new(6373, PlayerTP(CFrame.new(6373, 293, -6839)) -6839))
  elseif Enemie and Enemie:FindFirstChild("Human Enemie:FindFirstChild("HumanoidRootPart") oidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()EquipTool()end)
  else
  PlayerTP(CFrame.new(6473, PlayerTP(CFrame.new(6473, 297, -6944)) -6944))
  end
  elseif not VerifyTool("Black VerifyTool("Black Leg") and MasteryBlackLeg MasteryBlackLeg < 400 then
  FireRemote("BuyBlackLeg")
  elseif VerifyTool("Black VerifyTool("Black Leg") and MasteryBlackLeg MasteryBlackLeg < 400 then
  EquipToolName("Black EquipToolName("Black Leg")
local Enemie = GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  if Sea3 then
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  else
  PlayerTP(CFrame.new(-3350, PlayerTP(CFrame.new(-3350, 282, -10527)) -10527))
  end
  end
  end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Electric Electric Claw <BETA>", <BETA>",   Callback Callback = function(Value) function(Value)
  getgenv().AutoElectricCl getgenv().AutoElectricClaw = Value
  task.spawn(function()
  local MasteryElectro MasteryElectro = 0
  local MasteryElectricClaw MasteryElectricClaw = 0
local function GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water
Fighter" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end
  return NPC
  end
while getgenv().AutoElectricClaw do task.wait()
  if VerifyTool("Electro") VerifyTool("Electro") then
  MasteryElectro MasteryElectro = GetToolLevel("Electro") GetToolLevel("Electro")
  elseif VerifyTool("Electric VerifyTool("Electric Claw") then
  MasteryElectricClaw MasteryElectricClaw = GetToolLevel("Electric GetToolLevel("Electric Claw")
  end
if MasteryElectro < 400 then
  if not VerifyTool("Electro") VerifyTool("Electro") then
  FireRemote("BuyElectro")
  else
  EquipToolName("Electro")
  end
  elseif MasteryElectricClaw MasteryElectricClaw < 600 then
  if not VerifyTool("Electric VerifyTool("Electric Claw") then
  FireRemote("BuyElectricClaw")
  else
  EquipToolName("Electric EquipToolName("Electric Claw")
  end
  end
local Enemie = GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRoot PlayerTP(Enemie.HumanoidRootPart.CFrame Part.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  if Sea3 then
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  else
  PlayerTP(CFrame.new(-3350, PlayerTP(CFrame.new(-3350, 282, -10527)) -10527))
  end end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Sharkman Sharkman Karate", Karate",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSharkmanKa getgenv().AutoSharkmanKarate = Value
  task.spawn(function()
  local MasteryFishmanKarate MasteryFishmanKarate = 0
  local MasterySharkmanKarate MasterySharkmanKarate = 0
  local SharkmanStats SharkmanStats = 0
task.spawn(function()
  while getgenv().AutoSharkmanKarate getgenv().AutoSharkmanKarate do task.wait() task.wait()
  SharkmanStats SharkmanStats = FireRemote("BuySharkmanKa FireRemote("BuySharkmanKarate", true)
  end
  end)
while getgenv().AutoSharkmanKarate do task.wait()
  if VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") then
  MasteryFishmanKarate MasteryFishmanKarate = GetToolLevel("Fishman GetToolLevel("Fishman Karate") Karate")
  elseif VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  MasterySharkmanKarate MasterySharkmanKarate = GetToolLevel("Sharkman GetToolLevel("Sharkman Karate") Karate")
  end
if SharkmanStats == 1 then
  FireRemote("BuySharkmanKarate")
  elseif VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  EquipToolName("Sharkman EquipToolName("Sharkman Karate") Karate")
  local Enemie = Enemies:FindFirstChild("Wa Enemies:FindFirstChild("Water Fighter") Fighter")
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClic pcall(function()PlayerClick()ActiveHaki()BringNPC(E k()ActiveHaki()BringNPC(Enemie, true)end) true)end)
  else
  TweenNPCSpawn({CFrame.new( TweenNPCSpawn({CFrame.new(-3339, 290, -10412), -10412), CFrame.new(-3518, CFrame.new(-3518, 290,
-10419), CFrame.new(-3536, 290, -10607), CFrame.new(-3345, 280, -10667)}, "Water
Fighter")
  end
  elseif VerifyTool("Water VerifyTool("Water Key") and MasteryFishmanKarate MasteryFishmanKarate >= 400 then
  FireRemote("BuySharkmanKarat FireRemote("BuySharkmanKarate", true)
  elseif not VerifyTool("Water VerifyTool("Water Key") and MasteryFishmanKarate MasteryFishmanKarate >= 400 then
  local Enemie = Enemies:FindFirstChild("Wa Enemies:FindFirstChild("Water Fighter") Fighter")
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()EquipTool()BringNPC(Enemie,
true)end)
  else
  TweenNPCSpawn({CFrame.new( TweenNPCSpawn({CFrame.new(-3339, 290, -10412), -10412), CFrame.new(-3518, CFrame.new(-3518, 290,
-10419), CFrame.new(-3536, 290, -10607), CFrame.new(-3345, 280, -10667)}, "Water
Fighter")
  end
  elseif not VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") and MasteryFishmanKarate MasteryFishmanKarate < 400
then
  FireRemote("BuyFishmanKarate")   elseif VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") and MasteryFishmanKarate MasteryFishmanKarate < 400 then
  EquipToolName("Fishman EquipToolName("Fishman Karate") Karate")
  local Enemie = Enemies:FindFirstChild("Wa Enemies:FindFirstChild("Water Fighter") Fighter")
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClic pcall(function()PlayerClick()ActiveHaki()BringNPC(E k()ActiveHaki()BringNPC(Enemie, true)end) true)end)
  else
  TweenNPCSpawn({CFrame.new( TweenNPCSpawn({CFrame.new(-3339, 290, -10412), -10412), CFrame.new(-3518, CFrame.new(-3518, 290,
-10419), CFrame.new(-3536, 290, -10607),CFrame.new(-3345, 280, -10667)}, "Water
Fighter")
  end
  end
  end
  end)   end
  })
QuestsTabs:AddToggle({
  Name = "Auto Dragon Talon", Talon",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoDragonTalo getgenv().AutoDragonTalon = Value
  task.spawn(function()
  local MasteryDragonClaw MasteryDragonClaw = 0
  local FireEssence FireEssence = false
local function GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water
Fighter" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end
  return NPC
  end
task.spawn(function()
  while getgenv().AutoDragonTalon getgenv().AutoDragonTalon do task.wait() task.wait()
  if not VerifyTool("Fire VerifyTool("Fire Essence") Essence") then
  FireRemote("Bones", FireRemote("Bones", "Buy", 1, 1)
  else
  FireRemote("BuyDragonTalon FireRemote("BuyDragonTalon", true)
  FireEssence FireEssence = true
  end
  end
  end)
while getgenv().AutoDragonTalon do task.wait()
  if VerifyTool("Dragon VerifyTool("Dragon Claw") then
  MasteryDragonClaw MasteryDragonClaw = GetToolLevel("Dragon GetToolLevel("Dragon Claw")
  end
if MasteryDragonClaw >= 400 and Sea2 then
  FireRemote("TravelZou")
  end
if FireEssence and MasteryDragonClaw >= 400 then
  FireRemote("BuyDragonTalon")
  elseif not VerifyTool("Dragon VerifyTool("Dragon Claw") and MasteryDragonClaw MasteryDragonClaw < 400 or not
FireEssence and not VerifyTool("Dragon Claw") then
  FireRemote("BlackbeardReward FireRemote("BlackbeardReward", "DragonClaw", "DragonClaw", "1")
  FireRemote("BlackbeardReward FireRemote("BlackbeardReward", "DragonClaw", "DragonClaw", "2")
FireEssence and VerifyTool("Dragon Claw") then   elseif VerifyTool("Dragon VerifyTool("Dragon Claw") and MasteryDragonClaw MasteryDragonClaw < 400 or not
  EquipToolName("Dragon EquipToolName("Dragon Claw")
local Enemie = GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  if Sea3 then
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  else
  PlayerTP(CFrame.new(-3350, PlayerTP(CFrame.new(-3350, 282, -10527)) -10527))
  end
  end
  end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Superhuman", Superhuman",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSuperhuman getgenv().AutoSuperhuman = Value
  task.spawn(function()
  local MasteryBlackLeg MasteryBlackLeg = 0
  local MasteryElectro MasteryElectro = 0
  local MasteryFishmanKarate MasteryFishmanKarate = 0
  local MasteryDragonClaw MasteryDragonClaw = 0
  local MasterySuperhuman MasterySuperhuman = 0
local function GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" or npc.Name == "Water
Fighter" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end
  return NPC
  end
while getgenv().AutoSuperhuman do task.wait()
  if VerifyTool("Black VerifyTool("Black Leg") then
  MasteryBlackLeg MasteryBlackLeg = GetToolLevel("Black GetToolLevel("Black Leg")
  elseif VerifyTool("Electro") VerifyTool("Electro") then
  MasteryElectro MasteryElectro = GetToolLevel("Electro") GetToolLevel("Electro")
  elseif   MasteryFishmanKarate elseif VerifyTool("Fishman MasteryFishmanKarate = GetToolLevel("Fishman VerifyTool("Fishman Karate") GetToolLevel("Fishman Karate") Karate") then Karate")
  elseif VerifyTool("Dragon VerifyTool("Dragon Claw") then
  MasteryDragonClaw MasteryDragonClaw = GetToolLevel("Dragon GetToolLevel("Dragon Claw")
  elseif VerifyTool("Superhuman") VerifyTool("Superhuman") then
  MasterySuperhuman MasterySuperhuman = GetToolLevel("Superhuman") GetToolLevel("Superhuman")
  end
if MasteryBlackLeg < 300 then
  if not VerifyTool("Black VerifyTool("Black Leg") then
  FireRemote("BuyBlackLeg")
  else
  EquipToolName("Black EquipToolName("Black Leg")
  end
  elseif MasteryElectro MasteryElectro < 300 then
  if not VerifyTool("Electro") VerifyTool("Electro") then
  FireRemote("BuyElectro")
  else
  EquipToolName("Electro")
  end
  elseif MasteryFishmanKarate MasteryFishmanKarate < 300 then
  if not VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") then
  FireRemote("BuyFishmanKarate")
  else
  EquipToolName("Fishman EquipToolName("Fishman Karate") Karate")
  end
  elseif MasteryDragonClaw MasteryDragonClaw < 300 then
  if not VerifyTool("Dragon VerifyTool("Dragon Claw") then
  FireRemote("BlackbeardReward","DragonClaw","1")
  FireRemote("BlackbeardReward","DragonClaw","2")
  else
  EquipToolName("Dragon EquipToolName("Dragon Claw")
  end
  elseif MasterySuperhuman MasterySuperhuman < 600 then
  if not VerifyTool("Superhuman") VerifyTool("Superhuman") then
  FireRemote("BuySuperhuman")
  else
  EquipToolName("Superhuman")
  end
  end
local Enemie = GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRoot PlayerTP(Enemie.HumanoidRootPart.CFrame Part.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  if Sea3 then
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  else
  PlayerTP(CFrame.new(-3350, PlayerTP(CFrame.new(-3350, 282, -10527)) -10527))
  end
  end
  end
  end)
  end
  })
QuestsTabs:AddToggle({
  Callback   Name Callback = function(Value) Name = "Auto God function(Value) God Human", Human",
  getgenv().AutoGodHuman getgenv().AutoGodHuman = Value
  task.spawn(function()
  local function function GetProxyNPC() GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end
  return NPC
  end
-- V1
  local MasteryBlackLeg MasteryBlackLeg = 0
  local MasteryElectro MasteryElectro = 0
  local MasteryFishmanKarate MasteryFishmanKarate = 0
  local MasteryDragonClaw MasteryDragonClaw = 0
  local MasterySuperhuman MasterySuperhuman = 0
-- V2
  local MasteryElectricClaw MasteryElectricClaw = 0
  local MasteryDragonTalon MasteryDragonTalon = 0
  local MasterySharkmanKarate MasterySharkmanKarate = 0
  local MasteryDeathStep MasteryDeathStep = 0
  local MasteryGodHuman MasteryGodHuman = 0
while getgenv().AutoGodHuman do task.wait()
  if Sea2 then
  FireRemote("TravelZou")
  end
if VerifyTool("Black Leg") then
  MasteryBlackLeg MasteryBlackLeg = GetToolLevel("Black GetToolLevel("Black Leg")
  elseif VerifyTool("Electro") VerifyTool("Electro") then
  MasteryElectro MasteryElectro = GetToolLevel("Electro") GetToolLevel("Electro")
  elseif VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") then
  MasteryFishmanKarate MasteryFishmanKarate = GetToolLevel("Fishman GetToolLevel("Fishman Karate") Karate")
  elseif VerifyTool("Dragon VerifyTool("Dragon Claw") then
  MasteryDragonClaw MasteryDragonClaw = GetToolLevel("Dragon GetToolLevel("Dragon Claw")
  elseif VerifyTool("Superhuman") VerifyTool("Superhuman") then
  MasterySuperhuman MasterySuperhuman = GetToolLevel("Superhuman") GetToolLevel("Superhuman")
  elseif VerifyTool("Death VerifyTool("Death Step") then
  MasteryDeathStep MasteryDeathStep = GetToolLevel("Death GetToolLevel("Death Step")
  elseif VerifyTool("Electric VerifyTool("Electric Claw") then
  MasteryElectricClaw MasteryElectricClaw = GetToolLevel("Electric GetToolLevel("Electric Claw")
  elseif VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  MasterySharkmanKarate MasterySharkmanKarate = GetToolLevel("Sharkman GetToolLevel("Sharkman Karate") Karate")
  MasteryDragonTalon   elseif VerifyTool("Dragon MasteryDragonTalon = GetToolLevel("Dragon VerifyTool("Dragon Talon") GetToolLevel("Dragon Talon") Talon") then Talon")
  elseif VerifyTool("Godhuman") VerifyTool("Godhuman") then
  MasteryGodHuman MasteryGodHuman = GetToolLevel("Godhuman") GetToolLevel("Godhuman")
  end
if MasteryBlackLeg < 400 then
  if not VerifyTool("Black VerifyTool("Black Leg") then
  BuyFightStyle("BuyBlackLeg")
  else
  EquipToolName("Black EquipToolName("Black Leg")
  end
  elseif MasteryElectro MasteryElectro < 400 then
  if not VerifyTool("Electro") VerifyTool("Electro") then
  BuyFightStyle("BuyElectro")
  else
  EquipToolName("Electro")
  end
  elseif MasteryFishmanKarate MasteryFishmanKarate < 400 then
  if not VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") then
  BuyFightStyle("BuyFishmanKarate")
  else
  EquipToolName("Fishman EquipToolName("Fishman Karate") Karate")
  end
  elseif MasteryDragonClaw MasteryDragonClaw < 400 then
  if not VerifyTool("Dragon VerifyTool("Dragon Claw") then
  FireRemote("BlackbeardReward","DragonClaw","1")
  FireRemote("BlackbeardReward","DragonClaw","2")
  else
  EquipToolName("Dragon EquipToolName("Dragon Claw")
  end
  elseif MasterySuperhuman MasterySuperhuman < 400 then
  if not VerifyTool("Superhuman") VerifyTool("Superhuman") then
  BuyFightStyle("BuySuperhuman")
  else
  EquipToolName("Superhuman")
  end
  elseif MasteryDeathStep MasteryDeathStep < 400 then
  if not VerifyTool("Death VerifyTool("Death Step") then
  BuyFightStyle("BuyDeathStep")
  else
  EquipToolName("Death EquipToolName("Death Step")
  end
  elseif MasteryElectricClaw MasteryElectricClaw < 400 then
  if not VerifyTool("Electric VerifyTool("Electric Claw") then
  BuyFightStyle("BuyElectricClaw")
  else
  EquipToolName("Electric EquipToolName("Electric Claw")
  end
  elseif MasterySharkmanKarate MasterySharkmanKarate < 400 then
  if not VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  BuyFightStyle("BuySharkmanKarate")
  else
  EquipToolName("Sharkman EquipToolName("Sharkman Karate") Karate")
  end
  elseif MasteryDragonTalon MasteryDragonTalon < 400 then
  if not VerifyTool("Dragon VerifyTool("Dragon Talon") Talon") then
  BuyFightStyle("BuyDragonTalon")
  else
  EquipToolName("Dragon   endEquipToolName("Dragon Talon") Talon")
  else
  if not VerifyTool("Godhuman") VerifyTool("Godhuman") then
  BuyFightStyle("BuyGodhuman")
  else
  EquipToolName("Godhuman")
  end
  end
local Enemie = GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRoot PlayerTP(Enemie.HumanoidRootPart.CFrame Part.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  end
  end
  end)
  end
  })
end
if Sea3 then
  QuestsTabs:AddSection({"Auto QuestsTabs:AddSection({"Auto Mastery Mastery All"})
QuestsTabs:AddSlider({
  Name = "Select "Select Mastery", Mastery",
  Min = 100,
  Max = 600,
  Default Default = 600,
  Flag = "FMastery/Selected", "FMastery/Selected",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoMasteryVal getgenv().AutoMasteryValue = Value
  end
  })
table.insert(AFKOptions, QuestsTabs:AddToggle({
  Name = "Auto Mastery Mastery All Fighting Fighting Style", Style",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoMasteryFig getgenv().AutoMasteryFightingStyle htingStyle = Value
  task.spawn(function()
  local function function GetProxyNPC() GetProxyNPC()
  local Distance Distance = math.huge math.huge
  local NPC = nil
  local plrChar plrChar = Player and Player.Character Player.Character and
Player.Character.PrimaryPart
for _,npc in pairs(Enemies:GetChildren()) do
  if npc.Name npc.Name == "Reborn "Reborn Skeleton" Skeleton" or npc.Name npc.Name == "Living "Living Zombie" Zombie" or
npc.Name == "Demonic Soul" or npc.Name == "Posessed Mummy" then
  if plrChar plrChar and npc and npc:FindFirstChild("Humano npc:FindFirstChild("HumanoidRootPart") idRootPart") and
(plrChar.Position - npc.HumanoidRootPart.Position).Magnitude <= Distance then
  Distance Distance = (plrChar.Position (plrChar.Position -
npc.HumanoidRootPart.Position).Magnitude
  NPC = npc
  end
  end
  end   return end return NPC
  end
-- V1
  local MasteryBlackLeg MasteryBlackLeg = 0
  local MasteryElectro MasteryElectro = 0
  local MasteryFishmanKarate MasteryFishmanKarate = 0
  local MasteryDragonClaw MasteryDragonClaw = 0
  local MasterySuperhuman MasterySuperhuman = 0
-- V2
  local MasteryElectricClaw MasteryElectricClaw = 0
  local MasteryDragonTalon MasteryDragonTalon = 0
  local MasterySharkmanKarate MasterySharkmanKarate = 0
  local MasteryDeathStep MasteryDeathStep = 0
  local MasteryGodHuman MasteryGodHuman = 0
-- New
  local MasterySanguineArt MasterySanguineArt = 0
while getgenv().AutoMasteryFightingStyle do task.wait()
  local MaxMastery MaxMastery = getgenv().AutoMasteryVal getgenv().AutoMasteryValue
if VerifyTool("Black Leg") then
  MasteryBlackLeg MasteryBlackLeg = GetToolLevel("Black GetToolLevel("Black Leg")
  elseif VerifyTool("Electro") VerifyTool("Electro") then
  MasteryElectro MasteryElectro = GetToolLevel("Electro") GetToolLevel("Electro")
  elseif   MasteryFishmanKarate elseif VerifyTool("Fishman MasteryFishmanKarate = GetToolLevel("Fishman VerifyTool("Fishman Karate") GetToolLevel("Fishman Karate") Karate") then Karate")
  elseif VerifyTool("Dragon VerifyTool("Dragon Claw") then
  MasteryDragonClaw MasteryDragonClaw = GetToolLevel("Dragon GetToolLevel("Dragon Claw")
  elseif VerifyTool("Superhuman") VerifyTool("Superhuman") then
  MasterySuperhuman MasterySuperhuman = GetToolLevel("Superhuman") GetToolLevel("Superhuman")
  elseif VerifyTool("Death VerifyTool("Death Step") then
  MasteryDeathStep MasteryDeathStep = GetToolLevel("Death GetToolLevel("Death Step")
  elseif VerifyTool("Electric VerifyTool("Electric Claw") then
  MasteryElectricClaw MasteryElectricClaw = GetToolLevel("Electric GetToolLevel("Electric Claw")
  elseif VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  MasterySharkmanKarate MasterySharkmanKarate = GetToolLevel("Sharkman GetToolLevel("Sharkman Karate") Karate")
  elseif VerifyTool("Dragon VerifyTool("Dragon Talon") Talon") then
  MasteryDragonTalon MasteryDragonTalon = GetToolLevel("Dragon GetToolLevel("Dragon Talon") Talon")
  elseif VerifyTool("Godhuman") VerifyTool("Godhuman") then
  MasteryGodHuman MasteryGodHuman = GetToolLevel("Godhuman") GetToolLevel("Godhuman")
  elseif VerifyTool("Sanguine VerifyTool("Sanguine Art") then
  MasterySanguineArt MasterySanguineArt = GetToolLevel("Sanguine GetToolLevel("Sanguine Art")
  end
if MasteryBlackLeg < MaxMastery then
  if not VerifyTool("Black VerifyTool("Black Leg") then
  BuyFightStyle("BuyBlackLeg")
  else
  EquipToolName("Black EquipToolName("Black Leg")
  end
  elseif MasteryElectro MasteryElectro < MaxMastery MaxMastery then
  if not VerifyTool("Electro") VerifyTool("Electro") then
  BuyFightStyle("BuyElectro")
  else
  EquipToolName("Electro")
  end   elseif MasteryFishmanKarate MasteryFishmanKarate < MaxMastery MaxMastery then
  if not VerifyTool("Fishman VerifyTool("Fishman Karate") Karate") then
  BuyFightStyle("BuyFishmanKarate")
  else
  EquipToolName("Fishman EquipToolName("Fishman Karate") Karate")
  end
  elseif MasteryDragonClaw MasteryDragonClaw < MaxMastery MaxMastery then
  if not VerifyTool("Dragon VerifyTool("Dragon Claw") then
  FireRemote("BlackbeardReward","DragonClaw","1")
  FireRemote("BlackbeardReward","DragonClaw","2")
  else
  EquipToolName("Dragon EquipToolName("Dragon Claw")
  end
  elseif MasterySuperhuman MasterySuperhuman < MaxMastery MaxMastery then
  if not VerifyTool("Superhuman") VerifyTool("Superhuman") then
  BuyFightStyle("BuySuperhuman")
  else
  EquipToolName("Superhuman")
  end
  elseif MasteryDeathStep MasteryDeathStep < MaxMastery MaxMastery then
  if not VerifyTool("Death VerifyTool("Death Step") then
  BuyFightStyle("BuyDeathStep")
  else
  EquipToolName("Death EquipToolName("Death Step")
  end
  elseif MasteryElectricClaw MasteryElectricClaw < MaxMastery MaxMastery then
  if not VerifyTool("Electric VerifyTool("Electric Claw") then
  BuyFightStyle("BuyElectricClaw")   else
  EquipToolName("Electric EquipToolName("Electric Claw")
  end
  elseif MasterySharkmanKarate MasterySharkmanKarate < MaxMastery MaxMastery then
  if not VerifyTool("Sharkman VerifyTool("Sharkman Karate") Karate") then
  BuyFightStyle("BuySharkmanKarate")
  else
  EquipToolName("Sharkman EquipToolName("Sharkman Karate") Karate")
  end
  elseif MasteryDragonTalon MasteryDragonTalon < MaxMastery MaxMastery then
  if not VerifyTool("Dragon VerifyTool("Dragon Talon") Talon") then
  BuyFightStyle("BuyDragonTalon")
  else
  EquipToolName("Dragon EquipToolName("Dragon Talon") Talon")
  end
  elseif MasteryGodHuman MasteryGodHuman < MaxMastery MaxMastery then
  if not VerifyTool("Godhuman") VerifyTool("Godhuman") then
  BuyFightStyle("BuyGodhuman")
  else
  EquipToolName("Godhuman")
  end
  elseif MasterySanguineArt MasterySanguineArt < MaxMastery MaxMastery then
  if not VerifyTool("Sanguine VerifyTool("Sanguine Art") then
  BuyFightStyle("BuySanguineArt")
  else
  EquipToolName("Sanguine EquipToolName("Sanguine Art")
  end
  end
if not getgenv().AutoFarm_Level and not getgenv().AutoFarmBone and not
getgenv().AutoFarmEctoplasm then   local Enemie = GetProxyNPC() GetProxyNPC()
if Enemie and Enemie:FindFirstChild("HumanoidRootPart") then
  PlayerTP(Enemie.HumanoidRo PlayerTP(Enemie.HumanoidRootPart.CFrame otPart.CFrame + getgenv().FarmPos) getgenv().FarmPos)
  pcall(function()PlayerClick()ActiveHaki()BringNPC(Enemie)end)
  else
  PlayerTP(CFrame.new(-9513, PlayerTP(CFrame.new(-9513, 164, 5786))
  end
  end
  end
  end)
  end
  }))
end
QuestsTabs:AddSection({"Haki Color"})
table.insert(AFKOptions, QuestsTabs:AddToggle({
  Name = "Auto Buy Haki Color", Color",
  Flag = "Buy/HakiColor", "Buy/HakiColor",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoBuyHakiColor getgenv().AutoBuyHakiColor = Value
  task.spawn(function()
  while getgenv().AutoBuyHakiColor getgenv().AutoBuyHakiColor do task.wait(0.5) task.wait(0.5)
  pcall(function()
  FireRemote("ColorsDealer" FireRemote("ColorsDealer", "1")
  FireRemote("ColorsDealer" FireRemote("ColorsDealer", "2")
  end)   end
  end)
  end
}))
if Sea3 then
  QuestsTabs:AddToggle({
  Name = "Auto Rainbow Rainbow Haki",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoRainbowHak getgenv().AutoRainbowHaki = Value
  AutoRainbowHaki()
  end
  })
QuestsTabs:AddToggle({
  Name = "Auto Rainbow Rainbow Haki HOP",
  Callback Callback = function(Value) function(Value)
  getgenv().RainbowHakiHop getgenv().RainbowHakiHop = Value
  end
  })
--[[QuestsTabs:AddSection({"Soul Guitar"})
QuestsTabs:AddToggle({
  Name = "Auto Soul Guitar <Soon>", <Soon>",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoSoulGuitar getgenv().AutoSoulGuitar = Value
  AutoSoulGuitar()
  end
  })]]
--[[QuestsTabs:AddSection({"Cursed Dual Katana"})
QuestsTabs:AddToggle({
  Name = "Auto CDK",
  Callback Callback = function(Value) function(Value)
  getgenv().AutoCursedDual getgenv().AutoCursedDualKatana = Value
  AutoCursedDualKatana()
  end
  })]]
end
Teleport:AddSection({"Teleport to Sea"})
Teleport:AddButton({
  Name = "Teleport "Teleport to Sea 1",
  Callback Callback = function() function()
  FireRemote("TravelMain")
  end
})
Teleport:AddButton({
  Name = "Teleport "Teleport to Sea 2",
  Callback Callback = function() function()
  FireRemote("TravelDressrosa")
  end
})
Teleport:AddButton({   Name = "Teleport "Teleport to Sea 3",
  Callback Callback = function() function()
  FireRemote("TravelZou")
  end
})
Teleport:AddSection({"Islands"})
local IslandsList = {}
if Sea1 then
  IslandsList IslandsList = {
  "WindMill",
  "Marine",
  "Middle "Middle Town",
  "Jungle",
  "Pirate "Pirate Village", Village",
  "Desert",
  "Snow Island", Island",
  "MarineFord",
  "Colosseum",
  "Sky Island 1",
  "Sky Island 2",
  "Sky Island 3",
  "Prison",
  "Magma Village", Village",
  "Under Water Island", Island",
  "Fountain "Fountain City"
  }
elseif Sea2 then
  IslandsList IslandsList = {   "The Cafe",
  "Frist Spot",
  "Dark Area",
  "Flamingo "Flamingo Mansion", Mansion",
  "Flamingo "Flamingo Room",
  "Green Zone",
  "Zombie "Zombie Island", Island",
  "Two Snow Mountain", Mountain",
  "Punk Hazard", Hazard",
  "Cursed "Cursed Ship",
  "Ice Castle", Castle",
  "Forgotten "Forgotten Island", Island",
  "Ussop Island" Island"
  }
elseif Sea3 then
  IslandsList IslandsList = {
  "Mansion",
  "Port Town",
  "Great Tree",
  "Castle "Castle On The Sea",
  "Hydra Island", Island",
  "Floating "Floating Turtle", Turtle",
  "Haunted "Haunted Castle", Castle",
  "Ice Cream Island", Island",
  "Peanut "Peanut Island", Island",
  "Cake Island", Island",
  "Candy Cane Island", Island",
  "Tiki   } "Tiki Outpost" Outpost"
end
Teleport:AddDropdown({
  Name = "Select "Select Island", Island",
  Options Options = IslandsList, IslandsList,
  Default Default = "",
  Callback Callback = function(Value) function(Value)
  getgenv().TeleportIslandSe getgenv().TeleportIslandSelect = Value
  end
})
local TPToggle = Teleport:AddToggle({Name = "Teleport To Island",Callback =
function(Value)
  getgenv().TeleportToIsland getgenv().TeleportToIsland = Value
  task.spawn(function()
  while getgenv().TeleportToIslan getgenv().TeleportToIsland do task.wait() task.wait()
  local Island = getgenv().TeleportIslandSele getgenv().TeleportIslandSelect
  if Sea1 then
  -- Sea 1 Teleports Teleports
  if Island == "Middle "Middle Town" then
  PlayerTP(CFrame.new(-688, PlayerTP(CFrame.new(-688, 15, 1585))
  elseif Island == "MarineFord" "MarineFord" then
  PlayerTP(CFrame.new(-4810 PlayerTP(CFrame.new(-4810, 21, 4359))
  elseif Island == "Marine" "Marine" then
  PlayerTP(CFrame.new(-2728 PlayerTP(CFrame.new(-2728, 25, 2056))
  elseif Island == "WindMill" "WindMill" then
  PlayerTP(CFrame.new(889, PlayerTP(CFrame.new(889, 17, 1434))
  elseif Island == "Desert" "Desert" then
  PlayerTP(CFrame.new())
  elseif Island == "Snow Island" Island" then
  PlayerTP(CFrame.new(1298, PlayerTP(CFrame.new(1298, 87, -1344)) -1344))   elseif Island == "Pirate "Pirate Village" Village" then
  PlayerTP(CFrame.new(-1173 PlayerTP(CFrame.new(-1173, 45, 3837))
  elseif Island == "Jungle" "Jungle" then
  PlayerTP(CFrame.new(-1614 PlayerTP(CFrame.new(-1614, 37, 146))
  elseif Island == "Prison" "Prison" then
  PlayerTP(CFrame.new(4870, PlayerTP(CFrame.new(4870, 6, 736))
  elseif Island == "Under Water Island" Island" then
  PlayerTP(CFrame.new(61164 PlayerTP(CFrame.new(61164, 5, 1820))
  elseif Island == "Colosseum" "Colosseum" then
  PlayerTP(CFrame.new(-1535 PlayerTP(CFrame.new(-1535, 7, -3014)) -3014))
  elseif Island == "Magma Village" Village" then
  PlayerTP(CFrame.new(-5290 PlayerTP(CFrame.new(-5290, 9, 8349))
  elseif Island == "Sky Island 1" then
  PlayerTP(CFrame.new(-4814 PlayerTP(CFrame.new(-4814, 718, -2551)) -2551))
  elseif Island == "Sky Island 2" then
  PlayerTP(CFrame.new(-4652 PlayerTP(CFrame.new(-4652, 873, -1754)) -1754))
  elseif Island == "Sky Island 3" then
  PlayerTP(CFrame.new(-7895 PlayerTP(CFrame.new(-7895, 5547, -380))
  elseif Island == "Fountain "Fountain City" then
  PlayerTP(CFrame.new())
  end
  elseif Sea2 then
  -- Sea 2 Teleports Teleports
  if Island == "The Cafe" then
  PlayerTP(CFrame.new(-382, PlayerTP(CFrame.new(-382, 73, 290))
  elseif Island == "Frist Spot" then
  PlayerTP(CFrame.new(-11, PlayerTP(CFrame.new(-11, 29, 2771))
  elseif   PlayerTP(CFrame.new(3494, elseif Island PlayerTP(CFrame.new(3494, 13, Island == "Dark Area" then 13, -3259)) then-3259))
  elseif Island == "Flamingo "Flamingo Mansion" Mansion" then
  PlayerTP(CFrame.new(-317, PlayerTP(CFrame.new(-317, 331, 597))
  elseif Island == "Flamingo "Flamingo Room" then
  PlayerTP(CFrame.new(2285, PlayerTP(CFrame.new(2285, 15, 905))
  elseif Island == "Green Zone" then
  PlayerTP(CFrame.new(-2258 PlayerTP(CFrame.new(-2258, 73, -2696)) -2696))
  elseif Island == "Zombie "Zombie Island" Island" then
  PlayerTP(CFrame.new(-5552 PlayerTP(CFrame.new(-5552, 194, -776))
  elseif Island == "Two Snow Mountain" Mountain" then
  PlayerTP(CFrame.new(752, PlayerTP(CFrame.new(752, 408, -5277)) -5277))
  elseif Island == "Punk Hazard" Hazard" then
  PlayerTP(CFrame.new(-5897 PlayerTP(CFrame.new(-5897, 18, -5096)) -5096))
  elseif Island == "Cursed "Cursed Ship" then
  PlayerTP(CFrame.new(919, PlayerTP(CFrame.new(919, 125, 32869)) 32869))
  elseif Island == "Ice Castle" Castle" then
  PlayerTP(CFrame.new(5505, PlayerTP(CFrame.new(5505, 40, -6178)) -6178))
  elseif Island == "Forgotten "Forgotten Island" Island" then
  PlayerTP(CFrame.new(-3050 PlayerTP(CFrame.new(-3050, 240, -10178)) -10178))
  elseif Island == "Ussop Island" Island" then
  PlayerTP(CFrame.new(4816, PlayerTP(CFrame.new(4816, 8, 2863))
  end
  elseif Sea3 then
  -- Sea 3 Teleports Teleports
  if Island == "Mansion" "Mansion" then
  PlayerTP(CFrame.new(-1247 PlayerTP(CFrame.new(-12471, 374, -7551)) -7551))
  elseif Island == "Port Town" then
  PlayerTP(CFrame.new(-334, PlayerTP(CFrame.new(-334, 7, 5300))
  elseif Island == "Castle "Castle On The Sea" then
  PlayerTP(CFrame.new(-5073 PlayerTP(CFrame.new(-5073, 315, -3153)) -3153))
  elseif Island == "Hydra Island" Island" then   PlayerTP(CFrame.new(5756, PlayerTP(CFrame.new(5756, 610, -282))
  elseif Island == "Great Tree" then
  PlayerTP(CFrame.new(2681, PlayerTP(CFrame.new(2681, 1682, -7190)) -7190))
  elseif Island == "Floating "Floating Turtle" Turtle" then
  PlayerTP(CFrame.new(-1252 PlayerTP(CFrame.new(-12528, 332, -8658)) -8658))
  elseif Island == "Haunted "Haunted Castle" Castle" then
  PlayerTP(CFrame.new(-9517 PlayerTP(CFrame.new(-9517, 142, 5528))
  elseif Island == "Ice Cream Island" Island" then
  PlayerTP(CFrame.new(-902, PlayerTP(CFrame.new(-902, 79, -10988)) -10988))
  elseif Island == "Peanut "Peanut Island" Island" then
  PlayerTP(CFrame.new(-2062 PlayerTP(CFrame.new(-2062, 50, -10232)) -10232))
  elseif Island == "Cake Island" Island" then
  PlayerTP(CFrame.new(-1897 PlayerTP(CFrame.new(-1897, 14, -11576)) -11576))
  elseif Island == "Candy Cane Island" Island" then
  PlayerTP(CFrame.new(-1038 PlayerTP(CFrame.new(-1038, 10, -14076)) -14076))
  elseif Island == "Tiki Outpost" Outpost" then
  PlayerTP(CFrame.new(-1622 PlayerTP(CFrame.new(-16224, 9, 439))
  end
  end
  end
  end)
end})
TPToggle:Callback(function(Value)
  if Value then
  local Mag = math.huge math.huge
  repeat task.wait() task.wait()
  local   if local plrPP if plrPP then plrPP = Player.Character then Player.Character and Player.Character.PrimaryPa Player.Character.PrimaryPart
  Mag = (plrPP.Position (plrPP.Position - TeleportPos).Magnitude TeleportPos).Magnitude
  end
  until not getgenv().TeleportToIsland getgenv().TeleportToIsland or Mag < 15
  TPToggle:Set(false)
  end
end)
if Sea3 then
  Teleport:AddSection({"Race Teleport:AddSection({"Race V4"})
Teleport:AddButton({"Teleport To Temple of Time", function()
  for i = 1, 5 do task.wait() task.wait()
  Player.Character:SetPrim Player.Character:SetPrimaryPartCFrame(CFrame.new(28 aryPartCFrame(CFrame.new(28286, 14897, 103))
  end
  end})
end
Misc:AddSection({"Join Server"})
local ServerId = ""
Misc:AddTextBox({Name = "Input Job Id",Default = "",PlaceholderText = "Job
ID",Callback = function(Value)
  ServerId ServerId = Value
end})
Misc:AddButton({"Join Server", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/Webhook/main/
BloxFruits.lua"))():Teleport(ServerId)
end})
Misc:AddSection({"Configs"})
Misc:AddSlider({"Farm Distance", 5, 30, 1, 20, function(Value)   getgenv().FarmPos = getgenv().FarmPos = Vector3.new(0, Value Vector3.new(0, Value or 15, Value or
10)getgenv().FarmDistance = Value
end, "Misc/FarmDistance"})
Misc:AddSlider({"Tween Speed", 50, 300, 5, 170, function(Value)
  getgenv().TweenSpeed getgenv().TweenSpeed = Value
end, "Misc/TweenSpeed"})
Misc:AddSlider({"Bring Mobs Distance", 50, 500, 10, 250, function(Value)
  getgenv().BringMobsDistance = getgenv().BringMobsDistance = Value or 250
end, "Misc/BringMobsDistance"})
Misc:AddSlider({"Auto Click Delay", 0.15, 1, 0.01, 0.2, function(Value)
  getgenv().AutoClickDelay getgenv().AutoClickDelay = Value
end, "Misc/AutoClickDelay"})
Misc:AddToggle({"Fast Attack", true, function(Value)
  getgenv().FastAttack getgenv().FastAttack = Value
end, "Misc/FastAttack"})
Misc:AddToggle({"Increase Attack Distance", true, function(Value)
  getgenv().AttackDistance getgenv().AttackDistance = Value
  task.spawn(AttackDistance)
end, "Misc/IncreaseAttackDistance"})
Misc:AddToggle({"Auto Click", true, function(Value)
  getgenv().AutoClick getgenv().AutoClick = Value
end, "Misc/AutoClick"})
Misc:AddToggle({"Bring Mobs", true, function(Value)
  getgenv().BringMobs getgenv().BringMobs = Value
end, "Misc/BringMobs"})
Misc:AddToggle({"Auto Haki", true, function(Value)
  getgenv().AutoHaki getgenv().AutoHaki = Value
end, "Misc/AutoHaki"})
Misc:AddSection({"Codes"})
Misc:AddButton({
  Name = "Redeem "Redeem all Codes", Codes",
  Callback Callback = function() function()
  local Codes = {
  "REWARDFUN",
  "Chandler",
  "NEWTROLL",
  "KITT_RESET",
  "Sub2CaptainMaui",
  "DEVSCOOKING",
  "kittgaming",
  "Sub2Fer999",
  "Enyu_is_Pro",
  "Magicbus",
  "JCWK",
  "Starcodeheo",
  "Bluxxy",
  "fudd10_v2",
  "SUB2GAMERROBOT_EXP1",
  "Sub2NoobMaster123",
  "Sub2UncleKizaru",   "Sub2Daigrock",
  "Axiore",
  "TantaiGaming",
  "StrawHatMaine",
  "Sub2OfficialNoobie",
  "Fudd10",
  "Bignews",
  "TheGreatAce",
  "DRAGONABUSE",
  "SECRET_ADMIN",
  "ADMIN_TROLL",
  "STAFFBATTLE",
  "ADMIN_STRENGTH",
  "JULYUPDATE_RESET",
  "NOOB_REFUND",
  "15B_BESTBROTHERS",
  "CINCODEMAYO_BOOST",
  "ADMINGIVEAWAY",
  "GAMER_ROBOT_1M",
  "SUBGAMERROBOT_RESET",
  "SUB2GAMERROBOT_RESET1",
  "GAMERROBOT_YT",
  "TY_FOR_WATCHING",
  "EXP_5B",
  "RESET_5B",
  "UPD16",
  "3BVISITS",
  "2BILLION",   "UPD15",
  "THIRDSEA",
  "1MLIKES_RESET",
  "UPD14",
  "1BILLION",
  "ShutDownFix2",
  "XmasExp",
  "XmasReset",
  "Update11",
  "PointsReset",
  "Update10",
  "Control",
  "SUB2OFFICIALNOOBIE",
  "AXIORE",
  "BIGNEWS",
  "BLUXXY",
  "CHANDLER",
  "ENYU_IS_PRO",
  "FUDD10",
  "FUDD10_V2",
  "KITTGAMING",
  "MAGICBUS",
  "STARCODEHEO",
  "STRAWHATMAINE",
  "SUB2CAPTAINMAUI",
  "SUB2DAIGROCK",
  "SUB2FER999",
  "SUB2NOOBMASTER123",
  "SUB2UNCLEKIZARU",
  "TANTAIGAMING",
  "THEGREATACE",   "CONTROL",
  "UPDATE11",
  "XMASEXP",
  "Colosseum"
  }
for _,code in pairs(Codes) do
  task.spawn(function()ReplicatedStorage.Remotes.Redeem:InvokeServer(code)end)
  end
  end
})
Misc:AddSection({"Team"})
Misc:AddButton({"Join Pirates Team", function()
  FireRemote("SetTeam", FireRemote("SetTeam", "Pirates") "Pirates")
end})
Misc:AddButton({"Join Marines Team", function()
  FireRemote("SetTeam", FireRemote("SetTeam", "Marines") "Marines")
end})
Misc:AddSection({"Menu"})
Misc:AddButton({"Devil Fruit Shop", function()
  FireRemote("GetFruits")
Player.PlayerGui.Main.FruitShop.Visible = true
end})
Misc:AddButton({"Titles", function()
  FireRemote("getTitles")   Player.PlayerGui.Main.Titles Player.PlayerGui.Main.Titles.Visible .Visible = true
end})
Misc:AddButton({"Haki Color", function()
  Player.PlayerGui.Main.Colors Player.PlayerGui.Main.Colors.Visible .Visible = true
end})
Misc:AddSection({"Visual"})
Misc:AddButton({"Remove Fog", function()
  local LightingLayers, LightingLayers, Sky = Lighting:FindFirstChild("Lig Lighting:FindFirstChild("LightingLayers"), htingLayers"),
Lighting:FindFirstChild("Sky")
  if Sky then
  Sky:Destroy()
  end
  if LightingLayers LightingLayers then
  LightingLayers:Destroy()
  end
end})
Misc:AddSection({"More FPS"})
Misc:AddToggle({"Remove Damage", true, function(Value)
  ReplicatedStorage.Assets.GUI ReplicatedStorage.Assets.GUI.DamageCounter.Enabled .DamageCounter.Enabled = not Value
end, "Misc/RemoveDamage"})
table.insert(AFKOptions, Misc:AddToggle({"Remove Notifications", false,
function(Value)
  Player.PlayerGui.Notificatio Player.PlayerGui.Notifications.Enabled ns.Enabled = not Value
end, "Misc/RemoveNotifications"}))
Misc:AddSection({"Others"})
Misc:AddToggle({"Walk On Water", true, function(Value)
  getgenv().WalkOnWater getgenv().WalkOnWater = Value
  task.spawn(function()
  local Map = workspace:WaitForChild("Map" workspace:WaitForChild("Map", 9e9)
while getgenv().WalkOnWater do task.wait(0.1)
  Map:WaitForChild("WaterB Map:WaitForChild("WaterBase-Plane", ase-Plane", 9e9).Size 9e9).Size = Vector3.new(1000, Vector3.new(1000, 113, 1000)
  end
  Map:WaitForChild("WaterBas Map:WaitForChild("WaterBase-Plane", e-Plane", 9e9).Size 9e9).Size = Vector3.new(1000, Vector3.new(1000, 80, 1000)
  end)
end, "Misc/WalkOnWater"})
Misc:AddToggle({"Anti AFK", true, function(Value)
  getgenv().AntiAFK getgenv().AntiAFK = Value
  task.spawn(function()
  while getgenv().AntiAFK getgenv().AntiAFK do
  VirtualUser:CaptureController()
  VirtualUser:ClickButton1 VirtualUser:ClickButton1(Vector2.new(math.huge, (Vector2.new(math.huge, math.huge))task.wait(600) math.huge))task.wait(600)
  end
  end)
end, "Misc/AntiAFK"})
--[[Shop:AddSection({"Christmas"})
Shop:AddButton({"Buy 2x EXP (15 mins.) < 50 Candies >",
function()FireRemote("Candies", "Check")FireRemote("Candies", "Buy", 1, 1)end})
Shop:AddButton({"Stats Refund < 75 Candies >", function()FireRemote("Candies",
"Check")FireRemote("Candies", "Buy", 1, 2)end})
Shop:AddButton({"Race Reroll < 100 Candies >", function()FireRemote("Candies", "Check")FireRemote("Candies", "Buy", 1, 3)end})
Shop:AddSection({""})
Shop:AddButton({"Buy 200 Frags < 50 Candies >", function()FireRemote("Candies",
"Check")FireRemote("Candies", "Buy", 2, 2)end})
Shop:AddButton({"Buy 500 Frags < 100 Candies >", function()FireRemote("Candies",
"Check")FireRemote("Candies", "Buy", 2, 2)end})
Shop:AddSection({"Bones"})
Shop:AddButton({"Buy Surprise < 50 Bones >", function()FireRemote("Bones", "Buy",
1, 1)end})
Shop:AddButton({"Stats Refund < 150 Bones >", function()FireRemote("Bones", "Buy",
1, 2)end})
Shop:AddButton({"Race Reroll < 300 Bones >", function()FireRemote("Bones", "Buy",
1, 3)end})]]
--[[Shop:AddSection({"Ectoplasm"})
Shop:AddButton({"Midnight Blade", function()end})
Shop:AddButton({"Bizarre Rifle", function()end})
Shop:AddButton({"Midnight Blade", function()end})]]
Shop:AddSection({"Frags"})
Shop:AddButton({"Race Rerol", function()
FireRemote("BlackbeardReward", "Reroll", "1")FireRemote("BlackbeardReward",
"Reroll", "2")end})
Shop:AddButton({"Reset Stats", function()
FireRemote("BlackbeardReward", "Refund", "1")FireRemote("BlackbeardReward",
"Refund", "2")end})
Shop:AddSection({"Fighting Style"})
Shop:AddButton({"Buy Black Leg", function()FireRemote("BuyBlackLeg")end})
Shop:AddButton({"Buy Electro", function()FireRemote("BuyElectro")end})
Shop:AddButton({"Buy Fishman Karate", function()FireRemote("BuyFishmanKarate")end})
Shop:AddButton({"Buy Dragon Claw", function()
FireRemote("BlackbeardReward","DragonClaw","1")FireRemote("BlackbeardReward","Drago
nClaw","2")end}) Shop:AddButton({"Buy Superhuman", function()FireRemote("BuySuperhuman")end})
Shop:AddButton({"Buy Death Step", function()FireRemote("BuyDeathStep")end})
Shop:AddButton({"Buy Sharkman Karate",
function()FireRemote("BuySharkmanKarate")end})
Shop:AddButton({"Buy Electric Claw", function()FireRemote("BuyElectricClaw")end})
Shop:AddButton({"Buy Dragon Talon", function()FireRemote("BuyDragonTalon")end})
Shop:AddButton({"Buy GodHuman", function()FireRemote("BuyGodhuman")end})
Shop:AddButton({"Buy Sanguine Art", function()FireRemote("BuySanguineArt")end})
Shop:AddSection({"Ability Teacher"})
Shop:AddButton({"Buy Geppo", function()FireRemote("BuyHaki", "Geppo")end})
Shop:AddButton({"Buy Buso", function()FireRemote("BuyHaki", "Buso")end})
Shop:AddButton({"Buy Soru", function()FireRemote("BuyHaki", "Soru")end})
Shop:AddSection({"Sword"})
Shop:AddButton({"Buy Katana", function()FireRemote("BuyItem", "Katana")end})
Shop:AddButton({"Buy Cutlass", function()FireRemote("BuyItem", "Cutlass")end})
Shop:AddButton({"Buy Dual Katana", function()FireRemote("BuyItem", "Dual
Katana")end})
Shop:AddButton({"Buy Iron Mace", function()FireRemote("BuyItem", "Iron Mace")end})
Shop:AddButton({"Buy Triple Katana", function()FireRemote("BuyItem", "Triple
Katana")end})
Shop:AddButton({"Buy Pipe", function()FireRemote("BuyItem", "Pipe")end})
Shop:AddButton({"Buy Dual-Headed Blade", function()FireRemote("BuyItem", "DualHeaded Blade")end})
Shop:AddButton({"Buy Soul Cane", function()FireRemote("BuyItem", "Soul Cane")end})
Shop:AddButton({"Buy Bisento", function()FireRemote("BuyItem", "Bisento")end})
Shop:AddSection({"Gun"})
Shop:AddButton({"Buy Musket", function()FireRemote("BuyItem", "Musket")end})
Shop:AddButton({"Buy Slingshot", function()FireRemote("BuyItem", "Slingshot")end}) Shop:AddButton({"Buy Flintlock", function()FireRemote("BuyItem", "Flintlock")end})
Shop:AddButton({"Buy Refined Slingshot", function()FireRemote("BuyItem", "Refined
Slingshot")end})
Shop:AddButton({"Buy Refined Flintlock", function()FireRemote("BuyItem", "Refined
Flintlock")end})
Shop:AddButton({"Buy Cannon", function()FireRemote("BuyItem", "Cannon")end})
Shop:AddButton({"Buy Kabucha", function()
FireRemote("BlackbeardReward", "Slingshot", "1")FireRemote("BlackbeardReward",
"Slingshot", "2")end})
Shop:AddSection({"Accessories"})
Shop:AddButton({"Buy Black Cape", function()FireRemote("BuyItem", "Black
Cape")end})
Shop:AddButton({"Buy Swordsman Hat", function()FireRemote("BuyItem", "Swordsman
Hat")end})
Shop:AddButton({"Buy Tomoe Ring", function()FireRemote("BuyItem", "Tomoe
Ring")end})
Shop:AddSection({"Race"})
Shop:AddButton({"Ghoul Race", function()FireRemote("Ectoplasm", "Change", 4)end})
Shop:AddButton({"Cyborg Race", function()FireRemote("CyborgTrainer", "Buy")end})
local NotifiFruits = false
local NotifiTime = 15
workspace.ChildAdded:Connect(function(part)
  if NotifiFruits NotifiFruits then
  if part:IsA("Tool") part:IsA("Tool") or string.find(part.Name, string.find(part.Name, "Fruit") "Fruit") then
  redzlib:MakeNotify({
  Name = "Fruit Notifier", Notifier",
  Text = "The fruit '" .. part.Name part.Name .. "' Spawned Spawned on the Map",
  Time = NotifiTime NotifiTime
  })   end
  end
end)
Visual:AddSection({"Notifications"})
Visual:AddSlider({Name = "Nofication Time",Max = 120, Min = 5, Increase = 1,
Default = 15, Callback = function(Value)
  NotifiTime NotifiTime = Value
end, Flag = "Notify/Time"})
Visual:AddToggle({Name = "Fruit Spawn",Callback = function(Value)
  NotifiFruits NotifiFruits = Value
end, Flag = "Notify/Fruit"})
Visual:AddSection({"ESP"})
if Sea2 then
Visual:AddToggle({Name = "ESP Flowers",Callback = function(Value)
  getgenv().EspFlowers getgenv().EspFlowers = Value;EspFlowers() Value;EspFlowers()
end})end
Visual:AddToggle({Name = "ESP Players",Callback = function(Value)
  getgenv().EspPlayer getgenv().EspPlayer = Value;EspPlayer() Value;EspPlayer()
end})
Visual:AddToggle({Name = "ESP Fruits",Callback = function(Value)
  getgenv().EspFruits getgenv().EspFruits = Value;EspFruits() Value;EspFruits()
end, Flag = "ESP/Fruits"})
Visual:AddToggle({Name = "ESP Chests",Callback = function(Value)
  getgenv().EspChests getgenv().EspChests = Value;EspChests() Value;EspChests()
end})
Visual:AddToggle({Name = "ESP Islands",Callback = function(Value)
  getgenv().EspIslands getgenv().EspIslands = Value;EspIslands() Value;EspIslands() end})
if IsOwner then
  Visual:AddSection({"Fruits"})
  Visual:AddButton({"Rain Visual:AddButton({"Rain Fruit", Fruit", function(value) function(value)
  for _,Fruit _,Fruit in pairs(game:GetObjects("rb pairs(game:GetObjects("rbxassetid://14759368201") xassetid://14759368201")
[1]:GetChildren()) do
  Fruit.Parent Fruit.Parent = Map
  Fruit:MoveTo(Player.Char Fruit:MoveTo(Player.Character.PrimaryPart.Position acter.PrimaryPart.Position +
Vector3.new(math.random(-50, 50), 80, math.random(-50, 50)))
  Fruit:WaitForChild("Handle").Touched:Connect(function(part)
  if part.Parent:FindFirstChi part.Parent:FindFirstChild("Humanoid") ld("Humanoid") then
  Fruit.Parent Fruit.Parent = Players[part.Parent.Name Players[part.Parent.Name].Backpack ].Backpack
  end
  end)
  pcall(function()
  Fruit.Fruit["AnimationController"]:LoadAnimation(Fruit.Fruit.Idle):Play()
  end)
  end
  end})
  Visual:AddButton({"Bring Visual:AddButton({"Bring Fruits", Fruits", function() function()
  for _,Fruit _,Fruit in pairs(Map:GetChildren()) pairs(Map:GetChildren()) do
  if Fruit:IsA("Tool") Fruit:IsA("Tool") or Fruit.Name:find("Fruit") Fruit.Name:find("Fruit") then
  Fruit.Parent Fruit.Parent = Player.Backpack Player.Backpack
  end
  end
  end})
end
Visual:AddSection({"Fake"})
Visual:AddParagraph({"Fake Stats"})
Visual:AddTextBox({Name = "Fake Defense",Default = "",PlaceholderText =
"Defense",Callback = function(Value)   Player.Data.Stats.Defense.Le Player.Data.Stats.Defense.Level.Value vel.Value = Value
end})
Visual:AddTextBox({Name = "Fake Fruit",Default = "",PlaceholderText =
"Fruit",Callback = function(Value)
  Player.Data.Stats["Demon Player.Data.Stats["Demon Fruit"].Level.Value Fruit"].Level.Value = Value
end})
Visual:AddTextBox({Name = "Fake Gun",Default = "",PlaceholderText = "Gun",Callback
= function(Value)
  Player.Data.Stats.Gun.Level. Player.Data.Stats.Gun.Level.Value = Value
end})
Visual:AddTextBox({Name = "Fake Melee",Default = "",PlaceholderText =
"Melee",Callback = function(Value)
  Player.Data.Stats.Melee.Leve Player.Data.Stats.Melee.Level.Value l.Value = Value
end})
Visual:AddTextBox({Name = "Fake Sword",Default = "",PlaceholderText =
"Sword",Callback = function(Sword)
  Player.Data.Stats.Sword.Leve Player.Data.Stats.Sword.Level.Value l.Value = Value
end})
Visual:AddParagraph({"Fake Mode"})
Visual:AddTextBox({Name = "Fake Level",Default = "",PlaceholderText =
"Level",Callback = function(Value)
  PlayerLevel.Value PlayerLevel.Value = Value
end})
Visual:AddTextBox({Name = "Fake Points",Default = "",PlaceholderText =
"Points",Callback = function(Value)
  Player.Data.Points.Value Player.Data.Points.Value = Value
end})
Visual:AddTextBox({Name = "Fake Bounty",Default = "",PlaceholderText = "Bounty",Callback = function(Value)
  Player.leaderstats["Bounty/H Player.leaderstats["Bounty/Honor"].Value onor"].Value = Value
end})
Visual:AddTextBox({Name = "Fake Energy",Default = "",PlaceholderText =
"Energy",Callback = function(Value)
  local plrEnergy = plrEnergy = Player and Player and Player.Character and Player.Character and
Player.Character:FindFirstChild("Energy")
  if plrEnergy plrEnergy then
  plrEnergy.Max plrEnergy.Max = Value
  plrEnergy.Value plrEnergy.Value = Value
  end
end})
Visual:AddTextBox({Name = "Fake Health",Default = "",PlaceholderText =
"Health",Callback = function(Value)
  local plrHealth = plrHealth = Player and Player and Player.Character and Player.Character and
Player.Character:FindFirstChild("Humanoid")
  if plrHealth plrHealth then
  plrHealth.MaxHealth plrHealth.MaxHealth = Value
  plrHealth.Health plrHealth.Health = Value
  end
end})
Visual:AddTextBox({Name = "Fake Money",Default = "",PlaceholderText =
"Money",Callback = function(Value)
  Player.Data.Beli.Value Player.Data.Beli.Value = Value
end})
Visual:AddTextBox({Name = "Fake Fragments",Default = "",PlaceholderText =
"Fragments",Callback = function(Value)
  Player.Data.Fragments.Value Player.Data.Fragments.Value = Value
end})
-- ////////////////////////////////////// --
task.spawn(function()
  local EffectContainer EffectContainer = ReplicatedStorage:WaitForCh ReplicatedStorage:WaitForChild("Effect", ild("Effect",
9e9):WaitForChild("Container", 9e9)
RunService.RenderStepped:Connect(function()
  local DeathEffect DeathEffect = EffectContainer:FindFirst EffectContainer:FindFirstChild("Death") Child("Death")
if DeathEffect then
  DeathEffect:Destroy()
  end
  end)
hookfunction(error, function()end)
  hookfunction(warn, hookfunction(warn, function()end) function()end)
end)
