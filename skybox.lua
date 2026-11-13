local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local isFlying = false
local isEspEnabled = false
local flySpeed = 50
local flyConn = nil
local currentSkyType = "default"

local espBoxes, espNames, espHealthBg, espHealthBars, espDistances = {}, {}, {}, {}, {}

-- 1. Tạo ScreenGui chính (IgnoreGuiInset để không bị ẩn khi mở ESC menu)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FixedAvatarFlyMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or playerGui

-- 2. Nút mở/đóng Menu HÌNH TRÒN (Avatar ID)
local toggleButton = Instance.new("ImageButton", screenGui)
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 50, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleButton.Image = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 2

-- 3. Khung Menu chính
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 310, 0, 350)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BackgroundTransparency = 0.1
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 1.5

local bgImage = Instance.new("ImageLabel", mainFrame)
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxthumb://type=Asset&id=83459479787234&w=150&h=150"
bgImage.ImageTransparency = 0.65
bgImage.ScaleType = Enum.ScaleType.Stretch

local titleBar = Instance.new("TextButton", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
titleBar.BackgroundTransparency = 0.4
titleBar.Text = "   AVATAR MULTI-TOOL MENU"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 13
titleBar.Font = Enum.Font.GothamBold
titleBar.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

-- Kéo thả Menu
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
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

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Thanh chuyển Tab
local tabMainBtn = Instance.new("TextButton", mainFrame)
tabMainBtn.Size = UDim2.new(0, 96, 0, 30)
tabMainBtn.Position = UDim2.new(0, 5, 0, 45)
tabMainBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
tabMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabMainBtn.Text = "MAIN"
tabMainBtn.TextSize = 10
tabMainBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", tabMainBtn).CornerRadius = UDim.new(0, 6)

local tabSkyBtn = Instance.new("TextButton", mainFrame)
tabSkyBtn.Size = UDim2.new(0, 96, 0, 30)
tabSkyBtn.Position = UDim2.new(0, 105, 0, 45)
tabSkyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabSkyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
tabSkyBtn.Text = "SKY"
tabSkyBtn.TextSize = 10
tabSkyBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", tabSkyBtn).CornerRadius = UDim.new(0, 6)

local tabGfxBtn = Instance.new("TextButton", mainFrame)
tabGfxBtn.Size = UDim2.new(0, 96, 0, 30)
tabGfxBtn.Position = UDim2.new(0, 205, 0, 45)
tabGfxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabGfxBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
tabGfxBtn.Text = "GRAPHICS"
tabGfxBtn.TextSize = 10
tabGfxBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", tabGfxBtn).CornerRadius = UDim.new(0, 6)

local mainContainer = Instance.new("Frame", mainFrame)
mainContainer.Size = UDim2.new(1, 0, 1, -80)
mainContainer.Position = UDim2.new(0, 0, 0, 80)
mainContainer.BackgroundTransparency = 1

local skyContainer = Instance.new("Frame", mainFrame)
skyContainer.Size = UDim2.new(1, 0, 1, -80)
skyContainer.Position = UDim2.new(0, 0, 0, 80)
skyContainer.BackgroundTransparency = 1
skyContainer.Visible = false

local gfxContainer = Instance.new("Frame", mainFrame)
gfxContainer.Size = UDim2.new(1, 0, 1, -80)
gfxContainer.Position = UDim2.new(0, 0, 0, 80)
gfxContainer.BackgroundTransparency = 1
gfxContainer.Visible = false

tabMainBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible, skyContainer.Visible, gfxContainer.Visible = true, false, false
    tabMainBtn.BackgroundColor3, tabMainBtn.TextColor3 = Color3.fromRGB(50, 120, 220), Color3.fromRGB(255, 255, 255)
    tabSkyBtn.BackgroundColor3, tabSkyBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
    tabGfxBtn.BackgroundColor3, tabGfxBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
end)

tabSkyBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible, skyContainer.Visible, gfxContainer.Visible = false, true, false
    tabMainBtn.BackgroundColor3, tabMainBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
    tabSkyBtn.BackgroundColor3, tabSkyBtn.TextColor3 = Color3.fromRGB(50, 120, 220), Color3.fromRGB(255, 255, 255)
    tabGfxBtn.BackgroundColor3, tabGfxBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
end)

tabGfxBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible, skyContainer.Visible, gfxContainer.Visible = false, false, true
    tabMainBtn.BackgroundColor3, tabMainBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
    tabSkyBtn.BackgroundColor3, tabSkyBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200)
    tabGfxBtn.BackgroundColor3, tabGfxBtn.TextColor3 = Color3.fromRGB(50, 120, 220), Color3.fromRGB(255, 255, 255)
end)

-- ================= TAB MAIN =================
local flyBtn = Instance.new("TextButton", mainContainer)
flyBtn.Size = UDim2.new(0, 260, 0, 32)
flyBtn.Position = UDim2.new(0.5, -130, 0, 5)
flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
flyBtn.BackgroundTransparency = 0.2
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Text = "FLY (PHÍM T): TẮT"
flyBtn.TextSize = 12
flyBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 8)

local espButton = Instance.new("TextButton", mainContainer)
espButton.Size = UDim2.new(0, 260, 0, 32)
espButton.Position = UDim2.new(0.5, -130, 0, 42)
espButton.BackgroundColor3 = Color3.fromRGB(150, 50, 180)
espButton.BackgroundTransparency = 0.2
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "ESP 2D + MÁU: TẮT"
espButton.TextSize = 12
espButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", mainContainer)
statusLabel.Size = UDim2.new(0, 260, 0, 22)
statusLabel.Position = UDim2.new(0.5, -130, 0, 80)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Tốc độ Fly: " .. flySpeed
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham

local subBtn = Instance.new("TextButton", mainContainer)
subBtn.Size = UDim2.new(0, 122, 0, 28)
subBtn.Position = UDim2.new(0.5, -130, 0, 105)
subBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
subBtn.BackgroundTransparency = 0.2
subBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
subBtn.Text = "GIẢM (-50)"
subBtn.TextSize = 11
subBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", subBtn).CornerRadius = UDim.new(0, 6)

local addBtn = Instance.new("TextButton", mainContainer)
addBtn.Size = UDim2.new(0, 122, 0, 28)
addBtn.Position = UDim2.new(0.5, 8, 0, 105)
addBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
addBtn.BackgroundTransparency = 0.2
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Text = "TĂNG (+50)"
addBtn.TextSize = 11
addBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", mainContainer)
closeBtn.Size = UDim2.new(0, 260, 0, 30)
closeBtn.Position = UDim2.new(0.5, -130, 0, 140)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
closeBtn.BackgroundTransparency = 0.3
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "ĐÓNG MENU"
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- ================= TAB SKY =================
local sky1Btn = Instance.new("TextButton", skyContainer)
sky1Btn.Size = UDim2.new(0, 260, 0, 35)
sky1Btn.Position = UDim2.new(0.5, -130, 0, 15)
sky1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 80)
sky1Btn.BackgroundTransparency = 0.2
sky1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
sky1Btn.Text = "🌙 STARRY NIGHT (ĐÊM SAO SÁNG)"
sky1Btn.TextSize = 11
sky1Btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", sky1Btn).CornerRadius = UDim.new(0, 8)

local sky2Btn = Instance.new("TextButton", skyContainer)
sky2Btn.Size = UDim2.new(0, 260, 0, 35)
sky2Btn.Position = UDim2.new(0.5, -130, 0, 60)
sky2Btn.BackgroundColor3 = Color3.fromRGB(220, 110, 80)
sky2Btn.BackgroundTransparency = 0.2
sky2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
sky2Btn.Text = "🌅 ANIME SUNSET (HOÀNG HÔN ẤM ÁP)"
sky2Btn.TextSize = 11
sky2Btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", sky2Btn).CornerRadius = UDim.new(0, 8)

local sky3Btn = Instance.new("TextButton", skyContainer)
sky3Btn.Size = UDim2.new(0, 260, 0, 35)
sky3Btn.Position = UDim2.new(0.5, -130, 0, 105)
sky3Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
sky3Btn.BackgroundTransparency = 0.2
sky3Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
sky3Btn.Text = "☀️ DEFAULT (MẶC ĐỊNH)"
sky3Btn.TextSize = 11
sky3Btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", sky3Btn).CornerRadius = UDim.new(0, 8)

-- ================= TAB GRAPHICS (FIX LAG) =================
local fixLagBtn = Instance.new("TextButton", gfxContainer)
fixLagBtn.Size = UDim2.new(0, 260, 0, 45)
fixLagBtn.Position = UDim2.new(0.5, -130, 0, 20)
fixLagBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
fixLagBtn.BackgroundTransparency = 0.2
fixLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fixLagBtn.Text = "⚡ CHẠY FIX LAG TỐI ƯU"
fixLagBtn.TextSize = 11
fixLagBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", fixLagBtn).CornerRadius = UDim.new(0, 8)

local gfxInfoLabel = Instance.new("TextLabel", gfxContainer)
gfxInfoLabel.Size = UDim2.new(0, 260, 0, 60)
gfxInfoLabel.Position = UDim2.new(0.5, -130, 0, 75)
gfxInfoLabel.BackgroundTransparency = 1
gfxInfoLabel.Text = "Tắt Texture, Particle, Hiệu ứng và đổi Part sang SmoothPlastic giúp máy yếu chạy mượt không giật lag."
gfxInfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
gfxInfoLabel.TextSize = 11
gfxInfoLabel.Font = Enum.Font.Gotham
gfxInfoLabel.TextWrapped = true

local function applyNewFixLag()
    fixLagBtn.Text = "ĐANG TỐI ƯU..."
    task.spawn(function()
        local ToDisable = {
            Textures = true,
            VisualEffects = true,
            Parts = true,
            Particles = true,
            Sky = true
        }

        local Stuff = {}

        for _, v in next, game:GetDescendants() do
            local skip = false
            if v.Name == "CustomSky" then
                skip = true
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and v:IsDescendantOf(p.Character) then
                    skip = true
                    break
                end
            end

            if not skip then
                if ToDisable.Parts then
                    if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        table.insert(Stuff, 1, v)
                    end
                end
                
                if ToDisable.Particles then
                    if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                        v.Enabled = false
                        table.insert(Stuff, 1, v)
                    end
                end
                
                if ToDisable.VisualEffects then
                    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                        v.Enabled = false
                        table.insert(Stuff, 1, v)
                    end
                end
                
                if ToDisable.Textures then
                    if v:IsA("Decal") or v:IsA("Texture") then
                        v.Texture = ""
                        table.insert(Stuff, 1, v)
                    end
                end
                
                if ToDisable.Sky then
                    if v:IsA("Sky") then
                        v.Parent = nil
                        table.insert(Stuff, 1, v)
                    end
                end
            end
        end

        pcall(function()
            game:GetService("TestService"):Message("Effects Disabler Script : Successfully disabled "..#Stuff.." assets / effects.")
        end)

        fixLagBtn.Text = "ĐÃ XONG (" .. #Stuff .. " ASSETS)!"
        fixLagBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end)
end

fixLagBtn.MouseButton1Click:Connect(applyNewFixLag)

-- ================= LOGIC SKY =================
local function applySky(skyType, isRespawn)
    currentSkyType = skyType
    
    if not isRespawn then
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("SunRaysEffect") or child.Name == "AnimeSunsetCC" then 
                child:Destroy() 
            end
        end
    end

    if skyType == "starrynight" then
        if not Lighting:FindFirstChild("CustomSky") then
            local newSky = Instance.new("Sky", Lighting)
            newSky.Name = "CustomSky"
            newSky.SkyboxBk, newSky.SkyboxDn, newSky.SkyboxFt, newSky.SkyboxLf, newSky.SkyboxRt, newSky.SkyboxUp = "rbxassetid://159454286", "rbxassetid://159454296", "rbxassetid://159454293", "rbxassetid://159454284", "rbxassetid://159454288", "rbxassetid://159454300"
        end
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.8
        Lighting.Ambient = Color3.fromRGB(65, 65, 105)
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 120)
        Lighting.FogEnd = 100000
    elseif skyType == "animesunset" then
        if not Lighting:FindFirstChild("CustomSky") then
            local newSky = Instance.new("Sky", Lighting)
            newSky.Name = "CustomSky"
            newSky.SkyboxBk = "rbxassetid://600830600"
            newSky.SkyboxDn = "rbxassetid://600831331"
            newSky.SkyboxFt = "rbxassetid://600832039"
            newSky.SkyboxLf = "rbxassetid://600832775"
            newSky.SkyboxRt = "rbxassetid://600833662"
            newSky.SkyboxUp = "rbxassetid://600834379"
            newSky.SunAngularSize = 22
        end
        
        Lighting.ClockTime = 17.8
        Lighting.GeographicLatitude = 40
        Lighting.Brightness = 2.2
        
        Lighting.Ambient = Color3.fromRGB(135, 115, 110)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 120)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 205, 150)
        Lighting.ColorShift_Bottom = Color3.fromRGB(140, 95, 110)
        
        Lighting.FogEnd = 100000
        
        local cc = Lighting:FindFirstChild("AnimeSunsetCC") or Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "AnimeSunsetCC"
        cc.TintColor = Color3.fromRGB(255, 235, 215)
        cc.Saturation = 0.15
        cc.Contrast = 0.05
    else
        if Lighting:FindFirstChild("AnimeSunsetCC") then Lighting.AnimeSunsetCC:Destroy() end
        Lighting.FogEnd = 100000
        Lighting.ClockTime, Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient = 14, 2, Color3.fromRGB(128, 128, 128), Color3.fromRGB(128, 128, 128)
        Lighting.ColorShift_Top, Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)
    end
end

sky1Btn.MouseButton1Click:Connect(function() applySky("starrynight", false) end)
sky2Btn.MouseButton1Click:Connect(function() applySky("animesunset", false) end)
sky3Btn.MouseButton1Click:Connect(function() applySky("default", false) end)

-- ================= LOGIC FLY (ĐÃ BỎ NOCLIP) =================
local keys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function applyFlyPhysics()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    if flyConn then flyConn:Disconnect() end
    if hrp:FindFirstChild("CustomFlyAttachment") then hrp.CustomFlyAttachment:Destroy() end
    if hrp:FindFirstChild("CustomFlyAlign") then hrp.CustomFlyAlign:Destroy() end
    if hrp:FindFirstChild("CustomFlyVelocity") then hrp.CustomFlyVelocity:Destroy() end

    flyBtn.Text = "FLY (PHÍM T): BẬT"
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
        if not isFlying or not hrp.Parent then return end
        local moveDir = Vector3.zero
        local currentSpeed = flySpeed * (keys.Shift and 2 or 1)

        if keys.W then moveDir = moveDir + camera.CFrame.LookVector end
        if keys.S then moveDir = moveDir - camera.CFrame.LookVector end
        if keys.A then moveDir = moveDir - camera.CFrame.RightVector end
        if keys.D then moveDir = moveDir + camera.CFrame.RightVector end
        if keys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        
        lv.VectorVelocity = moveDir * currentSpeed
        align.CFrame = camera.CFrame
    end)
end

local function removeFlyPhysics()
    flyBtn.Text = "FLY (PHÍM T): TẮT"
    flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    if flyConn then flyConn:Disconnect() end
    
    local character = player.Character
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
    isFlying = not isFlying
    if isFlying then applyFlyPhysics() else removeFlyPhysics() end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

-- ================= LOGIC ESP 2D + MÁU + SỐ MÉT (DƯỚI CHÂN) =================
local function createEsp(plr)
    if espBoxes[plr] then return end
    
    local box = Drawing.new("Square")
    box.Visible, box.Color, box.Thickness, box.Filled, box.Transparency = false, Color3.fromRGB(255, 255, 255), 1, false, 1
    espBoxes[plr] = box

    local nameText = Drawing.new("Text")
    nameText.Visible, nameText.Color, nameText.Size, nameText.Center, nameText.Outline, nameText.OutlineColor, nameText.Font = false, Color3.fromRGB(255, 255, 255), 13, true, true, Color3.fromRGB(0, 0, 0), Drawing.Fonts.UI
    espNames[plr] = nameText

    local healthBg = Drawing.new("Square")
    healthBg.Visible, healthBg.Color, healthBg.Thickness, healthBg.Filled, healthBg.Transparency = false, Color3.fromRGB(0, 0, 0), 1, true, 1
    espHealthBg[plr] = healthBg

    local healthBar = Drawing.new("Square")
    healthBar.Visible, healthBar.Color, healthBar.Thickness, healthBar.Filled, healthBar.Transparency = false, Color3.fromRGB(0, 255, 0), 1, true, 1
    espHealthBars[plr] = healthBar

    local distText = Drawing.new("Text")
    distText.Visible, distText.Color, distText.Size, distText.Center, distText.Outline, distText.OutlineColor, distText.Font = false, Color3.fromRGB(255, 255, 255), 12, true, true, Color3.fromRGB(0, 0, 0), Drawing.Fonts.UI
    espDistances[plr] = distText
end

local function removeEsp(plr)
    if espBoxes[plr] then pcall(function() espBoxes[plr]:Remove() end) espBoxes[plr] = nil end
    if espNames[plr] then pcall(function() espNames[plr]:Remove() end) espNames[plr] = nil end
    if espHealthBg[plr] then pcall(function() espHealthBg[plr]:Remove() end) espHealthBg[plr] = nil end
    if espHealthBars[plr] then pcall(function() espHealthBars[plr]:Remove() end) espHealthBars[plr] = nil end
    if espDistances[plr] then pcall(function() espDistances[plr]:Remove() end) espDistances[plr] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= player then createEsp(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= player then createEsp(p) end end)
Players.PlayerRemoving:Connect(function(p) removeEsp(p) end)

local espConn = nil
local function toggleEsp()
    isEspEnabled = not isEspEnabled
    if isEspEnabled then
        espButton.Text = "ESP 2D + MÁU: BẬT"
        espButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        if espConn then espConn:Disconnect() end
        espConn = RunService.RenderStepped:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    local box, nameText, healthBg, healthBar, distText = espBoxes[p], espNames[p], espHealthBg[p], espHealthBars[p], espDistances[p]
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if box and nameText and healthBg and healthBar and distText then
                        if char and hrp and hum and hum.Health > 0 then
                            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                local dist = (camera.CFrame.Position - hrp.Position).Magnitude
                                local sizeX, sizeY = math.clamp(2000 / dist, 15, 300), math.clamp(3500 / dist, 20, 400)
                                local posX, posY = vector.X - sizeX / 2, vector.Y - sizeY / 2

                                box.Size, box.Position, box.Visible = Vector2.new(sizeX, sizeY), Vector2.new(posX, posY), true
                                nameText.Position, nameText.Text, nameText.Visible = Vector2.new(vector.X, posY - 18), p.Name, true

                                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                healthBg.Size, healthBg.Position, healthBg.Visible = Vector2.new(4, sizeY + 2), Vector2.new(posX - 7, posY - 1), true
                                healthBar.Size, healthBar.Position = Vector2.new(2, sizeY * healthPercent), Vector2.new(posX - 6, posY + (sizeY * (1 - healthPercent)))
                                healthBar.Color, healthBar.Visible = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0), true

                                distText.Position = Vector2.new(vector.X, posY + sizeY + 4)
                                distText.Text = math.floor(dist) .. "m"
                                distText.Visible = true
                            else
                                box.Visible, nameText.Visible, healthBg.Visible, healthBar.Visible, distText.Visible = false, false, false, false, false
                            end
                        else
                            box.Visible, nameText.Visible, healthBg.Visible, healthBar.Visible, distText.Visible = false, false, false, false, false
                        end
                    end
                end
            end
        end)
    else
        espButton.Text = "ESP 2D + MÁU: TẮT"
        espButton.BackgroundColor3 = Color3.fromRGB(150, 50, 180)
        if espConn then espConn:Disconnect() end
        for _, box in pairs(espBoxes) do box.Visible = false end
        for _, nameText in pairs(espNames) do nameText.Visible = false end
        for _, bg in pairs(espHealthBg) do bg.Visible = false end
        for _, bar in pairs(espHealthBars) do bar.Visible = false end
        for _, dt in pairs(espDistances) do dt.Visible = false end
    end
end
espButton.MouseButton1Click:Connect(toggleEsp)

player.CharacterAdded:Connect(function(newChar)
    task.spawn(function()
        newChar:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.1)
        if isFlying then applyFlyPhysics() end
        if currentSkyType ~= "default" then
            applySky(currentSkyType, true)
        end
    end)
end)

addBtn.MouseButton1Click:Connect(function()
    if flySpeed < 300 then flySpeed = math.min(300, flySpeed + 50) statusLabel.Text = "Tốc độ Fly: " .. flySpeed end
end)

subBtn.MouseButton1Click:Connect(function()
    if flySpeed > 50 then flySpeed = math.max(50, flySpeed - 50) statusLabel.Text = "Tốc độ Fly: " .. flySpeed end
end)

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.T and not gp then toggleFly() return end
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
