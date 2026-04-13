--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local version = "1.0.2"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local Teams = game:GetService("Teams")

local guardsTeam = Teams:FindFirstChild("Guards")
local inmatesTeam = Teams:FindFirstChild("Inmates")
local criminalsTeam = Teams:FindFirstChild("Criminals")

local cfg = {
	enabled = true, -- toggle the whole script on/off
	teamcheck = true, -- dont shoot people on your team
	wallcheck = true, -- dont shoot through walls
	deathcheck = true, -- skip dead players
	ffcheck = true, -- skip players with forcefield
	hostilecheck = true, -- only shoot hostile inmates 💢 (guards only)
	trespasscheck = true, -- only shoot trespassing inmates 🔗 (guards only)
	vehiclecheck = true, -- dont shoot people sitting in cars
	criminalsnoinnmates = true, -- criminals wont shoot inmates
	inmatesnocriminals = true, -- inmates wont shoot criminals
	shieldbreaker = true, -- target shields to break them instead of being blocked
	shieldfrontangle = 0.3, -- (DONT CHANGE) how wide the shield covers (-1 to 1, lower = wider, 0.3 = ~70 degrees)
	shieldrandomhead = true, -- randomly hit head instead of shield sometimes (more legit)
	shieldheadchance = 30, -- percent chance to hit head instead of shield (0-100)
	taserbypasshostile = false, -- taser ignores hostile check
	taserbypasstrespass = false, -- taser ignores trespass check
	taseralwayshit = true, -- taser never misses
	ifplayerstill = false, -- always hit if player isnt moving
	stillthreshold = 0.5, -- how slow they gotta be to count as still
	hitchance = 65, -- percent chance to actually hit (0-100)
	hitchanceAutoOnly = false, -- only apply hitchance to automatic weapons (shotguns always hit)
	distancebasedhitchance = false, -- use distance breakpoints to change hitchance
	distancehitchancepoints = {}, -- custom GUI list: 200:30, 350:20, etc
	distancehitchance1dist = 200, -- at/after this distance, use hitchance 1
	distancehitchance1value = 30,
	distancehitchance2dist = 350, -- at/after this distance, use hitchance 2
	distancehitchance2value = 20,
	distancehitchance3dist = 500, -- at/after this distance, use hitchance 3
	distancehitchance3value = 10,
	distancehitchance4dist = 650, -- at/after this distance, use hitchance 4
	distancehitchance4value = 5,
	distancehitchance5dist = 800, -- at/after this distance, use hitchance 5
	distancehitchance5value = 1,
	aimmaxdist = 100, -- max studs a target can be from you (set to 0 for any distance)
	missspread = 5, -- how far off to shoot when missing (makes it look legit)
	shotgunnaturalspread = true, -- let shotgun bullets spread naturally instead of all hitting
	shotgungamehandled = false, -- aim at player but let game handle hitchance/spread
	prioritizeclosest = true, -- shoot whoever is closest to your cursor (false = random from fov)
	prioritizecriminals = true, -- if an inmate and criminal are both in fov, prefer the criminal
	targetstickiness = false, -- enable/disable target stickiness
	targetstickinessduration = 0.6, -- how long to keep target (seconds)
	targetstickinessrandom = false, -- use random range instead of fixed value
	targetstickinessmin = 0.3, -- min time if random is on
	targetstickinessmax = 0.7, -- max time if random is on
	fov = 150, -- how big the aim circle is
	showfov = true, -- show the fov circle on screen
	staticfov = true, -- keep the fov centered instead of following touch/mouse
	showtargetline = false, -- draw a line to your target
	togglekey = Enum.KeyCode.RightShift, -- key to toggle silent aim
	aimpart = "Head", -- what body part to aim at
	randomparts = true, -- randomly pick body parts instead
	partslist = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}, -- parts to pick from if random is on (can add more if wanted)
	esp = true,
	espteamcheck = true,
	espshowteam = false,
	esptargets = {guards = true, inmates = true, criminals = true},
	espmaxdist = 500, -- set to 0 for any distance
	espshowdist = true,
	esptoggle = Enum.KeyCode.RightControl,
	espcolor = Color3.fromRGB(0, 170, 255),
	espguards = Color3.fromRGB(0, 170, 255),
	espinmates = Color3.fromRGB(255, 150, 50),
	espcriminals = Color3.fromRGB(255, 60, 60),
	espteam = Color3.fromRGB(60, 255, 60),
	espuseteamcolors = true,
	autoshoot = false,
	autoshootweapon = "Any", -- valid values: "Any", "Taser", "M9", "AK-47", "M4A1", "Remington 870", "Revolver", "Shotgun", "Sniper", "Automatic"
	autoshootdelay = 0.12,
	autoshootstartdelay = 0.2,
	autograb = true,
	autograbdistance = 12,
	autograbdelay = 1,
	autograbkeycard = true,
	autograbm9 = true,
	c4esp = true,
	c4esptoggle = Enum.KeyCode.B,
	c4espcolor = Color3.fromRGB(80, 255, 80),
	c4espmaxdist = 200, -- set to 0 for any distance
	c4espshowdist = true
}

local function deepCopyTable(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, nestedValue in pairs(value) do
		copy[key] = deepCopyTable(nestedValue)
	end
	return copy
end

local defaultCfg = deepCopyTable(cfg)

local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude
wallParams.IgnoreWater = true
wallParams.RespectCanCollide = false
wallParams.CollisionGroup = "ClientBullet"

local projectileParams = RaycastParams.new()
projectileParams.FilterType = Enum.RaycastFilterType.Exclude
projectileParams.IgnoreWater = true
projectileParams.RespectCanCollide = false
projectileParams.CollisionGroup = "ClientBullet"

local currentGun = nil
local rng = Random.new()
local lastShotTime = 0
local lastShotResult = false
local shotCooldown = 1 / 30
local currentTarget = nil
local targetSwitchTime = 0
local currentStickiness = 0
local randomPartCache = {}
local lastTouchAimPos = nil
local activeTouch = nil
local mobileGuiButton = nil
local mobileGuiDragInput = nil
local lastAutoShoot = 0
local cachedBulletsLabel = nil
local targetAcquiredTime = 0
local lastAutoTarget = nil
local lastReloadRequest = 0
local playerSettings = ReplicatedStorage:FindFirstChild("PlayerSettings")
local mobileCursorOffset = 0
local isInsideDynThumbFrame = nil
local giverPressedRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("GiverPressed")
local trackedGrabbables = {}
local firstSeenGrabbables = {}
local lastAutoGrab = 0

do
	local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
	local dynThumbModule = sharedModules and sharedModules:FindFirstChild("isInsideDynThumbFrame")
	if dynThumbModule then
		local ok, result = pcall(require, dynThumbModule)
		if ok and typeof(result) == "function" then
			isInsideDynThumbFrame = result
		end
	end
end

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Radius = cfg.fov
fovCircle.Transparency = 0.8
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Thickness = 1
fovCircle.Visible = cfg.showfov and cfg.enabled

local targetLine = Drawing.new("Line")
targetLine.Color = Color3.fromRGB(0, 255, 0)
targetLine.Thickness = 1
targetLine.Transparency = 0.5
targetLine.Visible = false

local visuals = {container = nil}
local espCache = {}
local uiElements = {}
local resolveMacLibWindowGui
local selectedDistanceHitchancePoint = 1
local syncingDistanceHitchanceEditor = false
local storedAimMaxDistanceBeforeDistanceHitchance = tonumber(cfg.aimmaxdist) or 0
local distanceHitchanceForcesAimMaxDistance = false

local function formatDistanceHitchanceNumber(value)
	if math.abs(value - math.floor(value)) < 0.001 then
		return tostring(math.floor(value))
	end
	return string.format("%.2f", value)
end

local function cloneDistanceHitchancePoints(points)
	local copy = {}
	for _, point in ipairs(points or {}) do
		copy[#copy + 1] = {
			distance = point.distance,
			chance = point.chance
		}
	end
	return copy
end

local function normalizeDistanceHitchancePoints(points)
	local baseChance = math.clamp(tonumber(cfg.hitchance) or 0, 0, 100)
	local normalized = {}
	if typeof(points) == "table" then
		for _, point in ipairs(points) do
			if typeof(point) == "table" then
				normalized[#normalized + 1] = {
					distance = math.max(tonumber(point.distance or point.dist or point[1]) or 0, 0),
					chance = math.clamp(tonumber(point.chance or point.value or point[2]) or baseChance, 0, 100)
				}
			end
		end
	end
	table.sort(normalized, function(a, b)
		return a.distance < b.distance
	end)
	return normalized
end

local function getDefaultDistanceHitchancePoints()
	local baseChance = math.clamp(tonumber(cfg.hitchance) or 0, 0, 100)
	return normalizeDistanceHitchancePoints({
		{distance = math.max(tonumber(cfg.distancehitchance1dist) or 0, 0), chance = math.clamp(tonumber(cfg.distancehitchance1value) or baseChance, 0, 100)},
		{distance = math.max(tonumber(cfg.distancehitchance2dist) or 0, 0), chance = math.clamp(tonumber(cfg.distancehitchance2value) or baseChance, 0, 100)},
		{distance = math.max(tonumber(cfg.distancehitchance3dist) or 0, 0), chance = math.clamp(tonumber(cfg.distancehitchance3value) or baseChance, 0, 100)},
		{distance = math.max(tonumber(cfg.distancehitchance4dist) or 0, 0), chance = math.clamp(tonumber(cfg.distancehitchance4value) or baseChance, 0, 100)},
		{distance = math.max(tonumber(cfg.distancehitchance5dist) or 0, 0), chance = math.clamp(tonumber(cfg.distancehitchance5value) or baseChance, 0, 100)}
	})
end

local function getDistanceHitchancePoints()
	local points = normalizeDistanceHitchancePoints(cfg.distancehitchancepoints)
	if #points == 0 then
		points = getDefaultDistanceHitchancePoints()
	end
	return points
end

local function ensureEditableDistanceHitchancePoints()
	local points = getDistanceHitchancePoints()
	if #points == 0 then
		points = {
			{distance = 200, chance = 30}
		}
	end
	cfg.distancehitchancepoints = cloneDistanceHitchancePoints(points)
	return cfg.distancehitchancepoints
end

local function getDistanceHitchancePointLabel(point, index)
	return string.format(
		"%d. %s studs -> %s%%",
		index,
		formatDistanceHitchanceNumber(point.distance),
		formatDistanceHitchanceNumber(point.chance)
	)
end

local function syncDistanceHitchanceEditor()
	if syncingDistanceHitchanceEditor then
		return
	end

	syncingDistanceHitchanceEditor = true

	local points = ensureEditableDistanceHitchancePoints()
	selectedDistanceHitchancePoint = math.clamp(selectedDistanceHitchancePoint, 1, math.max(#points, 1))

	local labels = {}
	for index, point in ipairs(points) do
		labels[index] = getDistanceHitchancePointLabel(point, index)
	end

	if uiElements.DistanceHitchancePointDropdown then
		if uiElements.DistanceHitchancePointDropdown.ClearOptions then
			uiElements.DistanceHitchancePointDropdown:ClearOptions()
		end
		if uiElements.DistanceHitchancePointDropdown.InsertOptions then
			uiElements.DistanceHitchancePointDropdown:InsertOptions(labels)
		end
		if labels[selectedDistanceHitchancePoint] and uiElements.DistanceHitchancePointDropdown.UpdateSelection then
			uiElements.DistanceHitchancePointDropdown:UpdateSelection(labels[selectedDistanceHitchancePoint])
		end
	end

	local selectedPoint = points[selectedDistanceHitchancePoint]
	if selectedPoint then
		if uiElements.SelectedDistancePointDistanceSlider then
			uiElements.SelectedDistancePointDistanceSlider:UpdateValue(selectedPoint.distance)
		end
		if uiElements.SelectedDistancePointHitchanceSlider then
			uiElements.SelectedDistancePointHitchanceSlider:UpdateValue(selectedPoint.chance)
		end
	end

	syncingDistanceHitchanceEditor = false
end

local function setDistanceHitchanceEnabledState(enabled)
	if enabled then
		if not distanceHitchanceForcesAimMaxDistance then
			storedAimMaxDistanceBeforeDistanceHitchance = tonumber(cfg.aimmaxdist) or 0
		end
		cfg.distancebasedhitchance = true
		cfg.aimmaxdist = 0
		distanceHitchanceForcesAimMaxDistance = true
	else
		cfg.distancebasedhitchance = false
		if distanceHitchanceForcesAimMaxDistance then
			cfg.aimmaxdist = tonumber(storedAimMaxDistanceBeforeDistanceHitchance) or 0
		end
		distanceHitchanceForcesAimMaxDistance = false
	end
end

local function syncDistanceHitchanceAimMaxDistanceFromConfig()
	local currentAimMaxDistance = tonumber(cfg.aimmaxdist) or 0
	if cfg.distancebasedhitchance then
		if currentAimMaxDistance > 0 then
			storedAimMaxDistanceBeforeDistanceHitchance = currentAimMaxDistance
		elseif storedAimMaxDistanceBeforeDistanceHitchance <= 0 then
			storedAimMaxDistanceBeforeDistanceHitchance = tonumber(defaultCfg.aimmaxdist) or 0
		end
		cfg.aimmaxdist = 0
		distanceHitchanceForcesAimMaxDistance = true
	else
		storedAimMaxDistanceBeforeDistanceHitchance = currentAimMaxDistance
		distanceHitchanceForcesAimMaxDistance = false
	end
end

local function loadLegitDistanceHitchancePreset()
	cfg.hitchance = 82
	setDistanceHitchanceEnabledState(true)
	cfg.distancehitchancepoints = {
		{distance = 90, chance = 76},
		{distance = 150, chance = 69},
		{distance = 225, chance = 60},
		{distance = 325, chance = 48},
		{distance = 450, chance = 36},
		{distance = 600, chance = 24},
		{distance = 800, chance = 14}
	}
	selectedDistanceHitchancePoint = 1
end

local function loadBlatantDistanceHitchancePreset()
	cfg.hitchance = 99
	setDistanceHitchanceEnabledState(true)
	cfg.distancehitchancepoints = {
		{distance = 125, chance = 99},
		{distance = 250, chance = 98},
		{distance = 400, chance = 97},
		{distance = 600, chance = 95},
		{distance = 850, chance = 92},
		{distance = 1100, chance = 88},
		{distance = 1500, chance = 82}
	}
	selectedDistanceHitchancePoint = 1
end

local function resetAimState()
	lastShotTime = 0
	lastShotResult = false
	currentTarget = nil
	targetSwitchTime = 0
	currentStickiness = 0
	lastAutoShoot = 0
	lastAutoTarget = nil
	targetAcquiredTime = 0
	cachedBulletsLabel = nil
end

local function getHud()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local home = playerGui and playerGui:FindFirstChild("Home")
	return home and home:FindFirstChild("hud") or nil
end

local function getMobileGunFrame()
	local hud = getHud()
	return hud and hud:FindFirstChild("MobileGunFrame") or nil
end

local function getMobileCursor()
	local mobileGunFrame = getMobileGunFrame()
	return mobileGunFrame and mobileGunFrame:FindFirstChild("MobileCursor") or nil
end

local function updateMobileCursorOffset()
	if not playerSettings then
		mobileCursorOffset = 0
		return
	end
	local offset = playerSettings:GetAttribute("MobileCursorOffset")
	if typeof(offset) == "number" then
		mobileCursorOffset = offset * 15
	else
		mobileCursorOffset = 0
	end
end

if playerSettings then
	updateMobileCursorOffset()
	playerSettings:GetAttributeChangedSignal("MobileCursorOffset"):Connect(updateMobileCursorOffset)
end

local function isIgnoredTouchPosition(position)
	if mobileGuiDragInput then
		return true
	end
	if isInsideDynThumbFrame and isInsideDynThumbFrame(position.X, position.Y) then
		return true
	end
	if mobileGuiButton and mobileGuiButton.Parent and mobileGuiButton.Visible then
		local x = position.X
		local y = position.Y
		local left = mobileGuiButton.AbsolutePosition.X
		local right = left + mobileGuiButton.AbsoluteSize.X
		local top = mobileGuiButton.AbsolutePosition.Y
		local bottom = top + mobileGuiButton.AbsoluteSize.Y
		if left <= x and x <= right and top <= y and y <= bottom then
			return true
		end
	end
	if resolveMacLibWindowGui then
		local windowGui = resolveMacLibWindowGui()
		if windowGui and windowGui.Enabled then
			local ok, guiObjects = pcall(function()
				return GuiService:GetGuiObjectsAtPosition(position.X, position.Y)
			end)
			if ok and guiObjects then
				for _, guiObject in ipairs(guiObjects) do
					if guiObject:IsDescendantOf(windowGui) then
						return true
					end
				end
			end
		end
	end
	local mobileGunFrame = getMobileGunFrame()
	local ignoreTouchArea = mobileGunFrame and mobileGunFrame:FindFirstChild("IgnoreTouchArea")
	if not ignoreTouchArea then
		return false
	end
	local x = position.X
	local y = position.Y
	local left = ignoreTouchArea.AbsolutePosition.X
	local right = left + ignoreTouchArea.AbsoluteSize.X
	local top = ignoreTouchArea.AbsolutePosition.Y
	local bottom = top + ignoreTouchArea.AbsoluteSize.Y
	return left <= x and x <= right and top <= y and y <= bottom
end

local function getAimScreenPosition(camera)
	camera = camera or workspace.CurrentCamera
	if not camera then
		return UserInputService:GetMouseLocation()
	end

	local lastInput = UserInputService:GetLastInputType()
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		local viewportSize = camera.ViewportSize
		return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	end

	if lastInput == Enum.UserInputType.Touch then
		local mobileCursor = getMobileCursor()
		if mobileCursor and mobileCursor.Visible then
			local pos = mobileCursor.AbsolutePosition
			local size = mobileCursor.AbsoluteSize
			return Vector2.new(pos.X + size.X / 2, pos.Y + size.Y / 2)
		end

		local viewportSize = camera.ViewportSize
		return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	end

	return UserInputService:GetMouseLocation()
end

local function getScreenCenter(camera)
	camera = camera or workspace.CurrentCamera
	if not camera then
		return Vector2.zero
	end
	local viewportSize = camera.ViewportSize
	return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end

local function getFovScreenPosition(camera)
	if cfg.staticfov then
		return getScreenCenter(camera)
	end
	return getAimScreenPosition(camera)
end

local function isSniper(gun)
	return gun and gun:GetAttribute("Behavior") == "Sniper"
end

local function isTaserGun(gun)
	return gun and (gun:GetAttribute("Behavior") == "Taser" or gun:GetAttribute("Projectile") == "Taser")
end

local function isShotgun(gun)
	return gun and (gun:GetAttribute("IsShotgun") or gun:GetAttribute("Behavior") == "Shotgun")
end

local function isAutomaticWeapon(gun)
	return gun and gun:GetAttribute("AutoFire") == true
end

local function normalizeWeaponSelector(value)
	return tostring(value or ""):lower():gsub("%s+", "")
end

local function gunMatchesAutoShootWeapon(gun)
	if not gun then
		return false
	end

	local selector = normalizeWeaponSelector(cfg.autoshootweapon)
	if selector == "" or selector == "any" or selector == "all" then
		return true
	end

	local gunName = normalizeWeaponSelector(gun.Name)
	local behavior = normalizeWeaponSelector(gun:GetAttribute("Behavior"))
	local projectile = normalizeWeaponSelector(gun:GetAttribute("Projectile"))

	if selector == "taser" then
		return isTaserGun(gun) or gunName:find("taser", 1, true) ~= nil
	elseif selector == "shotgun" then
		return isShotgun(gun)
	elseif selector == "sniper" then
		return isSniper(gun)
	elseif selector == "auto" or selector == "automatic" then
		return isAutomaticWeapon(gun)
	end

	return selector == gunName or selector == behavior or selector == projectile
end

local function getLocalAimOriginPart()
	local character = LocalPlayer.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

local function isWithinAimDistance(targetPos)
	local maxDistance = tonumber(cfg.aimmaxdist) or 0
	if maxDistance <= 0 or not targetPos then
		return true
	end

	local originPart = getLocalAimOriginPart()
	if not originPart then
		return true
	end

	return (targetPos - originPart.Position).Magnitude <= maxDistance
end

local function shouldBypassHitchance(gun)
	return gun ~= nil and cfg.hitchanceAutoOnly and not isAutomaticWeapon(gun)
end

local function getLocalHumanoid()
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function isSniperStable(gun)
	if not isSniper(gun) then
		return true
	end
	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		return false
	end
	local humanoid = getLocalHumanoid()
	return not humanoid or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall
end

local function getFireOriginPosition()
	local myChar = LocalPlayer.Character
	local myHead = myChar and myChar:FindFirstChild("Head")
	if not myHead then return nil end

	local muzzle = currentGun and currentGun:FindFirstChild("Muzzle")
	return muzzle and muzzle.Position or myHead.Position
end

local function isInCurrentGunRange(targetPos, originPos)
	if not currentGun or not targetPos then return true end

	local range = currentGun:GetAttribute("Range")
	if typeof(range) ~= "number" or range <= 0 then return true end

	originPos = originPos or getFireOriginPosition()
	if not originPos then return true end

	return (targetPos - originPos).Magnitude <= range + 5
end

local function isSupportedGrabbable(obj)
	if not obj or not obj:IsA("Model") then
		return false
	end

	local name = obj.Name:lower()
	return name:find("keycard", 1, true) ~= nil or name == "m9"
end

local function shouldAutoGrabItem(obj)
	if not cfg.autograb or not obj or not obj:IsA("Model") then
		return false
	end

	local name = obj.Name:lower()
	if name:find("keycard", 1, true) ~= nil then
		return cfg.autograbkeycard
	end
	if name == "m9" then
		return cfg.autograbm9
	end

	return false
end

local function isOwnedGrabbable(obj)
	local ancestor = obj and obj.Parent
	while ancestor and ancestor ~= workspace do
		if ancestor:FindFirstChildOfClass("Humanoid") then
			return true
		end
		if ancestor.Name == "Backpack" then
			return true
		end
		ancestor = ancestor.Parent
	end
	return false
end

local function getGrabbablePart(model)
	if not model then
		return nil
	end
	return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
end

local function distSq(a, b)
	local delta = a - b
	return delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
end

local function trackGrabbable(obj)
	if isSupportedGrabbable(obj) then
		trackedGrabbables[obj] = true
	end
end

local function untrackGrabbable(obj)
	trackedGrabbables[obj] = nil
	firstSeenGrabbables[obj] = nil
end

local function updateAutoGrab(now)
	if not cfg.autograb or not giverPressedRemote then
		return
	end
	if now - lastAutoGrab < 0.05 then
		return
	end

	local root = getLocalAimOriginPart()
	if not root then
		return
	end

	local grabDistance = math.clamp(tonumber(cfg.autograbdistance) or 0, 0, 12)
	if grabDistance <= 0 then
		return
	end

	local requiredDelay = math.max(tonumber(cfg.autograbdelay) or 0, 0)
	local grabDistanceSq = grabDistance * grabDistance

	for item in pairs(trackedGrabbables) do
		if not item or not item.Parent then
			untrackGrabbable(item)
		elseif not shouldAutoGrabItem(item) then
			firstSeenGrabbables[item] = nil
		elseif isOwnedGrabbable(item) then
			firstSeenGrabbables[item] = nil
		else
			local part = getGrabbablePart(item)
			if part and distSq(root.Position, part.Position) <= grabDistanceSq then
				if not firstSeenGrabbables[item] then
					firstSeenGrabbables[item] = now
				elseif now - firstSeenGrabbables[item] >= requiredDelay then
					lastAutoGrab = now
					firstSeenGrabbables[item] = nil
					pcall(giverPressedRemote.FireServer, giverPressedRemote, item)
					return
				end
			else
				firstSeenGrabbables[item] = nil
			end
		end
	end
end

local function shouldUseInstantAcquireDelay(gun)
	if not gun then
		return false
	end
	local lastInput = UserInputService:GetLastInputType()
	return lastInput == Enum.UserInputType.Touch or lastInput == Enum.UserInputType.Gamepad1 or isShotgun(gun)
end

local function simulateProjectileImpact(startPos, aimPos, gun)
	if not gun or not startPos or not aimPos then
		return nil, aimPos
	end
	local behavior = gun:GetAttribute("Behavior")
	local spread = gun:GetAttribute("SpreadRadius") or 0
	local range = gun:GetAttribute("Range") or 1500
	local randomScale = rng:NextNumber()
	if behavior == "Sniper" or behavior == "Shotgun" then
		randomScale = math.sqrt(randomScale)
	end
	local baseCFrame = CFrame.new(startPos, aimPos)
	local rollAngle = math.rad(360 - 720 * rng:NextNumber())
	local direction = (baseCFrame * CFrame.Angles(0, 0, rollAngle) * CFrame.Angles(0, randomScale * spread, 0)).LookVector * range
	projectileParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local result = workspace:Raycast(startPos, direction, projectileParams)
	if result then
		return result.Instance, result.Position
	end
	return nil, startPos + direction
end

local function makeVisuals()
	local container
	local guiParent = (gethui and gethui()) or CoreGui
	local existing = guiParent:FindFirstChild("SilentAimESP") or CoreGui:FindFirstChild("SilentAimESP")
	if existing then
		existing:Destroy()
	end
	if gethui then
		local screen = Instance.new("ScreenGui")
		screen.Name = "SilentAimESP"
		screen.ResetOnSpawn = false
		screen.Parent = gethui()
		container = screen
	elseif syn and syn.protect_gui then
		local screen = Instance.new("ScreenGui")
		screen.Name = "SilentAimESP"
		screen.ResetOnSpawn = false
		syn.protect_gui(screen)
		screen.Parent = CoreGui
		container = screen
	else
		local screen = Instance.new("ScreenGui")
		screen.Name = "SilentAimESP"
		screen.ResetOnSpawn = false
		screen.Parent = CoreGui
		container = screen
	end
	visuals.container = container
end

local function makeEsp(player)
	if espCache[player] then return espCache[player] end

	local esp = Instance.new("BillboardGui")
	esp.Name = "ESP_" .. player.Name
	esp.AlwaysOnTop = true
	esp.Size = UDim2.new(0, 20, 0, 20)
	esp.StudsOffset = Vector3.new(0, 3, 0)
	esp.LightInfluence = 0

	local diamond = Instance.new("Frame")
	diamond.Name = "Diamond"
	diamond.BackgroundColor3 = cfg.espcolor
	diamond.BorderSizePixel = 0
	diamond.Size = UDim2.new(0, 10, 0, 10)
	diamond.Position = UDim2.new(0.5, -5, 0.5, -5)
	diamond.Rotation = 45
	diamond.Parent = esp

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = diamond

	local distLabel = Instance.new("TextLabel")
	distLabel.Name = "DistanceLabel"
	distLabel.BackgroundTransparency = 1
	distLabel.Size = UDim2.new(0, 60, 0, 16)
	distLabel.Position = UDim2.new(0.5, -30, 1, 2)
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 11
	distLabel.TextColor3 = Color3.new(1, 1, 1)
	distLabel.TextStrokeTransparency = 0.5
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Text = ""
	distLabel.Parent = esp

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(0, 100, 0, 14)
	nameLabel.Position = UDim2.new(0.5, -50, 0, -16)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 10
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Text = player.Name
	nameLabel.Parent = esp

	espCache[player] = esp
	return esp
end

local function removeEsp(player)
	local e = espCache[player]
	if e then e:Destroy() espCache[player] = nil end
	if player and player.Character then
		randomPartCache[player.Character] = nil
	end
	if currentTarget == player then
		currentTarget = nil
	end
	if lastAutoTarget == player then
		lastAutoTarget = nil
	end
end

local function shouldShowEsp(player)
	if not player or player == LocalPlayer or not player.Character then return false end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end

	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local myChar = LocalPlayer.Character
	if not myChar then return false end
	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	if not myHrp then return false end

	local distance = (hrp.Position - myHrp.Position).Magnitude
	local espMaxDistance = tonumber(cfg.espmaxdist) or 0
	if espMaxDistance > 0 and distance > espMaxDistance then return false end

	local myTeam = LocalPlayer.Team
	local theirTeam = player.Team

	if theirTeam == myTeam then
		if not cfg.espshowteam then return false end
		return true
	end

	if cfg.espteamcheck then
		local imCrimOrInmate = (myTeam == criminalsTeam or myTeam == inmatesTeam)
		local theyCrimOrInmate = (theirTeam == criminalsTeam or theirTeam == inmatesTeam)
		if imCrimOrInmate and theyCrimOrInmate then return false end
	end

	if theirTeam == guardsTeam then return cfg.esptargets.guards
	elseif theirTeam == inmatesTeam then return cfg.esptargets.inmates
	elseif theirTeam == criminalsTeam then return cfg.esptargets.criminals end

	return false
end

local function updateEsp()
	if not cfg.esp or not visuals.container then
		for _, e in pairs(espCache) do e.Parent = nil end
		return
	end

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, player in ipairs(Players:GetPlayers()) do
		local show = shouldShowEsp(player)

		if show then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local head = char and char:FindFirstChild("Head")

			if hrp and head then
				local esp = makeEsp(player)
				esp.Adornee = head
				esp.Parent = visuals.container

				local d = esp:FindFirstChild("Diamond")
				if d and cfg.espuseteamcolors then
					local t = player.Team
					if t == LocalPlayer.Team then d.BackgroundColor3 = cfg.espteam
					elseif t == guardsTeam then d.BackgroundColor3 = cfg.espguards
					elseif t == inmatesTeam then d.BackgroundColor3 = cfg.espinmates
					elseif t == criminalsTeam then d.BackgroundColor3 = cfg.espcriminals
					else d.BackgroundColor3 = cfg.espcolor end
				end

				if cfg.espshowdist and myHrp then
					local label = esp:FindFirstChild("DistanceLabel")
					if label then
						label.Text = math.floor((hrp.Position - myHrp.Position).Magnitude) .. "m"
						label.Visible = true
					end
				else
					local label = esp:FindFirstChild("DistanceLabel")
					if label then
						label.Visible = false
					end
				end
			end
		else
			local e = espCache[player]
			if e then e.Parent = nil end
		end
	end
end

local c4espCache = {}

local function makeC4Esp(c4Part)
	if c4espCache[c4Part] then return c4espCache[c4Part] end

	local esp = Instance.new("BillboardGui")
	esp.Name = "C4ESP_" .. tostring(c4Part)
	esp.AlwaysOnTop = true
	esp.Size = UDim2.new(0, 24, 0, 24)
	esp.StudsOffset = Vector3.new(0, 1, 0)
	esp.LightInfluence = 0

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.BackgroundColor3 = cfg.c4espcolor
	icon.BorderSizePixel = 0
	icon.Size = UDim2.new(0, 14, 0, 14)
	icon.Position = UDim2.new(0.5, -7, 0.5, -7)
	icon.Rotation = 45
	icon.Parent = esp

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = icon

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 60, 0, 14)
	label.Position = UDim2.new(0.5, -30, 1, 2)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Text = "C4"
	label.Parent = esp

	local distLabel = Instance.new("TextLabel")
	distLabel.Name = "DistLabel"
	distLabel.BackgroundTransparency = 1
	distLabel.Size = UDim2.new(0, 60, 0, 12)
	distLabel.Position = UDim2.new(0.5, -30, 1, 16)
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 10
	distLabel.TextColor3 = cfg.c4espcolor
	distLabel.TextStrokeTransparency = 0.5
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.Text = ""
	distLabel.Parent = esp

	c4espCache[c4Part] = esp
	return esp
end

local trackedC4s = {}

local function isC4Part(part)
	if not part or not part:IsA("BasePart") then return false end
	local name = part.Name:lower()
	local parentName = part.Parent and part.Parent.Name:lower() or ""
	return name == "explosive" or name == "c4" or name == "clientc4" or 
		parentName:find("c4") or name:find("c4")
end

local function onDescendantAdded(desc)
	if isC4Part(desc) then
		trackedC4s[desc] = true
	end
end

local function onDescendantRemoving(desc)
	trackedC4s[desc] = nil
	if c4espCache[desc] then
		c4espCache[desc]:Destroy()
		c4espCache[desc] = nil
	end
end

for _, desc in ipairs(workspace:GetDescendants()) do
	if isC4Part(desc) then trackedC4s[desc] = true end
	trackGrabbable(desc)
end
workspace.DescendantAdded:Connect(onDescendantAdded)
workspace.DescendantRemoving:Connect(onDescendantRemoving)
workspace.DescendantAdded:Connect(trackGrabbable)
workspace.DescendantRemoving:Connect(untrackGrabbable)

local function updateC4Esp()
	if not cfg.c4esp or not visuals.container then
		for _, e in pairs(c4espCache) do e.Parent = nil end
		return
	end

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for part in pairs(trackedC4s) do
		if part and part:IsDescendantOf(workspace) then
			local dist = 0
			if myHrp then
				dist = (part.Position - myHrp.Position).Magnitude
			end

			local c4MaxDistance = tonumber(cfg.c4espmaxdist) or 0
			if c4MaxDistance <= 0 or dist <= c4MaxDistance then
				local esp = makeC4Esp(part)
				esp.Adornee = part
				esp.Parent = visuals.container

				if cfg.c4espshowdist and myHrp then
					local distLabel = esp:FindFirstChild("DistLabel")
					if distLabel then
						distLabel.Text = math.floor(dist) .. "m"
					end
				else
					local distLabel = esp:FindFirstChild("DistLabel")
					if distLabel then
						distLabel.Text = ""
					end
				end
			else
				local e = c4espCache[part]
				if e then e.Parent = nil end
			end
		else
			trackedC4s[part] = nil
			if c4espCache[part] then
				c4espCache[part]:Destroy()
				c4espCache[part] = nil
			end
		end
	end
end

makeVisuals()

local partMap = {
	["Torso"] = {"Torso"},
	["LeftArm"] = {"Left Arm"},
	["RightArm"] = {"Right Arm"},
	["LeftLeg"] = {"Left Leg"},
	["RightLeg"] = {"Right Leg"}
}

local function normalizePartName(name)
	return tostring(name or ""):gsub("%s+", "")
end

local function getPart(char, name)
	if not char then return nil end
	local p = char:FindFirstChild(name)
	if p then return p end
	local maps = partMap[normalizePartName(name)]
	if maps then
		for _, n in ipairs(maps) do
			local part = char:FindFirstChild(n)
			if part then return part end
		end
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function getTaserTargetPart(char)
	if not char then return nil end
	return char:FindFirstChild("Torso")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Head")
end

local function getTargetPart(char)
	if not char then return nil end
	if isTaserGun(currentGun) then
		return getTaserTargetPart(char)
	end
	if cfg.shieldbreaker then
		local shield = char:FindFirstChild("RiotShieldPart")
		if shield and shield:IsA("BasePart") then
			local hp = shield:GetAttribute("Health")
			if hp and hp > 0 then
				local myChar = LocalPlayer.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
				local theirHrp = char:FindFirstChild("HumanoidRootPart")
				if myHrp and theirHrp then
					local toMe = (myHrp.Position - theirHrp.Position).Unit
					local theirLook = theirHrp.CFrame.LookVector
					local dot = toMe:Dot(theirLook)
					if dot > cfg.shieldfrontangle then
						if cfg.shieldrandomhead and rng:NextInteger(1, 100) <= cfg.shieldheadchance then
							return getPart(char, "Head")
						end
						return shield
					end
				end
			end
		end
	end
	local partName
	if cfg.randomparts then
		local cached = randomPartCache[char]
		if cached and cached.part and cached.part.Parent == char and cached.expiresAt > os.clock() then
			return cached.part
		end
		local list = cfg.partslist
		partName = (list and #list > 0) and list[rng:NextInteger(1, #list)] or "Head"
	else
		partName = cfg.aimpart
	end
	local part = getPart(char, partName)
	if cfg.randomparts and part then
		randomPartCache[char] = {
			part = part,
			partName = partName,
			expiresAt = os.clock() + 0.15
		}
	end
	return part
end

local function isDead(player)
	if not player or not player.Character then return true end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	return not humanoid or humanoid.Health <= 0
end

local function isStanding(player)
	if not player or not player.Character then return false end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local vel = hrp.AssemblyLinearVelocity
	return Vector2.new(vel.X, vel.Z).Magnitude <= cfg.stillthreshold
end

local function hasForceField(player)
	if not player or not player.Character then return false end
	return player.Character:FindFirstChildOfClass("ForceField") ~= nil
end

local function isInVehicle(player)
	if not player or not player.Character then return false end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end
	return humanoid.SeatPart ~= nil
end

local function wallBetween(startPos, endPos, targetChar)
	local myChar = LocalPlayer.Character
	if not myChar then return true end
	local filter = {myChar}
	if targetChar then table.insert(filter, targetChar) end
	wallParams.FilterDescendantsInstances = filter
	local direction = endPos - startPos
	local distance = direction.Magnitude
	if distance <= 0.001 then return false end
	local unit = direction.Unit
	local currentStart = startPos
	local remaining = distance
	for _ = 1, 10 do
		local result = workspace:Raycast(currentStart, unit * remaining, wallParams)
		if not result then return false end
		local hit = result.Instance
		if hit.Transparency < 0.8 and hit.CanCollide then return true end
		local hitDist = (result.Position - currentStart).Magnitude
		remaining = remaining - hitDist - 0.01
		if remaining <= 0 then return false end
		currentStart = result.Position + unit * 0.01
	end
	return false
end

local function quickCheck(player)
	if not player or player == LocalPlayer or not player.Character then return false end
	local targetPart = getTargetPart(player.Character)
	if not targetPart then return false end
	if not isWithinAimDistance(targetPart.Position) then return false end
	if not isInCurrentGunRange(targetPart.Position) then return false end
	if cfg.deathcheck and isDead(player) then return false end
	if cfg.ffcheck and hasForceField(player) then return false end
	if cfg.vehiclecheck and isInVehicle(player) then return false end
	if cfg.teamcheck and player.Team == LocalPlayer.Team then return false end
	if cfg.criminalsnoinnmates then
		if LocalPlayer.Team == criminalsTeam and player.Team == inmatesTeam then return false end
	end
	if cfg.inmatesnocriminals then
		if LocalPlayer.Team == inmatesTeam and player.Team == criminalsTeam then return false end
	end
	if cfg.hostilecheck or cfg.trespasscheck then
		local isTaser = isTaserGun(currentGun)
		local bypassHostile = cfg.taserbypasshostile and isTaser
		local bypassTrespass = cfg.taserbypasstrespass and isTaser
		local targetChar = player.Character
		if LocalPlayer.Team == guardsTeam and player.Team == inmatesTeam then
			local hostile = targetChar:GetAttribute("Hostile")
			local trespass = targetChar:GetAttribute("Trespassing")
			if cfg.hostilecheck and cfg.trespasscheck then
				if not bypassHostile and not bypassTrespass then
					if not hostile and not trespass then return false end
				end
			elseif cfg.hostilecheck and not bypassHostile then
				if not hostile then return false end
			elseif cfg.trespasscheck and not bypassTrespass then
				if not trespass then return false end
			end
		end
	end
	return true
end

local function fullCheck(player)
	if not quickCheck(player) then return false end
	if cfg.wallcheck then
		local myChar = LocalPlayer.Character
		local myHead = myChar and myChar:FindFirstChild("Head")
		local targetPart = getTargetPart(player.Character)
		if myHead and targetPart then
			if wallBetween(myHead.Position, targetPart.Position, player.Character) then
				return false
			end
		end
	end
	return true
end

local function rollHit(chanceOverride)
	lastShotTime = os.clock()
	local chance = math.clamp(tonumber(chanceOverride) or tonumber(cfg.hitchance) or 0, 0, 100)
	if chance >= 100 then
		lastShotResult = true
	elseif chance <= 0 then
		lastShotResult = false
	else
		lastShotResult = rng:NextInteger(1, 100) <= chance
	end
	return lastShotResult
end

local function getDistanceBasedHitChance(targetPart, originPos)
	local baseChance = math.clamp(tonumber(cfg.hitchance) or 0, 0, 100)
	if not cfg.distancebasedhitchance then
		return baseChance
	end
	if not targetPart then
		return baseChance
	end
	local origin = originPos or getFireOriginPosition()
	if not origin then
		local originPart = getLocalAimOriginPart()
		origin = originPart and originPart.Position or nil
	end
	if not origin then
		return baseChance
	end
	local distance = (targetPart.Position - origin).Magnitude
	local selectedChance = baseChance
	local points = getDistanceHitchancePoints()
	for _, point in ipairs(points) do
		if point.distance > 0 and distance >= point.distance then
			selectedChance = point.chance
		end
	end
	return selectedChance
end

local function getMissPos(startPos, targetPartOrPos)
	local targetPart = typeof(targetPartOrPos) == "Instance" and targetPartOrPos:IsA("BasePart") and targetPartOrPos or nil
	local targetPos = targetPart and targetPart.Position or targetPartOrPos
	if not targetPos then return startPos end

	local toTarget = targetPos - startPos
	if toTarget.Magnitude <= 0.001 then
		return targetPos + Vector3.new(cfg.missspread + 6, 0, 0)
	end

	local direction = toTarget.Unit
	local reference = math.abs(direction.Y) > 0.98 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
	local right = direction:Cross(reference)
	if right.Magnitude <= 0.001 then
		right = Vector3.new(0, 0, 1)
	else
		right = right.Unit
	end

	local up = right:Cross(direction)
	if up.Magnitude <= 0.001 then
		up = Vector3.new(0, 1, 0)
	else
		up = up.Unit
	end

	local partRadius = targetPart and math.max(targetPart.Size.X, targetPart.Size.Y, targetPart.Size.Z) * 0.75 or 2
	local missRadius = math.max(cfg.missspread, partRadius + 3)
	local angle = rng:NextNumber(0, math.pi * 2)
	local offset = right * math.cos(angle) * missRadius + up * math.sin(angle) * missRadius
	return targetPos + offset
end

local function getFovTargetPriority(player)
	if not cfg.prioritizecriminals then
		return 0
	end
	if player.Team == criminalsTeam then
		return 0
	end
	if player.Team == inmatesTeam then
		return 1
	end
	return 0
end

local function getClosest(fovRadius)
	fovRadius = fovRadius or cfg.fov
	local camera = workspace.CurrentCamera
	if not camera then return nil, nil end

	local aimPos = getFovScreenPosition(camera)
	
	local now = os.clock()
	
	if cfg.targetstickiness and currentTarget and (now - targetSwitchTime) < currentStickiness then
		if fullCheck(currentTarget) then
			local part = getTargetPart(currentTarget.Character)
			if part then
				local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen and screenPos.Z > 0 then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude
					if dist < fovRadius then
						return currentTarget, part.Position
					end
				end
			end
		end
	end
	
	local candidates = {}
	
	for _, player in ipairs(Players:GetPlayers()) do
		if quickCheck(player) then
			local part = getTargetPart(player.Character)
			if part then
				local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen and screenPos.Z > 0 then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude
					if dist < fovRadius then
						candidates[#candidates + 1] = {
							player = player,
							dist = dist,
							part = part,
							priority = getFovTargetPriority(player)
						}
					end
				end
			end
		end
	end
	
	if cfg.prioritizeclosest then
		table.sort(candidates, function(a, b)
			if a.priority ~= b.priority then
				return a.priority < b.priority
			end
			return a.dist < b.dist
		end)
	else
		local bestPriority = math.huge
		for _, candidate in ipairs(candidates) do
			if candidate.priority < bestPriority then
				bestPriority = candidate.priority
			end
		end
		if bestPriority < math.huge then
			local prioritizedCandidates = {}
			for _, candidate in ipairs(candidates) do
				if candidate.priority == bestPriority then
					prioritizedCandidates[#prioritizedCandidates + 1] = candidate
				end
			end
			candidates = prioritizedCandidates
		end
		for i = #candidates, 2, -1 do
			local j = rng:NextInteger(1, i)
			candidates[i], candidates[j] = candidates[j], candidates[i]
		end
	end
	
	for _, candidate in ipairs(candidates) do
		if fullCheck(candidate.player) then
			local part = getTargetPart(candidate.player.Character)
			if not part then
				continue
			end
			if candidate.player ~= currentTarget then
				currentTarget = candidate.player
				targetSwitchTime = now
				if cfg.targetstickinessrandom then
					currentStickiness = rng:NextNumber(cfg.targetstickinessmin, cfg.targetstickinessmax)
				else
					currentStickiness = cfg.targetstickinessduration
				end
			end
			return candidate.player, part.Position
		end
	end
	
	currentTarget = nil
	return nil, nil
end

local ShootEvent = ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
local ReloadRemote = ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("FuncReload")
local Debris = game:GetService("Debris")

local function createBulletTrail(startPos, endPos, isTaser)
	local distance = (endPos - startPos).Magnitude
	local trail = Instance.new("Part")
	trail.Name = "BulletTrail"
	trail.Anchored = true
	trail.CanCollide = false
	trail.CanQuery = false
	trail.CanTouch = false
	trail.Material = Enum.Material.Neon
	trail.Size = Vector3.new(0.1, 0.1, distance)
	trail.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
	trail.Transparency = 0.5

	if isTaser then
		trail.BrickColor = BrickColor.new("Cyan")
		trail.Size = Vector3.new(0.2, 0.2, distance)
		local light = Instance.new("SurfaceLight")
		light.Color = Color3.fromRGB(0, 234, 255)
		light.Range = 7
		light.Brightness = 5
		light.Face = Enum.NormalId.Bottom
		light.Parent = trail
	else
		trail.BrickColor = BrickColor.Yellow()
	end

	trail.Parent = workspace
	Debris:AddItem(trail, isTaser and 0.8 or 0.1)
end

local function getBulletsLabel()
	if cachedBulletsLabel and cachedBulletsLabel.Parent then
		return cachedBulletsLabel
	end

	cachedBulletsLabel = nil
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local home = playerGui and playerGui:FindFirstChild("Home")
	local hud = home and home:FindFirstChild("hud")
	local bottomRight = hud and hud:FindFirstChild("BottomRightFrame")
	local gunFrame = bottomRight and bottomRight:FindFirstChild("GunFrame")
	cachedBulletsLabel = gunFrame and gunFrame:FindFirstChild("BulletsLabel") or nil
	return cachedBulletsLabel
end

local function requestReload(gun)
	local now = os.clock()
	if now - lastReloadRequest < 0.5 then
		return
	end
	if not gun or gun:GetAttribute("Local_ReloadSession") ~= 0 then
		return
	end
	local storedAmmo = gun:GetAttribute("StoredAmmo")
	if typeof(storedAmmo) == "number" and storedAmmo <= 0 then
		return
	end
	lastReloadRequest = now
	task.spawn(function()
		pcall(function()
			ReloadRemote:InvokeServer()
		end)
	end)
end

local function autoShoot()
	local gun = currentGun
	if not cfg.autoshoot or not cfg.enabled or not gun then return end
	if gun.Parent ~= LocalPlayer.Character then return end
	if not gunMatchesAutoShootWeapon(gun) then
		lastAutoTarget = nil
		return
	end

	local now = os.clock()
	local reloadSession = gun:GetAttribute("Local_ReloadSession") or 0
	if reloadSession ~= 0 or gun:GetAttribute("Local_IsShooting") then return end
	if not isSniperStable(gun) then return end

	local fireRate = math.max(gun:GetAttribute("FireRate") or 0, cfg.autoshootdelay)
	if now - lastAutoShoot < fireRate then return end

	local myChar = LocalPlayer.Character
	if not myChar then return end
	local myHead = myChar:FindFirstChild("Head")
	if not myHead then return end

	local muzzle = currentGun:FindFirstChild("Muzzle")
	local startPos = muzzle and muzzle.Position or myHead.Position

	local target, targetPos = getClosest(cfg.fov)
	if not target or not fullCheck(target) then 
		lastAutoTarget = nil
		return 
	end

	if target ~= lastAutoTarget then
		targetAcquiredTime = now
		lastAutoTarget = target
	end

	local acquireDelay = shouldUseInstantAcquireDelay(gun) and 0 or cfg.autoshootstartdelay
	local requiredDelay = math.max(acquireDelay, gun:GetAttribute("ChargeTime") or 0)
	if now - targetAcquiredTime < requiredDelay then return end

	local targetPart = getTargetPart(target.Character)
	if not targetPart then return end

	local weaponRange = gun:GetAttribute("Range")
	if weaponRange and (targetPart.Position - startPos).Magnitude > weaponRange + 5 then
		return
	end

	local ammo = gun:GetAttribute("Local_CurrentAmmo") or gun:GetAttribute("CurrentAmmo") or 0
	if ammo <= 0 then
		requestReload(gun)
		return
	end

	lastAutoShoot = now

	local isTaser = isTaserGun(gun)
	local sniper = isSniper(gun)
	local shotgun = isShotgun(gun)
	local shouldHit = false

	if cfg.taseralwayshit and isTaser then
		shouldHit = true
	elseif cfg.ifplayerstill and isStanding(target) then
		shouldHit = true
	elseif shouldBypassHitchance(gun) then
		shouldHit = true
	else
		shouldHit = rollHit(getDistanceBasedHitChance(targetPart, startPos))
	end

	local projectileCount = currentGun:GetAttribute("ProjectileCount") or 1
	local shots = {}

	for i = 1, projectileCount do
		local aimPoint
		if shouldHit then
			aimPoint = targetPart.Position
		else
			if cfg.missspread > 0 then
				aimPoint = getMissPos(startPos, targetPart)
			else
				return
			end
		end

		local hitPart = shouldHit and targetPart or nil
		local finalPos = aimPoint

		if shouldHit then
			if isTaser then
				local simulatedHit, simulatedPos = simulateProjectileImpact(startPos, aimPoint, gun)
				finalPos = simulatedPos
				hitPart = simulatedHit or targetPart
			elseif shotgun and cfg.shotgunnaturalspread then
				local simulatedHit, simulatedPos = simulateProjectileImpact(startPos, aimPoint, gun)
				finalPos = simulatedPos
				hitPart = simulatedHit or targetPart
			end
		end

		shots[i] = {myHead.Position, finalPos, hitPart}
		createBulletTrail(startPos, finalPos, isTaser)
	end

	ShootEvent:FireServer(shots)
	if gun ~= currentGun or gun.Parent ~= LocalPlayer.Character then return end

	local newAmmo = ammo - 1
	gun:SetAttribute("Local_CurrentAmmo", newAmmo)

	local bulletsLabel = getBulletsLabel()
	if bulletsLabel then
		if sniper then
			bulletsLabel.Text = newAmmo .. " | " .. (gun:GetAttribute("StoredAmmo") or 0)
		else
			bulletsLabel.Text = newAmmo .. "/" .. (gun:GetAttribute("MaxAmmo") or 30)
		end
	end

	local handle = gun:FindFirstChild("Handle")
	if handle then
		local shootSound = handle:FindFirstChild("ShootSound")
		if shootSound then
			local sound = shootSound:Clone()
			sound.Parent = handle
			sound:Play()
			Debris:AddItem(sound, 2)
		end
	end
end

local function getGun()
	local char = LocalPlayer.Character
	if not char then return nil end
	local children = char:GetChildren()
	for index = #children, 1, -1 do
		local tool = children[index]
		if tool:IsA("Tool") and tool:GetAttribute("ToolType") == "Gun" then
			return tool
		end
	end
	return nil
end


local function notify(title, text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 3
		})
	end)
end

local lastGun = nil

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	currentGun = getGun()
	if currentGun ~= lastGun then
		resetAimState()
		lastGun = currentGun
	end
	updateAutoGrab(now)
	autoShoot()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == cfg.togglekey then
		cfg.enabled = not cfg.enabled
		if uiElements.SilentAimToggle then uiElements.SilentAimToggle:UpdateState(cfg.enabled) end
		notify("Silent Aim", "Enabled: " .. tostring(cfg.enabled), 3)
	elseif input.KeyCode == cfg.esptoggle then
		cfg.esp = not cfg.esp
		if uiElements.EspToggle then uiElements.EspToggle:UpdateState(cfg.esp) end
		notify("ESP", "Enabled: " .. tostring(cfg.esp), 3)
	elseif input.KeyCode == cfg.c4esptoggle then
		cfg.c4esp = not cfg.c4esp
		if uiElements.C4EspToggle then uiElements.C4EspToggle:UpdateState(cfg.c4esp) end
		notify("C4 ESP", "Enabled: " .. tostring(cfg.c4esp), 3)
	end
end)

RunService.PreRender:Connect(function()
	local camera = workspace.CurrentCamera
	local fovPos = getFovScreenPosition(camera)

	fovCircle.Position = fovPos
	fovCircle.Radius = cfg.fov
	fovCircle.Visible = cfg.showfov and cfg.enabled

	if cfg.showtargetline and cfg.enabled then
		local target, targetPos = getClosest()
		if target and targetPos and camera then
			local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
			if onScreen then
				targetLine.From = fovPos
				targetLine.To = Vector2.new(screenPos.X, screenPos.Y)
				targetLine.Visible = true
			else
				targetLine.Visible = false
			end
		else
			targetLine.Visible = false
		end
	else
		targetLine.Visible = false
	end

	updateEsp()
	updateC4Esp()
end)

Players.PlayerRemoving:Connect(removeEsp)

local function bindPlayer(player)
	player.CharacterRemoving:Connect(function(char)
		randomPartCache[char] = nil
		if currentTarget and currentTarget == player then
			currentTarget = nil
		end
		if lastAutoTarget and lastAutoTarget == player then
			lastAutoTarget = nil
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	bindPlayer(player)
end
Players.PlayerAdded:Connect(bindPlayer)

local function clearEsp()
	for player, e in pairs(espCache) do
		if e then e:Destroy() end
		espCache[player] = nil
	end
	randomPartCache = {}
	currentTarget = nil
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	resetAimState()
	clearEsp()
end)

local function noUpvals(fn)
	return function(...) return fn(...) end
end

local origCastRay
local hooked = false

local function setupHook()
	local castRayFunc = filtergc("function", {Name = "castRay"}, true)
	if not castRayFunc then return false end

	origCastRay = hookfunction(castRayFunc, noUpvals(function(startPos, targetPos, ...)
		if not cfg.enabled then return origCastRay(startPos, targetPos, ...) end

		local closest = getClosest(cfg.fov)

		if closest and closest.Character then
			local gun = currentGun
			if not gun then
				return origCastRay(startPos, targetPos, ...)
			end
			local isTaser = isTaserGun(gun)
			local shotgun = isShotgun(gun)
			local sniperStable = isSniperStable(gun)
			local shouldHit = false
			local bypassHitchance = shouldBypassHitchance(gun)
			local targetPart = getTargetPart(closest.Character)

			if not targetPart then
				return origCastRay(startPos, targetPos, ...)
			end

			if not isInCurrentGunRange(targetPart.Position, startPos) then
				return origCastRay(startPos, targetPos, ...)
			end

			if cfg.shotgungamehandled and shotgun then
				return origCastRay(startPos, targetPart.Position, ...)
			end

			if cfg.taseralwayshit and isTaser then
				shouldHit = true
			elseif cfg.ifplayerstill and isStanding(closest) then
				shouldHit = true
			elseif bypassHitchance then
				shouldHit = true
			else
				shouldHit = rollHit(getDistanceBasedHitChance(targetPart, startPos))
			end

			if shouldHit then
				if isSniper(gun) and not sniperStable then
					return origCastRay(startPos, targetPart.Position, ...)
				end
				if isTaser then
					return origCastRay(startPos, targetPart.Position, ...)
				end
				if cfg.shotgunnaturalspread and shotgun then
					return origCastRay(startPos, targetPart.Position, ...)
				end
				return targetPart, targetPart.Position
			else
				if cfg.missspread > 0 then
					local missPos = getMissPos(startPos, targetPart)
					return origCastRay(startPos, missPos, ...)
				end
				return origCastRay(startPos, targetPos, ...)
			end
		end

		return origCastRay(startPos, targetPos, ...)
	end))

	return true
end

if not setupHook() then
	task.spawn(function()
		while not hooked do
			task.wait(0.5)
			if setupHook() then
				hooked = true
			end
		end
	end)
else
	hooked = true
end

notify("Silent Aim + ESP", "Loaded! RShift = Aim, RCtrl = ESP", 5)

local function replaceFirst(source, oldText, newText)
	local startIndex = string.find(source, oldText, 1, true)
	if not startIndex then
		return source, false
	end

	local endIndex = startIndex + #oldText - 1
	return string.sub(source, 1, startIndex - 1) .. newText .. string.sub(source, endIndex + 1), true
end

local function loadPatchedMacLib()
	local source = game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt")

	source = select(1, replaceFirst(
		source,
		'sliderBar.Size = UDim2.fromOffset(123, 3)',
		'sliderBar.Size = UDim2.fromOffset(123, 10)\n\t\t\t\t\tsliderBar.Active = true'
	))

	source = select(1, replaceFirst(
		source,
		'sliderHead.Size = UDim2.fromOffset(12, 12)',
		'sliderHead.Size = UDim2.fromOffset(16, 16)'
	))

	source = select(1, replaceFirst(
		source,
		[[					sliderHead.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							SetValue(input)
						end
					end)

					sliderHead.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
							if SliderFunctions.Settings.onInputComplete then
								SliderFunctions.Settings.onInputComplete(finalValue)
							end
						end
					end)]],
		[[					local function beginDrag(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							SetValue(input)
						end
					end

					local function endDrag(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
							if SliderFunctions.Settings.onInputComplete then
								SliderFunctions.Settings.onInputComplete(finalValue)
							end
						end
					end

					sliderHead.InputBegan:Connect(beginDrag)
					sliderBar.InputBegan:Connect(beginDrag)
					sliderHead.InputEnded:Connect(endDrag)
					sliderBar.InputEnded:Connect(endDrag)]]
	))

	return loadstring(source)()
end

local MacLib = loadPatchedMacLib()
local Folder = "Silent Aim"

local function getPreferredWindowSize()
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	if UserInputService.TouchEnabled then
		local maxWidth = math.min(1520, math.max(760, viewport.X - 20))
		local maxHeight = math.min(860, math.max(420, viewport.Y - 56))
		local minWidth = math.min(920, maxWidth)
		local minHeight = math.min(520, maxHeight)
		local width = math.floor(math.clamp(viewport.X * 0.9, minWidth, maxWidth))
		local height = math.floor(math.clamp(viewport.Y * 0.8, minHeight, maxHeight))
		return UDim2.fromOffset(width, height)
	end
	return UDim2.fromOffset(800, 600)
end

local Window = MacLib:Window({
	Title = "Prison Life Silent Aim",
	Subtitle = "Prison Life Exploit",
	Size = UDim2.fromOffset(800, 600),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = not UserInputService.TouchEnabled,
	Keybind = Enum.KeyCode.RightAlt,
	AcrylicBlur = true,
})

MacLib:SetFolder(Folder)

local function applyPreferredWindowSize()
	Window:SetSize(getPreferredWindowSize())
end

applyPreferredWindowSize()
task.defer(applyPreferredWindowSize)
task.delay(0.25, applyPreferredWindowSize)

if UserInputService.TouchEnabled then
	task.defer(function()
		pcall(function()
			Window:SetUserInfoState(false)
		end)
	end)
end

local clampMobileButtonPosition
local currentViewportConn = nil
local refreshMobileButtonVisibility
local syncMobileButtonLayer
local function bindWindowResizeToCamera()
	if currentViewportConn then
		currentViewportConn:Disconnect()
		currentViewportConn = nil
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	currentViewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if UserInputService.TouchEnabled then
			applyPreferredWindowSize()
			if clampMobileButtonPosition then
				clampMobileButtonPosition()
			end
		end
	end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindWindowResizeToCamera()
	if UserInputService.TouchEnabled then
		task.defer(applyPreferredWindowSize)
	end
end)

bindWindowResizeToCamera()

local function getMobileButtonParent()
	return (gethui and gethui()) or CoreGui
end

local function getClampedButtonCenter(rawCenter, buttonSize)
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local padding = 10
	local halfWidth = buttonSize.X * 0.5
	local halfHeight = buttonSize.Y * 0.5
	local minX = halfWidth + padding
	local maxX = math.max(minX, viewport.X - halfWidth - padding)
	local minY = halfHeight + padding
	local maxY = math.max(minY, viewport.Y - halfHeight - padding)
	return Vector2.new(
		math.clamp(rawCenter.X, minX, maxX),
		math.clamp(rawCenter.Y, minY, maxY)
	)
end

local function getDefaultMobileButtonCenter(buttonSize)
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local topOffset = math.max(118, viewport.Y * 0.12)
	local desiredCenter = Vector2.new(buttonSize.X * 0.5 + 28, topOffset + buttonSize.Y * 0.5)
	return getClampedButtonCenter(desiredCenter, buttonSize)
end

local function getInputPosition2D(input)
	local position = input and input.Position
	if not position then
		return Vector2.zero
	end
	return Vector2.new(position.X, position.Y)
end

clampMobileButtonPosition = function()
	if not mobileGuiButton or not mobileGuiButton.Parent then
		return
	end

	local currentCenter = Vector2.new(
		mobileGuiButton.AbsolutePosition.X + mobileGuiButton.AbsoluteSize.X * 0.5,
		mobileGuiButton.AbsolutePosition.Y + mobileGuiButton.AbsoluteSize.Y * 0.5
	)
	local clampedCenter = getClampedButtonCenter(currentCenter, mobileGuiButton.AbsoluteSize)
	mobileGuiButton.Position = UDim2.fromOffset(clampedCenter.X, clampedCenter.Y)
end

resolveMacLibWindowGui = function()
	local title = Window and Window.Settings and Window.Settings.Title or "Prison Life Silent Aim"
	local guiParent = getMobileButtonParent()
	local candidates = {guiParent}
	if guiParent ~= CoreGui then
		candidates[#candidates + 1] = CoreGui
	end

	for _, parent in ipairs(candidates) do
		for _, descendant in ipairs(parent:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text == title then
				return descendant:FindFirstAncestorOfClass("ScreenGui")
			end
		end
	end

	return nil
end

refreshMobileButtonVisibility = function()
	if not mobileGuiButton then
		return
	end

	mobileGuiButton.Visible = true
	mobileGuiButton.Active = true
end

syncMobileButtonLayer = function()
	if not mobileGuiButton then
		return
	end

	local screen = mobileGuiButton:FindFirstAncestorOfClass("ScreenGui")
	if not screen then
		return
	end

	local windowGui = resolveMacLibWindowGui and resolveMacLibWindowGui() or nil
	local targetParent = getMobileButtonParent()
	if windowGui and windowGui.Parent then
		targetParent = windowGui.Parent
	end

	screen.ScreenInsets = Enum.ScreenInsets.None
	screen.DisplayOrder = windowGui and windowGui.DisplayOrder or 2147483647

	if screen.Parent ~= targetParent then
		screen.Parent = targetParent
	end

	-- Reparent once so this layer collector is inserted after the menu.
	screen.Parent = nil
	screen.Parent = targetParent
end

local function toggleMacLibWindow()
	local windowGui = resolveMacLibWindowGui()
	if not windowGui then
		Window:Notify({
			Title = Window.Settings.Title,
			Description = "Couldn't find the window to toggle yet.",
			Lifetime = 3
		})
		return
	end

	windowGui.Enabled = not windowGui.Enabled
	refreshMobileButtonVisibility()
end

local function createMobileWindowButton()
	if not UserInputService.TouchEnabled then
		return
	end

	local existing = getMobileButtonParent():FindFirstChild("SilentAimMobileButton")
	if existing then
		existing:Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "SilentAimMobileButton"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.IgnoreGuiInset = true
	screen.ScreenInsets = Enum.ScreenInsets.None
	screen.DisplayOrder = 2147483647
	screen.Parent = getMobileButtonParent()

	local buttonSize = Vector2.new(68, 68)
	local defaultCenter = getDefaultMobileButtonCenter(buttonSize)
	local button = Instance.new("ImageButton")
	button.Name = "ToggleButton"
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.fromOffset(defaultCenter.X, defaultCenter.Y)
	button.Size = UDim2.fromOffset(buttonSize.X, buttonSize.Y)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Image = "rbxassetid://100746642581984"
	button.ScaleType = Enum.ScaleType.Fit
	button.Active = true
	button.ZIndex = 1000
	button.Parent = screen

	mobileGuiButton = button

	local dragInput = nil
	local dragStart = nil
	local startCenter = nil
	local moved = false
	local moveThreshold = 14

	button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragInput = input
		mobileGuiDragInput = input
		dragStart = getInputPosition2D(input)
		startCenter = Vector2.new(
			button.AbsolutePosition.X + button.AbsoluteSize.X * 0.5,
			button.AbsolutePosition.Y + button.AbsoluteSize.Y * 0.5
		)
		activeTouch = nil
		lastTouchAimPos = nil
		moved = false
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragStart and startCenter then
			local delta = getInputPosition2D(input) - dragStart

			if not moved then
				if delta.Magnitude < moveThreshold then
					return
				end
				moved = true
			end

			local nextCenter = getClampedButtonCenter(startCenter + delta, button.AbsoluteSize)
			button.Position = UDim2.fromOffset(nextCenter.X, nextCenter.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input ~= dragInput then
			return
		end

		local wasMoved = moved
		mobileGuiDragInput = nil
		dragInput = nil
		dragStart = nil
		startCenter = nil
		moved = false

		if wasMoved then
			clampMobileButtonPosition()
		else
			toggleMacLibWindow()
		end
	end)

	task.defer(clampMobileButtonPosition)
	task.defer(syncMobileButtonLayer)
	task.defer(refreshMobileButtonVisibility)
end

createMobileWindowButton()

task.defer(function()
	local windowGui = resolveMacLibWindowGui and resolveMacLibWindowGui() or nil
	syncMobileButtonLayer()
	if windowGui then
		windowGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			syncMobileButtonLayer()
			refreshMobileButtonVisibility()
		end)
	end
end)

local globalSettings = {
	UIBlurToggle = Window:GlobalSetting({
		Name = "UI Blur",
		Default = Window:GetAcrylicBlurState(),
		Callback = function(bool)
			Window:SetAcrylicBlurState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end,
	}),

	NotificationToggler = Window:GlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(bool)
			Window:SetNotificationsState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end,
	}),

	ShowUserInfo = Window:GlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(bool)
			Window:SetUserInfoState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end,
	})
}

local MainGroup = Window:TabGroup()

local AimbotTab = MainGroup:Tab({Name = "Aimbot", Image = "rbxassetid://4034483344"})
local DistanceHitchanceTab = MainGroup:Tab({Name = "Distance Hitchance", Image = "rbxassetid://4034483344"})
local ESPTab = MainGroup:Tab({Name = "ESP", Image = "rbxassetid://4034483345"})
local AutoshootTab = MainGroup:Tab({Name = "Autoshoot", Image = "rbxassetid://4034483346"})
local SettingsTab = MainGroup:Tab({Name = "Settings", Image = "rbxassetid://4034483347"})

local sections = {
	aimbotLeft = AimbotTab:Section({ Side = "Left" }),
	aimbotRight = AimbotTab:Section({ Side = "Right" }),
	distanceHitchanceLeft = DistanceHitchanceTab:Section({ Side = "Left" }),
	distanceHitchanceRight = DistanceHitchanceTab:Section({ Side = "Right" }),
	espLeft = ESPTab:Section({ Side = "Left" }),
	espRight = ESPTab:Section({ Side = "Right" }),
	autoshootLeft = AutoshootTab:Section({ Side = "Left" }),
	autoshootRight = AutoshootTab:Section({ Side = "Right" }),
	settingsLeft = SettingsTab:Section({ Side = "Left" }),
	settingsRight = SettingsTab:Section({ Side = "Right" })
}

AimbotTab:Select()

Window:Notify({
	Title = "Build Loaded",
	Description = string.format("GUI build %s loaded with Distance Hitchance tab.", version),
	Lifetime = 5
})

local configFolder = "SilentAimConfigs"
local autoloadConfigFile = configFolder .. "/_autoload.txt"

local function serializeColor3(color)
	return {R = color.R, G = color.G, B = color.B}
end

local function deserializeColor3(tbl)
	if tbl and tbl.R and tbl.G and tbl.B then
		return Color3.new(tbl.R, tbl.G, tbl.B)
	end
	return Color3.new(1, 1, 1)
end

local function serializeConfig()
	local data = {}
	for key, value in pairs(cfg) do
		if typeof(value) == "Color3" then
			data[key] = {type = "Color3", value = serializeColor3(value)}
		elseif typeof(value) == "EnumItem" then
			data[key] = {type = "EnumItem", value = tostring(value)}
		elseif typeof(value) == "table" then
			data[key] = {type = "table", value = value}
		else
			data[key] = {type = typeof(value), value = value}
		end
	end
	return game:GetService("HttpService"):JSONEncode(data)
end

local function deserializeConfig(jsonString)
	local success, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(jsonString)
	end)
	if not success then return nil end
	
	local result = {}
	for key, entry in pairs(data) do
		if entry.type == "Color3" then
			result[key] = deserializeColor3(entry.value)
		elseif entry.type == "EnumItem" then
			local enumPath = entry.value:match("Enum%.(.+)")
			if enumPath then
				local parts = enumPath:split(".")
				if #parts == 2 then
					local enumType = Enum[parts[1]]
					if enumType then
						result[key] = enumType[parts[2]]
					end
				end
			end
		elseif entry.type == "table" then
			result[key] = entry.value
		else
			result[key] = entry.value
		end
	end
	return result
end

local function saveConfig(name)
	if not isfolder then return false end
	if not isfolder(configFolder) then
		makefolder(configFolder)
	end
	local path = configFolder .. "/" .. name .. ".json"
	local data = serializeConfig()
	writefile(path, data)
	return true
end

local function loadConfig(name)
	if not isfolder or not isfile then return false end
	local path = configFolder .. "/" .. name .. ".json"
	if not isfile(path) then return false end
	
	local data = readfile(path)
	local loaded = deserializeConfig(data)
	if not loaded then return false end
	
	for key, value in pairs(loaded) do
		if cfg[key] ~= nil then
			cfg[key] = value
		end
	end
	syncDistanceHitchanceAimMaxDistanceFromConfig()
	return true
end

local function getConfigList()
	if not isfolder or not listfiles then return {} end
	if not isfolder(configFolder) then return {} end
	
	local files = listfiles(configFolder)
	local configs = {}
	for _, path in ipairs(files) do
		local name = path:match("([^/\\]+)%.json$")
		if name then
			table.insert(configs, name)
		end
	end
	return configs
end

local function deleteConfig(name)
	if not isfolder or not isfile or not delfile then return false end
	local path = configFolder .. "/" .. name .. ".json"
	if isfile(path) then
		delfile(path)
		return true
	end
	return false
end

local function getAutoLoadConfigName()
	if not isfolder or not isfile or not readfile then
		return ""
	end
	if not isfolder(configFolder) or not isfile(autoloadConfigFile) then
		return ""
	end
	return tostring(readfile(autoloadConfigFile) or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function setAutoLoadConfigName(name)
	if not isfolder or not writefile then
		return false
	end
	if not isfolder(configFolder) then
		makefolder(configFolder)
	end
	writefile(autoloadConfigFile, tostring(name or ""))
	return true
end

local function clearAutoLoadConfigName()
	if not isfolder or not isfile or not delfile then
		return false
	end
	if isfile(autoloadConfigFile) then
		delfile(autoloadConfigFile)
	end
	return true
end

local currentAutoLoadConfigName = getAutoLoadConfigName()
if currentAutoLoadConfigName ~= "" then
	if loadConfig(currentAutoLoadConfigName) then
		Window:Notify({
			Title = "Auto Load",
			Description = "Loaded config: " .. currentAutoLoadConfigName,
			Lifetime = 4
		})
	else
		Window:Notify({
			Title = "Auto Load",
			Description = "Couldn't load config: " .. currentAutoLoadConfigName,
			Lifetime = 4
		})
	end
end
syncDistanceHitchanceAimMaxDistanceFromConfig()

local function refreshUI()
	if uiElements.SilentAimToggle then uiElements.SilentAimToggle:UpdateState(cfg.enabled) end
	if uiElements.TeamCheckToggle then uiElements.TeamCheckToggle:UpdateState(cfg.teamcheck) end
	if uiElements.WallCheckToggle then uiElements.WallCheckToggle:UpdateState(cfg.wallcheck) end
	if uiElements.DeathCheckToggle then uiElements.DeathCheckToggle:UpdateState(cfg.deathcheck) end
	if uiElements.VehicleCheckToggle then uiElements.VehicleCheckToggle:UpdateState(cfg.vehiclecheck) end
	if uiElements.HostileCheckToggle then uiElements.HostileCheckToggle:UpdateState(cfg.hostilecheck) end
	if uiElements.TrespassCheckToggle then uiElements.TrespassCheckToggle:UpdateState(cfg.trespasscheck) end
	if uiElements.CriminalsSkipInmatesToggle then uiElements.CriminalsSkipInmatesToggle:UpdateState(cfg.criminalsnoinnmates) end
	if uiElements.InmatesSkipCriminalsToggle then uiElements.InmatesSkipCriminalsToggle:UpdateState(cfg.inmatesnocriminals) end
	if uiElements.FFCheckToggle then uiElements.FFCheckToggle:UpdateState(cfg.ffcheck) end
	if uiElements.ShieldBreakerToggle then uiElements.ShieldBreakerToggle:UpdateState(cfg.shieldbreaker) end
	if uiElements.ShieldFrontAngleSlider then uiElements.ShieldFrontAngleSlider:UpdateValue(cfg.shieldfrontangle) end
	if uiElements.ShieldRandomHeadToggle then uiElements.ShieldRandomHeadToggle:UpdateState(cfg.shieldrandomhead) end
	if uiElements.ShieldHeadChanceSlider then uiElements.ShieldHeadChanceSlider:UpdateValue(cfg.shieldheadchance) end
	if uiElements.TaserBypassHostileToggle then uiElements.TaserBypassHostileToggle:UpdateState(cfg.taserbypasshostile) end
	if uiElements.TaserBypassTrespassToggle then uiElements.TaserBypassTrespassToggle:UpdateState(cfg.taserbypasstrespass) end
	if uiElements.TaserAlwaysHitToggle then uiElements.TaserAlwaysHitToggle:UpdateState(cfg.taseralwayshit) end
	if uiElements.HitIfPlayerStillToggle then uiElements.HitIfPlayerStillToggle:UpdateState(cfg.ifplayerstill) end
	if uiElements.StillThresholdSlider then uiElements.StillThresholdSlider:UpdateValue(cfg.stillthreshold) end
	if uiElements.HitChanceSlider then uiElements.HitChanceSlider:UpdateValue(cfg.hitchance) end
	if uiElements.HitChanceAutoOnlyToggle then uiElements.HitChanceAutoOnlyToggle:UpdateState(cfg.hitchanceAutoOnly) end
	if uiElements.DistanceBasedHitChanceToggle then uiElements.DistanceBasedHitChanceToggle:UpdateState(cfg.distancebasedhitchance) end
	if uiElements.AimMaxDistSlider then uiElements.AimMaxDistSlider:UpdateValue(cfg.aimmaxdist) end
	if uiElements.MissSpreadSlider then uiElements.MissSpreadSlider:UpdateValue(cfg.missspread) end
	if uiElements.ShotgunNaturalSpreadToggle then uiElements.ShotgunNaturalSpreadToggle:UpdateState(cfg.shotgunnaturalspread) end
	if uiElements.ShotgunGameHandledToggle then uiElements.ShotgunGameHandledToggle:UpdateState(cfg.shotgungamehandled) end
	if uiElements.PrioritizeClosestToggle then uiElements.PrioritizeClosestToggle:UpdateState(cfg.prioritizeclosest) end
	if uiElements.PrioritizeCriminalsToggle then uiElements.PrioritizeCriminalsToggle:UpdateState(cfg.prioritizecriminals) end
	if uiElements.TargetStickinessToggle then uiElements.TargetStickinessToggle:UpdateState(cfg.targetstickiness) end
	if uiElements.StickinessDurationSlider then uiElements.StickinessDurationSlider:UpdateValue(cfg.targetstickinessduration) end
	if uiElements.TargetStickinessRandomToggle then uiElements.TargetStickinessRandomToggle:UpdateState(cfg.targetstickinessrandom) end
	if uiElements.TargetStickinessMinSlider then uiElements.TargetStickinessMinSlider:UpdateValue(cfg.targetstickinessmin) end
	if uiElements.TargetStickinessMaxSlider then uiElements.TargetStickinessMaxSlider:UpdateValue(cfg.targetstickinessmax) end
	if uiElements.FovSlider then uiElements.FovSlider:UpdateValue(cfg.fov) end
	if uiElements.ShowFovToggle then uiElements.ShowFovToggle:UpdateState(cfg.showfov) end
	if uiElements.StaticFovToggle then uiElements.StaticFovToggle:UpdateState(cfg.staticfov) end
	if uiElements.ShowTargetLineToggle then uiElements.ShowTargetLineToggle:UpdateState(cfg.showtargetline) end
	if uiElements.AimPartDropdown then uiElements.AimPartDropdown:UpdateSelection(cfg.aimpart) end
	if uiElements.RandomPartsToggle then uiElements.RandomPartsToggle:UpdateState(cfg.randomparts) end
	if uiElements.EspToggle then uiElements.EspToggle:UpdateState(cfg.esp) end
	if uiElements.EspTeamCheckToggle then uiElements.EspTeamCheckToggle:UpdateState(cfg.espteamcheck) end
	if uiElements.ShowTeamToggle then uiElements.ShowTeamToggle:UpdateState(cfg.espshowteam) end
	if uiElements.EspMaxDistanceSlider then uiElements.EspMaxDistanceSlider:UpdateValue(cfg.espmaxdist) end
	if uiElements.ShowDistanceToggle then uiElements.ShowDistanceToggle:UpdateState(cfg.espshowdist) end
	if uiElements.UseTeamColorsToggle then uiElements.UseTeamColorsToggle:UpdateState(cfg.espuseteamcolors) end
	if uiElements.EspColorPicker then uiElements.EspColorPicker:SetColor(cfg.espcolor) end
	if uiElements.GuardsColorPicker then uiElements.GuardsColorPicker:SetColor(cfg.espguards) end
	if uiElements.InmatesColorPicker then uiElements.InmatesColorPicker:SetColor(cfg.espinmates) end
	if uiElements.CriminalsColorPicker then uiElements.CriminalsColorPicker:SetColor(cfg.espcriminals) end
	if uiElements.TeamColorPicker then uiElements.TeamColorPicker:SetColor(cfg.espteam) end
	if uiElements.C4EspToggle then uiElements.C4EspToggle:UpdateState(cfg.c4esp) end
	if uiElements.C4EspMaxDistanceSlider then uiElements.C4EspMaxDistanceSlider:UpdateValue(cfg.c4espmaxdist) end
	if uiElements.C4ShowDistanceToggle then uiElements.C4ShowDistanceToggle:UpdateState(cfg.c4espshowdist) end
	if uiElements.C4EspColorPicker then uiElements.C4EspColorPicker:SetColor(cfg.c4espcolor) end
	if uiElements.AutoshootToggle then uiElements.AutoshootToggle:UpdateState(cfg.autoshoot) end
	if uiElements.AutoshootWeaponDropdown then uiElements.AutoshootWeaponDropdown:UpdateSelection(cfg.autoshootweapon) end
	if uiElements.AutoshootDelaySlider then uiElements.AutoshootDelaySlider:UpdateValue(cfg.autoshootdelay) end
	if uiElements.AutoshootStartDelaySlider then uiElements.AutoshootStartDelaySlider:UpdateValue(cfg.autoshootstartdelay) end
	if uiElements.AutoGrabToggle then uiElements.AutoGrabToggle:UpdateState(cfg.autograb) end
	if uiElements.AutoGrabDistanceSlider then uiElements.AutoGrabDistanceSlider:UpdateValue(cfg.autograbdistance) end
	if uiElements.AutoGrabDelaySlider then uiElements.AutoGrabDelaySlider:UpdateValue(cfg.autograbdelay) end
	if uiElements.AutoGrabKeycardToggle then uiElements.AutoGrabKeycardToggle:UpdateState(cfg.autograbkeycard) end
	if uiElements.AutoGrabM9Toggle then uiElements.AutoGrabM9Toggle:UpdateState(cfg.autograbm9) end
	syncDistanceHitchanceEditor()
	updateEsp()
	updateC4Esp()
end

uiElements.SilentAimToggle = sections.aimbotLeft:Toggle({
	Name = "Silent Aim",
	Default = cfg.enabled,
	Callback = function(state)
		cfg.enabled = state
	end,
}, "SilentAimToggle")

uiElements.TeamCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Team Check",
	Default = cfg.teamcheck,
	Callback = function(state)
		cfg.teamcheck = state
	end,
}, "TeamCheckToggle")

uiElements.WallCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Wall Check",
	Default = cfg.wallcheck,
	Callback = function(state)
		cfg.wallcheck = state
	end,
}, "WallCheckToggle")

uiElements.DeathCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Death Check",
	Default = cfg.deathcheck,
	Callback = function(state)
		cfg.deathcheck = state
	end,
}, "DeathCheckToggle")

uiElements.VehicleCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Vehicle Check",
	Default = cfg.vehiclecheck,
	Callback = function(state)
		cfg.vehiclecheck = state
	end,
}, "VehicleCheckToggle")

uiElements.HostileCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Hostile Check",
	Default = cfg.hostilecheck,
	Callback = function(state)
		cfg.hostilecheck = state
	end,
}, "HostileCheckToggle")

uiElements.TrespassCheckToggle = sections.aimbotLeft:Toggle({
	Name = "Trespass Check",
	Default = cfg.trespasscheck,
	Callback = function(state)
		cfg.trespasscheck = state
	end,
}, "TrespassCheckToggle")

uiElements.CriminalsSkipInmatesToggle = sections.aimbotLeft:Toggle({
	Name = "Criminals Skip Inmates",
	Default = cfg.criminalsnoinnmates,
	Callback = function(state)
		cfg.criminalsnoinnmates = state
	end,
}, "CriminalsSkipInmatesToggle")

uiElements.InmatesSkipCriminalsToggle = sections.aimbotLeft:Toggle({
	Name = "Inmates Skip Criminals",
	Default = cfg.inmatesnocriminals,
	Callback = function(state)
		cfg.inmatesnocriminals = state
	end,
}, "InmatesSkipCriminalsToggle")

uiElements.FFCheckToggle = sections.aimbotLeft:Toggle({
	Name = "ForceField Check",
	Default = cfg.ffcheck,
	Callback = function(state)
		cfg.ffcheck = state
	end,
}, "FFCheckToggle")

uiElements.ShieldBreakerToggle = sections.aimbotRight:Toggle({
	Name = "Shield Breaker",
	Default = cfg.shieldbreaker,
	Callback = function(state)
		cfg.shieldbreaker = state
	end,
}, "ShieldBreakerToggle")

uiElements.ShieldFrontAngleSlider = sections.aimbotRight:Slider({
	Name = "Shield Front Angle",
	Default = cfg.shieldfrontangle,
	Minimum = -1,
	Maximum = 1,
	Precision = 1,
	Callback = function(value)
		cfg.shieldfrontangle = value
	end,
}, "ShieldFrontAngleSlider")

uiElements.ShieldRandomHeadToggle = sections.aimbotRight:Toggle({
	Name = "Shield Random Head",
	Default = cfg.shieldrandomhead,
	Callback = function(state)
		cfg.shieldrandomhead = state
	end,
}, "ShieldRandomHeadToggle")

uiElements.ShieldHeadChanceSlider = sections.aimbotRight:Slider({
	Name = "Shield Head Chance",
	Default = cfg.shieldheadchance,
	Minimum = 0,
	Maximum = 100,
	Precision = 0,
	Callback = function(value)
		cfg.shieldheadchance = value
	end,
}, "ShieldHeadChanceSlider")

uiElements.TaserBypassHostileToggle = sections.aimbotRight:Toggle({
	Name = "Taser Bypass Hostile",
	Default = cfg.taserbypasshostile,
	Callback = function(state)
		cfg.taserbypasshostile = state
	end,
}, "TaserBypassHostileToggle")

uiElements.TaserBypassTrespassToggle = sections.aimbotRight:Toggle({
	Name = "Taser Bypass Trespass",
	Default = cfg.taserbypasstrespass,
	Callback = function(state)
		cfg.taserbypasstrespass = state
	end,
}, "TaserBypassTrespassToggle")

uiElements.TaserAlwaysHitToggle = sections.aimbotRight:Toggle({
	Name = "Taser Always Hit",
	Default = cfg.taseralwayshit,
	Callback = function(state)
		cfg.taseralwayshit = state
	end,
}, "TaserAlwaysHitToggle")

uiElements.HitIfPlayerStillToggle = sections.aimbotRight:Toggle({
	Name = "Hit If Player Still",
	Default = cfg.ifplayerstill,
	Callback = function(state)
		cfg.ifplayerstill = state
	end,
}, "HitIfPlayerStillToggle")

uiElements.StillThresholdSlider = sections.aimbotRight:Slider({
	Name = "Still Threshold",
	Default = cfg.stillthreshold,
	Minimum = 0,
	Maximum = 5,
	Precision = 1,
	Callback = function(value)
		cfg.stillthreshold = value
	end,
}, "StillThresholdSlider")

uiElements.HitChanceSlider = sections.aimbotRight:Slider({
	Name = "Hit Chance",
	Default = cfg.hitchance,
	Minimum = 0,
	Maximum = 100,
	Precision = 0,
	Callback = function(value)
		cfg.hitchance = value
	end,
}, "HitChanceSlider")

uiElements.HitChanceAutoOnlyToggle = sections.aimbotRight:Toggle({
	Name = "Hit Chance Auto Only",
	Default = cfg.hitchanceAutoOnly,
	Callback = function(state)
		cfg.hitchanceAutoOnly = state
	end,
}, "HitChanceAutoOnlyToggle")

uiElements.DistanceBasedHitChanceToggle = sections.distanceHitchanceLeft:Toggle({
	Name = "Distance Based Hitchance",
	Default = cfg.distancebasedhitchance,
	Callback = function(state)
		setDistanceHitchanceEnabledState(state)
		if uiElements.AimMaxDistSlider then
			uiElements.AimMaxDistSlider:UpdateValue(cfg.aimmaxdist)
		end
	end,
}, "DistanceBasedHitChanceToggle")

uiElements.DistanceHitchancePointDropdown = sections.distanceHitchanceLeft:Dropdown({
	Name = "Selected Point",
	Default = "1. 200 studs -> 30%",
	Options = {"1. 200 studs -> 30%"},
	Callback = function(value)
		if syncingDistanceHitchanceEditor then
			return
		end
		local selectedIndex = tonumber(tostring(value):match("^(%d+)%."))
		if selectedIndex then
			selectedDistanceHitchancePoint = selectedIndex
			syncDistanceHitchanceEditor()
		end
	end,
}, "DistanceHitchancePointDropdown")

sections.distanceHitchanceLeft:Button({
	Name = "Add Point",
	Callback = function()
		local points = ensureEditableDistanceHitchancePoints()
		local lastPoint = points[#points]
		local newPoint = {
			distance = lastPoint and (lastPoint.distance + 100) or 200,
			chance = lastPoint and math.max(lastPoint.chance - 8, 0) or 30
		}
		points[#points + 1] = newPoint
		table.sort(points, function(a, b)
			return a.distance < b.distance
		end)
		for index, point in ipairs(points) do
			if point == newPoint then
				selectedDistanceHitchancePoint = index
				break
			end
		end
		setDistanceHitchanceEnabledState(true)
		refreshUI()
		Window:Notify({
			Title = "Distance Hitchance",
			Description = "Added a new distance point.",
			Lifetime = 4
		})
	end,
})

sections.distanceHitchanceLeft:Button({
	Name = "Remove Selected",
	Callback = function()
		local points = ensureEditableDistanceHitchancePoints()
		if #points <= 1 then
			Window:Notify({
				Title = "Distance Hitchance",
				Description = "Keep at least one point in the list.",
				Lifetime = 4
			})
			return
		end
		table.remove(points, selectedDistanceHitchancePoint)
		selectedDistanceHitchancePoint = math.clamp(selectedDistanceHitchancePoint, 1, #points)
		refreshUI()
		Window:Notify({
			Title = "Distance Hitchance",
			Description = "Removed the selected point.",
			Lifetime = 4
		})
	end,
})

sections.distanceHitchanceLeft:Button({
	Name = "Load Legit Preset",
	Callback = function()
		loadLegitDistanceHitchancePreset()
		refreshUI()
		Window:Notify({
			Title = "Distance Hitchance",
			Description = "Loaded a legit distance preset and set base hitchance to 82.",
			Lifetime = 5
		})
	end,
})

sections.distanceHitchanceLeft:Button({
	Name = "Load Blatant Preset",
	Callback = function()
		loadBlatantDistanceHitchancePreset()
		refreshUI()
		Window:Notify({
			Title = "Distance Hitchance",
			Description = "Loaded a blatant distance preset and set base hitchance to 99.",
			Lifetime = 5
		})
	end,
})

sections.distanceHitchanceLeft:Button({
	Name = "Reset to Default",
	Callback = function()
		cfg.distancehitchancepoints = getDefaultDistanceHitchancePoints()
		selectedDistanceHitchancePoint = 1
		refreshUI()
		Window:Notify({
			Title = "Distance Hitchance",
			Description = "Reset the distance list back to the default build.",
			Lifetime = 4
		})
	end,
})

uiElements.SelectedDistancePointDistanceSlider = sections.distanceHitchanceRight:Slider({
	Name = "Selected Distance",
	Default = 200,
	Minimum = 0,
	Maximum = 5000,
	Precision = 0,
	Callback = function(value)
		if syncingDistanceHitchanceEditor then
			return
		end
		local points = ensureEditableDistanceHitchancePoints()
		local point = points[selectedDistanceHitchancePoint]
		if not point then
			return
		end
		point.distance = value
		table.sort(points, function(a, b)
			return a.distance < b.distance
		end)
		for index, existingPoint in ipairs(points) do
			if existingPoint == point then
				selectedDistanceHitchancePoint = index
				break
			end
		end
		syncDistanceHitchanceEditor()
	end,
}, "SelectedDistancePointDistanceSlider")

uiElements.SelectedDistancePointHitchanceSlider = sections.distanceHitchanceRight:Slider({
	Name = "Selected Hitchance",
	Default = 30,
	Minimum = 0,
	Maximum = 100,
	Precision = 0,
	Callback = function(value)
		if syncingDistanceHitchanceEditor then
			return
		end
		local points = ensureEditableDistanceHitchancePoints()
		local point = points[selectedDistanceHitchancePoint]
		if not point then
			return
		end
		point.chance = value
		syncDistanceHitchanceEditor()
	end,
}, "SelectedDistancePointHitchanceSlider")

uiElements.AimMaxDistSlider = sections.aimbotRight:Slider({
	Name = "Aim Max Distance (0 = Any)",
	Default = cfg.aimmaxdist,
	Minimum = 0,
	Maximum = 5000,
	Precision = 0,
	Callback = function(value)
		if cfg.distancebasedhitchance or distanceHitchanceForcesAimMaxDistance then
			storedAimMaxDistanceBeforeDistanceHitchance = value
			cfg.aimmaxdist = 0
			if uiElements.AimMaxDistSlider and value ~= 0 then
				uiElements.AimMaxDistSlider:UpdateValue(0)
			end
			return
		end
		cfg.aimmaxdist = value
	end,
}, "AimMaxDistSlider")

uiElements.MissSpreadSlider = sections.aimbotRight:Slider({
	Name = "Miss Spread",
	Default = cfg.missspread,
	Minimum = 0,
	Maximum = 20,
	Precision = 1,
	Callback = function(value)
		cfg.missspread = value
	end,
}, "MissSpreadSlider")

uiElements.ShotgunNaturalSpreadToggle = sections.aimbotRight:Toggle({
	Name = "Shotgun Natural Spread",
	Default = cfg.shotgunnaturalspread,
	Callback = function(state)
		cfg.shotgunnaturalspread = state
	end,
}, "ShotgunNaturalSpreadToggle")

uiElements.ShotgunGameHandledToggle = sections.aimbotRight:Toggle({
	Name = "Shotgun Game Handled",
	Default = cfg.shotgungamehandled,
	Callback = function(state)
		cfg.shotgungamehandled = state
	end,
}, "ShotgunGameHandledToggle")

uiElements.PrioritizeClosestToggle = sections.aimbotRight:Toggle({
	Name = "Prioritize Closest",
	Default = cfg.prioritizeclosest,
	Callback = function(state)
		cfg.prioritizeclosest = state
	end,
}, "PrioritizeClosestToggle")

uiElements.PrioritizeCriminalsToggle = sections.aimbotRight:Toggle({
	Name = "Prioritize Criminals",
	Default = cfg.prioritizecriminals,
	Callback = function(state)
		cfg.prioritizecriminals = state
	end,
}, "PrioritizeCriminalsToggle")

uiElements.TargetStickinessToggle = sections.aimbotRight:Toggle({
	Name = "Target Stickiness",
	Default = cfg.targetstickiness,
	Callback = function(state)
		cfg.targetstickiness = state
	end,
}, "TargetStickinessToggle")

uiElements.StickinessDurationSlider = sections.aimbotRight:Slider({
	Name = "Stickiness Duration",
	Default = cfg.targetstickinessduration,
	Minimum = 0.1,
	Maximum = 2,
	Precision = 1,
	Callback = function(value)
		cfg.targetstickinessduration = value
	end,
}, "StickinessDurationSlider")

uiElements.TargetStickinessRandomToggle = sections.aimbotRight:Toggle({
	Name = "Target Stickiness Random",
	Default = cfg.targetstickinessrandom,
	Callback = function(state)
		cfg.targetstickinessrandom = state
	end,
}, "TargetStickinessRandomToggle")

uiElements.TargetStickinessMinSlider = sections.aimbotRight:Slider({
	Name = "Target Stickiness Min",
	Default = cfg.targetstickinessmin,
	Minimum = 0.1,
	Maximum = 1,
	Precision = 1,
	Callback = function(value)
		cfg.targetstickinessmin = value
	end,
}, "TargetStickinessMinSlider")

uiElements.TargetStickinessMaxSlider = sections.aimbotRight:Slider({
	Name = "Target Stickiness Max",
	Default = cfg.targetstickinessmax,
	Minimum = 0.1,
	Maximum = 1,
	Precision = 1,
	Callback = function(value)
		cfg.targetstickinessmax = value
	end,
}, "TargetStickinessMaxSlider")

uiElements.FovSlider = sections.aimbotRight:Slider({
	Name = "FOV",
	Default = cfg.fov,
	Minimum = 10,
	Maximum = 500,
	Precision = 0,
	Callback = function(value)
		cfg.fov = value
	end,
}, "FovSlider")

uiElements.ShowFovToggle = sections.aimbotRight:Toggle({
	Name = "Show FOV",
	Default = cfg.showfov,
	Callback = function(state)
		cfg.showfov = state
	end,
}, "ShowFovToggle")

uiElements.StaticFovToggle = sections.aimbotRight:Toggle({
	Name = "Static FOV",
	Default = cfg.staticfov,
	Callback = function(state)
		cfg.staticfov = state
	end,
}, "StaticFovToggle")

uiElements.ShowTargetLineToggle = sections.aimbotRight:Toggle({
	Name = "Show Target Line",
	Default = cfg.showtargetline,
	Callback = function(state)
		cfg.showtargetline = state
	end,
}, "ShowTargetLineToggle")

uiElements.AimPartDropdown = sections.aimbotRight:Dropdown({
	Name = "Aim Part",
	Default = cfg.aimpart,
	Options = cfg.partslist,
	Callback = function(value)
		cfg.aimpart = value
	end,
}, "AimPartDropdown")

uiElements.RandomPartsToggle = sections.aimbotRight:Toggle({
	Name = "Random Parts",
	Default = cfg.randomparts,
	Callback = function(state)
		cfg.randomparts = state
	end,
}, "RandomPartsToggle")

uiElements.EspToggle = sections.espLeft:Toggle({
	Name = "ESP",
	Default = cfg.esp,
	Callback = function(state)
		cfg.esp = state
		updateEsp()
	end,
}, "EspToggle")

uiElements.EspTeamCheckToggle = sections.espLeft:Toggle({
	Name = "ESP Team Check",
	Default = cfg.espteamcheck,
	Callback = function(state)
		cfg.espteamcheck = state
		updateEsp()
	end,
}, "EspTeamCheckToggle")

uiElements.ShowTeamToggle = sections.espLeft:Toggle({
	Name = "Show Team",
	Default = cfg.espshowteam,
	Callback = function(state)
		cfg.espshowteam = state
		updateEsp()
	end,
}, "ShowTeamToggle")

uiElements.EspMaxDistanceSlider = sections.espLeft:Slider({
	Name = "ESP Max Distance (0 = Any)",
	Default = cfg.espmaxdist,
	Minimum = 0,
	Maximum = 5000,
	Precision = 0,
	Callback = function(value)
		cfg.espmaxdist = value
		updateEsp()
	end,
}, "EspMaxDistanceSlider")

uiElements.ShowDistanceToggle = sections.espLeft:Toggle({
	Name = "Show Distance",
	Default = cfg.espshowdist,
	Callback = function(state)
		cfg.espshowdist = state
		updateEsp()
	end,
}, "ShowDistanceToggle")

uiElements.UseTeamColorsToggle = sections.espLeft:Toggle({
	Name = "Use Team Colors",
	Default = cfg.espuseteamcolors,
	Callback = function(state)
		cfg.espuseteamcolors = state
		updateEsp()
	end,
}, "UseTeamColorsToggle")

uiElements.EspColorPicker = sections.espLeft:Colorpicker({
	Name = "ESP Color",
	Default = cfg.espcolor,
	Callback = function(color)
		cfg.espcolor = color
		updateEsp()
	end,
}, "EspColorPicker")

uiElements.GuardsColorPicker = sections.espLeft:Colorpicker({
	Name = "Guards Color",
	Default = cfg.espguards,
	Callback = function(color)
		cfg.espguards = color
		updateEsp()
	end,
}, "GuardsColorPicker")

uiElements.InmatesColorPicker = sections.espLeft:Colorpicker({
	Name = "Inmates Color",
	Default = cfg.espinmates,
	Callback = function(color)
		cfg.espinmates = color
		updateEsp()
	end,
}, "InmatesColorPicker")

uiElements.CriminalsColorPicker = sections.espLeft:Colorpicker({
	Name = "Criminals Color",
	Default = cfg.espcriminals,
	Callback = function(color)
		cfg.espcriminals = color
		updateEsp()
	end,
}, "CriminalsColorPicker")

uiElements.TeamColorPicker = sections.espLeft:Colorpicker({
	Name = "Team Color",
	Default = cfg.espteam,
	Callback = function(color)
		cfg.espteam = color
		updateEsp()
	end,
}, "TeamColorPicker")

uiElements.C4EspToggle = sections.espRight:Toggle({
	Name = "C4 ESP",
	Default = cfg.c4esp,
	Callback = function(state)
		cfg.c4esp = state
		updateC4Esp()
	end,
}, "C4EspToggle")

uiElements.C4EspMaxDistanceSlider = sections.espRight:Slider({
	Name = "C4 ESP Max Distance (0 = Any)",
	Default = cfg.c4espmaxdist,
	Minimum = 0,
	Maximum = 5000,
	Precision = 0,
	Callback = function(value)
		cfg.c4espmaxdist = value
		updateC4Esp()
	end,
}, "C4EspMaxDistanceSlider")

uiElements.C4ShowDistanceToggle = sections.espRight:Toggle({
	Name = "C4 Show Distance",
	Default = cfg.c4espshowdist,
	Callback = function(state)
		cfg.c4espshowdist = state
		updateC4Esp()
	end,
}, "C4ShowDistanceToggle")

uiElements.C4EspColorPicker = sections.espRight:Colorpicker({
	Name = "C4 ESP Color",
	Default = cfg.c4espcolor,
	Callback = function(color)
		cfg.c4espcolor = color
		updateC4Esp()
	end,
}, "C4EspColorPicker")

uiElements.AutoshootToggle = sections.autoshootLeft:Toggle({
	Name = "Autoshoot",
	Default = cfg.autoshoot,
	Callback = function(state)
		cfg.autoshoot = state
	end,
}, "AutoshootToggle")

uiElements.AutoshootWeaponDropdown = sections.autoshootRight:Dropdown({
	Name = "Autoshoot Weapon",
	Default = cfg.autoshootweapon,
	Options = {"Any", "Taser", "M9", "AK-47", "M4A1", "Remington 870", "Revolver", "Shotgun", "Sniper", "Automatic"},
	Callback = function(value)
		cfg.autoshootweapon = value
	end,
}, "AutoshootWeaponDropdown")

uiElements.AutoshootDelaySlider = sections.autoshootLeft:Slider({
	Name = "Autoshoot Delay",
	Default = cfg.autoshootdelay,
	Minimum = 0.05,
	Maximum = 0.5,
	Precision = 1,
	Callback = function(value)
		cfg.autoshootdelay = value
	end,
}, "AutoshootDelaySlider")

uiElements.AutoshootStartDelaySlider = sections.autoshootLeft:Slider({
	Name = "Autoshoot Start Delay",
	Default = cfg.autoshootstartdelay,
	Minimum = 0,
	Maximum = 1,
	Precision = 1,
	Callback = function(value)
		cfg.autoshootstartdelay = value
	end,
}, "AutoshootStartDelaySlider")

uiElements.AutoGrabToggle = sections.autoshootRight:Toggle({
	Name = "Auto Grab",
	Default = cfg.autograb,
	Callback = function(state)
		cfg.autograb = state
	end,
}, "AutoGrabToggle")

uiElements.AutoGrabDistanceSlider = sections.autoshootRight:Slider({
	Name = "Auto Grab Distance",
	Default = cfg.autograbdistance,
	Minimum = 0,
	Maximum = 12,
	Precision = 1,
	Callback = function(value)
		cfg.autograbdistance = value
	end,
}, "AutoGrabDistanceSlider")

uiElements.AutoGrabDelaySlider = sections.autoshootRight:Slider({
	Name = "Auto Grab Delay",
	Default = cfg.autograbdelay,
	Minimum = 0,
	Maximum = 3,
	Precision = 1,
	Callback = function(value)
		cfg.autograbdelay = value
	end,
}, "AutoGrabDelaySlider")

uiElements.AutoGrabKeycardToggle = sections.autoshootRight:Toggle({
	Name = "Grab Keycards",
	Default = cfg.autograbkeycard,
	Callback = function(state)
		cfg.autograbkeycard = state
	end,
}, "AutoGrabKeycardToggle")

uiElements.AutoGrabM9Toggle = sections.autoshootRight:Toggle({
	Name = "Grab M9",
	Default = cfg.autograbm9,
	Callback = function(state)
		cfg.autograbm9 = state
	end,
}, "AutoGrabM9Toggle")

local configNameInput = currentAutoLoadConfigName ~= "" and currentAutoLoadConfigName or ""

sections.settingsLeft:Input({
	Name = "Config Name",
	Placeholder = "Enter config name...",
	Callback = function(text)
		configNameInput = text
	end,
}, "ConfigNameInput")

sections.settingsLeft:Button({
	Name = "Save Config",
	Callback = function()
		if configNameInput == "" then
			Window:Notify({
				Title = "Config",
				Description = "Please enter a config name!",
				Lifetime = 3
			})
			return
		end
		if saveConfig(configNameInput) then
			Window:Notify({
				Title = "Config",
				Description = "Saved config: " .. configNameInput,
				Lifetime = 3
			})
		else
			Window:Notify({
				Title = "Config",
				Description = "Failed to save config!",
				Lifetime = 3
			})
		end
	end,
})

sections.settingsLeft:Button({
	Name = "Load Config",
	Callback = function()
		if configNameInput == "" then
			Window:Notify({
				Title = "Config",
				Description = "Please enter a config name!",
				Lifetime = 3
			})
			return
		end
		if loadConfig(configNameInput) then
			refreshUI()
			Window:Notify({
				Title = "Config",
				Description = "Loaded config: " .. configNameInput,
				Lifetime = 3
			})
		else
			Window:Notify({
				Title = "Config",
				Description = "Config not found: " .. configNameInput,
				Lifetime = 3
			})
		end
	end,
})

sections.settingsLeft:Button({
	Name = "Delete Config",
	Callback = function()
		if configNameInput == "" then
			Window:Notify({
				Title = "Config",
				Description = "Please enter a config name!",
				Lifetime = 3
			})
			return
		end
		if deleteConfig(configNameInput) then
			Window:Notify({
				Title = "Config",
				Description = "Deleted config: " .. configNameInput,
				Lifetime = 3
			})
		else
			Window:Notify({
				Title = "Config",
				Description = "Config not found: " .. configNameInput,
				Lifetime = 3
			})
		end
	end,
})

sections.settingsLeft:Button({
	Name = "List Configs",
	Callback = function()
		local configs = getConfigList()
		if #configs == 0 then
			Window:Notify({
				Title = "Configs",
				Description = "No configs found!",
				Lifetime = 5
			})
		else
			Window:Notify({
				Title = "Configs",
				Description = table.concat(configs, ", "),
				Lifetime = 10
			})
		end
	end,
})

sections.settingsRight:Button({
	Name = "Set Auto Load",
	Callback = function()
		if configNameInput == "" then
			Window:Notify({
				Title = "Auto Load",
				Description = "Enter a config name first.",
				Lifetime = 3
			})
			return
		end
		if not isfile or not isfile(configFolder .. "/" .. configNameInput .. ".json") then
			Window:Notify({
				Title = "Auto Load",
				Description = "Config not found: " .. configNameInput,
				Lifetime = 3
			})
			return
		end
		if setAutoLoadConfigName(configNameInput) then
			currentAutoLoadConfigName = configNameInput
			Window:Notify({
				Title = "Auto Load",
				Description = "Will auto load: " .. configNameInput,
				Lifetime = 4
			})
		else
			Window:Notify({
				Title = "Auto Load",
				Description = "Failed to save auto load config.",
				Lifetime = 3
			})
		end
	end,
})

sections.settingsRight:Button({
	Name = "Load Auto Config Now",
	Callback = function()
		local autoName = getAutoLoadConfigName()
		if autoName == "" then
			Window:Notify({
				Title = "Auto Load",
				Description = "No auto load config set.",
				Lifetime = 3
			})
			return
		end
		if loadConfig(autoName) then
			currentAutoLoadConfigName = autoName
			configNameInput = autoName
			refreshUI()
			Window:Notify({
				Title = "Auto Load",
				Description = "Loaded auto config: " .. autoName,
				Lifetime = 4
			})
		else
			Window:Notify({
				Title = "Auto Load",
				Description = "Config not found: " .. autoName,
				Lifetime = 3
			})
		end
	end,
})

sections.settingsRight:Button({
	Name = "Clear Auto Load",
	Callback = function()
		if clearAutoLoadConfigName() then
			currentAutoLoadConfigName = ""
			Window:Notify({
				Title = "Auto Load",
				Description = "Cleared auto load config.",
				Lifetime = 3
			})
		else
			Window:Notify({
				Title = "Auto Load",
				Description = "Failed to clear auto load config.",
				Lifetime = 3
			})
		end
	end,
})

sections.settingsRight:Button({
	Name = "Reset to Defaults",
	Callback = function()
		for key, value in pairs(defaultCfg) do
			cfg[key] = deepCopyTable(value)
		end
		syncDistanceHitchanceAimMaxDistanceFromConfig()
		resetAimState()
		refreshUI()
		Window:Notify({
			Title = "Config",
			Description = "Reset to defaults!",
			Lifetime = 3
		})
	end,
})

refreshUI()
