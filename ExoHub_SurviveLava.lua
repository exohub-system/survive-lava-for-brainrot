-- ╔═══════════════════════════════════╗
--   EXO HUB | SURVIVE LAVA
--   WindUI | discord.gg/6QzV9pTWs
-- ╚═══════════════════════════════════╝

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local lp              = Players.LocalPlayer

-- ══════════════════════════════════════
--  LOAD WINDUI
-- ══════════════════════════════════════
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ══════════════════════════════════════
--  STATE
-- ══════════════════════════════════════
local antiLavaConn   = nil
local autoJumpConn   = nil
local infJumpConn    = nil
local flyConn        = nil
local espConn        = nil
local flyActive      = false
local bodyGyro       = nil
local bodyVel        = nil
local flySpeed       = 50
local espObjects     = {}

-- ══════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════
local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- find highest platform above lava
local function getHighestPlatform()
    local best, bestY = nil, -math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local n = obj.Name:lower()
            -- skip lava parts
            if not (n:find("lava") or n:find("kill") or n:find("fire") or n:find("death")) then
                if obj.Size.Y < 10 and obj.Size.X > 3 and obj.Position.Y > bestY then
                    bestY = obj.Position.Y
                    best  = obj
                end
            end
        end
    end
    return best
end

local function isLava(part)
    if not part then return false end
    local n = part.Name:lower()
    local m = part.Material
    return n:find("lava") or n:find("kill") or n:find("fire") or n:find("death")
        or m == Enum.Material.Neon
        or (part.BrickColor == BrickColor.new("Bright orange") and part.CanCollide == false)
end

-- ══════════════════════════════════════
--  ANTI LAVA
-- ══════════════════════════════════════
local function startAntiLava()
    antiLavaConn = RunService.Heartbeat:Connect(function()
        local char = getChar()
        local hrp  = getHRP()
        local hum  = getHum()
        if not char or not hrp or not hum then return end

        -- lock health
        hum.Health = hum.MaxHealth

        -- if we're touching lava, teleport up
        pcall(function()
            local touching = hrp:GetTouchingParts()
            for _, part in ipairs(touching) do
                if isLava(part) then
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0)
                    break
                end
            end
        end)

        -- if below lava level, tp up
        if hrp.Position.Y < 5 then
            local platform = getHighestPlatform()
            if platform then
                hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, platform.Size.Y/2 + 3, 0))
            else
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
            end
        end
    end)
end

local function stopAntiLava()
    if antiLavaConn then antiLavaConn:Disconnect(); antiLavaConn = nil end
end

-- ══════════════════════════════════════
--  AUTO JUMP TO HIGHEST PLATFORM
-- ══════════════════════════════════════
local function startAutoJump()
    autoJumpConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local platform = getHighestPlatform()
        if platform then
            local target = platform.Position + Vector3.new(0, platform.Size.Y/2 + 3, 0)
            -- only tp if we're significantly lower
            if target.Y - hrp.Position.Y > 10 then
                hrp.CFrame = CFrame.new(target)
            end
        end
    end)
end

local function stopAutoJump()
    if autoJumpConn then autoJumpConn:Disconnect(); autoJumpConn = nil end
end

-- ══════════════════════════════════════
--  INFINITE JUMP
-- ══════════════════════════════════════
local function startInfJump()
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
end

-- ══════════════════════════════════════
--  SPEED
-- ══════════════════════════════════════
local function setSpeed(on)
    local hum = getHum()
    if hum then hum.WalkSpeed = on and 80 or 16 end
end

-- ══════════════════════════════════════
--  FLY
-- ══════════════════════════════════════
local function startFly()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    hum.PlatformStand = true
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero
    bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVel.P = 9e4
    bodyVel.Parent = hrp
    local cam = workspace.CurrentCamera
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        bodyGyro.CFrame  = cam.CFrame
    end)
end

local function stopFly()
    flyActive = false
    if flyConn  then flyConn:Disconnect();  flyConn  = nil end
    if bodyGyro then bodyGyro:Destroy();    bodyGyro = nil end
    if bodyVel  then bodyVel:Destroy();     bodyVel  = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end

-- ══════════════════════════════════════
--  AUTO WIN (tp to highest point)
-- ══════════════════════════════════════
local function autoWin()
    local hrp = getHRP()
    if not hrp then return end
    local platform = getHighestPlatform()
    if platform then
        hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, platform.Size.Y/2 + 3, 0))
        WindUI:Notify({
            Title   = "EXO HUB",
            Content = "Teleported to highest platform! 🔥",
            Duration = 3,
        })
    else
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0)
        WindUI:Notify({
            Title   = "EXO HUB",
            Content = "Teleported up! 🔥",
            Duration = 3,
        })
    end
end

-- ══════════════════════════════════════
--  PLAYER ESP
-- ══════════════════════════════════════
local espActive = false

local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function startESP()
    espActive = true
    espConn = RunService.Heartbeat:Connect(function()
        if not espActive then clearESP(); return end
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0,80,0,30)
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = root
                    bb.Parent = workspace
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = p.DisplayName
                    lbl.TextColor3 = Color3.fromRGB(0,180,255)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 13
                    lbl.Parent = bb
                    local hl = Instance.new("SelectionBox")
                    hl.Adornee = p.Character
                    hl.Color3 = Color3.fromRGB(0,120,255)
                    hl.LineThickness = 0.04
                    hl.SurfaceTransparency = 0.85
                    hl.SurfaceColor3 = Color3.fromRGB(0,100,255)
                    hl.Parent = workspace
                    table.insert(espObjects, bb)
                    table.insert(espObjects, hl)
                end
            end
        end
    end)
end

local function stopESP()
    espActive = false
    if espConn then espConn:Disconnect(); espConn = nil end
    clearESP()
end

-- respawn
lp.CharacterAdded:Connect(function()
    task.wait(1)
    if antiLavaConn then stopAntiLava(); startAntiLava() end
    if autoJumpConn then stopAutoJump(); startAutoJump() end
    if infJumpConn  then stopInfJump();  startInfJump()  end
    if flyActive    then startFly() end
end)

-- ══════════════════════════════════════
--  WINDUI WINDOW
-- ══════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title  = "EXO HUB",
    Icon   = "flame",
    Author = "discord.gg/6QzV9pTWs",
    Folder = "ExoHub",
    Size   = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme  = "Dark",
})

-- ══════════════════════════════════════
--  TABS
-- ══════════════════════════════════════
local SurviveTab  = Window:Tab({ Title = "Survive",  Icon = "shield" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })
local VisualsTab  = Window:Tab({ Title = "Visuals",  Icon = "eye" })
local MiscTab     = Window:Tab({ Title = "Misc",     Icon = "settings" })

-- ══════════════════════════════════════
--  SURVIVE TAB
-- ══════════════════════════════════════
local SurviveSection = SurviveTab:Section({ Title = "Survival" })

SurviveSection:Toggle({
    Title = "Anti Lava",
    Desc  = "Prevents lava from killing you + locks health at max",
    Icon  = "shield",
    Value = false,
    Callback = function(state)
        if state then startAntiLava() else stopAntiLava() end
    end
})

SurviveSection:Toggle({
    Title = "Auto Jump",
    Desc  = "Automatically teleports you to the highest platform",
    Icon  = "arrow-up",
    Value = false,
    Callback = function(state)
        if state then startAutoJump() else stopAutoJump() end
    end
})

SurviveSection:Toggle({
    Title = "Infinite Jump",
    Desc  = "Jump as many times as you want in the air",
    Icon  = "chevrons-up",
    Value = false,
    Callback = function(state)
        if state then startInfJump() else stopInfJump() end
    end
})

SurviveSection:Button({
    Title = "Auto Win",
    Desc  = "Instantly teleports you to the highest point on the map",
    Icon  = "trophy",
    Callback = function()
        autoWin()
    end
})

-- ══════════════════════════════════════
--  MOVEMENT TAB
-- ══════════════════════════════════════
local MovementSection = MovementTab:Section({ Title = "Movement" })

MovementSection:Toggle({
    Title = "Speed Hack",
    Desc  = "Boosts your walk speed to 80",
    Icon  = "zap",
    Value = false,
    Callback = function(state)
        setSpeed(state)
    end
})

MovementSection:Toggle({
    Title = "Fly",
    Desc  = "WASD to fly  •  Space up  •  Shift down",
    Icon  = "plane",
    Value = false,
    Callback = function(state)
        if state then flyActive = true; startFly() else stopFly() end
    end
})

MovementSection:Slider({
    Title = "Fly Speed",
    Desc  = "Controls how fast you fly",
    Icon  = "gauge",
    Min   = 10,
    Max   = 150,
    Value = 50,
    Callback = function(val)
        flySpeed = val
    end
})

-- ══════════════════════════════════════
--  VISUALS TAB
-- ══════════════════════════════════════
local VisualsSection = VisualsTab:Section({ Title = "ESP" })

VisualsSection:Toggle({
    Title = "Player ESP",
    Desc  = "See all players through walls with name tags",
    Icon  = "eye",
    Value = false,
    Callback = function(state)
        if state then startESP() else stopESP() end
    end
})

-- ══════════════════════════════════════
--  MISC TAB
-- ══════════════════════════════════════
local MiscSection = MiscTab:Section({ Title = "EXO HUB" })

MiscSection:Paragraph({
    Title = "EXO HUB — Survive Lava",
    Desc  = "Free forever. Always updating.\ndiscord.gg/6QzV9pTWs",
})

MiscSection:Button({
    Title = "Join Discord",
    Desc  = "discord.gg/6QzV9pTWs",
    Icon  = "message-circle",
    Callback = function()
        WindUI:Notify({
            Title   = "EXO HUB",
            Content = "Join us at discord.gg/6QzV9pTWs 🔥",
            Duration = 4,
        })
    end
})

print("[EXO HUB] Survive Lava for Brainrot loaded | discord.gg/6QzV9pTWs")
