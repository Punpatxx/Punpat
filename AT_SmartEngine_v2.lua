-- ==========================================
-- ⚡ AT Hub - Smart Teleport & Auto Farm Engine v2.2
-- 👑 Persistent Respawn Edition (Auto-Recovery & Background Farm)
-- 👨‍💻 Developer: NATTHANON WHAIPILP
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local player = Players.LocalPlayer

local safeKey = "AT_SmartEngine_v22"
local isRunning = true

if _G.AT_SmartUnload then pcall(_G.AT_SmartUnload) end

local Connections = {}
local function TrackConnection(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end

-- ==========================================
-- ⚙️ CONFIG & STATE STORAGE
-- ==========================================
local Config = {
    ActiveMode = "None",
    TargetPlayer = nil,
    PlayerDir = "Above",
    PlayerDist = 5,
    PlayerSpeed = 50,
    MobScanRange = 50,
    MobSpeed = 50,
    MobDir = "Above",
    MobDist = 5,
    StickyAutoMobInstance = nil,
    StickyAutoMobName = nil,
    SelectedMobInstance = nil,
    SelectedMobName = nil,
    AutoAttackOn = false,
    SelectedTool = nil,
    AttackCooldown = 0.25,
    SpeedOn = false, SpeedVal = 16,
    JumpOn = false, JumpVal = 50,
    NoClipOn = false
}

local State = {
    OriginalSpeed = 16,
    OriginalJumpPower = 50,
    OriginalJumpHeight = 7.2,
    UseJumpPower = true,
    LastAttackTick = 0
}

local function GetHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function RestoreStats()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.WalkSpeed = State.OriginalSpeed
            hum.UseJumpPower = State.UseJumpPower
            if State.UseJumpPower then
                hum.JumpPower = State.OriginalJumpPower
            else
                hum.JumpHeight = State.OriginalJumpHeight
            end
        end)
    end
end

local function GetOffsetVector(dir, dist)
    if dir == "Above" then return Vector3.new(0, dist, 0)
    elseif dir == "Below" then return Vector3.new(0, -dist, 0)
    elseif dir == "Front" then return Vector3.new(0, 0, -dist)
    elseif dir == "Back" then return Vector3.new(0, 0, dist)
    elseif dir == "Left" then return Vector3.new(-dist, 0, 0)
    elseif dir == "Right" then return Vector3.new(dist, 0, 0)
    end
    return Vector3.new(0, dist, 0)
end

local function GetTargetCFrame(targetHrp, dir, dist)
    if not targetHrp then return nil end
    local targetPos = targetHrp.Position
    local localOffset = GetOffsetVector(dir, dist)
    local computedPos = (targetHrp.CFrame * CFrame.new(localOffset)).Position
    return CFrame.new(computedPos, targetPos)
end

-- ==========================================
-- 🎨 UI SYSTEM (Cyber Theme & Modern UI)
-- ==========================================
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = safeKey
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local LauncherBtn = Instance.new("TextButton")
LauncherBtn.Size = UDim2.new(0, 52, 0, 52)
LauncherBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
LauncherBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
LauncherBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
LauncherBtn.Text = "AT"
LauncherBtn.Font = Enum.Font.GothamBold
LauncherBtn.TextSize = 18
LauncherBtn.Active = true
LauncherBtn.Draggable = true
LauncherBtn.Parent = ScreenGui
Instance.new("UICorner", LauncherBtn).CornerRadius = UDim.new(0, 14)
local lStroke = Instance.new("UIStroke", LauncherBtn)
lStroke.Color = Color3.fromRGB(0, 180, 255)
lStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 430)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.Color = Color3.fromRGB(60, 60, 90)
mStroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TopStatus = Instance.new("TextLabel")
TopStatus.Size = UDim2.new(1, -15, 1, 0)
TopStatus.Position = UDim2.new(0, 15, 0, 0)
TopStatus.BackgroundTransparency = 1
TopStatus.TextColor3 = Color3.fromRGB(0, 255, 150)
TopStatus.Text = "⚡ AT SMART ENGINE v2.2 [RESPAWN SAFE]"
TopStatus.Font = Enum.Font.GothamBold
TopStatus.TextSize = 11
TopStatus.TextXAlignment = Enum.TextXAlignment.Left
TopStatus.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, -36)
Sidebar.Position = UDim2.new(0, 4, 0, 36)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -110, 1, -40)
Container.Position = UDim2.new(0, 106, 0, 38)
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
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = sf
    Pages[name] = sf
    return sf
end

local function CreateTab(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    btn.TextColor3 = Color3.fromRGB(200, 210, 240)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end

local pagePlayer = CreatePage("Player")
local pageMob = CreatePage("Mob")
local pageSpecificMob = CreatePage("SpecMob")
local pageTool = CreatePage("Tool")
local pageMove = CreatePage("Move")

CreateTab("Player", "👤 ผู้เล่น")
CreateTab("Mob", "👾 ออโต้ใกล้")
CreateTab("SpecMob", "🎯 เจาะจงมอน")
CreateTab("Tool", "⚔️ อาวุธ/ตี")
CreateTab("Move", "⚡ เคลื่อนที่")
pagePlayer.Visible = true

local function MakeSlider(parentPage, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    frame.Parent = parentPage
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 16)
    label.Position = UDim2.new(0, 6, 0, 3)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Text = text .. " : " .. tostring(default)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -12, 0, 12)
    sliderBtn.Position = UDim2.new(0, 6, 0, 22)
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
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = text .. " : " .. tostring(val)
        pcall(callback, val)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDrag = true; update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDrag = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

local playerToggleBtn = Instance.new("TextButton")
playerToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
playerToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
playerToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
playerToggleBtn.Text = "[OFF] วาร์ปตามผู้เล่น"
playerToggleBtn.Font = Enum.Font.GothamBold
playerToggleBtn.TextSize = 10
playerToggleBtn.Parent = pagePlayer
Instance.new("UICorner", playerToggleBtn).CornerRadius = UDim.new(0, 8)

local playerInfoLabel = Instance.new("TextLabel")
playerInfoLabel.Size = UDim2.new(0.95, 0, 0, 22)
playerInfoLabel.BackgroundTransparency = 1
playerInfoLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
playerInfoLabel.Text = "📌 ทิศ: เหนือหัว | ระยะ: 5 | เป้า: ยังไม่เลือก"
playerInfoLabel.Font = Enum.Font.GothamBold
playerInfoLabel.TextSize = 10
playerInfoLabel.Parent = pagePlayer

playerToggleBtn.MouseButton1Click:Connect(function()
    if Config.ActiveMode == "Player" then
        Config.ActiveMode = "None"
        playerToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
        playerToggleBtn.Text = "[OFF] วาร์ปตามผู้เล่น"
    else
        Config.ActiveMode = "Player"
        playerToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        playerToggleBtn.Text = "[ON] วาร์ปตามผู้เล่น"
    end
end)

MakeSlider(pagePlayer, "ระยะห่างจากผู้เล่น (Studs)", 1, 20, 5, function(v) Config.PlayerDist = v end)

local pDirs = {"Above", "Below", "Front", "Back", "Left", "Right"}
local pDirNames = {"เหนือหัว", "ใต้เท้า", "ด้านหน้า", "ด้านหลัง", "ด้านซ้าย", "ด้านขวา"}
for i, dir in ipairs(pDirs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Text = "➔ ทิศทาง: " .. pDirNames[i]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.Parent = pagePlayer
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        Config.PlayerDir = dir
        playerInfoLabel.Text = "📌 ทิศ: " .. pDirNames[i] .. " | ระยะ: " .. tostring(Config.PlayerDist)
    end)
end

local refreshPlrBtn = Instance.new("TextButton")
refreshPlrBtn.Size = UDim2.new(0.95, 0, 0, 28)
refreshPlrBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
refreshPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshPlrBtn.Text = "🔄 โหลดรายชื่อผู้เล่น"
refreshPlrBtn.Font = Enum.Font.GothamBold
refreshPlrBtn.TextSize = 10
refreshPlrBtn.Parent = pagePlayer
Instance.new("UICorner", refreshPlrBtn).CornerRadius = UDim.new(0, 8)

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.95, 0, 0, 90)
playerListFrame.BackgroundTransparency = 1
playerListFrame.ScrollBarThickness = 2
playerListFrame.Parent = pagePlayer
Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 2)

refreshPlrBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(playerListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "👤 " .. p.DisplayName
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 10
            btn.Parent = playerListFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                Config.TargetPlayer = p
                Config.ActiveMode = "Player"
                playerToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                playerToggleBtn.Text = "[ON] วาร์ปตามผู้เล่น"
                playerInfoLabel.Text = "📌 เป้าหมาย: " .. p.DisplayName
            end)
        end
    end
end)

local autoMobToggleBtn = Instance.new("TextButton")
autoMobToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
autoMobToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
autoMobToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
autoMobToggleBtn.Text = "[OFF] วาร์ปหามอนใกล้เคียง (ออโต้)"
autoMobToggleBtn.Font = Enum.Font.GothamBold
autoMobToggleBtn.TextSize = 10
autoMobToggleBtn.Parent = pageMob
Instance.new("UICorner", autoMobToggleBtn).CornerRadius = UDim.new(0, 8)

local mobStatusLabel = Instance.new("TextLabel")
mobStatusLabel.Size = UDim2.new(0.95, 0, 0, 22)
mobStatusLabel.BackgroundTransparency = 1
mobStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
mobStatusLabel.Text = "👾 สถานะ: พร้อมทำงาน"
mobStatusLabel.Font = Enum.Font.GothamBold
mobStatusLabel.TextSize = 10
mobStatusLabel.Parent = pageMob

autoMobToggleBtn.MouseButton1Click:Connect(function()
    if Config.ActiveMode == "AutoMob" then
        Config.ActiveMode = "None"
        autoMobToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
        autoMobToggleBtn.Text = "[OFF] วาร์ปหามอนใกล้เคียง (ออโต้)"
        Config.StickyAutoMobInstance = nil
        Config.StickyAutoMobName = nil
    else
        Config.ActiveMode = "AutoMob"
        autoMobToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        autoMobToggleBtn.Text = "[ON] วาร์ปหามอนใกล้เคียง (ออโต้)"
    end
end)

MakeSlider(pageMob, "ระยะห่างจากมอน (Studs)", 1, 20, 5, function(v) Config.MobDist = v end)

for i, dir in ipairs(pDirs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Text = "➔ ทิศทางเกาะมอน: " .. pDirNames[i]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.Parent = pageMob
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        Config.MobDir = dir
        mobStatusLabel.Text = "👾 ทิศเกาะมอน: " .. pDirNames[i]
    end)
end

MakeSlider(pageMob, "ระยะสแกนหามอน", 10, 200, 50, function(v) Config.MobScanRange = v end)
MakeSlider(pageMob, "ความเร็วบินหามอน", 10, 200, 50, function(v) Config.MobSpeed = v end)

local resetMobBtn = Instance.new("TextButton")
resetMobBtn.Size = UDim2.new(0.95, 0, 0, 28)
resetMobBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
resetMobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetMobBtn.Text = "🔄 รีเซ็ตแคชมอนสเตอร์ออโต้"
resetMobBtn.Font = Enum.Font.GothamBold
resetMobBtn.TextSize = 10
resetMobBtn.Parent = pageMob
Instance.new("UICorner", resetMobBtn).CornerRadius = UDim.new(0, 8)

resetMobBtn.MouseButton1Click:Connect(function()
    Config.StickyAutoMobInstance = nil
    Config.StickyAutoMobName = nil
    mobStatusLabel.Text = "👾 สถานะ: รีเซ็ตแคชเรียบร้อย"
end)

local specMobToggleBtn = Instance.new("TextButton")
specMobToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
specMobToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
specMobToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
specMobToggleBtn.Text = "[OFF] วาร์ปเจาะจงมอนที่เลือก"
specMobToggleBtn.Font = Enum.Font.GothamBold
specMobToggleBtn.TextSize = 10
specMobToggleBtn.Parent = pageSpecificMob
Instance.new("UICorner", specMobToggleBtn).CornerRadius = UDim.new(0, 8)

local specMobStatusLabel = Instance.new("TextLabel")
specMobStatusLabel.Size = UDim2.new(0.95, 0, 0, 22)
specMobStatusLabel.BackgroundTransparency = 1
specMobStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
specMobStatusLabel.Text = "🎯 เป้าหมาย: ยังไม่เลือก"
specMobStatusLabel.Font = Enum.Font.GothamBold
specMobStatusLabel.TextSize = 10
specMobStatusLabel.Parent = pageSpecificMob

specMobToggleBtn.MouseButton1Click:Connect(function()
    if Config.ActiveMode == "SpecificMob" then
        Config.ActiveMode = "None"
        specMobToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
        specMobToggleBtn.Text = "[OFF] วาร์ปเจาะจงมอนที่เลือก"
    else
        Config.ActiveMode = "SpecificMob"
        specMobToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        specMobToggleBtn.Text = "[ON] วาร์ปเจาะจงมอนที่เลือก"
    end
end)

local scanSpecMobBtn = Instance.new("TextButton")
scanSpecMobBtn.Size = UDim2.new(0.95, 0, 0, 28)
scanSpecMobBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
scanSpecMobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanSpecMobBtn.Text = "🔄 สแกนรายชื่อมอนใกล้ตัว"
scanSpecMobBtn.Font = Enum.Font.GothamBold
scanSpecMobBtn.TextSize = 10
scanSpecMobBtn.Parent = pageSpecificMob
Instance.new("UICorner", scanSpecMobBtn).CornerRadius = UDim.new(0, 8)

local specMobListFrame = Instance.new("ScrollingFrame")
specMobListFrame.Size = UDim2.new(0.95, 0, 0, 130)
specMobListFrame.BackgroundTransparency = 1
specMobListFrame.ScrollBarThickness = 2
specMobListFrame.Parent = pageSpecificMob
Instance.new("UIListLayout", specMobListFrame).Padding = UDim.new(0, 2)

scanSpecMobBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(specMobListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local char = player.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    local foundMobs = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= char and IsAlive(v) then
            if not Players:GetPlayerFromCharacter(v) then
                local mHrp = GetHRP(v)
                if mHrp and (hrp.Position - mHrp.Position).Magnitude <= 150 then
                    local exists = false
                    for _, name in ipairs(foundMobs) do if name == v.Name then exists = true break end end
                    if not exists then
                        table.insert(foundMobs, v.Name)
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 24)
                        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
                        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
                        btn.Text = "👾 " .. v.Name
                        btn.Font = Enum.Font.GothamSemibold
                        btn.TextSize = 10
                        btn.Parent = specMobListFrame
                        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                        btn.MouseButton1Click:Connect(function()
                            Config.SelectedMobName = v.Name
                            Config.SelectedMobInstance = v
                            Config.ActiveMode = "SpecificMob"
                            specMobToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                            specMobToggleBtn.Text = "[ON] วาร์ปเจาะจงมอนที่เลือก"
                            specMobStatusLabel.Text = "🎯 ล็อกเป้า: " .. v.Name
                        end)
                    end
                end
            end
        end
    end
end)

MakeSlider(pageTool, "ความเร็วตี (ms x 10)", 1, 10, 2, function(v) Config.AttackCooldown = v / 10 end)

local toolStatusLabel = Instance.new("TextLabel")
toolStatusLabel.Size = UDim2.new(0.95, 0, 0, 22)
toolStatusLabel.BackgroundTransparency = 1
toolStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
toolStatusLabel.Text = "❌ อาวุธปัจจุบัน: ยังไม่เลือก"
toolStatusLabel.Font = Enum.Font.GothamBold
toolStatusLabel.TextSize = 10
toolStatusLabel.Parent = pageTool

local autoAttackToggleBtn = Instance.new("TextButton")
autoAttackToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
autoAttackToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
autoAttackToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
autoAttackToggleBtn.Text = "[OFF] ระบบออโต้ตีมอนเบื้องหลัง"
autoAttackToggleBtn.Font = Enum.Font.GothamBold
autoAttackToggleBtn.TextSize = 10
autoAttackToggleBtn.Parent = pageTool
Instance.new("UICorner", autoAttackToggleBtn).CornerRadius = UDim.new(0, 8)

autoAttackToggleBtn.MouseButton1Click:Connect(function()
    Config.AutoAttackOn = not Config.AutoAttackOn
    autoAttackToggleBtn.BackgroundColor3 = Config.AutoAttackOn and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(24, 24, 36)
    autoAttackToggleBtn.Text = Config.AutoAttackOn and "[ON] ระบบออโต้ตีมอนเบื้องหลัง" or "[OFF] ระบบออโต้ตีมอนเบื้องหลัง"
end)

local scanToolBtn = Instance.new("TextButton")
scanToolBtn.Size = UDim2.new(0.95, 0, 0, 28)
scanToolBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
scanToolBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanToolBtn.Text = "☰ สแกนหาอาวุธในตัว"
scanToolBtn.Font = Enum.Font.GothamBold
scanToolBtn.TextSize = 10
scanToolBtn.Parent = pageTool
Instance.new("UICorner", scanToolBtn).CornerRadius = UDim.new(0, 8)

local toolListFrame = Instance.new("ScrollingFrame")
toolListFrame.Size = UDim2.new(0.95, 0, 0, 100)
toolListFrame.BackgroundTransparency = 1
toolListFrame.ScrollBarThickness = 2
toolListFrame.Parent = pageTool
Instance.new("UIListLayout", toolListFrame).Padding = UDim.new(0, 2)

scanToolBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(toolListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local foundTools = {}
    local bp, char = player:FindFirstChild("Backpack"), player.Character
    local function AddTools(p)
        if not p then return end
        for _, v in ipairs(p:GetChildren()) do if v:IsA("Tool") then table.insert(foundTools, v) end end
    end
    AddTools(bp) AddTools(char)

    for _, tool in ipairs(foundTools) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        btn.Text = "⚔️ " .. tool.Name
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 10
        btn.Parent = toolListFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            Config.SelectedTool = tool
            toolStatusLabel.Text = "✔️ ใช้งาน: " .. tool.Name
        end)
    end
end)

local speedToggleBtn = Instance.new("TextButton")
speedToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
speedToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
speedToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
speedToggleBtn.Text = "[OFF] วิ่งเร็ว"
speedToggleBtn.Font = Enum.Font.GothamBold
speedToggleBtn.TextSize = 10
speedToggleBtn.Parent = pageMove
Instance.new("UICorner", speedToggleBtn).CornerRadius = UDim.new(0, 8)
speedToggleBtn.MouseButton1Click:Connect(function()
    Config.SpeedOn = not Config.SpeedOn
    speedToggleBtn.BackgroundColor3 = Config.SpeedOn and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(24, 24, 36)
    speedToggleBtn.Text = Config.SpeedOn and "[ON] วิ่งเร็ว" or "[OFF] วิ่งเร็ว"
    if not Config.SpeedOn then RestoreStats() end
end)
MakeSlider(pageMove, "ความเร็วเดิน", 16, 300, 16, function(v) Config.SpeedVal = v end)

local jumpToggleBtn = Instance.new("TextButton")
jumpToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
jumpToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
jumpToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
jumpToggleBtn.Text = "[OFF] กระโดดสูง"
jumpToggleBtn.Font = Enum.Font.GothamBold
jumpToggleBtn.TextSize = 10
jumpToggleBtn.Parent = pageMove
Instance.new("UICorner", jumpToggleBtn).CornerRadius = UDim.new(0, 8)
jumpToggleBtn.MouseButton1Click:Connect(function()
    Config.JumpOn = not Config.JumpOn
    jumpToggleBtn.BackgroundColor3 = Config.JumpOn and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(24, 24, 36)
    jumpToggleBtn.Text = Config.JumpOn and "[ON] กระโดดสูง" or "[OFF] กระโดดสูง"
    if not Config.JumpOn then RestoreStats() end
end)
MakeSlider(pageMove, "พลังกระโดด", 50, 300, 50, function(v) Config.JumpVal = v end)

local noclipToggleBtn = Instance.new("TextButton")
noclipToggleBtn.Size = UDim2.new(0.95, 0, 0, 32)
noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
noclipToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
noclipToggleBtn.Text = "[OFF] ทะลุกำแพง (NoClip)"
noclipToggleBtn.Font = Enum.Font.GothamBold
noclipToggleBtn.TextSize = 10
noclipToggleBtn.Parent = pageMove
Instance.new("UICorner", noclipToggleBtn).CornerRadius = UDim.new(0, 8)
noclipToggleBtn.MouseButton1Click:Connect(function()
    Config.NoClipOn = not Config.NoClipOn
    noclipToggleBtn.BackgroundColor3 = Config.NoClipOn and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(24, 24, 36)
    noclipToggleBtn.Text = Config.NoClipOn and "[ON] ทะลุกำแพง (NoClip)" or "[OFF] ทะลุกำแพง (NoClip)"
end)

-- ==========================================
-- 🔄 RESPAWN RECOVERY LISTENER (ระบบเกิดใหม่แล้วลุยต่อ)
-- ==========================================
TrackConnection(player.CharacterAdded:Connect(function(newChar)
    if not isRunning then return end
    task.wait(0.8)
    pcall(function()
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then
            if Config.AutoAttackOn and Config.SelectedTool then
                local toolName = Config.SelectedTool.Name
                local backpack = player:FindFirstChild("Backpack")
                local targetTool = nil

                if backpack then
                    targetTool = backpack:FindFirstChild(toolName)
                end

                if not targetTool then
                    targetTool = player.Character:FindFirstChild(toolName)
                end

                if targetTool then
                    Config.SelectedTool = targetTool
                    hum:EquipTool(targetTool)
                end
            end
        end
    end)
end))

-- ==========================================
-- ⚙️ BACKGROUND EXECUTION LOOPS (Masterpiece Core)
-- ==========================================
TrackConnection(RunService.Stepped:Connect(function()
    if not isRunning then return end
    pcall(function()
        if Config.NoClipOn then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)
end))

TrackConnection(RunService.Heartbeat:Connect(function()
    if not isRunning then return end
    pcall(function()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = GetHRP(char)
        if not hrp or not IsAlive(char) then return end

        if hum then
            if Config.SpeedOn then hum.WalkSpeed = Config.SpeedVal end
            if Config.JumpOn then
                if hum.UseJumpPower then hum.JumpPower = Config.JumpVal else hum.JumpHeight = Config.JumpVal end
            end
        end

        -- Player
        if Config.ActiveMode == "Player" and Config.TargetPlayer then
            local tChar = Config.TargetPlayer.Character
            if IsAlive(tChar) then
                local tHrp = GetHRP(tChar)
                if tHrp then
                    local targetCF = GetTargetCFrame(tHrp, Config.PlayerDir, Config.PlayerDist)
                    if targetCF then hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.clamp(Config.PlayerSpeed / 100, 0.05, 0.8)) end
                end
            end
        end

        -- Auto Nearby Mob
        if Config.ActiveMode == "AutoMob" then
            local validTarget = false
            if Config.StickyAutoMobInstance and IsAlive(Config.StickyAutoMobInstance) then
                local mHrp = GetHRP(Config.StickyAutoMobInstance)
                if mHrp and (hrp.Position - mHrp.Position).Magnitude <= Config.MobScanRange * 3 then
                    validTarget = true
                    local targetCF = GetTargetCFrame(mHrp, Config.MobDir, Config.MobDist)
                    if targetCF then hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.clamp(Config.MobSpeed / 100, 0.05, 0.8)) end
                end
            end

            if not validTarget then
                local nearestDist = Config.MobScanRange
                local nearestModel = nil
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char and IsAlive(v) then
                        if not Players:GetPlayerFromCharacter(v) then
                            local mHrp = GetHRP(v)
                            if mHrp then
                                local dist = (hrp.Position - mHrp.Position).Magnitude
                                if Config.StickyAutoMobName == v.Name or not Config.StickyAutoMobName then
                                    if dist <= nearestDist then
                                        nearestDist = dist
                                        nearestModel = v
                                    end
                                end
                            end
                        end
                    end
                end

                if nearestModel then
                    Config.StickyAutoMobInstance = nearestModel
                    Config.StickyAutoMobName = nearestModel.Name
                    mobStatusLabel.Text = "👾 กำลังล็อก: " .. nearestModel.Name
                else
                    mobStatusLabel.Text = "👾 กำลังรอมอนเกิดใหม่..."
                end
            end
        end

        -- Specific Selected Mob + Respawn Recovery
        if Config.ActiveMode == "SpecificMob" then
            local validSpecTarget = false

            if Config.SelectedMobInstance and IsAlive(Config.SelectedMobInstance) then
                local mHrp = GetHRP(Config.SelectedMobInstance)
                if mHrp then
                    validSpecTarget = true
                    local targetCF = GetTargetCFrame(mHrp, Config.MobDir, Config.MobDist)
                    if targetCF then hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.clamp(Config.MobSpeed / 100, 0.05, 0.8)) end
                end
            end

            if not validSpecTarget and Config.SelectedMobName then
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == Config.SelectedMobName and IsAlive(v) then
                        local mHrp = GetHRP(v)
                        if mHrp then
                            Config.SelectedMobInstance = v
                            specMobStatusLabel.Text = "🎯 มอนเกิดแล้ว: " .. v.Name
                            break
                        end
                    end
                end

                if not Config.SelectedMobInstance or not IsAlive(Config.SelectedMobInstance) then
                    specMobStatusLabel.Text = "🎯 มอนตาย... รอมอนตัวเดิมเกิด..."
                end
            end
        end

        -- Smart Background Tool Execution
        if Config.AutoAttackOn and Config.SelectedTool then
            local tool = Config.SelectedTool
            if tool and tool.Parent then
                if tool.Parent ~= char then
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack and tool.Parent == backpack then
                        if hum then pcall(function() hum:EquipTool(tool) end) end
                    else
                        pcall(function() tool.Parent = char end)
                    end
                end

                if tick() - State.LastAttackTick >= Config.AttackCooldown then
                    State.LastAttackTick = tick()
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end)
end))

-- ==========================================
-- 🛑 UNLOAD SYSTEM
-- ==========================================
_G.AT_SmartUnload = function()
    isRunning = false
    for _, conn in ipairs(Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end
    Connections = {}
    RestoreStats()
    if ScreenGui then ScreenGui:Destroy() end
    _G.AT_SmartUnload = nil
end
