--!strict
--[[
    Advanced Script Hub - Final Stabilized
    Features:
    - Safe full cleanup with cleanedUp guard
    - Single Noclip connection with CanCollide restoration
    - Waypoint Instant/Tween modes with safe tween cancellation
    - NPC-only Tool activation combat testing
    - Notification limit
    - Luau strict typing
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Cleanup old instance
local oldGui = CoreGui:FindFirstChild("AdvancedScriptHub")
if oldGui then
    oldGui:Destroy()
end

local cleanedUp = false
local ActiveConnections: { RBXScriptConnection } = {}

local function addConnection(conn: RBXScriptConnection): RBXScriptConnection
    table.insert(ActiveConnections, conn)
    return conn
end

local noclipConnection: RBXScriptConnection? = nil
local originalCanCollide: { [BasePart]: boolean } = {}
local activeTween: Tween? = nil

local function fullCleanup()
    if cleanedUp then
        return
    end
    cleanedUp = true

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, canCollide in pairs(originalCanCollide) do
        if part.Parent then
            part.CanCollide = canCollide
        end
    end
    table.clear(originalCanCollide)

    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end

    for _, conn in ipairs(ActiveConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(ActiveConnections)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedScriptHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

ScreenGui.Destroying:Connect(function()
    fullCleanup()
end)

-- Notifications
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 300, 0, 400)
NotifContainer.Position = UDim2.new(1, -315, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = NotifContainer

local lastNotifTime = 0

local function notify(message: string, notifType: string?)
    local currentTime = tick()
    if currentTime - lastNotifTime < 0.3 then
        return
    end
    lastNotifTime = currentTime

    local count = 0
    for _, child in ipairs(NotifContainer:GetChildren()) do
        if child:IsA("Frame") then
            count += 1
        end
    end

    if count >= 5 then
        for _, child in ipairs(NotifContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
                break
            end
        end
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 40)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 0.1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 =
        notifType == "Warning"
        and Color3.fromRGB(240, 160, 60)
        or (notifType == "Success"
        and Color3.fromRGB(60, 220, 100)
        or Color3.fromRGB(100, 150, 255))
    accent.BorderSizePixel = 0
    accent.Parent = notif

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 4)
    accentCorner.Parent = accent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -15, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = message
    label.Parent = notif

    notif.Parent = NotifContainer

    task.delay(2.5, function()
        if notif.Parent then
            local fade = TweenService:Create(
                notif,
                TweenInfo.new(0.3),
                { BackgroundTransparency = 1 }
            )
            fade:Play()
            task.wait(0.3)
            if notif.Parent then
                notif:Destroy()
            end
        end
    end)
end

-- Main UI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "⚡ Advanced Script Hub [Secure Edition]"
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local isMinimized = false

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -95)
ContentContainer.Position = UDim2.new(0, 10, 0, 90)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local tabs: { [string]: ScrollingFrame } = {}

local function createTabContent(name: string): ScrollingFrame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.Visible = false
    scroll.Parent = ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scroll

    tabs[name] = scroll
    return scroll
end

local function createTabButton(name: string, targetTab: ScrollingFrame, index: number)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.LayoutOrder = index
    btn.Parent = TabBar

    addConnection(btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Visible = false
        end
        for _, b in ipairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
        targetTab.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end))
end

local tabMovement = createTabContent("Movement")
local tabWaypoints = createTabContent("Waypoints")
local tabCombat = createTabContent("Combat")
local tabMisc = createTabContent("Misc")

createTabButton("Movement", tabMovement, 1)
createTabButton("Waypoints", tabWaypoints, 2)
createTabButton("Combat", tabCombat, 3)
createTabButton("Misc", tabMisc, 4)

tabMovement.Visible = true

addConnection(MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentContainer.Visible = not isMinimized
    TabBar.Visible = not isMinimized
    MainFrame.Size = isMinimized
        and UDim2.new(0, 480, 0, 40)
        or UDim2.new(0, 480, 0, 360)
    MinimizeBtn.Text = isMinimized and "+" or "-"
end))

addConnection(CloseBtn.MouseButton1Click:Connect(function()
    fullCleanup()
    ScreenGui:Destroy()
end))

-- Movement
local function createToggle(parent: GuiObject, title: string, callback: (boolean) -> ())
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 36)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.Text = "   " .. title .. ": [ OFF ]"
    toggleBtn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleBtn

    local state = false
    addConnection(toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = "   " .. title .. ": [ " .. (state and "ON" or "OFF") .. " ]"
        toggleBtn.BackgroundColor3 = state
            and Color3.fromRGB(50, 120, 80)
            or Color3.fromRGB(32, 32, 45)
        callback(state)
    end))
end

local function createSlider(
    parent: GuiObject,
    title: string,
    minVal: number,
    maxVal: number,
    defaultVal: number,
    callback: (number) -> ()
)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = title .. ": " .. tostring(defaultVal)
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 100, 0, 20)
    box.Position = UDim2.new(1, -110, 0, 22)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.Text = tostring(defaultVal)
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    addConnection(box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            val = math.clamp(val, minVal, maxVal)
            box.Text = tostring(val)
            label.Text = title .. ": " .. tostring(val)
            callback(val)
        else
            box.Text = tostring(defaultVal)
        end
    end))
end

local currentSpeed = 16
local currentJump = 50

createSlider(tabMovement, "WalkSpeed", 16, 200, 16, function(val)
    currentSpeed = val
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = val
        end
    end
end)

createSlider(tabMovement, "JumpPower", 50, 300, 50, function(val)
    currentJump = val
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = val
        end
    end
end)

createToggle(tabMovement, "Noclip (เดินทะลุกำแพง)", function(state)
    if state then
        notify("Noclip Enabled", "Success")

        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then
                    return
                end

                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if originalCanCollide[part] == nil then
                            originalCanCollide[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end)

            addConnection(noclipConnection)
        end
    else
        notify("Noclip Disabled", "Info")

        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        for part, canCollide in pairs(originalCanCollide) do
            if part.Parent then
                part.CanCollide = canCollide
            end
        end
        table.clear(originalCanCollide)
    end
end)

addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid and humanoid:IsA("Humanoid") then
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump
    end
end))

-- Waypoints
local waypoints: { CFrame } = {}
local maxWaypoints = 5
local wpMode = "Instant"

local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, 0, 0, 40)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = tabWaypoints

local btnInstant = Instance.new("TextButton")
btnInstant.Size = UDim2.new(0.48, 0, 1, 0)
btnInstant.BackgroundColor3 = Color3.fromRGB(50, 120, 80)
btnInstant.TextColor3 = Color3.fromRGB(255, 255, 255)
btnInstant.TextSize = 13
btnInstant.Font = Enum.Font.GothamBold
btnInstant.Text = "Mode: Instant (วาปทันที)"
btnInstant.Parent = modeFrame

local instCorner = Instance.new("UICorner")
instCorner.CornerRadius = UDim.new(0, 6)
instCorner.Parent = btnInstant

local btnTween = Instance.new("TextButton")
btnTween.Size = UDim2.new(0.48, 0, 1, 0)
btnTween.Position = UDim2.new(0.52, 0, 0, 0)
btnTween.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
btnTween.TextColor3 = Color3.fromRGB(180, 180, 200)
btnTween.TextSize = 13
btnTween.Font = Enum.Font.GothamBold
btnTween.Text = "Mode: Tween (ลอยไป)"
btnTween.Parent = modeFrame

local tweenCorner = Instance.new("UICorner")
tweenCorner.CornerRadius = UDim.new(0, 6)
tweenCorner.Parent = btnTween

addConnection(btnInstant.MouseButton1Click:Connect(function()
    wpMode = "Instant"
    btnInstant.BackgroundColor3 = Color3.fromRGB(50, 120, 80)
    btnInstant.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnTween.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    btnTween.TextColor3 = Color3.fromRGB(180, 180, 200)
    notify("Waypoint Mode: Instant", "Info")
end))

addConnection(btnTween.MouseButton1Click:Connect(function()
    wpMode = "Tween"
    btnTween.BackgroundColor3 = Color3.fromRGB(50, 120, 80)
    btnTween.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnInstant.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    btnInstant.TextColor3 = Color3.fromRGB(180, 180, 200)
    notify("Waypoint Mode: Tween", "Info")
end))

local btnMark = Instance.new("TextButton")
btnMark.Size = UDim2.new(1, 0, 0, 36)
btnMark.BackgroundColor3 = Color3.fromRGB(45, 80, 140)
btnMark.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMark.TextSize = 13
btnMark.Font = Enum.Font.GothamBold
btnMark.Text = "📍 Mark Current Position (สูงสุด 5 จุด)"
btnMark.Parent = tabWaypoints

local markCorner = Instance.new("UICorner")
markCorner.CornerRadius = UDim.new(0, 6)
markCorner.Parent = btnMark

local wpListContainer = Instance.new("Frame")
wpListContainer.Size = UDim2.new(1, 0, 0, 180)
wpListContainer.BackgroundTransparency = 1
wpListContainer.Parent = tabWaypoints

local wpLayout = Instance.new("UIListLayout")
wpLayout.SortOrder = Enum.SortOrder.LayoutOrder
wpLayout.Padding = UDim.new(0, 5)
wpLayout.Parent = wpListContainer

local function updateWaypointUI()
    for _, child in ipairs(wpListContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for i, cf in ipairs(waypoints) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 32)
        item.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        item.LayoutOrder = i
        item.Parent = wpListContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = item

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = string.format(
            "Waypoint %d (%.0f, %.0f, %.0f)",
            i, cf.Position.X, cf.Position.Y, cf.Position.Z
        )
        label.Parent = item

        local btnGoto = Instance.new("TextButton")
        btnGoto.Size = UDim2.new(0, 60, 0, 24)
        btnGoto.Position = UDim2.new(1, -135, 0, 4)
        btnGoto.BackgroundColor3 = Color3.fromRGB(50, 120, 80)
        btnGoto.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnGoto.TextSize = 11
        btnGoto.Font = Enum.Font.GothamBold
        btnGoto.Text = "Go"
        btnGoto.Parent = item

        local gCorner = Instance.new("UICorner")
        gCorner.CornerRadius = UDim.new(0, 4)
        gCorner.Parent = btnGoto

        addConnection(btnGoto.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if not char then
                notify("Character not found!", "Warning")
                return
            end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp or not hrp:IsA("BasePart") then
                notify("Character RootPart not found!", "Warning")
                return
            end

            if wpMode == "Instant" then
                if activeTween then
                    activeTween:Cancel()
                    activeTween = nil
                end

                hrp.CFrame = cf
                notify("Teleported to Waypoint " .. i, "Success")
            else
                if activeTween then
                    activeTween:Cancel()
                    activeTween = nil
                end

                local distance = (hrp.Position - cf.Position).Magnitude
                local speed = 50
                local timeTaken = math.clamp(distance / speed, 0.5, 5)

                local tween = TweenService:Create(
                    hrp,
                    TweenInfo.new(timeTaken, Enum.EasingStyle.Linear),
                    { CFrame = cf }
                )

                activeTween = tween
                addConnection(tween.Completed:Connect(function()
                    if activeTween == tween then
                        activeTween = nil
                    end
                end))

                tween:Play()
                notify(
                    string.format("Tweening to Waypoint %d (%.1fs)", i, timeTaken),
                    "Success"
                )
            end
        end))

        local btnDel = Instance.new("TextButton")
        btnDel.Size = UDim2.new(0, 60, 0, 24)
        btnDel.Position = UDim2.new(1, -70, 0, 4)
        btnDel.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        btnDel.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnDel.TextSize = 11
        btnDel.Font = Enum.Font.GothamBold
        btnDel.Text = "Delete"
        btnDel.Parent = item

        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(0, 4)
        dCorner.Parent = btnDel

        addConnection(btnDel.MouseButton1Click:Connect(function()
            table.remove(waypoints, i)
            updateWaypointUI()
            notify("Waypoint " .. i .. " deleted.", "Info")
        end))
    end
end

addConnection(btnMark.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then
        notify("Cannot mark: Character not found!", "Warning")
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then
        notify("Cannot mark: Character RootPart not found!", "Warning")
        return
    end

    if #waypoints >= maxWaypoints then
        notify("Maximum 5 waypoints reached!", "Warning")
        return
    end

    table.insert(waypoints, hrp.CFrame)
    updateWaypointUI()
    notify("Waypoint " .. #waypoints .. " marked successfully!", "Success")
end))

addConnection(LocalPlayer.CharacterRemoving:Connect(function()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
end))

-- Combat testing
local combatEnabled = false
local attackRange = 15
local attackCooldown = 0.5
local lastAttackTick = 0

createToggle(tabCombat, "Mob Kill Aura (ต้องถือ Tool ในมือ)", function(state)
    combatEnabled = state
    if state then
        notify("Kill Aura Activated (NPC Only)", "Success")
    else
        notify("Kill Aura Deactivated", "Info")
    end
end)

createSlider(tabCombat, "Attack Range", 5, 50, 15, function(val)
    attackRange = val
end)

local function performAttack(tool: Tool)
    pcall(function()
        tool:Activate()
    end)
end

addConnection(RunService.Heartbeat:Connect(function()
    if not combatEnabled then
        return
    end

    local char = LocalPlayer.Character
    if not char then
        return
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then
        return
    end

    local currentTime = tick()
    if currentTime - lastAttackTick < attackCooldown then
        return
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj ~= char and obj:IsA("Model") then
            local isPlayer = Players:GetPlayerFromCharacter(obj) ~= nil

            if not isPlayer then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local targetHRP = obj:FindFirstChild("HumanoidRootPart")

                if humanoid and targetHRP and targetHRP:IsA("BasePart") and humanoid.Health > 0 then
                    local distance = (hrp.Position - targetHRP.Position).Magnitude

                    if distance <= attackRange then
                        lastAttackTick = currentTime
                        performAttack(tool)
                        break
                    end
                end
            end
        end
    end
end))

print("⚡ Advanced Script Hub Loaded Successfully")