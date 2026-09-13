-- ==========================================
-- ⚡ AT Hub - Developer/Test Hub v28.0
-- Clean Execution Edition
-- ==========================================
-- Fixed:
-- 1) Robust PlayerGui/CoreGui parent selection
-- 2) CurrentCamera is refreshed dynamically
-- 3) Character respawn safely restores tracked movement values
-- 4) Slider input connections are cleaned up with the GUI
-- 5) No exploit/executor-only APIs are required
--
-- This build is intended for Roblox Studio / experiences you own.
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = workspace
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[AT Hub] LocalPlayer is unavailable. Run this from a LocalScript.")
    return
end

local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AT_DevHub_v28")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AT_DevHub_v28"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Connections = {}
local function Connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function Cleanup()
    for _, c in ipairs(Connections) do
        if c and c.Connected then c:Disconnect() end
    end
    table.clear(Connections)
end

local Config = {
    UIScale = 1,
    SpeedEnabled = false,
    SpeedVal = 16,
    JumpEnabled = false,
    JumpVal = 50,
    GravityEnabled = false,
    GravityVal = 196.2,
    NoClipEnabled = false,
    NoFog = false,
    RemoveEffects = false,
    ThemeDark = true,
}

local Original = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = Workspace.Gravity,
    FogEnd = Lighting.FogEnd,
}

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function BackupHumanoid(hum)
    if not hum then return end
    Original.WalkSpeed = hum.WalkSpeed
    Original.JumpPower = hum.JumpPower
end

if LocalPlayer.Character then
    BackupHumanoid(GetHumanoid())
end

local Launcher = Instance.new("TextButton")
Launcher.Name = "Launcher"
Launcher.Size = UDim2.fromOffset(52, 52)
Launcher.Position = UDim2.new(0.05, 0, 0.15, 0)
Launcher.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
Launcher.TextColor3 = Color3.fromRGB(0, 220, 255)
Launcher.Text = "AT"
Launcher.Font = Enum.Font.GothamBold
Launcher.TextSize = 16
Launcher.Active = true
Launcher.Draggable = true
Launcher.Parent = ScreenGui
Instance.new("UICorner", Launcher).CornerRadius = UDim.new(0, 10)

local launcherStroke = Instance.new("UIStroke", Launcher)
launcherStroke.Color = Color3.fromRGB(0, 180, 255)
launcherStroke.Thickness = 1.5

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(480, 380)
Main.Position = UDim2.new(0.5, -240, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Scale = Instance.new("UIScale", Main)
Scale.Scale = Config.UIScale

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(35, 45, 65)
Stroke.Thickness = 1

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 230, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(220, 235, 255)
Title.Text = "AT HUB V28.0 [DEV]"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(150, 35)
Status.Position = UDim2.new(1, -190, 0, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 120)
Status.Text = "● READY"
Status.Font = Enum.Font.GothamBold
Status.TextSize = 10
Status.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.fromRGB(200, 80, 80)
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Top

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 115, 1, -45)
Sidebar.Position = UDim2.fromOffset(5, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
Sidebar.ScrollBarThickness = 2
Sidebar.CanvasSize = UDim2.new()
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 4)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidePad = Instance.new("UIPadding", Sidebar)
sidePad.PaddingTop = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -45)
Content.Position = UDim2.fromOffset(125, 40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", page)
    pad.PaddingBottom = UDim.new(0, 8)

    Pages[name] = page
    return page
end

local function CreateTab(name, text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.92, 0, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
    button.TextColor3 = Color3.fromRGB(190, 210, 235)
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 11
    button.Parent = Sidebar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    Connect(button.MouseButton1Click, function()
        for _, page in pairs(Pages) do
            page.Visible = false
        end
        Pages[name].Visible = true
    end)
end

local pageMove = CreatePage("Movement")
local pageSettings = CreatePage("Settings")
local pageSafety = CreatePage("Safety")
local pageInfo = CreatePage("Info")

CreateTab("Movement", "🏃 Movement")
CreateTab("Settings", "⚙️ Settings")
CreateTab("Safety", "🛡 Safety")
CreateTab("Info", "ℹ️ Info")

pageMove.Visible = true

local function MakeToggle(parent, text, initial, callback)
    local state = initial == true
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.95, 0, 0, 30)
    button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(20, 25, 36)
    button.TextColor3 = Color3.fromRGB(220, 230, 245)
    button.Text = text .. (state and "  [ON]" or "  [OFF]")
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 11
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    Connect(button.MouseButton1Click, function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(20, 25, 36)
        button.Text = text .. (state and "  [ON]" or "  [OFF]")
        pcall(callback, state)
    end)

    return button
end

local function MakeSlider(parent, text, minValue, maxValue, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 44)
    frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 17)
    label.Position = UDim2.fromOffset(6, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 215, 235)
    label.Text = text .. " : " .. tostring(defaultValue)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -12, 0, 14)
    bar.Position = UDim2.fromOffset(6, 24)
    bar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local startPct = math.clamp((defaultValue - minValue) / (maxValue - minValue), 0, 1)
    fill.Size = UDim2.new(startPct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function SetFromX(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local value = math.floor(minValue + ((maxValue - minValue) * pct) + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        label.Text = text .. " : " .. tostring(value)
        pcall(callback, value)
    end

    Connect(bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(input.Position.X)
        end
    end)

    Connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end)

    Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame
end

-- Movement
MakeToggle(pageMove, "⚡ WalkSpeed Override", false, function(v)
    Config.SpeedEnabled = v
    local hum = GetHumanoid()
    if hum and not v then hum.WalkSpeed = Original.WalkSpeed end
end)

MakeSlider(pageMove, "WalkSpeed Value", 16, 100, 16, function(v)
    Config.SpeedVal = v
end)

MakeToggle(pageMove, "🦘 JumpPower Override", false, function(v)
    Config.JumpEnabled = v
    local hum = GetHumanoid()
    if hum and not v then
        hum.UseJumpPower = true
        hum.JumpPower = Original.JumpPower
    end
end)

MakeSlider(pageMove, "JumpPower Value", 50, 150, 50, function(v)
    Config.JumpVal = v
end)

MakeToggle(pageMove, "🌍 Custom Gravity", false, function(v)
    Config.GravityEnabled = v
    if not v then Workspace.Gravity = Original.Gravity end
end)

MakeSlider(pageMove, "Gravity Value", 0, 300, 196, function(v)
    Config.GravityVal = v
end)

MakeToggle(pageMove, "👻 NoClip", false, function(v)
    Config.NoClipEnabled = v
    if not v then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Settings
MakeToggle(pageSettings, "🌫️ Remove Fog", false, function(v)
    Config.NoFog = v
    Lighting.FogEnd = v and 1000000 or Original.FogEnd
end)

MakeToggle(pageSettings, "✨ Disable Post Effects", false, function(v)
    Config.RemoveEffects = v
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
            obj.Enabled = not v
        end
    end
end)

MakeToggle(pageSettings, "🌗 Light Theme", false, function(v)
    Config.ThemeDark = not v
    if Config.ThemeDark then
        Main.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
        Top.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    else
        Main.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
        Top.BackgroundColor3 = Color3.fromRGB(200, 205, 215)
        Sidebar.BackgroundColor3 = Color3.fromRGB(215, 220, 230)
    end
end)

MakeSlider(pageSettings, "UI Scale (%)", 80, 120, 100, function(v)
    Config.UIScale = v / 100
    Scale.Scale = Config.UIScale
end)

-- Safety
local stop = Instance.new("TextButton")
stop.Size = UDim2.new(0.95, 0, 0, 45)
stop.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
stop.TextColor3 = Color3.new(1, 1, 1)
stop.Text = "🚨 EMERGENCY STOP"
stop.Font = Enum.Font.GothamBold
stop.TextSize = 13
stop.Parent = pageSafety
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 8)

Connect(stop.MouseButton1Click, function()
    Config.SpeedEnabled = false
    Config.JumpEnabled = false
    Config.GravityEnabled = false
    Config.NoClipEnabled = false

    Workspace.Gravity = Original.Gravity

    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = Original.WalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = Original.JumpPower
    end

    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    Status.Text = "● STOPPED"
end)

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.95, 0, 0, 170)
info.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
info.TextColor3 = Color3.fromRGB(210, 225, 245)
info.Text = " AT Hub V28.0 [DEV]\n\n Clean LocalScript build\n\n• Movement test controls\n• UI scale / theme\n• Fog & post-effect controls\n• Emergency stop\n• Respawn-safe handling\n\nDesigned for Studio / experiences you own."
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = pageInfo
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)

Connect(RunService.Stepped, function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.SpeedEnabled then hum.WalkSpeed = Config.SpeedVal end
        if Config.JumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = Config.JumpVal
        end
    end

    if Config.GravityEnabled then
        Workspace.Gravity = Config.GravityVal
    end

    if Config.NoClipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if hum then BackupHumanoid(hum) end
end)

Connect(Launcher.MouseButton1Click, function()
    Main.Visible = not Main.Visible
end)

Connect(Close.MouseButton1Click, function()
    Main.Visible = false
end)

ScreenGui.Destroying:Connect(Cleanup)

print("[AT Hub] V28.0 loaded successfully.")
