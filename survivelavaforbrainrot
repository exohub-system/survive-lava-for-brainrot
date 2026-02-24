-- ╔═══════════════════════════════════════════════╗
--   ✦ EXO HUB | Survive the Lava for Brainrot
--   discord.gg/TzNds43vb  ·  Delta Ready
-- ╚═══════════════════════════════════════════════╝

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ╔══════════════════╗
--   STATES
-- ╚══════════════════╝

local states = {
    godMode      = false,
    antiLava     = false,
    fly          = false,
    speed        = false,
    noclip       = false,
    autoSafe     = false,
    espPlatforms = false,
    espPlayers   = false,
    fullbright   = false,
    autoRejoin   = false,
}

local flyActive     = false
local tpwalking     = false
local noclipConn    = nil
local antiLavaConn  = nil
local autoSafeConn  = nil
local espConn       = nil
local healthConns   = {}
local espObjs       = {}
local origAmbient   = Lighting.Ambient
local origBright    = Lighting.Brightness
local origFog       = Lighting.FogEnd
local origShadows   = Lighting.GlobalShadows

-- ╔══════════════════╗
--   GOD MODE
-- ╚══════════════════╝

local function setupGodMode(char)
    if not char then return end
    for _, c in pairs(healthConns) do if c then c:Disconnect() end end
    healthConns = {}
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.BreakJointsOnDeath = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    local ff = Instance.new("ForceField"); ff.Visible = false; ff.Parent = char
    local c = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if states.godMode and hum.Health <= 0 then task.wait(0.05); hum.Health = hum.MaxHealth end
    end)
    table.insert(healthConns, c)
end

local function stopGodMode()
    for _, c in pairs(healthConns) do if c then c:Disconnect() end end
    healthConns = {}
    local char = player.Character
    if char then
        local ff = char:FindFirstChildOfClass("ForceField"); if ff then ff:Destroy() end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end
    end
end

-- ╔══════════════════╗
--   ANTI LAVA
--   Prevents lava damage by locking health
--   and removing lava touch connections
-- ╚══════════════════╝

local function startAntiLava()
    antiLavaConn = RunService.Heartbeat:Connect(function()
        if not states.antiLava then return end
        local char = player.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        -- Lock health if it drops
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        -- Make all character parts non-collidable with lava
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("lava") or n:find("fire") or n:find("hot") or n:find("danger") or n:find("kill") or n:find("acid") then
                    pcall(function()
                        -- Remove any scripts/touch events on lava
                        for _, s in ipairs(obj:GetChildren()) do
                            if s:IsA("Script") or s:IsA("LocalScript") then
                                s.Disabled = true
                            end
                        end
                    end)
                end
            end
        end
    end)
end

local function stopAntiLava()
    if antiLavaConn then antiLavaConn:Disconnect(); antiLavaConn = nil end
end

-- ╔══════════════════╗
--   SPEED
-- ╚══════════════════╝

local function setSpeed(on)
    local hum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.WalkSpeed = on and 50 or 16 end
end

-- ╔══════════════════╗
--   FLY
-- ╚══════════════════╝

local function startTpWalking()
    tpwalking = false
    spawn(function()
        local hb = RunService.Heartbeat; tpwalking = true
        local chr = player.Character
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
            if hum.MoveDirection.Magnitude > 0 then chr:TranslateBy(hum.MoveDirection) end
        end
    end)
end

local function startFly()
    local char = player.Character; if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
    local isR6 = hum.RigType == Enum.HumanoidRigType.R6
    local torso = isR6 and char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"); if not torso then return end
    char.Animate.Disabled = true
    for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
    for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s, false) end) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming); startTpWalking(); hum.PlatformStand = true
    local bg = Instance.new("BodyGyro", torso); bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9); bg.cframe=torso.CFrame
    local bv = Instance.new("BodyVelocity", torso); bv.velocity=Vector3.new(0,0.1,0); bv.maxForce=Vector3.new(9e9,9e9,9e9)
    local ctrl={f=0,b=0,l=0,r=0}; local last={f=0,b=0,l=0,r=0}; local ms=60; local spd=0; local conn
    conn = RunService.RenderStepped:Connect(function()
        if not flyActive then
            conn:Disconnect(); pcall(function() bg:Destroy() end); pcall(function() bv:Destroy() end)
            hum.PlatformStand=false; char.Animate.Disabled=false; tpwalking=false
            for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s, true) end) end
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics); return
        end
        ctrl.f=UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
        ctrl.b=UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
        ctrl.l=UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
        ctrl.r=UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
        if ctrl.l+ctrl.r~=0 or ctrl.f+ctrl.b~=0 then spd=math.min(spd+0.5+(spd/ms),ms) else spd=math.max(spd-1,0) end
        local cam=workspace.CurrentCamera.CoordinateFrame
        if (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0 then
            bv.velocity=((cam.lookVector*(ctrl.f+ctrl.b))+((cam*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-cam.p))*spd
            last={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
        elseif spd~=0 then
            bv.velocity=((cam.lookVector*(last.f+last.b))+((cam*CFrame.new(last.l+last.r,(last.f+last.b)*.2,0).p)-cam.p))*spd
        else bv.velocity=Vector3.new(0,0,0) end
        bg.cframe=cam*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*spd/ms),0,0)
    end)
end

-- ╔══════════════════╗
--   NOCLIP
-- ╚══════════════════╝

local function startNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not states.noclip then return end
        local char = player.Character
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end)
end
local function stopNoclip() if noclipConn then noclipConn:Disconnect(); noclipConn=nil end end

-- ╔══════════════════╗
--   FULLBRIGHT
-- ╚══════════════════╝

local function setFullbright(on)
    if on then
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.Brightness=2
        Lighting.GlobalShadows=false
        Lighting.FogEnd=100000
    else
        Lighting.Ambient=origAmbient
        Lighting.Brightness=origBright
        Lighting.GlobalShadows=origShadows
        Lighting.FogEnd=origFog
    end
end

-- ╔══════════════════╗
--   AUTO SAFE ZONE
--   Finds nearest safe platform and TPs there
-- ╚══════════════════╝

local function findSafePlatform()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            -- Safe platforms are NOT lava
            local isLava = n:find("lava") or n:find("fire") or n:find("kill") or n:find("acid") or n:find("hot") or n:find("danger")
            local isSafe = n:find("platform") or n:find("safe") or n:find("floor") or n:find("base") or n:find("ground") or n:find("island") or n:find("tile")
            if isSafe and not isLava then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < nearestDist then nearest = obj; nearestDist = dist end
            end
        end
    end
    return nearest
end

local lastSafe = 0
local function startAutoSafe()
    autoSafeConn = RunService.Heartbeat:Connect(function()
        if not states.autoSafe then return end
        local now = tick(); if now - lastSafe < 1 then return end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum = player.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
        -- Only teleport if health is dropping or near lava
        if hum.Health < hum.MaxHealth * 0.8 then
            local safe = findSafePlatform()
            if safe then
                hrp.CFrame = CFrame.new(safe.Position + Vector3.new(0, 5, 0))
                lastSafe = tick()
            end
        end
    end)
end
local function stopAutoSafe() if autoSafeConn then autoSafeConn:Disconnect(); autoSafeConn = nil end end

-- ╔══════════════════╗
--   ESP
-- ╚══════════════════╝

local function clearESP()
    for _, o in pairs(espObjs) do pcall(function() o:Destroy() end) end
    espObjs = {}
end

local function makeESPBox(part, color, label)
    local box = Instance.new("SelectionBox")
    box.Color3 = color; box.LineThickness = 0.04
    box.SurfaceTransparency = 0.7; box.SurfaceColor3 = color
    box.Adornee = part; box.Parent = workspace
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,100,0,30); bill.StudsOffset = Vector3.new(0,4,0)
    bill.AlwaysOnTop = true; bill.Adornee = part; bill.Parent = workspace
    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
    txt.Text = label; txt.TextColor3 = color
    txt.TextSize = 12; txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    table.insert(espObjs, box); table.insert(espObjs, bill)
end

RunService.Heartbeat:Connect(function()
    if not states.espPlatforms and not states.espPlayers then clearESP(); return end
    clearESP()
    if states.espPlatforms then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local isLava = n:find("lava") or n:find("fire") or n:find("kill") or n:find("acid")
                local isSafe = n:find("platform") or n:find("safe") or n:find("floor") or n:find("island") or n:find("tile")
                if isLava then
                    makeESPBox(obj, Color3.fromRGB(255,50,50), "⚠️ LAVA")
                elseif isSafe then
                    makeESPBox(obj, Color3.fromRGB(0,255,100), "✅ SAFE")
                end
            end
        end
    end
    if states.espPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then makeESPBox(hrp, Color3.fromRGB(0,200,255), p.Name) end
            end
        end
    end
end)

-- ╔══════════════════╗
--   AUTO REJOIN
-- ╚══════════════════╝

local function startAutoRejoin()
    player.CharacterAdded:Connect(function(char)
        if not states.autoRejoin then return end
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            if states.autoRejoin then
                task.wait(3)
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                end)
            end
        end)
    end)
end

-- ╔══════════════════════════════════════════╗
--   GUI — SIDEBAR STYLE
-- ╚══════════════════════════════════════════╝

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExoHubLava"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- Main window
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 580, 0, 420)
mainWindow.Position = UDim2.new(0.5, -290, 0.5, -210)
mainWindow.BackgroundColor3 = Color3.fromRGB(6, 10, 24)
mainWindow.BorderSizePixel = 0
mainWindow.Active = true
mainWindow.Parent = ScreenGui
Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

local windowStroke = Instance.new("UIStroke")
windowStroke.Color = Color3.fromRGB(0, 180, 255)
windowStroke.Thickness = 1.5
windowStroke.Transparency = 0.3
windowStroke.Parent = mainWindow

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(4, 8, 18)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainWindow
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 8)
titleFix.Position = UDim2.new(0, 0, 1, -8)
titleFix.BackgroundColor3 = Color3.fromRGB(4, 8, 18)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 30, 1, 0)
titleIcon.Position = UDim2.new(0, 10, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "✦"
titleIcon.TextColor3 = Color3.fromRGB(0, 200, 255)
titleIcon.TextSize = 18
titleIcon.Font = Enum.Font.GothamBold
titleIcon.Parent = titleBar

local titleName = Instance.new("TextLabel")
titleName.Size = UDim2.new(0, 120, 0, 22)
titleName.Position = UDim2.new(0, 38, 0, 4)
titleName.BackgroundTransparency = 1
titleName.Text = "Exo Hub"
titleName.TextColor3 = Color3.fromRGB(255, 255, 255)
titleName.TextSize = 15
titleName.Font = Enum.Font.GothamBold
titleName.TextXAlignment = Enum.TextXAlignment.Left
titleName.Parent = titleBar

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,200,255)),
})
titleGrad.Parent = titleName

local titleSub = Instance.new("TextLabel")
titleSub.Size = UDim2.new(0, 180, 0, 14)
titleSub.Position = UDim2.new(0, 38, 0, 26)
titleSub.BackgroundTransparency = 1
titleSub.Text = "discord.gg/TzNds43vb"
titleSub.TextColor3 = Color3.fromRGB(0, 100, 150)
titleSub.TextSize = 9
titleSub.Font = Enum.Font.Gotham
titleSub.TextXAlignment = Enum.TextXAlignment.Left
titleSub.Parent = titleBar

-- Window controls
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 10; closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0; closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -58, 0.5, -11)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
minBtn.Text = "−"; minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.TextSize = 14; minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0; minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

local titleDiv = Instance.new("Frame")
titleDiv.Size = UDim2.new(1, 0, 0, 1)
titleDiv.Position = UDim2.new(0, 0, 0, 44)
titleDiv.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
titleDiv.BackgroundTransparency = 0.7
titleDiv.BorderSizePixel = 0
titleDiv.Parent = mainWindow

-- ╔══════════════════╗
--   LEFT SIDEBAR
-- ╚══════════════════╝

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 170, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(4, 8, 18)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainWindow
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 14, 1, 0)
sidebarFix.Position = UDim2.new(1, -14, 0, 0)
sidebarFix.BackgroundColor3 = Color3.fromRGB(4, 8, 18)
sidebarFix.BorderSizePixel = 0
sidebarFix.Parent = sidebar

local sideDiv = Instance.new("Frame")
sideDiv.Size = UDim2.new(0, 1, 1, 0)
sideDiv.Position = UDim2.new(1, -1, 0, 0)
sideDiv.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
sideDiv.BackgroundTransparency = 0.7
sideDiv.BorderSizePixel = 0
sideDiv.Parent = sidebar

-- Search bar
local searchBg = Instance.new("Frame")
searchBg.Size = UDim2.new(1, -16, 0, 32)
searchBg.Position = UDim2.new(0, 8, 0, 8)
searchBg.BackgroundColor3 = Color3.fromRGB(10, 16, 34)
searchBg.BorderSizePixel = 0
searchBg.Parent = sidebar
Instance.new("UICorner", searchBg).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", searchBg).Color = Color3.fromRGB(0, 100, 140)

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 28, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"; searchIcon.TextSize = 13; searchIcon.Font = Enum.Font.GothamBold
searchIcon.Parent = searchBg

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 1, 0)
searchBox.Position = UDim2.new(0, 26, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""; searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = Color3.fromRGB(60, 80, 100)
searchBox.TextColor3 = Color3.fromRGB(255,255,255)
searchBox.TextSize = 11; searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchBg

-- Sidebar scroll
local sideScroll = Instance.new("ScrollingFrame")
sideScroll.Size = UDim2.new(1, 0, 1, -100)
sideScroll.Position = UDim2.new(0, 0, 0, 50)
sideScroll.BackgroundTransparency = 1
sideScroll.BorderSizePixel = 0
sideScroll.ScrollBarThickness = 2
sideScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sideScroll.Parent = sidebar

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 2)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Parent = sideScroll

-- Player info bottom of sidebar
local playerInfoBg = Instance.new("Frame")
playerInfoBg.Size = UDim2.new(1, 0, 0, 44)
playerInfoBg.Position = UDim2.new(0, 0, 1, -44)
playerInfoBg.BackgroundColor3 = Color3.fromRGB(2, 6, 14)
playerInfoBg.BorderSizePixel = 0
playerInfoBg.Parent = sidebar
Instance.new("UICorner", playerInfoBg).CornerRadius = UDim.new(0, 8)

local playerAvatar = Instance.new("TextLabel")
playerAvatar.Size = UDim2.new(0, 34, 0, 34)
playerAvatar.Position = UDim2.new(0, 6, 0.5, -17)
playerAvatar.BackgroundColor3 = Color3.fromRGB(10, 16, 34)
playerAvatar.Text = "😊"; playerAvatar.TextSize = 18; playerAvatar.Font = Enum.Font.GothamBold
playerAvatar.BorderSizePixel = 0; playerAvatar.Parent = playerInfoBg
Instance.new("UICorner", playerAvatar).CornerRadius = UDim.new(1, 0)

local playerNameLbl = Instance.new("TextLabel")
playerNameLbl.Size = UDim2.new(1, -48, 0, 18)
playerNameLbl.Position = UDim2.new(0, 44, 0, 6)
playerNameLbl.BackgroundTransparency = 1
playerNameLbl.Text = player.Name
playerNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
playerNameLbl.TextSize = 11; playerNameLbl.Font = Enum.Font.GothamBold
playerNameLbl.TextXAlignment = Enum.TextXAlignment.Left
playerNameLbl.Parent = playerInfoBg

local playerTagLbl = Instance.new("TextLabel")
playerTagLbl.Size = UDim2.new(1, -48, 0, 14)
playerTagLbl.Position = UDim2.new(0, 44, 0, 24)
playerTagLbl.BackgroundTransparency = 1
playerTagLbl.Text = "@" .. player.Name
playerTagLbl.TextColor3 = Color3.fromRGB(0, 120, 160)
playerTagLbl.TextSize = 9; playerTagLbl.Font = Enum.Font.Gotham
playerTagLbl.TextXAlignment = Enum.TextXAlignment.Left
playerTagLbl.Parent = playerInfoBg

-- ╔══════════════════╗
--   RIGHT CONTENT
-- ╚══════════════════╝

local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -170, 1, -45)
contentPanel.Position = UDim2.new(0, 170, 0, 45)
contentPanel.BackgroundTransparency = 1
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainWindow

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, -10, 1, -10)
contentScroll.Position = UDim2.new(0, 5, 0, 5)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.Parent = contentPanel

local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 8)
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Parent = contentScroll

-- ╔══════════════════╗
--   CATEGORIES
-- ╚══════════════════╝

local categories = {
    {name="Information", icon="ℹ️",  order=1},
    {name="Survival",    icon="🛡️",  order=2},
    {name="Movement",    icon="🛸",   order=3},
    {name="Visuals",     icon="👁",   order=4},
    {name="Teleport",    icon="📍",   order=5},
}

local categoryFeatures = {
    Information = {},
    Survival = {
        {key="godMode",   name="God Mode",    desc="Cannot die — health always stays full",        icon="🛡️", color=Color3.fromRGB(0,200,255)},
        {key="antiLava",  name="Anti Lava",   desc="Lava cannot hurt you at all",                  icon="🔥",  color=Color3.fromRGB(255,100,0)},
        {key="autoSafe",  name="Auto Safe",   desc="Auto teleports to safe platform when burning", icon="✅",  color=Color3.fromRGB(0,255,100)},
        {key="autoRejoin",name="Auto Rejoin", desc="Auto rejoins the game when you die",           icon="🔄",  color=Color3.fromRGB(180,0,255)},
    },
    Movement = {
        {key="speed",   name="Speed Hack", desc="Run faster than the lava rising",   icon="⚡",  color=Color3.fromRGB(255,200,0)},
        {key="fly",     name="Fly",        desc="Fly above everything — WASD moves", icon="🛸",  color=Color3.fromRGB(120,80,255)},
        {key="noclip",  name="Noclip",     desc="Walk through all walls and floors", icon="👻",  color=Color3.fromRGB(180,0,255)},
    },
    Visuals = {
        {key="espPlatforms", name="Platform ESP", desc="See safe platforms and lava highlighted",  icon="🗺️",  color=Color3.fromRGB(0,255,100)},
        {key="espPlayers",   name="Player ESP",   desc="See all players through walls",            icon="👁",   color=Color3.fromRGB(0,180,255)},
        {key="fullbright",   name="Fullbright",   desc="Max brightness — see everything clearly",  icon="🔦",   color=Color3.fromRGB(255,220,0)},
    },
    Teleport = {},
}

local featureCallbacks = {
    godMode      = {on=function() setupGodMode(player.Character) end, off=stopGodMode},
    antiLava     = {on=startAntiLava, off=stopAntiLava},
    autoSafe     = {on=startAutoSafe, off=stopAutoSafe},
    autoRejoin   = {on=startAutoRejoin, off=function() states.autoRejoin=false end},
    speed        = {on=function() setSpeed(true) end, off=function() setSpeed(false) end},
    fly          = {on=function() flyActive=true; startFly() end, off=function() flyActive=false end},
    noclip       = {on=startNoclip, off=stopNoclip},
    espPlatforms = {on=function() end, off=clearESP},
    espPlayers   = {on=function() end, off=clearESP},
    fullbright   = {on=function() setFullbright(true) end, off=function() setFullbright(false) end},
}

-- Toggle row builder
local function makeToggleRow(feature, index)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 56)
    row.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = index
    row.Parent = contentScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = feature.color; rowStroke.Thickness = 1; rowStroke.Transparency = 0.8; rowStroke.Parent = row

    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 36, 0, 36); iconBg.Position = UDim2.new(0, 10, 0.5, -18)
    iconBg.BackgroundColor3 = feature.color; iconBg.BackgroundTransparency = 0.7
    iconBg.BorderSizePixel = 0; iconBg.Parent = row
    Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 8)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency = 1
    iconLbl.Text = feature.icon; iconLbl.TextSize = 18; iconLbl.Font = Enum.Font.GothamBold; iconLbl.Parent = iconBg

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-120,0,20); nameLbl.Position = UDim2.new(0,54,0,8)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = feature.name
    nameLbl.TextColor3 = Color3.fromRGB(220,230,255); nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.Parent = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1,-120,0,18); descLbl.Position = UDim2.new(0,54,0,28)
    descLbl.BackgroundTransparency = 1; descLbl.Text = feature.desc
    descLbl.TextColor3 = Color3.fromRGB(80,100,140); descLbl.TextSize = 9
    descLbl.Font = Enum.Font.Gotham; descLbl.TextXAlignment = Enum.TextXAlignment.Left; descLbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 44, 0, 24); pill.Position = UDim2.new(1,-54,0.5,-12)
    pill.BackgroundColor3 = Color3.fromRGB(16, 22, 40); pill.BorderSizePixel = 0; pill.Parent = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    local pillStroke = Instance.new("UIStroke"); pillStroke.Color = Color3.fromRGB(40,60,90); pillStroke.Thickness = 1; pillStroke.Parent = pill

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(100,120,160); dot.BorderSizePixel = 0; dot.Parent = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1,0,1,0); toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""; toggleBtn.Parent = row

    toggleBtn.MouseButton1Click:Connect(function()
        states[feature.key] = not states[feature.key]
        local on = states[feature.key]
        TweenService:Create(pill, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = on and feature.color or Color3.fromRGB(16,22,40)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = on and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,120,160)
        }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.2), {Transparency = on and 0.3 or 0.8}):Play()
        TweenService:Create(iconBg, TweenInfo.new(0.2), {BackgroundTransparency = on and 0.2 or 0.7}):Play()
        if on then
            if featureCallbacks[feature.key] then featureCallbacks[feature.key].on() end
        else
            if featureCallbacks[feature.key] then featureCallbacks[feature.key].off() end
        end
    end)

    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(10,18,36)}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(8,14,28)}):Play() end)
end

-- Info page
local function showInfoPage()
    for _, c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1,-10,0,90); banner.LayoutOrder = 1
    banner.BackgroundColor3 = Color3.fromRGB(0,180,255); banner.BackgroundTransparency = 0.85
    banner.BorderSizePixel = 0; banner.Parent = contentScroll
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0,12)
    Instance.new("UIStroke", banner).Color = Color3.fromRGB(0,200,255)

    local bTitle = Instance.new("TextLabel", banner)
    bTitle.Size = UDim2.new(1,0,0,44); bTitle.Position = UDim2.new(0,0,0,4)
    bTitle.BackgroundTransparency = 1; bTitle.Text = "✦ EXO HUB"
    bTitle.TextColor3 = Color3.fromRGB(255,255,255); bTitle.TextSize = 28; bTitle.Font = Enum.Font.GothamBold
    local bGrad = Instance.new("UIGradient", bTitle)
    bGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,220,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,255,180)),
    })

    local bSub = Instance.new("TextLabel", banner)
    bSub.Size = UDim2.new(1,0,0,18); bSub.Position = UDim2.new(0,0,0,48)
    bSub.BackgroundTransparency = 1; bSub.Text = "🌋  SURVIVE THE LAVA FOR BRAINROT"
    bSub.TextColor3 = Color3.fromRGB(0,180,255); bSub.TextSize = 11; bSub.Font = Enum.Font.GothamBold

    local bDisc = Instance.new("TextLabel", banner)
    bDisc.Size = UDim2.new(1,0,0,16); bDisc.Position = UDim2.new(0,0,0,68)
    bDisc.BackgroundTransparency = 1; bDisc.Text = "discord.gg/TzNds43vb"
    bDisc.TextColor3 = Color3.fromRGB(0,120,160); bDisc.TextSize = 10; bDisc.Font = Enum.Font.Gotham

    local infoItems = {
        {icon="💬", title="Join Discord",        desc="discord.gg/TzNds43vb — support and updates"},
        {icon="⌨️", title="Keybind",             desc="RightShift to toggle Exo Hub open/closed"},
        {icon="🌋", title="Welcome to Exo Hub!", desc="Pick a category on the left to get started"},
        {icon="👑", title="Exo Hub Team",        desc="Built with love — discord.gg/TzNds43vb"},
    }

    for i, item in ipairs(infoItems) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-10,0,52); row.LayoutOrder = i+1
        row.BackgroundColor3 = Color3.fromRGB(8,14,28); row.BorderSizePixel = 0; row.Parent = contentScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke", row).Color = Color3.fromRGB(0,100,140)

        local iIcon = Instance.new("TextLabel", row)
        iIcon.Size = UDim2.new(0,40,1,0); iIcon.BackgroundTransparency = 1
        iIcon.Text = item.icon; iIcon.TextSize = 20; iIcon.Font = Enum.Font.GothamBold

        local iTitle = Instance.new("TextLabel", row)
        iTitle.Size = UDim2.new(1,-50,0,22); iTitle.Position = UDim2.new(0,46,0,6)
        iTitle.BackgroundTransparency = 1; iTitle.Text = item.title
        iTitle.TextColor3 = Color3.fromRGB(255,255,255); iTitle.TextSize = 13
        iTitle.Font = Enum.Font.GothamBold; iTitle.TextXAlignment = Enum.TextXAlignment.Left

        local iDesc = Instance.new("TextLabel", row)
        iDesc.Size = UDim2.new(1,-50,0,18); iDesc.Position = UDim2.new(0,46,0,28)
        iDesc.BackgroundTransparency = 1; iDesc.Text = item.desc
        iDesc.TextColor3 = Color3.fromRGB(60,100,140); iDesc.TextSize = 10
        iDesc.Font = Enum.Font.Gotham; iDesc.TextXAlignment = Enum.TextXAlignment.Left
    end
    contentScroll.CanvasSize = UDim2.new(0,0,0,(#infoItems+1)*62+100)
end

-- Teleport page
local function showTeleportPage()
    for _, c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local tpPoints = {
        {name="Spawn",       pos=Vector3.new(0,10,0)},
        {name="High Ground", pos=Vector3.new(0,80,0)},
        {name="Center Map",  pos=Vector3.new(0,20,0)},
        {name="Edge",        pos=Vector3.new(100,20,100)},
    }

    for i, tp in ipairs(tpPoints) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-10,0,52); row.LayoutOrder = i
        row.BackgroundColor3 = Color3.fromRGB(8,14,28); row.BorderSizePixel = 0; row.Parent = contentScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke", row).Color = Color3.fromRGB(0,180,255)

        local tIcon = Instance.new("TextLabel", row)
        tIcon.Size = UDim2.new(0,40,1,0); tIcon.BackgroundTransparency = 1
        tIcon.Text = "📍"; tIcon.TextSize = 20; tIcon.Font = Enum.Font.GothamBold

        local tName = Instance.new("TextLabel", row)
        tName.Size = UDim2.new(1,-130,0,22); tName.Position = UDim2.new(0,46,0,6)
        tName.BackgroundTransparency = 1; tName.Text = tp.name
        tName.TextColor3 = Color3.fromRGB(255,255,255); tName.TextSize = 13
        tName.Font = Enum.Font.GothamBold; tName.TextXAlignment = Enum.TextXAlignment.Left

        local tDesc = Instance.new("TextLabel", row)
        tDesc.Size = UDim2.new(1,-130,0,18); tDesc.Position = UDim2.new(0,46,0,28)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = string.format("%.0f, %.0f, %.0f", tp.pos.X, tp.pos.Y, tp.pos.Z)
        tDesc.TextColor3 = Color3.fromRGB(60,100,140); tDesc.TextSize = 10
        tDesc.Font = Enum.Font.Gotham; tDesc.TextXAlignment = Enum.TextXAlignment.Left

        local tBtn = Instance.new("TextButton", row)
        tBtn.Size = UDim2.new(0,70,0,28); tBtn.Position = UDim2.new(1,-80,0.5,-14)
        tBtn.BackgroundColor3 = Color3.fromRGB(0,180,255); tBtn.BackgroundTransparency = 0.3
        tBtn.Text = "Teleport"; tBtn.TextColor3 = Color3.fromRGB(255,255,255)
        tBtn.TextSize = 10; tBtn.Font = Enum.Font.GothamBold; tBtn.BorderSizePixel = 0
        Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0,8)

        tBtn.MouseButton1Click:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(tp.pos) end
        end)
    end
    contentScroll.CanvasSize = UDim2.new(0,0,0,#tpPoints*62)
end

-- Switch category
local activeBtn = nil
local function switchCategory(catName, btn)
    if activeBtn then
        TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=1}):Play()
        local lbl = activeBtn:FindFirstChildWhichIsA("TextLabel")
        if lbl then TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3=Color3.fromRGB(140,160,180)}):Play() end
    end
    activeBtn = btn
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(0,180,255), BackgroundTransparency=0.85}):Play()
    local lbl = btn:FindFirstChildWhichIsA("TextLabel")
    if lbl then TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3=Color3.fromRGB(255,255,255)}):Play() end

    for _, c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    contentScroll.CanvasSize = UDim2.new(0,0,0,0)

    if catName == "Information" then
        showInfoPage()
    elseif catName == "Teleport" then
        showTeleportPage()
    else
        local feats = categoryFeatures[catName]
        if feats then
            for i, feat in ipairs(feats) do makeToggleRow(feat, i) end
            contentScroll.CanvasSize = UDim2.new(0,0,0,#feats*64)
        end
    end
end

-- Build sidebar buttons
for _, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,0,36); btn.Position = UDim2.new(0,4,0,0)
    btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0
    btn.Text = ""; btn.LayoutOrder = cat.order; btn.Parent = sideScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local bIcon = Instance.new("TextLabel", btn)
    bIcon.Size = UDim2.new(0,28,1,0); bIcon.Position = UDim2.new(0,8,0,0)
    bIcon.BackgroundTransparency = 1; bIcon.Text = cat.icon
    bIcon.TextSize = 15; bIcon.Font = Enum.Font.GothamBold

    local bLabel = Instance.new("TextLabel", btn)
    bLabel.Size = UDim2.new(1,-40,1,0); bLabel.Position = UDim2.new(0,36,0,0)
    bLabel.BackgroundTransparency = 1; bLabel.Text = cat.name
    bLabel.TextColor3 = Color3.fromRGB(140,160,180); bLabel.TextSize = 12
    bLabel.Font = Enum.Font.GothamMedium; bLabel.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseButton1Click:Connect(function() switchCategory(cat.name, btn) end)
    btn.MouseEnter:Connect(function()
        if btn ~= activeBtn then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(0,180,255), BackgroundTransparency=0.95}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if btn ~= activeBtn then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play() end
    end)

    if cat.name == "Information" then switchCategory("Information", btn) end
end

sideScroll.CanvasSize = UDim2.new(0,0,0,#categories*40)

-- ╔══════════════════╗
--   DRAGGING
-- ╚══════════════════╝

local dragging, dragStart, startPos = false, nil, nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

-- ╔══════════════════╗
--   CONTROLS
-- ╚══════════════════╝

local minimized = false
local fullSize = UDim2.new(0,580,0,420)

local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0,120,0,30); reopenBtn.Position = UDim2.new(0,10,0,10)
reopenBtn.BackgroundColor3 = Color3.fromRGB(4,8,18); reopenBtn.Text = "✦ EXO HUB"
reopenBtn.TextColor3 = Color3.fromRGB(0,200,255); reopenBtn.TextSize = 12
reopenBtn.Font = Enum.Font.GothamBold; reopenBtn.BorderSizePixel = 0
reopenBtn.Visible = false; reopenBtn.Parent = ScreenGui
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(0,8)
local rs = Instance.new("UIStroke",reopenBtn); rs.Color=Color3.fromRGB(0,200,255); rs.Thickness=1.5

closeBtn.MouseButton1Click:Connect(function() mainWindow.Visible=false; reopenBtn.Visible=true end)
reopenBtn.MouseButton1Click:Connect(function() mainWindow.Visible=true; reopenBtn.Visible=false end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Size = minimized and UDim2.new(0,580,0,44) or fullSize
    }):Play()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainWindow.Visible = not mainWindow.Visible
        reopenBtn.Visible = not mainWindow.Visible
    end
end)

-- ╔══════════════════╗
--   ANIMATION
-- ╚══════════════════╝

local t = 0
RunService.Heartbeat:Connect(function(dt)
    t = t + dt
    local pulse = (math.sin(t*2)+1)/2
    windowStroke.Transparency = 0.2 + pulse*0.3
end)

-- Respawn
player.CharacterAdded:Connect(function(char)
    character = char; task.wait(0.5)
    if states.godMode then setupGodMode(char) end
    if states.speed then setSpeed(true) end
    if states.fly then flyActive=true; startFly() end
    if states.noclip then startNoclip() end
    if states.fullbright then setFullbright(true) end
    if states.antiLava then startAntiLava() end
end)

-- Opening animation
mainWindow.Size = UDim2.new(0,0,0,0)
mainWindow.Position = UDim2.new(0.5,0,0.5,0)
TweenService:Create(mainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Size = fullSize,
    Position = UDim2.new(0.5,-290,0.5,-210)
}):Play()

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "✦ EXO HUB",
        Text = "Survive the Lava loaded! RightShift to toggle  |  discord.gg/TzNds43vb",
        Duration = 6
    })
end)

print("[ExoHub] Survive the Lava for Brainrot ✓  |  discord.gg/TzNds43vb")
