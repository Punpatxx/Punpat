-- ==========================================
-- ⚡ AT Hub - Ultimate Master Engine v33.2
-- 🔧 Ultimate Executor Protection Edition
-- 👨‍💻 Developer: NATTHANON WHAIPILP
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local player = Players.LocalPlayer

local safeKey = "AT_UltimateHub_v33"
local isRunning = true

-- ==========================================
-- 🧹 GLOBAL CLEANUP SYSTEM
-- ==========================================
if _G.ATHub_Unload then pcall(_G.ATHub_Unload) end

local Connections = {}
local function TrackConnection(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end

-- ==========================================
-- ⚙️ CONFIG & STATE MANAGEMENT
-- ==========================================
local Config = {
    AimbotOn = false, AimFOV = 180, LockPower = 90, TargetPart = "Head",
    TargetMode = "Players", TeamCheck = false, WallCheck = false,
    SpeedOn = false, SpeedVal = 16,
    JumpOn = false, JumpVal = 50,
    FloatOn = false, FloatSpeed = 20,
    NoClipOn = false,
    TPMode = "Instant", FlySpeed = 50,
    FollowTarget = nil, FollowOn = false,
    FollowOffset = CFrame.new(0, 3, 0), FollowDistance = 0,
    ProximityAuraOn = false, AuraRange = 15, AuraCooldown = 0.35,
    SelectedTool = nil, ToolStatus = "NONE",
    SafetyMode = true
}

local State = {
    OriginalSpeed = 16, OriginalJumpPower = 50,
    OriginalJumpHeight = 7.2, UseJumpPower = true,
    CachedMobs = {}, LastAuraTick = 0, RayParams = RaycastParams.new()
}

State.RayParams.FilterType = Enum.RaycastFilterType.Exclude

-- ==========================================
-- 🛡️ UTILITY FUNCTIONS
-- ==========================================
local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
end

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

local function BackupStats(hum)
    if not hum then return end
    State.OriginalSpeed = hum.WalkSpeed
    State.UseJumpPower = hum.UseJumpPower
    State.OriginalJumpPower = hum.JumpPower
    State.OriginalJumpHeight = hum.JumpHeight
    if player.Character then
        State.RayParams.FilterDescendantsInstances = {player.Character}
    end
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

local function IsVisible(targetPart, myChar)
    if not Config.WallCheck then return true end
    local cam = GetCamera()
    if not cam or not targetPart then return true end
    local origin = cam.CFrame.Position
    local dir = targetPart.Position - origin
    local result = Workspace:Raycast(origin, dir, State.RayParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- ==========================================
-- 🎨 UI CREATION
-- ==========================================
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
local guiParent = playerGui

pcall(function()
    if gethui then
        guiParent = gethui()
    elseif game:GetService("CoreGui") then
        guiParent = game:GetService("CoreGui")
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = safeKey
ScreenGui.ResetOnSpawn = false

local successParent = pcall(function()
    ScreenGui.Parent = guiParent
end)
if not successParent then
    ScreenGui.Parent = playerGui
end

local LauncherBtn = Instance.new("TextButton")
LauncherBtn.Size = UDim2.new(0, 48, 0, 48)
LauncherBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
LauncherBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
LauncherBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
LauncherBtn.Text = "AT"
LauncherBtn.Font = Enum.Font.GothamBold
LauncherBtn.TextSize = 16
LauncherBtn.Active = true
LauncherBtn.Draggable = true
LauncherBtn.Parent = ScreenGui
Instance.new("UICorner", LauncherBtn).CornerRadius = UDim.new(0, 10)
local launcherStroke = Instance.new("UIStroke", LauncherBtn)
launcherStroke.Color = Color3.fromRGB(0, 180, 255)
launcherStroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 400)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(40, 40, 60)
mainStroke.Thickness = 1

local TopStatus = Instance.new("TextLabel")
TopStatus.Size = UDim2.new(1, 0, 0, 20)
TopStatus.Position = UDim2.new(0, 0, 0, -25)
TopStatus.BackgroundTransparency = 1
TopStatus.TextColor3 = Color3.fromRGB(0, 255, 120)
TopStatus.Text = "● AT ENGINE V33.2 ACTIVE"
TopStatus.Font = Enum.Font.GothamBold
TopStatus.TextSize = 12
TopStatus.Parent = MainFrame

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
    sf.ScrollBarThickness = 2
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

local function MakeToggle(parent, text, callback, defaultState)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(22, 22, 32)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = (state and "[ON] " or "[OFF] ") .. text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(22, 22, 32)
        btn.Text = (state and "[ON] " or "[OFF] ") .. text
        pcall(callback, state)
    end)
    return btn
end

local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 16)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = text .. " : " .. tostring(default)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -12, 0, 14)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDrag = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDrag = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    return frame
end

-- ==========================================
-- 📚 UI PAGES & TABS
-- ==========================================
local pageAim = CreatePage("Aim")
local pageAura = CreatePage("Aura")
local pageMove = CreatePage("Move")
local pageTP = CreatePage("TP")
local pageInfo = CreatePage("Info")

CreateTab("Aim", "🎯 Aim")
CreateTab("Aura", "⚔️ Proximity")
CreateTab("Move", "⚡ Move")
CreateTab("TP", "✈️ TP")
CreateTab("Info", "🛡️ Info")
pageAim.Visible = true

-- ==========================================
-- 🎯 AIMBOT SYSTEM
-- ==========================================
MakeToggle(pageAim, "เปิด Aimbot", function(v) Config.AimbotOn = v end)
MakeToggle(pageAim, "🛡️ Team Check", function(v) Config.TeamCheck = v end)
MakeToggle(pageAim, "🧱 Wall Check", function(v) Config.WallCheck = v end)
MakeSlider(pageAim, "ขนาดวง FOV", 50, 500, 180, function(v) Config.AimFOV = v end)
MakeSlider(pageAim, "ความเนียน (Smooth)", 1, 100, 90, function(v) Config.LockPower = v end)

local targetModeBtn = Instance.new("TextButton")
targetModeBtn.Size = UDim2.new(0.95, 0, 0, 26)
targetModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
targetModeBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
targetModeBtn.Text = "📌 เป้า: ผู้เล่น (Players)"
targetModeBtn.Font = Enum.Font.GothamBold
targetModeBtn.TextSize = 10
targetModeBtn.Parent = pageAim
Instance.new("UICorner", targetModeBtn).CornerRadius = UDim.new(0, 6)

targetModeBtn.MouseButton1Click:Connect(function()
    Config.TargetMode = (Config.TargetMode == "Players") and "All" or "Players"
    targetModeBtn.Text = Config.TargetMode == "Players" and "📌 เป้า: ผู้เล่น (Players)" or "📌 เป้า: ผู้เล่น + มอนสเตอร์"
end)

local currentAimLabel = Instance.new("TextLabel")
currentAimLabel.Size = UDim2.new(0.95, 0, 0, 20)
currentAimLabel.BackgroundTransparency = 1
currentAimLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
currentAimLabel.Text = "📌 ล็อก: หัว (Head)"
currentAimLabel.Font = Enum.Font.GothamBold
currentAimLabel.TextSize = 11
currentAimLabel.Parent = pageAim

local parts = {
    {"Head", "หัว (Head)"},
    {"HumanoidRootPart", "กลางตัว (Root)"},
    {"Torso", "ลำตัว (Torso)"}
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
        currentAimLabel.Text = "📌 ล็อก: " .. p[2]
    end)
end

-- ==========================================
-- ⚔️ PROXIMITY AURA & SCANNER
-- ==========================================
MakeToggle(pageAura, "เปิด Proximity Strike", function(v) Config.ProximityAuraOn = v end)
MakeSlider(pageAura, "ระยะโจมตี", 5, 50, 15, function(v) Config.AuraRange = v end)
MakeSlider(pageAura, "ดีเลย์ตี (ms x 10)", 1, 10, 3, function(v) Config.AuraCooldown = v / 10 end)

local selectedToolLabel = Instance.new("TextLabel")
selectedToolLabel.Size = UDim2.new(0.95, 0, 0, 26)
selectedToolLabel.BackgroundTransparency = 1
selectedToolLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
selectedToolLabel.Text = "❌ อาวุธปัจจุบัน: ยังไม่เลือก"
selectedToolLabel.Font = Enum.Font.GothamBold
selectedToolLabel.TextSize = 11
selectedToolLabel.Parent = pageAura

local scanToolBtn = Instance.new("TextButton")
scanToolBtn.Size = UDim2.new(0.95, 0, 0, 28)
scanToolBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
scanToolBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanToolBtn.Text = "☰ สแกนหาอาวุธ"
scanToolBtn.Font = Enum.Font.GothamBold
scanToolBtn.TextSize = 11
scanToolBtn.Parent = pageAura
Instance.new("UICorner", scanToolBtn).CornerRadius = UDim.new(0, 6)

local toolListFrame = Instance.new("ScrollingFrame")
toolListFrame.Size = UDim2.new(0.95, 0, 0, 140)
toolListFrame.BackgroundTransparency = 1
toolListFrame.ScrollBarThickness = 2
toolListFrame.Parent = pageAura
Instance.new("UIListLayout", toolListFrame).Padding = UDim.new(0, 2)

local toolConnection = nil

local function EvaluateTool(tool)
    if not tool or not tool:IsA("Tool") then return "INVALID" end
    for _, desc in ipairs(tool:GetDescendants()) do
        if (desc:IsA("NumberValue") or desc:IsA("IntValue"))
            and (desc.Name:lower():find("damage") or desc.Name:lower():find("dmg")) then
            return "READY"
        end
    end
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            return "UNKNOWN"
        end
    end
    return "UNKNOWN"
end

scanToolBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(toolListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local foundTools = {}
    local bp, char = player:FindFirstChild("Backpack"), player.Character

    local function AddTools(parent)
        if not parent then return end
        for _, v in ipairs(parent:GetChildren()) do
            if v:IsA("Tool") then
                local exists = false
                for _, t in ipairs(foundTools) do
                    if t == v then exists = true break end
                end
                if not exists then table.insert(foundTools, v) end
            end
        end
    end

    AddTools(bp)
    AddTools(char)

    if #foundTools == 0 then
        selectedToolLabel.Text = "❌ ไม่พบ Tool ในตัว"
        selectedToolLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    for _, tool in ipairs(foundTools) do
        local status = EvaluateTool(tool)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        local statusText = status == "READY" and "[DETECTED] " or "[UNKNOWN] "
        local tColor = status == "READY" and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 200, 0)

        btn.TextColor3 = tColor
        btn.Text = "⚔️ " .. statusText .. tool.Name
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 10
        btn.Parent = toolListFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            for _, c in ipairs(toolListFrame:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(50, 70, 50)

            Config.SelectedTool = tool
            Config.ToolStatus = status
            selectedToolLabel.Text = "✔️ เลือกแล้ว: " .. tool.Name
            selectedToolLabel.TextColor3 = Color3.fromRGB(0, 255, 150)

            if toolConnection then toolConnection:Disconnect() end
            toolConnection = tool.AncestryChanged:Connect(function(_, newParent)
                if not newParent or (newParent ~= player.Character and newParent ~= player:FindFirstChild("Backpack")) then
                    if Config.SelectedTool == tool then
                        Config.SelectedTool = nil
                        selectedToolLabel.Text = "❌ อาวุธหลุดหายไปแล้ว"
                        selectedToolLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                    if toolConnection then toolConnection:Disconnect() end
                end
            end)
            TrackConnection(toolConnection)
        end)
    end
end)

-- ==========================================
-- 🏃 MOVEMENT SYSTEM
-- ==========================================
MakeToggle(pageMove, "เปิดวิ่งเร็ว", function(v)
    Config.SpeedOn = v
    if not v then RestoreStats() end
end)
MakeSlider(pageMove, "ความเร็ว", 16, 300, 16, function(v) Config.SpeedVal = v end)

MakeToggle(pageMove, "เปิดกระโดดสูง", function(v)
    Config.JumpOn = v
    if not v then RestoreStats() end
end)
MakeSlider(pageMove, "พลังกระโดด", 50, 300, 50, function(v) Config.JumpVal = v end)

MakeToggle(pageMove, "ทะลุกำแพง (NoClip)", function(v) Config.NoClipOn = v end)
MakeToggle(pageMove, "เปิดลอยตัว (Float)", function(v) Config.FloatOn = v end)
MakeSlider(pageMove, "ความเร็วลอยขึ้น", 5, 100, 20, function(v) Config.FloatSpeed = v end)

-- ==========================================
-- ✈️ TELEPORT SYSTEM
-- ==========================================
local tpModeBtn = Instance.new("TextButton")
tpModeBtn.Size = UDim2.new(0.95, 0, 0, 26)
tpModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
tpModeBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
tpModeBtn.Text = "🚀 โหมด: วาร์ปทันที (Instant)"
tpModeBtn.Font = Enum.Font.GothamBold
tpModeBtn.TextSize = 10
tpModeBtn.Parent = pageTP
Instance.new("UICorner", tpModeBtn).CornerRadius = UDim.new(0, 6)

tpModeBtn.MouseButton1Click:Connect(function()
    Config.TPMode = (Config.TPMode == "Instant") and "Smooth" or "Instant"
    tpModeBtn.Text = Config.TPMode == "Instant" and "🚀 โหมด: วาร์ปทันที" or "🚀 โหมด: บินไปหา (Smooth)"
end)

MakeSlider(pageTP, "ความเร็วบินตาม", 10, 200, 50, function(v) Config.FlySpeed = v end)
MakeSlider(pageTP, "ระยะห่างเป้าหมาย", 0, 20, 0, function(v) Config.FollowDistance = v end)

local offsetLabel = Instance.new("TextLabel")
offsetLabel.Size = UDim2.new(0.95, 0, 0, 20)
offsetLabel.BackgroundTransparency = 1
offsetLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
offsetLabel.Text = "📌 ทิศทาง: เหนือหัว (Above)"
offsetLabel.Font = Enum.Font.GothamBold
offsetLabel.TextSize = 11
offsetLabel.Parent = pageTP

local offsets = {
    {"เหนือหัว", CFrame.new(0, 4, 0)},
    {"ใต้เท้า", CFrame.new(0, -4, 0)},
    {"ด้านหน้า", CFrame.new(0, 0, -4)},
    {"ด้านหลัง", CFrame.new(0, 0, 4)}
}

for _, off in ipairs(offsets) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 22)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Text = "➔ " .. off[1]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.Parent = pageTP
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        Config.FollowOffset = off[2]
        offsetLabel.Text = "📌 ทิศทาง: " .. off[1]
    end)
end

local StopTPBtn = Instance.new("TextButton")
StopTPBtn.Size = UDim2.new(0.95, 0, 0, 30)
StopTPBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StopTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopTPBtn.Text = "🛑 ปิดวาร์ปตาม"
StopTPBtn.Font = Enum.Font.GothamBold
StopTPBtn.TextSize = 11
StopTPBtn.Parent = pageTP
Instance.new("UICorner", StopTPBtn).CornerRadius = UDim.new(0, 6)

StopTPBtn.MouseButton1Click:Connect(function()
    Config.FollowOn = false
    Config.FollowTarget = nil
    StopTPBtn.Text = "🛑 ปิดวาร์ปตาม"
end)

local RefreshTPBtn = Instance.new("TextButton")
RefreshTPBtn.Size = UDim2.new(0.95, 0, 0, 26)
RefreshTPBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
RefreshTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshTPBtn.Text = "🔄 โหลดรายชื่อผู้เล่น"
RefreshTPBtn.Font = Enum.Font.GothamBold
RefreshTPBtn.TextSize = 11
RefreshTPBtn.Parent = pageTP
Instance.new("UICorner", RefreshTPBtn).CornerRadius = UDim.new(0, 6)

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.95, 0, 0, 90)
playerListFrame.BackgroundTransparency = 1
playerListFrame.ScrollBarThickness = 2
playerListFrame.Parent = pageTP
Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 2)

RefreshTPBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(playerListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
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
                StopTPBtn.Text = "⚡ ตามติด: " .. p.DisplayName
            end)
        end
    end
end)

-- ==========================================
-- 🛡️ INFO & UNLOAD SYSTEM
-- ==========================================
MakeToggle(pageInfo, "Safety Check", function(v) Config.SafetyMode = v end, true)

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(0.95, 0, 0, 100)
InfoText.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
InfoText.TextColor3 = Color3.fromRGB(220, 230, 255)
InfoText.Text = "🔥 AT Hub - v33.2\n[Ultimate Protected Edition]\n👨‍💻 Dev: NATTHANON WHAIPILP\n✅ Safe Core & Crash Prevented"
InfoText.Font = Enum.Font.GothamBold
InfoText.TextSize = 11
InfoText.TextYAlignment = Enum.TextYAlignment.Center
InfoText.Parent = pageInfo
Instance.new("UICorner", InfoText).CornerRadius = UDim.new(0, 6)

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0.95, 0, 0, 36)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Text = "🗑️ ปิดระบบและลบสคริปต์ (Unload)"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 12
UnloadBtn.Parent = pageInfo
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

_G.ATHub_Unload = function()
    isRunning = false
    for _, conn in ipairs(Connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    Connections = {}
    RestoreStats()

    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end

    if ScreenGui then ScreenGui:Destroy() end
    _G.ATHub_Unload = nil
end

UnloadBtn.MouseButton1Click:Connect(function()
    _G.ATHub_Unload()
end)

-- ==========================================
-- ⚙️ CORE LOGIC LOOPS
-- ==========================================

TrackConnection(task.spawn(function()
    while isRunning do
        pcall(function()
            if Config.TargetMode == "All" or Config.ProximityAuraOn then
                local tempMobs = {}
                local function ScanContainer(container)
                    for _, v in ipairs(container:GetChildren()) do
                        if v:IsA("Model") and v ~= player.Character and IsAlive(v) then
                            table.insert(tempMobs, v)
                        elseif v:IsA("Folder") or v:IsA("Model") then
                            ScanContainer(v)
                        end
                    end
                end
                ScanContainer(Workspace)
                State.CachedMobs = tempMobs
            end
        end)
        task.wait(2.5)
    end
end))

TrackConnection(RunService.Stepped:Connect(function()
    if not isRunning then return end
    pcall(function()
        if Config.NoClipOn then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
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

        if hum then
            if Config.SpeedOn then hum.WalkSpeed = Config.SpeedVal end
            if Config.JumpOn then
                if hum.UseJumpPower then
                    hum.JumpPower = Config.JumpVal
                else
                    hum.JumpHeight = Config.JumpVal
                end
            end
        end

        if Config.FollowOn and Config.FollowTarget then
            local tChar = Config.FollowTarget.Character
            if IsAlive(tChar) and hrp then
                local tHrp = GetHRP(tChar)
                if tHrp then
                    local distOffset = Config.FollowOffset * CFrame.new(0, 0, Config.FollowDistance)
                    local targetCF = tHrp.CFrame * distOffset

                    if Config.TPMode == "Instant" then
                        hrp.CFrame = targetCF
                    else
                        hrp.CFrame = hrp.CFrame:Lerp(
                            targetCF,
                            math.clamp(Config.FlySpeed / 100, 0.05, 0.8)
                        )
                    end
                end
            else
                Config.FollowOn = false
                StopTPBtn.Text = "🛑 เป้าหมายหาย (วาร์ปหยุด)"
            end
        end

        if Config.FloatOn and hrp and not Config.FollowOn then
            hrp.Velocity = Vector3.new(
                hrp.Velocity.X,
                Config.FloatSpeed,
                hrp.Velocity.Z
            )
        end
    end)
end))

TrackConnection(RunService.RenderStepped:Connect(function()
    if not isRunning then return end
    pcall(function()
        local cam = GetCamera()
        if not cam then return end

        local char = player.Character
        if not char then return end

        local hrp = GetHRP(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not IsAlive(char) then return end

        if Config.ProximityAuraOn and Config.SelectedTool and Config.SelectedTool.Parent then
            local targetInRange = false
            local pool = (Config.TargetMode == "Players") and Players:GetPlayers() or State.CachedMobs

            for _, v in ipairs(pool) do
                local tChar = (typeof(v) == "Instance" and v:IsA("Player")) and v.Character or v
                if tChar and tChar ~= char and IsAlive(tChar) then
                    local p = Players:GetPlayerFromCharacter(tChar)
                    if p and Config.TeamCheck and p.Team == player.Team then continue end

                    local tHrp = GetHRP(tChar)
                    if tHrp then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist <= Config.AuraRange then
                            targetInRange = true
                            break
                        end
                    end
                end
            end

            if targetInRange and (tick() - State.LastAuraTick >= Config.AuraCooldown) then
                State.LastAuraTick = tick()
                if Config.SelectedTool.Parent ~= char then
                    pcall(function() hum:EquipTool(Config.SelectedTool) end)
                end
                pcall(function() Config.SelectedTool:Activate() end)
            end
        end

        if Config.AimbotOn then
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local bestPart, sDist = nil, Config.AimFOV / 2
            local pool = (Config.TargetMode == "Players") and Players:GetPlayers() or State.CachedMobs

            for _, v in ipairs(pool) do
                local tChar = (typeof(v) == "Instance" and v:IsA("Player")) and v.Character or v
                if tChar and tChar ~= char and IsAlive(tChar) then
                    local p = Players:GetPlayerFromCharacter(tChar)
                    if p and Config.TeamCheck and p.Team == player.Team then continue end

                    local part = tChar:FindFirstChild(Config.TargetPart) or GetHRP(tChar)
                    if part and IsVisible(part, char) then
                        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
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
                local curCF = cam.CFrame
                local tCF = CFrame.new(curCF.Position, bestPart.Position)
                cam.CFrame = curCF:Lerp(
                    tCF,
                    math.clamp(Config.LockPower / 100, 0.05, 1)
                )
            end
        end
    end)
end))

-- ==========================================
-- 🔄 RESPAWN HANDLER
-- ==========================================
TrackConnection(player.CharacterAdded:Connect(function(newChar)
    if not isRunning then return end
    task.wait(0.5)
    pcall(function()
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then BackupStats(hum) end
    end)
end))

pcall(function()
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then BackupStats(hum) end
    end
end)
