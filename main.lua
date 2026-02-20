local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/stk7702-hub/Uilibrary/refs/heads/main/library.lua"))()

-- ============================================================
-- CONSTANTS
-- ============================================================

local CONSTANTS = {
	PREDICTION_BASE = 0.095,
	PREDICTION_TAU = 0.15,
	SERVER_TICK = 1 / 60,
	MAX_VELOCITY = 150,
	JUMP_MULTIPLIER = 1.0,

	FLY_SPEED_MIN = 0.5,
	FLY_SPEED_MAX = 5,
	CFRAME_SPEED_MIN = 0.1,
	CFRAME_SPEED_MAX = 2,

	FLY_CORE_NAME = "RayFlyCore",
	FLY_CORE_SIZE = Vector3.new(0.05, 0.05, 0.05),
	FLY_MAX_FORCE = 9e9,
	FLY_GYRO_MAX_TORQUE = 9e9,
	FLY_GYRO_P = 9e4,

	CAMERA_SMOOTH_TAU_MIN = 0.02,
	CAMERA_SMOOTH_TAU_MAX = 0.3,
	CAMERA_MAX_ANGULAR_SPEED = 720,
	CAMERA_DEADZONE_ANGLE = 0.5,
	CAMERA_DEADZONE_SHIFTLOCK = 1.0,

	VELOCITY_HISTORY_FRAMES = 15,
	VELOCITY_TAU_MIN = 0.05,
	VELOCITY_TAU_MAX = 0.35,
	VELOCITY_TAU_RANGE = 0.30,
	VELOCITY_JUMP_TAU_MULT = 0.7,
	VELOCITY_CHAOS_WALK_RATIO = 1.5,

	ANTI_FLING_MAX_LINEAR = 50,
	ANTI_FLING_MAX_ANGULAR = 10,

	COMBAT_MIN_FIRE_RATE = 0.03,
	COMBAT_DEFAULT_FIRE_RATE = 0.1,
	COMBAT_KNOCK_MAX_SHOTS = 100,
	COMBAT_KILL_MAX_SHOTS = 150,
	COMBAT_MAX_STOMPS = 20,
	COMBAT_STOMP_DELAY = 0.25,
	COMBAT_TELEPORT_HEIGHT = 20,
	COMBAT_STOMP_HEIGHT = 3,
	COMBAT_HIDDEN_BULLETS_OFFSET = 12,
	COMBAT_LOOP_DELAY = 0,

	SMART_TP_RAY_UP = 25,
	SMART_TP_RAY_SIDE = 8,
	SMART_TP_SAFE_HEIGHT = 15,
	SMART_TP_SAFE_BEHIND = 5,
	SMART_TP_SAFE_SIDE = 6,
	SMART_TP_MIN_CLEARANCE = 3,

	THREAT_RANGE = 16,
	DETECTION_OFFSET_X = 100,
	DETECTION_OFFSET_YMIN = 50,
	DETECTION_OFFSET_YMAX = 150,
	DETECTION_OFFSET_Z = 100,

	FLY_CAR_SPEED_MULT = 300,
	FLY_CAR_GYRO_P = 50000,
	FLY_CAR_GYRO_D = 500,

	PRIORITY_NONE = 0,
	PRIORITY_LEGIT = 25,
	PRIORITY_RAGE = 50,
	PRIORITY_MANUAL = 100,

	THREAT_MEMORY_SECONDS = 3,
	THREAT_AIM_DOT = 0.7,
	THREAT_NEARBY_RANGE = 150,

	AUTOBUY_QUEUE_INTERVAL = 0.5,
	AUTOBUY_PURCHASE_COOLDOWN = 5,
	AUTOBUY_AMMO_COOLDOWN = 1.5,
	AUTOBUY_EXTRA_WAIT = 0.1,

	CHATSPY_MAX_MESSAGES = 100,

	MOD_GROUP_ID = 4698921,
	MOD_KICK_REASON = "Moderator on server (Security Kick)",
	MOD_BLACKLISTED_ROLES = {
		"Testers", "Moderators", "Contributed", "Monetization",
		"ADMlN", "Admin", "Administrator", "Owner",
	},

	WEAPONS_NO_HOLD_FIRE = {
		["GLOCK"] = true, ["SILENCER"] = true, ["DOUBLE BARREL"] = true,
		["SHOTGUN"] = true, ["TACTICAL SHOTGUN"] = true, ["REVOLVER"] = true, ["AUG"] = true,
	},
	WEAPONS_NO_SILENT = {
		["GRENADE"] = true, ["RPG"] = true, ["FLAMETHROWER"] = true,
	},
	WEAPONS_MELEE = {
		["PITCHFORK"] = true, ["KNIFE"] = true, ["BAT"] = true, ["STOP SIGN"] = true,
		["SHOVEL"] = true, ["SLEDGEHAMMER"] = true, ["KICKBOXING"] = true, ["BOXING"] = true,
	},

	AUTO_PRED_DIVISORS = {
		{ threshold = 10, divisor = 300 },
		{ threshold = 25, divisor = 250 },
		{ threshold = 40, divisor = 200 },
		{ fallback = 150 },
	},

	-- Приоритет оружия для Kill/Knock/AutoKill на основе эффективности
	-- Score: урон_за_магазин / время_опустошения (чем выше = тем лучше)
	WEAPON_KILL_PRIORITY = {
		-- Shotguns: лучшие для Kill через десинк (близкая дистанция)
		["DOUBLE BARREL"] =    { score = 100, type = "shotgun" },
		["SHOTGUN"] =          { score = 95,  type = "shotgun" },
		["TACTICAL SHOTGUN"] = { score = 90,  type = "shotgun" },
		
		-- High DPS automatic: много патронов, хороший урон
		["LMG"] =              { score = 85,  type = "auto" },
		["AK47"] =             { score = 80,  type = "auto" },
		["DRUMGUN"] =          { score = 75,  type = "auto" },
		["AR"] =               { score = 70,  type = "auto" },
		["SILENCERAR"] =       { score = 68,  type = "auto" },
		["P90"] =              { score = 65,  type = "auto" },
		["SMG"] =              { score = 60,  type = "auto" },
		
		-- Pistols: слабые, но лучше чем ничего
		["REVOLVER"] =         { score = 50,  type = "pistol" },
		["SILENCER"] =         { score = 35,  type = "pistol" },
		["GLOCK"] =            { score = 30,  type = "pistol" },
		
		-- Burst: AUG стреляет очередями, неудобно для AutoKill
		["AUG"] =              { score = 55,  type = "burst" },
		
		-- Special: Rifle мало патронов, долгий кулдаун
		["RIFLE"] =            { score = 40,  type = "sniper" },
		["FLINTLOCK"] =        { score = 20,  type = "sniper" },
	},
}

-- ============================================================
-- SERVICES
-- ============================================================

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	TweenService = game:GetService("TweenService"),
	Stats = game:GetService("Stats"),
	TextChatService = game:GetService("TextChatService"),
	CoreGui = game:GetService("CoreGui"),
	StarterGui = game:GetService("StarterGui"),
	Workspace = game:GetService("Workspace"),
	GuiService = game:GetService("GuiService"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local MainEvent = Services.ReplicatedStorage:WaitForChild("MainEvent")

-- ============================================================
-- THEME CONFIG
-- ============================================================

local ThemeConfig = {
	Accent = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(0, 0, 0),
	Header = Color3.fromRGB(0, 0, 0),
	Panel = Color3.fromRGB(10, 10, 10),
	Field = Color3.fromRGB(20, 20, 20),
	Stroke = Color3.fromRGB(30, 30, 30),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(255, 255, 255),
	Warning = Color3.fromRGB(255, 160, 92),
	Shadow = Color3.fromRGB(0, 0, 0),
	SliderAccent = Color3.fromRGB(255, 255, 255),
	ToggleAccent = Color3.fromRGB(255, 255, 255),
	TabSelected = Color3.fromRGB(255, 255, 255),
	TabUnselected = Color3.fromRGB(75, 75, 75),
	ProfileStroke = Color3.fromRGB(255, 255, 255),
	LogoText = Color3.fromRGB(229, 229, 229),
	LogoStroke = Color3.fromRGB(255, 255, 255),
	UsernameText = Color3.fromRGB(255, 255, 255),
	ExpireLabel = Color3.fromRGB(150, 150, 150),
	ExpireText = Color3.fromRGB(0, 255, 0),
	DropdownSelected = Color3.fromRGB(0, 255, 0),
}

-- ============================================================
-- UTILITY CLASS
-- ============================================================

local Util = {}

function Util.GetCharacterParts(player)
	player = player or LocalPlayer
	local character = player.Character
	if not character then return nil, nil, nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil, nil, nil end
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("LowerTorso")
	if not rootPart then return nil, nil, nil end
	return character, humanoid, rootPart
end

function Util.GetMousePosition()
	return Services.UserInputService:GetMouseLocation()
end

function Util.WorldToScreen(position)
	local screenPos, onScreen = Camera:WorldToViewportPoint(position)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function Util.GetDistanceFromCrosshair(position)
	local screenPos, onScreen = Util.WorldToScreen(position)
	if not onScreen then return math.huge end
	return (screenPos - Util.GetMousePosition()).Magnitude
end

function Util.GetWorldDistance(fromPos, toPos)
	return (fromPos - toPos).Magnitude
end

function Util.IsVisible(origin, targetPart)
	if not targetPart then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {
		LocalPlayer.Character, Camera,
		workspace:FindFirstChild("Bush"),
		workspace:FindFirstChild("Ignored"),
	}
	local direction = (targetPart.Position - origin)
	local result = workspace:Raycast(origin, direction, rayParams)
	if not result then return true end
	local targetChar = targetPart:FindFirstAncestorOfClass("Model")
	return targetChar and result.Instance:IsDescendantOf(targetChar)
end

function Util.IsCharacterAlive(character)
	if not character or not character.Parent then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	local bodyEffects = character:FindFirstChild("BodyEffects")
	if bodyEffects then
		local ko = bodyEffects:FindFirstChild("K.O")
		if ko and ko.Value then return false end
		local dead = bodyEffects:FindFirstChild("Dead")
		if dead and dead.Value then return false end
	end
	return true
end

function Util.IsCharacterAliveOrKO(character)
	if not character or not character.Parent then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	local bodyEffects = character:FindFirstChild("BodyEffects")
	if bodyEffects then
		local dead = bodyEffects:FindFirstChild("Dead")
		if dead and dead.Value then return false end
	end
	return true
end

function Util.IsTargetKO(character)
	if not character then return false end
	local bodyEffects = character:FindFirstChild("BodyEffects")
	if not bodyEffects then return false end
	local ko = bodyEffects:FindFirstChild("K.O")
	return ko and ko.Value == true
end

function Util.GetHitboxPart(character, hitboxName)
	if not character then return nil end
	hitboxName = hitboxName or "Head"

	if hitboxName == "Nearest" then
		local mousePos = Util.GetMousePosition()
		local parts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
		local closestPart, closestDist = nil, math.huge
		for _, partName in ipairs(parts) do
			local part = character:FindFirstChild(partName)
			if part then
				local screenPos, onScreen = Util.WorldToScreen(part.Position)
				if onScreen then
					local dist = (screenPos - mousePos).Magnitude
					if dist < closestDist then
						closestDist = dist
						closestPart = part
					end
				end
			end
		end
		return closestPart or character:FindFirstChild("HumanoidRootPart")
	end

	local part = character:FindFirstChild(hitboxName)
	if part then return part end
	if hitboxName == "UpperTorso" or hitboxName == "LowerTorso" then
		return character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
	end
	return character:FindFirstChild("HumanoidRootPart")
end

function Util.SmoothAlpha(deltaTime, tau)
	return 1 - math.exp(-deltaTime / tau)
end

function Util.CalculateFlySpeed(sliderValue)
	return CONSTANTS.FLY_SPEED_MIN + (sliderValue / 100) * (CONSTANTS.FLY_SPEED_MAX - CONSTANTS.FLY_SPEED_MIN)
end

function Util.CalculateCFrameSpeed(sliderValue)
	return CONSTANTS.CFRAME_SPEED_MIN + (sliderValue / 100) * (CONSTANTS.CFRAME_SPEED_MAX - CONSTANTS.CFRAME_SPEED_MIN)
end

function Util.IsUIBlocking()
	-- Проверяем, открыт ли интерфейс Fatality (самый надежный способ)
	local isMenuOpen = false
	if Fatality and Fatality.Windows then
		for _, win in ipairs(Fatality.Windows) do
			if win:IsA("ScreenGui") and win.Enabled then
				isMenuOpen = true
				break
			end
		end
	end

	if isMenuOpen then return true end
	if Services.GuiService.MenuIsOpen then return true end
	if Services.UserInputService:GetFocusedTextBox() ~= nil then return true end
	return false
end

function Util.IsShiftLockActive()
	return Services.UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

function Util.GetAutoPredDivisor(speed)
	for _, entry in ipairs(CONSTANTS.AUTO_PRED_DIVISORS) do
		if entry.fallback then
			return entry.fallback
		end
		if speed < entry.threshold then
			return entry.divisor
		end
	end
	return 250
end

-- ============================================================
-- DESYNC ENGINE (FIXED — правильный порядок фреймов)
-- ============================================================

local DesyncEngine = {}
DesyncEngine.__index = DesyncEngine

function DesyncEngine.new()
	local self = setmetatable({}, DesyncEngine)
	self._active = false
	self._realCFrame = nil
	self._fakeCFrame = nil
	self._restoreBound = false
	self._heartbeatConnection = nil
	self._steppedConnection = nil
	self._bindName = "Desync_" .. tostring(math.random(100000, 999999))
	return self
end

function DesyncEngine:Start(fakePosition)
	if self._active then return false end

	local character = LocalPlayer.Character
	if not character then return false end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	self._active = true
	self._realCFrame = hrp.CFrame

	if typeof(fakePosition) == "CFrame" then
		self._fakeCFrame = fakePosition
	else
		self._fakeCFrame = CFrame.new(fakePosition) * (self._realCFrame - self._realCFrame.Position)
	end

	-- ЭТАП 1: BindToRenderStep с приоритетом First (самый первый в кадре)
	-- Это выполняется ДО рендера — восстанавливаем реальную позицию
	-- чтобы камера и рендер видели персонажа на месте
	if not self._restoreBound then
		Services.RunService:BindToRenderStep(self._bindName, Enum.RenderPriority.First.Value - 1, function()
			if not self._active then return end
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and self._realCFrame then
				root.CFrame = self._realCFrame
			end
		end)
		self._restoreBound = true
	end

	-- ЭТАП 2: Heartbeat — выполняется ПОСЛЕ физики, ПЕРЕД отправкой пакета
	-- Здесь ставим фейковую позицию — сервер получит её
	self._heartbeatConnection = Services.RunService.Heartbeat:Connect(function()
		if not self._active then return end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		-- Сохраняем текущую реальную позицию (игрок мог двигаться)
		self._realCFrame = root.CFrame
		-- Подменяем на фейковую — это уйдёт серверу
		root.CFrame = self._fakeCFrame
	end)

	-- ЭТАП 3: Stepped — дополнительная страховка
	-- Stepped выполняется перед физикой, после RenderStepped
	-- Гарантируем что физика работает с реальной позицией
	self._steppedConnection = Services.RunService.Stepped:Connect(function()
		if not self._active then return end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and self._realCFrame then
			root.CFrame = self._realCFrame
		end
	end)

	return true
end

function DesyncEngine:SetFakePosition(fakePosition)
	if not self._active then return end
	if typeof(fakePosition) == "CFrame" then
		self._fakeCFrame = fakePosition
	elseif self._realCFrame then
		self._fakeCFrame = CFrame.new(fakePosition) * (self._realCFrame - self._realCFrame.Position)
	end
end

function DesyncEngine:SetRealCFrame(cf)
	self._realCFrame = cf
end

function DesyncEngine:GetRealCFrame()
	return self._realCFrame
end

-- НОВОЕ: Получить фейковую позицию (для Bullet TP startPos)
function DesyncEngine:GetFakeCFrame()
	return self._fakeCFrame
end

function DesyncEngine:GetFakePosition()
	return self._fakeCFrame and self._fakeCFrame.Position or nil
end

function DesyncEngine:IsActive()
	return self._active
end

function DesyncEngine:Stop()
	if not self._active then return end
	self._active = false

	if self._restoreBound then
		pcall(function()
			Services.RunService:UnbindFromRenderStep(self._bindName)
		end)
		self._restoreBound = false
	end

	if self._heartbeatConnection then
		self._heartbeatConnection:Disconnect()
		self._heartbeatConnection = nil
	end

	if self._steppedConnection then
		self._steppedConnection:Disconnect()
		self._steppedConnection = nil
	end

	-- Гарантируем возврат на реальную позицию
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root and self._realCFrame then
		root.CFrame = self._realCFrame
	end

	self._realCFrame = nil
	self._fakeCFrame = nil
end

function DesyncEngine:RunForFrames(fakePosition, frameCount, callback)
	if not self:Start(fakePosition) then
		if callback then callback(false) end
		return
	end

	task.spawn(function()
		for i = 1, frameCount do
			Services.RunService.Heartbeat:Wait()
			if not self._active then break end
		end
		self:Stop()
		if callback then callback(true) end
	end)
end

function DesyncEngine:RunWhile(fakePosition, condition, maxSeconds)
	maxSeconds = maxSeconds or 10
	if not self:Start(fakePosition) then return false end

	task.spawn(function()
		local startTime = tick()
		while self._active and condition() and (tick() - startTime < maxSeconds) do
			Services.RunService.Heartbeat:Wait()
		end
		self:Stop()
	end)

	return true
end

-- ============================================================
-- PING TRACKER
-- ============================================================

local PingTracker = {}
PingTracker.__index = PingTracker

function PingTracker.new()
	local self = setmetatable({}, PingTracker)
	self._ping = 100
	self._running = false
	return self
end

function PingTracker:GetPing()
	return self._ping
end

function PingTracker:Start()
	if self._running then return end
	self._running = true
	task.spawn(function()
		while self._running do
			local success, ping = pcall(function()
				return Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if success and ping then
				self._ping = ping
			end
			task.wait(0.5)
		end
	end)
end

function PingTracker:Stop()
	self._running = false
end

-- ============================================================
-- VELOCITY TRACKER
-- ============================================================

local VelocityTracker = {}
VelocityTracker.__index = VelocityTracker

function VelocityTracker.new()
	local self = setmetatable({}, VelocityTracker)
	self._previousPositions = {}
	self._smoothedVelocities = {}
	self._lastUpdateTimes = {}
	self._acceleration = {}
	self._velocityChanges = {}
	return self
end

function VelocityTracker:GetSmoothedVelocity(character, useResolver)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return Vector3.zero, Vector3.zero end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local player = Services.Players:GetPlayerFromCharacter(character)

	if useResolver and humanoid then
		local moveDir = humanoid.MoveDirection
		local walkSpeed = humanoid.WalkSpeed
		if moveDir.Magnitude > 0 then
			return moveDir * walkSpeed, Vector3.zero
		end
		return Vector3.zero, Vector3.zero
	end

	if not player then
		local velocity = rootPart.AssemblyLinearVelocity
		if velocity.Magnitude > CONSTANTS.MAX_VELOCITY then
			velocity = velocity.Unit * CONSTANTS.MAX_VELOCITY
		end
		return velocity, Vector3.zero
	end

	local currentTime = tick()
	local currentPos = rootPart.Position
	local lastPos = self._previousPositions[player] or currentPos
	local lastTime = self._lastUpdateTimes[player] or (currentTime - 0.016)
	local deltaTime = math.max(currentTime - lastTime, 0.001)

	local rawVelocity = (currentPos - lastPos) / deltaTime
	if rawVelocity.Magnitude > CONSTANTS.MAX_VELOCITY then
		rawVelocity = rawVelocity.Unit * CONSTANTS.MAX_VELOCITY
	end

	local prevSmoothed = self._smoothedVelocities[player] or rawVelocity
	local velocityChange = (rawVelocity - prevSmoothed).Magnitude

	if not self._velocityChanges[player] then
		self._velocityChanges[player] = {}
	end

	local history = self._velocityChanges[player]
	table.insert(history, velocityChange)
	if #history > CONSTANTS.VELOCITY_HISTORY_FRAMES then
		table.remove(history, 1)
	end

	local avgChange = 0
	for _, change in ipairs(history) do
		avgChange = avgChange + change
	end
	avgChange = avgChange / math.max(#history, 1)

	local walkSpeed = humanoid and humanoid.WalkSpeed or 16
	local chaosNormalized = math.clamp(avgChange / (walkSpeed * CONSTANTS.VELOCITY_CHAOS_WALK_RATIO), 0, 1)
	local autoTau = CONSTANTS.VELOCITY_TAU_MIN + chaosNormalized * CONSTANTS.VELOCITY_TAU_RANGE

	if humanoid then
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
			autoTau = autoTau * CONSTANTS.VELOCITY_JUMP_TAU_MULT
		end
	end

	local alpha = Util.SmoothAlpha(deltaTime, autoTau)
	local smoothed = prevSmoothed:Lerp(rawVelocity, alpha)

	local prevVelocity = self._smoothedVelocities[player] or smoothed
	local rawAccel = (smoothed - prevVelocity) / deltaTime
	local prevAccel = self._acceleration[player] or rawAccel
	local accelAlpha = Util.SmoothAlpha(deltaTime, autoTau * 2)
	local smoothedAccel = prevAccel:Lerp(rawAccel, accelAlpha)

	self._acceleration[player] = smoothedAccel
	self._smoothedVelocities[player] = smoothed
	self._previousPositions[player] = currentPos
	self._lastUpdateTimes[player] = currentTime

	return smoothed, smoothedAccel
end

function VelocityTracker:Clear()
	self._previousPositions = {}
	self._smoothedVelocities = {}
	self._lastUpdateTimes = {}
	self._acceleration = {}
	self._velocityChanges = {}
end

-- ============================================================
-- WEAPON SERVICE
-- ============================================================

local WeaponService = {}
WeaponService.__index = WeaponService

function WeaponService.new()
	local self = setmetatable({}, WeaponService)
	return self
end

function WeaponService:GetGun()
	local char = LocalPlayer.Character
	if not char then return nil end
	local tool = char:FindFirstChildWhichIsA("Tool")
	if not tool then return nil end
	if not tool:FindFirstChild("Handle") then return nil end
	if not tool:FindFirstChild("RemoteEvent") then return nil end
	return tool
end

function WeaponService:IsMelee(gun)
	if not gun then return false end
	return CONSTANTS.WEAPONS_MELEE[gun.Name:upper()] == true
end

function WeaponService:CanHoldFire(gun)
	if not gun then return false end
	return CONSTANTS.WEAPONS_NO_HOLD_FIRE[gun.Name:upper()] ~= true
end

function WeaponService:IsNoSilent(gun)
	if not gun then return false end
	return CONSTANTS.WEAPONS_NO_SILENT[gun.Name:upper()] == true
end

function WeaponService:IsShotgun(gun)
	if not gun then return false end
	local gunName = gun.Name:upper():gsub("%[", ""):gsub("%]", ""):gsub("%s+", ""):gsub("%-", "")
	return gunName:match("SHOTGUN") ~= nil or gunName:match("DOUBLEBARREL") ~= nil or gunName:match("DRUMSHOTGUN") ~= nil or gunName == "TACTICALSHOTGUN"
end

function WeaponService:GetFireRate(gun)
	if not gun then return CONSTANTS.COMBAT_DEFAULT_FIRE_RATE end
	local shootingCooldown = gun:FindFirstChild("ShootingCooldown")
	if shootingCooldown and shootingCooldown:IsA("NumberValue") then
		return math.max(shootingCooldown.Value, CONSTANTS.COMBAT_MIN_FIRE_RATE)
	end
	local fireRate = gun:FindFirstChild("FireRate")
	if fireRate and fireRate:IsA("NumberValue") then
		return math.max(fireRate.Value, CONSTANTS.COMBAT_MIN_FIRE_RATE)
	end
	return CONSTANTS.COMBAT_DEFAULT_FIRE_RATE
end

function WeaponService:GetWeaponRange(gun)
	if not gun then return math.huge end
	local range = gun:FindFirstChild("Range")
	if range and range:IsA("NumberValue") then
		return range.Value
	end
	return math.huge
end

function WeaponService:GetMaxAmmo(gun)
	if not gun then return 0 end
	local maxAmmo = gun:FindFirstChild("MaxAmmo")
	if maxAmmo and maxAmmo:IsA("NumberValue") then
		return maxAmmo.Value
	end
	return 30
end

function WeaponService:IsTargetInRange(gun, targetPosition)
	if not gun then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	local myRoot = char:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end
	local distance = (targetPosition - myRoot.Position).Magnitude
	return distance <= self:GetWeaponRange(gun)
end

function WeaponService:GetAmmoStatus(gun)
	if not gun then return nil end
	local status = {
		hasAmmoSystem = false,
		currentAmmo = 0,
		isReloading = false,
		needsReload = false,
	}
	local ammo = gun:FindFirstChild("Ammo")
	if ammo and ammo:IsA("NumberValue") then
		status.hasAmmoSystem = true
		status.currentAmmo = ammo.Value
		status.needsReload = ammo.Value <= 0
	end
	local char = LocalPlayer.Character
	if char then
		local bodyEffects = char:FindFirstChild("BodyEffects")
		if bodyEffects then
			local reloadValue = bodyEffects:FindFirstChild("Reload")
			if reloadValue then
				status.isReloading = reloadValue.Value
			end
		end
	end
	return status
end

function WeaponService:ForceReload(gun)
	if not gun then return false end
	local status = self:GetAmmoStatus(gun)
	if not status then return false end
	if status.isReloading then return false end
	if status.currentAmmo > 0 then return false end
	MainEvent:FireServer("Reload", gun)
	return true
end

function WeaponService:WaitForReload(gun, timeout)
	timeout = timeout or 3
	local startTime = tick()
	local char = LocalPlayer.Character
	if not char then return false end
	local bodyEffects = char:FindFirstChild("BodyEffects")
	if not bodyEffects then return false end
	local reloadValue = bodyEffects:FindFirstChild("Reload")
	if not reloadValue then return false end

	local reloadStarted = false
	while tick() - startTime < timeout do
		if reloadValue.Value == true then
			reloadStarted = true
			break
		end
		task.wait(0.05)
	end
	if not reloadStarted then return false end

	while tick() - startTime < timeout do
		if reloadValue.Value == false then
			local ammo = gun:FindFirstChild("Ammo")
			if ammo and ammo.Value > 0 then
				return true
			end
			return false
		end
		task.wait(0.05)
	end
	return false
end

-- FIX: CanShoot теперь имеет параметр skipNonSilentChecks для TriggerBot/AutoFire
function WeaponService:CanShoot(options)
	options = options or {}
	local forSilent = options.forSilent or false
	local checkMelee = options.checkMelee ~= false
	local checkNoSilent = options.checkNoSilent ~= false
	local autoReload = options.autoReload or false
	local skipExtendedChecks = options.skipExtendedChecks or false

	local char, hum = Util.GetCharacterParts()
	if not char or not hum then return false, nil end

	local gun = self:GetGun()
	if not gun then return false, nil end

	if checkMelee and self:IsMelee(gun) then return false, nil end
	if checkNoSilent and forSilent and self:IsNoSilent(gun) then return false, nil end

	local bodyEffects = char:FindFirstChild("BodyEffects")
	if not bodyEffects then return false, nil end

	if bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value then return false, nil end
	if bodyEffects:FindFirstChild("Dead") and bodyEffects.Dead.Value then return false, nil end
	if bodyEffects:FindFirstChild("Reload") and bodyEffects.Reload.Value then return false, gun end

	local ammo = gun:FindFirstChild("Ammo")
	if ammo and ammo.Value <= 0 then
		if autoReload then
			self:ForceReload(gun)
		end
		return false, gun
	end

	-- Для silent режима или skipExtendedChecks пропускаем расширенные проверки
	if not forSilent and not skipExtendedChecks then
		if bodyEffects:FindFirstChild("Cuff") and bodyEffects.Cuff.Value then return false, nil end
		if bodyEffects:FindFirstChild("Attacking") and bodyEffects.Attacking.Value then return false, nil end
		if bodyEffects:FindFirstChild("Grabbed") and bodyEffects.Grabbed.Value then return false, nil end
		if gun:GetAttribute("Cooldown") then return false, nil end
		if char:FindFirstChild("FORCEFIELD") then return false, nil end
		if not char:FindFirstChild("FULLY_LOADED_CHAR") then return false, nil end
		if char:FindFirstChild("GRABBING_CONSTRAINT") then return false, nil end
	end

	return true, gun
end

function WeaponService:EnsureWeaponEquipped()
	local char = LocalPlayer.Character
	if not char then return false, nil end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false, nil end

	local currentGun = self:GetGun()
	if currentGun and currentGun:FindFirstChild("Ammo") and not self:IsMelee(currentGun) and not self:IsNoSilent(currentGun) then
		local ammo = currentGun:FindFirstChild("Ammo")
		if ammo and ammo.Value <= 0 then
			if self:ForceReload(currentGun) then
				self:WaitForReload(currentGun, 3)
			end
		end
		return true, currentGun
	end

	local bestWeapon = self:GetBestWeaponFromBackpack()
	if bestWeapon then
		humanoid:EquipTool(bestWeapon)
		local waitStart = tick()
		while tick() - waitStart < 1 do
			local equippedTool = char:FindFirstChild(bestWeapon.Name)
			if equippedTool and equippedTool:IsA("Tool") then
				task.wait(0.1)
				local ammo = equippedTool:FindFirstChild("Ammo")
				if ammo and ammo.Value <= 0 then
					if self:ForceReload(equippedTool) then
						self:WaitForReload(equippedTool, 3)
					end
				end
				return true, equippedTool
			end
			task.wait(0.1)
		end
		return false, nil
	end
	return false, nil
end

-- УСТАРЕВШАЯ: оставлена для обратной совместимости, используйте GetBestWeaponForKill()
function WeaponService:GetBestWeaponFromBackpack()
	return self:GetBestWeaponForKill()
end

-- Динамический выбор лучшего оружия для Kill на основе score и патронов
function WeaponService:GetBestWeaponForKill()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local character = LocalPlayer.Character
	if not backpack and not character then return nil end
	
	local candidates = {}
	
	-- Собираем все оружия из backpack и character
	local function scanContainer(container)
		if not container then return end
		for _, item in pairs(container:GetChildren()) do
			if not item:IsA("Tool") then continue end
			if not item:FindFirstChild("Handle") then continue end
			if not item:FindFirstChild("RemoteEvent") then continue end
			
			local cleanName = item.Name:match("%[(.-)%]") or item.Name
			local upperName = cleanName:upper()
			
			-- Пропускаем melee и explosive
			if CONSTANTS.WEAPONS_MELEE[upperName] then continue end
			if CONSTANTS.WEAPONS_NO_SILENT[upperName] then continue end
			
			local priorityData = CONSTANTS.WEAPON_KILL_PRIORITY[upperName]
			if not priorityData then continue end
			
			local ammo = item:FindFirstChild("Ammo")
			local currentAmmo = ammo and ammo.Value or 0
			local storedAmmo = item:FindFirstChild("StoredAmmo")
			local totalAmmo = currentAmmo + (storedAmmo and storedAmmo.Value or 0)
			
			-- Базовый score из таблицы
			local score = priorityData.score
			
			-- Бонус за наличие патронов прямо сейчас
			if currentAmmo > 0 then
				score = score + 20  -- можно стрелять без перезарядки
			elseif totalAmmo > 0 then
				score = score + 5   -- нужна перезарядка, но есть запас
			else
				score = score - 50  -- нет патронов вообще
			end
			
			-- Бонус для shotgun при Kill через десинк (мы близко к цели)
			if priorityData.type == "shotgun" then
				score = score + 15
			end
			
			table.insert(candidates, {
				tool = item,
				name = upperName,
				score = score,
				ammo = currentAmmo,
				totalAmmo = totalAmmo,
				inCharacter = container == character,
			})
		end
	end
	
	scanContainer(character)
	scanContainer(backpack)
	
	if #candidates == 0 then return nil end
	
	-- Сортируем по score (убывание)
	table.sort(candidates, function(a, b) 
		return a.score > b.score 
	end)
	
	-- Лучший кандидат
	local best = candidates[1]
	
	-- Если лучший без патронов — ищем первый с патронами
	if best.ammo <= 0 and best.totalAmmo <= 0 then
		for _, c in ipairs(candidates) do
			if c.ammo > 0 or c.totalAmmo > 0 then
				return c.tool
			end
		end
	end
	
	return best.tool
end

-- Проверка: нужно ли менять текущее оружие
function WeaponService:ShouldSwitchWeapon(currentGun)
	if not currentGun then return true end
	if self:IsMelee(currentGun) then return true end
	if self:IsNoSilent(currentGun) then return true end
	
	-- Текущее оружие без патронов и без запаса
	local ammo = currentGun:FindFirstChild("Ammo")
	local stored = currentGun:FindFirstChild("StoredAmmo")
	local totalAmmo = (ammo and ammo.Value or 0) + (stored and stored.Value or 0)
	if totalAmmo <= 0 then return true end
	
	-- Текущее оружие сильно хуже лучшего доступного
	local cleanName = currentGun.Name:match("%[(.-)%]") or currentGun.Name
	local currentPriority = CONSTANTS.WEAPON_KILL_PRIORITY[cleanName:upper()]
	local currentScore = currentPriority and currentPriority.score or 0
	
	local bestWeapon = self:GetBestWeaponForKill()
	if not bestWeapon then return false end
	
	local bestClean = bestWeapon.Name:match("%[(.-)%]") or bestWeapon.Name
	local bestPriority = CONSTANTS.WEAPON_KILL_PRIORITY[bestClean:upper()]
	local bestScore = bestPriority and bestPriority.score or 0
	
	-- Переключаем только если разница > 30 очков
	-- (не менять SMG на AR, но менять Glock на Shotgun)
	return (bestScore - currentScore) > 30
end

-- ============================================================
-- SHOOTING SERVICE
-- ============================================================

local ShootingService = {}
ShootingService.__index = ShootingService

function ShootingService.new(weaponService, velocityTracker, pingTracker)
	local self = setmetatable({}, ShootingService)
	self._weaponService = weaponService
	self._velocityTracker = velocityTracker
	self._pingTracker = pingTracker
	return self
end

function ShootingService:PredictPosition(character, hitbox, options)
	if not hitbox then return nil end
	options = options or {}

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return hitbox.Position end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local ping = self._pingTracker:GetPing()
	local t_net = (ping / 1000) / 2
	local t_tick = CONSTANTS.SERVER_TICK / 2

	local velocity, acceleration

	-- АНТИ-ДЕСИНК (Auto-Resolver): Проверяем, не телепортируется ли цель
	local rawVel = rootPart.AssemblyLinearVelocity
	local isDesyncing = rawVel.Magnitude > CONSTANTS.MAX_VELOCITY or (humanoid and humanoid.MoveDirection.Magnitude == 0 and rawVel.Magnitude > 15)

	-- Если включен Resolver или мы обнаружили Десинк/Телепорт
	if options.useResolver or isDesyncing then
		-- Берем скорость только от кнопок ходьбы (WASD), игнорируем физические телепорты
		velocity, acceleration = self._velocityTracker:GetSmoothedVelocity(character, true)
		if isDesyncing then
			-- При жестком десинке убираем акселерацию, чтобы предикшен не сходил с ума
			acceleration = Vector3.zero
			-- Если враг стоит на месте (MoveDirection = 0), но его физически кидает, стреляем ровно в центр
			if velocity.Magnitude == 0 then
				return hitbox.Position
			end
		end
	elseif options.useSmoothedVelocity then
		velocity, acceleration = self._velocityTracker:GetSmoothedVelocity(character, false)
	else
		velocity = rawVel
		if velocity.Magnitude > CONSTANTS.MAX_VELOCITY then
			velocity = velocity.Unit * CONSTANTS.MAX_VELOCITY
		end
		acceleration = Vector3.zero
	end

	local t_proj
	if options.autoPrediction then
		local speed = velocity.Magnitude
		local autoDivisor = Util.GetAutoPredDivisor(speed)
		t_proj = CONSTANTS.PREDICTION_BASE + (ping / autoDivisor) * 0.1
	elseif options.manualDivisor then
		t_proj = CONSTANTS.PREDICTION_BASE + (ping / options.manualDivisor) * 0.1
	elseif options.manualPrediction then
		t_proj = options.manualPrediction
	else
		t_proj = 0
	end

	local t_total = t_net + t_tick + t_proj
	local yOffset = 0
	if options.jumpOffset and options.jumpOffset ~= 0 then
		if humanoid then
			local state = humanoid:GetState()
			if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
				yOffset = options.jumpOffset * CONSTANTS.JUMP_MULTIPLIER
			end
		end
	end

	return hitbox.Position + (velocity * t_total) + (acceleration * 0.5 * t_total * t_total) + Vector3.new(0, yOffset, 0)
end

function ShootingService:FireShot(handle, hitbox, predictedPos, gun, options)
	if not handle or not hitbox or not predictedPos then return false end
	options = options or {}

	local startPos = options.startPos or Camera.CFrame.Position

	if options.hiddenBullets then
		local offset = Vector3.new(0, CONSTANTS.COMBAT_HIDDEN_BULLETS_OFFSET, 0)
		startPos = startPos - offset
		predictedPos = predictedPos - offset
	end

	local normal = (predictedPos - startPos).Unit
	if normal.Magnitude == 0 then
		normal = Vector3.new(0, 0, -1)
	end

	if gun and self._weaponService:IsShotgun(gun) then
		MainEvent:FireServer("ShootGun", handle, startPos, predictedPos, tick())
	else
		MainEvent:FireServer("ShootGun", handle, startPos, predictedPos, hitbox, normal)
	end
	return true
end

-- НОВОЕ: Bullet TP shot — стрельба от фейковой позиции (рядом с целью)
function ShootingService:FireBulletTPShot(handle, hitbox, predictedPos, gun, fakeStartPos, options)
	if not handle or not hitbox or not predictedPos then return false end
	options = options or {}

	local startPos = fakeStartPos or Camera.CFrame.Position

	if options.hiddenBullets then
		local offset = Vector3.new(0, CONSTANTS.COMBAT_HIDDEN_BULLETS_OFFSET, 0)
		startPos = startPos - offset
		predictedPos = predictedPos - offset
	end

	local normal = (predictedPos - startPos).Unit
	if normal.Magnitude == 0 then
		normal = Vector3.new(0, 0, -1)
	end

	if gun and self._weaponService:IsShotgun(gun) then
		MainEvent:FireServer("ShootGun", handle, startPos, predictedPos, tick())
	else
		MainEvent:FireServer("ShootGun", handle, startPos, predictedPos, hitbox, normal)
	end
	return true
end

function ShootingService:ShootAtTarget(target, hitboxName, options)
	options = options or {}

	local canShootOpts = {
		forSilent = options.forSilent or false,
		checkMelee = options.checkMelee ~= false,
		checkNoSilent = not options.ignoreNoSilent,
		autoReload = options.autoReload or false,
		skipExtendedChecks = options.skipExtendedChecks or false,
	}
	local canShoot, gun = self._weaponService:CanShoot(canShootOpts)

	if not canShoot then
		if gun and options.autoReload then
			local ammo = gun:FindFirstChild("Ammo")
			if ammo and ammo.Value <= 0 then
				self._weaponService:ForceReload(gun)
			end
		end
		return false
	end

	local targetChar = target.Character
	if not targetChar then return false end
	if not (options.allowKO and Util.IsCharacterAliveOrKO(targetChar) or Util.IsCharacterAlive(targetChar)) then return false end

	local hitbox = Util.GetHitboxPart(targetChar, hitboxName or "Head")
	if not hitbox then return false end

	-- ИЗМЕНЕНО: При desync kill не проверяем visibility от камеры,
	-- проверяем от фейковой позиции если desync активен
	if options.checkVisibility ~= false then
		local visOrigin = Camera.CFrame.Position
		if options.useDesyncOrigin and desyncEngine:IsActive() then
			visOrigin = desyncEngine:GetFakePosition() or visOrigin
		end
		if not Util.IsVisible(visOrigin, hitbox) then return false end
	end

	-- ИЗМЕНЕНО: При desync не проверяем range от реальной позиции —
	-- фейковая позиция рядом с целью
	if options.checkRange and not options.useDesyncOrigin then
		if not self._weaponService:IsTargetInRange(gun, hitbox.Position) then
			return false
		end
	end

	local handle = gun:FindFirstChild("Handle")
	if not handle then return false end

	local ammo = gun:FindFirstChild("Ammo")
	if ammo and ammo.Value <= 0 then return false end

	local predictedPos = self:PredictPosition(targetChar, hitbox, options.predictionOptions or {})
	if not predictedPos then predictedPos = hitbox.Position end

	-- НОВОЕ: Если есть fakeStartPos — используем Bullet TP
	local fakeStart = options.fakeStartPos
	if not fakeStart and desyncEngine:IsActive() then
		fakeStart = desyncEngine:GetFakePosition()
	end

	if fakeStart then
		return self:FireBulletTPShot(handle, hitbox, predictedPos, gun, fakeStart, {
			hiddenBullets = options.hiddenBullets,
		})
	end

	return self:FireShot(handle, hitbox, predictedPos, gun, {
		startPos = options.startPos,
		hiddenBullets = options.hiddenBullets,
	})
end

-- ============================================================
-- COMBAT MANAGER
-- ============================================================

local CombatManager = {}
CombatManager.__index = CombatManager

function CombatManager.new()
	local self = setmetatable({}, CombatManager)
	self._currentAction = nil
	self._currentPriority = 0
	self._isPerforming = false
	self._actionOwner = nil
	return self
end

function CombatManager:CanPerform(priority)
	if not self._isPerforming then return true end
	return priority > self._currentPriority
end

function CombatManager:StartAction(actionName, priority, owner)
	if self._isPerforming and priority <= self._currentPriority then
		return false
	end
	if self._isPerforming and self._actionOwner and self._actionOwner.ForceStop then
		self._actionOwner:ForceStop()
	end
	self._currentAction = actionName
	self._currentPriority = priority
	self._isPerforming = true
	self._actionOwner = owner
	return true
end

function CombatManager:EndAction(actionName)
	if self._currentAction == actionName then
		self._currentAction = nil
		self._currentPriority = 0
		self._isPerforming = false
		self._actionOwner = nil
	end
end

function CombatManager:IsBlocked(priority)
	if not self._isPerforming then return false end
	return priority < self._currentPriority
end

-- ============================================================
-- SMART TELEPORT
-- ============================================================

local SmartTeleport = {}
SmartTeleport.__index = SmartTeleport

function SmartTeleport.new()
	local self = setmetatable({}, SmartTeleport)
	return self
end

function SmartTeleport:_doRaycast(origin, direction, filterInstances)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = filterInstances or {}
	return workspace:Raycast(origin, direction, rayParams)
end

function SmartTeleport:_hasClearance(position, filterInstances)
	local directions = {
		Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
		Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
		Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
	}
	for _, dir in ipairs(directions) do
		local result = self:_doRaycast(position, dir * CONSTANTS.SMART_TP_MIN_CLEARANCE, filterInstances)
		if result then return false end
	end
	return true
end

function SmartTeleport:FindBestPosition(targetCharacter)
	if not targetCharacter then return nil, nil end
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	local targetHead = targetCharacter:FindFirstChild("Head")
	if not targetRoot then return nil, nil end

	local myChar = LocalPlayer.Character
	local filterInstances = {
		myChar, targetCharacter, Camera,
		workspace:FindFirstChild("Bush"),
		workspace:FindFirstChild("Ignored"),
	}

	local headPos = targetHead and targetHead.Position or (targetRoot.Position + Vector3.new(0, 2, 0))
	local rootPos = targetRoot.Position
	local lookVector = targetRoot.CFrame.LookVector
	local rightVector = targetRoot.CFrame.RightVector

	local upRay = self:_doRaycast(headPos, Vector3.new(0, CONSTANTS.SMART_TP_RAY_UP, 0), filterInstances)
	if not upRay then
		local abovePos = rootPos + Vector3.new(0, CONSTANTS.SMART_TP_SAFE_HEIGHT, 0)
		if self:_hasClearance(abovePos, filterInstances) then
			return abovePos, "Above"
		end
	end

	local behindDir = -lookVector * CONSTANTS.SMART_TP_RAY_SIDE
	local behindRay = self:_doRaycast(rootPos, behindDir, filterInstances)
	if not behindRay then
		local behindPos = rootPos - lookVector * CONSTANTS.SMART_TP_SAFE_BEHIND + Vector3.new(0, 1, 0)
		if self:_hasClearance(behindPos, filterInstances) then
			return behindPos, "Behind"
		end
	end

	local leftDir = -rightVector * CONSTANTS.SMART_TP_RAY_SIDE
	local leftRay = self:_doRaycast(rootPos, leftDir, filterInstances)
	if not leftRay then
		local leftPos = rootPos - rightVector * CONSTANTS.SMART_TP_SAFE_SIDE + Vector3.new(0, 1, 0)
		if self:_hasClearance(leftPos, filterInstances) then
			return leftPos, "Left"
		end
	end

	local rightDir = rightVector * CONSTANTS.SMART_TP_RAY_SIDE
	local rightRay = self:_doRaycast(rootPos, rightDir, filterInstances)
	if not rightRay then
		local rightPos = rootPos + rightVector * CONSTANTS.SMART_TP_SAFE_SIDE + Vector3.new(0, 1, 0)
		if self:_hasClearance(rightPos, filterInstances) then
			return rightPos, "Right"
		end
	end

	return rootPos + Vector3.new(0, CONSTANTS.SMART_TP_MIN_CLEARANCE + 2, 0), "Above"
end

function SmartTeleport:TeleportToTarget(targetCharacter)
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end
	local position = self:FindBestPosition(targetCharacter)
	if not position then return false end
	myRoot.CFrame = CFrame.new(position)
	return true
end

function SmartTeleport:TeleportForStomp(targetCharacter)
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot or not targetCharacter then return false end
	local torso = targetCharacter:FindFirstChild("UpperTorso")
		or targetCharacter:FindFirstChild("Torso")
		or targetCharacter:FindFirstChild("HumanoidRootPart")
	if not torso then return false end
	myRoot.CFrame = CFrame.new(torso.Position + Vector3.new(0, CONSTANTS.COMBAT_STOMP_HEIGHT, 0))
	return true
end

-- ============================================================
-- FOV GUI
-- ============================================================

if game:GetService("CoreGui"):FindFirstChild("RayFOV_Visuals") then
	game:GetService("CoreGui").RayFOV_Visuals:Destroy()
end
if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("RayFOV_Visuals") then
	Services.Players.LocalPlayer.PlayerGui.RayFOV_Visuals:Destroy()
end

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "RayFOV_Visuals"
FOVGui.IgnoreGuiInset = true
FOVGui.ResetOnSpawn = false
FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
	FOVGui.Parent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
	pcall(function() FOVGui.Parent = game:GetService("CoreGui") end)
end
if not FOVGui.Parent then
	FOVGui.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function CreateVanillaCircle()
	local frame = Instance.new("Frame")
	frame.Name = "FOVCircle"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = FOVGui

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.Thickness = 1
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame

	return frame, stroke
end

-- ============================================================
-- FOV CIRCLE MANAGER
-- ============================================================

local FOVCircleManager = {}
FOVCircleManager.__index = FOVCircleManager

function FOVCircleManager.new()
	local self = setmetatable({}, FOVCircleManager)
	self._circles = {}
	return self
end

function FOVCircleManager:CreateCircle(name)
	local frame, stroke = CreateVanillaCircle()
	self._circles[name] = {
		Object = frame,
		Stroke = stroke,
	}
	return self._circles[name]
end

function FOVCircleManager:UpdateCircle(name, visible, radius, color, transparency)
	local circle = self._circles[name]
	if not circle then return end

	circle.Object.Visible = visible
	if visible then
		local mousePos = Util.GetMousePosition()
		local diameter = radius * 2
		circle.Object.Size = UDim2.new(0, diameter, 0, diameter)
		circle.Object.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
		circle.Stroke.Color = color
		circle.Stroke.Transparency = transparency or 0.3
	end
end

-- ============================================================
-- STATE MANAGER
-- ============================================================

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new()
	local self = setmetatable({}, StateManager)
	self._activeMode = "None"
	self._uiToggles = { Legit = nil, Rage = nil }
	self._isUpdatingUI = false
	self._onEnableLegit = nil
	self._onDisableLegit = nil
	self._onEnableRage = nil
	self._onDisableRage = nil
	return self
end

function StateManager:SetUIToggle(name, toggle)
	self._uiToggles[name] = toggle
end

function StateManager:SetCallbacks(callbacks)
	self._onEnableLegit = callbacks.onEnableLegit
	self._onDisableLegit = callbacks.onDisableLegit
	self._onEnableRage = callbacks.onEnableRage
	self._onDisableRage = callbacks.onDisableRage
end

function StateManager:GetMode()
	return self._activeMode
end

function StateManager:_setOppositeToggle(name, value)
	if self._uiToggles[name] and not self._isUpdatingUI then
		self._isUpdatingUI = true
		pcall(function() self._uiToggles[name]:SetValue(value) end)
		self._isUpdatingUI = false
	end
end

function StateManager:EnableLegit()
	if self._isUpdatingUI then return end
	if self._activeMode == "Legit" then return end
	if self._onDisableRage then self._onDisableRage() end
	self:_setOppositeToggle("Rage", false)
	self._activeMode = "Legit"
	if self._onEnableLegit then self._onEnableLegit() end
end

function StateManager:DisableLegit()
	if self._isUpdatingUI then return end
	if self._activeMode ~= "Legit" then return end
	self._activeMode = "None"
	if self._onDisableLegit then self._onDisableLegit() end
end

function StateManager:EnableRage()
	if self._isUpdatingUI then return end
	if self._activeMode == "Rage" then return end
	if self._onDisableLegit then self._onDisableLegit() end
	self:_setOppositeToggle("Legit", false)
	self._activeMode = "Rage"
	if self._onEnableRage then self._onEnableRage() end
end

function StateManager:DisableRage()
	if self._isUpdatingUI then return end
	if self._activeMode ~= "Rage" then return end
	self._activeMode = "None"
	if self._onDisableRage then self._onDisableRage() end
end

function StateManager:IsLegit()
	return self._activeMode == "Legit"
end

function StateManager:IsRage()
	return self._activeMode == "Rage"
end

-- ============================================================
-- CAMERA LOCK MODULE (STICKY TARGET & MENU FIX)
-- ============================================================

local CameraLock = {}
CameraLock.__index = CameraLock

function CameraLock.new(shootingService)
	local self = setmetatable({}, CameraLock)
	self.Active = false
	self.FOV = 100
	self.Smoothness = 0.1
	self.Prediction = 0.1
	self.CurrentTarget = nil
	self.Stickiness = 1.3 -- Коэффициент "липкости" (1.3 = 130% от FOV для удержания)

	self._shootingService = shootingService
	self._connection = nil
	self._lastTime = 0
	self._getTargetFn = nil
	self._hitboxFn = nil
	self._visibleCheckFn = nil
	return self
end

function CameraLock:SetTargetProvider(fn)
	self._getTargetFn = fn
end

function CameraLock:SetHitboxProvider(fn)
	self._hitboxFn = fn
end

function CameraLock:SetVisibleCheckProvider(fn)
	self._visibleCheckFn = fn
end

function CameraLock:_getSmoothAlpha(deltaTime)
	if self.Smoothness <= 0.01 then return 1.0 end
	local tau = CONSTANTS.CAMERA_SMOOTH_TAU_MIN + (self.Smoothness * (CONSTANTS.CAMERA_SMOOTH_TAU_MAX - CONSTANTS.CAMERA_SMOOTH_TAU_MIN))
	return Util.SmoothAlpha(deltaTime, tau)
end

function CameraLock:_calculateTargetCFrame(targetPosition)
	local camera = workspace.CurrentCamera
	local currentCFrame = camera.CFrame
	local camPosition = currentCFrame.Position
	local direction = (targetPosition - camPosition)
	local distance = direction.Magnitude
	if distance < 0.1 then return nil end

	local currentLookDirection = currentCFrame.LookVector
	local targetDirection = direction.Unit
	local dotProduct = math.clamp(currentLookDirection:Dot(targetDirection), -1, 1)
	local angle = math.deg(math.acos(dotProduct))

	local deadzoneAngle = Util.IsShiftLockActive() and CONSTANTS.CAMERA_DEADZONE_SHIFTLOCK or CONSTANTS.CAMERA_DEADZONE_ANGLE
	if angle < deadzoneAngle then return nil end

	local maxAngleChange = CONSTANTS.CAMERA_MAX_ANGULAR_SPEED * (1 / 60)
	if angle > maxAngleChange then
		local lerpAlpha = maxAngleChange / angle
		targetDirection = currentLookDirection:Lerp(targetDirection, lerpAlpha).Unit
		targetPosition = camPosition + targetDirection * distance
	end

	return CFrame.lookAt(camPosition, targetPosition)
end

-- Функция проверки: валидна ли текущая цель для удержания
function CameraLock:_isValidTarget(target, useVisCheck)
	if not target or not target.Character then return false end
	if not Util.IsCharacterAlive(target.Character) then return false end

	local hitboxName = self._hitboxFn and self._hitboxFn() or "Head"
	local hitbox = Util.GetHitboxPart(target.Character, hitboxName)
	if not hitbox then return false end

	-- Проверка расстояния с учетом липкости (Stickiness)
	local dist = Util.GetDistanceFromCrosshair(hitbox.Position)
	if dist > (self.FOV * self.Stickiness) then return false end

	-- Проверка на стены, если включено
	if useVisCheck and not Util.IsVisible(Camera.CFrame.Position, hitbox) then return false end

	return true
end

function CameraLock:Start()
	if self._connection then return end
	self._lastTime = tick()

	self._connection = Services.RunService.RenderStepped:Connect(function()
		if not self.Active then
			self.CurrentTarget = nil
			return
		end

		-- Если UI открыт — полностью игнорируем наводку (позволяет спокойно крутить настройки)
		if Util.IsUIBlocking() then
			self.CurrentTarget = nil
			return
		end

		local currentTime = tick()
		local deltaTime = math.clamp(currentTime - self._lastTime, 0.001, 0.1)
		self._lastTime = currentTime

		if not self._getTargetFn then return end
		local useVisCheck = self._visibleCheckFn and self._visibleCheckFn() or false

		-- ЛОГИКА ВЫБОРА ЦЕЛИ (Sticky Target)
		-- Сначала проверяем, валидна ли еще старая цель. Если да — оставляем её.
		if self.CurrentTarget and self:_isValidTarget(self.CurrentTarget, useVisCheck) then
			-- Ничего не делаем, цель остается прежней
		else
			-- Ищем новую цель
			self.CurrentTarget = self._getTargetFn(self.FOV, useVisCheck, false)
		end

		local target = self.CurrentTarget

		if not target or not target.Character then return end

		local hitboxName = self._hitboxFn and self._hitboxFn() or "Head"
		local hitbox = Util.GetHitboxPart(target.Character, hitboxName)
		if not hitbox then return end

		local targetPos = self._shootingService:PredictPosition(target.Character, hitbox, {
			manualPrediction = self.Prediction,
		})
		if not targetPos then return end

		local _, onScreen = Util.WorldToScreen(targetPos)
		if not onScreen then return end

		local targetCFrame = self:_calculateTargetCFrame(targetPos)
		if not targetCFrame then return end

		local alpha = self:_getSmoothAlpha(deltaTime)
		local camera = workspace.CurrentCamera
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
	end)
end

function CameraLock:Stop()
	self.CurrentTarget = nil
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

-- ============================================================
-- SILENT AIM MODULE (FIXED)
-- ============================================================

local SilentAim = {}
SilentAim.__index = SilentAim

function SilentAim.new(shootingService, weaponService)
	local self = setmetatable({}, SilentAim)
	self.Enabled = false
	self.FOV = 100
	self.CurrentTarget = nil
	self.Resolver = false
	self.JumpOffset = 0
	self.AutoPrediction = false
	self.ManualDivisor = 250

	self._shootingService = shootingService
	self._weaponService = weaponService
	self._updateConnection = nil
	self._hooksSetup = false
	self._getTargetFn = nil
	self._hitboxFn = nil
	self._visibleCheckFn = nil -- FIX: добавлен провайдер visibleCheck
	self._combatManager = nil
	return self
end

function SilentAim:SetTargetProvider(fn)
	self._getTargetFn = fn
end

function SilentAim:SetHitboxProvider(fn)
	self._hitboxFn = fn
end

-- FIX: новый метод
function SilentAim:SetVisibleCheckProvider(fn)
	self._visibleCheckFn = fn
end

function SilentAim:SetCombatManager(cm)
	self._combatManager = cm
end

function SilentAim:GetPredictionOptions(character)
	local opts = {
		jumpOffset = self.JumpOffset,
	}
	if self.Resolver then
		opts.useResolver = true
	else
		opts.useSmoothedVelocity = true
	end
	if self.AutoPrediction then
		opts.autoPrediction = true
	else
		opts.manualDivisor = self.ManualDivisor
	end
	return opts
end

function SilentAim:_setupHooks()
	if self._hooksSetup then return true end
	if not hookmetamethod or not getnamecallmethod then return false end

	self._hooksSetup = true
	local selfRef = self

	local originalNamecall
	originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(selfObj, ...)
		local method = getnamecallmethod()
		local args = {...}

		if method == "FireServer" and (selfObj == MainEvent or selfObj.Name == "MainEvent") and args[1] == "ShootGun" then
			if selfRef._combatManager and selfRef._combatManager:IsBlocked(CONSTANTS.PRIORITY_LEGIT) then
				return originalNamecall(selfObj, ...)
			end

			if selfRef.Enabled and selfRef.CurrentTarget then
				local target = selfRef.CurrentTarget
				local targetChar = target and target.Character

				if targetChar and Util.IsCharacterAlive(targetChar) then
					local hitboxName = selfRef._hitboxFn and selfRef._hitboxFn() or "Head"
					local hbox = Util.GetHitboxPart(targetChar, hitboxName)
					if hbox and Util.IsVisible(Camera.CFrame.Position, hbox) then
						local gun = selfRef._weaponService:GetGun()
						if gun and not selfRef._weaponService:IsTargetInRange(gun, hbox.Position) then
							return originalNamecall(selfObj, ...)
						end

						local predOpts = selfRef:GetPredictionOptions(targetChar)
						local newPos = selfRef._shootingService:PredictPosition(targetChar, hbox, predOpts)
						if newPos then
							local handle = args[2]
							local startPos = args[3]
							local argCount = #args

							setnamecallmethod("FireServer")

							if gun and selfRef._weaponService:IsShotgun(gun) then
								if argCount <= 5 or (argCount >= 6 and typeof(args[5]) == "number") then
									return originalNamecall(selfObj, "ShootGun", handle, startPos, newPos, tick())
								else
									local normal = args[6]
									if typeof(normal) ~= "Vector3" then normal = Vector3.new(0, 1, 0) end
									local timestamp = args[7] or tick()
									return originalNamecall(selfObj, "ShootGun", handle, startPos, newPos, hbox, normal, timestamp)
								end
							else
								local normal = args[6]
								if typeof(normal) ~= "Vector3" then normal = Vector3.new(0, 1, 0) end
								return originalNamecall(selfObj, "ShootGun", handle, startPos, newPos, hbox, normal)
							end
						end
					end
				end
			end
		end

		return originalNamecall(selfObj, ...)
	end))

	return true
end

function SilentAim:Start()
	if self.Enabled then return end
	self.Enabled = true

	if not self._hooksSetup then
		if not self:_setupHooks() then
			self.Enabled = false
			return
		end
	end

	if not self._getTargetFn then return end

	self._updateConnection = Services.RunService.RenderStepped:Connect(function()
		if not self.Enabled then
			self.CurrentTarget = nil
			return
		end
		-- FIX: используем VisibleCheck провайдер
		local useVisCheck = self._visibleCheckFn and self._visibleCheckFn() or true
		self.CurrentTarget = self._getTargetFn(self.FOV, useVisCheck, true)
	end)
end

function SilentAim:Stop()
	self.Enabled = false
	if self._updateConnection then
		self._updateConnection:Disconnect()
		self._updateConnection = nil
	end
	self.CurrentTarget = nil
end

-- ============================================================
-- TRIGGER BOT MODULE (FIXED)
-- ============================================================

local TriggerBot = {}
TriggerBot.__index = TriggerBot

function TriggerBot.new(shootingService, weaponService)
	local self = setmetatable({}, TriggerBot)
	self.Active = false
	self.MinDelay = 0.05

	self._shootingService = shootingService
	self._weaponService = weaponService
	self._connection = nil
	self._lastShot = 0
	self._delay = 0.05
	self._lastTarget = nil
	self._hasShotTarget = false
	self._lastGun = nil
	self._getTargetFn = nil
	self._hitboxFn = nil
	self._silentAim = nil
	self._cameraLock = nil
	self._combatManager = nil
	return self
end

function TriggerBot:SetTargetProvider(fn)
	self._getTargetFn = fn
end

function TriggerBot:SetHitboxProvider(fn)
	self._hitboxFn = fn
end

function TriggerBot:SetSilentAim(sa)
	self._silentAim = sa
end

function TriggerBot:SetCameraLock(cl)
	self._cameraLock = cl
end

function TriggerBot:SetCombatManager(cm)
	self._combatManager = cm
end

function TriggerBot:Start()
	if self._connection then return end
	self._lastShot = 0
	self._lastTarget = nil
	self._hasShotTarget = false
	self._lastGun = nil

	self._connection = Services.RunService.RenderStepped:Connect(function()
		if not self.Active then return end
		if self._combatManager and self._combatManager:IsBlocked(CONSTANTS.PRIORITY_LEGIT) then return end

		local currentTime = tick()
		if currentTime - self._lastShot < self._delay then return end

		-- FIX: Определяем цель — сначала от Silent, потом от CameraLock, потом ищем сами
		local target
		if self._silentAim and self._silentAim.Enabled and self._silentAim.CurrentTarget then
			target = self._silentAim.CurrentTarget
		elseif self._cameraLock and self._cameraLock.Active and self._cameraLock.CurrentTarget then
			target = self._cameraLock.CurrentTarget
		elseif self._getTargetFn then
			local fov = (self._silentAim and self._silentAim.FOV) or (self._cameraLock and self._cameraLock.FOV) or 100
			target = self._getTargetFn(fov, true, true)
		end

		if not target then return end

		local targetChar = target.Character
		if not targetChar or not Util.IsCharacterAlive(targetChar) then return end

		local hitboxName = self._hitboxFn and self._hitboxFn() or "Head"
		local hitbox = Util.GetHitboxPart(targetChar, hitboxName)
		if not hitbox then return end

		-- FIX: Определяем режим стрельбы
		local silentEnabled = self._silentAim and self._silentAim.Enabled
		local cameraLockActive = self._cameraLock and self._cameraLock.Active

		-- FIX: Используем skipExtendedChecks=true для silent, чтобы не блокировать из-за FULLY_LOADED_CHAR и Attacking
		local canShootResult, gun = self._weaponService:CanShoot({
			forSilent = silentEnabled,
			checkMelee = true,
			checkNoSilent = silentEnabled,
			autoReload = true,
			skipExtendedChecks = silentEnabled,
		})

		if not canShootResult or not gun then return end

		-- Проверка дальности
		if not self._weaponService:IsTargetInRange(gun, hitbox.Position) then
			return
		end

		-- Отслеживание смены цели/оружия для semi-auto
		if target ~= self._lastTarget then
			self._hasShotTarget = false
			self._lastTarget = target
		end
		if gun ~= self._lastGun then
			self._hasShotTarget = false
			self._lastGun = gun
		end

		local isSemiAuto = not self._weaponService:CanHoldFire(gun)
		if isSemiAuto and self._hasShotTarget then return end

		self._delay = math.max(self._weaponService:GetFireRate(gun) + 0.02, self.MinDelay)

		-- FIX: Стрельба в зависимости от режима
		if silentEnabled then
			-- Silent mode: стреляем напрямую через FireShot, хук перепишет позицию
			if Util.IsVisible(Camera.CFrame.Position, hitbox) then
				local handle = gun:FindFirstChild("Handle")
				if handle then
					local predOpts = self._silentAim:GetPredictionOptions(targetChar)
					local predictedPos = self._shootingService:PredictPosition(targetChar, hitbox, predOpts)
					if not predictedPos then predictedPos = hitbox.Position end

					self._shootingService:FireShot(handle, hitbox, predictedPos, gun, {
						startPos = Camera.CFrame.Position,
					})
				end
			end
		elseif cameraLockActive then
			-- Camera lock mode: кликаем мышью
			pcall(function()
				if mouse1click then mouse1click() end
			end)
		else
			-- Ни silent, ни camlock: проверяем близость к перекрестию и кликаем
			local crosshairDist = Util.GetDistanceFromCrosshair(hitbox.Position)
			if crosshairDist <= 5 then
				pcall(function()
					if mouse1click then mouse1click() end
				end)
			end
		end

		self._lastShot = currentTime
		self._hasShotTarget = isSemiAuto
	end)
end

function TriggerBot:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end


-- ============================================================
-- LEGIT BOT (FIXED)
-- ============================================================

local LegitBot = {}
LegitBot.__index = LegitBot

function LegitBot.new(weaponService, shootingService, pingTracker, velocityTracker, combatManager)
	local self = setmetatable({}, LegitBot)
	self._enabled = false
	self.Hitbox = "Head"
	self.VisibleCheck = false

	self._weaponService = weaponService
	self._shootingService = shootingService
	self._pingTracker = pingTracker
	self._velocityTracker = velocityTracker
	self._combatManager = combatManager

	self.CameraLock = CameraLock.new(shootingService)
	self.Silent = SilentAim.new(shootingService, weaponService)
	self.Trigger = TriggerBot.new(shootingService, weaponService)

	self.ESP = {
		ShowCameraLockFOV = true,
		ShowSilentFOV = true,
		CameraLockFOVColor = Color3.fromRGB(255, 255, 255),
		SilentFOVColor = Color3.fromRGB(0, 255, 255),
		LockedColor = Color3.fromRGB(255, 70, 70),
	}

	self._fovCircles = FOVCircleManager.new()
	self._fovCircles:CreateCircle("CameraLock")
	self._fovCircles:CreateCircle("Silent")

	local getTargetFn = function(fov, visCheck, forSilent)
		return self:GetTarget(fov, visCheck, forSilent)
	end
	local hitboxFn = function()
		return self.Hitbox
	end
	-- FIX: провайдер VisibleCheck привязан к настройке
	local visibleCheckFn = function()
		return self.VisibleCheck
	end

	self.CameraLock:SetTargetProvider(getTargetFn)
	self.CameraLock:SetHitboxProvider(hitboxFn)
	self.CameraLock:SetVisibleCheckProvider(visibleCheckFn) -- FIX
	self.Silent:SetTargetProvider(getTargetFn)
	self.Silent:SetHitboxProvider(hitboxFn)
	self.Silent:SetVisibleCheckProvider(visibleCheckFn) -- FIX
	self.Silent:SetCombatManager(combatManager)
	self.Trigger:SetTargetProvider(getTargetFn)
	self.Trigger:SetHitboxProvider(hitboxFn)
	self.Trigger:SetSilentAim(self.Silent)
	self.Trigger:SetCameraLock(self.CameraLock)
	self.Trigger:SetCombatManager(combatManager)

	return self
end

function LegitBot:SetEnabled(value)
	self._enabled = value
	if not value then
		self:StopAll()
	end
end

function LegitBot:IsEnabled()
	return self._enabled
end

-- FIX: GetTarget теперь корректно использует visCheck параметр
function LegitBot:GetTarget(fov, useVisibleCheck, forSilent)
	local myChar, myHum, myRoot = Util.GetCharacterParts()
	if not myRoot then return nil end

	local gun = forSilent and self._weaponService:GetGun() or nil
	local bestTarget, bestScore = nil, math.huge

	for _, player in ipairs(Services.Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local char = player.Character
		if not char then continue end
		if not Util.IsCharacterAlive(char) then continue end

		local hitbox = Util.GetHitboxPart(char, self.Hitbox)
		if not hitbox then continue end

		local crosshairDist = Util.GetDistanceFromCrosshair(hitbox.Position)
		if crosshairDist > fov then continue end

		-- FIX: visibility check только если useVisibleCheck == true
		if useVisibleCheck then
			if not Util.IsVisible(Camera.CFrame.Position, hitbox) then continue end
		end

		if forSilent and gun then
			if not self._weaponService:IsTargetInRange(gun, hitbox.Position) then continue end
		end

		local worldDist = Util.GetWorldDistance(myRoot.Position, hitbox.Position)
		local score = (crosshairDist * 0.7) + (worldDist * 0.3)

		if score < bestScore then
			bestScore = score
			bestTarget = player
		end
	end

	return bestTarget
end

function LegitBot:StopAll()
	self.CameraLock:Stop()
	self.CameraLock.Active = false
	self.Silent:Stop()
	self.Silent.Enabled = false
	self.Trigger:Stop()
	self.Trigger.Active = false
end

function LegitBot:UpdateFOVCircles()
	local isEnabled = self._enabled

	local camLockVisible = isEnabled and self.ESP.ShowCameraLockFOV and self.CameraLock.Active
	local camLockColor = self.CameraLock.CurrentTarget and self.ESP.LockedColor or self.ESP.CameraLockFOVColor
	self._fovCircles:UpdateCircle("CameraLock", camLockVisible, self.CameraLock.FOV, camLockColor)

	local silentVisible = isEnabled and self.ESP.ShowSilentFOV and self.Silent.Enabled
	local silentColor = self.Silent.CurrentTarget and self.ESP.LockedColor or self.ESP.SilentFOVColor
	self._fovCircles:UpdateCircle("Silent", silentVisible, self.Silent.FOV, silentColor)
end

function LegitBot:ClearCache()
	self._velocityTracker:Clear()
end

function LegitBot:RestartIfEnabled()
	if self.Trigger.Active then self.Trigger:Start() end
	if self.Silent.Enabled then self.Silent:Start() end
end

-- ============================================================
-- RAGE BOT (FIXED)
-- ============================================================

local RageBot = {}
RageBot.__index = RageBot

function RageBot.new(weaponService, shootingService, pingTracker, velocityTracker, combatManager)
	local self = setmetatable({}, RageBot)
	self.Enabled = false
	self.Hitbox = "Head"
	self.Prediction = 0.15

	self.TargetSettings = {
		IgnoreFriends = false,
		IgnoredPlayers = {},
	}

	self.AutoPrediction = { Enabled = false }

	self.Autofire = {
		Enabled = false,
		Connection = nil,
		LastShot = 0,
	}

	self.Autoequip = {
		Enabled = false,
		Connection = nil,
		-- Priority теперь управляется через WEAPON_KILL_PRIORITY в CONSTANTS
	}

	self.Rapidfire = {
		Enabled = false,
		Speed = 2,
	}

	self.Killaura = {
		Enabled = false,
		Connection = nil,
		Range = 15,
		LastAttack = 0,
		AttackDelay = 0.1,
		AutoEquip = false,
	}

	self.ThreatCache = {}
	self.IgnorePlayersDropdown = nil

	self._weaponService = weaponService
	self._shootingService = shootingService
	self._pingTracker = pingTracker
	self._velocityTracker = velocityTracker
	self._combatManager = combatManager
	self._manualRapidFire = nil
	self._currentTarget = nil

	return self
end

function RageBot:SetManualRapidFire(mrf)
	self._manualRapidFire = mrf
end

function RageBot:RegisterThreat(attacker)
	if not attacker or not attacker:IsA("Player") then return end
	self.ThreatCache[attacker.UserId] = tick()
end

function RageBot:IsAimingAtMe(player)
	if not player then return false end
	local myChar = LocalPlayer.Character
	if not myChar then return false end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end
	local theirChar = player.Character
	if not theirChar then return false end
	local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
	if not theirRoot then return false end
	local lookVector = theirRoot.CFrame.LookVector
	local directionToMe = (myRoot.Position - theirRoot.Position).Unit
	return lookVector:Dot(directionToMe) > CONSTANTS.THREAT_AIM_DOT
end

function RageBot:HasGunEquipped(player)
	if not player then return false end
	local char = player.Character
	if not char then return false end
	local tool = char:FindFirstChildWhichIsA("Tool")
	if not tool then return false end
	if CONSTANTS.WEAPONS_MELEE[tool.Name:upper()] then return false end
	local ammo = tool:FindFirstChild("Ammo")
	if ammo and ammo:IsA("NumberValue") then return true end
	if tool:FindFirstChild("Handle") and tool:FindFirstChild("RemoteEvent") then
		return not CONSTANTS.WEAPONS_MELEE[tool.Name:upper()]
	end
	return false
end

function RageBot:_passesFilters(player)
	if not player then return false end
	if player == LocalPlayer then return false end
	local char = player.Character
	if char and char:FindFirstChildOfClass("ForceField") then return false end
	if self.TargetSettings.IgnoredPlayers[player.UserId] then return false end
	if self.TargetSettings.IgnoreFriends then
		local isFriend = false
		pcall(function() isFriend = player:IsFriendsWith(LocalPlayer.UserId) end)
		if isFriend then return false end
	end
	return true
end

function RageBot:_getFireDelay(gun)
	local baseRate = self._weaponService:GetFireRate(gun)
	if not self.Rapidfire.Enabled then return baseRate end
	return baseRate / self.Rapidfire.Speed
end

function RageBot:_getPredictionOptions()
	local opts = {}
	if self.AutoPrediction.Enabled then
		opts.useSmoothedVelocity = true
		opts.autoPrediction = true
	else
		opts.manualPrediction = self.Prediction
	end
	return opts
end

function RageBot:GetTarget()
	if not self.Enabled then return nil end
	local myChar, myHum, myRoot = Util.GetCharacterParts()
	if not myRoot then return nil end

	local gun = self._weaponService:GetGun()
	local maxDistance = gun and self._weaponService:GetWeaponRange(gun) or math.huge
	local bestTarget, bestScore = nil, math.huge

	for _, player in ipairs(Services.Players:GetPlayers()) do
		if not self:_passesFilters(player) then continue end
		local char = player.Character
		if not char then continue end
		if not Util.IsCharacterAlive(char) then continue end

		local hitbox = Util.GetHitboxPart(char, self.Hitbox)
		if not hitbox then continue end

		local targetRoot = char:FindFirstChild("HumanoidRootPart")
		local isDesyncing = targetRoot and targetRoot.AssemblyLinearVelocity.Magnitude > 100

		-- Для жесткого десинка игнорируем проверку стен (raycast может давать ложные промахи)
		if not isDesyncing then
			if not Util.IsVisible(Camera.CFrame.Position, hitbox) then continue end
		end

		local worldDist = Util.GetWorldDistance(myRoot.Position, hitbox.Position)
		if worldDist > maxDistance then continue end

		if worldDist < bestScore then
			bestScore = worldDist
			bestTarget = player
		end
	end

	self._currentTarget = bestTarget
	return bestTarget
end

function RageBot:GetTargetsInRange(range)
	local targets = {}
	local myChar, myHum, myRoot = Util.GetCharacterParts()
	if not myRoot then return targets end

	for _, player in ipairs(Services.Players:GetPlayers()) do
		if not self:_passesFilters(player) then continue end
		local char = player.Character
		if not char then continue end
		if not Util.IsCharacterAlive(char) then continue end

		local hitbox = Util.GetHitboxPart(char, self.Hitbox)
		if not hitbox then continue end

		local distance = Util.GetWorldDistance(myRoot.Position, hitbox.Position)
		if distance <= range then
			table.insert(targets, {player = player, distance = distance, hitbox = hitbox, character = char})
		end
	end

	table.sort(targets, function(a, b) return a.distance < b.distance end)
	return targets
end

-- FIX: _shootAtTarget использует skipExtendedChecks для Rage
function RageBot:_shootAtTarget(target)
	local predOpts = self:_getPredictionOptions()
	return self._shootingService:ShootAtTarget(target, self.Hitbox, {
		checkMelee = true,
		ignoreNoSilent = true,
		autoReload = true,
		checkRange = true,
		skipExtendedChecks = true, -- FIX: пропускаем расширенные проверки для Rage
		predictionOptions = predOpts,
	})
end

-- УСТАРЕВШАЯ: используем WeaponService:GetBestWeaponForKill()
function RageBot:_getBestWeapon()
	return self._weaponService:GetBestWeaponForKill()
end

-- FIX: StartAutofire с правильной логикой стрельбы
function RageBot:StartAutofire()
	if self.Autofire.Connection then return end
	self.Autofire.Connection = Services.RunService.RenderStepped:Connect(function()
		if not self.Enabled or not self.Autofire.Enabled then return end
		if self._combatManager:IsBlocked(CONSTANTS.PRIORITY_RAGE) then return end

		local currentTime = tick()

		-- FIX: сначала ищем цель, потом проверяем оружие
		local target = self:GetTarget()
		if not target then return end

		local targetChar = target.Character
		if not targetChar or not Util.IsCharacterAlive(targetChar) then return end

		-- FIX: Проверяем оружие с skipExtendedChecks и autoReload
		local canShootResult, gun = self._weaponService:CanShoot({
			forSilent = false,
			checkMelee = true,
			autoReload = true,
			skipExtendedChecks = true, -- FIX: не блокируем из-за FULLY_LOADED_CHAR и т.д.
		})

		if not canShootResult or not gun then
			-- FIX: Если не можем стрелять из-за патронов, пробуем перезарядку
			if gun then
				local ammo = gun:FindFirstChild("Ammo")
				if ammo and ammo.Value <= 0 then
					self._weaponService:ForceReload(gun)
				end
			end
			return
		end

		local fireDelay = math.max(self:_getFireDelay(gun), 0.01)
		if currentTime - self.Autofire.LastShot < fireDelay then return end

		if self:_shootAtTarget(target) then
			self.Autofire.LastShot = currentTime
		end
	end)
end

function RageBot:StopAutofire()
	if self.Autofire.Connection then
		self.Autofire.Connection:Disconnect()
		self.Autofire.Connection = nil
	end
end

function RageBot:StartAutoequip()
	if self.Autoequip.Connection then return end
	self.Autoequip.Connection = Services.RunService.Heartbeat:Connect(function()
		if not self.Enabled or not self.Autoequip.Enabled then return end
		if self._autoBuyRef then
			if self._autoBuyRef.GhostActive
				or self._autoBuyRef.BlockAutoEquip
				or self._autoBuyRef.IsBuying then
				return
			end
		end

		local char = LocalPlayer.Character
		if not char then return end

		local currentTool = char:FindFirstChildWhichIsA("Tool")
		
		-- Проверяем нужно ли переключаться с текущего оружия
		if currentTool and not self._weaponService:ShouldSwitchWeapon(currentTool) then
			return
		end

		local bestWeapon = self:_getBestWeapon()
		if bestWeapon then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(bestWeapon)
			end
		end
	end)
end

function RageBot:StopAutoequip()
	if self.Autoequip.Connection then
		self.Autoequip.Connection:Disconnect()
		self.Autoequip.Connection = nil
	end
end

function RageBot:StartKillaura()
	if self.Killaura.Connection then return end
	self.Killaura.Connection = Services.RunService.Heartbeat:Connect(function()
		if not self.Enabled or not self.Killaura.Enabled then return end
		if self._combatManager:IsBlocked(CONSTANTS.PRIORITY_RAGE) then return end

		local currentTime = tick()
		if currentTime - self.Killaura.LastAttack < self.Killaura.AttackDelay then return end

		local targets = self:GetTargetsInRange(self.Killaura.Range)
		if #targets == 0 then return end

		local char = LocalPlayer.Character
		if not char then return end
		local myRoot = char:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		if self.Killaura.AutoEquip and not (self._autoBuyRef and self._autoBuyRef.GhostActive) then
			local currentTool = char:FindFirstChildWhichIsA("Tool")
			local needsEquip = not currentTool or (currentTool and CONSTANTS.WEAPONS_MELEE[currentTool.Name:upper()])
			if needsEquip then
				local bestWeapon = self:_getBestWeapon()
				if bestWeapon then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid:EquipTool(bestWeapon) end
				end
			end
		end

		local gun = self._weaponService:GetGun()

		for _, targetData in ipairs(targets) do
			local target = targetData.player
			local hitbox = targetData.hitbox
			local targetChar = targetData.character

			if gun and not self._weaponService:IsMelee(gun) then
				if Util.IsVisible(Camera.CFrame.Position, hitbox) then
					self:_shootAtTarget(target)
					self.Killaura.LastAttack = currentTime
					break
				end
			else
				local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					if gun and gun:FindFirstChild("RemoteEvent") then
						local handle = gun:FindFirstChild("Handle")
						if handle then
							gun.RemoteEvent:FireServer("Hit", hitbox, handle)
						end
					else
						MainEvent:FireServer("Hit", hitbox)
					end
					self.Killaura.LastAttack = currentTime
					break
				end
			end
		end
	end)
end

function RageBot:StopKillaura()
	if self.Killaura.Connection then
		self.Killaura.Connection:Disconnect()
		self.Killaura.Connection = nil
	end
end

function RageBot:SetAutoBuyRef(autoBuy)
	self._autoBuyRef = autoBuy
end

function RageBot:SetEnabled(enabled)
	self.Enabled = enabled
	if not enabled then
		self:CleanupAll()
		self._velocityTracker:Clear()
	else
		if self.Autofire.Enabled then self:StartAutofire() end
		if self.Autoequip.Enabled then self:StartAutoequip() end
		if self.Killaura.Enabled then self:StartKillaura() end
	end
end

function RageBot:CleanupAll()
	self:StopAutofire()
	self:StopAutoequip()
	self:StopKillaura()
end

function RageBot:RestartIfEnabled()
	if self.Enabled then
		if self.Autofire.Enabled then self:StartAutofire() end
		if self.Autoequip.Enabled then self:StartAutoequip() end
		if self.Killaura.Enabled then self:StartKillaura() end
	end
end

-- ============================================================
-- MANUAL RAPID FIRE
-- ============================================================

local ManualRapidFire = {}
ManualRapidFire.__index = ManualRapidFire

function ManualRapidFire.new(weaponService, rageBot)
	local self = setmetatable({}, ManualRapidFire)
	self._weaponService = weaponService
	self._rageBot = rageBot
	self._active = false
	self._isFiring = false
	self._connections = {}
	return self
end

function ManualRapidFire:_getFireDelay()
	if not self._rageBot.Rapidfire.Enabled then return 0.1 end
	local gun = self._weaponService:GetGun()
	local baseRate = self._weaponService:GetFireRate(gun)
	return baseRate / self._rageBot.Rapidfire.Speed
end

function ManualRapidFire:Start()
	if self._active then return end
	self._active = true

	local beganConn = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not self._rageBot.Enabled then return end
		if not self._rageBot.Rapidfire.Enabled then return end
		if self._rageBot.Autofire.Enabled then return end

		local gun = self._weaponService:GetGun()
		if not gun then return end
		if self._weaponService:IsMelee(gun) then return end
		if self._isFiring then return end
		self._isFiring = true

		task.spawn(function()
			while self._isFiring and self._rageBot.Enabled and self._rageBot.Rapidfire.Enabled do
				local currentGun = self._weaponService:GetGun()
				if not currentGun then break end
				pcall(function() currentGun:Activate() end)
				local delay = math.max(self:_getFireDelay(), 0.01)
				task.wait(delay)
			end
		end)
	end)
	table.insert(self._connections, beganConn)

	local endedConn = Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._isFiring = false
		end
	end)
	table.insert(self._connections, endedConn)
end

function ManualRapidFire:Stop()
	self._active = false
	self._isFiring = false
	for _, conn in ipairs(self._connections) do
		pcall(function() conn:Disconnect() end)
	end
	self._connections = {}
end

-- ============================================================
-- MOVEMENT MODULE
-- ============================================================

local Movement = {}
Movement.__index = Movement

function Movement.new()
	local self = setmetatable({}, Movement)
	self.Fly = { Enabled = false, Speed = 250, Connection = nil, Active = false, Core = nil, BodyVelocity = nil, BodyGyro = nil }
	self.CFrameSpeed = { Enabled = false, Value = 50, Connection = nil, Active = false }
	self.BunnyHop = { Enabled = false, Speed = 50, Connection = nil }
	self.WalkSpeed = { Enabled = false, Value = 16, Connection = nil }
	self.JumpPower = { Enabled = false, Value = 50, Connection = nil }
	self.Spin360 = { Enabled = false, Speed = 30, Connection = nil }
	self.FlyCar = { Enabled = false, Speed = 50, Connection = nil }
	return self
end

function Movement:_createFlyCore(rootPart)
	local oldCore = workspace:FindFirstChild(CONSTANTS.FLY_CORE_NAME)
	if oldCore then oldCore:Destroy() end

	local core = Instance.new("Part")
	core.Name = CONSTANTS.FLY_CORE_NAME
	core.Size = CONSTANTS.FLY_CORE_SIZE
	core.CanCollide = false
	core.Transparency = 1
	core.Anchored = false
	core.Parent = workspace

	local weld = Instance.new("Weld")
	weld.Part0 = core
	weld.Part1 = rootPart
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = core

	return core
end

function Movement:_destroyFlyCore()
	if self.Fly.Core and self.Fly.Core.Parent then
		self.Fly.Core:Destroy()
	end
	self.Fly.Core = nil
	self.Fly.BodyVelocity = nil
	self.Fly.BodyGyro = nil
end

function Movement:StartFly()
	if self.Fly.Active then return end
	local char, hum, root = Util.GetCharacterParts()
	if not char or not hum or not root then return end

	self.Fly.Active = true

	if self.CFrameSpeed.Connection then
		self.CFrameSpeed.Connection:Disconnect()
		self.CFrameSpeed.Connection = nil
	end
	self.CFrameSpeed.Active = false

	if self.BunnyHop.Connection then
		self.BunnyHop.Connection:Disconnect()
		self.BunnyHop.Connection = nil
	end

	hum.PlatformStand = true
	self.Fly.Core = self:_createFlyCore(root)

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(CONSTANTS.FLY_MAX_FORCE, CONSTANTS.FLY_MAX_FORCE, CONSTANTS.FLY_MAX_FORCE)
	bv.Velocity = Vector3.zero
	bv.Parent = self.Fly.Core
	self.Fly.BodyVelocity = bv

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(CONSTANTS.FLY_GYRO_MAX_TORQUE, CONSTANTS.FLY_GYRO_MAX_TORQUE, CONSTANTS.FLY_GYRO_MAX_TORQUE)
	bg.P = CONSTANTS.FLY_GYRO_P
	bg.CFrame = self.Fly.Core.CFrame
	bg.Parent = self.Fly.Core
	self.Fly.BodyGyro = bg

	self.Fly.Connection = Services.RunService.RenderStepped:Connect(function()
		if not self.Fly.Enabled or not self.Fly.Active then return end
		if not self.Fly.BodyVelocity or not self.Fly.BodyGyro then return end
		if not self.Fly.Core or not self.Fly.Core.Parent then
			self:StopFly()
			return
		end

		local c, h, r = Util.GetCharacterParts()
		if not c or not r then
			self:StopFly()
			return
		end

		local camera = workspace.CurrentCamera
		local UIS = Services.UserInputService
		local moveDirection = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end

		self.Fly.BodyVelocity.Velocity = moveDirection * self.Fly.Speed
		self.Fly.BodyGyro.CFrame = camera.CFrame
	end)
end

function Movement:StopFly()
	self.Fly.Active = false
	if self.Fly.Connection then
		self.Fly.Connection:Disconnect()
		self.Fly.Connection = nil
	end
	local char, hum = Util.GetCharacterParts()
	if hum then hum.PlatformStand = false end
	self:_destroyFlyCore()

	if self.CFrameSpeed.Enabled and not self.CFrameSpeed.Active then
		self:StartCFrameSpeed()
	end
	if self.BunnyHop.Enabled and not self.BunnyHop.Connection then
		self:StartBunnyHop()
	end
end

function Movement:StartCFrameSpeed()
	if self.CFrameSpeed.Active then return end
	if self.Fly.Enabled and self.Fly.Active then return end
	self.CFrameSpeed.Active = true

	self.CFrameSpeed.Connection = Services.RunService.Stepped:Connect(function()
		if not self.CFrameSpeed.Enabled or not self.CFrameSpeed.Active then return end
		if self.Fly.Enabled and self.Fly.Active then
			self:StopCFrameSpeed()
			return
		end
		local c, h, r = Util.GetCharacterParts()
		if not c or not r or not h then return end
		local moveDir = h.MoveDirection
		if moveDir.Magnitude > 0 then
			r.CFrame = r.CFrame + moveDir * Util.CalculateCFrameSpeed(self.CFrameSpeed.Value)
		end
	end)
end

function Movement:StopCFrameSpeed()
	self.CFrameSpeed.Active = false
	if self.CFrameSpeed.Connection then
		self.CFrameSpeed.Connection:Disconnect()
		self.CFrameSpeed.Connection = nil
	end
end

function Movement:StartBunnyHop()
	if self.BunnyHop.Connection then return end
	if self.Fly.Enabled and self.Fly.Active then return end

	self.BunnyHop.Connection = Services.RunService.Stepped:Connect(function()
		if not self.BunnyHop.Enabled then return end
		if self.Fly.Enabled and self.Fly.Active then
			self:StopBunnyHop()
			return
		end
		local c, h, r = Util.GetCharacterParts()
		if not c or not h or not r then return end
		if h.FloorMaterial == Enum.Material.Air then
			local moveDir = h.MoveDirection
			if moveDir.Magnitude > 0 then
				r.CFrame = r.CFrame + moveDir * (self.BunnyHop.Speed / 100)
			end
		end
	end)
end

function Movement:StopBunnyHop()
	if self.BunnyHop.Connection then
		self.BunnyHop.Connection:Disconnect()
		self.BunnyHop.Connection = nil
	end
end

function Movement:StartWalkSpeed()
	if self.WalkSpeed.Connection then return end
	self.WalkSpeed.Connection = Services.RunService.RenderStepped:Connect(function()
		if not self.WalkSpeed.Enabled then return end
		local c, h = Util.GetCharacterParts()
		if h and h.WalkSpeed ~= self.WalkSpeed.Value then
			h.WalkSpeed = self.WalkSpeed.Value
		end
	end)
end

function Movement:StopWalkSpeed()
	if self.WalkSpeed.Connection then
		self.WalkSpeed.Connection:Disconnect()
		self.WalkSpeed.Connection = nil
	end
end

function Movement:StartJumpPower()
	if self.JumpPower.Connection then return end
	self.JumpPower.Connection = Services.RunService.RenderStepped:Connect(function()
		if not self.JumpPower.Enabled then return end
		local c, h = Util.GetCharacterParts()
		if h then
			-- Устанавливаем значение для старой системы
			if h.JumpPower ~= self.JumpPower.Value then
				h.JumpPower = self.JumpPower.Value
			end

			-- Вычисляем эквивалент для новой системы (JumpHeight) на которую переключает No Jump Cooldown
			-- Формула Roblox: JumpHeight = (JumpPower^2) / (2 * Gravity)
			local gravity = workspace.Gravity or 196.2
			local equivalentHeight = (self.JumpPower.Value * self.JumpPower.Value) / (2 * gravity)

			if h.JumpHeight ~= equivalentHeight then
				h.JumpHeight = equivalentHeight
			end
		end
	end)
end

function Movement:StopJumpPower()
	if self.JumpPower.Connection then
		self.JumpPower.Connection:Disconnect()
		self.JumpPower.Connection = nil
	end
end

function Movement:Start360Spin()
	if self.Spin360.Connection then return end
	self.Spin360.Connection = Services.RunService.RenderStepped:Connect(function(dt)
		if not self.Spin360.Enabled then return end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, self.Spin360.Speed * dt, 0)
		end
	end)
end

function Movement:Stop360Spin()
	if self.Spin360.Connection then
		self.Spin360.Connection:Disconnect()
		self.Spin360.Connection = nil
	end
end

function Movement:StartFlyCar()
	if self.FlyCar.Connection then return end

	local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
	if not vehicle then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if hum and hum.SeatPart then
			local current = hum.SeatPart
			while current.Parent and current.Parent ~= workspace.Vehicles do
				current = current.Parent
			end
			if current.Parent == workspace.Vehicles then
				vehicle = current
			end
		end
	end
	if not vehicle then return end

	local vf = vehicle:FindFirstChildOfClass("VectorForce")
	if not vf then return end

	local gyro = Instance.new("BodyGyro")
	gyro.Name = "FlyGyro"
	gyro.P = CONSTANTS.FLY_CAR_GYRO_P
	gyro.D = CONSTANTS.FLY_CAR_GYRO_D
	gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	gyro.CFrame = vehicle.CFrame
	gyro.Parent = vehicle

	self.FlyCar.Connection = Services.RunService.RenderStepped:Connect(function(deltaTime)
		if not vehicle or not vehicle.Parent or not vehicle:FindFirstChildOfClass("VectorForce") then
			self:StopFlyCar()
			return
		end

		local UIS = Services.UserInputService
		local camera = workspace.CurrentCamera

		local totalMass = vehicle.AssemblyMass
		local gravity = workspace.Gravity
		local hoverForce = Vector3.new(0, totalMass * gravity, 0)

		gyro.CFrame = camera.CFrame

		local speed = self.FlyCar.Speed * CONSTANTS.FLY_CAR_SPEED_MULT
		local moveVector = Vector3.new(0, 0, 0)

		if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end

		local verticalBonus = Vector3.new(0, 0, 0)
		if UIS:IsKeyDown(Enum.KeyCode.Q) then
			verticalBonus = Vector3.new(0, speed, 0)
		elseif UIS:IsKeyDown(Enum.KeyCode.E) then
			verticalBonus = Vector3.new(0, -speed, 0)
		end

		if moveVector.Magnitude > 0 then
			moveVector = moveVector.Unit * speed
		end

		vf.Force = hoverForce + moveVector + verticalBonus
	end)
end

function Movement:StopFlyCar()
	if self.FlyCar.Connection then
		self.FlyCar.Connection:Disconnect()
		self.FlyCar.Connection = nil
	end

	local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
	if not vehicle then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if hum and hum.SeatPart then
			local current = hum.SeatPart
			while current.Parent and current.Parent ~= workspace.Vehicles do
				current = current.Parent
			end
			if current.Parent == workspace.Vehicles then
				vehicle = current
			end
		end
	end

	if vehicle then
		local gyro = vehicle:FindFirstChild("FlyGyro")
		if gyro then gyro:Destroy() end
		local vf = vehicle:FindFirstChildOfClass("VectorForce")
		if vf then vf.Force = Vector3.new(0, 0, 0) end
	end
end

function Movement:CleanupAll()
	self:StopFly()
	self:StopCFrameSpeed()
	self:StopBunnyHop()
	self:StopWalkSpeed()
	self:StopJumpPower()
	self:Stop360Spin()
	self:StopFlyCar()
end

function Movement:RestartIfEnabled()
	if self.Fly.Enabled then
		self:StartFly()
	else
		if self.CFrameSpeed.Enabled then self:StartCFrameSpeed() end
		if self.BunnyHop.Enabled then self:StartBunnyHop() end
	end
	if self.WalkSpeed.Enabled then self:StartWalkSpeed() end
	if self.JumpPower.Enabled then self:StartJumpPower() end
	if self.Spin360.Enabled then self:Start360Spin() end
	if self.FlyCar.Enabled then self:StartFlyCar() end
end

-- ============================================================
-- CHARACTER MODULE (FIXED: Noclip performance, connection leaks)
-- ============================================================

local CharacterModule = {}
CharacterModule.__index = CharacterModule

function CharacterModule.new(movement)
	local self = setmetatable({}, CharacterModule)
	self._movement = movement
	self.Noclip = { Enabled = false, Connection = nil }
	self.AntiFling = { Enabled = false, Connection = nil }
	self.AutoReload = { Enabled = false, Connection = nil }
	self.NoSlow = { Enabled = false, Connection = nil, WalkSpeedConnection = nil, OriginalWalkSpeed = 16, OriginalJumpPower = 50 }
	self.NoJumpCooldown = { Enabled = false, Connection = nil }
	self.NoSeat = { Enabled = false, Connection = nil }
	self.InfiniteZoom = { Enabled = false, DefaultMax = 128, DefaultMin = 0.5 }
	self.Fell = { Enabled = false, Thread = nil }
	-- FIX: кешируем части для Noclip
	self._noclipParts = {}
	self._noclipCharConnection = nil
	self.AntiFlingBypass = false
	return self
end

-- FIX: Noclip теперь кеширует BasePart вместо GetDescendants каждый кадр
function CharacterModule:_cacheNoclipParts()
	self._noclipParts = {}
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(self._noclipParts, part)
		end
	end
end

function CharacterModule:EnableNoclip()
	if self.Noclip.Connection then return end

	self:_cacheNoclipParts()

	-- FIX: обновляем кеш при изменении персонажа
	local char = LocalPlayer.Character
	if char then
		self._noclipCharConnection = char.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") then
				table.insert(self._noclipParts, desc)
			end
		end)
	end

	self.Noclip.Connection = Services.RunService.Stepped:Connect(function()
		for _, part in ipairs(self._noclipParts) do
			if part and part.Parent then
				part.CanCollide = false
			end
		end
	end)
end

function CharacterModule:DisableNoclip()
	if self.Noclip.Connection then
		self.Noclip.Connection:Disconnect()
		self.Noclip.Connection = nil
	end
	if self._noclipCharConnection then
		self._noclipCharConnection:Disconnect()
		self._noclipCharConnection = nil
	end
	self._noclipParts = {}
end

function CharacterModule:EnableAntiFling()
	if self.AntiFling.Connection then return end

	-- Инициализация полей для хранения connections
	if not self._antiFlingPlayerConnections then
		self._antiFlingPlayerConnections = {}
	end
	self._lastSafePosition = nil

	-- ЧАСТЬ 1: Нейтрализация ЧУЖИХ игроков
	local function neutralizePlayer(player)
		if player == LocalPlayer then return end

		-- Инициализация таблицы connections для этого игрока
		if not self._antiFlingPlayerConnections[player] then
			self._antiFlingPlayerConnections[player] = {}
		end

		local function processCharacter(character)
			if not character then return end

			local conn = Services.RunService.Heartbeat:Connect(function()
				if not character or not character.Parent then
					if conn then conn:Disconnect() end
					return
				end

				local theirRoot = character:FindFirstChild("HumanoidRootPart")
				if not theirRoot then return end

				local angularSpeed = theirRoot.AssemblyAngularVelocity.Magnitude
				local linearSpeed = theirRoot.AssemblyLinearVelocity.Magnitude

				if angularSpeed > 50 or linearSpeed > 100 then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
							part.AssemblyAngularVelocity = Vector3.zero
							part.AssemblyLinearVelocity = Vector3.zero
							part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
						end
					end
				end
			end)

			-- Сохраняем connection в таблицу для этого игрока
			table.insert(self._antiFlingPlayerConnections[player], conn)

			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Died:Once(function()
					if conn then
						conn:Disconnect()
						-- Удаляем connection из таблицы
						for i, c in ipairs(self._antiFlingPlayerConnections[player]) do
							if c == conn then
								table.remove(self._antiFlingPlayerConnections[player], i)
								break
							end
						end
					end
				end)
			end
		end

		if player.Character then
			processCharacter(player.Character)
		end

		local charAddedConn = player.CharacterAdded:Connect(processCharacter)
		table.insert(self._antiFlingPlayerConnections[player], charAddedConn)
	end

	-- Обрабатываем всех существующих игроков
	for _, player in ipairs(Services.Players:GetPlayers()) do
		neutralizePlayer(player)
	end

	-- Обработчик для новых игроков
	self._antiFlingPlayerAddedConn = Services.Players.PlayerAdded:Connect(neutralizePlayer)

	-- ЧАСТЬ 2: Защита СВОЕГО персонажа
	self.AntiFling.Connection = Services.RunService.Heartbeat:Connect(function()
		if self.AntiFlingBypass then return end

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local linearSpeed = hrp.AssemblyLinearVelocity.Magnitude
		local angularSpeed = hrp.AssemblyAngularVelocity.Magnitude

		-- Проверка активности movement-модулей
		local movementActive = false
		if self._movement then
			if (self._movement.Fly and self._movement.Fly.Enabled and self._movement.Fly.Active) or
			   (self._movement.CFrameSpeed and self._movement.CFrameSpeed.Enabled) or
			   (self._movement.BunnyHop and self._movement.BunnyHop.Enabled) or
			   (self._movement.Spin360 and self._movement.Spin360.Enabled) or
			   (self._movement.FlyCar and self._movement.FlyCar.Enabled) then
				movementActive = true
			end
		end

		if movementActive then
			-- Если movement активен - сохраняем lastSafePosition если скорость < 50, и RETURN
			if linearSpeed < 50 then
				self._lastSafePosition = hrp.CFrame
			end
			return
		end

		-- Если movement не активен - проверяем пороги
		if linearSpeed > 250 or angularSpeed > 250 then
			-- Превышен порог - зануливаем velocity и телепортируем
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			if self._lastSafePosition then
				hrp.CFrame = self._lastSafePosition
			end
		else
			-- Если linearSpeed < 50 - обновляем lastSafePosition
			if linearSpeed < 50 then
				self._lastSafePosition = hrp.CFrame
			end
		end
	end)
end

function CharacterModule:DisableAntiFling()
	-- Disconnect защита своего персонажа
	if self.AntiFling.Connection then
		self.AntiFling.Connection:Disconnect()
		self.AntiFling.Connection = nil
	end

	-- Disconnect обработчик PlayerAdded
	if self._antiFlingPlayerAddedConn then
		self._antiFlingPlayerAddedConn:Disconnect()
		self._antiFlingPlayerAddedConn = nil
	end

	-- Disconnect всех connections для чужих игроков
	if self._antiFlingPlayerConnections then
		for player, connections in pairs(self._antiFlingPlayerConnections) do
			if type(connections) == "table" then
				for _, conn in ipairs(connections) do
					pcall(function()
						if conn then
							conn:Disconnect()
						end
					end)
				end
			end
		end
		self._antiFlingPlayerConnections = {}
	end

	-- Обнуление всех полей
	self._lastSafePosition = nil
end

function CharacterModule:EnableAutoReload()
	if self.AutoReload.Connection then return end
	self.AutoReload.Connection = Services.RunService.Stepped:Connect(function()
		if not self.AutoReload.Enabled then return end
		local char = LocalPlayer.Character
		if not char then return end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			local ammo = tool:FindFirstChild("Ammo")
			if ammo and ammo.Value <= 0 then
				MainEvent:FireServer("Reload", tool)
			end
		end
		task.wait(1)
	end)
end

function CharacterModule:DisableAutoReload()
	if self.AutoReload.Connection then
		self.AutoReload.Connection:Disconnect()
		self.AutoReload.Connection = nil
	end
end

function CharacterModule:EnableNoSlow()
	if self.NoSlow.Connection then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		self.NoSlow.OriginalWalkSpeed = hum.WalkSpeed
		self.NoSlow.OriginalJumpPower = hum.JumpPower
	end

	self.NoSlow.Connection = Services.RunService.Stepped:Connect(function()
		if not self.NoSlow.Enabled then return end
		local character = LocalPlayer.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local bodyEffects = character:FindFirstChild("BodyEffects")

		if bodyEffects then
			local movement = bodyEffects:FindFirstChild("Movement")
			if movement then
				for _, effect in pairs(movement:GetChildren()) do
					effect:Destroy()
				end
			end

			local stunEffects = {
				"Stun", "Stunned", "Stunn", "Slow", "Slowed", "SlowEffect",
				"Frozen", "Freeze", "Paralyzed", "Paralyze", "Rooted", "Root",
				"Tased", "TaserEffect", "PepperSprayed", "Blinded", "Crippled", "Cripple",
			}

			for _, effectName in ipairs(stunEffects) do
				local effect = bodyEffects:FindFirstChild(effectName)
				if effect then
					if effect:IsA("ValueBase") then
						pcall(function() effect.Value = false end)
						pcall(function() effect.Value = 0 end)
					else
						pcall(function() effect:Destroy() end)
					end
				end
			end

			for _, child in pairs(bodyEffects:GetChildren()) do
				if child:IsA("NumberValue") then
					local name = child.Name:lower()
					if name:find("slow") or name:find("speed") or name:find("stun") then
						if child.Value < 0 then
							child.Value = 0
						end
					end
				end
			end
		end

		if humanoid then
			local minSpeed = self._movement.WalkSpeed.Enabled and self._movement.WalkSpeed.Value or self.NoSlow.OriginalWalkSpeed
			local minJump = self._movement.JumpPower.Enabled and self._movement.JumpPower.Value or self.NoSlow.OriginalJumpPower

			if humanoid.WalkSpeed < minSpeed then
				humanoid.WalkSpeed = minSpeed
			end

			-- Проверяем старую систему прыжка
			if humanoid.JumpPower < minJump then
				humanoid.JumpPower = minJump
			end

			-- Защищаем новую систему прыжка (для работы вместе с No Jump Cooldown)
			local gravity = workspace.Gravity or 196.2
			local minJumpHeight = (minJump * minJump) / (2 * gravity)
			if humanoid.JumpHeight < minJumpHeight then
				humanoid.JumpHeight = minJumpHeight
			end

			if humanoid.PlatformStand and not (self._movement.Fly.Enabled and self._movement.Fly.Active) then
				humanoid.PlatformStand = false
			end
		end
	end)

	local currentChar = LocalPlayer.Character
	local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
	if currentHum then
		self.NoSlow.WalkSpeedConnection = currentHum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if not self.NoSlow.Enabled then return end
			local minSpeed = self._movement.WalkSpeed.Enabled and self._movement.WalkSpeed.Value or self.NoSlow.OriginalWalkSpeed
			if currentHum.WalkSpeed < minSpeed then
				task.defer(function()
					if self.NoSlow.Enabled and currentHum and currentHum.Parent then
						currentHum.WalkSpeed = minSpeed
					end
				end)
			end
		end)
	end
end

function CharacterModule:DisableNoSlow()
	if self.NoSlow.Connection then
		self.NoSlow.Connection:Disconnect()
		self.NoSlow.Connection = nil
	end
	if self.NoSlow.WalkSpeedConnection then
		self.NoSlow.WalkSpeedConnection:Disconnect()
		self.NoSlow.WalkSpeedConnection = nil
	end
end

function CharacterModule:EnableNoJumpCooldown()
	if self.NoJumpCooldown.Connection then return end
	self.NoJumpCooldown.Connection = Services.RunService.Stepped:Connect(function()
		if not self.NoJumpCooldown.Enabled then return end
		local c, h = Util.GetCharacterParts()
		if h then h.UseJumpPower = false end
	end)
end

function CharacterModule:DisableNoJumpCooldown()
	if self.NoJumpCooldown.Connection then
		self.NoJumpCooldown.Connection:Disconnect()
		self.NoJumpCooldown.Connection = nil
	end
	local c, h = Util.GetCharacterParts()
	if h then h.UseJumpPower = true end
end

function CharacterModule:EnableNoSeat()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			obj.Disabled = true
		end
	end
	self.NoSeat.Connection = workspace.DescendantAdded:Connect(function(obj)
		if self.NoSeat.Enabled and (obj:IsA("Seat") or obj:IsA("VehicleSeat")) then
			obj.Disabled = true
		end
	end)
end

function CharacterModule:DisableNoSeat()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			obj.Disabled = false
		end
	end
	if self.NoSeat.Connection then
		self.NoSeat.Connection:Disconnect()
		self.NoSeat.Connection = nil
	end
end

function CharacterModule:EnableInfiniteZoom()
	self.InfiniteZoom.DefaultMax = LocalPlayer.CameraMaxZoomDistance
	self.InfiniteZoom.DefaultMin = LocalPlayer.CameraMinZoomDistance
	LocalPlayer.CameraMaxZoomDistance = 9999
	LocalPlayer.CameraMinZoomDistance = 0.5
end

function CharacterModule:DisableInfiniteZoom()
	LocalPlayer.CameraMaxZoomDistance = self.InfiniteZoom.DefaultMax
	LocalPlayer.CameraMinZoomDistance = self.InfiniteZoom.DefaultMin
end

function CharacterModule:StartFell()
	self.Fell.Thread = task.spawn(function()
		while self.Fell.Enabled do
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				hum:ChangeState(Enum.HumanoidStateType.FallingDown)
				task.wait(1.5)
				if not self.Fell.Enabled then break end
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				task.wait(1)
			else
				task.wait(0.5)
			end
		end
	end)
end

function CharacterModule:StopFell()
	self.Fell.Enabled = false
	if self.Fell.Thread then
		task.cancel(self.Fell.Thread)
		self.Fell.Thread = nil
	end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function CharacterModule:CleanupAll()
	self:DisableNoclip()
	self:DisableAntiFling()
	self:DisableAutoReload()
	self:DisableNoSlow()
	self:DisableNoJumpCooldown()
	self:StopFell()
end

function CharacterModule:RestartIfEnabled()
	if self.Noclip.Enabled then self:EnableNoclip() end
	if self.AntiFling.Enabled then self:EnableAntiFling() end
	if self.AutoReload.Enabled then self:EnableAutoReload() end
	if self.NoSlow.Enabled then self:EnableNoSlow() end
	if self.NoJumpCooldown.Enabled then self:EnableNoJumpCooldown() end
	if self.InfiniteZoom.Enabled then self:EnableInfiniteZoom() end
	if self.Fell.Enabled then self:StartFell() end
end

-- ============================================================
-- AUTOBUY MODULE (ПОЛНОСТЬЮ ИСПРАВЛЕН)
-- ============================================================

local AutoBuy = {}
AutoBuy.__index = AutoBuy

function AutoBuy.new(weaponService)
    local self = setmetatable({}, AutoBuy)
    self._weaponService = weaponService
    self.Enabled = false
    self.SelectedWeapons = {}
    self.SelectedArmor = {}
    self.SelectedMasks = {}
    self.AutoAmmo = false
    self.AmmoPriority = "Equipped First"
    self.RecentPurchases = {}
    self.LastAmmoRequest = {}
    self.BuyQueue = {}
    self.IsBuying = false
    self.GhostActive = false
    self.BlockAutoEquip = false
    self.Connection = nil
    self.LastQueueTick = 0

    self.WeaponsDropdown = nil
    self.ArmorDropdown = nil
    self.MasksDropdown = nil

    self._shopIndex = nil
    self._shopIndexTime = 0
    self._shopIndexTTL = 10

    return self
end

AutoBuy.WeaponsList = {
    "Glock", "Silencer", "SilencerAR", "SMG", "AR", "AK47", "AUG", "P90",
    "Shotgun", "TacticalShotgun", "Double-Barrel SG", "Drum-Shotgun",
    "Revolver", "Flintlock", "Rifle", "LMG", "DrumGun",
    "RPG", "GrenadeLauncher", "Flamethrower",
    "Knife", "Bat", "SledgeHammer", "Pitchfork", "Shovel", "StopSign",
    "Taser", "PepperSpray", "Grenade", "Flashbang", "TearGas"
}

AutoBuy.ArmorList = {
    "Medium Armor", "High-Medium Armor", "Fire Armor"
}

AutoBuy.MasksList = {
    "Paintball Mask", "Ninja Mask", "Surgeon Mask", "Riot Mask",
    "Hockey Mask", "Breathing Mask", "Pumpkin Mask", "Skull Mask"
}

-- ФИКС 1: dropdownName -> exact bracket content (shop)
AutoBuy.ShopNameMapping = {
    ["Glock"] = "Glock",
    ["Silencer"] = "Silencer",
    ["SilencerAR"] = "SilencerAR",
    ["SMG"] = "SMG",
    ["AR"] = "AR",
    ["AK47"] = "AK47",
    ["AUG"] = "AUG",
    ["P90"] = "P90",
    ["Shotgun"] = "Shotgun",
    ["TacticalShotgun"] = "TacticalShotgun",
    ["Double-Barrel SG"] = "Double-Barrel SG",
    ["Drum-Shotgun"] = "Drum-Shotgun",
    ["Revolver"] = "Revolver",
    ["Flintlock"] = "Flintlock",
    ["Rifle"] = "Rifle",
    ["LMG"] = "LMG",
    ["DrumGun"] = "DrumGun",
    ["RPG"] = "RPG",
    ["GrenadeLauncher"] = "GrenadeLauncher",
    ["Flamethrower"] = "Flamethrower",
    ["Knife"] = "Knife",
    ["Bat"] = "Bat",
    ["SledgeHammer"] = "SledgeHammer",
    ["Pitchfork"] = "Pitchfork",
    ["Shovel"] = "Shovel",
    ["StopSign"] = "StopSign",
    ["Taser"] = "Taser",
    ["PepperSpray"] = "PepperSpray",
    ["Grenade"] = "Grenade",
    ["Flashbang"] = "Flashbang",
    ["TearGas"] = "TearGas",
    -- Armor
    ["Medium Armor"] = "Medium Armor",
    ["High-Medium Armor"] = "High-Medium Armor",
    ["Fire Armor"] = "Fire Armor",
    -- Masks
    ["Paintball Mask"] = "Paintball Mask",
    ["Ninja Mask"] = "Ninja Mask",
    ["Surgeon Mask"] = "Surgeon Mask",
    ["Riot Mask"] = "Riot Mask",
    ["Hockey Mask"] = "Hockey Mask",
    ["Breathing Mask"] = "Breathing Mask",
    ["Pumpkin Mask"] = "Pumpkin Mask",
    ["Skull Mask"] = "Skull Mask",
}

-- ФИКС 2: Ammo маппинг (name in dropdown/inventory to exact bracket content)
AutoBuy.AmmoShopMapping = {
    ["Glock"] = "Glock Ammo",
    ["Silencer"] = "Silencer Ammo",
    ["SilencerAR"] = "SilencerAR Ammo",
    ["SMG"] = "SMG Ammo",
    ["AR"] = "AR Ammo",
    ["AK47"] = "AK47 Ammo",
    ["AUG"] = "AUG Ammo",
    ["P90"] = "P90 Ammo",
    ["Shotgun"] = "Shotgun Ammo",
    ["TacticalShotgun"] = "TacticalShotgun Ammo",
    ["Double-Barrel SG"] = "Double-Barrel SG Ammo",
    ["Drum-Shotgun"] = "Drum-Shotgun Ammo",
    ["Revolver"] = "Revolver Ammo",
    ["Flintlock"] = "Flintlock Ammo",
    ["Rifle"] = "Rifle Ammo",
    ["LMG"] = "LMG Ammo",
    ["DrumGun"] = "DrumGun Ammo",
    ["RPG"] = "RPG Ammo",
    ["GrenadeLauncher"] = "GrenadeLauncher Ammo",
    ["Flamethrower"] = "Flamethrower Ammo",
}

-- ============================================================
-- НОРМАЛИЗАЦИЯ ИМЁН (NOT USED by main routines anymore)
-- ============================================================
function AutoBuy:_normalize(name)
    if not name then return "" end
    return tostring(name):lower():gsub("%[", ""):gsub("%]", ""):gsub("%s+", ""):gsub("%-", ""):gsub("_", "")
end

-- ============================================================
-- ПЕРЕПИСАННЫЙ ДИНАМИЧЕСКИЙ ИНДЕКС МАГАЗИНА ПО ТОЧНОМУ BRACKET
-- ============================================================
function AutoBuy:_rebuildShopIndex()
    self._shopIndex = {}
    local shop = workspace:FindFirstChild("Ignored")
    if not shop then self._shopIndexTime = tick(); return end
    shop = shop:FindFirstChild("Shop")
    if not shop then self._shopIndexTime = tick(); return end

    for _, item in ipairs(shop:GetChildren()) do
        local fullName = item.Name
        local bracketContent = fullName:match("%[(.-)%]")
        if not bracketContent then continue end

        local clickDetector = item:FindFirstChild("ClickDetector")
        if not clickDetector then continue end

        local head = item:FindFirstChild("Head")
        local position = head and head.CFrame and head.CFrame.Position or nil
        if not position then
            pcall(function()
                position = item:GetPivot().Position
            end)
        end
        if not position then continue end

        self._shopIndex[bracketContent] = {
            Object = item,
            ClickDetector = clickDetector,
            Position = position,
            FullName = fullName,
            BracketName = bracketContent,
        }
    end
    self._shopIndexTime = tick()
end

function AutoBuy:_ensureShopIndex()
    if not self._shopIndex or (tick() - self._shopIndexTime) > self._shopIndexTTL then
        self:_rebuildShopIndex()
    end
end

-- ============================================================
-- ПЕРЕПИСАННЫЙ ТОЧНЫЙ ПОИСК ПРЕДМЕТА В МАГАЗИНЕ
-- ============================================================
function AutoBuy:_findInShop(itemName, isAmmo)
    self:_ensureShopIndex()
    if not self._shopIndex then return nil end

    local bracketName
    if isAmmo then
        bracketName = self.AmmoShopMapping[itemName]
        if not bracketName then
            bracketName = itemName .. " Ammo"
        end
    else
        bracketName = self.ShopNameMapping[itemName]
        if not bracketName then
            bracketName = itemName
        end
    end

    if self._shopIndex[bracketName] then
        return self._shopIndex[bracketName]
    end

    -- Try find by exact match in bracketContent
    for shopBracket, data in pairs(self._shopIndex) do
        if shopBracket == bracketName then
            return data
        end
    end

    warn("[AutoBuy] Item not found in shop: " .. tostring(bracketName) .. " (isAmmo: " .. tostring(isAmmo) .. ")")
    return nil
end

-- ============================================================
-- ПЕРЕПИСАННАЯ ПРОВЕРКА ВЛАДЕНИЯ ПРЕДМЕТОМ (ТОЧНО)
-- ============================================================
function AutoBuy:_needsToBuy(itemName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local shopName = self.ShopNameMapping[itemName] or itemName
    local expectedToolName = "[" .. shopName .. "]"

    -- Определяем тип
    local isArmor = false
    for _, n in ipairs(self.ArmorList) do
        if n == itemName then isArmor = true; break end
    end
    local isMask = false
    for _, n in ipairs(self.MasksList) do
        if n == itemName then isMask = true; break end
    end

    -- === ARMOR ===
    -- BodyEffects.Armor    <- Medium (дает 100) и High-Medium (дает 130)
    -- BodyEffects.FireArmor <- Fire Armor (стакается, макс 200)
    --
    -- Medium Armor:       не покупать если Armor >= 100
    -- High-Medium Armor:  не покупать если Armor >= 130
    -- Fire Armor:         не покупать если FireArmor >= 200
    if isArmor and character then
        local bodyEffects = character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local function getBodyEffectValue(effectName)
                local effect = bodyEffects:FindFirstChild(effectName)
                if not effect or not effect:IsA("ValueBase") then
                    return nil
                end
                return tonumber(effect.Value)
            end

            if itemName == "Fire Armor" then
                local fireArmorValue = getBodyEffectValue("FireArmor")
                if fireArmorValue and fireArmorValue >= 200 then
                    return false
                end
            elseif itemName == "High-Medium Armor" then
                local armorValue = getBodyEffectValue("Armor")
                if armorValue and armorValue >= 130 then
                    return false
                end
            elseif itemName == "Medium Armor" then
                local armorValue = getBodyEffectValue("Armor")
                if armorValue and armorValue >= 100 then
                    return false
                end
            end
        end
        return true
    end

    -- === MASK ===
    if isMask then
        local function hasMaskIn(container)
            if not container then return false end
            for _, item in ipairs(container:GetChildren()) do
                if (item:IsA("Tool") or item:IsA("Accessory")) then
                    local name = item.Name
                    if name == "Mask" or name == "[Mask]"
                        or name:lower():find("mask") then
                        return true
                    end
                end
            end
            return false
        end

        if hasMaskIn(backpack) then return false end
        if hasMaskIn(character) then return false end
        return true
    end

    -- === СТАНДАРТНАЯ ПРОВЕРКА (оружие и прочее) ===
    local function checkContainer(container)
        if not container then return false end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Accessory") then
                if item.Name == expectedToolName or item.Name == shopName or item.Name == itemName then
                    return true
                end
            end
        end
        return false
    end

    if checkContainer(backpack) then return false end
    if checkContainer(character) then return false end

    return true
end

-- ============================================================
-- ПЕРЕПИСАННАЯ ПРОВЕРКА НАХОЖДЕНИЯ ОРУЖИЯ С ТОЧНЫМ ПОИСКОМ
-- ============================================================
function AutoBuy:_findWeaponTool(weaponName)
    local shopName = self.ShopNameMapping[weaponName] or weaponName
    local expectedNames = {
        "[" .. shopName .. "]",
        shopName,
        weaponName,
    }
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local function searchContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                for _, name in ipairs(expectedNames) do
                    if item.Name == name then
                        return item
                    end
                end
            end
        end
        return nil
    end

    return searchContainer(character) or searchContainer(backpack)
end

-- ============================================================
-- ТОЧНО ПЕРЕПИСАННАЯ ПРОВЕРКА ПОТРЕБНОСТИ AMMO
-- ============================================================
function AutoBuy:_needsAmmo(weaponName)
    local weapon = self:_findWeaponTool(weaponName)
    if not weapon then return false end

    local ammo = weapon:FindFirstChild("Ammo")
    if not ammo then return false end

    local maxAmmo = self._weaponService:GetMaxAmmo(weapon)
    local currentAmmo = ammo.Value

    local stored = weapon:FindFirstChild("StoredAmmo")
    local storedValue = (stored and stored:IsA("NumberValue")) and stored.Value or 0

    -- Нужно ammo если текущие + запас меньше макс
    return (currentAmmo + storedValue) < maxAmmo
end

-- ============================================================
-- ПЕРЕПИСАННАЯ ПРОВЕРКА/QUEUE AMMO ПО НОВОЙ ЛОГИКЕ
-- ============================================================
function AutoBuy:_checkAmmoNeeds()
    if not self.AutoAmmo then return end
    local now = tick()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local function scanContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("Ammo") and item:FindFirstChild("Handle") then
                local cleanName = item.Name:match("%[(.-)%]") or item.Name
                local upper = cleanName:upper()
                if CONSTANTS.WEAPONS_MELEE[upper] then continue end
                if CONSTANTS.WEAPONS_NO_SILENT[upper] then continue end

                local ammo = item:FindFirstChild("Ammo")
                if ammo then
                    local maxAmmo = self._weaponService:GetMaxAmmo(item)
                    local currentAmmo = ammo.Value
                    local stored = item:FindFirstChild("StoredAmmo")
                    local storedValue = stored and stored:IsA("NumberValue") and stored.Value or 0
                    local needsAmmo = (currentAmmo + storedValue) < maxAmmo

                    if needsAmmo then
                        local ammoKey = cleanName
                        local lastRequest = self.LastAmmoRequest[ammoKey] or 0
                        if now - lastRequest >= CONSTANTS.AUTOBUY_AMMO_COOLDOWN then
                            if self.AmmoShopMapping[cleanName] then
                                self.LastAmmoRequest[ammoKey] = now
                                self:_queueBuy(cleanName, true)
                            else
                                for mapKey, _ in pairs(self.AmmoShopMapping) do
                                    if mapKey:upper() == upper then
                                        self.LastAmmoRequest[ammoKey] = now
                                        self:_queueBuy(mapKey, true)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    scanContainer(backpack)
    scanContainer(character)
end

-- ============================================================
-- ПРОЧИЕ НЕЗМЕНЁННЫЕ МЕТОДЫ (QUEUE, PROCESSING, ETC)
-- ============================================================
function AutoBuy:_queueBuy(itemName, isAmmo)
    -- Не дублируем
    for _, item in ipairs(self.BuyQueue) do
        if item.name == itemName and item.isAmmo == (isAmmo or false) then return end
    end

    local key = itemName .. (isAmmo and "_ammo" or "")
    local lastPurchase = self.RecentPurchases[key]
    if lastPurchase and (tick() - lastPurchase) < CONSTANTS.AUTOBUY_PURCHASE_COOLDOWN then return end

    table.insert(self.BuyQueue, {
        name = itemName,
        isAmmo = isAmmo or false,
    })
end

function AutoBuy:_processQueue()
    if self.IsBuying or #self.BuyQueue == 0 then return end
    if not self:_isCharacterReady() then return end

    self.IsBuying = true

    task.spawn(function()
        local ok, err = xpcall(function()
            local item = table.remove(self.BuyQueue, 1)
            if not item then return end

            self:_rebuildShopIndex()
            local shopData = self:_findInShop(item.name, item.isAmmo)
            if not shopData then
                return
            end

            local cash = self:_getCash()
            local price = self:_extractPrice(shopData.FullName)
            if cash and price and price > cash then
                return
            end

            local buySuccess = self:_ghostBuy(shopData, item.name)

            if buySuccess then
                local key = item.name .. (item.isAmmo and "_ammo" or "")
                self.RecentPurchases[key] = tick()
                if item.isAmmo then
                    task.wait(0.3)
                    local weapon = self:_findWeaponTool(item.name)
                    if weapon then
                        self._weaponService:ForceReload(weapon)
                    end
                end
            end

            task.wait(0.5)
        end, function(e)
            warn("[AutoBuy] ProcessQueue error: " .. tostring(e))
        end)

        self.IsBuying = false
    end)
end

function AutoBuy:_extractPrice(fullName)
    if not fullName then return nil end
    local priceStr = fullName:match("%$(%d+)")
    if priceStr then
        return tonumber(priceStr)
    end
    return nil
end

function AutoBuy:_getCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money")
        if cash and cash:IsA("ValueBase") then return cash.Value end
    end
    return nil
end

function AutoBuy:_queueSelectedItems()
    local function queueFrom(selection)
        if typeof(selection) ~= "table" then return end
        for itemName, isSelected in pairs(selection) do
            if isSelected then
                if self:_needsToBuy(itemName) then
                    self:_queueBuy(itemName, false)
                end
            end
        end
    end

    queueFrom(self.SelectedWeapons)
    queueFrom(self.SelectedArmor)
    queueFrom(self.SelectedMasks)
end

function AutoBuy:_isCharacterReady()
    local character = LocalPlayer.Character
    if not Util.IsCharacterAlive(character) then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Dead then
            return false
        end
    end

    local bodyEffects = character:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ragdoll = bodyEffects:FindFirstChild("Ragdoll")
            or bodyEffects:FindFirstChild("Ragdolled")
            or bodyEffects:FindFirstChild("Ragdolling")
        if ragdoll and ragdoll:IsA("ValueBase") and ragdoll.Value then
            return false
        end
    end

    return true
end

function AutoBuy:_getPing()
    local ping = 0
    pcall(function()
        ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ping == 0 then
        pcall(function()
            ping = LocalPlayer:GetNetworkPing() * 1000
        end)
    end
    return ping
end

function AutoBuy:_ghostBuy(shopData, itemName)
    if self.GhostActive then return false end
    if not shopData then return false end
    if not shopData.ClickDetector then return false end
    if not self:_isCharacterReady() then return false end
    if not fireclickdetector then return false end

    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    self.GhostActive = true
    self.BlockAutoEquip = true
    local buyResult = false

    local ok, err = xpcall(function()
        local targetPos
        if shopData.Object and shopData.Object.Parent then
            local head = shopData.Object:FindFirstChild("Head")
            if head then
                targetPos = head.CFrame.Position + Vector3.new(0, 3, 0)
            end
        end
        if not targetPos and shopData.Position then
            targetPos = shopData.Position + Vector3.new(0, 3, 0)
        end
        if not targetPos then return end

        local pingMs = self:_getPing()
        local framesNeeded = math.clamp(math.ceil((pingMs * 3) / 16.67) + 8, 12, 50)

        local equippedTool = character:FindFirstChildOfClass("Tool")
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local toolWasEquipped = false
        local savedTool = nil

        if equippedTool and backpack then
            toolWasEquipped = true
            savedTool = equippedTool
            equippedTool.Parent = backpack
            task.wait(0.05)
        end

        if not desyncEngine:Start(targetPos) then
            if toolWasEquipped and savedTool and savedTool.Parent == backpack then
                pcall(function() savedTool.Parent = character end)
            end
            return
        end

        local maxAttempts = 3
        local purchased = false

        for attempt = 1, maxAttempts do
            if purchased then break end

            local preClickFrames = math.ceil(framesNeeded * 0.5)
            for i = 1, preClickFrames do
                Services.RunService.Heartbeat:Wait()
                if not desyncEngine:IsActive() then break end
            end

            local clickDetector = shopData.ClickDetector
            if shopData.Object and shopData.Object.Parent then
                clickDetector = shopData.Object:FindFirstChild("ClickDetector") or clickDetector
            end

            for click = 1, 5 do
                pcall(function()
                    fireclickdetector(clickDetector, clickDetector.MaxActivationDistance or 10)
                end)
                task.wait(0.03)
            end

            local postClickFrames = math.ceil(framesNeeded * 0.5)
            for i = 1, postClickFrames do
                Services.RunService.Heartbeat:Wait()
                if not desyncEngine:IsActive() then break end
            end

            if not shopData.IsAmmo then
                if not self:_needsToBuy(itemName) then
                    purchased = true
                end
            else
                purchased = true
            end
        end

        desyncEngine:Stop()
        buyResult = purchased

        if toolWasEquipped and savedTool then
            pcall(function()
                if character and character.Parent and savedTool.Parent == backpack then
                    savedTool.Parent = character
                end
            end)
        end

    end, function(e)
        warn("[AutoBuy] GhostBuy error: " .. tostring(e))
        pcall(function() desyncEngine:Stop() end)
    end)

    self.GhostActive = false
    self.BlockAutoEquip = false
    return buyResult
end

function AutoBuy:StartLoop()
    if self.Connection then return end
    self.LastQueueTick = 0

    self.Connection = Services.RunService.Heartbeat:Connect(function()
        if not (self.Enabled or self.AutoAmmo) then return end
        if not self:_isCharacterReady() then return end
        if self.GhostActive then return end

        local now = tick()
        if now - (self.LastQueueTick or 0) < CONSTANTS.AUTOBUY_QUEUE_INTERVAL then return end
        self.LastQueueTick = now

        if self.Enabled then self:_queueSelectedItems() end
        if self.AutoAmmo then self:_checkAmmoNeeds() end
        self:_processQueue()
    end)
end

function AutoBuy:StopLoop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.BuyQueue = {}
    self.IsBuying = false
    self.GhostActive = false
    self.BlockAutoEquip = false
    self.LastQueueTick = 0
    self.LastAmmoRequest = {}
    self.RecentPurchases = {}
    self._shopIndex = nil
    self._shopIndexTime = 0
end

function AutoBuy:CleanupAll()
    self:StopLoop()
end

function AutoBuy:RestartIfEnabled()
    self.GhostActive = false
    self.BlockAutoEquip = false
    self.IsBuying = false
    if self.Enabled or self.AutoAmmo then self:StartLoop() end
end

-- ============================================================
-- CHAT SPY MODULE (FIXED: connection leaks in UI)
-- ============================================================

local ChatSpy = {}
ChatSpy.__index = ChatSpy

function ChatSpy.new()
	local self = setmetatable({}, ChatSpy)
	self.Enabled = false
	self.SpyOnMyself = false
	self._instance = 0
	self._connections = {}
	self._uiConnections = {} -- FIX: отдельный список для UI коннектов
	self._ui = nil
	self._frame = nil
	self._scrollFrame = nil
	self._messages = {}
	self._minimized = false
	return self
end

function ChatSpy:_createUI()
	-- FIX: уничтожаем старые UI коннекты
	for _, conn in ipairs(self._uiConnections) do
		pcall(function() conn:Disconnect() end)
	end
	self._uiConnections = {}

	if self._ui then self._ui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ChatSpyUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999
	pcall(function() screenGui.Parent = Services.CoreGui end)
	if not screenGui.Parent then
		screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	self._ui = screenGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 300)
	mainFrame.Position = UDim2.new(1, -370, 0.5, -150)
	mainFrame.BackgroundColor3 = ThemeConfig.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = ThemeConfig.Accent
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = mainFrame

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.ZIndex = -1
	shadow.Parent = mainFrame

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 35)
	header.BackgroundColor3 = ThemeConfig.Header
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 8)
	headerCorner.Parent = header

	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 10)
	headerFix.Position = UDim2.new(0, 0, 1, -10)
	headerFix.BackgroundColor3 = ThemeConfig.Header
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = " Chat Spy"
	title.TextColor3 = ThemeConfig.Accent
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 8, 0, 8)
	statusDot.Position = UDim2.new(0, 95, 0.5, -4)
	statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	statusDot.BorderSizePixel = 0
	statusDot.Parent = header
	Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

	local msgCount = Instance.new("TextLabel")
	msgCount.Name = "MsgCount"
	msgCount.Size = UDim2.new(0, 50, 1, 0)
	msgCount.Position = UDim2.new(1, -120, 0, 0)
	msgCount.BackgroundTransparency = 1
	msgCount.Text = "0"
	msgCount.TextColor3 = ThemeConfig.TextDim
	msgCount.TextSize = 12
	msgCount.Font = Enum.Font.Gotham
	msgCount.TextXAlignment = Enum.TextXAlignment.Right
	msgCount.Parent = header

	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
	minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
	minimizeBtn.BackgroundColor3 = ThemeConfig.Field
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Text = ""
	minimizeBtn.TextColor3 = ThemeConfig.Text
	minimizeBtn.TextSize = 18
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.Parent = header
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

	local clearBtn = Instance.new("TextButton")
	clearBtn.Size = UDim2.new(0, 25, 0, 25)
	clearBtn.Position = UDim2.new(1, -30, 0, 5)
	clearBtn.BackgroundColor3 = ThemeConfig.Field
	clearBtn.BorderSizePixel = 0
	clearBtn.Text = ""
	clearBtn.TextColor3 = ThemeConfig.Text
	clearBtn.TextSize = 12
	clearBtn.Font = Enum.Font.Gotham
	clearBtn.Parent = header
	Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -10, 1, -45)
	content.Position = UDim2.new(0, 5, 0, 40)
	content.BackgroundColor3 = ThemeConfig.Panel
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = mainFrame
	Instance.new("UICorner", content).CornerRadius = UDim.new(0, 6)

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -6, 1, -6)
	scrollFrame.Position = UDim2.new(0, 3, 0, 3)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = ThemeConfig.Accent
	scrollFrame.ScrollBarImageTransparency = 0.3
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Parent = content

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 3)
	listLayout.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 3)
	padding.PaddingBottom = UDim.new(0, 3)
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.Parent = scrollFrame

	self._frame = mainFrame
	self._scrollFrame = scrollFrame

	-- FIX: все UI коннекты добавляем в _uiConnections
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local c1 = header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	table.insert(self._uiConnections, c1)

	local c2 = header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	table.insert(self._uiConnections, c2)

	local c3 = Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	table.insert(self._uiConnections, c3)

	local c4 = minimizeBtn.MouseButton1Click:Connect(function()
		self._minimized = not self._minimized
		if self._minimized then
			Services.TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 350, 0, 35)}):Play()
			minimizeBtn.Text = "+"
			content.Visible = false
		else
			content.Visible = true
			Services.TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 350, 0, 300)}):Play()
			minimizeBtn.Text = ""
		end
	end)
	table.insert(self._uiConnections, c4)

	local c5 = clearBtn.MouseButton1Click:Connect(function()
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		self._messages = {}
		msgCount.Text = "0"
	end)
	table.insert(self._uiConnections, c5)

	local function addHover(button)
		local c6 = button.MouseEnter:Connect(function()
			Services.TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = ThemeConfig.Stroke}):Play()
		end)
		table.insert(self._uiConnections, c6)
		local c7 = button.MouseLeave:Connect(function()
			Services.TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = ThemeConfig.Field}):Play()
		end)
		table.insert(self._uiConnections, c7)
	end
	addHover(minimizeBtn)
	addHover(clearBtn)

	return screenGui
end

function ChatSpy:_addMessage(sender, message, isHidden)
	if not self._scrollFrame then return end

	local msgFrame = Instance.new("Frame")
	msgFrame.Size = UDim2.new(1, 0, 0, 0)
	msgFrame.AutomaticSize = Enum.AutomaticSize.Y
	msgFrame.BackgroundColor3 = isHidden and Color3.fromRGB(40, 20, 20) or ThemeConfig.Field
	msgFrame.BorderSizePixel = 0
	msgFrame.LayoutOrder = #self._messages + 1

	Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 4)

	local msgPadding = Instance.new("UIPadding")
	msgPadding.PaddingTop = UDim.new(0, 5)
	msgPadding.PaddingBottom = UDim.new(0, 5)
	msgPadding.PaddingLeft = UDim.new(0, 8)
	msgPadding.PaddingRight = UDim.new(0, 8)
	msgPadding.Parent = msgFrame

	local typeColor = isHidden and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
	local typeText = isHidden and "HIDDEN" or "PUBLIC"
	local typeIcon = isHidden and "" or ""

	local timeLabel = Instance.new("TextLabel")
	timeLabel.Size = UDim2.new(0, 45, 0, 14)
	timeLabel.Position = UDim2.new(0, 0, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = os.date("%H:%M")
	timeLabel.TextColor3 = ThemeConfig.TextDim
	timeLabel.TextSize = 10
	timeLabel.Font = Enum.Font.Gotham
	timeLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeLabel.Parent = msgFrame

	local typeBadge = Instance.new("TextLabel")
	typeBadge.Size = UDim2.new(0, 60, 0, 14)
	typeBadge.Position = UDim2.new(0, 48, 0, 0)
	typeBadge.BackgroundColor3 = typeColor
	typeBadge.BackgroundTransparency = 0.7
	typeBadge.Text = typeText
	typeBadge.TextColor3 = typeColor
	typeBadge.TextSize = 9
	typeBadge.Font = Enum.Font.GothamBold
	typeBadge.Parent = msgFrame
	Instance.new("UICorner", typeBadge).CornerRadius = UDim.new(0, 3)

	local senderLabel = Instance.new("TextLabel")
	senderLabel.Size = UDim2.new(1, -115, 0, 14)
	senderLabel.Position = UDim2.new(0, 115, 0, 0)
	senderLabel.BackgroundTransparency = 1
	senderLabel.Text = typeIcon .. " " .. sender
	senderLabel.TextColor3 = typeColor
	senderLabel.TextSize = 11
	senderLabel.Font = Enum.Font.GothamBold
	senderLabel.TextXAlignment = Enum.TextXAlignment.Left
	senderLabel.TextTruncate = Enum.TextTruncate.AtEnd
	senderLabel.Parent = msgFrame

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, 0, 0, 0)
	messageLabel.Position = UDim2.new(0, 0, 0, 18)
	messageLabel.AutomaticSize = Enum.AutomaticSize.Y
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = ThemeConfig.Text
	messageLabel.TextSize = 12
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = msgFrame

	msgFrame.Parent = self._scrollFrame
	table.insert(self._messages, msgFrame)

	local msgCountLabel = self._frame:FindFirstChild("Header"):FindFirstChild("MsgCount")
	if msgCountLabel then
		msgCountLabel.Text = tostring(#self._messages)
	end

	if #self._messages > CONSTANTS.CHATSPY_MAX_MESSAGES then
		local oldMsg = table.remove(self._messages, 1)
		if oldMsg then oldMsg:Destroy() end
	end

	task.defer(function()
		if self._scrollFrame then
			self._scrollFrame.CanvasPosition = Vector2.new(0, self._scrollFrame.AbsoluteCanvasSize.Y)
		end
	end)

	msgFrame.BackgroundTransparency = 1
	Services.TweenService:Create(msgFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end

function ChatSpy:Setup()
	for _, conn in ipairs(self._connections) do
		pcall(function() conn:Disconnect() end)
	end
	self._connections = {}

	self:_createUI()

	self._instance = self._instance + 1
	local currentInstance = self._instance

	local saymsg = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
	local getmsg = saymsg and saymsg:FindFirstChild("OnMessageDoneFiltering")

	if not getmsg then
		pcall(function()
			saymsg = Services.ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
			if saymsg then
				getmsg = saymsg:WaitForChild("OnMessageDoneFiltering", 5)
			end
		end)
	end

	local function onChatted(player, msg)
		if currentInstance ~= self._instance then return end
		if not self.Enabled then return end
		if not self.SpyOnMyself and player == LocalPlayer then return end

		msg = msg:gsub("[\n\r]", ''):gsub("\t", ' '):gsub("[ ]+", ' ')
		local hidden = true

		if getmsg then
			local conn
			conn = getmsg.OnClientEvent:Connect(function(packet, channel)
				if packet.SpeakerUserId == player.UserId then
					if packet.Message == msg:sub(#msg - #packet.Message + 1) then
						if channel == "All" then
							hidden = false
						elseif channel == "Team" then
							local teamPlayer = Services.Players:FindFirstChild(packet.FromSpeaker)
							if teamPlayer and teamPlayer.Team == LocalPlayer.Team then
								hidden = false
							end
						end
					end
				end
			end)
			task.wait(1)
			conn:Disconnect()
		end

		if self.Enabled and currentInstance == self._instance then
			self:_addMessage(player.Name, msg, hidden)
			if hidden then
				pcall(function()
					Services.StarterGui:SetCore("ChatMakeSystemMessage", {
						Text = "[SPY] " .. player.Name .. ": " .. msg,
						Color = Color3.fromRGB(255, 200, 0),
						Font = Enum.Font.SourceSansBold,
						TextSize = 18
					})
				end)
			end
		end
	end

	for _, player in ipairs(Services.Players:GetPlayers()) do
		local conn = player.Chatted:Connect(function(msg) onChatted(player, msg) end)
		table.insert(self._connections, conn)
	end

	local playerAddedConn = Services.Players.PlayerAdded:Connect(function(player)
		local conn = player.Chatted:Connect(function(msg) onChatted(player, msg) end)
		table.insert(self._connections, conn)
	end)
	table.insert(self._connections, playerAddedConn)

	pcall(function()
		local channels = Services.TextChatService:FindFirstChild("TextChannels")
		if channels then
			local function connectChannel(channel)
				if not channel:IsA("TextChannel") then return end
				local conn = channel.MessageReceived:Connect(function(msg)
					if not self.Enabled then return end
					if currentInstance ~= self._instance then return end
					pcall(function()
						if msg.TextSource then
							local player = Services.Players:GetPlayerByUserId(msg.TextSource.UserId)
							if player and (self.SpyOnMyself or player ~= LocalPlayer) then
								local channelName = channel.Name
								if channelName ~= "RBXGeneral" and channelName ~= "RBXSystem" then
									self:_addMessage(player.Name .. " [" .. channelName .. "]", msg.Text, true)
								end
							end
						end
					end)
				end)
				table.insert(self._connections, conn)
			end

			for _, channel in pairs(channels:GetChildren()) do
				connectChannel(channel)
			end
			local addedConn = channels.ChildAdded:Connect(function(channel)
				task.wait(0.1)
				connectChannel(channel)
			end)
			table.insert(self._connections, addedConn)
		end
	end)

	self:_addMessage("SYSTEM", "Chat Spy enabled - monitoring messages...", false)
end

function ChatSpy:Cleanup()
	for _, conn in ipairs(self._connections) do
		pcall(function() conn:Disconnect() end)
	end
	self._connections = {}
	-- FIX: очищаем UI коннекты тоже
	for _, conn in ipairs(self._uiConnections) do
		pcall(function() conn:Disconnect() end)
	end
	self._uiConnections = {}
	if self._ui then
		self._ui:Destroy()
		self._ui = nil
		self._frame = nil
		self._scrollFrame = nil
	end
	self._messages = {}
end

-- ============================================================
-- DETECTIONS MODULE — ЗАМЕНА через DesyncEngine
-- ============================================================

local Detections = {}
Detections.__index = Detections

function Detections.new()
	local self = setmetatable({}, Detections)
	self.RPGDetection = { Enabled = false }
	self.GranadeDetection = { Enabled = false }
	self.ModDetection = { Enabled = false, Connection = nil }
	self._threatLoop = nil
	self._charAddedConnection = nil
	self._isEvading = false
	self._currentOffset = Vector3.zero
	self._evadeStartTime = 0
	-- Таймер чтобы не менять offset каждый фрейм
	self._lastOffsetChange = 0
	self._offsetChangeInterval = 0.5 -- новый offset каждые 0.5 сек
	return self
end

function Detections:_isThreatNear(threatName)
	local success, result = pcall(function()
		local threat = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild(threatName)
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		return threat and hrp and (threat.Position - hrp.Position).Magnitude < CONSTANTS.THREAT_RANGE
	end)
	return success and result
end

function Detections:_generateEvadeOffset()
	return Vector3.new(
		math.random(-CONSTANTS.DETECTION_OFFSET_X, CONSTANTS.DETECTION_OFFSET_X),
		math.random(CONSTANTS.DETECTION_OFFSET_YMIN, CONSTANTS.DETECTION_OFFSET_YMAX),
		math.random(-CONSTANTS.DETECTION_OFFSET_Z, CONSTANTS.DETECTION_OFFSET_Z)
	)
end

function Detections:StartThreatDetection()
	if self._threatLoop then return end

	self._isEvading = false

	-- Один connection на PostSimulation — определяем нужно ли уворачиваться
	self._threatLoop = Services.RunService.PostSimulation:Connect(function()
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			if self._isEvading then
				self._isEvading = false
				desyncDetection:Stop()
			end
			return
		end

		-- Проверяем угрозы
		local rpgThreat = false
		pcall(function()
			local model = workspace.Ignored:FindFirstChild("Model")
			rpgThreat = model and model:FindFirstChild("Launcher") ~= nil
		end)
		local grenadeThreat = self:_isThreatNear("Handle")

		local shouldEvade = (self.RPGDetection.Enabled and rpgThreat)
			or (self.GranadeDetection.Enabled and grenadeThreat)

		if shouldEvade then
			local now = tick()

			if not self._isEvading then
				-- Начинаем уворот — генерируем offset и запускаем десинк
				self._currentOffset = self:_generateEvadeOffset()
				self._lastOffsetChange = now
				self._evadeStartTime = now

				local fakePos = hrp.CFrame.Position + self._currentOffset
				if desyncDetection:Start(fakePos) then
					self._isEvading = true
				end

			else
				-- Уже уворачиваемся — периодически меняем offset
				if now - self._lastOffsetChange > self._offsetChangeInterval then
					self._currentOffset = self:_generateEvadeOffset()
					self._lastOffsetChange = now
				end

				-- Обновляем фейковую позицию (игрок мог двигаться)
				local fakePos = hrp.CFrame.Position + self._currentOffset
				desyncDetection:SetFakePosition(fakePos)
			end
		else
			-- Угрозы нет — останавливаем десинк
			if self._isEvading then
				self._isEvading = false
				desyncDetection:Stop()
			end
		end
	end)

	-- CharacterAdded — сбрасываем состояние
	if not self._charAddedConnection then
		self._charAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
			if self._isEvading then
				self._isEvading = false
				desyncDetection:Stop()
			end
			task.wait(1)
		end)
	end
end

function Detections:StopThreatDetection()
	if self._isEvading then
		self._isEvading = false
		desyncDetection:Stop()
	end
	if self._threatLoop then
		self._threatLoop:Disconnect()
		self._threatLoop = nil
	end
	if self._charAddedConnection then
		self._charAddedConnection:Disconnect()
		self._charAddedConnection = nil
	end
end

-- ModDetection остаётся без изменений
function Detections:_checkPlayer(player)
	if not getgenv().ModDetectionEnabled or player == LocalPlayer then return end
	local success, role = pcall(function()
		return player:GetRoleInGroup(CONSTANTS.MOD_GROUP_ID)
	end)
	if success and role then
		for _, bannedRole in pairs(CONSTANTS.MOD_BLACKLISTED_ROLES) do
			if role == bannedRole then
				LocalPlayer:Kick(CONSTANTS.MOD_KICK_REASON)
				break
			end
		end
	end
end

function Detections:StartModDetection()
	if self.ModDetection.Connection then return end
	for _, player in pairs(Services.Players:GetPlayers()) do
		task.spawn(function() self:_checkPlayer(player) end)
	end
	self.ModDetection.Connection = Services.Players.PlayerAdded:Connect(function(player)
		self:_checkPlayer(player)
	end)
end

function Detections:StopModDetection()
	if self.ModDetection.Connection then
		self.ModDetection.Connection:Disconnect()
		self.ModDetection.Connection = nil
	end
end

-- ============================================================
-- PLAYER SYSTEM MODULE
-- ============================================================

local PlayerSystem = {}
PlayerSystem.__index = PlayerSystem

function PlayerSystem.new(weaponService, shootingService, combatManager, smartTeleport, charModule)
	local self = setmetatable({}, PlayerSystem)
	self._weaponService = weaponService
	self._shootingService = shootingService
	self._combatManager = combatManager
	self._smartTeleport = smartTeleport
	self._characterModule = charModule

	self.KnockActive = {}
	self.KillActive = {}
	self.AutoKillActive = false
	self.AutoKillTargets = {}
	self._autoKillPlayerConn = nil

	self.SpectatingPlayer = nil
	self.SelectedPlayer = nil
	self.Dropdown = nil

	self.SilentShot = {
		LastShot = 0,
		HiddenBullets = false,
		SpectateTarget = false,
	}

	-- НОВОЕ: Настройки Kill/Knock (десинк всегда активен)
	self.KillSettings = {
		BurstCount = 3,            -- Выстрелов за фрейм
		StompWaitFrames = 2,       -- Фреймов ожидания перед стомпом
		MaxShootFrames = 120,      -- Макс фреймов на фазу стрельбы
		MaxStompAttempts = 25,     -- Макс попыток стомпа
	}

	self._forceStopFlag = false
	self._desyncKillEngine = DesyncEngine.new() -- Отдельный desync для Kill/Knock
	return self
end

function PlayerSystem:ForceStop()
	self._forceStopFlag = true
	for player in pairs(self.KillActive) do
		self.KillActive[player] = nil
	end
	for player in pairs(self.KnockActive) do
		self.KnockActive[player] = nil
	end
	-- Останавливаем desync при force stop
	if self._desyncKillEngine:IsActive() then
		self._desyncKillEngine:Stop()
	end
end

function PlayerSystem:_resetForceStop()
	self._forceStopFlag = false
end

function PlayerSystem:_shouldStop()
	return self._forceStopFlag
end

function PlayerSystem:_startSpectateTarget(target)
	if not self.SilentShot.SpectateTarget then return end
	local char = target and target.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then Camera.CameraSubject = hum end
	end
end

function PlayerSystem:_stopSpectateTarget()
	if not self.SilentShot.SpectateTarget then return end
	local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
	if myHum then Camera.CameraSubject = myHum end
end

-- НОВОЕ: Рассчитать фейковую позицию рядом с целью для desync
function PlayerSystem:_calcFakePosition(targetCharacter)
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return nil end

	-- Позиция максимально близко к цели для десинка (сзади и выше на 3-5 studs)
	-- Сервер проверяет расстояние, поэтому SmartTeleport не нужен
	local behind = -targetRoot.CFrame.LookVector
	return targetRoot.Position + behind * 4 + Vector3.new(0, 2, 0)
end

-- НОВОЕ: Рассчитать позицию для стомпа
function PlayerSystem:_calcStompPosition(targetCharacter)
	local torso = targetCharacter:FindFirstChild("UpperTorso")
		or targetCharacter:FindFirstChild("Torso")
		or targetCharacter:FindFirstChild("HumanoidRootPart")
	if not torso then return nil end
	return torso.Position + Vector3.new(0, CONSTANTS.COMBAT_STOMP_HEIGHT, 0)
end

-- НОВОЕ: Обеспечить оружие и патроны (с ожиданием)
function PlayerSystem:_ensureWeaponAndAmmo()
	local gun = self._weaponService:GetGun()
	if gun and gun:FindFirstChild("Ammo") and not self._weaponService:IsMelee(gun) and not self._weaponService:IsNoSilent(gun) then
		local ammo = gun:FindFirstChild("Ammo")
		if ammo and ammo.Value <= 0 then
			if self._weaponService:ForceReload(gun) then
				self._weaponService:WaitForReload(gun, 2)
			end
		end
		return gun
	end

	local weaponReady, equippedGun = self._weaponService:EnsureWeaponEquipped()
	return equippedGun
end

-- НОВОЕ: Burst-fire — несколько выстрелов за фрейм через Bullet TP
function PlayerSystem:_burstFireAtTarget(targetChar, gun, fakePos, burstCount)
	burstCount = burstCount or self.KillSettings.BurstCount
	local shotsFired = 0

	local handle = gun:FindFirstChild("Handle")
	if not handle then return 0 end

	local hitbox = Util.GetHitboxPart(targetChar, "Head")
	if not hitbox then
		hitbox = Util.GetHitboxPart(targetChar, "UpperTorso")
	end
	if not hitbox then return 0 end

	for i = 1, burstCount do
		local ammo = gun:FindFirstChild("Ammo")
		if not ammo or ammo.Value <= 0 then
			-- Перезарядка если кончились патроны
			self._weaponService:ForceReload(gun)
			break
		end

		local predictedPos = self._shootingService:PredictPosition(targetChar, hitbox, {
			useSmoothedVelocity = true,
			autoPrediction = true,
		})
		if not predictedPos then predictedPos = hitbox.Position end

		-- Bullet TP: startPos = фейковая позиция (рядом с целью)
		local startPos = fakePos or handle.CFrame.Position
		self._shootingService:FireBulletTPShot(handle, hitbox, predictedPos, gun, startPos, {
			hiddenBullets = self.SilentShot.HiddenBullets,
		})
		shotsFired = shotsFired + 1
	end

	return shotsFired
end

-- НОВОЕ: Фаза стрельбы (до KO или смерти) через desync
function PlayerSystem:_shootPhase(target, stopOnKO)
	local frameCount = 0
	local totalShots = 0

	while frameCount < self.KillSettings.MaxShootFrames and not self:_shouldStop() do
		-- Проверка цели
		local targetChar = target.Character
		if not targetChar or not targetChar.Parent then break end

		local effects = targetChar:FindFirstChild("BodyEffects")
		if not effects then break end

		if stopOnKO then
			local ko = effects:FindFirstChild("K.O")
			if ko and ko.Value then break end
		end

		local deadVal = effects:FindFirstChild("Dead")
		if deadVal and deadVal.Value then break end

		-- Если цель в KO и мы не stopOnKO — тоже прерываем стрельбу, нужен stomp
		if not stopOnKO then
			local ko = effects:FindFirstChild("K.O")
			if ko and ko.Value then break end
		end

		-- Обновляем фейковую позицию (цель может двигаться)
		local fakePos = self:_calcFakePosition(targetChar)
		if not fakePos then break end

		if self._desyncKillEngine:IsActive() then
			self._desyncKillEngine:SetFakePosition(fakePos)
		end

		-- Оружие
		local gun = self:_ensureWeaponAndAmmo()
		if not gun then
			Services.RunService.Heartbeat:Wait()
			frameCount = frameCount + 1
			continue
		end

		-- Проверка патронов
		local ammo = gun:FindFirstChild("Ammo")
		if ammo and ammo.Value <= 0 then
			self._weaponService:ForceReload(gun)
			-- Ждём 1 фрейм после запроса перезарядки
			Services.RunService.Heartbeat:Wait()
			frameCount = frameCount + 1
			continue
		end

		-- Burst fire
		local shots = self:_burstFireAtTarget(targetChar, gun, fakePos, self.KillSettings.BurstCount)
		totalShots = totalShots + shots

		Services.RunService.Heartbeat:Wait()
		frameCount = frameCount + 1
	end

	return totalShots
end

-- НОВОЕ: Фаза стомпа через desync
function PlayerSystem:_stompPhase(target)
	local stompCount = 0

	while stompCount < self.KillSettings.MaxStompAttempts and not self:_shouldStop() do
		local targetChar = target.Character
		if not targetChar or not targetChar.Parent then break end

		local effects = targetChar:FindFirstChild("BodyEffects")
		if not effects then break end

		local deadValue = effects:FindFirstChild("Dead")
		local sDeathValue = effects:FindFirstChild("SDeath")
		if (deadValue and deadValue.Value) or (sDeathValue and sDeathValue.Value) then break end

		local koValue = effects:FindFirstChild("K.O")
		if not koValue or not koValue.Value then
			-- Ещё не KO — добиваем стрельбой
			local fakePos = self:_calcFakePosition(targetChar)
			if fakePos and self._desyncKillEngine:IsActive() then
				self._desyncKillEngine:SetFakePosition(fakePos)
			end

			local gun = self:_ensureWeaponAndAmmo()
			if gun then
				local ammo = gun:FindFirstChild("Ammo")
				if ammo and ammo.Value > 0 then
					self:_burstFireAtTarget(targetChar, gun, fakePos, self.KillSettings.BurstCount)
				else
					self._weaponService:ForceReload(gun)
				end
			end

			Services.RunService.Heartbeat:Wait()
			continue
		end

		-- KO — стомпаем
		local stompPos = self:_calcStompPosition(targetChar)
		if not stompPos then break end

		if self._desyncKillEngine:IsActive() then
			self._desyncKillEngine:SetFakePosition(stompPos)
		else
			-- Fallback: физический ТП для стомпа
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myRoot then myRoot.CFrame = CFrame.new(stompPos) end
		end

		-- Ждём несколько фреймов чтобы сервер зафиксировал позицию
		for i = 1, self.KillSettings.StompWaitFrames do
			Services.RunService.Heartbeat:Wait()
		end

		MainEvent:FireServer("Stomp")
		stompCount = stompCount + 1

		task.wait(math.max(CONSTANTS.COMBAT_STOMP_DELAY * 0.6, 0.1))
	end

	return stompCount
end

-- ПЕРЕРАБОТАНО: Knock с desync
function PlayerSystem:Knock(target)
	if not target then return end
	local targetChar = target.Character
	if not targetChar then return end
	if not Util.IsCharacterAlive(targetChar) then return end
	if self.KnockActive[target] then return end

	local bodyEffects = targetChar:FindFirstChild("BodyEffects")
	if not bodyEffects then return end
	local koValue = bodyEffects:FindFirstChild("K.O")
	if koValue and koValue.Value then return end

	if not self._combatManager:StartAction("ManualKnock", CONSTANTS.PRIORITY_MANUAL, self) then return end

	self.KnockActive[target] = true
	self:_resetForceStop()

	task.spawn(function()
		local myChar, myHum, myRoot = Util.GetCharacterParts()
		if not myRoot then
			self.KnockActive[target] = nil
			self._combatManager:EndAction("ManualKnock")
			return
		end

		self._weaponService:EnsureWeaponEquipped()
		self:_startSpectateTarget(target)

		-- Запускаем desync (обязательно)
		local fakePos = self:_calcFakePosition(targetChar)
		if fakePos then
			self._desyncKillEngine:Start(fakePos)
		end

		-- Стреляем через desync
		self:_shootPhase(target, true)

		-- Останавливаем desync
		if self._desyncKillEngine:IsActive() then
			self._desyncKillEngine:Stop()
		end

		self:_stopSpectateTarget()
		self.KnockActive[target] = nil
		self._combatManager:EndAction("ManualKnock")
	end)
end

-- ПЕРЕРАБОТАНО: Kill с desync (стрельба + стомп)
function PlayerSystem:Kill(target)
	if not target then return end
	local targetChar = target.Character
	if not targetChar then return end
	if not Util.IsCharacterAliveOrKO(targetChar) then return end
	if self.KillActive[target] then return end

	local bodyEffects = targetChar:FindFirstChild("BodyEffects")
	if not bodyEffects then return end
	local deadValue = bodyEffects:FindFirstChild("Dead")
	if deadValue and deadValue.Value then return end

	if not self._combatManager:StartAction("ManualKill", CONSTANTS.PRIORITY_MANUAL, self) then return end

	self.KillActive[target] = true
	self:_resetForceStop()

	task.spawn(function()
		local myChar, myHum, myRoot = Util.GetCharacterParts()
		if not myRoot then
			self.KillActive[target] = nil
			self._combatManager:EndAction("ManualKill")
			return
		end

		local skipShootingPhase = Util.IsTargetKO(targetChar)
		if not skipShootingPhase then
			self._weaponService:EnsureWeaponEquipped()
		end

		self:_startSpectateTarget(target)

		-- Запускаем desync (обязательно)
		local fakePos = self:_calcFakePosition(targetChar)
		if fakePos then
			self._desyncKillEngine:Start(fakePos)
		end

		-- Фаза стрельбы (если не уже KO)
		if not skipShootingPhase then
			self:_shootPhase(target, false)
		end

		-- Фаза стомпа
		self:_stompPhase(target)

		-- Останавливаем desync
		if self._desyncKillEngine:IsActive() then
			self._desyncKillEngine:Stop()
		end

		self:_stopSpectateTarget()
		self.KillActive[target] = nil
		self._combatManager:EndAction("ManualKill")
	end)
end

function PlayerSystem:Fling(target)
	if not target or not target.Character then return end
	local TargetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not TargetRoot then return end

	local Character = LocalPlayer.Character
	if not Character then return end
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return end

	local OriginalCFrame = RootPart.CFrame
	local OriginalCameraType = Camera.CameraType
	local OriginalCameraCFrame = Camera.CFrame
	local FlingDuration = 1.0
	local StartTime = tick()

	-- Включаем обход антифлинга
	if self._characterModule then
		self._characterModule.AntiFlingBypass = true
	end

	-- Фиксируем камеру чтобы не дёргалась
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = OriginalCameraCFrame

	-- Noclip чтобы не застревать
	local NoclipConnection = Services.RunService.Stepped:Connect(function()
		if Character then
			for _, part in ipairs(Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)

	-- LinearVelocity через Attachment (надёжнее чем прямой Velocity)
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = RootPart

	local LinearVel = Instance.new("LinearVelocity")
	LinearVel.Attachment0 = Attachment
	LinearVel.MaxForce = math.huge
	LinearVel.VectorVelocity = Vector3.zero
	LinearVel.Parent = RootPart

	local HeartbeatConnection
	HeartbeatConnection = Services.RunService.Heartbeat:Connect(function()
		if tick() - StartTime >= FlingDuration
			or not TargetRoot or not TargetRoot.Parent
			or not RootPart or not RootPart.Parent then

			-- Cleanup
			HeartbeatConnection:Disconnect()
			NoclipConnection:Disconnect()

			pcall(function() LinearVel:Destroy() end)
			pcall(function() Attachment:Destroy() end)

			-- Восстанавливаем камеру
			Camera.CameraType = OriginalCameraType
			Camera.CFrame = OriginalCameraCFrame

			-- Обнуляем скорости
			RootPart.AssemblyLinearVelocity = Vector3.zero
			RootPart.AssemblyAngularVelocity = Vector3.zero

			-- Возвращаемся на исходную позицию
			RootPart.CFrame = OriginalCFrame * CFrame.new(0, 3, 0)

			-- Восстанавливаем коллизию
			task.wait(0.1)
			if Character and Character.Parent then
				for _, part in ipairs(Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end

			-- Выключаем обход антифлинга
			if self._characterModule then
				self._characterModule.AntiFlingBypass = false
			end
		else
			-- Телепортируемся к цели и задаём огромную скорость
			RootPart.CFrame = TargetRoot.CFrame
			LinearVel.VectorVelocity = Vector3.new(1e5, 1e5, 1e5)
		end
	end)
end

function PlayerSystem:Teleport(target)
	if not target or not target.Character then return end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if targetRoot and root then
		root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
	end
end

function PlayerSystem:Spectate(target)
	if not target or not target.Character then return end
	local hum = target.Character:FindFirstChild("Humanoid")
	if hum then
		self.SpectatingPlayer = target
		Camera.CameraSubject = hum
	end
end

function PlayerSystem:StopSpectate()
	self.SpectatingPlayer = nil
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then Camera.CameraSubject = hum end
end

function PlayerSystem:AddAutoKillTarget(player)
	if not player or player == LocalPlayer then return false end
	if self.AutoKillTargets[player.UserId] then return false end
	self.AutoKillTargets[player.UserId] = player
	return true
end

function PlayerSystem:RemoveAutoKillTarget(player)
	if not player then return false end
	if not self.AutoKillTargets[player.UserId] then return false end
	self.AutoKillTargets[player.UserId] = nil
	self.KillActive[player] = nil
	return true
end

function PlayerSystem:GetAutoKillCount()
	local count = 0
	for _ in pairs(self.AutoKillTargets) do count = count + 1 end
	return count
end

function PlayerSystem:StartAutoKill()
	if self.AutoKillActive then return end
	self.AutoKillActive = true

	task.spawn(function()
		local desyncActive = false

		while self.AutoKillActive do
			local myChar, myHum, myRoot = Util.GetCharacterParts()
			if not myRoot then
				task.wait(0.5)
				continue
			end

			-- Собираем все живые цели с приоритизацией
			local targets = {}
			for userId, target in pairs(self.AutoKillTargets) do
				if not target or not target.Parent then
					self.AutoKillTargets[userId] = nil
					continue
				end

				local char = target.Character
				if not char then continue end
				if not Util.IsCharacterAliveOrKO(char) then continue end

				local effects = char:FindFirstChild("BodyEffects")
				if not effects then continue end
				local deadVal = effects:FindFirstChild("Dead")
				if deadVal and deadVal.Value then continue end

				local root = char:FindFirstChild("HumanoidRootPart")
				if not root then continue end

				local dist = (myRoot.Position - root.Position).Magnitude
				local isKO = Util.IsTargetKO(char)

				table.insert(targets, {
					player = target,
					character = char,
					distance = dist,
					isKO = isKO,
					-- KO цели — высший приоритет (быстро добить стомпом)
					priority = isKO and -1 or dist,
				})
			end

			table.sort(targets, function(a, b) return a.priority < b.priority end)

			if #targets == 0 then
				-- Нет целей — выключаем desync
				if self._desyncKillEngine:IsActive() then
					self._desyncKillEngine:Stop()
					desyncActive = false
				end
				task.wait(0.3)
				continue
			end

			-- Берём приоритетную цель
			local best = targets[1]
			local targetChar = best.character
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then
				task.wait(0.1)
				continue
			end

			if best.isKO then
				-- === STOMP KO ЦЕЛИ ===
				local stompPos = self:_calcStompPosition(targetChar)
				if stompPos then
					-- Запускаем/обновляем desync (обязательно)
					if not self._desyncKillEngine:IsActive() then
						self._desyncKillEngine:Start(stompPos)
						desyncActive = true
					else
						self._desyncKillEngine:SetFakePosition(stompPos)
					end

					-- Ждём фреймы
					for i = 1, self.KillSettings.StompWaitFrames do
						Services.RunService.Heartbeat:Wait()
					end

					MainEvent:FireServer("Stomp")
					task.wait(math.max(CONSTANTS.COMBAT_STOMP_DELAY * 0.6, 0.1))
				else
					Services.RunService.Heartbeat:Wait()
				end
			else
				-- === СТРЕЛЬБА ===
				local fakePos = self:_calcFakePosition(targetChar)
				if not fakePos then
					Services.RunService.Heartbeat:Wait()
					continue
				end

				-- Запускаем/обновляем desync (обязательно)
				if not self._desyncKillEngine:IsActive() then
					self._desyncKillEngine:Start(fakePos)
					desyncActive = true
				else
					self._desyncKillEngine:SetFakePosition(fakePos)
				end

				-- Оружие
				local gun = self:_ensureWeaponAndAmmo()
				if gun then
					local ammo = gun:FindFirstChild("Ammo")
					if ammo and ammo.Value > 0 then
						self:_burstFireAtTarget(targetChar, gun, fakePos, self.KillSettings.BurstCount)
					else
						self._weaponService:ForceReload(gun)
					end
				end

				Services.RunService.Heartbeat:Wait()
			end
		end

		-- Cleanup при остановке
		if self._desyncKillEngine:IsActive() then
			self._desyncKillEngine:Stop()
		end
	end)
end

function PlayerSystem:StopAutoKill()
	self.AutoKillActive = false
	if self._autoKillPlayerConn then
		self._autoKillPlayerConn:Disconnect()
		self._autoKillPlayerConn = nil
	end
	for userId in pairs(self.AutoKillTargets) do
		self.AutoKillTargets[userId] = nil
	end
	for p in pairs(self.KillActive) do self.KillActive[p] = nil end
	for p in pairs(self.KnockActive) do self.KnockActive[p] = nil end
	if self._desyncKillEngine:IsActive() then
		self._desyncKillEngine:Stop()
	end
end

function PlayerSystem:GetPlayerNames(ignoredPlayer)
	local names = {"None"}
	for _, player in ipairs(Services.Players:GetPlayers()) do
		if player ~= LocalPlayer and player ~= ignoredPlayer then
			table.insert(names, player.Name)
		end
	end
	return names
end

function PlayerSystem:RefreshDropdown(ignoredPlayer)
	if not self.Dropdown then return end
	local success, err = pcall(function()
		local newValues = self:GetPlayerNames(ignoredPlayer)
		self.Dropdown:SetData(newValues)
		local needsReset = false
		if self.SelectedPlayer then
			if self.SelectedPlayer == ignoredPlayer then
				needsReset = true
			else
				local ok, playerName = pcall(function() return self.SelectedPlayer.Name end)
				if ok and playerName then
					needsReset = Services.Players:FindFirstChild(playerName) == nil
				else
					needsReset = true
				end
			end
		end
		if needsReset then
			self.SelectedPlayer = nil
			self.Dropdown:SetValue("None")
		end
	end)
end

-- ============================================================
-- UI FACTORY
-- ============================================================

local UIFactory = {}

function UIFactory:CreateFeatureToggle(section, config)
	local slider = nil
	if config.sliderConfig then
		slider = section:AddSlider(config.sliderConfig)
		slider:SetVisible(false)
	end

	local toggle = section:AddToggle({
		Name = config.name,
		Default = config.default or false,
		Option = config.hasKeybind,
		Flag = config.flag,
		Callback = function(v)
			if v then
				if config.onEnable then config.onEnable() end
			else
				if config.onDisable then config.onDisable() end
			end
			if slider then slider:SetVisible(v) end
		end
	})

	if toggle.Option and config.hasKeybind then
		toggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = config.flag .. "Keybind",
			OnTriggered = function(active)
				toggle:SetValue(active)
			end
		})
	end

	return toggle, slider
end

-- ============================================================
-- INSTANTIATE ALL MODULES
-- ============================================================

local menuOpen = true

local pingTracker = PingTracker.new()
local velocityTracker = VelocityTracker.new()
local weaponService = WeaponService.new()
local shootingService = ShootingService.new(weaponService, velocityTracker, pingTracker)
local combatManager = CombatManager.new()
local smartTeleport = SmartTeleport.new()
desyncEngine = DesyncEngine.new()
-- отдельный инстанс для детекций, чтобы не конфликтовал с autobuy
desyncDetection = DesyncEngine.new()
local stateManager = StateManager.new()

local legitBot = LegitBot.new(weaponService, shootingService, pingTracker, velocityTracker, combatManager)
local rageBot = RageBot.new(weaponService, shootingService, pingTracker, velocityTracker, combatManager)
local manualRapidFire = ManualRapidFire.new(weaponService, rageBot)
rageBot:SetManualRapidFire(manualRapidFire)

local movement = Movement.new()
local characterModule = CharacterModule.new(movement)
local autoBuy = AutoBuy.new(weaponService)
rageBot:SetAutoBuyRef(autoBuy)

local chatSpy = ChatSpy.new()
local detections = Detections.new()
local playerSystem = PlayerSystem.new(weaponService, shootingService, combatManager, smartTeleport, characterModule)

getgenv().ModDetectionEnabled = false

stateManager:SetCallbacks({
	onEnableLegit = function()
		legitBot:SetEnabled(true)
	end,
	onDisableLegit = function()
		legitBot:SetEnabled(false)
		legitBot:StopAll()
	end,
	onEnableRage = function()
		rageBot:SetEnabled(true)
		if rageBot.Rapidfire.Enabled then
			manualRapidFire:Start()
		end
	end,
	onDisableRage = function()
		rageBot:SetEnabled(false)
		manualRapidFire:Stop()
	end,
})

pingTracker:Start()

-- ============================================================
-- FOV RENDER LOOP
-- ============================================================

Services.RunService.RenderStepped:Connect(function()
	pcall(function() legitBot:UpdateFOVCircles() end)
end)

-- ============================================================
-- THREAT DETECTION SYSTEM
-- ============================================================

local ThreatDetectionConnection = nil

local function SetupThreatDetection(char)
	if ThreatDetectionConnection then
		pcall(function() ThreatDetectionConnection:Disconnect() end)
		ThreatDetectionConnection = nil
	end

	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end

	local lastHealth = hum.Health

	ThreatDetectionConnection = hum.HealthChanged:Connect(function(newHealth)
		if newHealth >= lastHealth then
			lastHealth = newHealth
			return
		end
		lastHealth = newHealth

		local myRoot = char:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		for _, player in ipairs(Services.Players:GetPlayers()) do
			if player == LocalPlayer then continue end
			local theirChar = player.Character
			if not theirChar then continue end
			local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
			if not theirRoot then continue end

			local distance = (myRoot.Position - theirRoot.Position).Magnitude
			if distance > CONSTANTS.THREAT_NEARBY_RANGE then continue end

			if rageBot:HasGunEquipped(player) then
				if rageBot:IsAimingAtMe(player) then
					rageBot:RegisterThreat(player)
				end
			end
		end
	end)
end

-- ============================================================
-- STATE / RESETTING
-- ============================================================

local State = {
	MenuToggleKey = Enum.KeyCode.Insert,
	IsResetting = false,
}

local function OnCharacterAdded(char)
	State.IsResetting = true
	movement:CleanupAll()
	characterModule:CleanupAll()
	legitBot.Trigger:Stop()
	if legitBot.Silent.Enabled then legitBot.Silent:Stop() end
	velocityTracker:Clear()
	rageBot:CleanupAll()
	autoBuy:CleanupAll()

	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then State.IsResetting = false return end
	char:WaitForChild("HumanoidRootPart", 10)
	task.wait(0.5)
	State.IsResetting = false

	SetupThreatDetection(char)

	movement:RestartIfEnabled()
	characterModule:RestartIfEnabled()
	legitBot:RestartIfEnabled()
	rageBot:RestartIfEnabled()
	autoBuy:RestartIfEnabled()

	if rageBot.Enabled and rageBot.Rapidfire.Enabled then
		manualRapidFire:Start()
	end

	hum.Died:Connect(function()
		movement:CleanupAll()
		characterModule:CleanupAll()
		legitBot.Trigger:Stop()
		manualRapidFire:Stop()
		autoBuy:CleanupAll()
	end)
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if LocalPlayer.Character then task.spawn(function() OnCharacterAdded(LocalPlayer.Character) end) end

-- ============================================================
-- AUTO UPDATE PLAYER LIST
-- ============================================================

Services.Players.PlayerAdded:Connect(function(player)
	task.defer(function()
		task.wait(0.3)
		playerSystem:RefreshDropdown()
		if rageBot.IgnorePlayersDropdown then
			pcall(function() rageBot.IgnorePlayersDropdown:SetData(playerSystem:GetPlayerNames()) end)
		end
	end)
end)

Services.Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	if playerSystem.AutoKillTargets[userId] then
		playerSystem.AutoKillTargets[userId] = nil
	end
	playerSystem.KillActive[player] = nil
	playerSystem.KnockActive[player] = nil
	if playerSystem.SpectatingPlayer == player then
		playerSystem:StopSpectate()
	end
	rageBot.TargetSettings.IgnoredPlayers[userId] = nil
	playerSystem:RefreshDropdown(player)
	if rageBot.IgnorePlayersDropdown then
		pcall(function() rageBot.IgnorePlayersDropdown:SetData(playerSystem:GetPlayerNames()) end)
	end
end)

-- ============================================================
-- UI SETUP
-- ============================================================

local Window = Fatality.new({
	Name = "RAY",
	Keybind = Enum.KeyCode.Insert,
	Scale = UDim2.new(0, 750, 0, 500),
	Expire = "LifeTime",
	SidebarWidth = 200,
	TabHeight = 40,
	HeaderHeight = 50,
	BottomHeight = 30,
	Theme = ThemeConfig,
})

if Window and Window.Signal then
	Window.Signal.Event:Connect(function(isVisible)
		menuOpen = isVisible
	end)
	menuOpen = Window.Toggle
end

local Menus = {
	Legit = Window:AddMenu({ Name = "Legit", Icon = "lucide-mouse", AutoFill = false }),
	Rage = Window:AddMenu({ Name = "Rage", Icon = "lucide-skull", AutoFill = false }),
	Visuals = Window:AddMenu({ Name = "Visuals", Icon = "eye", AutoFill = false }),
	Misc = Window:AddMenu({ Name = "Misc", Icon = "package", AutoFill = false }),
	Players = Window:AddMenu({ Name = "Players", Icon = "users", AutoFill = false }),
	Settings = Window:AddMenu({ Name = "Settings", Icon = "settings", AutoFill = false }),
}

-- ============================================================
-- LEGIT TAB
-- ============================================================

do
	local GlobalSection = Menus.Legit:AddSection({ Name = "Global", Side = "left", ShowTitle = true, Height = 0 })

	local legitBotToggle = GlobalSection:AddToggle({
		Name = "LegitBot",
		Default = false,
		Option = true,
		Flag = "AimbotEnabled",
		Callback = function(v)
			if v then stateManager:EnableLegit() else stateManager:DisableLegit() end
		end
	})
	stateManager:SetUIToggle("Legit", legitBotToggle)
	if legitBotToggle.Option then
		legitBotToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "AimbotEnabledKeybind",
			OnTriggered = function(active)
				legitBotToggle:SetValue(active)
			end
		})
	end

	local visibleCheckToggle = GlobalSection:AddToggle({ Name = "Visible Check", Default = false, Option = true, Flag = "VisibleCheck",
		Callback = function(v) legitBot.VisibleCheck = v end })
	if visibleCheckToggle.Option then
		visibleCheckToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "VisibleCheckKeybind",
			OnTriggered = function(active)
				visibleCheckToggle:SetValue(active)
			end
		})
	end
	GlobalSection:AddDropdown({ Name = "Hitbox", Values = {"Head", "UpperTorso", "HumanoidRootPart", "Nearest"},
		Default = "Head", Flag = "Hitbox", Callback = function(v) legitBot.Hitbox = v end })

	local CamSection = Menus.Legit:AddSection({ Name = "Camera Lock", Side = "left", ShowTitle = true, Height = 0 })
	local camToggle = CamSection:AddToggle({ Name = "Enabled", Default = false, Option = true, Flag = "CameraLockEnabled",
		Callback = function(v)
			legitBot.CameraLock.Active = v
			if v then legitBot.CameraLock:Start() else legitBot.CameraLock:Stop() end
		end })
	if camToggle.Option then camToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "CameraLockKeybind", OnTriggered = function(active) camToggle:SetValue(active) end }) end
	CamSection:AddSlider({ Name = "FOV", Type = "px", Default = 100, Min = 10, Max = 500, Round = 0, Flag = "CameraLockFOV",
		Callback = function(v) legitBot.CameraLock.FOV = v end })
	CamSection:AddSlider({ Name = "Smoothness", Default = 0.1, Min = 0, Max = 0.95, Round = 2, Flag = "CameraLockSmooth",
		Callback = function(v) legitBot.CameraLock.Smoothness = v end })
	CamSection:AddSlider({ Name = "Prediction", Default = 0.5, Min = 0, Max = 0.95, Round = 2, Flag = "CameraLockPrediction",
		Callback = function(v) legitBot.CameraLock.Prediction = v end })

	local SilentSection = Menus.Legit:AddSection({ Name = "Silent", Side = "right", ShowTitle = true, Height = 0 })
	local silentToggle = SilentSection:AddToggle({ Name = "Enabled", Default = false, Option = true, Flag = "SilentEnabled",
		Callback = function(v) if v then legitBot.Silent:Start() else legitBot.Silent:Stop() end end })
	if silentToggle.Option then silentToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "SilentKeybind", OnTriggered = function(active) silentToggle:SetValue(active) end }) end
	SilentSection:AddSlider({ Name = "FOV", Type = "px", Default = 100, Min = 10, Max = 500, Round = 0, Flag = "SilentFOV",
		Callback = function(v) legitBot.Silent.FOV = v end })
	SilentSection:AddToggle({ Name = "Velocity Resolver", Default = false, Flag = "SilentResolver",
		Callback = function(v) legitBot.Silent.Resolver = v end })
	SilentSection:AddSlider({ Name = "Jump Offset", Default = 0, Min = -1, Max = 1, Round = 2, Flag = "SilentJumpOffset",
		Callback = function(v) legitBot.Silent.JumpOffset = v end })

	local autoPredDivisorSlider = SilentSection:AddSlider({ Name = "Auto Pred Divisor", Default = 250, Min = 200, Max = 350, Round = 0, Flag = "SilentAutoPredDivisor",
		Callback = function(v) legitBot.Silent.ManualDivisor = v end })

	SilentSection:AddToggle({ Name = "Auto Prediction", Default = false, Flag = "SilentAutoPrediction",
		Callback = function(v)
			legitBot.Silent.AutoPrediction = v
			autoPredDivisorSlider:SetVisible(not v)
		end })

	local TriggerSection = Menus.Legit:AddSection({ Name = "Triggerbot", Side = "right", ShowTitle = true, Height = 0 })
	local triggerToggle = TriggerSection:AddToggle({ Name = "Enabled", Default = false, Option = true, Flag = "TriggerEnabled",
		Callback = function(v)
			legitBot.Trigger.Active = v
			if v then legitBot.Trigger:Start() else legitBot.Trigger:Stop() end
		end })
	if triggerToggle.Option then triggerToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "TriggerKeybind", OnTriggered = function(active) triggerToggle:SetValue(active) end }) end
	TriggerSection:AddSlider({ Name = "Min Delay", Type = "ms", Default = 50, Min = 0, Max = 200, Round = 0, Flag = "TriggerMinDelay",
		Callback = function(v) legitBot.Trigger.MinDelay = v / 1000 end })
end

-- ============================================================
-- RAGE TAB
-- ============================================================

do
	local GlobalSection = Menus.Rage:AddSection({ Name = "Global", Side = "left", ShowTitle = true, Height = 0 })

	local rageBotToggle = GlobalSection:AddToggle({
		Name = "Ragebot",
		Default = false,
		Option = true,
		Flag = "RagebotEnabled",
		Callback = function(v)
			if v then stateManager:EnableRage() else stateManager:DisableRage() end
		end
	})
	stateManager:SetUIToggle("Rage", rageBotToggle)
	if rageBotToggle.Option then
		rageBotToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "RagebotEnabledKeybind",
			OnTriggered = function(active)
				rageBotToggle:SetValue(active)
			end
		})
	end

	GlobalSection:AddDropdown({
		Name = "Hitbox",
		Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "Nearest"},
		Default = "Head",
		Flag = "RageHitbox",
		Callback = function(v) rageBot.Hitbox = v end
	})

	local TargetSection = Menus.Rage:AddSection({ Name = "Targeting", Side = "left", ShowTitle = true, Height = 0 })

	TargetSection:AddToggle({
		Name = "Ignore Friends",
		Default = false,
		Flag = "RageIgnoreFriends",
		Callback = function(v) rageBot.TargetSettings.IgnoreFriends = v end
	})

	local ignorePlayersDropdown = TargetSection:AddDropdown({
		Name = "Ignore Players",
		Values = playerSystem:GetPlayerNames(),
		Default = {},
		Multi = true,
		Flag = "RageIgnoredPlayers",
		Callback = function(selected)
			rageBot.TargetSettings.IgnoredPlayers = {}
			if typeof(selected) == "table" then
				for playerName, isSelected in pairs(selected) do
					if isSelected then
						local player = Services.Players:FindFirstChild(playerName)
						if player then rageBot.TargetSettings.IgnoredPlayers[player.UserId] = true end
					end
				end
			end
		end
	})
	rageBot.IgnorePlayersDropdown = ignorePlayersDropdown

	TargetSection:AddButton({
		Name = "Clear Ignored",
		Callback = function()
			rageBot.TargetSettings.IgnoredPlayers = {}
			ignorePlayersDropdown:SetValue({})
		end
	})

	local PredictionSection = Menus.Rage:AddSection({ Name = "Prediction", Side = "left", ShowTitle = true, Height = 0 })

	local manualPredSlider = PredictionSection:AddSlider({
		Name = "Prediction",
		Default = 0.15,
		Min = 0,
		Max = 0.5,
		Round = 2,
		Flag = "RagePrediction",
		Callback = function(v) rageBot.Prediction = v end
	})

	PredictionSection:AddToggle({
		Name = "Auto Prediction",
		Default = false,
		Flag = "RageAutoPrediction",
		Callback = function(v)
			rageBot.AutoPrediction.Enabled = v
			manualPredSlider:SetVisible(not v)
		end
	})

	local FunctionsSection = Menus.Rage:AddSection({ Name = "Functions", Side = "right", ShowTitle = true, Height = 0 })

	local autofireToggle = FunctionsSection:AddToggle({
		Name = "Autofire",
		Default = false,
		Option = true,
		Flag = "AutofireEnabled",
		Callback = function(v)
			rageBot.Autofire.Enabled = v
			if v then
				if rageBot.Enabled then rageBot:StartAutofire() end
			else
				rageBot:StopAutofire()
			end
		end
	})
	if autofireToggle.Option then autofireToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "AutofireKeybind", OnTriggered = function(active) autofireToggle:SetValue(active) end }) end

	local autoequipToggle = FunctionsSection:AddToggle({
		Name = "Autoequip",
		Default = false,
		Option = true,
		Flag = "AutoequipEnabled",
		Callback = function(v)
			rageBot.Autoequip.Enabled = v
			if v then
				if rageBot.Enabled then rageBot:StartAutoequip() end
			else
				rageBot:StopAutoequip()
			end
		end
	})
	if autoequipToggle.Option then autoequipToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "AutoequipKeybind", OnTriggered = function(active) autoequipToggle:SetValue(active) end }) end

	local rapidfireSpeedSlider = FunctionsSection:AddSlider({
		Name = "Rapidfire Speed",
		Default = 2,
		Min = 1,
		Max = 10,
		Round = 1,
		Flag = "RapidfireSpeed",
		Callback = function(v) rageBot.Rapidfire.Speed = v end
	})
	rapidfireSpeedSlider:SetVisible(false)

	local rapidfireToggle = FunctionsSection:AddToggle({
		Name = "Rapidfire",
		Default = false,
		Option = true,
		Flag = "RapidfireEnabled",
		Callback = function(v)
			rageBot.Rapidfire.Enabled = v
			rapidfireSpeedSlider:SetVisible(v)
			if v and rageBot.Enabled then manualRapidFire:Start() else manualRapidFire:Stop() end
		end
	})
	if rapidfireToggle.Option then
		rapidfireToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "RapidfireEnabledKeybind",
			OnTriggered = function(active)
				rapidfireToggle:SetValue(active)
			end
		})
	end

	local KillauraSection = Menus.Rage:AddSection({ Name = "Killaura", Side = "right", ShowTitle = true, Height = 0 })

	local killauraRangeSlider = KillauraSection:AddSlider({
		Name = "Range", Type = "studs", Default = 15, Min = 5, Max = 50, Round = 0, Flag = "KillauraRange",
		Callback = function(v) rageBot.Killaura.Range = v end
	})
	killauraRangeSlider:SetVisible(false)

	local killauraDelaySlider = KillauraSection:AddSlider({
		Name = "Attack Delay", Type = "ms", Default = 100, Min = 30, Max = 500, Round = 0, Flag = "KillauraDelay",
		Callback = function(v) rageBot.Killaura.AttackDelay = v / 1000 end
	})
	killauraDelaySlider:SetVisible(false)

	local killauraAutoEquipToggle = KillauraSection:AddToggle({
		Name = "Auto Equip", Default = false, Flag = "KillauraAutoEquip",
		Callback = function(v) rageBot.Killaura.AutoEquip = v end
	})
	killauraAutoEquipToggle:SetVisible(false)

	local killauraToggle = KillauraSection:AddToggle({
		Name = "Enabled", Default = false, Option = true, Flag = "KillauraEnabled",
		Callback = function(v)
			rageBot.Killaura.Enabled = v
			killauraRangeSlider:SetVisible(v)
			killauraDelaySlider:SetVisible(v)
			killauraAutoEquipToggle:SetVisible(v)
			if v then
				if rageBot.Enabled then rageBot:StartKillaura() end
			else
				rageBot:StopKillaura()
			end
		end
	})
	if killauraToggle.Option then killauraToggle.Option:AddKeybind({ Name = "Keybind", Mode = "Toggle", Flag = "KillauraKeybind", OnTriggered = function(active) killauraToggle:SetValue(active) end }) end
end

-- ============================================================
-- VISUALS TAB
-- ============================================================

do
	local FOVSection = Menus.Visuals:AddSection({ Name = "FOV Circles", Side = "left", ShowTitle = true, Height = 0 })
	FOVSection:AddToggle({ Name = "Show Camera Lock FOV", Default = true, Flag = "ShowCameraLockFOV",
		Callback = function(v) legitBot.ESP.ShowCameraLockFOV = v end })
	FOVSection:AddColorPicker({ Name = "Camera Lock Color", Default = Color3.fromRGB(255, 255, 255), Flag = "CameraLockFOVColor",
		Callback = function(c) legitBot.ESP.CameraLockFOVColor = c end })
	FOVSection:AddToggle({ Name = "Show Silent FOV", Default = true, Flag = "ShowSilentFOV",
		Callback = function(v) legitBot.ESP.ShowSilentFOV = v end })
	FOVSection:AddColorPicker({ Name = "Silent Color", Default = Color3.fromRGB(0, 255, 255), Flag = "SilentFOVColor",
		Callback = function(c) legitBot.ESP.SilentFOVColor = c end })
	FOVSection:AddColorPicker({ Name = "Locked Color", Default = Color3.fromRGB(255, 70, 70), Flag = "LockedColor",
		Callback = function(c) legitBot.ESP.LockedColor = c end })
end

-- ============================================================
-- MISC TAB
-- ============================================================

do
	local MovementSection = Menus.Misc:AddSection({ Name = "Movement", Side = "left", ShowTitle = true, Height = 0 })

	UIFactory:CreateFeatureToggle(MovementSection, {
		name = "Fly", flag = "FlyEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "Fly Speed", Default = 250, Min = 1, Max = 500, Round = 0, Flag = "FlySpeed",
			Callback = function(v) movement.Fly.Speed = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.Fly.Enabled = true
			movement:StartFly()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.Fly.Enabled = false
			movement:StopFly()
		end
	})

	UIFactory:CreateFeatureToggle(MovementSection, {
		name = "Fly Car", flag = "FlyCarEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "Fly Car Speed", Default = 50, Min = 1, Max = 100, Round = 0, Flag = "FlyCarSpeed",
			Callback = function(v) movement.FlyCar.Speed = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.FlyCar.Enabled = true
			movement:StartFlyCar()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.FlyCar.Enabled = false
			movement:StopFlyCar()
		end
	})

	UIFactory:CreateFeatureToggle(MovementSection, {
		name = "CFrame Speed", flag = "CFrameSpeedEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "CFrame Speed", Default = 50, Min = 1, Max = 100, Round = 0, Flag = "CFrameSpeedValue",
			Callback = function(v) movement.CFrameSpeed.Value = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.CFrameSpeed.Enabled = true
			movement:StartCFrameSpeed()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.CFrameSpeed.Enabled = false
			movement:StopCFrameSpeed()
		end
	})

	UIFactory:CreateFeatureToggle(MovementSection, {
		name = "Bunny Hop", flag = "BunnyHopEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "Hop Speed", Default = 50, Min = 1, Max = 100, Round = 0, Flag = "BunnyHopSpeed",
			Callback = function(v) movement.BunnyHop.Speed = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.BunnyHop.Enabled = true
			movement:StartBunnyHop()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.BunnyHop.Enabled = false
			movement:StopBunnyHop()
		end
	})

	local HumanSection = Menus.Misc:AddSection({ Name = "Human", Side = "left", ShowTitle = true, Height = 0 })

	UIFactory:CreateFeatureToggle(HumanSection, {
		name = "WalkSpeed", flag = "WalkSpeedEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "Speed", Default = 16, Min = 16, Max = 200, Round = 0, Flag = "WalkSpeedValue",
			Callback = function(v) movement.WalkSpeed.Value = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.WalkSpeed.Enabled = true
			movement:StartWalkSpeed()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.WalkSpeed.Enabled = false
			movement:StopWalkSpeed()
		end
	})

	UIFactory:CreateFeatureToggle(HumanSection, {
		name = "JumpPower", flag = "JumpPowerEnabled", default = false, hasKeybind = true,
		sliderConfig = { Name = "Power", Default = 50, Min = 50, Max = 200, Round = 0, Flag = "JumpPowerValue",
			Callback = function(v) movement.JumpPower.Value = v end },
		onEnable = function()
			if State.IsResetting then return end
			movement.JumpPower.Enabled = true
			movement:StartJumpPower()
		end,
		onDisable = function()
			if State.IsResetting then return end
			movement.JumpPower.Enabled = false
			movement:StopJumpPower()
		end
	})

	local FunSection = Menus.Misc:AddSection({ Name = "Fun", Side = "left", ShowTitle = true, Height = 0 })

	local spin360Slider = FunSection:AddSlider({ Name = "Spin Speed", Default = 30, Min = 1, Max = 100, Round = 0, Flag = "Spin360Speed",
		Callback = function(v) movement.Spin360.Speed = v end })
	spin360Slider:SetVisible(false)

	local spin360Toggle = FunSection:AddToggle({ Name = "360", Default = false, Option = true, Flag = "360Spin",
		Callback = function(v)
			movement.Spin360.Enabled = v
			spin360Slider:SetVisible(v)
			if v then movement:Start360Spin() else movement:Stop360Spin() end
		end })
	if spin360Toggle.Option then
		spin360Toggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "360SpinKeybind",
			OnTriggered = function(active)
				spin360Toggle:SetValue(active)
			end
		})
	end

	local fellToggle = FunSection:AddToggle({ Name = "Fell", Default = false, Option = true, Flag = "Fell",
		Callback = function(v)
			characterModule.Fell.Enabled = v
			if v then characterModule:StartFell() else characterModule:StopFell() end
		end })
	if fellToggle.Option then
		fellToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "FellKeybind",
			OnTriggered = function(active)
				fellToggle:SetValue(active)
			end
		})
	end

	local CharSection = Menus.Misc:AddSection({ Name = "Character", Side = "right", ShowTitle = true, Height = 0 })

	local noclipToggle = CharSection:AddToggle({ Name = "Noclip", Default = false, Option = true, Flag = "NoclipEnabled",
		Callback = function(v)
			characterModule.Noclip.Enabled = v
			if v then characterModule:EnableNoclip() else characterModule:DisableNoclip() end
		end })
	if noclipToggle.Option then
		noclipToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "NoclipEnabledKeybind",
			OnTriggered = function(active)
				noclipToggle:SetValue(active)
			end
		})
	end
	local antiFlingToggle = CharSection:AddToggle({ Name = "Anti Fling", Default = false, Option = true, Flag = "AntiFlingEnabled",
		Callback = function(v)
			characterModule.AntiFling.Enabled = v
			if v then characterModule:EnableAntiFling() else characterModule:DisableAntiFling() end
		end })
	if antiFlingToggle.Option then
		antiFlingToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "AntiFlingEnabledKeybind",
			OnTriggered = function(active)
				antiFlingToggle:SetValue(active)
			end
		})
	end
	local autoReloadToggle = CharSection:AddToggle({ Name = "Auto Reload", Default = false, Option = true, Flag = "AutoReloadEnabled",
		Callback = function(v)
			characterModule.AutoReload.Enabled = v
			if v then characterModule:EnableAutoReload() else characterModule:DisableAutoReload() end
		end })
	if autoReloadToggle.Option then
		autoReloadToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "AutoReloadEnabledKeybind",
			OnTriggered = function(active)
				autoReloadToggle:SetValue(active)
			end
		})
	end
	local noSlowToggle = CharSection:AddToggle({ Name = "No Slow", Default = false, Option = true, Flag = "NoSlowEnabled",
		Callback = function(v)
			characterModule.NoSlow.Enabled = v
			if v then characterModule:EnableNoSlow() else characterModule:DisableNoSlow() end
		end })
	if noSlowToggle.Option then
		noSlowToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "NoSlowEnabledKeybind",
			OnTriggered = function(active)
				noSlowToggle:SetValue(active)
			end
		})
	end
	local noJumpCooldownToggle = CharSection:AddToggle({ Name = "No Jump Cooldown", Default = false, Option = true, Flag = "NoJumpCooldownEnabled",
		Callback = function(v)
			characterModule.NoJumpCooldown.Enabled = v
			if v then characterModule:EnableNoJumpCooldown() else characterModule:DisableNoJumpCooldown() end
		end })
	if noJumpCooldownToggle.Option then
		noJumpCooldownToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "NoJumpCooldownEnabledKeybind",
			OnTriggered = function(active)
				noJumpCooldownToggle:SetValue(active)
			end
		})
	end
	local noSeatToggle = CharSection:AddToggle({ Name = "No Seat", Default = false, Option = true, Flag = "NoSeatEnabled",
		Callback = function(v)
			characterModule.NoSeat.Enabled = v
			if v then characterModule:EnableNoSeat() else characterModule:DisableNoSeat() end
		end })
	if noSeatToggle.Option then
		noSeatToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "NoSeatEnabledKeybind",
			OnTriggered = function(active)
				noSeatToggle:SetValue(active)
			end
		})
	end
	local infiniteZoomToggle = CharSection:AddToggle({ Name = "Infinite Zoom", Default = false, Option = true, Flag = "InfiniteZoomEnabled",
		Callback = function(v)
			characterModule.InfiniteZoom.Enabled = v
			if v then characterModule:EnableInfiniteZoom() else characterModule:DisableInfiniteZoom() end
		end })
	if infiniteZoomToggle.Option then
		infiniteZoomToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "InfiniteZoomEnabledKeybind",
			OnTriggered = function(active)
				infiniteZoomToggle:SetValue(active)
			end
		})
	end
	local chatSpyToggle = CharSection:AddToggle({ Name = "Chat Spy", Default = false, Option = true, Flag = "ChatSpyEnabled",
		Callback = function(v)
			chatSpy.Enabled = v
			if v then chatSpy:Setup() else chatSpy:Cleanup() end
		end })
	if chatSpyToggle.Option then
		chatSpyToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "ChatSpyEnabledKeybind",
			OnTriggered = function(active)
				chatSpyToggle:SetValue(active)
			end
		})
	end

	local DetectionsSection = Menus.Misc:AddSection({ Name = "Detections", Side = "right", ShowTitle = true, Height = 0 })

	local rpgDetectionToggle = DetectionsSection:AddToggle({ Name = "RPG Detection", Default = false, Option = true, Flag = "RPGDetectionEnabled",
		Callback = function(v)
			detections.RPGDetection.Enabled = v
			if v or detections.GranadeDetection.Enabled then
				detections:StartThreatDetection()
			else
				detections:StopThreatDetection()
			end
		end })
	if rpgDetectionToggle.Option then
		rpgDetectionToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "RPGDetectionEnabledKeybind",
			OnTriggered = function(active)
				rpgDetectionToggle:SetValue(active)
			end
		})
	end

	local granadeDetectionToggle = DetectionsSection:AddToggle({ Name = "Granade Detection", Default = false, Option = true, Flag = "GranadeDetectionEnabled",
		Callback = function(v)
			detections.GranadeDetection.Enabled = v
			if v or detections.RPGDetection.Enabled then
				detections:StartThreatDetection()
			else
				detections:StopThreatDetection()
			end
		end })
	if granadeDetectionToggle.Option then
		granadeDetectionToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "GranadeDetectionEnabledKeybind",
			OnTriggered = function(active)
				granadeDetectionToggle:SetValue(active)
			end
		})
	end

	DetectionsSection:AddToggle({ Name = "Mod Detection", Default = false, Flag = "ModDetectionEnabled",
		Callback = function(v)
			getgenv().ModDetectionEnabled = v
			detections.ModDetection.Enabled = v
			if v then detections:StartModDetection() else detections:StopModDetection() end
		end })

	local AutoBuySection = Menus.Misc:AddSection({ Name = "AutoBuy", Side = "right", ShowTitle = true, Height = 0 })

	local autoBuyToggle = AutoBuySection:AddToggle({
		Name = "Enable AutoBuy", Default = false, Option = true, Flag = "AutoBuyEnabled",
		Callback = function(v)
			autoBuy.Enabled = v
			if v then autoBuy:StartLoop() else
				if not autoBuy.AutoAmmo then autoBuy:StopLoop() end
			end
		end
	})
	if autoBuyToggle.Option then
		autoBuyToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "AutoBuyEnabledKeybind",
			OnTriggered = function(active)
				autoBuyToggle:SetValue(active)
			end
		})
	end

	autoBuy.WeaponsDropdown = AutoBuySection:AddDropdown({
		Name = "Weapons", Values = AutoBuy.WeaponsList, Default = {}, Multi = true, Flag = "AutoBuyWeapons",
		Callback = function(selected) autoBuy.SelectedWeapons = selected or {} end
	})

	autoBuy.ArmorDropdown = AutoBuySection:AddDropdown({
		Name = "Armor", Values = AutoBuy.ArmorList, Default = {}, Multi = true, Flag = "AutoBuyArmor",
		Callback = function(selected) autoBuy.SelectedArmor = selected or {} end
	})

	autoBuy.MasksDropdown = AutoBuySection:AddDropdown({
		Name = "Masks", Values = AutoBuy.MasksList, Default = {}, Multi = true, Flag = "AutoBuyMasks",
		Callback = function(selected) autoBuy.SelectedMasks = selected or {} end
	})

	local autoBuyAmmoToggle = AutoBuySection:AddToggle({
		Name = "Auto Buy Ammo", Default = false, Option = true, Flag = "AutoBuyAmmo",
		Callback = function(v)
			autoBuy.AutoAmmo = v
			if v then autoBuy:StartLoop() else
				if not autoBuy.Enabled then autoBuy:StopLoop() end
			end
		end
	})
	if autoBuyAmmoToggle.Option then
		autoBuyAmmoToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "AutoBuyAmmoKeybind",
			OnTriggered = function(active)
				autoBuyAmmoToggle:SetValue(active)
			end
		})
	end

	AutoBuySection:AddDropdown({
		Name = "Ammo Priority",
		Values = {"Equipped First", "Selected Only", "All Weapons"},
		Default = "Equipped First",
		Flag = "AutoBuyAmmoPriority",
		Callback = function(v)
			autoBuy.AmmoPriority = v
		end
	})
end

-- ============================================================
-- PLAYERS TAB
-- ============================================================

do
	local PlayerSection = Menus.Players:AddSection({ Name = "Player List", Side = "left", ShowTitle = true, Height = 0 })

	playerSystem.Dropdown = PlayerSection:AddDropdown({
		Name = "Select Player",
		Values = playerSystem:GetPlayerNames(),
		Default = "None",
		Flag = "PlayerSelect",
		Callback = function(v)
			playerSystem.SelectedPlayer = v == "None" and nil or Services.Players:FindFirstChild(v)
		end
	})

	PlayerSection:AddButton({ Name = "Knock", Flag = "PlayerKnock",
		Callback = function() if playerSystem.SelectedPlayer then playerSystem:Knock(playerSystem.SelectedPlayer) end end })
	PlayerSection:AddButton({ Name = "Kill", Flag = "PlayerKill",
		Callback = function() if playerSystem.SelectedPlayer then playerSystem:Kill(playerSystem.SelectedPlayer) end end })
	PlayerSection:AddButton({ Name = "Stop Knock/Kill", Flag = "StopKnockKill",
		Callback = function()
			if playerSystem.SelectedPlayer then
				playerSystem.KnockActive[playerSystem.SelectedPlayer] = nil
				playerSystem.KillActive[playerSystem.SelectedPlayer] = nil
			end
		end })
	PlayerSection:AddButton({ Name = "Fling", Flag = "PlayerFling",
		Callback = function() if playerSystem.SelectedPlayer then playerSystem:Fling(playerSystem.SelectedPlayer) end end })
	PlayerSection:AddButton({ Name = "Teleport", Flag = "PlayerTeleport",
		Callback = function() if playerSystem.SelectedPlayer then playerSystem:Teleport(playerSystem.SelectedPlayer) end end })
	PlayerSection:AddButton({ Name = "Spectate", Flag = "PlayerSpectate",
		Callback = function() if playerSystem.SelectedPlayer then playerSystem:Spectate(playerSystem.SelectedPlayer) end end })
	PlayerSection:AddButton({ Name = "Stop Spectate", Flag = "StopSpectate",
		Callback = function() playerSystem:StopSpectate() end })

	local SettingsSection = Menus.Players:AddSection({ Name = "Kill/Knock Settings", Side = "right", ShowTitle = true, Height = 0 })

	local hiddenBulletsToggle = SettingsSection:AddToggle({
		Name = "Hidden Bullets", Default = false, Option = true, Flag = "HiddenBullets",
		Callback = function(v) playerSystem.SilentShot.HiddenBullets = v end
	})
	if hiddenBulletsToggle.Option then
		hiddenBulletsToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "HiddenBulletsKeybind",
			OnTriggered = function(active)
				hiddenBulletsToggle:SetValue(active)
			end
		})
	end

	local spectateTargetToggle = SettingsSection:AddToggle({
		Name = "Spectate Target", Default = false, Option = true, Flag = "SpectateTarget",
		Callback = function(v) playerSystem.SilentShot.SpectateTarget = v end
	})
	if spectateTargetToggle.Option then
		spectateTargetToggle.Option:AddKeybind({
			Name = "Keybind",
			Mode = "Toggle",
			Flag = "SpectateTargetKeybind",
			OnTriggered = function(active)
				spectateTargetToggle:SetValue(active)
			end
		})
	end

	-- Десинк теперь всегда включен для Kill/Knock/AutoKill (убраны настройки UseDesync и FallbackToTeleport)

	SettingsSection:AddSlider({
		Name = "Burst Count", Default = 3, Min = 1, Max = 10, Round = 0, Flag = "KillBurstCount",
		Callback = function(v) playerSystem.KillSettings.BurstCount = v end
	})

	SettingsSection:AddSlider({
		Name = "Stomp Wait Frames", Default = 2, Min = 1, Max = 8, Round = 0, Flag = "KillStompFrames",
		Callback = function(v) playerSystem.KillSettings.StompWaitFrames = v end
	})

	local AutoSection = Menus.Players:AddSection({ Name = "Auto Kill", Side = "right", ShowTitle = true, Height = 0 })

	AutoSection:AddButton({ Name = "Add to Auto Kill", Flag = "AddAutoKill",
		Callback = function()
			if playerSystem.SelectedPlayer then
				if playerSystem:AddAutoKillTarget(playerSystem.SelectedPlayer) then
					playerSystem:StartAutoKill()
				end
			end
		end })
	AutoSection:AddButton({ Name = "Remove from Auto Kill", Flag = "RemoveAutoKill",
		Callback = function()
			if playerSystem.SelectedPlayer then
				playerSystem:RemoveAutoKillTarget(playerSystem.SelectedPlayer)
			end
		end })
	AutoSection:AddToggle({ Name = "Auto Kill All", Default = false, Flag = "AutoKillAll",
		Callback = function(v)
			if v then
				for _, p in ipairs(Services.Players:GetPlayers()) do
					if p ~= LocalPlayer then
						playerSystem:AddAutoKillTarget(p)
					end
				end
				-- Авто-добавление новых игроков
				playerSystem._autoKillPlayerConn = Services.Players.PlayerAdded:Connect(function(player)
					if player ~= LocalPlayer then
						task.wait(2) -- Ждём спавн
						playerSystem:AddAutoKillTarget(player)
					end
				end)
				playerSystem:StartAutoKill()
			else
				playerSystem:StopAutoKill()
			end
		end })
end

-- ============================================================
-- SETTINGS TAB
-- ============================================================

do
	local UI = Menus.Settings:AddSection({ Name = "UI", Side = "left", ShowTitle = true, Height = 0 })

	UI:AddKeybind({
		Name = "Toggle Menu",
		Default = Enum.KeyCode.Insert,
		Mode = "Toggle",
		HideMode = true,
		Option = false,
		Flag = "ToggleMenu",
		Callback = function(key)
			if typeof(key) == "EnumItem" then
				State.MenuToggleKey = key
				Window:SetToggleKeybind(key)
			elseif typeof(key) == "string" then
				if key == "None" then return end
				pcall(function()
					State.MenuToggleKey = Enum.KeyCode[key]
					Window:SetToggleKeybind(Enum.KeyCode[key])
				end)
			end
		end
	})


	UI:AddColorPicker({ Name = "Background", Default = ThemeConfig.Background,
		Callback = function(c) Window:SetTheme({ Background = c, Panel = c }) end, Flag = "MainColor" })

	UI:AddColorPicker({ Name = "Accent", Default = ThemeConfig.Accent,
		Callback = function(c) Window:SetTheme({ Accent = c, SliderAccent = c, ToggleAccent = c, TabSelected = c, ProfileStroke = c }) end, Flag = "AccentColor" })

	UI:AddColorPicker({ Name = "Text", Default = ThemeConfig.Text,
		Callback = function(c) Window:SetTheme({ Text = c }) end, Flag = "TextColor" })

	UI:AddColorPicker({ Name = "Slider", Default = ThemeConfig.SliderAccent,
		Callback = function(c) Window:SetTheme({ SliderAccent = c }) end, Flag = "SliderColor" })

	UI:AddColorPicker({ Name = "Toggle", Default = ThemeConfig.ToggleAccent,
		Callback = function(c) Window:SetTheme({ ToggleAccent = c }) end, Flag = "ToggleColor" })

	UI:AddColorPicker({ Name = "Tab Selected", Default = ThemeConfig.TabSelected,
		Callback = function(c) Window:SetTheme({ TabSelected = c }) end, Flag = "TabSelectedColor" })

	UI:AddColorPicker({ Name = "Tab Unselected", Default = ThemeConfig.TabUnselected,
		Callback = function(c) Window:SetTheme({ TabUnselected = c }) end, Flag = "TabUnselectedColor" })

	UI:AddColorPicker({ Name = "Header", Default = ThemeConfig.Header,
		Callback = function(c) Window:SetTheme({ Header = c }) end, Flag = "HeaderColor" })

	UI:AddColorPicker({ Name = "Panel", Default = ThemeConfig.Panel,
		Callback = function(c) Window:SetTheme({ Panel = c }) end, Flag = "PanelColor" })

	UI:AddColorPicker({ Name = "Field", Default = ThemeConfig.Field,
		Callback = function(c) Window:SetTheme({ Field = c }) end, Flag = "FieldColor" })

	UI:AddColorPicker({ Name = "Stroke", Default = ThemeConfig.Stroke,
		Callback = function(c) Window:SetTheme({ Stroke = c }) end, Flag = "StrokeColor" })

	UI:AddColorPicker({ Name = "Text Dim", Default = ThemeConfig.TextDim,
		Callback = function(c) Window:SetTheme({ TextDim = c }) end, Flag = "TextDimColor" })

	UI:AddColorPicker({ Name = "Warning", Default = ThemeConfig.Warning,
		Callback = function(c) Window:SetTheme({ Warning = c }) end, Flag = "WarningColor" })

	UI:AddColorPicker({ Name = "Shadow", Default = ThemeConfig.Shadow,
		Callback = function(c) Window:SetTheme({ Shadow = c }) end, Flag = "ShadowColor" })

	UI:AddColorPicker({ Name = "Profile Stroke", Default = ThemeConfig.ProfileStroke,
		Callback = function(c) Window:SetTheme({ ProfileStroke = c }) end, Flag = "ProfileStrokeColor" })

	UI:AddColorPicker({ Name = "Logo Text", Default = ThemeConfig.LogoText,
		Callback = function(c) Window:SetTheme({ LogoText = c }) end, Flag = "LogoTextColor" })

	UI:AddColorPicker({ Name = "Logo Stroke", Default = ThemeConfig.LogoStroke,
		Callback = function(c) ThemeConfig.LogoStroke = c; Window:SetTheme({ LogoStroke = c }) end, Flag = "LogoStrokeColor" })

	UI:AddColorPicker({ Name = "Username Text", Default = ThemeConfig.UsernameText,
		Callback = function(c) ThemeConfig.UsernameText = c; Window:SetTheme({ UsernameText = c }) end, Flag = "UsernameTextColor" })

	UI:AddColorPicker({ Name = "Expire Label", Default = ThemeConfig.ExpireLabel,
		Callback = function(c) ThemeConfig.ExpireLabel = c; Window:SetTheme({ ExpireLabel = c }) end, Flag = "ExpireLabelColor" })

	UI:AddColorPicker({ Name = "Expire Text (LifeTime)", Default = ThemeConfig.ExpireText,
		Callback = function(c) ThemeConfig.ExpireText = c; Window:SetTheme({ ExpireText = c }) end, Flag = "ExpireTextColor" })

	UI:AddColorPicker({ Name = "Dropdown Selected", Default = ThemeConfig.DropdownSelected,
		Callback = function(c) ThemeConfig.DropdownSelected = c; Window:SetTheme({ DropdownSelected = c }) end, Flag = "DropdownSelectedColor" })
end
