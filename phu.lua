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
local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local fovRadius = 50
local followDistance = 3
local currentTarget, isLocked, espActive, speedActive, jumpActive, noclipActive, flyActive, fullbrightActive, fixLagActive, autoClickActive = nil, false, false, false, false, false, false, false, false, false
local followTargetPlayer = nil
local speedValue, jumpValue, flyValue = 16, 25, 50
local bodyGyro, bodyVel = nil, nil
local origBrightness, origClockTime, origGlobalShadows, origFogEnd = Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.FogEnd

-- Lưu trữ hàm update giao diện nút bấm để đồng bộ với phím tắt
local toggleUpdateFuncs = {}

-- ============================================
-- MAIN GUI CREATION
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NNOOBVN_Glassmorphism_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Circle FOV
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
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
fovStroke.Color = Color3.fromRGB(0, 255, 200)
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- Floating Toggle Button
local toggleMenuBtn = Instance.new("ImageButton")
toggleMenuBtn.Name = "OpenMenuBtn"
toggleMenuBtn.Size = UDim2.new(0, 55, 0, 55)
toggleMenuBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
toggleMenuBtn.Image = AVATAR_IMAGE_ID
toggleMenuBtn.ScaleType = Enum.ScaleType.Crop
toggleMenuBtn.Active = true
toggleMenuBtn.Draggable = true
toggleMenuBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 255, 200)
toggleStroke.Thickness = 2.5
toggleStroke.Parent = toggleMenuBtn

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 560, 0, 320)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.Color = Color3.fromRGB(0, 255, 200)
mainStroke.Parent = mainFrame

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = AVATAR_IMAGE_ID
bgImage.ImageTransparency = 0.88
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1
bgImage.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1
header.ZIndex = 2
header.Parent = mainFrame

local avatarHeader = Instance.new("ImageLabel")
avatarHeader.Size = UDim2.new(0, 34, 0, 34)
avatarHeader.Position = UDim2.new(0, 12, 0, 8)
avatarHeader.Image = AVATAR_IMAGE_ID
avatarHeader.BackgroundTransparency = 1
avatarHeader.ZIndex = 2
avatarHeader.Parent = header

local avatarHeaderCorner = Instance.new("UICorner")
avatarHeaderCorner.CornerRadius = UDim.new(1, 0)
avatarHeaderCorner.Parent = avatarHeader

local titleText = Instance.new("TextLabel")
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
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 2
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
toggleMenuBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- ============================================
-- SIDEBAR & TABS
-- ============================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -130, 1, -50)
tabContainer.Position = UDim2.new(0, 130, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 2
tabContainer.Parent = mainFrame

local tabs, tabButtons = {}, {}

local function createTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    page.Visible = false
    page.ZIndex = 3
    page.Parent = tabContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    tabs[name] = page

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Position = UDim2.new(0, 8, 0, (#tabButtons * 42) + 10)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(150, 150, 170)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    btn.BackgroundTransparency = 0.5
    btn.ZIndex = 3
    btn.Parent = sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for tabName, tabObj in pairs(tabs) do tabObj.Visible = (tabName == name) end
        for _, b in ipairs(tabButtons) do
            b.TextColor3 = Color3.fromRGB(150, 150, 170)
            b.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        end
        btn.TextColor3 = Color3.fromRGB(0, 255, 200)
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        btn.BackgroundTransparency = 0.85
    end)

    table.insert(tabButtons, btn)
    return page
end

local mainTab = createTab("⚡ Main")
local followTab = createTab("👥 Target Player")
local visualTab = createTab("👁️ Visual")
local lockTab = createTab("🎯 Lock Aim")
local miscTab = createTab("🛠️ Misc")

tabs["⚡ Main"].Visible = true
tabButtons[1].TextColor3 = Color3.fromRGB(0, 255, 200)
tabButtons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 200)
tabButtons[1].BackgroundTransparency = 0.85

-- UI CONTROL BUILDERS (ĐỒNG BỘ NÚT BẤM & PHÍM TẮT)
local function updatePillState(pill, state)
    pill.Text = state and "ON" or "OFF"
    pill.BackgroundColor3 = state and Color3.fromRGB(0, 230, 135) or Color3.fromRGB(35, 38, 50)
    pill.TextColor3 = state and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(180, 180, 200)
end

local function createToggle(parent, id, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
    frame.BackgroundTransparency = 0.3
    frame.ZIndex = 3
    frame.Parent = parent

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = frame

    local pill = Instance.new("TextButton")
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

    local function setToggleState(newState)
        state = newState
        updatePillState(pill, state)
        callback(state)
    end

    pill.MouseButton1Click:Connect(function()
        setToggleState(not state)
    end)

    if id then
        toggleUpdateFuncs[id] = function(newState)
            if newState ~= nil then
                state = newState
            else
                state = not state
            end
            updatePillState(pill, state)
            callback(state)
        end
    end

    return frame, pill
end

local function createAdjuster(parent, text, val, min, max, step, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
    frame.BackgroundTransparency = 0.3
    frame.ZIndex = 3
    frame.Parent = parent

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text .. ": " .. val
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = frame

    local decBtn = Instance.new("TextButton")
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
-- MAIN TAB FEATURES
-- ============================================
createToggle(mainTab, "fly", "Fly (Bay)", flyActive, function(s)
    flyActive = s
    local c = localPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if flyActive and hrp then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = hrp.CFrame
        bodyGyro.Parent = hrp
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.velocity = Vector3.zero
        bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Parent = hrp
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
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
end)

-- ============================================
-- TARGET PLAYER TAB (TRIỆT TIÊU RUNG RẮC 100%)
-- ============================================
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 32)
statusLabel.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
statusLabel.BackgroundTransparency = 0.3
statusLabel.Text = "Đang dí: Chưa chọn player nào"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.ZIndex = 3
statusLabel.Parent = followTab

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local actionFrame = Instance.new("Frame")
actionFrame.Size = UDim2.new(1, -10, 0, 32)
actionFrame.BackgroundTransparency = 1
actionFrame.ZIndex = 3
actionFrame.Parent = followTab

local stopFollowBtn = Instance.new("TextButton")
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
refreshBtn.Size = UDim2.new(0.35, 0, 1, 0)
refreshBtn.Position = UDim2.new(0.65, 4, 0, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
refreshBtn.Text = "🔄 CẬP NHẬT"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    
    local c = localPlayer.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

stopFollowBtn.MouseButton1Click:Connect(stopFollowing)

createAdjuster(followTab, "Khoảng Cách Dí", followDistance, 0, 20, 1, function(v)
    followDistance = v
end)

local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, -10, 0, 150)
playerListFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
playerListFrame.BackgroundTransparency = 0.3
playerListFrame.ZIndex = 3
playerListFrame.Parent = followTab

local plCorner = Instance.new("UICorner")
plCorner.CornerRadius = UDim.new(0, 8)
plCorner.Parent = playerListFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -10, 1, -10)
playerScroll.Position = UDim2.new(0, 5, 0, 5)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
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
            pBtn.Size = UDim2.new(1, -8, 0, 32)
            pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
            pBtn.Text = "  👤 " .. p.DisplayName .. " (@" .. p.Name .. ")"
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
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 135)
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

-- VISUAL TAB
local function applyEsp(p)
    if p == localPlayer then return end
    local function setup(c)
        if not c then return end
        local h = c:FindFirstChild("PlayerHighlight")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "PlayerHighlight"
            h.FillTransparency = 1
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = c
        end
        h.Adornee = c
        h.Enabled = espActive
    end
    if p.Character then setup(p.Character) end
    p.CharacterAdded:Connect(setup)
end

for _, p in ipairs(Players:GetPlayers()) do applyEsp(p) end
Players.PlayerAdded:Connect(applyEsp)

createToggle(visualTab, "esp", "ESP Highlight [X]", espActive, function(s)
    espActive = s
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            applyEsp(p)
            local h = p.Character:FindFirstChild("PlayerHighlight")
            if h then h.Enabled = espActive end
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

-- LOCK AIM TAB
local function getTargetInFOV()
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
    if toggleUpdateFuncs["lock"] then
        toggleUpdateFuncs["lock"](false)
    end
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

createAdjuster(lockTab, "Bán Kính FOV", fovRadius, 20, 400, 10, function(v)
    fovRadius = v
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end)

-- MISC TAB
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

createToggle(miscTab, "fixlag", "Fix Lag (Giảm Đồ Họa)", fixLagActive, function(s)
    fixLagActive = s
    if fixLagActive then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("PostEffect") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
    end
end)

-- ============================================
-- INPUT & LOOP (ĐỒNG BỘ PHÍM TẮT CHUẨN XÁC)
-- ============================================
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    
    if i.KeyCode == NOCLIP_KEY then
        if toggleUpdateFuncs["noclip"] then toggleUpdateFuncs["noclip"]() end
    elseif i.KeyCode == LOCK_KEY then
        if toggleUpdateFuncs["lock"] then toggleUpdateFuncs["lock"]() end
    elseif i.KeyCode == ESP_KEY then
        if toggleUpdateFuncs["esp"] then toggleUpdateFuncs["esp"]() end
    elseif i.KeyCode == AUTOCLICK_KEY then
        if toggleUpdateFuncs["autoclick"] then toggleUpdateFuncs["autoclick"]() end
    end
end)

RunService.Stepped:Connect(function()
    if noclipActive or followTargetPlayer then
        local c = localPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.003) % 1
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    
    mainStroke.Color = rainbowColor
    toggleStroke.Color = rainbowColor
    
    if fullbrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    end
    
    if espActive then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local h = p.Character:FindFirstChild("PlayerHighlight")
                if h then 
                    h.OutlineColor = rainbowColor 
                    h.Enabled = true
                else
                    applyEsp(p)
                end
            end
        end
    end
    
    local c = localPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    
    -- XỬ LÝ DÍ THEO BẰNG CÁCH KHÓA LỰC GIẬT VẬT LÝ (CHỐNG RUNG)
    if followTargetPlayer and followTargetPlayer.Character and hrp and hum then
        local targetHrp = followTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = followTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if targetHrp and targetHum and targetHum.Health > 0 then
            hum.AutoRotate = false
            
            -- Triệt tiêu hoàn toàn vận tốc vật lý gây rung giật
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            -- Đặt CFrame phía sau lưng target mượt mà
            local goalCFrame = targetHrp.CFrame * CFrame.new(0, 0, followDistance)
            hrp.CFrame = goalCFrame
        else
            stopFollowing()
        end
    else
        if hum and not hum.AutoRotate then hum.AutoRotate = true end
    end
    
    if c and hum then
        if speedActive then hum.WalkSpeed = speedValue end
        if jumpActive then
            if hum.UseJumpPower then hum.JumpPower = jumpValue else hum.JumpHeight = (jumpValue * 0.14) end
        end
    end
    
    if flyActive and bodyGyro and bodyVel and not followTargetPlayer then
        local camCFrame = camera.CFrame
        bodyGyro.cframe = camCFrame
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then bodyVel.velocity = moveDir.Unit * flyValue else bodyVel.velocity = Vector3.zero end
    end
    
    if not isLocked then return end
    if not hrp or not hum or hum.Health <= 0 then disableLock(); return end
    
    if currentTarget and currentTarget.Parent then
        local th = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
        if not th or th.Health <= 0 then currentTarget = nil end
    else
        currentTarget = nil
    end
    
    if not currentTarget then currentTarget = getTargetInFOV() end
    
    if currentTarget then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, currentTarget.Position)
        local tp = currentTarget.Position
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
    else
        disableLock()
    end
end)
