if _G.speechlessLoaded then return end
_G.speechlessLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local name = Player.Name
local playerGui = Player:WaitForChild("PlayerGui")

local insertIntoTable = table.insert
local clearTable = table.clear
local delayTask = task.delay
local maxValue = math.max
local minValue = math.min
local clampValue = math.clamp
local floorValue = math.floor
local bitwiseXor = bit32.bxor
local stringChar = string.char
local stringByte = string.byte
local concatTable = table.concat
local createTable = table.create

local postSimulation = RunService.PostSimulation
local dataPing = Stats.Network.ServerStatsItem["Data Ping"]

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local packages = ReplicatedStorage.Packages
local controllers = ReplicatedStorage.Controllers
local balls = Workspace.Balls
local alive = Workspace.Alive
local runtime = Workspace.Runtime

local currentPing = 100
local lastPingUpdate = 0
local function GetPing()
    local now = tick()
    if now - lastPingUpdate > 1.0 then
        lastPingUpdate = now
        local ok, result = pcall(function() return dataPing:GetValue() end)
        currentPing = ok and result or 100
    end
    return currentPing
end

local eventCapture = { captured = {}, hooked = {}, originals = {}, token_fn = nil }

for _, f in pairs(getgc(true)) do
    if type(f) ~= "function" or not debug.info(f, "s"):find("PRY", 1, true) then continue end
    for _, v in pairs(debug.getupvalues(f)) do
        if type(v) == "function" then eventCapture.token_fn = v break end
    end
    if eventCapture.token_fn then break end
end

eventCapture.tokenize = function(inputValue)
    local sec = tostring(floorValue(Workspace:GetServerTimeNow() * 100))
    local tok = eventCapture.token_fn(inputValue, "TIME")
    local out = createTable(#sec)
    for i = 1, #sec do
        out[i] = stringChar(bitwiseXor((stringByte(sec, i) + i) % 256, stringByte(tok, (i - 1) % #tok + 1)))
    end
    return concatTable(out)
end

eventCapture.unhook = function()
    for k, v in pairs(eventCapture.originals) do
        pcall(function() setreadonly(k, false) k.__index = v setreadonly(k, true) end)
    end
    clearTable(eventCapture.hooked)
    clearTable(eventCapture.originals)
end

eventCapture.valid_args = function(args)
    return #args == 8 and type(args[2]) == "string" and type(args[3]) == "string"
        and type(args[4]) == "number" and typeof(args[5]) == "CFrame"
        and type(args[6]) == "table" and type(args[7]) == "table" and type(args[8]) == "boolean"
end

eventCapture.hook = function(obj)
    if next(eventCapture.captured) ~= nil then return end
    local mt = getrawmetatable(obj)
    if eventCapture.hooked[mt] then return end
    eventCapture.hooked[mt] = true
    setreadonly(mt, false)
    local index = mt.__index
    eventCapture.originals[mt] = index
    mt.__index = function(self, key)
        if key == "FireServer" and self:IsA("RemoteEvent") or key == "InvokeServer" and self:IsA("RemoteFunction") then
            return function(s, ...)
                local args = {...}
                if eventCapture.valid_args(args) then
                    eventCapture.captured[self] = args
                    eventCapture.unhook()
                end
                return index(self, key)(s, unpack(args))
            end
        end
        return index(self, key)
    end
    setreadonly(mt, true)
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then eventCapture.hook(obj) end
end

local swordAnimationState = {
    active = nil, cache = {}, tracks = {}, api = nil,
    generation = 0, last_spam = 0, cancel_delay = 0.12, cancel_fraction = 0.35,
}
pcall(function() swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI) end)

Player.CharacterAdded:Connect(function()
    clearTable(swordAnimationState.tracks)
    swordAnimationState.active = nil
    swordAnimationState.generation = swordAnimationState.generation + 1
    swordAnimationState.last_spam = 0
end)

swordAnimationState.find = function(folder)
    local p = folder:FindFirstChild("GrabParry") or folder:FindFirstChild("Parry") or folder:FindFirstChild("Grab")
    if p then return p end
    local base = folder:FindFirstChild("Base")
    if base then return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab") end
    return nil
end

swordAnimationState.resolve = function(char, swordName)
    if not swordName then return nil end
    if swordAnimationState.cache[swordName] and swordAnimationState.cache[swordName].Parent then return swordAnimationState.cache[swordName] end
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    if not shared then return nil end
    local swords = shared:FindFirstChild("ReplicatedInstances")
    swords = swords and swords:FindFirstChild("Swords")
    local getSword = swords and swords:FindFirstChild("GetSword")
    local data = nil
    if getSword then pcall(function() data = getSword:Invoke(swordName) end) end
    local animType = data and data.AnimationType or "Single"
    local swordType = data and data.SwordType or "Single"
    if swordAnimationState.api and type(swordAnimationState.api.GetAnimations) == "function" then
        local ok, anims = pcall(function() return swordAnimationState.api:GetAnimations(char, {"Parry", "GrabParry"}, animType, swordType) end)
        if ok and type(anims) == "table" and anims[1] then swordAnimationState.cache[swordName] = anims[1] return anims[1] end
    end
    local api = shared:FindFirstChild("SwordAPI")
    if api then
        api = api:FindFirstChild("Collection") or api
        if api then
            local typeFolder = api:FindFirstChild(animType)
            if typeFolder then
                local anim = swordAnimationState.find(typeFolder)
                if anim then swordAnimationState.cache[swordName] = anim return anim end
            end
            local default = api:FindFirstChild("Default")
            if default then
                local anim = swordAnimationState.find(default)
                if anim then swordAnimationState.cache[swordName] = anim return anim end
            end
        end
    end
    return nil
end

swordAnimationState.grab = function(isSpam)
    local char = Player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not animator then return false end
    local swordName = char:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
    local animObj = swordAnimationState.resolve(char, swordName)
    if not animObj then return false end
    local tracks = swordAnimationState.tracks[animator]
    if not tracks then tracks = {} swordAnimationState.tracks[animator] = tracks end
    local track = tracks[animObj]
    if not track or not track.Parent or track.Parent ~= animator then
        local ok, t = pcall(function() return animator:LoadAnimation(animObj) end)
        if not ok or not t then return false end
        for k, v in pairs(animObj:GetAttributes()) do t:SetAttribute(k, v) end
        t:SetAttribute("GrabParry", true)
        t.Priority = Enum.AnimationPriority.Action4
        tracks[animObj] = t
        track = t
    end
    if isSpam then
        local now = tick()
        if now - swordAnimationState.last_spam < swordAnimationState.cancel_delay then
            local isPlaying = false
            if swordAnimationState.active then pcall(function() isPlaying = swordAnimationState.active.IsPlaying end) end
            if isPlaying then
                char:SetAttribute("ParryTime", maxValue(char:GetAttribute("ParryTime") or 0, swordAnimationState.active.Length ~= 0 and swordAnimationState.active.Length or 1))
                return true
            end
        end
        swordAnimationState.last_spam = now
    else
        swordAnimationState.last_spam = 0
    end
    swordAnimationState.generation = swordAnimationState.generation + 1
    local gen = swordAnimationState.generation
    for _, t in pairs(animator:GetPlayingAnimationTracks()) do
        if t:GetAttribute("GrabParry") or t:GetAttribute("Parry") or t:GetAttribute("SuccessParry") then
            pcall(t.Stop, t, t:GetAttribute("StopFadeTime") or 0.05)
        end
    end
    local fadeIn = animObj:GetAttribute("PlayFadeTime") or 0.05
    local weight = animObj:GetAttribute("PlayWeight") or 1
    local speed = animObj:GetAttribute("PlaySpeed") or 1
    track.TimePosition = 0
    track:Play(fadeIn, weight, speed)
    swordAnimationState.active = track
    char:SetAttribute("ParryTime", maxValue(char:GetAttribute("ParryTime") or 0, track.Length ~= 0 and (track.Length - track.TimePosition) * speed or 1))
    if isSpam then
        local delay = math.min(swordAnimationState.cancel_delay, (track.Length or 0) * swordAnimationState.cancel_fraction)
        if delay < 0.05 then delay = 0.05 end
        local trackedTrack = track
        local fadeOut = animObj:GetAttribute("StopFadeTime") or 0.05
        delayTask(delay, function()
            if gen ~= swordAnimationState.generation or swordAnimationState.active ~= trackedTrack then return end
            pcall(trackedTrack.Stop, trackedTrack, fadeOut)
        end)
    end
    return true
end

local ballState = { positions = {}, replicator = nil }

ballState.get = function()
    for _, b in pairs(balls:GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
    return nil
end

ballState.get_all = function()
    local list = {}
    for _, b in pairs(balls:GetChildren()) do
        if b:GetAttribute("realBall") then insertIntoTable(list, b) end
    end
    return list
end

ballState.position = function(b)
    local target = b or ballState.get()
    if target then return ballState.positions[target] or target.Position end
    return Vector3.zero
end

do
    local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.1.0") and ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"]:FindFirstChild("net")
    if net then
        for _, obj in pairs(net:GetChildren()) do
            if obj:IsA("UnreliableRemoteEvent") and obj.Name ~= "URE/ReplicateBallPosition" then
                ballState.replicator = obj
                break
            end
        end
    end
end

if ballState.replicator then
    ballState.replicator.OnClientEvent:Connect(function(b, pos)
        if b and b.Parent == balls and b:GetAttribute("realBall") == true then
            ballState.positions[b] = pos
        end
    end)
end

local inventoryUnlockManager = { current = nil }

inventoryUnlockManager.by_mouse = function()
    local list = {}
    for _, v in pairs(alive:GetChildren()) do
        if v.Name ~= name and v.PrimaryPart then insertIntoTable(list, v) end
    end
    if #list == 0 then inventoryUnlockManager.current = nil return nil end
    local cam = Workspace.CurrentCamera
    local direction
    if UserInputService.MouseEnabled then
        local m = UserInputService:GetMouseLocation()
        direction = cam:ScreenPointToRay(m.X, m.Y).Direction
    else
        local vp = cam.ViewportSize
        direction = cam:ViewportPointToRay(vp.X * 0.5, vp.Y * 0.5).Direction
    end
    local best, target = -math.huge, nil
    for _, v in pairs(list) do
        local dir = v.PrimaryPart.Position - cam.CFrame.Position
        if dir.Magnitude > 0 then
            local dot = direction:Dot(dir.Unit)
            if best < dot then best = dot target = v end
        end
    end
    target = target or list[1]
    inventoryUnlockManager.current = target
    return target
end

local parryController = { count = 0, first_signal = nil }

parryController.fire = function()
    local cam = Workspace.CurrentCamera
    inventoryUnlockManager.by_mouse()
    if not inventoryUnlockManager.current or not inventoryUnlockManager.current.PrimaryPart then return end
    local cframe = cam.CFrame
    local targetPart = inventoryUnlockManager.current.PrimaryPart
    local p = cam:WorldToViewportPoint(targetPart.Position)
    local viewportPos = {p.X, p.Y}
    local screenPoints = {}
    for _, v in pairs(alive:GetChildren()) do
        local tp = v.PrimaryPart
        if tp then
            local sp = cam:WorldToScreenPoint(tp.Position)
            if sp and sp.Z > 0 then screenPoints[v.Name] = sp end
        end
    end
    if next(eventCapture.captured) == nil then
        if not parryController.first_signal then
            parryController.first_signal = require(packages.Signal).new()
            parryController.first_signal:Connect(require(controllers["SwordsController \12"].PRY))
        end
        parryController.first_signal:Fire(0.5, cframe, screenPoints, viewportPos, false)
        swordAnimationState.grab(false)
    else
        swordAnimationState.grab(false)
        for remote, args in pairs(eventCapture.captured) do
            local token = eventCapture.tokenize(args[2])
            local newArgs = {args[1], args[2], token, 0.5, cframe, screenPoints, viewportPos, false}
            if remote:IsA("RemoteEvent") then remote:FireServer(unpack(newArgs))
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(newArgs)) end
        end
    end
    if parryController.count > 7 then return false end
    parryController.count = parryController.count + 1
    delayTask(0.5, function() if parryController.count > 0 then parryController.count = parryController.count - 1 end end)
end

local AccuracyPresets = {1, 45, 65, 110, 165, 200}
local AccuracyLabels = {
    [1] = "1 (200-300 ms)",
    [45] = "45",
    [65] = "65",
    [110] = "110",
    [165] = "165",
    [200] = "200 (20-30 ms)",
}

local AutoParry = {
    enabled = false,
    antiSoF = false,
    accuracy = 200,
    cooldown = 0.18,
    lastParry = 0,
    connection = nil,
    soFActive = false,
    soFLastSeen = 0,
    soFTimeout = 2.5,
    lastSpeeds = {},
    lastSoFParry = 0,
    soFCooldown = 0.01,
}

local function getBaseThreshold()
    if AutoParry.accuracy == 1 then return 0.500 end
    return AutoParry.accuracy / 1000
end

local function getThreshold(ball)
    local base = getBaseThreshold()
    local speed = 0
    local zoomies = ball and ball:FindFirstChild("zoomies")
    if zoomies then speed = zoomies.VectorVelocity.Magnitude end
    local speedBonus = clampValue((speed - 300) / 2000, 0, 0.10)
    local pingBonus = (GetPing() / 1000) * 0.5
    return base + speedBonus + pingBonus
end

local function updateSoFState(ball, speed)
    if not AutoParry.antiSoF then AutoParry.soFActive = false return end
    local now = tick()
    local lastSpeed = AutoParry.lastSpeeds[ball] or 0
    AutoParry.lastSpeeds[ball] = speed
    local isSoFSignal = false
    local targetAttr = ball:GetAttribute("target")
    if speed < 5 and targetAttr and targetAttr ~= name then isSoFSignal = true end
    if lastSpeed < 50 and speed > 200 then isSoFSignal = true end
    if speed > 500 then isSoFSignal = true end
    if isSoFSignal then
        AutoParry.soFActive = true
        AutoParry.soFLastSeen = now
    end
    if AutoParry.soFActive and now - AutoParry.soFLastSeen > AutoParry.soFTimeout then
        AutoParry.soFActive = false
    end
end

local function checkParry()
    if not AutoParry.enabled then return end
    local now = tick()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position

    for _, ball in pairs(balls:GetChildren()) do
        if not ball:GetAttribute("realBall") then continue end
        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then continue end
        updateSoFState(ball, zoomies.VectorVelocity.Magnitude)
    end

    if AutoParry.soFActive and AutoParry.antiSoF then
        for _, ball in pairs(balls:GetChildren()) do
            if not ball:GetAttribute("realBall") then continue end
            if ball:GetAttribute("target") ~= name then continue end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then continue end
            local speed = zoomies.VectorVelocity.Magnitude
            if speed < 1 then continue end
            if now - AutoParry.lastSoFParry >= AutoParry.soFCooldown then
                parryController.fire()
                AutoParry.lastSoFParry = now
            end
        end
        return
    end

    for _, ball in pairs(balls:GetChildren()) do
        if not ball:GetAttribute("realBall") then continue end
        if ball:GetAttribute("target") ~= name then continue end
        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then continue end
        local vel = zoomies.VectorVelocity
        local speed = vel.Magnitude
        if speed < 1 then continue end
        local dist = (myPos - ball.Position).Magnitude
        local toMe = (myPos - ball.Position).Unit
        if toMe:Dot(vel.Unit) < 0 then continue end
        if now - AutoParry.lastParry < AutoParry.cooldown then continue end
        local threshold = getThreshold(ball)
        local tti = dist / speed
        if dist > speed * (threshold + 0.15) then continue end
        if tti <= threshold then
            parryController.fire()
            AutoParry.lastParry = now
        end
    end
end

function AutoParry.setEnabled(v)
    AutoParry.enabled = v
    if v then
        if not AutoParry.connection then
            AutoParry.connection = postSimulation:Connect(checkParry)
        end
    else
        if AutoParry.connection then AutoParry.connection:Disconnect() AutoParry.connection = nil end
    end
end

function AutoParry.setAccuracy(v) AutoParry.accuracy = clampValue(v, 1, 200) end

_G.AutoParry = AutoParry

local Visual = {
    enabled = false,
    showReactionCircle = true,
    showSoFCircle = true,
    showStatus = true,
    reactionPart = nil,
    soFPart = nil,
    statusGui = nil,
    statusLabel = nil,
    statusDot = nil,
    statusStroke = nil,
}

local function createReactionCircle()
    if Visual.reactionPart then return end
    local part = Instance.new("Part")
    part.Name = "SpeechlessReactionCircle"
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.15, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 200, 180)
    part.Transparency = 0.7
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = Workspace
    Visual.reactionPart = part
end

local function createSoFCircle()
    if Visual.soFPart then return end
    local part = Instance.new("Part")
    part.Name = "SpeechlessSoFCircle"
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.15, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 60, 60)
    part.Transparency = 0.5
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = Workspace
    Visual.soFPart = part
end

local function updateCircles()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        if Visual.reactionPart then Visual.reactionPart.Transparency = 1 end
        if Visual.soFPart then Visual.soFPart.Transparency = 1 end
        return
    end
    local pos = hrp.Position - Vector3.new(0, 2.5, 0)
    local rot = CFrame.Angles(0, 0, math.rad(90))

    if Visual.enabled and Visual.showReactionCircle and _G.AutoParry and _G.AutoParry.enabled then
        createReactionCircle()
        local threshold
        if _G.AutoParry.accuracy == 1 then threshold = 0.500 else threshold = _G.AutoParry.accuracy / 1000 end
        local speed = 200
        local incoming = false
        local balls2 = Workspace:FindFirstChild("Balls")
        if balls2 then
            for _, b in pairs(balls2:GetChildren()) do
                if b:GetAttribute("realBall") and b:GetAttribute("target") == Player.Name then
                    local zoomies = b:FindFirstChild("zoomies")
                    if zoomies then
                        local s = zoomies.VectorVelocity.Magnitude
                        if s > speed then speed = s incoming = true end
                    end
                end
            end
        end
        local radius = clampValue(threshold * speed, 5, 350)
        Visual.reactionPart.CFrame = CFrame.new(pos) * rot
        Visual.reactionPart.Size = Vector3.new(0.15, radius * 2, radius * 2)
        Visual.reactionPart.Transparency = incoming and 0.45 or 0.75
        Visual.reactionPart.Color = incoming and Color3.fromRGB(255, 180, 60) or Color3.fromRGB(0, 200, 180)
    elseif Visual.reactionPart then
        Visual.reactionPart.Transparency = 1
    end

    local soFActive = _G.AutoParry and _G.AutoParry.antiSoF and _G.AutoParry.soFActive
    if Visual.enabled and Visual.showSoFCircle and soFActive then
        createSoFCircle()
        Visual.soFPart.CFrame = CFrame.new(pos) * rot
        Visual.soFPart.Size = Vector3.new(0.15, 400, 400)
        Visual.soFPart.Transparency = 0.45
        Visual.soFPart.Color = Color3.fromRGB(255, 60, 60)
    elseif Visual.soFPart then
        Visual.soFPart.Transparency = 1
    end
end

local function createStatus()
    if Visual.statusGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpeechlessStatus"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 998
    gui.Parent = playerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(200, 40)
    frame.Position = UDim2.new(0.5, -100, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 180)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(10, 10)
    dot.Position = UDim2.new(0, 14, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(0, 200, 180)
    dot.BorderSizePixel = 0
    dot.Parent = frame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -34, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "SAFE"
    label.TextColor3 = Color3.fromRGB(0, 200, 180)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    Visual.statusGui = gui
    Visual.statusLabel = label
    Visual.statusDot = dot
    Visual.statusStroke = stroke
end

local function updateStatus()
    if not Visual.statusGui then return end
    if not Visual.enabled or not Visual.showStatus or not _G.AutoParry or not _G.AutoParry.enabled then
        Visual.statusGui.Enabled = false
        return
    end
    Visual.statusGui.Enabled = true
    if _G.AutoParry.antiSoF and _G.AutoParry.soFActive then
        Visual.statusLabel.Text = "ANTI SOF"
        Visual.statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        Visual.statusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Visual.statusStroke.Color = Color3.fromRGB(255, 60, 60)
        return
    end
    local incoming = false
    local tti = math.huge
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local balls2 = Workspace:FindFirstChild("Balls")
        if balls2 then
            for _, b in pairs(balls2:GetChildren()) do
                if b:GetAttribute("realBall") and b:GetAttribute("target") == Player.Name then
                    local zoomies = b:FindFirstChild("zoomies")
                    if zoomies then
                        local speed = zoomies.VectorVelocity.Magnitude
                        if speed > 1 then
                            local dist = (hrp.Position - b.Position).Magnitude
                            local t = dist / speed
                            if t < tti then tti = t incoming = true end
                        end
                    end
                end
            end
        end
    end
    if incoming then
        local danger = tti < 0.5
        Visual.statusLabel.Text = danger and ("PARRY " .. string.format("%.2f", tti)) or ("NEAR " .. string.format("%.2f", tti))
        Visual.statusLabel.TextColor3 = danger and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 180, 60)
        Visual.statusDot.BackgroundColor3 = danger and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 180, 60)
        Visual.statusStroke.Color = danger and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 180, 60)
    else
        Visual.statusLabel.Text = "SAFE"
        Visual.statusLabel.TextColor3 = Color3.fromRGB(0, 200, 180)
        Visual.statusDot.BackgroundColor3 = Color3.fromRGB(0, 200, 180)
        Visual.statusStroke.Color = Color3.fromRGB(0, 200, 180)
    end
end

RunService.RenderStepped:Connect(function()
    if Visual.enabled then
        updateCircles()
        if Visual.showStatus then createStatus() updateStatus() elseif Visual.statusGui then Visual.statusGui.Enabled = false end
    else
        if Visual.reactionPart then Visual.reactionPart.Transparency = 1 end
        if Visual.soFPart then Visual.soFPart.Transparency = 1 end
        if Visual.statusGui then Visual.statusGui.Enabled = false end
    end
end)

_G.Visual = Visual

local C = {
    Bg = Color3.fromRGB(8, 8, 8),
    Bg2 = Color3.fromRGB(13, 13, 13),
    Bg3 = Color3.fromRGB(18, 18, 18),
    Elem = Color3.fromRGB(24, 24, 24),
    ElemHover = Color3.fromRGB(32, 32, 32),
    Border = Color3.fromRGB(38, 38, 38),
    Text = Color3.fromRGB(235, 235, 235),
    Sub = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(0, 200, 180),
}

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end
local function tween(inst, props, t, style, dir)
    local tw = TweenService:Create(inst, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local gui = create("ScreenGui", {
    Name = "SpeechlessMenu", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = playerGui,
})

local SIZE = 480
local main = create("Frame", {
    Name = "Main", Size = UDim2.fromOffset(SIZE, SIZE),
    Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = main })
local mainStroke = create("UIStroke", { Color = C.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = main })

local header = create("Frame", { Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = C.Bg2, BorderSizePixel = 0, Parent = main })
create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = header })
create("Frame", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16), BackgroundColor3 = C.Bg2, BorderSizePixel = 0, Parent = header })

create("TextLabel", {
    Text = "Speechless.cc", Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
    Position = UDim2.new(0, 22, 0, 10), Size = UDim2.new(0, 200, 0, 18), Parent = header,
})
create("TextLabel", {
    Text = "Paid Version", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.Sub,
    TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
    Position = UDim2.new(0, 22, 0, 28), Size = UDim2.new(0, 200, 0, 14), Parent = header,
})

local collapseBtn = create("TextButton", {
    Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -42, 0.5, -14),
    BackgroundColor3 = C.Elem, AutoButtonColor = false, Text = "", Parent = header,
})
create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = collapseBtn })
create("TextLabel", { Text = "-", Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = C.Sub, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = collapseBtn })
collapseBtn.MouseEnter:Connect(function() tween(collapseBtn, { BackgroundColor3 = C.Accent }, 0.15) end)
collapseBtn.MouseLeave:Connect(function() tween(collapseBtn, { BackgroundColor3 = C.Elem }, 0.15) end)

local tabBar = create("Frame", {
    Size = UDim2.new(1, -44, 0, 38), Position = UDim2.new(0, 22, 0, 66),
    BackgroundColor3 = C.Bg2, BorderSizePixel = 0, Parent = main,
})
create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tabBar })
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = tabBar })
create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = tabBar })

local pageHolder = create("Frame", {
    Size = UDim2.new(1, -44, 1, -128), Position = UDim2.new(0, 22, 0, 112),
    BackgroundTransparency = 1, Parent = main,
})

local tabs = {}
local pages = {}
local activeTab = nil

local function switchTab(n)
    for nm, btn in pairs(tabs) do
        local a = nm == n
        tween(btn, { BackgroundColor3 = a and C.Accent or C.Bg3 }, 0.15)
        tween(btn.Label, { TextColor3 = a and C.Bg or C.Sub }, 0.15)
    end
    for nm, p in pairs(pages) do p.Visible = nm == n end
    activeTab = n
end

local function addTab(n)
    local btn = create("TextButton", {
        Size = UDim2.new(0, 100, 1, 0), BackgroundColor3 = C.Bg3,
        AutoButtonColor = false, Text = "", Parent = tabBar,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    local lbl = create("TextLabel", {
        Text = n, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.Sub,
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = btn,
    })
    btn.Label = lbl
    tabs[n] = btn

    local p = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = pageHolder,
    })
    create("UIListLayout", { Padding = UDim.new(0, 6), Parent = p })
    pages[n] = p

    btn.MouseButton1Click:Connect(function() switchTab(n) end)
    btn.MouseEnter:Connect(function() if activeTab ~= n then tween(btn, { BackgroundColor3 = C.Elem }, 0.15) end end)
    btn.MouseLeave:Connect(function() if activeTab ~= n then tween(btn, { BackgroundColor3 = C.Bg3 }, 0.15) end end)
    return p
end

local function addToggle(page, text, default, callback)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.Bg3,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = page,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
    create("UIStroke", { Color = C.Border, Thickness = 1, Parent = row })
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -80, 1, 0), Parent = row,
    })
    local sw = create("Frame", {
        Size = UDim2.fromOffset(36, 20), Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = default and C.Accent or C.Elem, BorderSizePixel = 0, Parent = row,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
    local knob = create("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sw,
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local state = default
    local function set(v)
        state = v
        tween(sw, { BackgroundColor3 = v and C.Accent or C.Elem }, 0.15)
        tween(knob, { Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.15)
        if callback then callback(v) end
    end
    row.MouseButton1Click:Connect(function() set(not state) end)
    return { Set = set, Get = function() return state end }
end

local function addDropdown(page, text, options, default, callback)
    local wrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.Bg3,
        BorderSizePixel = 0, ClipsDescendants = false, Parent = page,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = wrap })
    create("UIStroke", { Color = C.Border, Thickness = 1, Parent = wrap })
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -140, 1, 0), Parent = wrap,
    })
    local btn = create("TextButton", {
        Size = UDim2.new(0, 110, 0, 28), Position = UDim2.new(1, -126, 0.5, -14),
        BackgroundColor3 = C.Elem, AutoButtonColor = false, Text = default or options[1],
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.Sub, Parent = wrap,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })

    local list = create("Frame", {
        Size = UDim2.new(0, 110, 0, 0), Position = UDim2.new(1, -126, 1, 6),
        BackgroundColor3 = C.Elem, BorderSizePixel = 0, ClipsDescendants = true,
        Visible = false, ZIndex = 10, Parent = wrap,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = list })
    create("UIListLayout", { Padding = UDim.new(0, 2), Parent = list })

    local val = default or options[1]
    for _, opt in ipairs(options) do
        local o = create("TextButton", {
            Size = UDim2.new(1, -8, 0, 26), Position = UDim2.new(0, 4, 0, 0),
            BackgroundColor3 = C.Elem, BorderSizePixel = 0, Text = opt,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.Text,
            AutoButtonColor = false, ZIndex = 11, Parent = list,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = o })
        o.MouseEnter:Connect(function() tween(o, { BackgroundColor3 = C.ElemHover }, 0.1) end)
        o.MouseLeave:Connect(function() tween(o, { BackgroundColor3 = C.Elem }, 0.1) end)
        o.MouseButton1Click:Connect(function()
            val = opt btn.Text = opt list.Visible = false
            if callback then callback(opt) end
        end)
    end
    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    return { Get = function() return val end }
end

local combat = addTab("Combat")
local visualTab = addTab("Visual")
local misc = addTab("Misc")

addToggle(combat, "Auto Parry", false, function(v) _G.AutoParry.setEnabled(v) end)
addDropdown(combat, "Reaction", {"1 (200-300 ms)","45","65","110","165","200 (20-30 ms)"}, "200 (20-30 ms)", function(v)
    local map = {["1 (200-300 ms)"]=1,["45"]=45,["65"]=65,["110"]=110,["165"]=165,["200 (20-30 ms)"]=200}
    _G.AutoParry.setAccuracy(map[v] or 200)
end)
addToggle(combat, "Anti Slash of Fury", false, function(v) _G.AutoParry.antiSoF = v end)

addToggle(visualTab, "Visual", false, function(v) _G.Visual.enabled = v end)
addToggle(visualTab, "Reaction Circle", true, function(v) _G.Visual.showReactionCircle = v end)
addToggle(visualTab, "Anti SoF Circle", true, function(v) _G.Visual.showSoFCircle = v end)
addToggle(visualTab, "Status", true, function(v) _G.Visual.showStatus = v end)

create("TextLabel", {
    Text = "Speechless.cc — Paid Version", Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = C.Sub, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = misc,
})

switchTab("Combat")

local STRIP_W, STRIP_H = 130, 36
local strip = create("TextButton", {
    Size = UDim2.fromOffset(STRIP_W, STRIP_H), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Bg, AutoButtonColor = false, Text = "", Visible = false, Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = strip })
local stripStroke = create("UIStroke", { Color = C.Border, Thickness = 1, Parent = strip })
create("TextLabel", { Text = "Speechless.cc", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = strip })
create("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.new(1, -12, 0.5, -3), BackgroundColor3 = C.Accent, BorderSizePixel = 0, Parent = strip })

local isOpen = true
local function collapse()
    if not isOpen then return end
    isOpen = false
    strip.Visible = true
    strip.BackgroundTransparency = 1
    stripStroke.Transparency = 1
    strip.Size = UDim2.fromOffset(SIZE, SIZE)
    strip.Position = main.Position
    strip.AnchorPoint = main.AnchorPoint
    tween(main, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(mainStroke, { Transparency = 1 }, 0.25)
    task.delay(0.05, function()
        tween(strip, { Size = UDim2.fromOffset(STRIP_W, STRIP_H), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(strip, { BackgroundTransparency = 0 }, 0.2)
        tween(stripStroke, { Transparency = 0 }, 0.2)
    end)
    task.delay(0.32, function() if not isOpen then main.Visible = false end end)
end
local function expand()
    if isOpen then return end
    isOpen = true
    main.Visible = true
    main.Size = UDim2.fromOffset(0, 0)
    main.Position = strip.Position
    main.BackgroundTransparency = 1
    mainStroke.Transparency = 1
    tween(strip, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(stripStroke, { Transparency = 1 }, 0.2)
    task.delay(0.08, function()
        tween(main, { Size = UDim2.fromOffset(SIZE, SIZE), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(mainStroke, { Transparency = 0 }, 0.25)
    end)
    task.delay(0.3, function() if isOpen then strip.Visible = false end end)
end

collapseBtn.MouseButton1Click:Connect(collapse)
local moved = false
strip.InputBegan:Connect(function() moved = false end)
strip.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then moved = true end
end)
strip.MouseButton1Click:Connect(function() if not moved then expand() end end)

local function drag(frame, handle)
    local d, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            d = true ds = input.Position sp = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then d = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if d and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
end
drag(main, header)
local sd, sds, ssp = false, nil, nil
strip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sd = true sds = input.Position ssp = strip.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then sd = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sd and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - sds
        strip.Position = UDim2.new(ssp.X.Scale, ssp.X.Offset + delta.X, ssp.Y.Scale, ssp.Y.Offset + delta.Y)
    end
end)

print("[speechless] loaded")
