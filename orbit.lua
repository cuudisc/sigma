-- 🍌 ORBIT + SPEED + FLY + WHITE ESP + DYNAMIC STATUS COLOR (Full Code)
-- E: Orbit | C: Speed | T: Fly | X: White ESP

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

local isOrbiting = false
local targetPlayer = nil
local orbitSpeed = 100
local orbitRadius = 4
local angle = 0
local renderConnection = nil
local isSpeedEnabled = false
local customWalkSpeed = 16
local isFlyEnabled = false
local flySpeed = 50
local isEspEnabled = false

local espFolder = Instance.new("Folder")
espFolder.Name = "BananaWhite_ESP"
espFolder.Parent = playerGui
local espObjects = {}

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

local function clearESP(p)
    local data = espObjects[p]
    if data then
        pcall(function() if data.hl and data.hl.Parent then data.hl:Destroy() end end)
        pcall(function() if data.bb and data.bb.Parent then data.bb:Destroy() end end)
        espObjects[p] = nil
    end
end

local function clearAllESP()
    for p in pairs(espObjects) do clearESP(p) end
end

local function setupESP(p)
    if p == localPlayer then return end
    local char = p.Character
    if not char then return end

    local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 3)
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
    if not head and not hrp then return end
    local attach = head or hrp

    clearESP(p)

    local hl = Instance.new("Highlight")
    hl.Name = "BananaHL"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.75
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = isEspEnabled
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "BananaName"
    bb.Adornee = attach
    bb.Size = UDim2.new(0, 180, 0, 44)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 500
    bb.Enabled = isEspEnabled
    bb.Parent = espFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = p.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = bb

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 18)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "DISTANCE:0M"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 12
    distLabel.Parent = bb

    espObjects[p] = { hl = hl, bb = bb, nameLabel = nameLabel, distLabel = distLabel, char = char }
end

local function updateESP()
    if not isEspEnabled then return end
    local myChar = localPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local data = espObjects[p]
                if not data or data.char ~= char or not data.hl or not data.hl.Parent or not data.bb or not data.bb.Parent then
                    setupESP(p)
                    data = espObjects[p]
                end
                if data then
                    if data.nameLabel then 
                        data.nameLabel.Text = p.DisplayName 
                        data.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                    if data.distLabel then
                        data.distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        if myPos then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                data.distLabel.Text = "DISTANCE:" .. math.floor((hrp.Position - myPos).Magnitude) .. "M"
                            end
                        end
                    end
                    if data.hl then 
                        data.hl.Enabled = true
                        data.hl.FillColor = Color3.fromRGB(255, 255, 255)
                        data.hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    if data.bb then data.bb.Enabled = true end
                end
            else
                clearESP(p)
            end
        end
    end
end

local function hookPlayer(p)
    if p == localPlayer then return end
    p.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if hrp and head and isEspEnabled then
            task.wait(0.3)
            setupESP(p)
        end
    end)
    if p.Character and isEspEnabled then
        setupESP(p)
    end
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(p) clearESP(p) end)

-- GUI Setup
if playerGui:FindFirstChild("BananaOrbitGui") then
    playerGui.BananaOrbitGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BananaOrbitGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "       E:Orbit | C:Speed | T:Fly | X:ESP"
title.TextSize = 11
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local titleImage = Instance.new("ImageButton")
titleImage.Size = UDim2.new(0, 28, 0, 28)
titleImage.Position = UDim2.new(0, 6, 0.5, -14)
titleImage.BackgroundTransparency = 1
titleImage.Image = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"
titleImage.Parent = title
Instance.new("UICorner", titleImage).CornerRadius = UDim.new(1, 0)

local bananaBtn = Instance.new("ImageButton")
bananaBtn.Size = UDim2.new(0, 45, 0, 45)
bananaBtn.Position = UDim2.new(0, 15, 0.5, -22)
bananaBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
bananaBtn.Image = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"
bananaBtn.Parent = screenGui
Instance.new("UICorner", bananaBtn).CornerRadius = UDim.new(1, 0)

local bananaStroke = Instance.new("UIStroke")
bananaStroke.Color = Color3.fromRGB(255, 255, 255)
bananaStroke.Thickness = 2
bananaStroke.Parent = bananaBtn

bananaBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

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
targetText.TextColor3 = Color3.fromRGB(255, 75, 75) -- Mặc định chưa orbit là màu đỏ
targetText.Text = "Orbit Target: Chưa có"
targetText.TextSize = 12
targetText.Font = Enum.Font.SourceSans
targetText.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0.9, 0, 0, 36)
statusText.Position = UDim2.new(0.05, 0, 0, 68)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(200, 200, 210)
statusText.Text = "Speed: OFF | Fly: OFF | White ESP: OFF"
statusText.TextSize = 12
statusText.Font = Enum.Font.SourceSansBold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = mainFrame

local function refreshStatus()
    statusText.Text = string.format(
        "Speed(C): %s | Fly(T): %s | White ESP(X): %s",
        isSpeedEnabled and "ON" or "OFF",
        isFlyEnabled and "ON" or "OFF",
        isEspEnabled and "ON" or "OFF"
    )
end

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

    local sliderBgStroke = Instance.new("UIStroke")
    sliderBgStroke.Color = Color3.fromRGB(255, 255, 255)
    sliderBgStroke.Thickness = 1
    sliderBgStroke.Parent = sliderBg

    local sliderFill = Instance.new("Frame")
    local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
createSlider(165, "Orbit Speed", 1, 800, orbitSpeed, function(val) orbitSpeed = val end)
createSlider(215, "Orbit Radius", 2, 50, orbitRadius, function(val) orbitRadius = val end)
createSlider(265, "Fly Speed", 10, 600, flySpeed, function(val) flySpeed = val end)

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

local espTick = 0
RunService.RenderStepped:Connect(function(dt)
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if isSpeedEnabled and hum then
        hum.WalkSpeed = customWalkSpeed
    end

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

    espTick += dt
    if isEspEnabled and espTick >= 0.05 then
        espTick = 0
        updateESP()
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
        targetText.TextColor3 = Color3.fromRGB(255, 75, 75)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        isOrbiting = not isOrbiting
        if isOrbiting then
            targetPlayer = getClosestPlayer()
            if targetPlayer then
                targetText.Text = "Orbit: " .. targetPlayer.DisplayName
                targetText.TextColor3 = Color3.fromRGB(75, 255, 75) -- Đang orbit -> Xanh lá
                startOrbit()
            else
                targetText.Text = "Orbit: Không tìm thấy!"
                targetText.TextColor3 = Color3.fromRGB(255, 75, 75) -- Không tìm thấy -> Đỏ
                isOrbiting = false
            end
        else
            targetText.Text = "Orbit Target: Tắt"
            targetText.TextColor3 = Color3.fromRGB(255, 75, 75) -- Tắt -> Đỏ
            stopOrbit()
        end

    elseif input.KeyCode == Enum.KeyCode.C then
        isSpeedEnabled = not isSpeedEnabled
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = isSpeedEnabled and customWalkSpeed or 16 end
        refreshStatus()

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

    elseif input.KeyCode == Enum.KeyCode.X then
        isEspEnabled = not isEspEnabled
        if isEspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character then setupESP(p) end
            end
        else
            clearAllESP()
        end
        refreshStatus()
    end
end)

refreshStatus()
print("✅ Status Color Updated Successfully!")
