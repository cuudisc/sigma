-- 🍌 ORBIT + SPEED + FLY + XBOX LOCK
-- E: Orbit | C: WalkSpeed | T: Fly | V: Xbox Lock | (đổi target orbit: giữ E tắt/bật lại)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = Workspace.CurrentCamera
end)

-- Orbit & WalkSpeed
local isOrbiting = false
local targetPlayer = nil
local orbitSpeed = 100
local orbitRadius = 4
local angle = 0
local renderConnection = nil
local isSpeedEnabled = false
local customWalkSpeed = 16

-- Fly
local isFlyEnabled = false
local flySpeed = 50

-- Xbox Lock
local isLockEnabled = false
local lockTarget = nil
local fovRadius = 150

local function getClosestPlayer()
	local myChar = localPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = myChar.HumanoidRootPart.Position
	local closestPlayer, shortestDistance = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closestPlayer = p
				end
			end
		end
	end
	return closestPlayer
end

local function getPart(p)
	local char = p and p.Character
	if not char then return nil end
	return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function isValidTarget(p)
	if not p or p == localPlayer then return false end
	local char = p.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and getPart(p) ~= nil
end

-- Sticky FOV lock: FOV chỉ lúc chọn, sau đó giữ đến chết
local function getLockTarget()
	if not camera then return nil end
	if lockTarget and isValidTarget(lockTarget) then
		return lockTarget
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestDist = nil, fovRadius
	for _, p in pairs(Players:GetPlayers()) do
		if isValidTarget(p) then
			local part = getPart(p)
			if part then
				local pos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen and pos.Z > 0 then
					local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if d < bestDist then
						bestDist = d
						best = p
					end
				end
			end
		end
	end
	return best
end

-- GUI
if playerGui:FindFirstChild("BananaOrbitGui") then
	playerGui.BananaOrbitGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BananaOrbitGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 420)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🍌 E:Orbit | C:Speed | T:Fly | V:Lock"
title.TextSize = 11
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local bananaBtn = Instance.new("TextButton")
bananaBtn.Size = UDim2.new(0, 45, 0, 45)
bananaBtn.Position = UDim2.new(0, 15, 0.5, -22)
bananaBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
bananaBtn.Text = "🍌"
bananaBtn.TextSize = 25
bananaBtn.Parent = screenGui
Instance.new("UICorner", bananaBtn).CornerRadius = UDim.new(1, 0)
local bananaStroke = Instance.new("UIStroke")
bananaStroke.Color = Color3.fromRGB(255, 220, 0)
bananaStroke.Thickness = 2
bananaStroke.Parent = bananaBtn
bananaBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Drag menu
local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local targetText = Instance.new("TextLabel")
targetText.Size = UDim2.new(0.9, 0, 0, 20)
targetText.Position = UDim2.new(0.05, 0, 0, 48)
targetText.BackgroundTransparency = 1
targetText.TextColor3 = Color3.fromRGB(255, 220, 100)
targetText.Text = "Orbit Target: Chưa có"
targetText.TextSize = 12
targetText.Font = Enum.Font.SourceSans
targetText.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0.9, 0, 0, 40)
statusText.Position = UDim2.new(0.05, 0, 0, 68)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(200, 200, 210)
statusText.Text = "Speed: OFF | Fly: OFF | Lock: OFF"
statusText.TextSize = 12
statusText.Font = Enum.Font.SourceSansBold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.TextYAlignment = Enum.TextYAlignment.Top
statusText.Parent = mainFrame

local function refreshStatus()
	statusText.Text = string.format(
		"Speed(C): %s | Fly(T): %s\nLock(V): %s",
		isSpeedEnabled and "ON" or "OFF",
		isFlyEnabled and "ON" or "OFF",
		isLockEnabled and "ON" or "OFF"
	)
end

-- FOV circle
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 220, 0)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.3
fovStroke.Parent = fovCircle

local function createSlider(posY, labelText, minVal, maxVal, defaultVal, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.9, 0, 0, 16)
	label.Position = UDim2.new(0.05, 0, 0, posY)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = labelText .. ": " .. defaultVal
	label.TextSize = 12
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = mainFrame

	local sliderBg = Instance.new("Frame")
	sliderBg.Size = UDim2.new(0.9, 0, 0, 8)
	sliderBg.Position = UDim2.new(0.05, 0, 0, posY + 20)
	sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = mainFrame
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

	local sliderFill = Instance.new("Frame")
	local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	sliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBg
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(0, 14, 0, 14)
	sliderBtn.Position = UDim2.new(initPercent, -7, 0.5, -7)
	sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderBtn.Text = ""
	sliderBtn.Parent = sliderBg
	Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

	local isSliderDragging = false
	local function update(input)
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / math.max(sliderBg.AbsoluteSize.X, 1), 0, 1)
		sliderFill.Size = UDim2.new(pos, 0, 1, 0)
		sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
		local val = math.floor(minVal + (maxVal - minVal) * pos)
		label.Text = labelText .. ": " .. val
		callback(val)
	end

	sliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliderDragging = true
		end
	end)
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			update(input)
			isSliderDragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliderDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isSliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

createSlider(115, "WalkSpeed", 1, 1000, customWalkSpeed, function(val)
	customWalkSpeed = val
	if isSpeedEnabled then
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end
end)

createSlider(165, "Orbit Speed", 1, 1000, orbitSpeed, function(val)
	orbitSpeed = val
end)

createSlider(215, "Orbit Radius", 2, 50, orbitRadius, function(val)
	orbitRadius = val
end)

createSlider(265, "Fly Speed", 10, 500, flySpeed, function(val)
	flySpeed = val
end)

createSlider(315, "Lock FOV", 20, 400, fovRadius, function(val)
	fovRadius = val
	fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end)

-- Orbit
local function stopOrbit()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	if camera then
		camera.CameraType = Enum.CameraType.Custom
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then camera.CameraSubject = hum end
	end
end

local function startOrbit()
	stopOrbit()
	renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
		if not isOrbiting or not targetPlayer or not targetPlayer.Character then
			stopOrbit()
			return
		end
		local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		local myChar = localPlayer.Character
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not targetHRP or not myHRP then return end
		if targetHum and camera then camera.CameraSubject = targetHum end
		angle = angle + (orbitSpeed * deltaTime)
		local offsetX = math.cos(angle) * orbitRadius
		local offsetZ = math.sin(angle) * orbitRadius
		local targetPos = targetHRP.Position
		local newPos = Vector3.new(targetPos.X + offsetX, targetPos.Y, targetPos.Z + offsetZ)
		myHRP.CFrame = CFrame.new(newPos, targetPos)
	end)
end

-- Main loop: speed + fly + xbox lock
RunService.RenderStepped:Connect(function(dt)
	local char = localPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if isSpeedEnabled and hum then
		hum.WalkSpeed = customWalkSpeed
	end

	-- Fly
	if isFlyEnabled and hrp and camera then
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
		if move.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + move.Unit * flySpeed * dt
		end
		hrp.AssemblyLinearVelocity = Vector3.zero
	end

	-- Xbox Lock (sticky hard)
	if isLockEnabled and camera then
		local t = getLockTarget()
		lockTarget = t
		if t then
			local part = getPart(t)
			if part then
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, part.Position)
			end
		end
	end
end)

localPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = isSpeedEnabled and customWalkSpeed or 16
	end
	if isOrbiting then
		isOrbiting = false
		stopOrbit()
		targetText.Text = "Orbit Target: Tắt (respawn)"
	end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- E: Orbit
	if input.KeyCode == Enum.KeyCode.E then
		isOrbiting = not isOrbiting
		if isOrbiting then
			targetPlayer = getClosestPlayer()
			if targetPlayer then
				targetText.Text = "Orbit: " .. targetPlayer.DisplayName
				startOrbit()
			else
				targetText.Text = "Orbit: Không tìm thấy!"
				isOrbiting = false
			end
		else
			targetText.Text = "Orbit Target: Tắt"
			stopOrbit()
		end

	-- C: WalkSpeed
	elseif input.KeyCode == Enum.KeyCode.C then
		isSpeedEnabled = not isSpeedEnabled
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = isSpeedEnabled and customWalkSpeed or 16 end
		refreshStatus()

	-- T: Fly
	elseif input.KeyCode == Enum.KeyCode.T then
		isFlyEnabled = not isFlyEnabled
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			if isFlyEnabled then
				hum:ChangeState(Enum.HumanoidStateType.Swimming)
			else
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
		refreshStatus()

	-- V: Xbox Lock
	elseif input.KeyCode == Enum.KeyCode.V then
		isLockEnabled = not isLockEnabled
		if isLockEnabled then
			lockTarget = getLockTarget()
			fovCircle.Visible = true
		else
			lockTarget = nil
			fovCircle.Visible = false
		end
		refreshStatus()
	end
end)

refreshStatus()
print("✅ Banana | E Orbit | C Speed | T Fly | V Lock")
