local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local hook = getgenv and getgenv().hookfunction or hookfunction
local HASH = "5455ef47-de02-4074-808c-8d82c2cd12ec"
local byte, char, floor, bxor = string.byte, string.char, math.floor, bit32.bxor
local captured, votes, key = {}, {}, nil
local spamRunning = false
local actualCPS, cpsCounter, lastCPSTime = 0, 0, tick()

local toggleKey = Enum.KeyCode.E
local waitingForKey = false
local KEY_FILE = "Speechless_APMacro_Key.txt"

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local BG = Color3.fromRGB(0, 0, 0)
local GRAY = Color3.fromRGB(150, 150, 150)

local function timestamp() return tostring(floor(workspace:GetServerTimeNow() * 100)) end

local function ShowNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
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
local AnimCache, Tracks, LastTrack = {}, {}, nil
local ANIM_GENERATION = 0
local ANIM_LAST_SPAM = 0
local ANIM_CANCEL_DELAY = 0.03
local ANIM_CANCEL_FRACTION = 0.35

local function FindAnimIn(obj)
    local a = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Parry") or obj:FindFirstChild("Grab")
    if a then return a end
    local base = obj:FindFirstChild("Base")
    if base then
        return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab")
    end
    return nil
end

local function ResolveParryAnim(swordName)
    if not swordName then return nil end
    if AnimCache[swordName] and AnimCache[swordName].Parent then
        return AnimCache[swordName]
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
    local animType = swordData and swordData.AnimationType or "Single"
    local swordType = swordData and swordData.SwordType or "Single"

    if SwordAPI and type(SwordAPI.GetAnimations) == "function" then
        local ok, anims = pcall(function()
            return SwordAPI:GetAnimations(SwordAPI, {"Parry", "GrabParry"}, animType, swordType)
        end)
        if ok and type(anims) == "table" and anims[1] then
            AnimCache[swordName] = anims[1]
            return anims[1]
        end
    end

    local collection = SwordAPI and SwordAPI:FindFirstChild("Collection") or SwordAPI
    if collection then
        local byType = collection:FindFirstChild(animType)
        if byType then
            local a = FindAnimIn(byType)
            if a then AnimCache[swordName] = a return a end
        end
        local def = collection:FindFirstChild("Default")
        if def then
            local a = FindAnimIn(def)
            if a then AnimCache[swordName] = a return a end
        end
    end
    return nil
end

local function PlayGrabParry(isSpam)
    local char = Player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end

    local swordName = char:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
    local animObj = ResolveParryAnim(swordName)
    if not animObj then return false end

    local trackList = Tracks[animator]
    if not trackList then
        trackList = {}
        Tracks[animator] = trackList
    end
    local track = trackList[animObj]
    if not track or not track.Parent or track.Parent ~= animator then
        local ok, loaded = pcall(function() return animator:LoadAnimation(animObj) end)
        if not ok or not loaded then return false end
        for k, v in animObj:GetAttributes() do
            loaded:SetAttribute(k, v)
        end
        loaded:SetAttribute("GrabParry", true)
        loaded.Priority = Enum.AnimationPriority.Action4
        trackList[animObj] = loaded
        track = loaded
    end

    if isSpam then
        local now = tick()
        if now - ANIM_LAST_SPAM < 0.004 then
            return true
        end
        ANIM_LAST_SPAM = now
        char:SetAttribute("ParryTime", math.max(char:GetAttribute("ParryTime") or 0, track.Length ~= 0 and track.Length or 1))
    else
        ANIM_LAST_SPAM = 0
    end

    ANIM_GENERATION = ANIM_GENERATION + 1
    local gen = ANIM_GENERATION

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
    LastTrack = track
    char:SetAttribute("ParryTime", math.max(char:GetAttribute("ParryTime") or 0, track.Length ~= 0 and (track.Length - track.TimePosition) * speed or 1))

    if not isSpam then
        local len = track.Length or 0
        local delay = math.min(ANIM_CANCEL_DELAY, len * ANIM_CANCEL_FRACTION)
        if delay < 0.05 then delay = 0.05 end
        local t2 = track
        local stopFade = animObj:GetAttribute("StopFadeTime") or 0.05
        task.delay(delay, function()
            if gen ~= ANIM_GENERATION or LastTrack ~= t2 then return end
            pcall(t2.Stop, t2, stopFade)
        end)
    end
    return true
end

pcall(function()
    ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
        local char = Player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChild("Animator")
        if not animator then return end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track.Name == "GrabParry" or track.Name == "Grab" or track:GetAttribute("GrabParry") then
                pcall(function() track:Stop(0.1) end)
            end
        end
        LastTrack = nil
        ANIM_LAST_SPAM = 0
        ANIM_GENERATION = ANIM_GENERATION + 1
    end)
end)

local spamThreads = {}
local SPAM_THREAD_COUNT = 5
local TARGET_CPS = 140
local THREAD_DELAY = SPAM_THREAD_COUNT / TARGET_CPS

local function SpamThread()
    while spamRunning do
        Parry()
        PlayGrabParry(true)
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
ScreenGui.Name = "SpeechlessAPMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 260)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = WHITE
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local CloseBar = Instance.new("TextButton")
CloseBar.Size = UDim2.new(1, 0, 0, 15)
CloseBar.BackgroundColor3 = BLACK
CloseBar.BorderSizePixel = 0
CloseBar.Text = "✕"
CloseBar.TextColor3 = WHITE
CloseBar.TextSize = 12
CloseBar.Font = Enum.Font.GothamBold
CloseBar.Parent = MainFrame

local barStroke = Instance.new("UIStroke", CloseBar)
barStroke.Color = WHITE
barStroke.Thickness = 1

CloseBar.MouseButton1Click:Connect(function()
    MainFrame:Destroy()
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.BackgroundColor3 = BLACK
Title.BorderSizePixel = 0
Title.Text = "Speechless.cc"
Title.TextColor3 = WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 15)
SubTitle.Position = UDim2.new(0, 0, 0, 45)
SubTitle.BackgroundColor3 = BLACK
SubTitle.BorderSizePixel = 0
SubTitle.Text = "Ap Macro"
SubTitle.TextColor3 = GRAY
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Center
SubTitle.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 65)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = WHITE
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

local function CreateButton(name, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = WHITE
    btn.BorderSizePixel = 0
    btn.Text = name .. ": OFF"
    btn.TextColor3 = BLACK
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = ContentFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and BLACK or WHITE
        btn.TextColor3 = state and WHITE or BLACK
        if callback then callback(state) end
    end)
    return btn
end

local SpamBtn = CreateButton("Spam", 1, function(state)
    if state then StartSpam() else StopSpam() end
end)

local ShowSpamBtn = CreateButton("Show Spam", 2, function(state)
    if FloatingSpamBtn then FloatingSpamBtn.Visible = state end
end)

local ShowStatsBtn = CreateButton("Show Stats", 3, function(state)
    if FloatingStatsWindow then FloatingStatsWindow.Visible = state end
end)

local ChangeKeyBtn = CreateButton("Key: " .. toggleKey.Name, 4, function()
    if waitingForKey then return end
    waitingForKey = true
    ChangeKeyBtn.Text = "Нажми клавишу..."
end)

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, 0, 0, 30)
KeyBox.BackgroundColor3 = WHITE
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Введи клавишу (E, Q, F...)"
KeyBox.Text = ""
KeyBox.TextColor3 = BLACK
KeyBox.TextSize = 11
KeyBox.Font = Enum.Font.Gotham
KeyBox.LayoutOrder = 5
KeyBox.Parent = ContentFrame
local kbCorner = Instance.new("UICorner")
kbCorner.CornerRadius = UDim.new(0, 4)
kbCorner.Parent = KeyBox

KeyBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    if KeyBox.Text == "" then
        toggleKey = Enum.KeyCode.E
    else
        local ok, code = pcall(function() return Enum.KeyCode[KeyBox.Text:upper()] end)
        if ok and code then
            toggleKey = code
        else
            KeyBox.Text = "Неверная клавиша"
            task.delay(1.5, function() KeyBox.Text = "" end)
            return
        end
    end
    ChangeKeyBtn.Text = "Key: " .. toggleKey.Name
    KeyBox.Text = ""
    if writefile then pcall(writefile, KEY_FILE, toggleKey.Name) end
    ShowNotification("Speechless.cc", "Хоткей: " .. toggleKey.Name, 3)
end)

local FloatingSpamBtn = Instance.new("TextButton")
FloatingSpamBtn.Size = UDim2.new(0, 130, 0, 45)
FloatingSpamBtn.Position = UDim2.new(0, 20, 0, 450)
FloatingSpamBtn.BackgroundColor3 = WHITE
FloatingSpamBtn.BorderSizePixel = 0
FloatingSpamBtn.Text = "SPAM: OFF"
FloatingSpamBtn.TextColor3 = BLACK
FloatingSpamBtn.TextSize = 13
FloatingSpamBtn.Font = Enum.Font.GothamBold
FloatingSpamBtn.Active = true
FloatingSpamBtn.Draggable = true
FloatingSpamBtn.Visible = false
FloatingSpamBtn.Parent = ScreenGui
local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 8)
fCorner.Parent = FloatingSpamBtn

local function ToggleSpam()
    if spamRunning then
        StopSpam()
        SpamBtn.Text = "Spam: OFF"
        SpamBtn.BackgroundColor3 = WHITE
        SpamBtn.TextColor3 = BLACK
        FloatingSpamBtn.Text = "SPAM: OFF"
        FloatingSpamBtn.BackgroundColor3 = WHITE
        FloatingSpamBtn.TextColor3 = BLACK
    else
        StartSpam()
        SpamBtn.Text = "Spam: ON"
        SpamBtn.BackgroundColor3 = BLACK
        SpamBtn.TextColor3 = WHITE
        FloatingSpamBtn.Text = "SPAM: ON"
        FloatingSpamBtn.BackgroundColor3 = BLACK
        FloatingSpamBtn.TextColor3 = WHITE
    end
end

FloatingSpamBtn.MouseButton1Click:Connect(ToggleSpam)

local FloatingStatsWindow = Instance.new("Frame")
FloatingStatsWindow.Size = UDim2.new(0, 160, 0, 70)
FloatingStatsWindow.Position = UDim2.new(0, 20, 0, 510)
FloatingStatsWindow.BackgroundColor3 = BLACK
FloatingStatsWindow.BorderSizePixel = 0
FloatingStatsWindow.Active = true
FloatingStatsWindow.Draggable = true
FloatingStatsWindow.Visible = false
FloatingStatsWindow.Parent = ScreenGui
local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 8)
sCorner.Parent = FloatingStatsWindow
local sStroke = Instance.new("UIStroke")
sStroke.Color = WHITE
sStroke.Thickness = 1.5
sStroke.Parent = FloatingStatsWindow

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1, 0, 0, 22)
sTitle.BackgroundColor3 = BLACK
sTitle.BorderSizePixel = 0
sTitle.Text = "  STATS"
sTitle.TextColor3 = WHITE
sTitle.TextSize = 10
sTitle.Font = Enum.Font.GothamBold
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = FloatingStatsWindow
local sTitleCorner = Instance.new("UICorner")
sTitleCorner.CornerRadius = UDim.new(0, 8)
sTitleCorner.Parent = sTitle

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if waitingForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                waitingForKey = false
                ChangeKeyBtn.Text = "Key: " .. toggleKey.Name
                return
            end
            toggleKey = input.KeyCode
            waitingForKey = false
            ChangeKeyBtn.Text = "Key: " .. toggleKey.Name
            if writefile then pcall(writefile, KEY_FILE, toggleKey.Name) end
            ShowNotification("Speechless.cc", "Хоткей изменён: " .. toggleKey.Name, 3)
        end
        return
    end

    if input.KeyCode == toggleKey then
        ToggleSpam()
    end
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
        if FloatingStatsWindow and FloatingStatsWindow.Visible then
            realCpsLabel.Text = ("Real CPS: %d"):format(actualCPS)
        end
    end
end)

Player.CharacterAdded:Connect(function()
    Tracks = {}
    LastTrack = nil
    ANIM_GENERATION = ANIM_GENERATION + 1
    ANIM_LAST_SPAM = 0
end)

if isfile and readfile and isfile(KEY_FILE) then
    local ok, saved = pcall(readfile, KEY_FILE)
    if ok and saved and saved ~= "" then
        local code = Enum.KeyCode[saved]
        if code then
            toggleKey = code
            ChangeKeyBtn.Text = "Key: " .. toggleKey.Name
        end
    end
end

ShowNotification("Speechless.cc [Ap Macro]", "E = Spam toggle | Сделай 1 ручной паринг", 5)
