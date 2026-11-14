local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local name = Player.Name

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(10, 10, 10)
local BG = BLACK
local GREEN = Color3.fromRGB(0, 255, 0)
local RED = Color3.fromRGB(255, 0, 0)

local spamRunning = false
local actualCPS, cpsCounter, lastCPSTime = 0, 0, tick()
local currentPing, lastPingUpdate, PING_UPDATE_INTERVAL = 0, 0, 1.0
local currentFPS = 60

local insertIntoTable = table.insert
local clearTable = table.clear
local delayTask = task.delay
local maxValue = math.max

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local packages = ReplicatedStorage.Packages
local controllers = ReplicatedStorage.Controllers
local balls = Workspace.Balls
local alive = Workspace.Alive
local runtime = Workspace.Runtime

local swordEventConnections = { parry_connections = {}, fire_sword_connections = {}, play_parry = nil, sword_fn = nil }

if remotes and type(getconnections) == "function" then
    local parrySuccessAll = remotes:WaitForChild("ParrySuccessAll", 10)
    if parrySuccessAll then
        local ok, conns = pcall(getconnections, parrySuccessAll.OnClientEvent)
        if ok and type(conns) == "table" then
            for _, c in ipairs(conns) do
                local success, fn = pcall(function() return c.Function end)
                if success and type(fn) == "function" then
                    insertIntoTable(swordEventConnections.parry_connections, c)
                    swordEventConnections.play_parry = fn
                end
            end
        end
    end
end

local swordAnimationState = {
    active = nil, cache = {}, tracks = {}, api = nil, generation = 0, last_spam = 0, cancel_delay = 0.12, cancel_fraction = 0.35,
}
pcall(function() swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI) end)

Player.CharacterAdded:Connect(function()
    clearTable(swordAnimationState.tracks)
    swordAnimationState.active = nil
    swordAnimationState.generation = swordAnimationState.generation + 1
    swordAnimationState.last_spam = 0
end)

local ballState = {
    state = { AerodynamicTime = tick(), LastWarping = tick(), LerpRadians = 0, Curving = tick() },
    positions = {}, replicator = nil,
}

local eventCapture = { captured = {}, hooked = {}, originals = {}, token_fn = nil }
for _, f in pairs(getgc(true)) do
    if type(f) ~= "function" or not debug.info(f, "s"):find("PRY", 1, true) then continue end
    for _, v in pairs(debug.getupvalues(f)) do
        if type(v) == "function" then eventCapture.token_fn = v break end
    end
    if eventCapture.token_fn then break end
end

local bitwiseXor = bit32.bxor
local stringChar = string.char
local stringByte = string.byte
local concatTable = table.concat
local createTable = table.create

eventCapture.tokenize = function(inputValue)
    local primaryValue = 100
    local secondaryValue = tostring(math.floor(Workspace:GetServerTimeNow() * primaryValue))
    local tertiaryValue = eventCapture.token_fn(inputValue, "TIME")
    local quaternaryValue = createTable(#secondaryValue)
    for i = 1, #secondaryValue do
        local auxiliaryValue = 256
        quaternaryValue[i] = stringChar(bitwiseXor((stringByte(secondaryValue, i) + i) % auxiliaryValue, stringByte(tertiaryValue, (i - 1) % #tertiaryValue + 1)))
    end
    return concatTable(quaternaryValue)
end

eventCapture.unhook = function()
    for k, v in pairs(eventCapture.originals) do
        pcall(function() setreadonly(k, false) k.__index = v setreadonly(k, true) end)
    end
    clearTable(eventCapture.hooked)
    clearTable(eventCapture.originals)
end

eventCapture.valid_args = function(args)
    return #args == 8 and type(args[2]) == "string" and type(args[3]) == "string" and type(args[4]) == "number" and typeof(args[5]) == "CFrame" and type(args[6]) == "table" and type(args[7]) == "table" and type(args[8]) == "boolean"
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

ballState.get = function()
    for _, b in pairs(balls:GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
    return nil
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

ballState.position = function(b)
    local target = b or ballState.get()
    if target then return ballState.positions[target] or target.Position end
    return Vector3.zero
end

local inventoryUnlockManager = { current = nil, visited = {} }
local curveController = { get_cframe = function() return Workspace.CurrentCamera.CFrame end }

local UserInputService_MouseEnabled = UserInputService.MouseEnabled

inventoryUnlockManager.by_mouse = function()
    local list = {}
    for _, v in pairs(alive:GetChildren()) do
        if v.Name ~= name and v.PrimaryPart then insertIntoTable(list, v) end
    end
    if #list == 0 then inventoryUnlockManager.current = nil return nil end
    local cam = Workspace.CurrentCamera
    local direction
    if UserInputService_MouseEnabled then
        local mouseLoc = UserInputService:GetMouseLocation()
        direction = cam:ScreenPointToRay(mouseLoc.X, mouseLoc.Y).Direction
    else
        local vp = cam.ViewportSize
        direction = cam:ViewportPointToRay(vp.X * 0.5, vp.Y * 0.5).Direction
    end
    local best = -math.huge
    local target = nil
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

local parryController = { count = 0, first_signal = nil }

parryController.fire = function(isSpam)
    local cam = Workspace.CurrentCamera
    if not inventoryUnlockManager.by_mouse() then return end
    
    local cframe = curveController.get_cframe()
    local targetPart = inventoryUnlockManager.current and inventoryUnlockManager.current.PrimaryPart
    local viewportPos
    
    if targetPart then
        local p = cam:WorldToViewportPoint(targetPart.Position)
        viewportPos = {p.X, p.Y}
    elseif UserInputService_MouseEnabled then
        local m = UserInputService:GetMouseLocation()
        viewportPos = {m.X, m.Y}
    else
        local v = cam.ViewportSize
        viewportPos = {v.X * 0.5, v.Y * 0.5}
    end
    
    local screenPoints = {}
    for _, v in pairs(alive:GetChildren()) do
        local p = v.PrimaryPart
        if p then
            local sp = cam:WorldToScreenPoint(p.Position)
            if sp and sp.Z > 0 then screenPoints[v.Name] = sp end
        end
    end
    
    if next(eventCapture.captured) == nil then
        if not parryController.first_signal then
            parryController.first_signal = require(packages.Signal).new()
            parryController.first_signal:Connect(require(controllers["SwordsController \12"].PRY))
        end
        parryController.first_signal:Fire(0.5, cframe, screenPoints, viewportPos, false)
        if isSpam then swordAnimationState.grab(true) end
    else
        swordAnimationState.grab(isSpam)
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
    
    cpsCounter = cpsCounter + 1
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

local function ShowNotification(title, text, duration)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3}) end)
end

local spamThreads = {}
local SPAM_THREAD_COUNT = 11

local function SpamThread()
    while spamRunning do
        parryController.fire(true)
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
MainFrame.Size = UDim2.new(0, 230, 0, 230)
MainFrame.Position = UDim2.new(0, 20, 0, 80)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = BLACK
Title.BackgroundTransparency = 0
Title.BorderSizePixel = 0
Title.Text = "  Speechless.cc [Ap Macro]"
Title.TextColor3 = WHITE
Title.TextSize = 13
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = WHITE
TitleStroke.Thickness = 1
TitleStroke.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 28, 0, 24)
ToggleBtn.Position = UDim2.new(1, -34, 0, 6)
ToggleBtn.BackgroundColor3 = BLACK
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = WHITE
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.ZIndex = 3
ToggleBtn.Parent = Title

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = WHITE
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleBtn

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -12, 1, -46)
ContentFrame.Position = UDim2.new(0, 6, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = WHITE
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

local FULL_SIZE, MIN_SIZE = UDim2.new(0, 230, 0, 230), UDim2.new(0, 230, 0, 36)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local menuOpen = true

local function SetMenuOpen(open)
    menuOpen = open
    TweenService:Create(MainFrame, tweenInfo, {Size = open and FULL_SIZE or MIN_SIZE}):Play()
    if open then
        ContentFrame.Visible = true
        ToggleBtn.Text = "-"
    else
        task.delay(0.3, function() if not menuOpen then ContentFrame.Visible = false end end)
        ToggleBtn.Text = "+"
    end
end

ToggleBtn.MouseButton1Click:Connect(function() SetMenuOpen(not menuOpen) end)

local function CreateSectionLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = WHITE
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.ZIndex = 2
    lbl.Parent = ContentFrame
    return lbl
end

local function CreateButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = BLACK
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = name .. ": INACTIVE"
    btn.TextColor3 = RED
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.ZIndex = 2
    btn.Parent = ContentFrame
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = WHITE
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    return btn
end

CreateSectionLabel("Main", 1)
local CpsLabel = Instance.new("TextLabel")
CpsLabel.Name = "CpsLabel"
CpsLabel.Size = UDim2.new(1, 0, 0, 20)
CpsLabel.BackgroundTransparency = 1
CpsLabel.Text = "  CPS: 0"
CpsLabel.TextColor3 = WHITE
CpsLabel.TextSize = 11
CpsLabel.Font = Enum.Font.Gotham
CpsLabel.TextXAlignment = Enum.TextXAlignment.Left
CpsLabel.LayoutOrder = 2
CpsLabel.ZIndex = 2
CpsLabel.Parent = ContentFrame

local SpamBtn = CreateButton("Spam (E)", 3)
local ShowSpamBtn = CreateButton("Show Spam", 4)
local ShowStatsBtn = CreateButton("Show Stats", 5)

local FloatingSpamBtn, spamUIVisible = nil, false

local function CreateFloatingSpam()
    if FloatingSpamBtn then return end
    FloatingSpamBtn = Instance.new("TextButton")
    FloatingSpamBtn.Size = UDim2.new(0, 130, 0, 45)
    FloatingSpamBtn.Position = UDim2.new(0, 20, 0, 450)
    FloatingSpamBtn.BackgroundColor3 = BLACK
    FloatingSpamBtn.BackgroundTransparency = 0
    FloatingSpamBtn.BorderSizePixel = 0
    FloatingSpamBtn.Text = "SPAM: INACTIVE"
    FloatingSpamBtn.TextColor3 = RED
    FloatingSpamBtn.TextSize = 13
    FloatingSpamBtn.Font = Enum.Font.Gotham
    FloatingSpamBtn.Active = true
    FloatingSpamBtn.Draggable = true
    FloatingSpamBtn.Parent = ScreenGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = WHITE
    stroke.Thickness = 1
    stroke.Parent = FloatingSpamBtn
    
    FloatingSpamBtn.MouseButton1Click:Connect(function()
        if spamRunning then
            StopSpam()
            FloatingSpamBtn.Text = "SPAM: INACTIVE"
            FloatingSpamBtn.TextColor3 = RED
            SpamBtn.Text = "Spam (E): INACTIVE"
            SpamBtn.TextColor3 = RED
        else
            StartSpam()
            FloatingSpamBtn.Text = "SPAM: ACTIVE"
            FloatingSpamBtn.TextColor3 = GREEN
            SpamBtn.Text = "Spam (E): ACTIVE"
            SpamBtn.TextColor3 = GREEN
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
    FloatingStatsWindow.BackgroundColor3 = BG
    FloatingStatsWindow.BorderSizePixel = 0
    FloatingStatsWindow.Active = true
    FloatingStatsWindow.Draggable = true
    FloatingStatsWindow.Parent = ScreenGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = WHITE
    stroke.Thickness = 1
    stroke.Parent = FloatingStatsWindow
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "  STATS"
    title.TextColor3 = WHITE
    title.TextSize = 10
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = FloatingStatsWindow
    
    local realCpsLabel = Instance.new("TextLabel")
    realCpsLabel.Name = "RealCpsLabel"
    realCpsLabel.Size = UDim2.new(1, -10, 0, 22)
    realCpsLabel.Position = UDim2.new(0, 5, 0, 26)
    realCpsLabel.BackgroundTransparency = 1
    realCpsLabel.Text = "Real CPS: 0"
    realCpsLabel.TextColor3 = WHITE
    realCpsLabel.TextSize = 10
    realCpsLabel.Font = Enum.Font.Gotham
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
    realPingLabel.Font = Enum.Font.Gotham
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
    realFpsLabel.Font = Enum.Font.Gotham
    realFpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    realFpsLabel.Parent = FloatingStatsWindow
end

local function DestroyFloatingStats()
    if FloatingStatsWindow then FloatingStatsWindow:Destroy() FloatingStatsWindow = nil end
end

local function ToggleSpam()
    if spamRunning then
        StopSpam()
        SpamBtn.Text = "Spam (E): INACTIVE"
        SpamBtn.TextColor3 = RED
        if FloatingSpamBtn then 
            FloatingSpamBtn.Text = "SPAM: INACTIVE" 
            FloatingSpamBtn.TextColor3 = RED 
        end
    else
        StartSpam()
        SpamBtn.Text = "Spam (E): ACTIVE"
        SpamBtn.TextColor3 = GREEN
        if FloatingSpamBtn then 
            FloatingSpamBtn.Text = "SPAM: ACTIVE" 
            FloatingSpamBtn.TextColor3 = GREEN
        end
    end
end

SpamBtn.MouseButton1Click:Connect(ToggleSpam)

ShowSpamBtn.MouseButton1Click:Connect(function()
    spamUIVisible = not spamUIVisible
    if spamUIVisible then
        CreateFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: ACTIVE"
        ShowSpamBtn.TextColor3 = GREEN
    else
        DestroyFloatingSpam()
        ShowSpamBtn.Text = "Show Spam: INACTIVE"
        ShowSpamBtn.TextColor3 = RED
    end
end)

ShowStatsBtn.MouseButton1Click:Connect(function()
    statsVisible = not statsVisible
    if statsVisible then
        CreateFloatingStats()
        ShowStatsBtn.Text = "Show Stats: ACTIVE"
        ShowStatsBtn.TextColor3 = GREEN
    else
        DestroyFloatingStats()
        ShowStatsBtn.Text = "Show Stats: INACTIVE"
        ShowStatsBtn.TextColor3 = RED
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
    clearTable(swordAnimationState.tracks)
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
            if CpsLabel then CpsLabel.Text = "  CPS: " .. actualCPS end
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

ShowNotification("Speechless.cc [Ap Macro]", "E = Spam toggle | Press the block a few times.", 5)
