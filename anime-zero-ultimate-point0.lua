-- โหลด UI Library แบบคลีนและลื่นไหล
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Anime Zero | Ultimate Point 0 Hub",
   LoadingTitle = "Loading Ultimate System...",
   LoadingSubtitle = "Point 0 (10s Wait) & Robust Auto-Replay",
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
    CurrentState = "PointZeroWait",
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

local pointZeroStartTime = nil

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

MainTab:CreateSection("ระบบฟาร์ม (Point 0 Timer & Replay)")

MainTab:CreateToggle({
   Name = "เปิด/ปิด Ultimate Farm",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      getgenv().SmartConfig.Enabled = Value
      if Value then
          getgenv().SmartConfig.CurrentState = "PointZeroWait"
          getgenv().SmartConfig.WaypointIndex = 1
          pointZeroStartTime = nil
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

MainTab:CreateSection("ตั้งค่าความลื่น")

MainTab:CreateToggle({
   Name = "โหมดลดแลคสูงสุด (Anti-Lag)",
   CurrentValue = true,
   Flag = "ToggleLag",
   Callback = function(Value)
      if Value then
          pcall(function()
              settings():GetService("RenderSettings").QualityLevel = Enum.QualityLevel.Level01
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
              end
          end)
      end
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
            for _, v in pairs(playerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                    local text = v:IsA("TextButton") and v.Text:lower() or ""
                    local name = v.Name:lower()
                    if text:find("เล่นอีกครั้ง") or text:find("อีกครั้ง") or text:find("replay") or text:find("play again") or name:find("replay") then
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

                            getgenv().SmartConfig.CurrentState = "PointZeroWait"
                            getgenv().SmartConfig.WaypointIndex = 1
                            pointZeroStartTime = nil
                            lastWaypointIdx = nil
                            task.wait(2)
                        end
                    end
                end
            end
        end
    end)
end

local function getInitialMonster()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestTarget = nil
    local highestPriority = -1
    local shortestDist = math.huge

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= char then
            local isPlayer = Players:GetPlayerFromCharacter(v)
            local nameLower = v.Name:lower()
            if not isPlayer and not nameLower:find("breakable") and not nameLower:find("rubble") and not nameLower:find("door") and not nameLower:find("barrier") then
                local hum = v:FindFirstChildOfClass("Humanoid")
                local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("PrimaryPart")
                if hum and root and hum.Health > 0 then
                    local isBoss = v:GetAttribute("IsBoss") or nameLower:find("boss") ~= nil
                    local priority = isBoss and 2 or 1
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

                if currentState == "PointZeroWait" then
                    local distToP0 = (hrp.Position - PointZeroPosition).Magnitude
                    if distToP0 > 10 then
                        local flyP0CFrame = CFrame.new(PointZeroPosition + Vector3.new(0, 5, 0), PointZeroPosition)
                        hrp.CFrame = hrp.CFrame:Lerp(flyP0CFrame, getgenv().SmartConfig.Smoothness)
                        hrp.Velocity = Vector3.new(0,0,0)
                        pointZeroStartTime = nil
                    else
                        if not pointZeroStartTime then
                            pointZeroStartTime = tick()
                        end

                        local p0Elapsed = tick() - pointZeroStartTime
                        local waitCFrame = CFrame.new(PointZeroPosition + Vector3.new(0, 5, 0), PointZeroPosition)
                        hrp.CFrame = hrp.CFrame:Lerp(waitCFrame, 0.1)
                        hrp.Velocity = Vector3.new(0,0,0)

                        if p0Elapsed >= 10 then
                            getgenv().SmartConfig.CurrentState = "InitialFarm"
                        end
                    end

                elseif currentState == "InitialFarm" then
                    local mob = getInitialMonster()
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
                                        getgenv().SmartConfig.CurrentState = "WaitingReplay"
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
                                            getgenv().SmartConfig.CurrentState = "WaitingReplay"
                                        end
                                    end
                                end
                            end
                        end
                    else
                        getgenv().SmartConfig.CurrentState = "WaitingReplay"
                    end

                elseif currentState == "WaitingReplay" then
                    local flyP0CFrame = CFrame.new(PointZeroPosition + Vector3.new(0, 5, 0), PointZeroPosition)
                    hrp.CFrame = hrp.CFrame:Lerp(flyP0CFrame, 0.1)
                    hrp.Velocity = Vector3.new(0,0,0)
                    checkAndAutoReplay()
                end
            end
        end)
    end
end)

Rayfield:Notify({
   Title = "Ultra Smooth Hub Loaded",
   Content = "เปิดระบบเร่งความลื่น 'ลื่นปื๊ด' และจุด 0 สมบูรณ์แบบ!",
   Duration = 5,
   Image = 4483362458,
})