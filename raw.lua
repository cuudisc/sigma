-- ============================================
-- ANTI-CHEAT BYPASS & UI PROTECTION
-- ============================================
local function generateRandomName()
    local str = ""
    for i = 1, math.random(10, 20) do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = generateRandomName()
screenGui.ResetOnSpawn = false
local parentSuccess = pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
end)
if not parentSuccess or not screenGui.Parent then
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
-- ============================================
-- KEYBIND & ASSET CONFIG
-- ============================================
local LOCK_KEY = Enum.KeyCode.E
local NOCLIP_KEY = Enum.KeyCode.C
local ESP_KEY = Enum.KeyCode.X
local AUTOCLICK_KEY = Enum.KeyCode.Minus
local AVATAR_IMAGE_ID = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"
-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = Workspace.CurrentCamera
end)
local fovRadius = 50
local followDistance = 3
local currentTarget, isLocked, espActive, speedActive, jumpActive, infJumpActive, noclipActive, flyActive, fullbrightActive, fixLagActive, autoClickActive, invisActive, hitboxActive = nil, false, false, false, false, false, false, false, false, false, false, false, false
local godmodeActive = false
local spinbotActive = false          -- << SPINBOT
local spinSpeed = 25                 -- << Tốc độ xoay
local followTargetPlayer = nil
local speedValue, jumpValue, flyValue = 16, 25, 50
local maxZoomValue, fovValue = 128, 70
local hitboxSize = 15
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origGlobalShadows = Lighting.GlobalShadows
local origFogEnd = Lighting.FogEnd
local originalTransparencies = {}
local toggleUpdateFuncs = {}
local disabledEffects = {}
local hiddenAccessories = {}
-- Smooth Dragging
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Name = generateRandomName()
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle
-- Floating Button
local toggleMenuBtn = Instance.new("ImageButton")
toggleMenuBtn.Name = generateRandomName()
toggleMenuBtn.Size = UDim2.new(0, 55, 0, 55)
toggleMenuBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
toggleMenuBtn.Image = AVATAR_IMAGE_ID
toggleMenuBtn.ScaleType = Enum.ScaleType.Crop
toggleMenuBtn.Active = true
toggleMenuBtn.Parent = screenGui
makeDraggable(toggleMenuBtn)
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleMenuBtn
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 2.5
toggleStroke.Parent = toggleMenuBtn
-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = generateRandomName()
mainFrame.Size = UDim2.new(0, 560, 0, 320)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
makeDraggable(mainFrame)
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Parent = mainFrame
local bgImage = Instance.new("ImageLabel")
bgImage.Name = generateRandomName()
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = AVATAR_IMAGE_ID
bgImage.ImageTransparency = 0.88
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1
bgImage.Parent = mainFrame
-- Header
local header = Instance.new("Frame")
header.Name = generateRandomName()
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1
header.ZIndex = 2
header.Parent = mainFrame
local avatarHeader = Instance.new("ImageLabel")
avatarHeader.Name = generateRandomName()
avatarHeader.Size = UDim2.new(0, 34, 0, 34)
avatarHeader.Position = UDim2.new(0, 12, 0, 8)
avatarHeader.Image = AVATAR_IMAGE_ID
avatarHeader.BackgroundTransparency = 1
avatarHeader.ZIndex = 2
avatarHeader.Parent = header
local avatarHeaderCorner = Instance.new("UICorner")
avatarHeaderCorner.CornerRadius = UDim.new(1, 0)
avatarHeaderCorner.Parent = avatarHeader
local avatarHeaderStroke = Instance.new("UIStroke")
avatarHeaderStroke.Color = Color3.fromRGB(255, 255, 255)
avatarHeaderStroke.Thickness = 1.5
avatarHeaderStroke.Parent = avatarHeader
local titleText = Instance.new("TextLabel")
titleText.Name = generateRandomName()
titleText.Size = UDim2.new(0, 200, 0, 34)
titleText.Position = UDim2.new(0, 54, 0, 8)
titleText.Text = "NNO_OBVN HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.ZIndex = 2
titleText.Parent = header
local closeBtn = Instance.new("TextButton")
closeBtn.Name = generateRandomName()
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 2
closeBtn.Parent = header
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
toggleMenuBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
-- Sidebar & Tabs System
local sidebar = Instance.new("Frame")
sidebar.Name = generateRandomName()
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = mainFrame
local tabContainer = Instance.new("Frame")
tabContainer.Name = generateRandomName()
tabContainer.Size = UDim2.new(1, -130, 1, -50)
tabContainer.Position = UDim2.new(0, 130, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 2
tabContainer.Parent = mainFrame
local tabs, tabButtons = {}, {}
local function createTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = generateRandomName()
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    page.Visible = false
    page.ZIndex = 3
    page.Parent = tabContainer
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    tabs[name] = page
    local btn = Instance.new("TextButton")
    btn.Name = generateRandomName()
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, (#tabButtons * 36) + 6)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(150, 150, 170)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    btn.BackgroundTransparency = 0.5
    btn.ZIndex = 3
    btn.Parent = sidebar
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        for tabName, tabObj in pairs(tabs) do tabObj.Visible = (tabName == name) end
        for _, b in ipairs(tabButtons) do
            b.TextColor3 = Color3.fromRGB(150, 150, 170)
            b.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.85
    end)
    table.insert(tabButtons, btn)
    return page
end
local mainTab = createTab("🏃 Main Player")
local followTab = createTab("👥 Target Player")
local visualTab = createTab("👁️ Visual ESP")
local cameraTab = createTab("🔍 Camera")
local lockTab = createTab("🎯 Lock Aim")
local settingsTab = createTab("⚙️ Settings & Lag")
local miscTab = createTab("🛠️ Misc")
mainTab.Visible = true
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
tabButtons[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabButtons[1].BackgroundTransparency = 0.85
-- UI Builders
local function updatePillState(pill, state)
    pill.Text = state and "ON" or "OFF"
    pill.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 38, 50)
    pill.TextColor3 = state and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(180, 180, 200)
end
local function createToggle(parent, id, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = generateRandomName()
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
    frame.BackgroundTransparency = 0.3
    frame.ZIndex = 3
    frame.Parent = parent
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = generateRandomName()
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = frame
    local pill = Instance.new("TextButton")
    pill.Name = generateRandomName()
    pill.Size = UDim2.new(0, 60, 0, 24)
    pill.Position = UDim2.new(1, -70, 0.5, -12)
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 11
    pill.ZIndex = 3
    pill.Parent = frame
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = pill
    local state = default
    updatePillState(pill, state)
    pill.MouseButton1Click:Connect(function()
        state = not state
        updatePillState(pill, state)
        callback(state)
    end)
    if id then
        toggleUpdateFuncs[id] = function(newState)
            if newState ~= nil then state = newState else state = not state end
            updatePillState(pill, state)
            callback(state)
        end
    end
    return frame, pill
end
local function createAdjuster(parent, text, val, min, max, step, callback)
    local frame = Instance.new("Frame")
    frame.Name = generateRandomName()
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
    frame.BackgroundTransparency = 0.3
    frame.ZIndex = 3
    frame.Parent = parent
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = generateRandomName()
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text .. ": " .. val
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = frame
    local decBtn = Instance.new("TextButton")
    decBtn.Name = generateRandomName()
    decBtn.Size = UDim2.new(0, 26, 0, 24)
    decBtn.Position = UDim2.new(1, -70, 0.5, -12)
    decBtn.Text = "-"
    decBtn.Font = Enum.Font.GothamBold
    decBtn.TextSize = 14
    decBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    decBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    decBtn.ZIndex = 3
    decBtn.Parent = frame
    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 6)
    dCorner.Parent = decBtn
    local incBtn = Instance.new("TextButton")
    incBtn.Name = generateRandomName()
    incBtn.Size = UDim2.new(0, 26, 0, 24)
    incBtn.Position = UDim2.new(1, -38, 0.5, -12)
    incBtn.Text = "+"
    incBtn.Font = Enum.Font.GothamBold
    incBtn.TextSize = 14
    incBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    incBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    incBtn.ZIndex = 3
    incBtn.Parent = frame
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(0, 6)
    iCorner.Parent = incBtn
    local function update(newVal)
        val = math.clamp(newVal, min, max)
        label.Text = text .. ": " .. val
        callback(val)
    end
    decBtn.MouseButton1Click:Connect(function() update(val - step) end)
    incBtn.MouseButton1Click:Connect(function() update(val + step) end)
    return frame
end
-- ============================================
-- MAIN PLAYER TAB
-- ============================================
createToggle(mainTab, "godmode", "🛡️ Godmode (Bất Tử Chuẩn)", godmodeActive, function(s)
    godmodeActive = s
end)
RunService.Stepped:Connect(function()
    if godmodeActive then
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.Died, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                if hum:GetState() == Enum.HumanoidStateType.Died then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end
end)
createToggle(mainTab, "infjump", "🦘 Infinite Jump (Nhảy Vô Hạn)", infJumpActive, function(s)
    infJumpActive = s
end)
UserInputService.JumpRequest:Connect(function()
    if infJumpActive then
        local c = localPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
createToggle(mainTab, "fly", "Fly (Bay CFRAME Mượt)", flyActive, function(s)
    flyActive = s
    local c = localPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then
        if flyActive then
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        else
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
createAdjuster(mainTab, "Tốc Độ Fly", flyValue, 10, 500, 10, function(v) flyValue = v end)
createToggle(mainTab, "speed", "WalkSpeed (Chạy Nhanh)", speedActive, function(s)
    speedActive = s
    if not s then
        local c = localPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
    end
end)
createAdjuster(mainTab, "Tốc Độ Chạy", speedValue, 16, 500, 5, function(v) speedValue = v end)
createToggle(mainTab, "jump", "JumpPower (Nhảy Cao)", jumpActive, function(s)
    jumpActive = s
    if not s then
        local c = localPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            if h.UseJumpPower then h.JumpPower = 50 else h.JumpHeight = 7 end
        end
    end
end)
createAdjuster(mainTab, "Lực Nhảy", jumpValue, 10, 500, 5, function(v) jumpValue = v end)
createToggle(mainTab, "noclip", "Noclip (Xuyên Tường) [C]", noclipActive, function(s)
    noclipActive = s
    if not noclipActive then
        local c = localPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    if p.Name ~= "HumanoidRootPart" and not p:FindFirstAncestorOfClass("Accessory") then
                        p.CanCollide = true
                    end
                end
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CanCollide = false end
        end
    end
end)
createToggle(mainTab, "invis", "Invisible (Tàng Hình)", invisActive, function(s)
    invisActive = s
    local c = localPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if invisActive then
        if hum and hrp then
            local tempSeat = Instance.new("Seat")
            tempSeat.Name = generateRandomName()
            tempSeat.Size = Vector3.new(2, 1, 2)
            tempSeat.Transparency = 1
            tempSeat.CanCollide = false
            tempSeat.Anchored = false
            tempSeat.CFrame = hrp.CFrame
            tempSeat.Parent = Workspace
            tempSeat:Sit(hum)
            task.spawn(function()
                task.wait(0.15)
                if tempSeat then tempSeat:Destroy() end
            end)
            originalTransparencies = {}
            for _, obj in ipairs(c:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                    originalTransparencies[obj] = obj.Transparency
                    obj.Transparency = 1
                end
            end
        end
    else
        if hum then hum.Sit = false end
        for obj, trans in pairs(originalTransparencies) do
            if obj and obj.Parent then obj.Transparency = trans end
        end
        originalTransparencies = {}
    end
end)
-- ============================================
-- CAMERA TAB
-- ============================================
createAdjuster(cameraTab, "Max Zoom (Khoảng Cách)", maxZoomValue, 128, 10000, 100, function(v)
    maxZoomValue = v
    localPlayer.CameraMaxZoomDistance = maxZoomValue
end)
createAdjuster(cameraTab, "Góc Nhìn FOV", fovValue, 30, 120, 5, function(v)
    fovValue = v
    if camera then camera.FieldOfView = fovValue end
end)
-- ============================================
-- SETTINGS & FIX LAG TAB
-- ============================================
local function applyNoSkinToCharacter(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
            table.insert(hiddenAccessories, child)
            child.Parent = nil
        elseif child:IsA("BasePart") then
            if child.Name == "Head" then
                local face = child:FindFirstChildOfClass("Decal")
                if face then
                    table.insert(hiddenAccessories, face)
                    face.Parent = nil
                end
            end
        end
    end
end
createToggle(settingsTab, "fixlag", "🚀 Fix Lag Smooth (Nét Căng + Xóa Skill & Skin)", fixLagActive, function(s)
    fixLagActive = s
    if fixLagActive then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        disabledEffects = {}
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
                if v.Enabled then
                    v.Enabled = false
                    table.insert(disabledEffects, v)
                end
            elseif v:IsA("PostEffect") then
                if v.Enabled then
                    v.Enabled = false
                    table.insert(disabledEffects, v)
                end
            end
        end
        hiddenAccessories = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                applyNoSkinToCharacter(p.Character)
            end
        end
    else
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.FogEnd = origFogEnd
        for _, obj in ipairs(disabledEffects) do
            if obj and obj.Parent then
                obj.Enabled = true
            end
        end
        disabledEffects = {}
    end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if fixLagActive then
            task.wait(0.2)
            applyNoSkinToCharacter(char)
        end
    end)
end)
local testCard = Instance.new("Frame")
testCard.Name = generateRandomName()
testCard.Size = UDim2.new(1, -10, 0, 100)
testCard.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
testCard.BackgroundTransparency = 0.3
testCard.ZIndex = 3
testCard.Parent = settingsTab
local tcCorner = Instance.new("UICorner")
tcCorner.CornerRadius = UDim.new(0, 8)
tcCorner.Parent = testCard
local testTitle = Instance.new("TextLabel")
testTitle.Name = generateRandomName()
testTitle.Size = UDim2.new(1, -20, 0, 25)
testTitle.Position = UDim2.new(0, 10, 0, 5)
testTitle.Text = "🔍 Anti-Cheat Status Check"
testTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
testTitle.Font = Enum.Font.GothamBold
testTitle.TextSize = 13
testTitle.TextXAlignment = Enum.TextXAlignment.Left
testTitle.BackgroundTransparency = 1
testTitle.ZIndex = 3
testTitle.Parent = testCard
local testStatus = Instance.new("TextLabel")
testStatus.Name = generateRandomName()
testStatus.Size = UDim2.new(1, -20, 0, 25)
testStatus.Position = UDim2.new(0, 10, 0, 30)
testStatus.Text = "Status: UNCHECKED"
testStatus.TextColor3 = Color3.fromRGB(180, 180, 200)
testStatus.Font = Enum.Font.GothamBold
testStatus.TextSize = 12
testStatus.TextXAlignment = Enum.TextXAlignment.Left
testStatus.BackgroundTransparency = 1
testStatus.ZIndex = 3
testStatus.Parent = testCard
local testBtn = Instance.new("TextButton")
testBtn.Name = generateRandomName()
testBtn.Size = UDim2.new(1, -20, 0, 32)
testBtn.Position = UDim2.new(0, 10, 0, 60)
testBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
testBtn.Text = "TEST"
testBtn.TextColor3 = Color3.fromRGB(15, 16, 21)
testBtn.Font = Enum.Font.GothamBold
testBtn.TextSize = 13
testBtn.ZIndex = 3
testBtn.Parent = testCard
local testBtnCorner = Instance.new("UICorner")
testBtnCorner.CornerRadius = UDim.new(0, 6)
testBtnCorner.Parent = testBtn
testBtn.MouseButton1Click:Connect(function()
    testStatus.Text = "Status: SCANNING..."
    testStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    task.wait(1.2)
    local isFlagged = false
    local c = localPlayer.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed > 50 then isFlagged = true end
        if noclipActive or flyActive then isFlagged = true end
    end
    if isFlagged then
        testStatus.Text = "Status: SUSPECTED ⚠️"
        testStatus.TextColor3 = Color3.fromRGB(255, 60, 60)
    else
        testStatus.Text = "Status: SAFE ✅"
        testStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
-- ============================================
-- TARGET PLAYER TAB
-- ============================================
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = generateRandomName()
statusLabel.Size = UDim2.new(1, -10, 0, 32)
statusLabel.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
statusLabel.BackgroundTransparency = 0.3
statusLabel.Text = "Đang dí: Chưa chọn player nào"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.ZIndex = 3
statusLabel.Parent = followTab
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel
local actionFrame = Instance.new("Frame")
actionFrame.Name = generateRandomName()
actionFrame.Size = UDim2.new(1, -10, 0, 32)
actionFrame.BackgroundTransparency = 1
actionFrame.ZIndex = 3
actionFrame.Parent = followTab
local stopFollowBtn = Instance.new("TextButton")
stopFollowBtn.Name = generateRandomName()
stopFollowBtn.Size = UDim2.new(0.65, -4, 1, 0)
stopFollowBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
stopFollowBtn.Text = "⛔ DỪNG FOLLOW"
stopFollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopFollowBtn.Font = Enum.Font.GothamBold
stopFollowBtn.TextSize = 11
stopFollowBtn.ZIndex = 3
stopFollowBtn.Parent = actionFrame
local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopFollowBtn
local refreshBtn = Instance.new("TextButton")
refreshBtn.Name = generateRandomName()
refreshBtn.Size = UDim2.new(0.35, 0, 1, 0)
refreshBtn.Position = UDim2.new(0.65, 4, 0, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Text = "🔄 CẬP NHẬT"
refreshBtn.TextColor3 = Color3.fromRGB(15, 16, 21)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 11
refreshBtn.ZIndex = 3
refreshBtn.Parent = actionFrame
local refCorner = Instance.new("UICorner")
refCorner.CornerRadius = UDim.new(0, 8)
refCorner.Parent = refreshBtn
local function stopFollowing()
    followTargetPlayer = nil
    statusLabel.Text = "Đang dí: Chưa chọn player nào"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    local c = localPlayer.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end
stopFollowBtn.MouseButton1Click:Connect(stopFollowing)
createAdjuster(followTab, "Khoảng Cách Dí", followDistance, 0, 20, 1, function(v) followDistance = v end)
local playerListFrame = Instance.new("Frame")
playerListFrame.Name = generateRandomName()
playerListFrame.Size = UDim2.new(1, -10, 0, 150)
playerListFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
playerListFrame.BackgroundTransparency = 0.3
playerListFrame.ZIndex = 3
playerListFrame.Parent = followTab
local plCorner = Instance.new("UICorner")
plCorner.CornerRadius = UDim.new(0, 8)
plCorner.Parent = playerListFrame
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Name = generateRandomName()
playerScroll.Size = UDim2.new(1, -10, 1, -10)
playerScroll.Position = UDim2.new(0, 5, 0, 5)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.ZIndex = 3
playerScroll.Parent = playerListFrame
local plLayout = Instance.new("UIListLayout")
plLayout.SortOrder = Enum.SortOrder.LayoutOrder
plLayout.Padding = UDim.new(0, 4)
plLayout.Parent = playerScroll
local function refreshPlayerList()
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Name = generateRandomName()
            pBtn.Size = UDim2.new(1, -8, 0, 32)
            pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
            pBtn.Text = " 👤 " .. p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
            pBtn.Font = Enum.Font.GothamBold
            pBtn.TextSize = 12
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.ZIndex = 4
            pBtn.Parent = playerScroll
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = pBtn
            pBtn.MouseButton1Click:Connect(function()
                followTargetPlayer = p
                statusLabel.Text = "🔥 Đang dí: " .. p.DisplayName
                statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
    end
end
refreshBtn.MouseButton1Click:Connect(refreshPlayerList)
task.spawn(function()
    task.wait(1)
    refreshPlayerList()
end)
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if followTargetPlayer == p then stopFollowing() end
    refreshPlayerList()
end)
-- ============================================
-- VISUAL (ESP TRẮNG)
-- ============================================
local function setupESPForCharacter(char)
    if not char then return end
    local highlight = char:FindFirstChild("PlayerHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
    end
    highlight.Enabled = espActive
end
local function trackPlayer(p)
    if p == localPlayer then return end
    if p.Character then setupESPForCharacter(p.Character) end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        setupESPForCharacter(char)
    end)
end
for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
createToggle(visualTab, "esp", "ESP Highlight (Trắng) [X]", espActive, function(s)
    espActive = s
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("PlayerHighlight")
            if highlight then
                highlight.Enabled = espActive
            else
                setupESPForCharacter(p.Character)
            end
        end
    end
end)
createToggle(visualTab, "fullbright", "Fullbright (Sáng Màn)", fullbrightActive, function(s)
    fullbrightActive = s
    if not s then
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClockTime
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.FogEnd = origFogEnd
    end
end)
-- ============================================
-- LOCK AIM TAB & HITBOX EXPANDER
-- ============================================
local function getTargetInFOV()
    if not camera then return nil end
    local sc = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local cm, sf = nil, fovRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local o = p.Character
            local h = o:FindFirstChildOfClass("Humanoid")
            local th = o:FindFirstChild("Head") or o:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and th then
                local sp, os = camera:WorldToViewportPoint(th.Position)
                if os then
                    local md = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
                    if md <= sf then sf = md; cm = th end
                end
            end
        end
    end
    return cm
end
local function disableLock()
    currentTarget = nil
    isLocked = false
    fovCircle.Visible = false
    if toggleUpdateFuncs["lock"] then toggleUpdateFuncs["lock"](false) end
end
local function enableLock()
    isLocked = true
    fovCircle.Visible = true
    currentTarget = getTargetInFOV()
    if not currentTarget then disableLock() end
end
createToggle(lockTab, "lock", "Lock Aim Target [E]", isLocked, function(s)
    if s then enableLock() else disableLock() end
end)
createAdjuster(lockTab, "Bán Kính FOV Aim", fovRadius, 20, 400, 10, function(v)
    fovRadius = v
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end)
createToggle(lockTab, "hitbox", "Hitbox Expander (Ăn Chuẩn)", hitboxActive, function(s)
    hitboxActive = s
    if not hitboxActive then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if pHrp then
                    pHrp.Size = Vector3.new(2, 2, 1)
                    pHrp.Transparency = 1
                end
            end
        end
    end
end)
createAdjuster(lockTab, "Kích Thước Hitbox", hitboxSize, 2, 60, 2, function(v)
    hitboxSize = v
end)
-- ============================================
-- MISC TAB (có Spinbot)
-- ============================================
createToggle(miscTab, "autoclick", "Auto Click [-]", autoClickActive, function(s)
    autoClickActive = s
    if autoClickActive then
        task.spawn(function()
            while autoClickActive do
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.001)
            end
        end)
    end
end)

-- ===== SPINBOT =====
createToggle(miscTab, "spinbot", "🌀 Spinbot", spinbotActive, function(s)
    spinbotActive = s
end)
createAdjuster(miscTab, "Tốc Độ Spin", spinSpeed, 5, 100, 5, function(v)
    spinSpeed = v
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == LOCK_KEY then
        if toggleUpdateFuncs["lock"] then toggleUpdateFuncs["lock"]() end
    elseif input.KeyCode == NOCLIP_KEY then
        if toggleUpdateFuncs["noclip"] then toggleUpdateFuncs["noclip"]() end
    elseif input.KeyCode == ESP_KEY then
        if toggleUpdateFuncs["esp"] then toggleUpdateFuncs["esp"]() end
    elseif input.KeyCode == AUTOCLICK_KEY then
        if toggleUpdateFuncs["autoclick"] then toggleUpdateFuncs["autoclick"]() end
    end
end)
-- ============================================
-- MAIN RENDER LOOP
-- ============================================
RunService.RenderStepped:Connect(function(dt)
    if camera then
        if camera.FieldOfView ~= fovValue then
            camera.FieldOfView = fovValue
        end
    end
    if localPlayer.CameraMaxZoomDistance ~= maxZoomValue then
        localPlayer.CameraMaxZoomDistance = maxZoomValue
    end
    local c = localPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    -- FLY MECHANIC
    if flyActive and hrp and camera then
        local moveVector = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
        if moveVector.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveVector.Unit * flyValue * dt)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    -- Hitbox Expander Loop
    if hitboxActive then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                if pHrp and pHum and pHum.Health > 0 then
                    pHrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    pHrp.Transparency = 0.75
                    pHrp.Color = Color3.fromRGB(255, 255, 255)
                    pHrp.Material = Enum.Material.ForceField
                    pHrp.CanCollide = false
                end
            end
        end
    end
    -- Lighting Loop
    if fullbrightActive or fixLagActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.GlobalShadows = false
    end
    -- Speed & Jump
    if hum then
        if speedActive then hum.WalkSpeed = speedValue end
        if jumpActive then
            if hum.UseJumpPower then hum.JumpPower = jumpValue else hum.JumpHeight = jumpValue end
        end
    end
    -- Noclip
    if noclipActive then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    -- ===== SPINBOT =====
    if spinbotActive and hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
    -- Lock Aim
    if isLocked and camera then
        if currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChildOfClass("Humanoid") and currentTarget.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
            camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
        else
            disableLock()
        end
    end
    -- Target Player
    if followTargetPlayer and followTargetPlayer.Character and hrp then
        local targetHrp = followTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            local targetPos = targetHrp.CFrame * Vector3.new(0, 0, followDistance)
            hrp.CFrame = CFrame.new(targetPos, targetHrp.Position)
        end
    end
end)
