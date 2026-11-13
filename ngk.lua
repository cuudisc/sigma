local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = Workspace.CurrentCamera
end)

-- Biến trạng thái & giá trị
local isFlyEnabled = false
local flySpeed = 103
local isSpeedEnabled = false
local customWalkSpeed = 206
local isJumpEnabled = false
local customJumpPower = 102
local isSpinEnabled = false
local spinSpeed = 412
local isEspEnabled = false
local isNoclipEnabled = false
local isFixLagEnabled = false
local customFakeNameText = "ProPlayer"

-- Biến phụ cho Fly chuẩn physics
local flyConn = nil

local neonGreen = Color3.fromRGB(57, 255, 20)
local darkBg = Color3.fromRGB(20, 20, 25)

-- Font nét thanh gọn chuẩn mẫu
local customFont = Enum.Font.Code

-- Avatar Asset ID mới
local customAvatarAsset = "rbxthumb://type=Asset&id=18553019389&w=150&h=150"

-- ESP Folder
local espFolder = Instance.new("Folder")
espFolder.Name = "NgkooeeaaHub_ESP"
espFolder.Parent = playerGui
local espObjects = {}

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
    if not char then 
        clearESP(p)
        return 
    end
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid or humanoid.Health <= 0 then 
        clearESP(p)
        return 
    end

    local data = espObjects[p]
    if data and data.char == char then
        if data.hl then data.hl.Enabled = isEspEnabled end
        if data.bb then data.bb.Enabled = isEspEnabled end
        return
    end

    clearESP(p)

    local hl = Instance.new("Highlight")
    hl.Name = "HubHL"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(135, 206, 235)
    hl.OutlineColor = Color3.fromRGB(135, 206, 235)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = isEspEnabled
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "HubName"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3.2, 0) -- Đẩy cao lên một chút
    bb.AlwaysOnTop = true
    bb.Enabled = isEspEnabled
    bb.Parent = espFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 28)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = p.DisplayName or p.Name
    nameLabel.TextColor3 = Color3.fromRGB(135, 206, 235)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.Font = customFont
    nameLabel.TextSize = 14
    nameLabel.Parent = bb

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 25)
    distLabel.Position = UDim2.new(0, 0, 0, 28) -- Tách dòng và phóng to rõ hơn
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.2
    distLabel.Font = customFont
    distLabel.TextSize = 13 -- Phóng to số mét
    distLabel.Parent = bb

    espObjects[p] = { hl = hl, bb = bb, nameLabel = nameLabel, distLabel = distLabel, char = char }
end

Players.PlayerRemoving:Connect(function(p) clearESP(p) end)

-- GUI Setup
if playerGui:FindFirstChild("NgkooeeaaHub") then
    playerGui.NgkooeeaaHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NgkooeeaaHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 99999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Notification Frame
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 240, 0, 45)
notifFrame.Position = UDim2.new(1, -255, 1, -60)
notifFrame.BackgroundColor3 = darkBg
notifFrame.BackgroundTransparency = 0.2
notifFrame.BorderSizePixel = 0
notifFrame.Visible = false
notifFrame.Parent = screenGui
Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = neonGreen
notifStroke.Thickness = 1.5
notifStroke.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = neonGreen
notifText.Text = "🛡️ Scan Cheat: Hệ thống An toàn!"
notifText.TextSize = 11
notifText.Font = customFont
notifText.Parent = notifFrame

local function showScanNotification()
    task.spawn(function()
        notifFrame.Visible = true
        task.wait(3)
        notifFrame.Visible = false
    end)
end

-- Main Menu Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 525)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -262)
mainFrame.BackgroundColor3 = darkBg
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = neonGreen
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
title.TextColor3 = neonGreen
title.Text = "      Ngkooeeaa HUB"
title.TextSize = 13
title.Font = customFont
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local titleImage = Instance.new("ImageButton")
titleImage.Size = UDim2.new(0, 28, 0, 28)
titleImage.Position = UDim2.new(0, 6, 0.5, -14)
titleImage.BackgroundTransparency = 1
titleImage.Image = customAvatarAsset
titleImage.Parent = title
Instance.new("UICorner", titleImage).CornerRadius = UDim.new(1, 0)

-- Nút Avatar di chuyển được
local bananaBtn = Instance.new("ImageButton")
bananaBtn.Size = UDim2.new(0, 45, 0, 45)
bananaBtn.Position = UDim2.new(0, 15, 0.5, -22)
bananaBtn.BackgroundColor3 = darkBg
bananaBtn.Image = customAvatarAsset
bananaBtn.Parent = screenGui
Instance.new("UICorner", bananaBtn).CornerRadius = UDim.new(1, 0)

local bananaStroke = Instance.new("UIStroke")
bananaStroke.Color = neonGreen
bananaStroke.Thickness = 2
bananaStroke.Parent = bananaBtn

bananaBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Kéo thả Main Menu & Avatar
local draggingMain, dragInputMain, dragStartMain, startPosMain
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingMain = false end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputMain = input
    end
end)

local draggingAvatar, dragInputAvatar, dragStartAvatar, startPosAvatar
bananaBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingAvatar = true
        dragStartAvatar = input.Position
        startPosAvatar = bananaBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingAvatar = false end
        end)
    end
end)
bananaBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputAvatar = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputMain and draggingMain then
        local delta = input.Position - dragStartMain
        mainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    elseif input == dragInputAvatar and draggingAvatar then
        local delta = input.Position - dragStartAvatar
        bananaBtn.Position = UDim2.new(startPosAvatar.X.Scale, startPosAvatar.X.Offset + delta.X, startPosAvatar.Y.Scale, startPosAvatar.Y.Offset + delta.Y)
    end
end)

-- Tab Switcher
local tabMainBtn = Instance.new("TextButton")
tabMainBtn.Size = UDim2.new(0.45, 0, 0, 26)
tabMainBtn.Position = UDim2.new(0.05, 0, 0, 48)
tabMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabMainBtn.TextColor3 = neonGreen
tabMainBtn.Text = "Main Menu"
tabMainBtn.TextSize = 11
tabMainBtn.Font = customFont
tabMainBtn.Parent = mainFrame
Instance.new("UICorner", tabMainBtn).CornerRadius = UDim.new(0, 6)
local t1Stroke = Instance.new("UIStroke")
t1Stroke.Color = neonGreen
t1Stroke.Thickness = 1
t1Stroke.Parent = tabMainBtn

local tabTeleBtn = Instance.new("TextButton")
tabTeleBtn.Size = UDim2.new(0.45, 0, 0, 26)
tabTeleBtn.Position = UDim2.new(0.5, 0, 0, 48)
tabTeleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabTeleBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
tabTeleBtn.Text = "Tele Player"
tabTeleBtn.TextSize = 11
tabTeleBtn.Font = customFont
tabTeleBtn.Parent = mainFrame
Instance.new("UICorner", tabTeleBtn).CornerRadius = UDim.new(0, 6)
local t2Stroke = Instance.new("UIStroke")
t2Stroke.Color = Color3.fromRGB(120, 120, 120)
t2Stroke.Thickness = 1
t2Stroke.Parent = tabTeleBtn

local containerMain = Instance.new("ScrollingFrame")
containerMain.Size = UDim2.new(1, 0, 0, 440)
containerMain.Position = UDim2.new(0, 0, 0, 80)
containerMain.BackgroundTransparency = 1
containerMain.CanvasSize = UDim2.new(0, 0, 0, 450)
containerMain.ScrollBarThickness = 4
containerMain.Visible = true
containerMain.Parent = mainFrame

local containerTele = Instance.new("ScrollingFrame")
containerTele.Size = UDim2.new(1, 0, 0, 440)
containerTele.Position = UDim2.new(0, 0, 0, 80)
containerTele.BackgroundTransparency = 1
containerTele.CanvasSize = UDim2.new(0, 0, 0, 0)
containerTele.ScrollBarThickness = 4
containerTele.Visible = false
containerTele.Parent = mainFrame

tabMainBtn.MouseButton1Click:Connect(function()
    containerMain.Visible = true
    containerTele.Visible = false
    tabMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabMainBtn.TextColor3 = neonGreen
    t1Stroke.Color = neonGreen
    tabTeleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabTeleBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    t2Stroke.Color = Color3.fromRGB(120, 120, 120)
end)

tabTeleBtn.MouseButton1Click:Connect(function()
    containerMain.Visible = false
    containerTele.Visible = true
    tabTeleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabTeleBtn.TextColor3 = neonGreen
    t2Stroke.Color = neonGreen
    tabMainBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabMainBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    t1Stroke.Color = Color3.fromRGB(120, 120, 120)
end)

-- Ctrl + Click Teleport
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            pcall(function()
                local mouse = localPlayer:GetMouse()
                local targetPos = mouse.Hit
                local char = localPlayer.Character
                if char and targetPos then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(targetPos.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end)

-- Ô nhập Fake Name
local nameInputBox = Instance.new("TextBox")
nameInputBox.Size = UDim2.new(0.62, 0, 0, 28)
nameInputBox.Position = UDim2.new(0.05, 0, 0, 10)
nameInputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
nameInputBox.TextColor3 = neonGreen
nameInputBox.PlaceholderText = "Nhập tên giả ở đây..."
nameInputBox.Text = customFakeNameText
nameInputBox.TextSize = 11
nameInputBox.Font = customFont
nameInputBox.ClearTextOnFocus = false
nameInputBox.Parent = containerMain
Instance.new("UICorner", nameInputBox).CornerRadius = UDim.new(0, 6)

local niStroke = Instance.new("UIStroke")
niStroke.Color = neonGreen
niStroke.Thickness = 1
niStroke.Parent = nameInputBox

nameInputBox.FocusLost:Connect(function()
    if nameInputBox.Text ~= "" then
        customFakeNameText = nameInputBox.Text
    end
end)

local fakeNameBtn = Instance.new("TextButton")
fakeNameBtn.Size = UDim2.new(0.26, 0, 0, 28)
fakeNameBtn.Position = UDim2.new(0.69, 0, 0, 10)
fakeNameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
fakeNameBtn.TextColor3 = neonGreen
fakeNameBtn.Text = "Fake Name"
fakeNameBtn.TextSize = 10
fakeNameBtn.Font = customFont
fakeNameBtn.Parent = containerMain
Instance.new("UICorner", fakeNameBtn).CornerRadius = UDim.new(0, 6)

local fnStroke = Instance.new("UIStroke")
fnStroke.Color = neonGreen
fnStroke.Thickness = 1
fnStroke.Parent = fakeNameBtn

fakeNameBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local head = char:FindFirstChild("Head")
                if head then
                    local existingTag = head:FindFirstChild("CustomFakeTag")
                    if existingTag then existingTag:Destroy() end
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "CustomFakeTag"
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 200, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = customFakeNameText
                    txt.TextColor3 = neonGreen
                    txt.TextStrokeTransparency = 0.2
                    txt.Font = customFont
                    txt.TextSize = 14
                    txt.Parent = bb
                end
            end
        end
    end)
end)

-- Tạo hàng tính năng Fly và các tính năng khác trong Main
local flyBtn, statusLabel

local function createFeatureRow(posY, labelName, minVal, maxVal, stepVal, defaultVal, stateRef, valRef)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.38, 0, 0, 28)
    label.Position = UDim2.new(0.05, 0, 0, posY)
    label.BackgroundTransparency = 1
    label.TextColor3 = neonGreen
    label.Text = labelName .. ": " .. defaultVal
    label.TextSize = 11
    label.Font = customFont
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = containerMain

    if stateRef == "fly" then
        statusLabel = label
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.25, 0, 0, 28)
    toggleBtn.Position = UDim2.new(0.44, 0, 0, posY)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "OFF"
    toggleBtn.TextSize = 11
    toggleBtn.Font = customFont
    toggleBtn.Parent = containerMain
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = neonGreen
    tStroke.Thickness = 1
    tStroke.Parent = toggleBtn

    if stateRef == "fly" then
        flyBtn = toggleBtn
    end

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0.1, 0, 0, 28)
    minusBtn.Position = UDim2.new(0.71, 0, 0, posY)
    minusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    minusBtn.TextColor3 = neonGreen
    minusBtn.Text = "-"
    minusBtn.TextSize = 13
    minusBtn.Font = customFont
    minusBtn.Parent = containerMain
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

    local mStroke = Instance.new("UIStroke")
    mStroke.Color = neonGreen
    mStroke.Thickness = 1
    mStroke.Parent = minusBtn

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0.1, 0, 0, 28)
    plusBtn.Position = UDim2.new(0.83, 0, 0, posY)
    plusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    plusBtn.TextColor3 = neonGreen
    plusBtn.Text = "+"
    plusBtn.TextSize = 13
    plusBtn.Font = customFont
    plusBtn.Parent = containerMain
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = neonGreen
    pStroke.Thickness = 1
    pStroke.Parent = plusBtn

    if stateRef ~= "fly" then
        toggleBtn.MouseButton1Click:Connect(function()
            if stateRef == "speed" then isSpeedEnabled = not isSpeedEnabled
            elseif stateRef == "jump" then isJumpEnabled = not isJumpEnabled
            elseif stateRef == "spin" then isSpinEnabled = not isSpinEnabled end

            local isOn = (stateRef == "speed" and isSpeedEnabled) or (stateRef == "jump" and isJumpEnabled) or (stateRef == "spin" and isSpinEnabled)
            toggleBtn.Text = isOn and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = isOn and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(220, 60, 60)
        end)
    end

    minusBtn.MouseButton1Click:Connect(function()
        if valRef == "fly" then
            if flySpeed > 50 then flySpeed = math.max(50, flySpeed - stepVal) label.Text = labelName .. ": " .. flySpeed end
        elseif valRef == "speed" then
            customWalkSpeed = math.clamp(customWalkSpeed - stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. customWalkSpeed
        elseif valRef == "jump" then
            customJumpPower = math.clamp(customJumpPower - stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. customJumpPower
        elseif valRef == "spin" then
            spinSpeed = math.clamp(spinSpeed - stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. spinSpeed
        end
    end)

    plusBtn.MouseButton1Click:Connect(function()
        if valRef == "fly" then
            if flySpeed < 1236 then flySpeed = math.min(1236, flySpeed + stepVal) label.Text = labelName .. ": " .. flySpeed end
        elseif valRef == "speed" then
            customWalkSpeed = math.clamp(customWalkSpeed + stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. customWalkSpeed
        elseif valRef == "jump" then
            customJumpPower = math.clamp(customJumpPower + stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. customJumpPower
        elseif valRef == "spin" then
            spinSpeed = math.clamp(spinSpeed + stepVal, minVal, maxVal)
            label.Text = labelName .. ": " .. spinSpeed
        end
    end)
end

createFeatureRow(48, "Tốc độ Fly", 50, 1236, 103, flySpeed, "fly", "fly")
createFeatureRow(86, "WalkSpeed", 16, 2472, 206, customWalkSpeed, "speed", "speed")
createFeatureRow(124, "JumpPower", 50, 1236, 51, customJumpPower, "jump", "jump")
createFeatureRow(162, "Spinbot", 0, 4944, 412, spinSpeed, "spin", "spin")

local function createToggleButton(posY, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. ": OFF"
    btn.TextSize = 11
    btn.Font = customFont
    btn.Parent = containerMain
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = neonGreen
    stroke.Thickness = 1
    stroke.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(220, 60, 60)
        callback(state)
    end)
end

createToggleButton(212, "Sky Blue ESP", function(state)
    isEspEnabled = state
    if not state then
        clearAllESP()
    end
end)

createToggleButton(250, "Noclip", function(state)
    isNoclipEnabled = state
end)

createToggleButton(288, "Fix Lag (Quét Toàn Server)", function(state)
    isFixLagEnabled = state
    if state then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.FogEnd = 999999
            
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                elseif v:IsA("MeshPart") then
                    v.TextureID = ""
                    v.CastShadow = false
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Beam") then
                    v.Enabled = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true
        end)
    end
end)

-- --- TAB TELEPORT PLAYER ---
local playerButtons = {}

local resetTabBtn = Instance.new("TextButton")
resetTabBtn.Size = UDim2.new(0.9, 0, 0, 32)
resetTabBtn.Position = UDim2.new(0.05, 0, 0, 10)
resetTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
resetTabBtn.TextColor3 = neonGreen
resetTabBtn.Text = "🔄 Reset Tab (Cập nhật danh sách Player)"
resetTabBtn.TextSize = 11
resetTabBtn.Font = customFont
resetTabBtn.Parent = containerTele
Instance.new("UICorner", resetTabBtn).CornerRadius = UDim.new(0, 6)

local rStroke = Instance.new("UIStroke")
rStroke.Color = neonGreen
rStroke.Thickness = 1.5
rStroke.Parent = resetTabBtn

local function refreshPlayerList()
    for _, btn in pairs(playerButtons) do
        if btn then btn:Destroy() end
    end
    playerButtons = {}

    local yOffset = 52
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0.9, 0, 0, 32)
            tpBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
            tpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            tpBtn.TextColor3 = neonGreen
            tpBtn.Text = "⚡ Teleport -> " .. (p.DisplayName or p.Name) .. " (@" .. p.Name .. ")"
            tpBtn.TextSize = 10
            tpBtn.Font = customFont
            tpBtn.Parent = containerTele
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

            local tpStroke = Instance.new("UIStroke")
            tpStroke.Color = neonGreen
            tpStroke.Thickness = 1
            tpStroke.Parent = tpBtn

            tpBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local targetChar = p.Character
                    local myChar = localPlayer.Character
                    if targetChar and myChar then
                        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                        if targetHrp and myHrp then
                            myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end)
            end)

            yOffset = yOffset + 38
            table.insert(playerButtons, tpBtn)
        end
    end
    containerTele.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

resetTabBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
end)

Players.PlayerAdded:Connect(function() refreshPlayerList() end)
Players.PlayerRemoving:Connect(function() refreshPlayerList() end)
refreshPlayerList()

-- ================= LOGIC FLY & NOCLIP RIÊNG BIỆT =================
local keys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function applyFlyPhysics()
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    if flyConn then flyConn:Disconnect() end
    if hrp:FindFirstChild("CustomFlyAttachment") then hrp.CustomFlyAttachment:Destroy() end
    if hrp:FindFirstChild("CustomFlyAlign") then hrp.CustomFlyAlign:Destroy() end
    if hrp:FindFirstChild("CustomFlyVelocity") then hrp.CustomFlyVelocity:Destroy() end

    flyBtn.Text = "BẬT"
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)

    local att = Instance.new("Attachment", hrp)
    att.Name = "CustomFlyAttachment"

    local align = Instance.new("AlignOrientation", hrp)
    align.Name = "CustomFlyAlign"
    align.Attachment0 = att
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.CFrame = camera.CFrame
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
        if not isFlyEnabled or not hrp.Parent then return end
        local moveDir = Vector3.zero
        local currentSpeed = flySpeed * (keys.Shift and 2 or 1)

        if keys.W then moveDir = moveDir + camera.CFrame.LookVector end
        if keys.S then moveDir = moveDir - camera.CFrame.LookVector end
        if keys.A then moveDir = moveDir - camera.CFrame.RightVector end
        if keys.D then moveDir = moveDir + camera.CFrame.RightVector end
        if keys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keys.Shift then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        lv.VectorVelocity = moveDir * currentSpeed
        align.CFrame = camera.CFrame
    end)
end

local function removeFlyPhysics()
    flyBtn.Text = "OFF"
    flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    if flyConn then flyConn:Disconnect() end
    
    local character = localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        if hrp:FindFirstChild("CustomFlyAttachment") then hrp.CustomFlyAttachment:Destroy() end
        if hrp:FindFirstChild("CustomFlyAlign") then hrp.CustomFlyAlign:Destroy() end
        if hrp:FindFirstChild("CustomFlyVelocity") then hrp.CustomFlyVelocity:Destroy() end
    end
    
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function toggleFly()
    isFlyEnabled = not isFlyEnabled
    if isFlyEnabled then applyFlyPhysics() else removeFlyPhysics() end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then keys.Shift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then keys.Shift = false end
end)

-- Main Loop
local antiCheatTimer = 0

RunService.RenderStepped:Connect(function(dt)
    if isEspEnabled then
        for p, data in pairs(espObjects) do
            local char = p.Character
            local myChar = localPlayer.Character
            if char and myChar then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                if hrp and myHrp then
                    setupESP(p)
                    local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                    data.distLabel.Text = "[" .. dist .. "m]"
                else
                    clearESP(p)
                end
            else
                clearESP(p)
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if not espObjects[p] then
                setupESP(p)
            end
        end
    end

    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if isSpeedEnabled and hum then hum.WalkSpeed = customWalkSpeed end
    if isJumpEnabled and hum then 
        hum.UseJumpPower = true
        hum.JumpPower = customJumpPower 
    end

    if isSpinEnabled and hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed * dt), 0)
    end

    if isNoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    antiCheatTimer = antiCheatTimer + dt
    if antiCheatTimer >= 30 then
        antiCheatTimer = 0
        showScanNotification()
    end
end)

print("✨ Ngkooeeaa HUB Loaded Successfully!")
