-- โหลด UI Library แบบคลีนและลื่นไหล
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Anime Zero | Responsive Smart Hub",
   LoadingTitle = "Loading Responsive System...",
   LoadingSubtitle = "No-Lag & Instant Action Smart Farm",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

getgenv().SmartConfig = {
    Enabled = false,
    AutoReplay = true,
    CombatHeight = 3.5,
    SafeHeight = 16,
    Smoothness = 0.35,
    LowHPEscape = 0.3,
    CurrentState = "GlobalFarm",
    WaypointIndex = 1,
    AntiLag = true
}

local PointZeroPosition = Vector3.new(-22, 3, 214)

local DungeonWaypoints = {
    {pos = Vector3.new(-12, 14, 144), type = "Obstacle"},
    {pos = Vector3.new(-7, 3, 71),   type = "Mob"},
    {pos = Vector3.new(-3, 3, -96),  type = "Obstacle"},
    {pos = Vector3.new(-5, 3, -187), type = "Mob"},
    {pos = Vector3.new(289, 13, -198), type = "Obstacle"},
    {pos = Vector3.new(379, 3, -206), type = "Mob"},
    {pos = Vector3.new(591, 21, -194), type = "Obstacle"},
    {pos = Vector3.new(293, 3, -40),  type = "Mob"}
}

local finalWaitTimer = nil

local function activateUltraSmoothBoost()
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
        settings():GetService("RenderSettings").QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
    end)
end

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

MainTab:CreateSection("ระบบฟาร์ม (Responsive Smart Mode)")

MainTab:CreateToggle({
   Name = "เปิด/ปิด Smart Farm (ลื่นปื๊ด)",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      getgenv().SmartConfig.Enabled = Value
      if Value then
          getgenv().SmartConfig.CurrentState = "GlobalFarm"
          getgenv().SmartConfig.WaypointIndex = 1
          finalWaitTimer = nil
          activateUltraSmoothBoost()
      end
   end,
})

MainTab:CreateToggle({
   Name = "เปิด/ปิด Auto-Replay (เล่นซ้ำอัตโนมัติ)",
   CurrentValue = true,
   Flag = "ToggleReplay",
   Callback = function(Value)
      getgenv().SmartConfig.AutoReplay = Value
   end,
})

MainTab:CreateSlider({
   Name = "ความสูงติดหัวเป้าหมาย (Combat Height)",
   Range = {2, 7},
   Increment = 0.5,
   Suffix = " Studs",
   CurrentValue = 3.5,
   Flag = "Slider1",
   Callback = function(Value)
      getgenv().SmartConfig.CombatHeight = Value
   end,
})

MainTab:CreateSection("ตั้งค่าเพิ่มเติม")

MainTab:CreateButton({
   Name = "⚡ เร่งความลื่นทันที (Boost FPS)",
   Callback = function()
      activateUltraSmoothBoost()
      Rayfield:Notify({ Title = "FPS Boosted", Content = "เปิดโหมดลื่นปื๊ดเรียบร้อย!", Duration = 3 })
   end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("การควบคุมสคริปต์")

SettingsTab:CreateButton({
   Name = "🛑 ปิดสคริปต์และลบ UI ทั้งหมด (Unload)",
   Callback = function()
      getgenv().SmartConfig.Enabled = false
      if getgenv().RunningConnection then
          getgenv().RunningConnection:Disconnect()
          getgenv().RunningConnection = nil
      end
      pcall(function() Rayfield:Destroy() end)
      pcall(function()
          for _, gui in pairs(game.CoreGui:GetChildren()) do
              if gui.Name:find("Rayfield") or gui.Name:find("AnimeZero") then gui:Destroy() end
          end
          for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
              if gui.Name:find("Rayfield") or gui.Name:find("AnimeZero") then gui:Destroy() end
          end
      end)
   end,
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function checkAndAutoReplay()
    if not getgenv().SmartConfig.AutoReplay then return end
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local foundButton = false
            for _, v in pairs(playerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                    local text = v:IsA("TextButton") and v.Text:lower() or ""
                    local name = v.Name:lower()
                    if text:find("เล่นอีกครั้ง") or text:find("อีกครั้ง") or text:find("replay") or text:find("play again") or name:find("replay") then
                        foundButton = true
                        local pos = v.AbsolutePosition + (v.AbsoluteSize / 2)
                        if pos.X > 0 and pos.Y > 0 then
                            if firesignal then
                                pcall(function() firesignal(v.MouseButton1Click) end)
                                pcall(function() firesignal(v.Activated) end)
                            end
                            local vim = game:GetService("VirtualInputManager")
                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                            task.wait(0.05)
                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                            pcall(function()
                                VirtualUser:Button1Down(Vector2.new(pos.X, pos.Y))
                                VirtualUser:Button1Up(Vector2.new(pos.X, pos.Y))
                            end)
                            getgenv().SmartConfig.CurrentState = "GlobalFarm"
                            getgenv().SmartConfig.WaypointIndex = 1
                            finalWaitTimer = nil
                            lastWaypointIdx = nil
                            task.wait(2)
                        end
                    end
                end
            end
            if not foundButton then
                for _, v in pairs(playerGui:GetDescendants()) do
                    if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                        local text = v:IsA("TextButton") and v.Text:lower() or ""
                        if text:find("เริ่ม") or text:find("start") or text:find("solo") or text:find("ready") then
                            local pos = v.AbsolutePosition + (v.AbsoluteSize / 2)
                            if pos.X > 0 and pos.Y > 0 then
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function getGlobalSmartTarget()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestTarget = nil
    local highestPriority = -1
    local shortestDist = math.huge

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= char then
            local isPlayer = Players:GetPlayerFromCharacter(v)
            if not isPlayer then
                local nameLower = v.Name:lower()
                if not nameLower:find("door") and not nameLower:find("barrier") and not nameLower:find("chest") and not nameLower:find("wall") then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("PrimaryPart")
                    if hum and root and hum.Health > 0 then
                        local isBoss = v:GetAttribute("IsBoss") or nameLower:find("boss") ~= nil
                        local isObstacle = nameLower:find("rubble") or nameLower:find("debris") or nameLower:find("breakable") or nameLower:find("rock")
                        local priority = 1
                        if isBoss then priority = 3
                        elseif not isObstacle then priority = 2
                        else priority = 1 end
                        local dist = (hrp.Position - root.Position).Magnitude
                        if priority > highestPriority or (priority == highestPriority and dist < shortestDist) then
                            highestPriority = priority
                            shortestDist = dist
                            bestTarget = root
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function countAndGetSmartTarget(wpPos, wpType)
    local count = 0
    local bestTarget = nil
    local highestPriority = -1
    local shortestDist = math.huge
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            if v ~= char then
                local isPlayer = Players:GetPlayerFromCharacter(v)
                if not isPlayer then
                    local nameLower = v.Name:lower()
                    local isObstacle = nameLower:find("rubble") or nameLower:find("debris") or nameLower:find("barrier") or nameLower:find("obstacle") or nameLower:find("door") or nameLower:find("chest") or nameLower:find("wall") or nameLower:find("breakable") or nameLower:find("rock") or nameLower:find("gate")
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("PrimaryPart") or (v:IsA("BasePart") and v)

                    if root then
                        local isValid = false
                        if wpType == "Mob" and hum and hum.Health > 0 and not isObstacle then
                            isValid = true
                        elseif wpType == "Obstacle" and (isObstacle or (hum and hum.Health > 0)) then
                            isValid = true
                        end

                        if isValid then
                            local distToWp = (wpPos - root.Position).Magnitude
                            if distToWp < 75 then
                                count = count + 1
                                local isBoss = v:GetAttribute("IsBoss") or nameLower:find("boss") ~= nil
                                local priority = isBoss and 2 or 1
                                if hrp then
                                    local distToPlayer = (hrp.Position - root.Position).Magnitude
                                    if priority > highestPriority or (priority == highestPriority and distToPlayer < shortestDist) then
                                        highestPriority = priority
                                        shortestDist = distToPlayer
                                        bestTarget = root
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return count, bestTarget
end

local lastSkillTime = 0
local skillCooldown = 3.0

local function executeCombat(char)
    local currentTime = tick()
    if currentTime - lastSkillTime >= skillCooldown then
        local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three}
        for _, key in ipairs(skillKeys) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.02)
        end
        lastSkillTime = currentTime
    end
end

local lastWaypointIdx = nil
local obstacleStartTime = nil
local mobEmptyTimer = nil
local hasArrivedAtWaypoint = false

if getgenv().RunningConnection then
    getgenv().RunningConnection:Disconnect()
    getgenv().RunningConnection = nil
end

getgenv().RunningConnection = RunService.Stepped:Connect(function()
    if getgenv().SmartConfig.Enabled then
        pcall(function()
            checkAndAutoReplay()

            local char = getCharacter()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                if hpPercent <= getgenv().SmartConfig.LowHPEscape then
                    local escapePos = hrp.Position + Vector3.new(0, 40, 0)
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(escapePos), 0.2)
                    hrp.Velocity = Vector3.new(0,0,0)
                    return
                end

                local currentState = getgenv().SmartConfig.CurrentState

                if currentState == "GlobalFarm" then
                    local mob = getGlobalSmartTarget()
                    if mob then
                        executeCombat(char)
                        local targetPos = mob.Position + Vector3.new(0, getgenv().SmartConfig.CombatHeight, 0)
                        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, mob.Position), getgenv().SmartConfig.Smoothness)
                        hrp.Velocity = Vector3.new(0,0,0)
                    else
                        getgenv().SmartConfig.CurrentState = "WaypointFarm"
                        getgenv().SmartConfig.WaypointIndex = 1
                        lastWaypointIdx = nil
                    end

                elseif currentState == "WaypointFarm" then
                    local globalMob = getGlobalSmartTarget()
                    if globalMob and (globalMob.Position - hrp.Position).Magnitude < 100 then
                        executeCombat(char)
                        local targetPos = globalMob.Position + Vector3.new(0, getgenv().SmartConfig.CombatHeight, 0)
                        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, globalMob.Position), getgenv().SmartConfig.Smoothness)
                        hrp.Velocity = Vector3.new(0,0,0)
                        return
                    end

                    local idx = getgenv().SmartConfig.WaypointIndex
                    local wpData = DungeonWaypoints[idx]

                    if wpData then
                        if lastWaypointIdx ~= idx then
                            lastWaypointIdx = idx
                            obstacleStartTime = nil
                            mobEmptyTimer = nil
                            hasArrivedAtWaypoint = false
                        end

                        local distToWp = (hrp.Position - wpData.pos).Magnitude

                        if distToWp > 12 and not hasArrivedAtWaypoint then
                            local flyPos = wpData.pos + Vector3.new(0, 5, 0)
                            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(flyPos, wpData.pos), getgenv().SmartConfig.Smoothness)
                            hrp.Velocity = Vector3.new(0,0,0)
                        else
                            hasArrivedAtWaypoint = true

                            if wpData.type == "Obstacle" then
                                if not obstacleStartTime then
                                    obstacleStartTime = tick()
                                end

                                local elapsed = tick() - obstacleStartTime
                                if elapsed < 8 then
                                    local count, targetRoot = countAndGetSmartTarget(wpData.pos, "Obstacle")
                                    executeCombat(char)
                                    local targetPos = (targetRoot and targetRoot.Position or wpData.pos) + Vector3.new(0, 4, 0)
                                    local lookTarget = targetRoot and targetRoot.Position or wpData.pos
                                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, lookTarget), getgenv().SmartConfig.Smoothness)
                                    hrp.Velocity = Vector3.new(0,0,0)
                                else
                                    if idx < #DungeonWaypoints then
                                        getgenv().SmartConfig.WaypointIndex = idx + 1
                                    else
                                        getgenv().SmartConfig.CurrentState = "CheckFinalPoint"
                                        finalWaitTimer = tick()
                                    end
                                end

                            elseif wpData.type == "Mob" then
                                local count, targetRoot = countAndGetSmartTarget(wpData.pos, "Mob")

                                if count > 0 and targetRoot then
                                    mobEmptyTimer = nil
                                    local currentTime = tick()
                                    local isCoolingDown = (currentTime - lastSkillTime < skillCooldown)
                                    local currentHeight = isCoolingDown and getgenv().SmartConfig.SafeHeight or getgenv().SmartConfig.CombatHeight

                                    executeCombat(char)

                                    local targetPos = targetRoot.Position + Vector3.new(0, currentHeight, 0)
                                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, targetRoot.Position), getgenv().SmartConfig.Smoothness)
                                    hrp.Velocity = Vector3.new(0,0,0)
                                else
                                    if not mobEmptyTimer then
                                        mobEmptyTimer = tick()
                                    end

                                    local emptyElapsed = tick() - mobEmptyTimer
                                    if emptyElapsed < 4 then
                                        local waitPos = wpData.pos + Vector3.new(0, 5, 0)
                                        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(waitPos, wpData.pos), getgenv().SmartConfig.Smoothness)
                                        hrp.Velocity = Vector3.new(0,0,0)
                                    else
                                        if idx < #DungeonWaypoints then
                                            getgenv().SmartConfig.WaypointIndex = idx + 1
                                        else
                                            getgenv().SmartConfig.CurrentState = "CheckFinalPoint"
                                            finalWaitTimer = tick()
                                        end
                                    end
                                end
                            end
                        end
                    else
                        getgenv().SmartConfig.CurrentState = "CheckFinalPoint"
                        finalWaitTimer = tick()
                    end

                elseif currentState == "CheckFinalPoint" then
                    local finalElapsed = tick() - (finalWaitTimer or tick())
                    local mob = getGlobalSmartTarget()
                    if mob then
                        getgenv().SmartConfig.CurrentState = "WaypointFarm"
                    else
                        local wp8 = DungeonWaypoints[8].pos
                        local waitCFrame = CFrame.new(wp8 + Vector3.new(0, 5, 0), wp8)
                        hrp.CFrame = hrp.CFrame:Lerp(waitCFrame, 0.1)
                        hrp.Velocity = Vector3.new(0,0,0)

                        if finalElapsed >= 8 then
                            getgenv().SmartConfig.CurrentState = "ReturnToPointZero"
                        end
                    end

                elseif currentState == "ReturnToPointZero" then
                    local distToP0 = (hrp.Position - PointZeroPosition).Magnitude
                    if distToP0 > 8 then
                        local flyP0CFrame = CFrame.new(PointZeroPosition + Vector3.new(0, 5, 0), PointZeroPosition)
                        hrp.CFrame = hrp.CFrame:Lerp(flyP0CFrame, getgenv().SmartConfig.Smoothness)
                        hrp.Velocity = Vector3.new(0,0,0)
                    else
                        local waitCFrame = CFrame.new(PointZeroPosition + Vector3.new(0, 5, 0), PointZeroPosition)
                        hrp.CFrame = hrp.CFrame:Lerp(waitCFrame, 0.1)
                        hrp.Velocity = Vector3.new(0,0,0)

                        checkAndAutoReplay()
                        local mob = getGlobalSmartTarget()
                        if mob then
                            getgenv().SmartConfig.CurrentState = "GlobalFarm"
                        end
                    end
                end
            end
        end)
    end
end)

Rayfield:Notify({
   Title = "Responsive Smart Loaded",
   Content = "แก้ปัญหาตัวละครยืนนิ่ง เพิ่มระบบสแกนสากลและจุด 0 สมบูรณ์แบบ!",
   Duration = 5,
   Image = 4483362458,
})
