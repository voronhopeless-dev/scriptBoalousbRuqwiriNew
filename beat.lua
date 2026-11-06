local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local hook = getgenv and getgenv().hookfunction or hookfunction
local HASH = "5455ef47-de02-4074-808c-8d82c2cd12ec"
local byte, char, floor, bxor = string.byte, string.char, math.floor, bit32.bxor
local captured, votes, key = {}, {}, nil
local spamRunning = false
local actualCPS, cpsCounter, lastCPSTime = 0, 0, tick()
local currentPing, lastPingUpdate, PING_UPDATE_INTERVAL = 0, 0, 1.0
local currentFPS = 60

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(18, 18, 18)
local GRAY = Color3.fromRGB(130, 130, 130)
local GREEN = Color3.fromRGB(0, 255, 100)

local function timestamp() return tostring(floor(workspace:GetServerTimeNow() * 100)) end

local function ShowNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
end

local function GetPing()
    local now = tick()
    if now - lastPingUpdate > PING_UPDATE_INTERVAL then
        lastPingUpdate = now
        local ok, result = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        currentPing = ok and result or 100
    end
    return currentPing
end

local function learn(token, stamp)
    if #token ~= #stamp then return false end
    for i = 1, #token do
        local value = bxor(byte(token, i), (byte(stamp, i) + i) % 256)
        local counts = votes[i] or {}
        votes[i] = counts
        counts[value] = (counts[value] or 0) + 1
    end
    local nextKey = {}
    for i = 1, #token do
        local best, highest = 0, -1
        for value, count in pairs(votes[i]) do
            if count > highest then best, highest = value, count end
        end
        nextKey[i] = best
    end
    key = nextKey
    return true
end

local function makeToken()
    if not key then return nil end
    local stamp = timestamp()
    local out = {}
    for i = 1, #stamp do
        local value = key[i] or key[#key]
        if not value then return nil end
        out[i] = char(bxor((byte(stamp, i) + i) % 256, value))
    end
    return table.concat(out)
end

local fire
if hook then
    pcall(function()
        local template = Instance.new("RemoteEvent")
        fire = hook(template.FireServer, function(self, ...)
            local args = table.pack(...)
            if args[1] ~= HASH or type(args[3]) ~= "string" then
                return fire(self, ...)
            end
            captured = {remote = self, sessionKey = args[2], token = args[3], timing = args[4], tailBool = args[8]}
            learn(args[3], timestamp())
            if not _G.RuqwiriActivated then
                _G.RuqwiriActivated = true
                ShowNotification("Speechless.cc [Ap Macro]", "Ap Macro Activated", 4)
            end
            return fire(self, ...)
        end)
    end)
end

local camCache, pointsCache, pointsCacheTime, POINTS_TTL = nil, {}, 0, 0.05

local function refreshPoints()
    local now = tick()
    if now - pointsCacheTime < POINTS_TTL then return end
    pointsCacheTime = now
    pointsCache = {}
    local alive = workspace:FindFirstChild("Alive")
    if alive and camCache then
        for _, character in ipairs(alive:GetChildren()) do
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                pointsCache[character.Name] = camCache:WorldToScreenPoint(root.Position)
            end
        end
    end
end

local function replay()
    if not fire or not captured.remote or not captured.sessionKey then return end
    local token = makeToken()
    if not token then return end
    camCache = workspace.CurrentCamera
    if not camCache then return end
    refreshPoints()
    
    local centerX = camCache.ViewportSize.X / 2
    local centerY = camCache.ViewportSize.Y / 2
    
    fire(captured.remote, HASH, captured.sessionKey, token, captured.timing or 0.5, camCache.CFrame, pointsCache, {centerX, centerY}, captured.tailBool or false)
    cpsCounter = cpsCounter + 1
end

local function Parry()
    if captured.remote and captured.sessionKey then
        replay()
    end
end

local SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI")
local AnimFix_Cache = {}
local swordAnimationState = {
    active = nil,
    cache = {},
    tracks = {},
    api = nil,
    generation = 0,
    last_spam = 0,
    cancel_delay = 0.12,
    cancel_fraction = 0.35,
}

pcall(function()
    swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI)
end)

local function findAnimIn(obj)
    local grabParry = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Parry") or obj:FindFirstChild("Grab")
    if grabParry then return grabParry end
    local base = obj:FindFirstChild("Base")
    if base then
        return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab")
    end
    return nil
end

local function resolveParryAnim(character, swordName)
    if not swordName then return nil end
    if swordAnimationState.cache[swordName] and swordAnimationState.cache[swordName].Parent then
        return swordAnimationState.cache[swordName]
    end
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    if not shared then return nil end
    local swords = shared:FindFirstChild("ReplicatedInstances")
    swords = swords and swords:FindFirstChild("Swords")
    local getSword = swords and swords:FindFirstChild("GetSword")
    local swordData = nil
    if getSword then
        pcall(function() swordData = getSword:Invoke(swordName) end)
    end
    local animationType = swordData and swordData.AnimationType or "Single"
    local swordType = swordData and swordData.SwordType or "Single"
    
    if swordAnimationState.api and type(swordAnimationState.api.GetAnimations) == "function" then
        local ok, anims = pcall(function()
            return swordAnimationState.api:GetAnimations(character, {"Parry", "GrabParry"}, animationType, swordType)
        end)
        if ok and type(anims) == "table" and anims[1] then
            swordAnimationState.cache[swordName] = anims[1]
            return anims[1]
        end
    end
    
    local swordAPI = shared:FindFirstChild("SwordAPI")
    if swordAPI then
        swordAPI = swordAPI:FindFirstChild("Collection") or swordAPI
    end
    if swordAPI then
        local byType = swordAPI:FindFirstChild(animationType)
        if byType then
            local a = findAnimIn(byType)
            if a then swordAnimationState.cache[swordName] = a return a end
        end
        local default = swordAPI:FindFirstChild("Default")
        if default then
            local a = findAnimIn(default)
            if a then swordAnimationState.cache[swordName] = a return a end
        end
    end
    return nil
end

local function PlayGrabParry(isSpam)
    local character = Player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not animator then return false end
    
    local swordName = character:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
    local animObj = resolveParryAnim(character, swordName)
    if not animObj then return false end
    
    local tracks = swordAnimationState.tracks[animator]
    if not tracks then
        tracks = {}
        swordAnimationState.tracks[animator] = tracks
    end
    
    local track = tracks[animObj]
    if not track or not track.Parent or track.Parent ~= animator then
        local ok, loaded = pcall(function() return animator:LoadAnimation(animObj) end)
        if not ok or not loaded then return false end
        for k, v in animObj:GetAttributes() do loaded:SetAttribute(k, v) end
        loaded:SetAttribute("GrabParry", true)
        loaded.Priority = Enum.AnimationPriority.Action4
        tracks[animObj] = loaded
        track = loaded
    end
    
    if isSpam then
        local now = tick()
        if now - swordAnimationState.last_spam < swordAnimationState.cancel_delay then
            if swordAnimationState.active and swordAnimationState.active.IsPlaying then
                character:SetAttribute("ParryTime", math.max(character:GetAttribute("ParryTime") or 0, swordAnimationState.active.Length or 1))
                return true
            end
        end
        swordAnimationState.last_spam = now
    else
        swordAnimationState.last_spam = 0
    end
    
    swordAnimationState.generation = swordAnimationState.generation + 1
    local generation = swordAnimationState.generation
    
    for _, t in animator:GetPlayingAnimationTracks() do
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
    character:SetAttribute("ParryTime", math.max(character:GetAttribute("ParryTime") or 0, track.Length ~= 0 and (track.Length - track.TimePosition) * speed or 1))
    
    if isSpam then
        local length = track.Length or 0
        local delay = math.min(swordAnimationState.cancel_delay, length * swordAnimationState.cancel_fraction)
        if delay < 0.05 then delay = 0.05 end
        local thisTrack = track
        local stopFade = animObj:GetAttribute("StopFadeTime") or 0.05
        task.delay(delay, function()
            if generation ~= swordAnimationState.generation or swordAnimationState.active ~= thisTrack then return end
            pcall(thisTrack.Stop, thisTrack, stopFade)
        end)
    end
    return true
end

pcall(function()
    ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
        local char = Player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChild("Animator")
        if not animator then return end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track.Name == "GrabParry" or track.Name == "Grab" or track:GetAttribute("GrabParry") then
                pcall(function() track:Stop(0.1) end)
            end
        end
        swordAnimationState.active = nil
        swordAnimationState.generation = swordAnimationState.generation + 1
    end)
end)

local spamThreads = {}
local SPAM_THREAD_COUNT = 11

local function SpamThread()
    while spamRunning do
        Parry()
        PlayGrabParry(true)
        task.wait(0)
    end
end

local function StartSpam()
    if spamRunning then return end
    spamRunning = true
    for i = 1, SPAM_THREAD_COUNT do
        local th = task.spawn(SpamThread)
        table.insert(spamThreads, th)
    end
end

local function StopSpam()
    spamRunning = false
    for _, th in ipairs(spamThreads) do
        pcall(function() task.cancel(th) end)
    end
    spamThreads = {}
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeechlessAPMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = WHITE
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Speechless.cc"
Title.TextColor3 = WHITE
Title.TextSize = 32
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0.5, -55, 0, 75)
StatusDot.BackgroundColor3 = GRAY
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 5, 0, 65)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ОСТАНОВЛЕН"
StatusLabel.TextColor3 = GRAY
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -40, 0, 130)
ContentFrame.Position = UDim2.new(0, 20, 0, 110)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

local function CreateButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = WHITE
    btn.BorderSizePixel = 0
    btn.Text = name .. ": OFF"
    btn.TextColor3 = BLACK
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = ContentFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local SpamBtn = CreateButton("Spam (E)", 1)
local ShowSpamBtn = CreateButton("Show Spam", 2)
local ShowStatsBtn = CreateButton("Show Stats", 3)

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 30)
KeyLabel.Position = UDim2.new(0, 0, 1, -35)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Key: E"
KeyLabel.TextColor3 = WHITE
KeyLabel.TextSize = 14
KeyLabel.Font = Enum.Font.GothamBold
KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
KeyLabel.Parent = MainFrame

local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size = UDim2.new(0, 40, 0, 40)
ReopenBtn.Position = UDim2.new(0, 20, 0.5, -20)
ReopenBtn.BackgroundColor3 = BLACK
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Text = "S"
ReopenBtn.TextColor3 = WHITE
ReopenBtn.TextSize = 18
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.Visible = false
ReopenBtn.Parent = ScreenGui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0, 8)
ReopenCorner.Parent = ReopenBtn

local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = WHITE
ReopenStroke.Thickness = 1
ReopenStroke.Parent = ReopenBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ReopenBtn.Visible = true
end)

ReopenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ReopenBtn.Visible = false
end)

local function UpdateStatus(state)
    spamRunning = state
    if spamRunning then
        StatusDot.BackgroundColor3 = GREEN
        StatusLabel.Text = "РАБОТАЕТ"
        StatusLabel.TextColor3 = GREEN
        SpamBtn.Text = "Spam (E): ON"
        SpamBtn.BackgroundColor3 = GREEN
        SpamBtn.TextColor3 = BLACK
    else
        StatusDot.BackgroundColor3 = GRAY
        StatusLabel.Text = "ОСТАНОВЛЕН"
        StatusLabel.TextColor3 = GRAY
        SpamBtn.Text = "Spam (E): OFF"
        SpamBtn.BackgroundColor3 = WHITE
        SpamBtn.TextColor3 = BLACK
    end
end

local FloatingSpamBtn, spamUIVisible = nil, false

local function CreateFloatingSpam()
    if FloatingSpamBtn then return end
    FloatingSpamBtn = Instance.new("TextButton")
    FloatingSpamBtn.Size = UDim2.new(0, 130, 0, 45)
    FloatingSpamBtn.Position = UDim2.new(0, 20, 0, 450)
    FloatingSpamBtn.BackgroundColor3 = WHITE
    FloatingSpamBtn.BorderSizePixel = 0
    FloatingSpamBtn.Text = "SPAM (E): OFF"
    FloatingSpamBtn.TextColor3 = BLACK
    FloatingSpamBtn.TextSize = 13
    FloatingSpamBtn.Font = Enum.Font.GothamBold
    FloatingSpamBtn.Active = true
    FloatingSpamBtn.Draggable = true
    FloatingSpamBtn.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = FloatingSpamBtn
    FloatingSpamBtn.MouseButton1Click:Connect(function()
        if spamRunning then
            StopSpam()
            UpdateStatus(false)
            FloatingSpamBtn.Text = "SPAM (E): OFF"
        else
            StartSpam()
            UpdateStatus(true)
            FloatingSpamBtn.Text = "SPAM (E): ON"
        end
    end)
end

local function DestroyFloatingSpam()
    if FloatingSpamBtn then FloatingSpamBtn:Destroy() FloatingSpamBtn = nil end
end

local FloatingStatsWindow, statsVisible = nil, false

local function CreateFloatingStats()
    if FloatingStatsWindow then return end
    FloatingStatsWindow = Instance.new("Frame")
    FloatingStatsWindow.Size = UDim2.new(0, 150, 0, 100)
    FloatingStatsWindow.Position = UDim2.new(0, 20, 0, 510)
    FloatingStatsWindow.BackgroundColor3 = BLACK
    FloatingStatsWindow.BorderSizePixel = 0
    FloatingStatsWindow.Active = true
    FloatingStatsWindow.Draggable = true
    FloatingStatsWindow.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = FloatingStatsWindow
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1.5
    stroke.Parent = FloatingStatsWindow
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "  STATS"
    title.TextColor3 = WHITE
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = FloatingStatsWindow
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 8)
    tCorner.Parent = title
    local realCpsLabel = Instance.new("TextLabel")
    realCpsLabel.Name = "RealCpsLabel"
    realCpsLabel.Size = UDim2.new(1, -10, 0, 22)
    realCpsLabel.Position = UDim2.new(0, 5, 0, 26)
    realCpsLabel.BackgroundTransparency = 1
    realCpsLabel.Text = "Real CPS: 0"
    realCpsLabel.TextColor3 = WHITE
    realCpsLabel.TextSize = 10
    realCpsLabel.Font = Enum.Font.GothamBold
    realCpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    realCpsLabel.Parent = FloatingStatsWindow
    local realPingLabel = Instance.new("TextLabel")
    realPingLabel.Name = "RealPingLabel"
    realPingLabel.Size = UDim2.new(1, -10, 0, 22)
    realPingLabel.Position = UDim2.new(0, 5, 0, 48)
    realPingLabel.BackgroundTransparency = 1
    realPingLabel.Text = "Ping: 0 ms"
    realPingLabel.TextColor3 = WHITE
    realPingLabel.TextSize = 10
    realPingLabel.Font = Enum.Font.GothamBold
    realPingLabel.TextXAlignment = Enum.TextXAlignment.Left
    realPingLabel.Parent = FloatingStatsWindow
    local realFpsLabel = Instance.new("TextLabel")
    realFpsLabel.Name = "RealFpsLabel"
    realFpsLabel.Size = UDim2.new(1, -10, 0, 22)
    realFpsLabel.Position = UDim2.new(0, 5, 0, 70)
    realFpsLabel.BackgroundTransparency = 1
    realFpsLabel.Text = "FPS: 0"
    realFpsLabel.TextColor3 = WHITE
    realFpsLabel.TextSize = 10
    realFpsLabel.Font = Enum.Font.GothamBold
    realFpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    realFpsLabel.Parent = FloatingStatsWindow
end

local function DestroyFloatingStats()
    if FloatingStatsWindow then FloatingStatsWindow:Destroy() FloatingStatsWindow = nil end
end

local function ToggleSpam()
    if spamRunning then
        StopSpam()
        UpdateStatus(false)
        if FloatingSpamBtn then FloatingSpamBtn.Text = "SPAM (E): OFF" end
    else
        StartSpam()
        UpdateStatus(true)
        if FloatingSpamBtn then FloatingSpamBtn.Text = "SPAM (E): ON" end
    end
end

SpamBtn.MouseButton1Click:Connect(ToggleSpam)

ShowSpamBtn.MouseButton1Click:Connect(function()
    spamUIVisible = not spamUIVisible
    if spamUIVisible then
        CreateFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: ON"
        ShowSpamBtn.BackgroundColor3 = WHITE
        ShowSpamBtn.TextColor3 = BLACK
    else
        DestroyFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: OFF"
    end
end)

ShowStatsBtn.MouseButton1Click:Connect(function()
    statsVisible = not statsVisible
    if statsVisible then
        CreateFloatingStats()
        ShowStatsBtn.Text = "Show Stats: ON"
        ShowStatsBtn.BackgroundColor3 = WHITE
        ShowStatsBtn.TextColor3 = BLACK
    else
        DestroyFloatingStats()
        ShowStatsBtn.Text = "Show Stats: OFF"
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then ToggleSpam() end
end)

task.spawn(function()
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            currentFPS = frameCount
            frameCount = 0
            lastTime = now
        end
    end)
end)

Player.CharacterAdded:Connect(function()
    swordAnimationState.tracks = {}
    swordAnimationState.active = nil
    swordAnimationState.generation = swordAnimationState.generation + 1
    swordAnimationState.last_spam = 0
end)

task.spawn(function()
    while true do
        task.wait(1)
        local now = tick()
        if now - lastCPSTime >= 1 then
            actualCPS = cpsCounter
            cpsCounter = 0
            lastCPSTime = now
        end
        if FloatingStatsWindow then
            local realCpsLabel = FloatingStatsWindow:FindFirstChild("RealCpsLabel")
            local realPingLabel = FloatingStatsWindow:FindFirstChild("RealPingLabel")
            local realFpsLabel = FloatingStatsWindow:FindFirstChild("RealFpsLabel")
            if realCpsLabel then realCpsLabel.Text = ("Real CPS: %d"):format(actualCPS) end
            if realPingLabel then realPingLabel.Text = ("Ping: %d ms"):format(math.floor(GetPing())) end
            if realFpsLabel then realFpsLabel.Text = ("FPS: %d"):format(currentFPS) end
        end
    end
end)

ShowNotification("Speechless.cc [Ap Macro]", "E = Spam toggle | Сделай 1 ручной паринг", 5)
