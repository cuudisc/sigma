local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local rng = Random.new()

local R15Config = {
	Enabled = false,
	ToggleKey = Enum.KeyCode.Q,
	HighlightKey = Enum.KeyCode.X,
	MenuKey = Enum.KeyCode.RightShift,
	ShowFOV = true,
	MaxTracers = 10,
	FOVRadius = 300,
	HeadChance = 100,
	HeadLift = 0.22,
	PullStrength = 0.42,
	Prediction = 0.015,
	Deadzone = 1.5,
	LockUntilDead = true,
	VisibleCheck = true,
	TeamCheck = true,
	IgnoreFriends = false,
	BodyParts = { "UpperTorso", "HumanoidRootPart", "LowerTorso" },

	-- Fly + Noclip (mặc định 300, max 800, bước +-100, bind trực tiếp trên menu)
	FlyEnabled = false,
	FlySpeed = 300,
	FlyMaxSpeed = 800,
	FlyStep = 100,
	FlyKey = nil,

	-- ESP Highlight + Tracer (bật/tắt chung bằng phím X)
	ShowHighlight = true,
	HighlightFill = Color3.fromRGB(255, 85, 120),
	HighlightOutline = Color3.fromRGB(255, 255, 255),
	HighlightInterval = 0.2
}

local lockedBodyMode = {}
local friendCache = {}
local ignoredPlayers = {}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isFriend(plr)
	if not R15Config.IgnoreFriends then return false end
	if friendCache[plr] == nil then
		local ok, res = pcall(function()
			return LocalPlayer:IsFriendsWith(plr.UserId)
		end)
		friendCache[plr] = (ok and res == true)
	end
	return friendCache[plr] == true
end

local function isTeammate(plr)
	if not plr or plr == LocalPlayer then return true end
	if ignoredPlayers[plr.UserId] then return true end
	if isFriend(plr) then return true end

	if R15Config.TeamCheck then
		if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then
			return true
		end
		if LocalPlayer.TeamColor and plr.TeamColor
			and LocalPlayer.TeamColor ~= BrickColor.White()
			and plr.TeamColor == LocalPlayer.TeamColor then
			return true
		end
	end

	return false
end

local function pickBodyPartForPlayer(plr, char)
	if not char then return nil end
	local head = char:FindFirstChild("Head")

	if R15Config.HeadChance >= 100 then
		return (head and head:IsA("BasePart")) and head or nil
	end

	if R15Config.HeadChance <= 0 then
		for _, partName in ipairs(R15Config.BodyParts) do
			local p = char:FindFirstChild(partName)
			if p and p:IsA("BasePart") then
				return p
			end
		end
		return char:FindFirstChildWhichIsA("BasePart")
	end

	if lockedBodyMode[plr] == nil then
		lockedBodyMode[plr] = (rng:NextNumber(0, 100) < R15Config.HeadChance)
	end

	if lockedBodyMode[plr] and head and head:IsA("BasePart") then
		return head
	end

	for _, partName in ipairs(R15Config.BodyParts) do
		local p = char:FindFirstChild(partName)
		if p and p:IsA("BasePart") then
			return p
		end
	end

	return (head and head:IsA("BasePart")) and head or char:FindFirstChildWhichIsA("BasePart")
end

local function getAimWorldPosition(part)
	local pos = part.Position
	if R15Config.HeadChance >= 100 and part.Name == "Head" then
		pos = pos + Vector3.new(0, R15Config.HeadLift, 0)
	end
	return pos + (part.AssemblyLinearVelocity * R15Config.Prediction)
end

-- ================= LOGIC FLY + NOCLIP GỘP CHUNG =================
local flyConn = nil
local noclipConn = nil
local noclipModifiedParts = {}
local flyBtnRef = nil

local function enableNoclip()
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
	table.clear(noclipModifiedParts)

	noclipConn = RunService.Stepped:Connect(function()
		if not R15Config.FlyEnabled then return end
		local char = LocalPlayer.Character
		if not char then return end

		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				noclipModifiedParts[v] = true
				v.CanCollide = false
			end
		end
	end)
end

local function disableNoclip()
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end

	for part in pairs(noclipModifiedParts) do
		if part and part.Parent then
			part.CanCollide = true
		end
	end
	table.clear(noclipModifiedParts)
end

local function syncFlyBtn()
	if not flyBtnRef then return end
	if R15Config.FlyEnabled then
		flyBtnRef.Text = "Fly + Noclip: BẬT"
		flyBtnRef.TextColor3 = Color3.fromRGB(95, 245, 150)
	else
		flyBtnRef.Text = "Fly + Noclip: TẮT"
		flyBtnRef.TextColor3 = Color3.fromRGB(255, 110, 130)
	end
end

local function applyFlyPhysics()
	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then return end
	local hum = character:FindFirstChildOfClass("Humanoid")

	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end
	if hrp:FindFirstChild("CustomFlyAttachment") then hrp.CustomFlyAttachment:Destroy() end
	if hrp:FindFirstChild("CustomFlyAlign") then hrp.CustomFlyAlign:Destroy() end
	if hrp:FindFirstChild("CustomFlyVelocity") then hrp.CustomFlyVelocity:Destroy() end

	syncFlyBtn()
	enableNoclip()

	local att = Instance.new("Attachment", hrp)
	att.Name = "CustomFlyAttachment"

	local align = Instance.new("AlignOrientation", hrp)
	align.Name = "CustomFlyAlign"
	align.Attachment0 = att
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.CFrame = Camera.CFrame
	align.MaxTorque = 9e9
	align.Responsiveness = 200

	local lv = Instance.new("LinearVelocity", hrp)
	lv.Name = "CustomFlyVelocity"
	lv.Attachment0 = att
	lv.VectorVelocity = Vector3.zero
	lv.MaxForce = 9e9
	lv.RelativeTo = Enum.ActuatorRelativeTo.World

	if hum then hum.PlatformStand = true end

	flyConn = RunService.RenderStepped:Connect(function()
		if not R15Config.FlyEnabled or not hrp.Parent then return end
		local moveDir = Vector3.zero
		local cf = Camera.CFrame

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

		lv.VectorVelocity = (moveDir.Magnitude > 0 and moveDir.Unit or Vector3.zero) * R15Config.FlySpeed
		align.CFrame = cf
	end)
end

local function removeFlyPhysics()
	syncFlyBtn()
	disableNoclip()

	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		if hrp:FindFirstChild("CustomFlyAttachment") then hrp.CustomFlyAttachment:Destroy() end
		if hrp:FindFirstChild("CustomFlyAlign") then hrp.CustomFlyAlign:Destroy() end
		if hrp:FindFirstChild("CustomFlyVelocity") then hrp.CustomFlyVelocity:Destroy() end
	end
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

local function toggleFly()
	R15Config.FlyEnabled = not R15Config.FlyEnabled
	if R15Config.FlyEnabled then
		applyFlyPhysics()
	else
		removeFlyPhysics()
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if R15Config.FlyEnabled then
		task.wait(0.1)
		if R15Config.FlyEnabled then
			applyFlyPhysics()
		end
	end
end)

-- ================= DRAWING FOV & TRACER MÀU TRẮNG (DÍNH ĐẦU, MỎNG 1PX) =================
local fovCircle
local tracerPool = {}

if Drawing and Drawing.new then
	fovCircle = Drawing.new("Circle")
	fovCircle.Thickness = 1.6
	fovCircle.NumSides = 40
	fovCircle.Filled = false
	fovCircle.Transparency = 0.85
	fovCircle.Color = Color3.fromRGB(255, 85, 120)

	for i = 1, R15Config.MaxTracers do
		local line = Drawing.new("Line")
		line.Thickness = 1
		line.Transparency = 0.9
		line.Color = Color3.fromRGB(255, 255, 255)
		line.Visible = false
		tracerPool[i] = line
	end
end

local function hideAllTracers()
	for i = 1, #tracerPool do
		tracerPool[i].Visible = false
	end
end

local function getTracerScreenPoint(worldPos, center, viewport)
	local screenPos = Camera:WorldToViewportPoint(worldPos)
	local pt = Vector2.new(screenPos.X, screenPos.Y)

	if screenPos.Z < 0 then
		pt = Vector2.new(viewport.X - pt.X, viewport.Y - pt.Y)
	end

	local dir = pt - center
	if dir.Magnitude < 1e-3 then
		return center
	end

	local pad = 12
	local maxX = math.max(pad + 1, viewport.X - pad)
	local maxY = math.max(pad + 1, viewport.Y - pad)

	if pt.X < pad or pt.X > maxX or pt.Y < pad or pt.Y > maxY then
		local tx = dir.X > 0 and ((maxX - center.X) / dir.X) or (dir.X < 0 and ((pad - center.X) / dir.X) or math.huge)
		local ty = dir.Y > 0 and ((maxY - center.Y) / dir.Y) or (dir.Y < 0 and ((pad - center.Y) / dir.Y) or math.huge)
		local t = math.max(0, math.min(tx, ty))
		if t < math.huge then
			pt = center + (dir * t)
		end
	end

	return Vector2.new(math.clamp(pt.X, pad, maxX), math.clamp(pt.Y, pad, maxY))
end

local function updateESPTracers(center, viewport)
	if #tracerPool == 0 then return end
	if not R15Config.ShowHighlight then
		hideAllTracers()
		return
	end

	local idx = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if idx >= R15Config.MaxTracers then break end
		if isTeammate(plr) then continue end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not hum or hum.Health <= 0 then continue end

		local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
		if not head or not head:IsA("BasePart") then continue end

		idx += 1
		local line = tracerPool[idx]
		line.From = center
		line.To = getTracerScreenPoint(head.Position, center, viewport)
		line.Visible = true
	end

	for i = idx + 1, #tracerPool do
		tracerPool[i].Visible = false
	end
end

-- ================= ESP HIGHLIGHT =================
local highlights = {}

local function getOrCreateHighlight(plr)
	if highlights[plr] then return highlights[plr] end
	local hl = Instance.new("Highlight")
	hl.Name = "R15_ESP_Highlight"
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillColor = R15Config.HighlightFill
	hl.OutlineColor = R15Config.HighlightOutline
	hl.FillTransparency = 0.65
	hl.OutlineTransparency = 0.1
	hl.Enabled = false
	pcall(function() hl.Parent = CoreGui end)
	if not hl.Parent then
		hl.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	highlights[plr] = hl
	return hl
end

local function clearAllHighlights()
	for _, hl in pairs(highlights) do
		if hl then
			hl.Enabled = false
			hl.Adornee = nil
		end
	end
end

local function removeHighlight(plr)
	local hl = highlights[plr]
	if hl then
		pcall(function() hl:Destroy() end)
		highlights[plr] = nil
	end
end

local function updateHighlights()
	if not R15Config.ShowHighlight then
		clearAllHighlights()
		hideAllTracers()
		return
	end

	for plr, hl in pairs(highlights) do
		if not plr.Parent or isTeammate(plr) then
			hl.Enabled = false
			hl.Adornee = nil
			continue
		end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if char and hum and hum.Health > 0 then
			if hl.Adornee ~= char then
				hl.Adornee = char
			end
			hl.Enabled = true
		else
			hl.Enabled = false
			hl.Adornee = nil
		end
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		getOrCreateHighlight(p)
	end
end
Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		getOrCreateHighlight(p)
	end
end)
Players.PlayerRemoving:Connect(function(p)
	lockedBodyMode[p] = nil
	friendCache[p] = nil
	removeHighlight(p)
end)

-- ================= MENU OKAY-NNO_OBVN =================
local function buildMenu()
	local old = CoreGui:FindFirstChild("OKAY_NNO_OBVN_Menu")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "OKAY_NNO_OBVN_Menu"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local main = Instance.new("Frame")
	main.Name = "MainFrame"
	main.Size = UDim2.fromOffset(300, 455)
	main.Position = UDim2.new(1, -320, 0.5, -227)
	main.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.Visible = true
	main.Parent = gui

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(55, 60, 82)
	stroke.Thickness = 1

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 26)
	title.Position = UDim2.fromOffset(10, 6)
	title.BackgroundTransparency = 1
	title.Text = "OKAY-NNO_OBVN"
	title.TextColor3 = Color3.fromRGB(240, 242, 255)
	title.TextSize = 15
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main

	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, -16, 0, 16)
	hint.Position = UDim2.fromOffset(10, 28)
	hint.BackgroundTransparency = 1
	hint.Text = "Nhấn RightShift để đóng menu"
	hint.TextColor3 = Color3.fromRGB(145, 152, 178)
	hint.TextSize = 11
	hint.Font = Enum.Font.Gotham
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.Parent = main

	local aimBtn = Instance.new("TextButton")
	aimBtn.Size = UDim2.new(0.47, 0, 0, 28)
	aimBtn.Position = UDim2.fromOffset(10, 52)
	aimBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 56)
	aimBtn.Text = "Aim [Q]: TẮT"
	aimBtn.TextColor3 = Color3.fromRGB(255, 110, 130)
	aimBtn.TextSize = 12
	aimBtn.Font = Enum.Font.GothamBold
	aimBtn.Parent = main
	Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0, 6)

	local hlBtn = Instance.new("TextButton")
	hlBtn.Size = UDim2.new(0.47, 0, 0, 28)
	hlBtn.Position = UDim2.new(0.51, 0, 0, 52)
	hlBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 56)
	hlBtn.Text = R15Config.ShowHighlight and "Highlight [X]: BẬT" or "Highlight [X]: TẮT"
	hlBtn.TextColor3 = R15Config.ShowHighlight and Color3.fromRGB(95, 245, 150) or Color3.fromRGB(255, 110, 130)
	hlBtn.TextSize = 12
	hlBtn.Font = Enum.Font.GothamBold
	hlBtn.Parent = main
	Instance.new("UICorner", hlBtn).CornerRadius = UDim.new(0, 6)

	local waitingFlyBind = false

	local flyBtn = Instance.new("TextButton")
	flyBtn.Size = UDim2.new(0.58, 0, 0, 28)
	flyBtn.Position = UDim2.fromOffset(10, 86)
	flyBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 56)
	flyBtn.Text = "Fly + Noclip: TẮT"
	flyBtn.TextColor3 = Color3.fromRGB(255, 110, 130)
	flyBtn.TextSize = 12
	flyBtn.Font = Enum.Font.GothamBold
	flyBtn.Parent = main
	Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 6)
	flyBtnRef = flyBtn

	local flyBindBtn = Instance.new("TextButton")
	flyBindBtn.Size = UDim2.new(0.36, 0, 0, 28)
	flyBindBtn.Position = UDim2.new(0.61, 0, 0, 86)
	flyBindBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	flyBindBtn.Text = "Bind: None"
	flyBindBtn.TextColor3 = Color3.fromRGB(215, 220, 240)
	flyBindBtn.TextSize = 11
	flyBindBtn.Font = Enum.Font.GothamBold
	flyBindBtn.Parent = main
	Instance.new("UICorner", flyBindBtn).CornerRadius = UDim.new(0, 6)

	local flySpeedLbl = Instance.new("TextLabel")
	flySpeedLbl.Size = UDim2.new(0.54, 0, 0, 28)
	flySpeedLbl.Position = UDim2.fromOffset(10, 120)
	flySpeedLbl.BackgroundTransparency = 1
	flySpeedLbl.Text = "Fly Speed: " .. R15Config.FlySpeed .. "/" .. R15Config.FlyMaxSpeed
	flySpeedLbl.TextColor3 = Color3.fromRGB(185, 165, 255)
	flySpeedLbl.TextSize = 12
	flySpeedLbl.Font = Enum.Font.GothamBold
	flySpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
	flySpeedLbl.Parent = main

	local flyMinus = Instance.new("TextButton")
	flyMinus.Size = UDim2.new(0.18, 0, 0, 28)
	flyMinus.Position = UDim2.new(0.58, 0, 0, 120)
	flyMinus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	flyMinus.Text = "-100"
	flyMinus.TextColor3 = Color3.fromRGB(255, 130, 140)
	flyMinus.TextSize = 12
	flyMinus.Font = Enum.Font.GothamBold
	flyMinus.Parent = main
	Instance.new("UICorner", flyMinus).CornerRadius = UDim.new(0, 6)

	local flyPlus = Instance.new("TextButton")
	flyPlus.Size = UDim2.new(0.18, 0, 0, 28)
	flyPlus.Position = UDim2.new(0.79, 0, 0, 120)
	flyPlus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	flyPlus.Text = "+100"
	flyPlus.TextColor3 = Color3.fromRGB(110, 245, 160)
	flyPlus.TextSize = 12
	flyPlus.Font = Enum.Font.GothamBold
	flyPlus.Parent = main
	Instance.new("UICorner", flyPlus).CornerRadius = UDim.new(0, 6)

	local function syncFlyBindBtn()
		if waitingFlyBind then
			flyBindBtn.Text = "Nhấn phím..."
			flyBindBtn.TextColor3 = Color3.fromRGB(255, 215, 100)
		elseif R15Config.FlyKey then
			flyBindBtn.Text = "Key: " .. R15Config.FlyKey.Name
			flyBindBtn.TextColor3 = Color3.fromRGB(120, 230, 255)
		else
			flyBindBtn.Text = "Bind: None"
			flyBindBtn.TextColor3 = Color3.fromRGB(215, 220, 240)
		end
	end

	flyBtn.MouseButton1Click:Connect(toggleFly)

	flyBindBtn.MouseButton1Click:Connect(function()
		waitingFlyBind = not waitingFlyBind
		syncFlyBindBtn()
	end)

	flyMinus.MouseButton1Click:Connect(function()
		R15Config.FlySpeed = math.clamp(R15Config.FlySpeed - R15Config.FlyStep, 100, R15Config.FlyMaxSpeed)
		flySpeedLbl.Text = "Fly Speed: " .. R15Config.FlySpeed .. "/" .. R15Config.FlyMaxSpeed
	end)

	flyPlus.MouseButton1Click:Connect(function()
		R15Config.FlySpeed = math.clamp(R15Config.FlySpeed + R15Config.FlyStep, 100, R15Config.FlyMaxSpeed)
		flySpeedLbl.Text = "Fly Speed: " .. R15Config.FlySpeed .. "/" .. R15Config.FlyMaxSpeed
	end)

	local fovLbl = Instance.new("TextLabel")
	fovLbl.Size = UDim2.new(0.54, 0, 0, 28)
	fovLbl.Position = UDim2.fromOffset(10, 154)
	fovLbl.BackgroundTransparency = 1
	fovLbl.Text = "Vòng FOV: " .. R15Config.FOVRadius
	fovLbl.TextColor3 = Color3.fromRGB(120, 230, 255)
	fovLbl.TextSize = 12
	fovLbl.Font = Enum.Font.GothamBold
	fovLbl.TextXAlignment = Enum.TextXAlignment.Left
	fovLbl.Parent = main

	local fovMinus = Instance.new("TextButton")
	fovMinus.Size = UDim2.new(0.18, 0, 0, 28)
	fovMinus.Position = UDim2.new(0.58, 0, 0, 154)
	fovMinus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	fovMinus.Text = "-100"
	fovMinus.TextColor3 = Color3.fromRGB(255, 130, 140)
	fovMinus.TextSize = 12
	fovMinus.Font = Enum.Font.GothamBold
	fovMinus.Parent = main
	Instance.new("UICorner", fovMinus).CornerRadius = UDim.new(0, 6)

	local fovPlus = Instance.new("TextButton")
	fovPlus.Size = UDim2.new(0.18, 0, 0, 28)
	fovPlus.Position = UDim2.new(0.79, 0, 0, 154)
	fovPlus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	fovPlus.Text = "+100"
	fovPlus.TextColor3 = Color3.fromRGB(110, 245, 160)
	fovPlus.TextSize = 12
	fovPlus.Font = Enum.Font.GothamBold
	fovPlus.Parent = main
	Instance.new("UICorner", fovPlus).CornerRadius = UDim.new(0, 6)

	fovMinus.MouseButton1Click:Connect(function()
		R15Config.FOVRadius = math.clamp(R15Config.FOVRadius - 100, 50, 1200)
		fovLbl.Text = "Vòng FOV: " .. R15Config.FOVRadius
	end)

	fovPlus.MouseButton1Click:Connect(function()
		R15Config.FOVRadius = math.clamp(R15Config.FOVRadius + 100, 50, 1200)
		fovLbl.Text = "Vòng FOV: " .. R15Config.FOVRadius
	end)

	local headLbl = Instance.new("TextLabel")
	headLbl.Size = UDim2.new(0.56, 0, 0, 28)
	headLbl.Position = UDim2.fromOffset(10, 188)
	headLbl.BackgroundTransparency = 1
	headLbl.Text = "Đầu: " .. R15Config.HeadChance .. "% | Thân: " .. (100 - R15Config.HeadChance) .. "%"
	headLbl.TextColor3 = Color3.fromRGB(215, 220, 240)
	headLbl.TextSize = 12
	headLbl.Font = Enum.Font.GothamBold
	headLbl.TextXAlignment = Enum.TextXAlignment.Left
	headLbl.Parent = main

	local headMinus = Instance.new("TextButton")
	headMinus.Size = UDim2.new(0.18, 0, 0, 28)
	headMinus.Position = UDim2.new(0.58, 0, 0, 188)
	headMinus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	headMinus.Text = "-10%"
	headMinus.TextColor3 = Color3.fromRGB(255, 195, 95)
	headMinus.TextSize = 12
	headMinus.Font = Enum.Font.GothamBold
	headMinus.Parent = main
	Instance.new("UICorner", headMinus).CornerRadius = UDim.new(0, 6)

	local headPlus = Instance.new("TextButton")
	headPlus.Size = UDim2.new(0.18, 0, 0, 28)
	headPlus.Position = UDim2.new(0.79, 0, 0, 188)
	headPlus.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	headPlus.Text = "+10%"
	headPlus.TextColor3 = Color3.fromRGB(95, 245, 150)
	headPlus.TextSize = 12
	headPlus.Font = Enum.Font.GothamBold
	headPlus.Parent = main
	Instance.new("UICorner", headPlus).CornerRadius = UDim.new(0, 6)

	local function updateHeadChance(delta)
		R15Config.HeadChance = math.clamp(R15Config.HeadChance + delta, 0, 100)
		headLbl.Text = "Đầu: " .. R15Config.HeadChance .. "% | Thân: " .. (100 - R15Config.HeadChance) .. "%"
		table.clear(lockedBodyMode)
	end

	headMinus.MouseButton1Click:Connect(function()
		updateHeadChance(-10)
	end)

	headPlus.MouseButton1Click:Connect(function()
		updateHeadChance(10)
	end)

	local listHeader = Instance.new("TextLabel")
	listHeader.Size = UDim2.new(0.62, 0, 0, 24)
	listHeader.Position = UDim2.fromOffset(10, 224)
	listHeader.BackgroundTransparency = 1
	listHeader.Text = "Bỏ qua player (chọn = không aim):"
	listHeader.TextColor3 = Color3.fromRGB(205, 210, 232)
	listHeader.TextSize = 11
	listHeader.Font = Enum.Font.GothamBold
	listHeader.TextXAlignment = Enum.TextXAlignment.Left
	listHeader.Parent = main

	local scanBtn = Instance.new("TextButton")
	scanBtn.Size = UDim2.new(0.28, 0, 0, 24)
	scanBtn.Position = UDim2.new(0.69, 0, 0, 224)
	scanBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 190)
	scanBtn.Text = "Quét (1 lần)"
	scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	scanBtn.TextSize = 11
	scanBtn.Font = Enum.Font.GothamBold
	scanBtn.Parent = main
	Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 0, 192)
	scroll.Position = UDim2.fromOffset(10, 252)
	scroll.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.Parent = main
	Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function scanPlayersOnce()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local yTotal = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local row = Instance.new("TextButton")
				row.Size = UDim2.new(1, -8, 0, 26)
				row.BackgroundColor3 = ignoredPlayers[plr.UserId] and Color3.fromRGB(115, 35, 45) or Color3.fromRGB(32, 36, 50)
				row.Text = (ignoredPlayers[plr.UserId] and "[BỎ QUA] " or "[MỤC TIÊU] ") .. plr.DisplayName .. " (@" .. plr.Name .. ")"
				row.TextColor3 = ignoredPlayers[plr.UserId] and Color3.fromRGB(255, 165, 175) or Color3.fromRGB(230, 235, 250)
				row.TextSize = 11
				row.Font = Enum.Font.Gotham
				row.TextTruncate = Enum.TextTruncate.AtEnd
				row.Parent = scroll
				Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

				row.MouseButton1Click:Connect(function()
					ignoredPlayers[plr.UserId] = not ignoredPlayers[plr.UserId]
					local skip = ignoredPlayers[plr.UserId]
					row.BackgroundColor3 = skip and Color3.fromRGB(115, 35, 45) or Color3.fromRGB(32, 36, 50)
					row.Text = (skip and "[BỎ QUA] " or "[MỤC TIÊU] ") .. plr.DisplayName .. " (@" .. plr.Name .. ")"
					row.TextColor3 = skip and Color3.fromRGB(255, 165, 175) or Color3.fromRGB(230, 235, 250)
				end)

				yTotal += 30
			end
		end

		scroll.CanvasSize = UDim2.fromOffset(0, math.max(0, yTotal))
	end

	scanBtn.MouseButton1Click:Connect(scanPlayersOnce)
	scanPlayersOnce()

	local function syncAimBtn()
		if R15Config.Enabled then
			aimBtn.Text = "Aim [Q]: BẬT"
			aimBtn.TextColor3 = Color3.fromRGB(95, 245, 150)
		else
			aimBtn.Text = "Aim [Q]: TẮT"
			aimBtn.TextColor3 = Color3.fromRGB(255, 110, 130)
		end
	end

	local function syncHlBtn()
		if R15Config.ShowHighlight then
			hlBtn.Text = "Highlight [X]: BẬT"
			hlBtn.TextColor3 = Color3.fromRGB(95, 245, 150)
		else
			hlBtn.Text = "Highlight [X]: TẮT"
			hlBtn.TextColor3 = Color3.fromRGB(255, 110, 130)
		end
	end

	aimBtn.MouseButton1Click:Connect(function()
		R15Config.Enabled = not R15Config.Enabled
		syncAimBtn()
	end)

	hlBtn.MouseButton1Click:Connect(function()
		R15Config.ShowHighlight = not R15Config.ShowHighlight
		syncHlBtn()
		updateHighlights()
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if waitingFlyBind then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					R15Config.FlyKey = nil
				else
					R15Config.FlyKey = input.KeyCode
				end
				waitingFlyBind = false
				syncFlyBindBtn()
			end
			return
		end

		if gp then return end
		if input.KeyCode == R15Config.MenuKey then
			main.Visible = not main.Visible
		elseif input.KeyCode == R15Config.ToggleKey then
			R15Config.Enabled = not R15Config.Enabled
			syncAimBtn()
		elseif input.KeyCode == R15Config.HighlightKey then
			R15Config.ShowHighlight = not R15Config.ShowHighlight
			syncHlBtn()
			updateHighlights()
		elseif R15Config.FlyKey and input.KeyCode == R15Config.FlyKey then
			toggleFly()
		end
	end)
end

-- ================= LOGIC AIM R15 =================
local function isVisible(char, aimPos)
	if not R15Config.VisibleCheck then return true end
	local origin = Camera.CFrame.Position
	rayParams.FilterDescendantsInstances = { LocalPlayer.Character, char, Camera }
	local result = Workspace:Raycast(origin, aimPos - origin, rayParams)
	return not result or result.Instance:IsDescendantOf(char)
end

local function getLockedTargetPoint(plr, center)
	if not plr or not plr.Parent or isTeammate(plr) then
		return nil, true
	end

	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not hum or hum.Health <= 0 then
		lockedBodyMode[plr] = nil
		return nil, true
	end

	local part = pickBodyPartForPlayer(plr, char)
	if not part then
		return nil, true
	end

	local aimPos = getAimWorldPosition(part)
	local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
	if not onScreen or screenPos.Z <= 0 then
		return nil, true
	end

	local pt = Vector2.new(screenPos.X, screenPos.Y)
	if (pt - center).Magnitude > R15Config.FOVRadius * 1.15 then
		return nil, true
	end

	if R15Config.VisibleCheck and not isVisible(char, aimPos) then
		return nil, true
	end

	return pt, false
end

local function findNewTargetInFOV(center)
	local bestPlr = nil
	local bestPt = nil
	local bestDist = math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if isTeammate(plr) then continue end
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not hum or hum.Health <= 0 then
			lockedBodyMode[plr] = nil
			continue
		end

		local part = pickBodyPartForPlayer(plr, char)
		if not part then continue end

		local aimPos = getAimWorldPosition(part)
		local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
		if not onScreen or screenPos.Z <= 0 then continue end

		local pt = Vector2.new(screenPos.X, screenPos.Y)
		local dist = (pt - center).Magnitude
		if dist <= R15Config.FOVRadius and dist < bestDist then
			if not R15Config.VisibleCheck or isVisible(char, aimPos) then
				bestDist = dist
				bestPlr = plr
				bestPt = pt
			end
		end
	end

	return bestPlr, bestPt
end

local function applyR15Pull(targetPt, center)
	local delta = targetPt - center
	local dist = delta.Magnitude
	if dist <= R15Config.Deadzone then return end

	local baseStrength = math.clamp(R15Config.PullStrength, 0.05, 0.98)
	local nearFactor = math.clamp(dist / 38, 0.72, 1)
	local strength = baseStrength * nearFactor
	local step = delta * strength

	if typeof(mousemoverel) == "function" then
		pcall(mousemoverel, step.X, step.Y)
		return
	end

	local ray = Camera:ViewportPointToRay(center.X + step.X, center.Y + step.Y)
	local camPos = Camera.CFrame.Position
	local desiredCF = CFrame.lookAt(camPos, camPos + ray.Direction)
	Camera.CFrame = Camera.CFrame:Lerp(desiredCF, math.clamp(strength * 0.72, 0.14, 0.9))
end

buildMenu()
updateHighlights()

local hlAccum = 0
local lockedTargetPlr = nil

RunService.RenderStepped:Connect(function(dt)
	local frameDt = dt or (1 / 60)
	local viewport = Camera.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local activeColor = R15Config.Enabled and Color3.fromRGB(70, 240, 130) or Color3.fromRGB(255, 85, 120)

	if fovCircle then
		fovCircle.Visible = R15Config.ShowFOV
		fovCircle.Radius = R15Config.FOVRadius
		fovCircle.Position = center
		fovCircle.Color = activeColor
	end

	hlAccum += frameDt
	if hlAccum >= R15Config.HighlightInterval then
		updateHighlights()
		hlAccum = 0
	end

	local targetPt = nil

	if R15Config.Enabled then
		local shouldDropLock = false
		if lockedTargetPlr then
			targetPt, shouldDropLock = getLockedTargetPoint(lockedTargetPlr, center)
			if shouldDropLock then
				lockedTargetPlr = nil
			end
		end

		if not lockedTargetPlr then
			local newPlr, newPt = findNewTargetInFOV(center)
			if newPlr then
				lockedTargetPlr = newPlr
				targetPt = newPt
			end
		end

		if targetPt then
			applyR15Pull(targetPt, center)
		end
	else
		lockedTargetPlr = nil
	end

	updateESPTracers(center, viewport)
end)
