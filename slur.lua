-- ============================================
-- KEYBIND & ASSET CONFIG
-- ============================================
local LOCK_KEY = Enum.KeyCode.E
local NOCLIP_KEY = Enum.KeyCode.C
local ESP_KEY = Enum.KeyCode.X
local AUTOCLICK_KEY = Enum.KeyCode.Minus
local AVATAR_IMAGE_ID = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"

-- ============================================
-- MAIN CODE
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
local ROTATION_SPEED = 0.25

local currentTarget, isLocked, espActive, speedActive, jumpActive, noclipActive, flyActive, fullbrightActive, fixLagActive, autoClickActive = nil, false, false, false, false, false, false, false, false, false
local speedValue, jumpValue, flyValue = 16, 25, 50
local bodyGyro, bodyVel = nil, nil
local origBrightness, origClockTime, origGlobalShadows, origFogEnd = Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.FogEnd

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AppleCombinedMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0, 255, 200)
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

local toggleMenuBtn = Instance.new("ImageButton")
toggleMenuBtn.Name = "OpenMenuBtn"
toggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
toggleMenuBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
toggleMenuBtn.Image = AVATAR_IMAGE_ID
toggleMenuBtn.ScaleType = Enum.ScaleType.Crop
toggleMenuBtn.BorderSizePixel = 0
toggleMenuBtn.Active = true
toggleMenuBtn.Draggable = true
toggleMenuBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 255, 200)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleMenuBtn

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 720, 0, 210)
frame.Position = UDim2.new(0.15, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2.5
frameStroke.Color = Color3.fromRGB(0, 255, 200)
frameStroke.Parent = frame

local menuBgImage = Instance.new("ImageLabel")
menuBgImage.Name = "MenuBackground"
menuBgImage.Size = UDim2.new(1, 0, 1, 0)
menuBgImage.Position = UDim2.new(0, 0, 0, 0)
menuBgImage.BackgroundTransparency = 1
menuBgImage.Image = AVATAR_IMAGE_ID
menuBgImage.ImageTransparency = 0.55
menuBgImage.ScaleType = Enum.ScaleType.Crop
menuBgImage.ZIndex = 1
menuBgImage.Parent = frame

local titleBox = Instance.new("Frame")
titleBox.Size = UDim2.new(1, 0, 0, 52)
titleBox.BackgroundTransparency = 1
titleBox.ZIndex = 2
titleBox.Parent = frame

local title1 = Instance.new("TextLabel")
title1.Size = UDim2.new(1, 0, 0, 22)
title1.Position = UDim2.new(0, 0, 0, 6)
title1.Text = "SCRIPT BY"
title1.TextColor3 = Color3.fromRGB(200, 200, 220)
title1.BackgroundTransparency = 1
title1.Font = Enum.Font.GothamBold
title1.TextSize = 12
title1.ZIndex = 2
title1.Parent = titleBox

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, 0, 0, 22)
title2.Position = UDim2.new(0, 0, 0, 26)
title2.Text = "✨ NNO_OBVN ✨"
title2.TextColor3 = Color3.fromRGB(0, 255, 200)
title2.BackgroundTransparency = 1
title2.Font = Enum.Font.GothamBold
title2.TextSize = 16
title2.ZIndex = 2
title2.Parent = titleBox

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -18, 1, -62)
container.Position = UDim2.new(0, 9, 0, 54)
container.BackgroundTransparency = 1
container.ZIndex = 2
container.Parent = frame

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.158, 0, 0.30, 0)
grid.CellPadding = UDim2.new(0.008, 0, 0.025, 0)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = container

local COLOR_OFF_BG = Color3.fromRGB(28, 30, 42)
local COLOR_OFF_TXT = Color3.fromRGB(220, 220, 235)
local COLOR_ON_BG = Color3.fromRGB(0, 230, 135)
local COLOR_ON_TXT = Color3.fromRGB(10, 10, 15)

local function createCell(txt, ord, bg)
    local b = Instance.new("TextButton")
    b.Text = txt
    b.BackgroundColor3 = bg or COLOR_OFF_BG
    b.BackgroundTransparency = 0.25
    b.TextColor3 = COLOR_OFF_TXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.LayoutOrder = ord
    b.ZIndex = 3
    b.Parent = container
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(48, 52, 72)
    stroke.Thickness = 1.5
    stroke.Parent = b
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b
    return b, stroke
end

local flyToggleBtn, s1 = createCell("fly " .. flyValue .. "\n[OFF]", 1)
local speedToggleBtn, s2 = createCell("speed " .. speedValue .. "\n[OFF]", 2)
local jumpToggleBtn, s3 = createCell("jump " .. jumpValue .. "\n[OFF]", 3)
local fixLagBtn, s4 = createCell("fix lag\n[OFF]", 4)
local toggleEspBtn, s5 = createCell("esp\n[OFF] [X]", 5)
local lockStatusBtn, s6 = createCell("target " .. fovRadius .. "\n[OFF] [E]", 6)
local incFlyBtn = createCell("+", 7)
local incSpeedBtn = createCell("+", 8)
local incJumpBtn = createCell("+", 9)
local noclipToggleBtn, s10 = createCell("noclip\n[OFF] [C]", 10)
local autoClickBtn, s11 = createCell("auto click\n[OFF] [-]", 11)
local incFovBtn = createCell("+", 12)
local decFlyBtn = createCell("-", 13)
local decSpeedBtn = createCell("-", 14)
local decJumpBtn = createCell("-", 15)
local flyBtn2, s16 = createCell("fly\n[OFF]", 16)
local fullbrightToggleBtn, s17 = createCell("fullbright\n[OFF]", 17)
local decFovBtn = createCell("-", 18)

local function setBtnState(btn, stroke, active, txt)
    btn.BackgroundColor3 = active and COLOR_ON_BG or COLOR_OFF_BG
    btn.TextColor3 = active and COLOR_ON_TXT or COLOR_OFF_TXT
    stroke.Color = active and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(48, 52, 72)
    if txt then btn.Text = txt end
end

toggleMenuBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local function updateFovSize(n)
    fovRadius = math.clamp(n, 20, 400)
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    setBtnState(lockStatusBtn, s6, isLocked, "target " .. fovRadius .. "\n" .. (isLocked and "[ON]" or "[OFF]") .. " [E]")
end

decFovBtn.MouseButton1Click:Connect(function() updateFovSize(fovRadius - 10) end)
incFovBtn.MouseButton1Click:Connect(function() updateFovSize(fovRadius + 10) end)

-- FIX ESP 100% CHO TẤT CẢ NGƯỜI CHƠI
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

local function refreshAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            if p.Character then
                applyEsp(p)
                local h = p.Character:FindFirstChild("PlayerHighlight")
                if h then h.Enabled = espActive end
            end
        end
    end
end

local function toggleEsp()
    espActive = not espActive
    setBtnState(toggleEspBtn, s5, espActive, "esp\n" .. (espActive and "[ON]" or "[OFF]") .. " [X]")
    refreshAllESP()
end

toggleEspBtn.MouseButton1Click:Connect(toggleEsp)

local function toggleNoclip()
    noclipActive = not noclipActive
    setBtnState(noclipToggleBtn, s10, noclipActive, "noclip\n" .. (noclipActive and "[ON]" or "[OFF]") .. " [C]")
end

noclipToggleBtn.MouseButton1Click:Connect(toggleNoclip)

local function toggleAutoClick()
    autoClickActive = not autoClickActive
    setBtnState(autoClickBtn, s11, autoClickActive, "auto click\n" .. (autoClickActive and "[ON]" or "[OFF]") .. " [-]")
    if autoClickActive then
        task.spawn(function()
            while autoClickActive do
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.001)
            end
        end)
    end
end

autoClickBtn.MouseButton1Click:Connect(toggleAutoClick)

local function toggleFullbright()
    fullbrightActive = not fullbrightActive
    setBtnState(fullbrightToggleBtn, s17, fullbrightActive, "fullbright\n" .. (fullbrightActive and "[ON]" or "[OFF]"))
    if not fullbrightActive then
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClockTime
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.FogEnd = origFogEnd
    end
end

fullbrightToggleBtn.MouseButton1Click:Connect(toggleFullbright)

fixLagBtn.MouseButton1Click:Connect(function()
    fixLagActive = not fixLagActive
    setBtnState(fixLagBtn, s4, fixLagActive, "fix lag\n" .. (fixLagActive and "[ON]" or "[OFF]"))
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
        local t = Workspace:FindFirstChildOfClass("Terrain")
        if t then
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
        end
    end
end)

local function toggleFly()
    flyActive = not flyActive
    local st = flyActive and "[ON]" or "[OFF]"
    setBtnState(flyToggleBtn, s1, flyActive, "fly " .. flyValue .. "\n" .. st)
    setBtnState(flyBtn2, s16, flyActive, "fly\n" .. st)
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
end

flyToggleBtn.MouseButton1Click:Connect(toggleFly)
flyBtn2.MouseButton1Click:Connect(toggleFly)

decFlyBtn.MouseButton1Click:Connect(function()
    flyValue = math.clamp(flyValue - 10, 10, 500)
    flyToggleBtn.Text = "fly " .. flyValue .. "\n" .. (flyActive and "[ON]" or "[OFF]")
end)

incFlyBtn.MouseButton1Click:Connect(function()
    flyValue = math.clamp(flyValue + 10, 10, 500)
    flyToggleBtn.Text = "fly " .. flyValue .. "\n" .. (flyActive and "[ON]" or "[OFF]")
end)

for _, p in ipairs(Players:GetPlayers()) do applyEsp(p) end
Players.PlayerAdded:Connect(applyEsp)

local function updateStats()
    local c = localPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            if speedActive then h.WalkSpeed = speedValue end
            if jumpActive then
                if h.UseJumpPower then h.JumpPower = jumpValue else h.JumpHeight = (jumpValue * 0.14) end
            end
        end
        if noclipActive then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end

speedToggleBtn.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    setBtnState(speedToggleBtn, s2, speedActive, "speed " .. speedValue .. "\n" .. (speedActive and "[ON]" or "[OFF]"))
    if not speedActive then
        local c = localPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
    updateStats()
end)

decSpeedBtn.MouseButton1Click:Connect(function()
    speedValue = math.clamp(speedValue - 5, 16, 500)
    speedToggleBtn.Text = "speed " .. speedValue .. "\n" .. (speedActive and "[ON]" or "[OFF]")
    updateStats()
end)

incSpeedBtn.MouseButton1Click:Connect(function()
    speedValue = math.clamp(speedValue + 5, 16, 500)
    speedToggleBtn.Text = "speed " .. speedValue .. "\n" .. (speedActive and "[ON]" or "[OFF]")
    updateStats()
end)

jumpToggleBtn.MouseButton1Click:Connect(function()
    jumpActive = not jumpActive
    setBtnState(jumpToggleBtn, s3, jumpActive, "jump " .. jumpValue .. "\n" .. (jumpActive and "[ON]" or "[OFF]"))
    if not jumpActive then
        local c = localPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                if h.UseJumpPower then h.JumpPower = 50 else h.JumpHeight = 7 end
            end
        end
    end
    updateStats()
end)

decJumpBtn.MouseButton1Click:Connect(function()
    jumpValue = math.clamp(jumpValue - 5, 10, 500)
    jumpToggleBtn.Text = "jump " .. jumpValue .. "\n" .. (jumpActive and "[ON]" or "[OFF]")
    updateStats()
end)

incJumpBtn.MouseButton1Click:Connect(function()
    jumpValue = math.clamp(jumpValue + 5, 10, 500)
    jumpToggleBtn.Text = "jump " .. jumpValue .. "\n" .. (jumpActive and "[ON]" or "[OFF]")
    updateStats()
end)

-- FIX AIMBOT/LOCK CHUẨN XÁC THEO DANH SÁCH PLAYERS
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
                    if md <= sf then 
                        sf = md
                        cm = th 
                    end
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
    setBtnState(lockStatusBtn, s6, false, "target " .. fovRadius .. "\n[OFF] [E]")
end

local function enableLock()
    isLocked = true
    fovCircle.Visible = true
    setBtnState(lockStatusBtn, s6, true, "target " .. fovRadius .. "\n[ON] [E]")
    currentTarget = getTargetInFOV()
end

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == LOCK_KEY then
        if isLocked then disableLock() else enableLock() end
    elseif i.KeyCode == NOCLIP_KEY then
        toggleNoclip()
    elseif i.KeyCode == ESP_KEY then
        toggleEsp()
    elseif i.KeyCode == AUTOCLICK_KEY then
        toggleAutoClick()
    end
end)

lockStatusBtn.MouseButton1Click:Connect(function()
    if isLocked then disableLock() else enableLock() end
end)

RunService.Stepped:Connect(function()
    if noclipActive then
        local c = localPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end
end)

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.003) % 1
    local r = Color3.fromHSV(hue, 1, 1)
    frameStroke.Color = r
    toggleStroke.Color = r
    
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
                    h.OutlineColor = r 
                    h.Enabled = true
                else
                    applyEsp(p)
                end
            end
        end
    end
    
    updateStats()
    
    if flyActive and bodyGyro and bodyVel then
        local c = camera.CFrame
        bodyGyro.cframe = c
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + c.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - c.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - c.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + c.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then bodyVel.velocity = moveDir.Unit * flyValue else bodyVel.velocity = Vector3.zero end
    end
    
    if not isLocked then return end
    local c = localPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not h or h.Health <= 0 then disableLock(); return end
    
    if currentTarget and currentTarget.Parent then
        local th = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
        local sc = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local sp, os = camera:WorldToViewportPoint(currentTarget.Position)
        local sd = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
        if not th or th.Health <= 0 or not os or sd > fovRadius + 50 then currentTarget = nil end
    else
        currentTarget = nil
    end
    
    if not currentTarget then currentTarget = getTargetInFOV() end
    
    if currentTarget then
        local cc = camera.CFrame
        camera.CFrame = cc:Lerp(CFrame.lookAt(cc.Position, currentTarget.Position), ROTATION_SPEED)
        local tp = currentTarget.Position
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z)), ROTATION_SPEED)
    end
end)
