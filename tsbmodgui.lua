local Config = {
	SmoothMap = true,
	RemoveTextures = true,
	KeepClearVision = true,
	NoShadows = true,
	DisableVFX = true,
	CustomGarouStream = true, -- Bật/tắt đổi màu vệt Garou
	StreamColor = Color3.fromRGB(0, 0, 0), -- Đổi màu RGB ở đây (VD: Tím)
	StreamNeon = false, -- true = vệt phát sáng nhẹ, false = màu lì mịn FPS
	CleanHighlights = true,
	LowRender = true,
	FpsCap = 144,
	BatchLimitPerFrame = 250
}

--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

--// DYNAMIC COLOR CONSTANTS (Tự động tính từ Config.StreamColor)
local STREAM_COLOR = Config.StreamColor
local STREAM_SEQ = ColorSequence.new(STREAM_COLOR)
local STREAM_VERTEX = Vector3.new(STREAM_COLOR.R, STREAM_COLOR.G, STREAM_COLOR.B)
local STREAM_EMISSION = Config.StreamNeon and 0.6 or 0

local GAROU_KEYWORDS = {
	"garou", "flowing", "whirlwind", "lethal",
	"hunter", "prey", "stream", "crushing",
	"slash", "fist", "m1", "punch", "swing"
}

local VFX_DISABLE_CLASSES = {
	ParticleEmitter = true,
	Trail = true,
	Beam = true,
	Smoke = true,
	Fire = true,
	Sparkles = true
}

local LIGHT_CLASSES = {
	PointLight = true,
	SpotLight = true,
	SurfaceLight = true
}

--// CACHES
local Processed = setmetatable({}, { __mode = "k" })
local SkillCache = setmetatable({}, { __mode = "k" })

local MapFolder = Workspace:FindFirstChild("Map")
local ThrownFolder = Workspace:FindFirstChild("Thrown")

local function getMapFolder()
	if not MapFolder or not MapFolder.Parent then
		MapFolder = Workspace:FindFirstChild("Map")
	end
	return MapFolder
end

local function getThrownFolder()
	if not ThrownFolder or not ThrownFolder.Parent then
		ThrownFolder = Workspace:FindFirstChild("Thrown")
	end
	return ThrownFolder
end

--// HELPERS
local function isCharacterObject(obj)
	local char = LocalPlayer and LocalPlayer.Character
	return char ~= nil and obj:IsDescendantOf(char)
end

local function hasGarouKeyword(nameLower)
	for i = 1, #GAROU_KEYWORDS do
		if string.find(nameLower, GAROU_KEYWORDS[i], 1, true) then
			return true
		end
	end
	return false
end

local function isGarouSkill(obj)
	local thrown = getThrownFolder()
	if not thrown or not obj:IsDescendantOf(thrown) then
		return false
	end

	local map = getMapFolder()
	if map and obj:IsDescendantOf(map) then
		return false
	end

	local root = obj
	while root.Parent and root.Parent ~= thrown do
		root = root.Parent
	end

	if root.Parent ~= thrown then
		return false
	end

	local cached = SkillCache[root]
	if cached ~= nil then
		return cached
	end

	local current = obj
	for _ = 1, 5 do
		if not current or current == thrown then
			break
		end

		if hasGarouKeyword(string.lower(current.Name)) then
			SkillCache[root] = true
			return true
		end

		current = current.Parent
	end

	return false
end

--// CUSTOM STREAM COLORING
local function tintCharacterTrail(obj)
	if obj:IsA("Trail") or obj:IsA("Beam") then
		obj.Color = STREAM_SEQ
		obj.Texture = ""
		obj.LightEmission = STREAM_EMISSION
		obj.LightInfluence = 0
	end
end

local function applyCustomStream(obj)
	if obj:IsA("BasePart") then
		obj.Material = Config.StreamNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic
		obj.Color = STREAM_COLOR
		obj.Reflectance = 0
		obj.CastShadow = false

		if obj:IsA("MeshPart") then
			obj.TextureID = ""
		end
	elseif obj:IsA("SpecialMesh") then
		obj.TextureId = ""
		obj.VertexColor = STREAM_VERTEX
	elseif obj:IsA("SurfaceAppearance") then
		obj:Destroy()
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Texture = ""
	elseif obj:IsA("Trail") or obj:IsA("Beam") then
		obj.Enabled = true
		obj.Color = STREAM_SEQ
		obj.Texture = ""
		obj.LightEmission = STREAM_EMISSION
		obj.LightInfluence = 0
	elseif obj:IsA("ParticleEmitter") or LIGHT_CLASSES[obj.ClassName] then
		obj.Enabled = false
	end
end

--// OBJECT OPTIMIZER
local function optimizeObject(obj, runtime)
	if not obj or Processed[obj] then
		return
	end
	Processed[obj] = true

	local className = obj.ClassName

	-- 1. Trail trên nhân vật
	if Config.CustomGarouStream and (className == "Trail" or className == "Beam") and isCharacterObject(obj) then
		tintCharacterTrail(obj)
		return
	end

	-- 2. Skill Garou (giữ lại và tô màu custom trước khi tắt VFX)
	if Config.CustomGarouStream and runtime and isGarouSkill(obj) then
		applyCustomStream(obj)
		return
	end

	-- 3. Part & Texture
	if obj:IsA("BasePart") then
		if Config.SmoothMap then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end
		if Config.NoShadows then
			obj.CastShadow = false
		end
		if Config.RemoveTextures and className == "MeshPart" then
			obj.TextureID = ""
		end
	elseif Config.RemoveTextures then
		if className == "Decal" or className == "Texture" then
			obj.Texture = ""
		elseif className == "SurfaceAppearance" then
			obj:Destroy()
			return
		end
	end

	-- 4. VFX
	if Config.DisableVFX then
		if VFX_DISABLE_CLASSES[className] then
			obj.Enabled = false
		elseif className == "Explosion" then
			obj.Visible = false
		end
	end

	-- 5. Đèn
	if Config.NoShadows and LIGHT_CLASSES[className] then
		obj.Enabled = false
	end

	-- 6. Highlight
	if Config.CleanHighlights and className == "Highlight" then
		obj.Enabled = false
	end
end

--// LIGHTING OPTIMIZATION
if Config.NoShadows then
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.EnvironmentSpecularScale = 0
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.ShadowSoftness = 0
	end)
end

if Config.KeepClearVision then
	for _, obj in ipairs(Lighting:GetChildren()) do
		if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
			obj:Destroy()
		end
	end

	pcall(function()
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
		Lighting.Brightness = 1.25
		Lighting.Ambient = Color3.fromRGB(125, 125, 125)
		Lighting.OutdoorAmbient = Color3.fromRGB(145, 145, 145)
	end)
end

--// TERRAIN OPTIMIZATION
if Terrain then
	pcall(function()
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
		Terrain.Decoration = false
	end)
end

--// INITIAL SCAN
for _, obj in ipairs(Workspace:GetDescendants()) do
	optimizeObject(obj, false)
end

--// BATCHED RUNTIME PROCESSING
local Queue = {}
local Queued = setmetatable({}, { __mode = "k" })
local IsRunning = false

local function processQueue()
	if IsRunning then
		return
	end
	IsRunning = true

	task.defer(function()
		while #Queue > 0 do
			local count = 0
			while #Queue > 0 and count < Config.BatchLimitPerFrame do
				local obj = table.remove(Queue, 1)
				Queued[obj] = nil
				count += 1

				if obj and obj.Parent then
					optimizeObject(obj, true)
				end
			end

			if #Queue > 0 then
				task.wait()
			end
		end

		IsRunning = false
	end)
end

Workspace.DescendantAdded:Connect(function(obj)
	if not obj or Processed[obj] or Queued[obj] then
		return
	end

	Queued[obj] = true
	Queue[#Queue + 1] = obj
	processQueue()
end)

--// CHARACTER RESPAWN
if LocalPlayer then
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.delay(0.5, function()
			if not LocalPlayer or LocalPlayer.Character ~= char or not char.Parent then
				return
			end

			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("Trail") or obj:IsA("Beam") then
					tintCharacterTrail(obj)
				end
			end
		end)
	end)
end

--// LOW RENDER
if Config.LowRender then
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)

	if type(setfpscap) == "function" and Config.FpsCap and Config.FpsCap > 0 then
		pcall(function()
			setfpscap(Config.FpsCap)
		end)
	end
end

print("[Optimized Anti-Lag + Custom Garou Stream] Loaded!")
