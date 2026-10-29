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
local antilagEnabled = false
local actualCPS, cpsCounter, lastCPSTime = 0, 0, tick()
local currentPing, lastPingUpdate, PING_UPDATE_INTERVAL = 0, 0, 1.0
local ANIM_COOLDOWN, LastPlayTime = 0.05, 0
local currentFPS = 60
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local BG = Color3.fromRGB(15, 15, 15)
local antilagConnection = nil

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
                ShowNotification("Ruqwiri Ap Macro [LOW]", "Ap Macro Activated", 4)
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
local AnimFix_Cache, Loaded_Tracks, LastPlayedTrack = {}, {}, nil

local function GetParryAnimation(swordName)
    local defaultAnim = SwordAPI.Collection.Default:FindFirstChild("GrabParry")
    if not swordName or swordName == "" then return defaultAnim end
    if AnimFix_Cache[swordName] then return AnimFix_Cache[swordName] end
    local ok, swordData = pcall(function()
        return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(swordName)
    end)
    if not ok or type(swordData) ~= "table" or not swordData.AnimationType then
        AnimFix_Cache[swordName] = defaultAnim
        return defaultAnim
    end
    for _, obj in pairs(SwordAPI.Collection:GetChildren()) do
        if obj.Name == swordData.AnimationType then
            local anim = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Grab")
            if anim then AnimFix_Cache[swordName] = anim return anim end
        end
    end
    AnimFix_Cache[swordName] = defaultAnim
    return defaultAnim
end

local function GetOrLoadTrack()
    local char = Player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return nil end
    local currentSword = char:GetAttribute("CurrentlyEquippedSword") or "Default"
    if Loaded_Tracks.Character ~= char then
        Loaded_Tracks = {Character = char}
        LastPlayedTrack = nil
    end
    if Loaded_Tracks[currentSword] then return Loaded_Tracks[currentSword] end
    local animation = GetParryAnimation(currentSword)
    if not animation then return nil end
    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = false
        Loaded_Tracks[currentSword] = track
        return track
    end
    return nil
end

local function PlayGrabParry()
    if tick() - LastPlayTime < ANIM_COOLDOWN then return end
    LastPlayTime = tick()
    local track = GetOrLoadTrack()
    if not track then return end
    pcall(function()
        if LastPlayedTrack and LastPlayedTrack ~= track then
            pcall(function() LastPlayedTrack:Stop(0) end)
        end
        track:Stop(0)
        track.TimePosition = 0
        track:Play(0, 1, 1)
        LastPlayedTrack = track
    end)
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
            if track.Name == "GrabParry" or track.Name == "Grab" then
                pcall(function() track:Stop(0.1) end)
            end
        end
        LastPlayedTrack = nil
    end)
end)

local disabledObjects = {}

local function KillEffect(obj)
    if not antilagEnabled then return end
    pcall(function()
        if obj:IsA("Sound") then
            obj.Volume = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end)
end

local function EnableAntiLag()
    if antilagEnabled then return end
    antilagEnabled = true
    task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not antilagEnabled then break end
            KillEffect(obj)
        end
    end)
    antilagConnection = workspace.DescendantAdded:Connect(function(obj)
        if antilagEnabled then
            KillEffect(obj)
        end
    end)
end

local function DisableAntiLag()
    if not antilagEnabled then return end
    antilagEnabled = false
    if antilagConnection then
        antilagConnection:Disconnect()
        antilagConnection = nil
    end
end

local spamThreads = {}
local SPAM_THREAD_COUNT = 3
local TARGET_CPS = 140
local THREAD_DELAY = (1 / TARGET_CPS) * SPAM_THREAD_COUNT

local function SpamThread()
    while spamRunning do
        Parry()
        PlayGrabParry()
        task.wait(THREAD_DELAY)
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
ScreenGui.Name = "RuqwiriAPMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 190, 0, 160)
MainFrame.Position = UDim2.new(0, 20, 0, 80)
MainFrame.BackgroundColor3 = BG
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BackgroundTransparency = 0.4
Title.BorderSizePixel = 0
Title.Text = "  Ruqwiri Ap Macro [LOW]"
Title.TextColor3 = WHITE
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 22, 0, 18)
ToggleBtn.Position = UDim2.new(1, -28, 0, 5)
ToggleBtn.BackgroundColor3 = WHITE
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = BLACK
ToggleBtn.TextSize = 10
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 3
ToggleBtn.Parent = Title

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleBtn

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -34)
ContentFrame.Position = UDim2.new(0, 5, 0, 32)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = WHITE
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 3)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

local FULL_SIZE, MIN_SIZE = UDim2.new(0, 190, 0, 160), UDim2.new(0, 190, 0, 28)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local menuOpen = true

local function SetMenuOpen(open)
    menuOpen = open
    TweenService:Create(MainFrame, tweenInfo, {Size = open and FULL_SIZE or MIN_SIZE}):Play()
    if open then
        ContentFrame.Visible = true
        ToggleBtn.Text = "-"
    else
        task.delay(0.2, function()
            if not menuOpen then ContentFrame.Visible = false end
        end)
        ToggleBtn.Text = "+"
    end
end

ToggleBtn.MouseButton1Click:Connect(function() SetMenuOpen(not menuOpen) end)

local function CreateSectionLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = WHITE
    lbl.TextSize = 9
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.ZIndex = 2
    lbl.Parent = ContentFrame
    return lbl
end

local function CreateButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = WHITE
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = name .. ": OFF"
    btn.TextColor3 = BLACK
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.ZIndex = 2
    btn.Parent = ContentFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    return btn
end

CreateSectionLabel("Main", 1)
local SpamBtn = CreateButton("Spam (E)", 2)
local ShowSpamBtn = CreateButton("Show Spam", 3)
local AntiLagBtn = CreateButton("Anti Lag", 4)
local ShowStatsBtn = CreateButton("Show Stats", 5)

local FloatingSpamBtn, spamUIVisible = nil, false

local function CreateFloatingSpam()
    if FloatingSpamBtn then return end
    FloatingSpamBtn = Instance.new("TextButton")
    FloatingSpamBtn.Size = UDim2.new(0, 150, 0, 55)
    FloatingSpamBtn.Position = UDim2.new(0, 20, 0, 400)
    FloatingSpamBtn.BackgroundColor3 = WHITE
    FloatingSpamBtn.BorderSizePixel = 0
    FloatingSpamBtn.Text = "SPAM (E): OFF"
    FloatingSpamBtn.TextColor3 = BLACK
    FloatingSpamBtn.TextSize = 14
    FloatingSpamBtn.Font = Enum.Font.GothamBold
    FloatingSpamBtn.Active = true
    FloatingSpamBtn.Draggable = true
    FloatingSpamBtn.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = FloatingSpamBtn
    FloatingSpamBtn.MouseButton1Click:Connect(function()
        if spamRunning then
            StopSpam()
            FloatingSpamBtn.Text = "SPAM (E): OFF"
            SpamBtn.Text = "Spam (E): OFF"
        else
            StartSpam()
            FloatingSpamBtn.Text = "SPAM (E): ON"
            SpamBtn.Text = "Spam (E): ON"
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
    FloatingStatsWindow.Size = UDim2.new(0, 130, 0, 85)
    FloatingStatsWindow.Position = UDim2.new(0, 20, 0, 470)
    FloatingStatsWindow.BackgroundColor3 = BG
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
    title.Size = UDim2.new(1, 0, 0, 18)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "  STATS"
    title.TextColor3 = WHITE
    title.TextSize = 9
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = FloatingStatsWindow
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 8)
    tCorner.Parent = title
    local realCpsLabel = Instance.new("TextLabel")
    realCpsLabel.Name = "RealCpsLabel"
    realCpsLabel.Size = UDim2.new(1, -10, 0, 18)
    realCpsLabel.Position = UDim2.new(0, 5, 0, 22)
    realCpsLabel.BackgroundTransparency = 1
    realCpsLabel.Text = "Real CPS: 0"
    realCpsLabel.TextColor3 = WHITE
    realCpsLabel.TextSize = 9
    realCpsLabel.Font = Enum.Font.GothamBold
    realCpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    realCpsLabel.Parent = FloatingStatsWindow
    local realPingLabel = Instance.new("TextLabel")
    realPingLabel.Name = "RealPingLabel"
    realPingLabel.Size = UDim2.new(1, -10, 0, 18)
    realPingLabel.Position = UDim2.new(0, 5, 0, 42)
    realPingLabel.BackgroundTransparency = 1
    realPingLabel.Text = "Ping: 0 ms"
    realPingLabel.TextColor3 = WHITE
    realPingLabel.TextSize = 9
    realPingLabel.Font = Enum.Font.GothamBold
    realPingLabel.TextXAlignment = Enum.TextXAlignment.Left
    realPingLabel.Parent = FloatingStatsWindow
    local realFpsLabel = Instance.new("TextLabel")
    realFpsLabel.Name = "RealFpsLabel"
    realFpsLabel.Size = UDim2.new(1, -10, 0, 18)
    realFpsLabel.Position = UDim2.new(0, 5, 0, 62)
    realFpsLabel.BackgroundTransparency = 1
    realFpsLabel.Text = "FPS: 0"
    realFpsLabel.TextColor3 = WHITE
    realFpsLabel.TextSize = 9
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
        SpamBtn.Text = "Spam (E): OFF"
        if FloatingSpamBtn then FloatingSpamBtn.Text = "SPAM (E): OFF" end
    else
        StartSpam()
        SpamBtn.Text = "Spam (E): ON"
        if FloatingSpamBtn then FloatingSpamBtn.Text = "SPAM (E): ON" end
    end
end

SpamBtn.MouseButton1Click:Connect(ToggleSpam)

ShowSpamBtn.MouseButton1Click:Connect(function()
    spamUIVisible = not spamUIVisible
    if spamUIVisible then
        CreateFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: ON"
    else
        DestroyFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: OFF"
    end
end)

AntiLagBtn.MouseButton1Click:Connect(function()
    if antilagEnabled then
        DisableAntiLag()
        AntiLagBtn.Text = "Anti Lag: OFF"
    else
        EnableAntiLag()
        AntiLagBtn.Text = "Anti Lag: ON"
    end
end)

ShowStatsBtn.MouseButton1Click:Connect(function()
    statsVisible = not statsVisible
    if statsVisible then
        CreateFloatingStats()
        ShowStatsBtn.Text = "Show Stats: ON"
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
    Loaded_Tracks = {}
    LastPlayedTrack = nil
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

ShowNotification("Ruqwiri Ap Macro [LOW]", "E = Spam toggle | Сделай 1 ручной паринг", 5)
