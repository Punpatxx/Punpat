-- ==========================================
-- ⚡ AT Hub - Mobile Bulletproof Developer Hub v25.2 (Fixed)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ActiveConnections = {}
local function TrackConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

local OriginalStats = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = Workspace.Gravity
}

local function BackupOriginalStats(hum)
    if hum then
        OriginalStats.WalkSpeed = hum.WalkSpeed
        OriginalStats.JumpPower = hum.JumpPower
    end
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local guiParent = playerGui
pcall(function()
    if gethui then
        guiParent = gethui()
    elseif game:GetService("CoreGui") then
        guiParent = game:GetService("CoreGui")
    end
end)

local safeKey = "AT_DevHub_v25_2"
if guiParent:FindFirstChild(safeKey) then
    guiParent:FindFirstChild(safeKey):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = safeKey
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local Config = {
    UIScale = 1.0,
    CombatEnabled = false,
    FOVSize = 150,
    Smoothness = 0.2,
    TargetPart = "Head",
    MaxDistance = 500,
    TeamCheck = true,
    AliveCheck = true,
    ESPEnabled = false,
    ESPTeamCheck = true,
    ESPAliveOnly = true,
    SpeedEnabled = false,
    SpeedVal = 16,
    JumpEnabled = false,
    JumpVal = 50,
    GravityEnabled = false,
    GravityVal = 196.2,
    NoClipEnabled = false,
    SavedPositions = { [1] = nil, [2] = nil, [3] = nil }
}

-- Floating Launcher Button
local LauncherBtn = Instance.new("TextButton")
LauncherBtn.Size = UDim2.new(0, 52, 0, 52)
LauncherBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
LauncherBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
LauncherBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
LauncherBtn.Text = "AT"
LauncherBtn.Font = Enum.Font.GothamBold
LauncherBtn.TextSize = 16
LauncherBtn.Active = true
LauncherBtn.Draggable = true
LauncherBtn.Parent = ScreenGui
Instance.new("UICorner", LauncherBtn).CornerRadius = UDim.new(0, 10)
local LauncherStroke = Instance.new("UIStroke", LauncherBtn)
LauncherStroke.Color = Color3.fromRGB(0, 180, 255)
LauncherStroke.Thickness = 1.5

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 45, 65)
MainStroke.Thickness = 1

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
TitleLabel.Text = "AT HUB V25.2 [DEV]"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local StatusIndicator = Instance.new("TextLabel")
StatusIndicator.Size = UDim2.new(0, 160, 1, 0)
StatusIndicator.Position = UDim2.new(0, 145, 0, 0)
StatusIndicator.BackgroundTransparency = 1
StatusIndicator.TextColor3 = Color3.fromRGB(0, 255, 120)
StatusIndicator.Text = "● SYSTEM READY"
StatusIndicator.Font = Enum.Font.GothamBold
StatusIndicator.TextSize = 10
StatusIndicator.TextXAlignment = Enum.TextXAlignment.Left
StatusIndicator.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
LauncherBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 115, 1, -45)
Sidebar.Position = UDim2.new(0, 5, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 6)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -45)
ContentContainer.Position = UDim2.new(0, 125, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Pages = {}
local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 3
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.Parent = ContentContainer
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = sf
    return sf
end

local function CreateTab(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
    btn.TextColor3 = Color3.fromRGB(190, 210, 235)
    btn.Text = displayName
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end

local pageCombat = CreatePage("Combat")
local pageESP = CreatePage("ESP")
local pageMove = CreatePage("Movement")
local pageTP = CreatePage("Teleport")
local pageSettings = CreatePage("Settings")
local pageSafety = CreatePage("Safety")
local pageInfo = CreatePage("Info")

CreateTab("Combat", "🎯 Combat")
CreateTab("ESP", "👁 ESP")
CreateTab("Movement", "🏃 Movement")
CreateTab("Teleport", "✈️ Teleport")
CreateTab("Settings", "⚙️ Settings")
CreateTab("Safety", "🛡 Safety")
CreateTab("Info", "ℹ️ Info")
pageCombat.Visible = true

local function MakeToggle(parent, text, callback)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
    btn.TextColor3 = Color3.fromRGB(220, 230, 245)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(20, 25, 36)
        pcall(callback, state)
    end)
    return btn
end

local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 16)
    label.Position = UDim2.new(0, 6, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 215, 235)
    label.Text = text .. " : " .. tostring(default)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -12, 0, 14)
    sliderBtn.Position = UDim2.new(0, 6, 0, 22)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
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

-- 1. Combat
MakeToggle(pageCombat, "🎯 Enable Combat/Aimbot", function(v) Config.CombatEnabled = v end)
MakeSlider(pageCombat, "FOV Size", 50, 400, 150, function(v) Config.FOVSize = v end)
MakeSlider(pageCombat, "Aim Smoothness (%)", 5, 100, 20, function(v) Config.Smoothness = v / 100 end)
MakeSlider(pageCombat, "Max Distance", 50, 2000, 500, function(v) Config.MaxDistance = v end)
MakeToggle(pageCombat, "🛡 Team Check", function(v) Config.TeamCheck = v end)
MakeToggle(pageCombat, "❤️ Alive Check", function(v) Config.AliveCheck = v end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Config.FOVSize, 0, Config.FOVSize)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVCircle)
FOVStroke.Color = Color3.fromRGB(0, 180, 255)
FOVStroke.Thickness = 1.5

local function GetClosestTarget()
    local bestTarget = nil
    local shortestDist = Config.FOVSize / 2
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
                local hum = v.Character.Humanoid
                if Config.AliveCheck and hum.Health <= 0 then continue end
                local part = v.Character:FindFirstChild(Config.TargetPart) or v.Character.HumanoidRootPart
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude or 0
                if dist <= Config.MaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist < shortestDist then
                            shortestDist = screenDist
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

TrackConnection(RunService.RenderStepped:Connect(function()
    pcall(function()
        FOVCircle.Size = UDim2.new(0, Config.FOVSize, 0, Config.FOVSize)
        FOVCircle.Visible = Config.CombatEnabled
        if Config.CombatEnabled then
            local target = GetClosestTarget()
            if target then
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, target.Position)
                Camera.CFrame = currentCF:Lerp(targetCF, Config.Smoothness)
            end
        end
    end)
end))

-- 2. ESP
MakeToggle(pageESP, "👁 Enable ESP (Highlight)", function(v) Config.ESPEnabled = v end)
MakeToggle(pageESP, "🛡 ESP Team Check", function(v) Config.ESPTeamCheck = v end)

TrackConnection(RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local highlight = char:FindFirstChild("AT_ESP_Highlight")
                local shouldShow = Config.ESPEnabled
                if shouldShow and Config.ESPTeamCheck and plr.Team == LocalPlayer.Team then shouldShow = false end
                if shouldShow then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "AT_ESP_Highlight"
                        highlight.Adornee = char
                        highlight.FillColor = Color3.fromRGB(0, 180, 255)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = char
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)
end))

-- 3. Movement
MakeToggle(pageMove, "⚡ WalkSpeed Override", function(v) Config.SpeedEnabled = v end)
MakeSlider(pageMove, "WalkSpeed Value", 16, 300, 16, function(v) Config.SpeedVal = v end)
MakeToggle(pageMove, "🦘 JumpPower Override", function(v) Config.JumpEnabled = v end)
MakeSlider(pageMove, "JumpPower Value", 50, 300, 50, function(v) Config.JumpVal = v end)
MakeToggle(pageMove, "🌍 Custom Gravity", function(v) Config.GravityEnabled = v end)
MakeSlider(pageMove, "Gravity Value", 0, 300, 196, function(v) Config.GravityVal = v end)
MakeToggle(pageMove, "👻 NoClip", function(v) Config.NoClipEnabled = v end)

TrackConnection(RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Config.SpeedEnabled then hum.WalkSpeed = Config.SpeedVal end
                if Config.JumpEnabled then hum.UseJumpPower = true; hum.JumpPower = Config.JumpVal end
            end
            if Config.GravityEnabled then Workspace.Gravity = Config.GravityVal else Workspace.Gravity = OriginalStats.Gravity end
            if Config.NoClipEnabled then
                for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end
        end
    end)
end))

-- 4. Teleport
local SavePos1Btn = Instance.new("TextButton")
SavePos1Btn.Size = UDim2.new(0.95, 0, 0, 28)
SavePos1Btn.BackgroundColor3 = Color3.fromRGB(22, 30, 42)
SavePos1Btn.TextColor3 = Color3.fromRGB(220, 230, 245)
SavePos1Btn.Text = "📌 Save Position 1"
SavePos1Btn.Font = Enum.Font.GothamSemibold
SavePos1Btn.TextSize = 11
SavePos1Btn.Parent = pageTP
Instance.new("UICorner", SavePos1Btn).CornerRadius = UDim.new(0, 6)

SavePos1Btn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedPositions[1] = LocalPlayer.Character.HumanoidRootPart.CFrame
        SavePos1Btn.Text = "📌 Position 1 Saved!"
        task.delay(1.5, function() SavePos1Btn.Text = "📌 Save Position 1" end)
    end
end)

local TPPos1Btn = Instance.new("TextButton")
TPPos1Btn.Size = UDim2.new(0.95, 0, 0, 28)
TPPos1Btn.BackgroundColor3 = Color3.fromRGB(22, 30, 42)
TPPos1Btn.TextColor3 = Color3.fromRGB(220, 230, 245)
TPPos1Btn.Text = "🚀 Teleport To Position 1"
TPPos1Btn.Font = Enum.Font.GothamSemibold
TPPos1Btn.TextSize = 11
TPPos1Btn.Parent = pageTP
Instance.new("UICorner", TPPos1Btn).CornerRadius = UDim.new(0, 6)

TPPos1Btn.MouseButton1Click:Connect(function()
    if Config.SavedPositions[1] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Config.SavedPositions[1]
    end
end)

local RefreshTPBtn = Instance.new("TextButton")
RefreshTPBtn.Size = UDim2.new(0.95, 0, 0, 28)
RefreshTPBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 180)
RefreshTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshTPBtn.Text = "🔄 Refresh Player List"
RefreshTPBtn.Font = Enum.Font.GothamBold
RefreshTPBtn.TextSize = 11
RefreshTPBtn.Parent = pageTP
Instance.new("UICorner", RefreshTPBtn).CornerRadius = UDim.new(0, 6)

local TPPlayerScroll = Instance.new("ScrollingFrame")
TPPlayerScroll.Size = UDim2.new(0.95, 0, 0, 140)
TPPlayerScroll.BackgroundTransparency = 1
TPPlayerScroll.ScrollBarThickness = 3
TPPlayerScroll.Parent = pageTP
local TPListLayout = Instance.new("UIListLayout", TPPlayerScroll)
TPListLayout.Padding = UDim.new(0, 3)

RefreshTPBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(TPPlayerScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 26)
            pBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
            pBtn.TextColor3 = Color3.fromRGB(220, 230, 245)
            pBtn.Text = "👤 " .. p.DisplayName
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 10
            pBtn.Parent = TPPlayerScroll
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                end
            end)
        end
    end
end)

-- 5. Settings
MakeSlider(pageSettings, "UI Scale (%)", 80, 120, 100, function(v) Config.UIScale = v / 100 end)

-- 6. Safety
local EmergencyBtn = Instance.new("TextButton")
EmergencyBtn.Size = UDim2.new(0.95, 0, 0, 45)
EmergencyBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
EmergencyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EmergencyBtn.Text = "🚨 EMERGENCY STOP"
EmergencyBtn.Font = Enum.Font.GothamBold
EmergencyBtn.TextSize = 13
EmergencyBtn.Parent = pageSafety
Instance.new("UICorner", EmergencyBtn).CornerRadius = UDim.new(0, 8)

local function EmergencyStopAll()
    Config.CombatEnabled = false
    Config.ESPEnabled = false
    Config.SpeedEnabled = false
    Config.JumpEnabled = false
    Config.GravityEnabled = false
    Config.NoClipEnabled = false
    Workspace.Gravity = OriginalStats.Gravity
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("AT_ESP_Highlight") then plr.Character.AT_ESP_Highlight:Destroy() end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = OriginalStats.WalkSpeed
        hum.JumpPower = OriginalStats.JumpPower
    end
    StatusIndicator.TextColor3 = Color3.fromRGB(255, 60, 60)
    StatusIndicator.Text = "● EMERGENCY STOPPED"
    task.delay(2.5, function()
        StatusIndicator.TextColor3 = Color3.fromRGB(0, 255, 120)
        StatusIndicator.Text = "● SYSTEM READY"
    end)
end

EmergencyBtn.MouseButton1Click:Connect(EmergencyStopAll)

-- 7. Info
local InfoBox = Instance.new("TextLabel")
InfoBox.Size = UDim2.new(0.95, 0, 0, 160)
InfoBox.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
InfoBox.TextColor3 = Color3.fromRGB(210, 225, 245)
InfoBox.Text = " AT Hub V25.2 [Fixed & Bulletproof]\n\n Developer: NATTHANON WHAIPILP\n Status: Stable\n\n- Fixed UI Corner Bug\n- Highlight ESP Ready\n- Emergency Stop Fully Working"
InfoBox.Font = Enum.Font.Gotham
InfoBox.TextSize = 11
InfoBox.TextYAlignment = Enum.TextYAlignment.Top
InfoBox.TextXAlignment = Enum.TextXAlignment.Left
InfoBox.Parent = pageInfo
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 6)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then BackupOriginalStats(hum) end
end)

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    BackupOriginalStats(LocalPlayer.Character.Humanoid)
end
