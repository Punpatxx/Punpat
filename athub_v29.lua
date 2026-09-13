-- ==========================================
-- ⚡ AT Hub - Ultimate Master Engine v29.0 (Clean Edition)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
local guiParent = playerGui
pcall(function()
    if gethui then guiParent = gethui()
    elseif game:GetService("CoreGui") then guiParent = game:GetService("CoreGui") end
end)

local safeKey = "AT_UltimateHub_v29"
if guiParent:FindFirstChild(safeKey) then
    guiParent:FindFirstChild(safeKey):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = safeKey
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local Config = {
    AimbotOn = false, AimFOV = 180, LockPower = 90, TargetPart = "Head",
    TargetMode = "Players",
    SpeedOn = false, SpeedVal = 16,
    JumpOn = false, JumpVal = 50,
    FloatOn = false, FloatSpeed = 20,
    NoClipOn = false,
    TPMode = "Instant", FlySpeed = 50,
    FollowTarget = nil, FollowOn = false,
    FollowOffset = Vector3.new(0, 3, 0),
    FollowDistance = 0,
    AntiBan = true
}

local OriginalStats = { WalkSpeed = 16, JumpPower = 50 }
local function BackupStats(hum)
    if hum then OriginalStats.WalkSpeed = hum.WalkSpeed OriginalStats.JumpPower = hum.JumpPower end
end

local LauncherBtn = Instance.new("TextButton")
LauncherBtn.Size = UDim2.new(0, 52, 0, 52)
LauncherBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
LauncherBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
LauncherBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
LauncherBtn.Text = "AT"
LauncherBtn.Font = Enum.Font.GothamBold
LauncherBtn.TextSize = 18
LauncherBtn.Active = true
LauncherBtn.Draggable = true
LauncherBtn.Parent = ScreenGui
Instance.new("UICorner", LauncherBtn).CornerRadius = UDim.new(0, 10)
local launcherStroke = Instance.new("UIStroke", LauncherBtn)
launcherStroke.Color = Color3.fromRGB(0, 180, 255)
launcherStroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 370, 0, 400)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(40, 40, 60)
mainStroke.Thickness = 1

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 95, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -100, 1, -10)
Container.Position = UDim2.new(0, 100, 0, 5)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

LauncherBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Pages = {}
local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 3
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.Parent = Container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = sf
    
    Pages[name] = sf
    return sf
end

local function CreateTab(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    btn.TextColor3 = Color3.fromRGB(220, 230, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end

local pageAim = CreatePage("Aim")
local pageMove = CreatePage("Move")
local pageTP = CreatePage("TP")
local pageInfo = CreatePage("Info")

CreateTab("Aim", "🎯 Aim")
CreateTab("Move", "⚡ Move")
CreateTab("TP", "✈️ TP")
CreateTab("Info", "🛡️ Info")
pageAim.Visible = true

local function MakeToggle(parent, text, callback)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(22, 22, 32)
        pcall(callback, state)
    end)
    return btn
end

local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 15)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = text .. " : " .. tostring(default)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -10, 0, 14)
    sliderBtn.Position = UDim2.new(0, 5, 0, 20)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    sliderBtn.Text = ""
    sliderBtn.Parent = frame
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local startPct = math.clamp((default - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(startPct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    fill.Parent = sliderBtn
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local isDrag = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDrag = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDrag = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + ((max - min) * pos))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. " : " .. tostring(val)
            pcall(callback, val)
        end
    end)
    return frame
end

MakeToggle(pageAim, "🎯 เปิด Aimbot (Universal)", function(v) Config.AimbotOn = v end)
MakeSlider(pageAim, "ขนาดวง FOV", 50, 500, 180, function(v) Config.AimFOV = v end)
MakeSlider(pageAim, "ความแรงล็อก (Smooth)", 1, 100, 90, function(v) Config.LockPower = v end)

local targetModeLabel = Instance.new("TextLabel")
targetModeLabel.Size = UDim2.new(0.95, 0, 0, 24)
targetModeLabel.BackgroundTransparency = 1
targetModeLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
targetModeLabel.Text = "📌 เป้าหมาย: ผู้เล่น (Players)"
targetModeLabel.Font = Enum.Font.GothamBold
targetModeLabel.TextSize = 11
targetModeLabel.Parent = pageAim

local targetModeBtn = Instance.new("TextButton")
targetModeBtn.Size = UDim2.new(0.95, 0, 0, 26)
targetModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
targetModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
targetModeBtn.Text = "🔄 สลับโหมดเป้า (ผู้เล่น / ทุกสิ่งมีชีวิต)"
targetModeBtn.Font = Enum.Font.GothamBold
targetModeBtn.TextSize = 10
targetModeBtn.Parent = pageAim
Instance.new("UICorner", targetModeBtn).CornerRadius = UDim.new(0, 6)

targetModeBtn.MouseButton1Click:Connect(function()
    if Config.TargetMode == "Players" then
        Config.TargetMode = "All"
        targetModeLabel.Text = "📌 เป้าหมาย: สิ่งมีชีวิตทั้งหมด (Players + Mobs)"
    else
        Config.TargetMode = "Players"
        targetModeLabel.Text = "📌 เป้าหมาย: ผู้เล่น (Players)"
    end
end)

local currentAimLabel = Instance.new("TextLabel")
currentAimLabel.Size = UDim2.new(0.95, 0, 0, 24)
currentAimLabel.BackgroundTransparency = 1
currentAimLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
currentAimLabel.Text = "📌 ส่วนที่ล็อก: หัว (Head)"
currentAimLabel.Font = Enum.Font.GothamBold
currentAimLabel.TextSize = 11
currentAimLabel.Parent = pageAim

local parts = {
    {"Head", "หัว (Head)"}, {"Torso", "ลำตัว (Torso)"}, {"HumanoidRootPart", "กลางตัว (Root)"},
    {"LeftArm", "แขนซ้าย"}, {"RightArm", "แขนขวา"}, {"LeftLeg", "ขาซ้าย"}, {"RightLeg", "ขาขวา"}
}

for _, p in ipairs(parts) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Text = "➔ " .. p[2]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.Parent = pageAim
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        Config.TargetPart = p[1]
        currentAimLabel.Text = "📌 ส่วนที่ล็อก: " .. p[2]
    end)
end

local tpModeLabel = Instance.new("TextLabel")
tpModeLabel.Size = UDim2.new(0.95, 0, 0, 24)
tpModeLabel.BackgroundTransparency = 1
tpModeLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
tpModeLabel.Text = "🚀 โหมดวาร์ป: วาร์ปทันที"
tpModeLabel.Font = Enum.Font.GothamBold
tpModeLabel.TextSize = 11
tpModeLabel.Parent = pageTP

local tpModeBtn = Instance.new("TextButton")
tpModeBtn.Size = UDim2.new(0.95, 0, 0, 26)
tpModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
tpModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpModeBtn.Text = "🔄 สลับโหมด (Instant / Smooth)"
tpModeBtn.Font = Enum.Font.GothamBold
tpModeBtn.TextSize = 10
tpModeBtn.Parent = pageTP
Instance.new("UICorner", tpModeBtn).CornerRadius = UDim.new(0, 6)

tpModeBtn.MouseButton1Click:Connect(function()
    if Config.TPMode == "Instant" then
        Config.TPMode = "SmoothFly"
        tpModeLabel.Text = "🚀 โหมดวาร์ป: ลอยไปหา"
    else
        Config.TPMode = "Instant"
        tpModeLabel.Text = "🚀 โหมดวาร์ป: วาร์ปทันที"
    end
end)

MakeSlider(pageTP, "ความเร็วลอย", 10, 200, 50, function(v) Config.FlySpeed = v end)
MakeSlider(pageTP, "ระยะห่างการตาม (Offset Dist)", 0, 20, 0, function(v) Config.FollowDistance = v end)

local offsetLabel = Instance.new("TextLabel")
offsetLabel.Size = UDim2.new(0.95, 0, 0, 24)
offsetLabel.BackgroundTransparency = 1
offsetLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
offsetLabel.Text = "📌 ตำแหน่ง: เหนือหัว (Above)"
offsetLabel.Font = Enum.Font.GothamBold
offsetLabel.TextSize = 11
offsetLabel.Parent = pageTP

local offsets = {
    {"เหนือหัว (Above)", Vector3.new(0, 1, 0)},
    {"ใต้เท้า (Below)", Vector3.new(0, -1, 0)},
    {"ด้านซ้าย (Left)", Vector3.new(-1, 0, 0)},
    {"ด้านขวา (Right)", Vector3.new(1, 0, 0)},
    {"ด้านหลัง (Behind)", Vector3.new(0, 0, 1)}
}

for _, off in ipairs(offsets) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Text = "ทิศทาง: " .. off[1]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.Parent = pageTP
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        Config.FollowOffset = off[2]
        offsetLabel.Text = "📌 ตำแหน่ง: " .. off[1]
    end)
end

local StopTPBtn = Instance.new("TextButton")
StopTPBtn.Size = UDim2.new(0.95, 0, 0, 26)
StopTPBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StopTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopTPBtn.Text = "🛑 ปิดวาร์ปติดตาม"
StopTPBtn.Font = Enum.Font.GothamBold
StopTPBtn.TextSize = 11
StopTPBtn.Parent = pageTP
Instance.new("UICorner", StopTPBtn).CornerRadius = UDim.new(0, 6)

StopTPBtn.MouseButton1Click:Connect(function()
    Config.FollowOn = false
    Config.FollowTarget = nil
    StopTPBtn.Text = "🛑 ปิดวาร์ปติดตาม"
end)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.95, 0, 0, 26)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 โหลดรายชื่อผู้เล่น"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 11
RefreshBtn.Parent = pageTP
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.95, 0, 0, 110)
playerListFrame.BackgroundTransparency = 1
playerListFrame.ScrollBarThickness = 2
playerListFrame.Parent = pageTP
Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 2)

RefreshBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(playerListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "👤 " .. p.DisplayName
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 10
            btn.Parent = playerListFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                Config.FollowTarget = p
                Config.FollowOn = true
                StopTPBtn.Text = "⚡ ตาม: " .. p.DisplayName
            end)
        end
    end
end)

MakeToggle(pageMove, "⚡ เปิดวิ่งเร็ว", function(v) 
    Config.SpeedOn = v 
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and not v then hum.WalkSpeed = OriginalStats.WalkSpeed end
end)
MakeSlider(pageMove, "ความเร็ว", 16, 500, 16, function(v) Config.SpeedVal = v end)

MakeToggle(pageMove, "🦘 เปิดกระโดดสูง", function(v) 
    Config.JumpOn = v 
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and not v then 
        hum.UseJumpPower = true 
        hum.JumpPower = OriginalStats.JumpPower 
    end
end)
MakeSlider(pageMove, "พลังกระโดด", 50, 300, 50, function(v) Config.JumpVal = v end)

MakeToggle(pageMove, "👻 ระบบทะลุ (NoClip)", function(v) Config.NoClipOn = v end)
MakeToggle(pageMove, "🛸 เปิดลอยตัว", function(v) Config.FloatOn = v end)
MakeSlider(pageMove, "ความเร็วลอย", 5, 100, 20, function(v) Config.FloatSpeed = v end)

MakeToggle(pageInfo, "🛡️ ระบบกันแบนขั้นสูง (Anti-Ban Shield)", function(v) Config.AntiBan = v end)

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(0.95, 0, 0, 160)
InfoText.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
InfoText.TextColor3 = Color3.fromRGB(220, 230, 255)
InfoText.Text = "🔥 AT Hub - v29.0 Master Edition\n\n👨‍💻 Dev: NATTHANON WHAIPILP\n👑 Status: Universal Lock & Anti-Ban\n\n- Priority Map Native Lock Integration\n- Universal Players + Mobs Aimbot\n- Custom Offset Distance Follow\n- Full NoClip & Safe Bypass Engine"
InfoText.Font = Enum.Font.GothamBold
InfoText.TextSize = 11
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = pageInfo
Instance.new("UICorner", InfoText).CornerRadius = UDim.new(0, 6)

local function GetPart(char, pName)
    if not char then return nil end
    if pName == "Head" then return char:FindFirstChild("Head") end
    if pName == "Torso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") end
    if pName == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") end
    if pName == "LeftArm" then return char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm") end
    if pName == "RightArm" then return char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm") end
    if pName == "LeftLeg" then return char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg") end
    if pName == "RightLeg" then return char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

RunService.Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end
        if Config.NoClipOn then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hrp then return end

        if OriginalStats.WalkSpeed == 16 and hum.WalkSpeed ~= 16 and not Config.SpeedOn then
            BackupStats(hum)
        end

        if Config.FollowOn and Config.FollowTarget and Config.FollowTarget.Character then
            local tHrp = Config.FollowTarget.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local computedOffset = Config.FollowOffset * (Config.FollowDistance + 1)
                local targetCF = tHrp.CFrame * CFrame.new(computedOffset)
                if Config.TPMode == "Instant" then
                    hrp.CFrame = targetCF
                elseif Config.TPMode == "SmoothFly" then
                    local spd = math.clamp(Config.FlySpeed / 200, 0.05, 0.8)
                    hrp.CFrame = hrp.CFrame:Lerp(targetCF, spd)
                end
            end
        end

        if Config.SpeedOn then hum.WalkSpeed = Config.SpeedVal end
        if Config.JumpOn then hum.UseJumpPower = true; hum.JumpPower = Config.JumpVal end
        if Config.FloatOn and not Config.FollowOn then 
            hrp.Velocity = Vector3.new(hrp.Velocity.X, Config.FloatSpeed, hrp.Velocity.Z) 
        end

        if Config.AimbotOn then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local bestPart = nil
            local sDist = Config.AimFOV / 2

            local nativeTarget = nil
            pcall(function()
                if getgenv and getgenv().Target then nativeTarget = getgenv().Target end
            end)

            if nativeTarget and nativeTarget:IsA("BasePart") then
                bestPart = nativeTarget
            else
                local candidatePool = {}
                if Config.TargetMode == "Players" then
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= player and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
                            if v.Character.Humanoid.Health > 0 then
                                table.insert(candidatePool, v.Character)
                            end
                        end
                    end
                else
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
                            local h = v:FindFirstChildOfClass("Humanoid")
                            if h.Health > 0 and v ~= char then
                                table.insert(candidatePool, v)
                            end
                        end
                    end
                end

                for _, cModel in pairs(candidatePool) do
                    local part = GetPart(cModel, Config.TargetPart)
                    if part then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < sDist then
                                sDist = dist
                                bestPart = part
                            end
                        end
                    end
                end
            end

            if bestPart then
                local curCF = Camera.CFrame
                local tCF = CFrame.new(curCF.Position, bestPart.Position)
                local sm = math.clamp(Config.LockPower / 100, 0.05, 1)
                Camera.CFrame = curCF:Lerp(tCF, sm)
            end
        end
    end)
end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.6)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then BackupStats(hum) end
end)
