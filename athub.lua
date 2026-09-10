-- ==========================================
-- ⚡ AT Hub - Developer Hub v26.0
-- ==========================================
-- UI + movement + ESP + teleport + safety
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local OriginalStats = {WalkSpeed = 16, JumpPower = 50, Gravity = Workspace.Gravity}
local Config = {
    UIScale = 1,
    SpeedEnabled = false, SpeedVal = 16,
    JumpEnabled = false, JumpVal = 50,
    GravityEnabled = false, GravityVal = 196,
    NoClipEnabled = false,
    ESPEnabled = false, ESPTeamCheck = true,
    FOVEnabled = false, FOVSize = 150,
    SavedPositions = {}
}

local function backup(hum)
    if hum then
        OriginalStats.WalkSpeed = hum.WalkSpeed
        OriginalStats.JumpPower = hum.JumpPower
    end
end
if LocalPlayer.Character then backup(LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AT_DevHub_v26"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Launcher = Instance.new("TextButton")
Launcher.Size = UDim2.fromOffset(54,54)
Launcher.Position = UDim2.new(.04,0,.2,0)
Launcher.BackgroundColor3 = Color3.fromRGB(12,16,24)
Launcher.Text = "AT"
Launcher.TextColor3 = Color3.fromRGB(0,210,255)
Launcher.Font = Enum.Font.GothamBold
Launcher.TextSize = 17
Launcher.Active = true
Launcher.Draggable = true
Launcher.Parent = ScreenGui
Instance.new("UICorner",Launcher).CornerRadius = UDim.new(0,12)
local ls = Instance.new("UIStroke",Launcher)
ls.Color = Color3.fromRGB(0,180,255)
ls.Thickness = 1.5

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(500,390)
Main.Position = UDim2.new(.5,-250,.5,-195)
Main.BackgroundColor3 = Color3.fromRGB(11,14,21)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,40)
Top.BackgroundColor3 = Color3.fromRGB(18,23,33)
Top.Parent = Main
Instance.new("UICorner",Top).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,1,0)
Title.Position = UDim2.fromOffset(14,0)
Title.BackgroundTransparency = 1
Title.Text = "AT HUB  •  V26.0"
Title.TextColor3 = Color3.fromRGB(225,240,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40,40)
Close.Position = UDim2.new(1,-40,0,0)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255,90,90)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 22
Close.Parent = Top

local Side = Instance.new("ScrollingFrame")
Side.Size = UDim2.fromOffset(120,340)
Side.Position = UDim2.fromOffset(6,45)
Side.BackgroundColor3 = Color3.fromRGB(16,20,29)
Side.ScrollBarThickness = 2
Side.AutomaticCanvasSize = Enum.AutomaticSize.Y
Side.Parent = Main
Instance.new("UICorner",Side).CornerRadius = UDim.new(0,8)
local sl = Instance.new("UIListLayout",Side)
sl.Padding = UDim.new(0,5)
sl.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-132,1,-48)
Content.Position = UDim2.fromOffset(126,45)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local function newPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 3
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = Content
    local l = Instance.new("UIListLayout",p)
    l.Padding = UDim.new(0,6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = p
    return p
end

local function addTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(.92,0,0,32)
    b.BackgroundColor3 = Color3.fromRGB(23,29,41)
    b.TextColor3 = Color3.fromRGB(200,215,235)
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Parent = Side
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        for _,p in pairs(Pages) do p.Visible=false end
        Pages[name].Visible=true
    end)
end

local Movement = newPage("Movement")
local Visuals = newPage("Visuals")
local Teleport = newPage("Teleport")
local Settings = newPage("Settings")
local Safety = newPage("Safety")
local Info = newPage("Info")

for _,n in ipairs({"Movement","Visuals","Teleport","Settings","Safety","Info"}) do addTab(n) end
Movement.Visible = true

local function toggle(parent,text,key,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(.95,0,0,32)
    b.BackgroundColor3 = Color3.fromRGB(21,26,37)
    b.TextColor3 = Color3.fromRGB(220,230,245)
    b.Text = text.."  [OFF]"
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Parent = parent
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local state=false
    b.MouseButton1Click:Connect(function()
        state=not state
        Config[key]=state
        b.Text=text..(state and "  [ON]" or "  [OFF]")
        b.BackgroundColor3=state and Color3.fromRGB(0,125,190) or Color3.fromRGB(21,26,37)
        if callback then pcall(callback,state) end
    end)
    return b
end

local function slider(parent,text,min,max,default,callback)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(.95,0,0,46)
    f.BackgroundColor3=Color3.fromRGB(18,23,33)
    f.Parent=parent
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(1,-12,0,18)
    t.Position=UDim2.fromOffset(6,2)
    t.BackgroundTransparency=1
    t.Text=text..": "..default
    t.TextColor3=Color3.fromRGB(205,220,240)
    t.Font=Enum.Font.GothamSemibold
    t.TextSize=10
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.Parent=f
    local bar=Instance.new("TextButton")
    bar.Size=UDim2.new(1,-12,0,14)
    bar.Position=UDim2.fromOffset(6,26)
    bar.BackgroundColor3=Color3.fromRGB(8,11,17)
    bar.Text=""
    bar.Parent=f
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame")
    fill.BackgroundColor3=Color3.fromRGB(0,175,240)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.Parent=bar
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local drag=false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local pct=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local v=math.floor(min+(max-min)*pct)
            fill.Size=UDim2.new(pct,0,1,0)
            t.Text=text..": "..v
            pcall(callback,v)
        end
    end)
end

slider(Movement,"WalkSpeed",16,300,16,function(v) Config.SpeedVal=v end)
toggle(Movement,"WalkSpeed Override","SpeedEnabled",function(v)
    if not v and LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=OriginalStats.WalkSpeed end
    end
end)

slider(Movement,"JumpPower",50,300,50,function(v) Config.JumpVal=v end)
toggle(Movement,"JumpPower Override","JumpEnabled",function(v)
    if not v and LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower=OriginalStats.JumpPower end
    end
end)

slider(Movement,"Gravity",0,300,196,function(v) Config.GravityVal=v end)
toggle(Movement,"Custom Gravity","GravityEnabled",function(v)
    if not v then Workspace.Gravity=OriginalStats.Gravity end
end)
toggle(Movement,"NoClip","NoClipEnabled")

toggle(Visuals,"Player Highlight","ESPEnabled")
toggle(Visuals,"Team Check","ESPTeamCheck")
toggle(Visuals,"FOV Circle","FOVEnabled")

slider(Visuals,"FOV Size",50,400,150,function(v) Config.FOVSize=v end)

local FOV=Instance.new("Frame")
FOV.BackgroundTransparency=1
FOV.Parent=ScreenGui
Instance.new("UICorner",FOV).CornerRadius=UDim.new(1,0)
local fs=Instance.new("UIStroke",FOV)
fs.Color=Color3.fromRGB(0,180,255)
fs.Thickness=1.5

local function saveButton(parent,index)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(.95,0,0,32)
    b.BackgroundColor3=Color3.fromRGB(22,29,41)
    b.TextColor3=Color3.fromRGB(220,230,245)
    b.Text="Save Position "..index
    b.Font=Enum.Font.GothamSemibold
    b.TextSize=11
    b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then Config.SavedPositions[index]=r.CFrame; b.Text="Position "..index.." Saved!" end
    end)
    local tp=Instance.new("TextButton")
    tp.Size=UDim2.new(.95,0,0,32)
    tp.BackgroundColor3=Color3.fromRGB(0,105,170)
    tp.TextColor3=Color3.new(1,1,1)
    tp.Text="Teleport Position "..index
    tp.Font=Enum.Font.GothamSemibold
    tp.TextSize=11
    tp.Parent=parent
    Instance.new("UICorner",tp).CornerRadius=UDim.new(0,6)
    tp.MouseButton1Click:Connect(function()
        local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r and Config.SavedPositions[index] then r.CFrame=Config.SavedPositions[index] end
    end)
end
saveButton(Teleport,1)
saveButton(Teleport,2)
saveButton(Teleport,3)

local refresh=Instance.new("TextButton")
refresh.Size=UDim2.new(.95,0,0,32)
refresh.BackgroundColor3=Color3.fromRGB(0,110,180)
refresh.TextColor3=Color3.new(1,1,1)
refresh.Text="Refresh Player Teleport List"
refresh.Font=Enum.Font.GothamBold
refresh.TextSize=11
refresh.Parent=Teleport
Instance.new("UICorner",refresh).CornerRadius=UDim.new(0,6)

local playerList=Instance.new("ScrollingFrame")
playerList.Size=UDim2.new(.95,0,0,130)
playerList.BackgroundTransparency=1
playerList.ScrollBarThickness=3
playerList.Parent=Teleport
local pl=Instance.new("UIListLayout",playerList)
pl.Padding=UDim.new(0,3)

refresh.MouseButton1Click:Connect(function()
    for _,c in ipairs(playerList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local b=Instance.new("TextButton")
            b.Size=UDim2.new(1,0,0,28)
            b.BackgroundColor3=Color3.fromRGB(22,28,40)
            b.TextColor3=Color3.fromRGB(220,230,245)
            b.Text=p.DisplayName
            b.Font=Enum.Font.Gotham
            b.TextSize=10
            b.Parent=playerList
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
            b.MouseButton1Click:Connect(function()
                local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r and tr then r.CFrame=tr.CFrame*CFrame.new(0,3,0) end
            end)
        end
    end
end)

slider(Settings,"UI Scale",80,120,100,function(v) Config.UIScale=v/100 end)
toggle(Settings,"Remove Fog","NoFogEnabled",function(v) Lighting.FogEnd=v and 100000 or 1000 end)
toggle(Settings,"Disable Post Effects","RemoveEffects",function(v)
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("PostEffect") then o.Enabled=not v end
    end
end)

local emergency=Instance.new("TextButton")
emergency.Size=UDim2.new(.95,0,0,50)
emergency.BackgroundColor3=Color3.fromRGB(210,40,40)
emergency.TextColor3=Color3.new(1,1,1)
emergency.Text="EMERGENCY STOP"
emergency.Font=Enum.Font.GothamBold
emergency.TextSize=13
emergency.Parent=Safety
Instance.new("UICorner",emergency).CornerRadius=UDim.new(0,8)

emergency.MouseButton1Click:Connect(function()
    Config.SpeedEnabled=false
    Config.JumpEnabled=false
    Config.GravityEnabled=false
    Config.NoClipEnabled=false
    Config.ESPEnabled=false
    Config.FOVEnabled=false
    Workspace.Gravity=OriginalStats.Gravity
    local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=OriginalStats.WalkSpeed; h.JumpPower=OriginalStats.JumpPower end
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h2=p.Character:FindFirstChild("AT_ESP")
            if h2 then h2:Destroy() end
        end
    end
end)

local inf=Instance.new("TextLabel")
inf.Size=UDim2.new(.95,0,0,170)
inf.BackgroundColor3=Color3.fromRGB(16,20,28)
inf.TextColor3=Color3.fromRGB(210,225,245)
inf.Text="AT HUB V26.0\n\nDeveloper Utility Edition\n\nMovement • Visuals • Teleport\nSettings • Safety\n\nEmergency Stop included."
inf.Font=Enum.Font.Gotham
inf.TextSize=11
inf.TextXAlignment=Enum.TextXAlignment.Left
inf.TextYAlignment=Enum.TextYAlignment.Top
inf.Parent=Info
Instance.new("UICorner",inf).CornerRadius=UDim.new(0,7)

RunService.Stepped:Connect(function()
    local c=LocalPlayer.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        if Config.SpeedEnabled then h.WalkSpeed=Config.SpeedVal end
        if Config.JumpEnabled then h.UseJumpPower=true; h.JumpPower=Config.JumpVal end
    end
    if Config.GravityEnabled then Workspace.Gravity=Config.GravityVal end
    if c and Config.NoClipEnabled then
        for _,o in ipairs(c:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end
    end
end)

RunService.RenderStepped:Connect(function()
    FOV.Size=UDim2.fromOffset(Config.FOVSize,Config.FOVSize)
    FOV.Position=UDim2.fromScale(.5,.5)
    FOV.AnchorPoint=Vector2.new(.5,.5)
    FOV.Visible=Config.FOVEnabled

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local old=p.Character:FindFirstChild("AT_ESP")
            local show=Config.ESPEnabled and not (Config.ESPTeamCheck and p.Team==LocalPlayer.Team)
            if show and not old then
                local h=Instance.new("Highlight")
                h.Name="AT_ESP"
                h.FillColor=Color3.fromRGB(0,180,255)
                h.OutlineColor=Color3.fromRGB(255,255,255)
                h.FillTransparency=.5
                h.Parent=p.Character
            elseif not show and old then
                old:Destroy()
            end
        end
    end
end)

Close.MouseButton1Click:Connect(function() Main.Visible=false end)
Launcher.MouseButton1Click:Connect(function() Main.Visible=not Main.Visible end)

LocalPlayer.CharacterAdded:Connect(function(c)
    local h=c:WaitForChild("Humanoid",5)
    if h then task.wait(.2); backup(h) end
end)

print("[AT Hub] V26.0 loaded.")
