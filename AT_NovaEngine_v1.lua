-- ==========================================
-- ⚡ AT Nova Engine v1.0
-- 🧩 Clean Roblox Utility Framework
-- 👨‍💻 Developer: NATTHANON WHAIPILP
-- ==========================================
-- Designed for Roblox Studio / experiences you own.
-- No executor-only APIs. No remote spying. No exploit hooks.
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ATNova = {}
ATNova.Version = "1.0.0"
ATNova.Unloaded = false

local Connections = {}
local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function disconnectAll()
    for _, c in ipairs(Connections) do
        if c and c.Connected then
            c:Disconnect()
        end
    end
    table.clear(Connections)
end

-- ==========================================
-- 🎨 UI
-- ==========================================

local gui = Instance.new("ScreenGui")
gui.Name = "AT_NovaEngine"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(430, 330)
main.Position = UDim2.new(0.5, -215, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(17, 18, 24)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 74, 90)
stroke.Thickness = 1
stroke.Transparency = 0.25
stroke.Parent = main

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 58)
top.BackgroundTransparency = 1
top.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18, 7)
title.Size = UDim2.new(1, -36, 0, 28)
title.Font = Enum.Font.GothamBold
title.Text = "AT NOVA ENGINE"
title.TextColor3 = Color3.fromRGB(240, 242, 255)
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(19, 33)
subtitle.Size = UDim2.new(1, -38, 0, 18)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Clean utility framework • v" .. ATNova.Version
subtitle.TextColor3 = Color3.fromRGB(145, 149, 165)
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = top

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Position = UDim2.fromOffset(16, 70)
contentFrame.Size = UDim2.new(1, -32, 1, -86)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 9)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentFrame

local function makeButton(textValue, order)
    local button = Instance.new("TextButton")
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(27, 29, 38)
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamMedium
    button.Text = textValue
    button.TextColor3 = Color3.fromRGB(226, 229, 240)
    button.TextSize = 13
    button.Parent = contentFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = button

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(55, 58, 72)
    s.Transparency = 0.35
    s.Parent = button

    return button
end

local status = Instance.new("TextLabel")
status.LayoutOrder = 5
status.Size = UDim2.new(1, 0, 0, 36)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(130, 220, 160)
status.TextSize = 12
status.Parent = contentFrame

local function setStatus(textValue, color)
    status.Text = "Status: " .. textValue
    status.TextColor3 = color or Color3.fromRGB(130, 220, 160)
end

-- ==========================================
-- 🧍 PLAYER UTILITIES
-- ==========================================

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function refreshCharacterInfo()
    local humanoid = getHumanoid()
    local root = getRoot()

    if not humanoid or not root then
        setStatus("Character not ready", Color3.fromRGB(240, 160, 120))
        return
    end

    setStatus(
        string.format(
            "HP %.0f/%.0f • Speed %.0f",
            humanoid.Health,
            humanoid.MaxHealth,
            humanoid.WalkSpeed
        )
    )
end

-- ==========================================
-- 🧭 SAFE MOVEMENT HELPERS
-- ==========================================

local function moveForward(distance)
    local root = getRoot()
    if not root then
        setStatus("RootPart not found", Color3.fromRGB(240, 120, 120))
        return
    end

    local target = root.Position + root.CFrame.LookVector * distance
    root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)
    setStatus("Moved forward " .. distance .. " studs")
end

-- ==========================================
-- 🔘 BUTTONS
-- ==========================================

local infoButton = makeButton("PLAYER INFO", 1)
connect(infoButton.MouseButton1Click, refreshCharacterInfo)

local forwardButton = makeButton("MOVE FORWARD 5 STUDS", 2)
connect(forwardButton.MouseButton1Click, function()
    moveForward(5)
end)

local resetButton = makeButton("RESET TO NORMAL SPEED", 3)
connect(resetButton.MouseButton1Click, function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
        setStatus("WalkSpeed reset to 16")
    else
        setStatus("Character not ready", Color3.fromRGB(240, 120, 120))
    end
end)

local respawnButton = makeButton("REFRESH CHARACTER", 4)
connect(respawnButton.MouseButton1Click, function()
    refreshCharacterInfo()
end)

-- ==========================================
-- 🖱️ DRAG WINDOW
-- ==========================================

local dragging = false
local dragStart
local startPosition

connect(top.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        local ended
        ended = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if ended then
                    ended:Disconnect()
                end
            end
        end)
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

-- ==========================================
-- ♻️ CHARACTER RECOVERY
-- ==========================================

connect(LocalPlayer.CharacterAdded, function()
    task.wait(0.75)

    if ATNova.Unloaded then
        return
    end

    setStatus("Character loaded")
end)

-- ==========================================
-- ⌨️ TOGGLE
-- ==========================================

local visible = true

connect(UserInputService.InputBegan, function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        visible = not visible
        main.Visible = visible
    end
end)

-- ==========================================
-- 🧹 CLEAN UNLOAD
-- ==========================================

function ATNova:Unload()
    if self.Unloaded then
        return
    end

    self.Unloaded = true
    disconnectAll()

    if gui then
        gui:Destroy()
    end

    table.clear(self)
end

_G.ATNova = ATNova

print("[AT Nova Engine] Loaded v" .. ATNova.Version)
print("[AT Nova Engine] RightShift = Toggle UI")
print("[AT Nova Engine] Framework ready.")
