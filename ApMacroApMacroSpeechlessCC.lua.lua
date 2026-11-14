local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local HASH = "5455ef47-de02-4074-808c-8d82c2cd12ec"
local ANIM_COOLDOWN = 0.05
local SPAM_THROTTLE = 0.001
local CANCEL_DELAY = 0.12
local CANCEL_FRACTION = 0.35
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local BG = BLACK

local byte, char, floor, bxor = string.byte, string.char, math.floor, bit32.bxor
local clamp, min, max = math.clamp, math.min, math.max

local function timestamp()
    return tostring(floor(workspace:GetServerTimeNow() * 100))
end

local function ShowNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
end

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local packages = ReplicatedStorage:FindFirstChild("Packages")
local controllers = ReplicatedStorage:FindFirstChild("Controllers")
local balls = workspace:WaitForChild("Balls")
local alive = workspace:WaitForChild("Alive")

local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
local heartbeat = RunService.Heartbeat
local preSimulation = RunService.PreSimulation
local postSimulation = RunService.PostSimulation

local currentPing, lastPingUpdate, PING_UPDATE_INTERVAL = 0, 0, 1.0
local currentFPS = 60

local function GetPing()
    local now = tick()
    if now - lastPingUpdate > PING_UPDATE_INTERVAL then
        lastPingUpdate = now
        local ok, result = pcall(function() return dataPing:GetValue() end)
        currentPing = ok and result or 100
    end
    return currentPing
end

local token_fn = nil
for _, fn in getgc(true) do
    if type(fn) ~= "function" then continue end
    if not debug.info(fn, "s"):find("PRY", 1, true) then continue end
    for _, up in debug.getupvalues(fn) do
        if type(up) == "function" then
            token_fn = up
            break
        end
    end
    if token_fn then break end
end

local function tokenize()
    if not token_fn then return nil end
    local stamp = timestamp()
    local ok, key = pcall(token_fn, HASH, "TIME")
    if not ok or type(key) ~= "string" or #key == 0 then return nil end
    local out = table.create(#stamp)
    for i = 1, #stamp do
        out[i] = char(bxor((byte(stamp, i) + i) % 256, byte(key, (i - 1) % #key + 1)))
    end
    return table.concat(out)
end

local eventCapture = {
    captured = {},
    hooked = {},
    originals = {},
}

local function valid_args(args)
    return #args == 8
        and type(args[2]) == "string"
        and type(args[3]) == "string"
        and type(args[4]) == "number"
        and typeof(args[5]) == "CFrame"
        and type(args[6]) == "table"
        and type(args[7]) == "table"
        and type(args[8]) == "boolean"
end

local function unhook_all()
    for mt, orig in pairs(eventCapture.originals) do
        pcall(function()
            setreadonly(mt, false)
            mt.__index = orig
            setreadonly(mt, true)
        end)
    end
    table.clear(eventCapture.hooked)
    table.clear(eventCapture.originals)
end

local function hook_remote(remote)
    if next(eventCapture.captured) ~= nil then return end
    local mt = getrawmetatable(remote)
    if not mt or eventCapture.hooked[mt] then return end
    eventCapture.hooked[mt] = true
    setreadonly(mt, false)
    local orig_index = mt.__index
    eventCapture.originals[mt] = orig_index
    mt.__index = function(self, key)
        if (key == "FireServer" and self:IsA("RemoteEvent"))
        or (key == "InvokeServer" and self:IsA("RemoteFunction")) then
            return function(_, ...)
                local args = table.pack(...)
                if valid_args(args) then
                    eventCapture.captured[self] = args
                    unhook_all()
                end
                return orig_index(self, key)(_, table.unpack(args, 1, args.n))
            end
        end
        return orig_index(self, key)
    end
    setreadonly(mt, true)
end

for _, obj in ReplicatedStorage:GetDescendants() do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        hook_remote(obj)
    end
end

local first_signal = nil
local function get_first_signal()
    if first_signal then return first_signal end
    if not packages or not controllers then return nil end
    local Signal = packages:FindFirstChild("Signal")
    local swordsCtrl = controllers:FindFirstChild("SwordsController \12")
    if not Signal or not swordsCtrl then return nil end
    local ok1, sigMod = pcall(require, Signal)
    local ok2, prY = pcall(require, swordsCtrl)
    if ok1 and ok2 and sigMod and prY and prY.PRY then
        first_signal = sigMod.new()
        first_signal:Connect(prY.PRY)
    end
    return first_signal
end

local camCache, pointsCache, pointsCacheTime, POINTS_TTL = nil, {}, 0, 0.05

local function refreshPoints()
    local now = tick()
    if now - pointsCacheTime < POINTS_TTL then return end
    pointsCacheTime = now
    table.clear(pointsCache)
    local aliveFolder = workspace:FindFirstChild("Alive")
    if aliveFolder and camCache then
        for _, character in ipairs(aliveFolder:GetChildren()) do
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                pointsCache[character.Name] = camCache:WorldToViewportPoint(root.Position)
            end
        end
    end
end

local SwordAPI_Collection = nil
do
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local api = shared and shared:FindFirstChild("SwordAPI")
    SwordAPI_Collection = api and api:FindFirstChild("Collection")
end

local animCache, loadedTracks, activeTrack = {}, {}, nil
local animGeneration = 0
local last_spam_time = 0

local function resolve_animation(swordName)
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    if not shared then return nil end
    local getSword = shared:FindFirstChild("ReplicatedInstances")
    getSword = getSword and getSword:FindFirstChild("Swords")
    getSword = getSword and getSword:FindFirstChild("GetSword")

    local swordData = nil
    if getSword then
        local ok, res = pcall(function() return getSword:Invoke(swordName) end)
        if ok then swordData = res end
    end
    local animationType = (swordData and swordData.AnimationType) or "Single"
    local swordType = (swordData and swordData.SwordType) or "Single"

    local api = shared:FindFirstChild("SwordAPI")
    if api and type(api.GetAnimations) == "function" then
        local ok, res = pcall(function()
            return api:GetAnimations(swordName, {"Parry", "GrabParry"}, animationType, swordType)
        end)
        if ok and type(res) == "table" and res[1] then
            return res[1]
        end
    end

    if SwordAPI_Collection then
        local function pick(node)
            return node:FindFirstChild("GrabParry")
                or node:FindFirstChild("Parry")
                or node:FindFirstChild("Grab")
        end
        local node = SwordAPI_Collection:FindFirstChild(animationType)
        if node then
            local a = pick(node)
            if a then return a end
        end
        local def = SwordAPI_Collection:FindFirstChild("Default")
        if def then return pick(def) end
    end
    return nil
end

local function get_track()
    local char = Player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return nil end

    local currentSword = char:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
    if loadedTracks.Animator ~= animator then
        loadedTracks = { Animator = animator }
        activeTrack = nil
    end
    if loadedTracks[currentSword] then
        return loadedTracks[currentSword], animator, char
    end

    local anim = resolve_animation(currentSword)
    if not anim then return nil end

    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if not ok or not track then return nil end

    for k, v in pairs(anim:GetAttributes()) do
        track:SetAttribute(k, v)
    end
    track:SetAttribute("GrabParry", true)
    track.Priority = Enum.AnimationPriority.Action4
    loadedTracks[currentSword] = track
    return track, animator, char
end

local function play_grab_parry(from_spam)
    local track, animator, char = get_track()
    if not track then return end

    if from_spam then
        local now = tick()
        if now - last_spam_time < CANCEL_DELAY then
            if activeTrack and activeTrack.IsPlaying then
                char:SetAttribute("ParryTime",
                    max(char:GetAttribute("ParryTime") or 0,
                        (activeTrack.Length ~= 0 and activeTrack.Length) or 1))
                return
            end
        end
        last_spam_time = now
    else
        last_spam_time = 0
    end

    animGeneration += 1
    local gen = animGeneration

    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
        if t:GetAttribute("GrabParry") or t:GetAttribute("Parry") or t:GetAttribute("SuccessParry") then
            pcall(t.Stop, t, t:GetAttribute("StopFadeTime") or 0.05)
        end
    end

    local fadeIn = track:GetAttribute("PlayFadeTime") or 0.05
    local weight = track:GetAttribute("PlayWeight") or 1
    local speed = track:GetAttribute("PlaySpeed") or 1

    track.TimePosition = 0
    track:Play(fadeIn, weight, speed)
    activeTrack = track

    char:SetAttribute("ParryTime",
        max(char:GetAttribute("ParryTime") or 0,
            track.Length ~= 0 and (track.Length - track.TimePosition) * speed or 1))

    if from_spam then
        local fadeOut = track:GetAttribute("StopFadeTime") or 0.05
        local length = track.Length or 0
        local delay = (length > 0) and min(CANCEL_DELAY, length * CANCEL_FRACTION) or CANCEL_DELAY
        if delay < 0.05 then delay = 0.05 end
        task.delay(delay, function()
            if gen ~= animGeneration or activeTrack ~= track then return end
            pcall(track.Stop, track, fadeOut)
        end)
    end
end

Player.CharacterAdded:Connect(function()
    loadedTracks = {}
    activeTrack = nil
    animGeneration += 1
    last_spam_time = 0
end)

local function build_points()
    local map = {}
    for _, character in ipairs(alive:GetChildren()) do
        local root = character.PrimaryPart
        if root then
            local p = camCache:WorldToScreenPoint(root.Position)
            if p and p.Z > 0 then
                map[character.Name] = p
            end
        end
    end
    return map
end

local function build_center()
    local size = camCache.ViewportSize
    if UserInputService.MouseEnabled then
        local m = UserInputService:GetMouseLocation()
        return {m.X, m.Y}
    end
    return {size.X * 0.5, size.Y * 0.5}
end

local function fire_parry(from_spam)
    camCache = workspace.CurrentCamera
    if not camCache then return end
    refreshPoints()

    local cframe = camCache.CFrame
    local points = pointsCache
    local center = build_center()
    local allPts = build_points()

    if next(eventCapture.captured) == nil then
        local sig = get_first_signal()
        if sig then
            sig:Fire(0.5, cframe, allPts, center, false)
        end
        if from_spam then play_grab_parry(true) end
        return
    end

    play_grab_parry(from_spam)

    local token = tokenize()
    if not token then return end

    for remote, args in pairs(eventCapture.captured) do
        local payload = {
            args[1],
            args[2],
            token,
            0.5,
            cframe,
            allPts,
            center,
            false,
        }
        if remote:IsA("RemoteEvent") then
            remote:FireServer(table.unpack(payload))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(table.unpack(payload))
        end
    end
end

local manual_on = false
local manual_conn = nil
local manual_last = 0

local function set_manual(on)
    on = on == true
    if manual_on == on then return end
    manual_on = on
    if manual_conn then
        manual_conn:Disconnect()
        manual_conn = nil
    end
    if on then
        manual_conn = preSimulation:Connect(function()
            local now = tick()
            if now - manual_last < SPAM_THROTTLE then return end
            manual_last = now
            fire_parry(true)
        end)
    end
    if _G.SpeechlessSpamBtn then
        _G.SpeechlessSpamBtn.Text = on and "Spam (E): ON" or "Spam (E): OFF"
    end
    if _G.SpeechlessFloatingBtn then
        _G.SpeechlessFloatingBtn.Text = on and "SPAM (E): ON" or "SPAM (E): OFF"
    end
end

local function toggle_manual() set_manual(not manual_on) end

pcall(function()
    remotes.ParrySuccessAll.OnClientEvent:Connect(function()
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
        activeTrack = nil
    end)
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeechlessAPMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 200)
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

local FULL_SIZE, MIN_SIZE = UDim2.new(0, 230, 0, 200), UDim2.new(0, 230, 0, 36)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local menuOpen = true

local function SetMenuOpen(open)
    menuOpen = open
    TweenService:Create(MainFrame, tweenInfo, {Size = open and FULL_SIZE or MIN_SIZE}):Play()
    if open then
        ContentFrame.Visible = true
        ToggleBtn.Text = "-"
    else
        task.delay(0.3, function()
            if not menuOpen then ContentFrame.Visible = false end
        end)
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
    btn.Text = name .. ": OFF"
    btn.TextColor3 = WHITE
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.ZIndex = 2
    btn.Parent = ContentFrame
    return btn
end

CreateSectionLabel("Main", 1)
local SpamBtn = CreateButton("Spam (E)", 2)
local ShowSpamBtn = CreateButton("Show Spam", 3)
local ShowStatsBtn = CreateButton("Show Stats", 4)

_G.SpeechlessSpamBtn = SpamBtn

local FloatingSpamBtn, spamUIVisible = nil, false

local function CreateFloatingSpam()
    if FloatingSpamBtn then return end
    FloatingSpamBtn = Instance.new("TextButton")
    FloatingSpamBtn.Size = UDim2.new(0, 130, 0, 45)
    FloatingSpamBtn.Position = UDim2.new(0, 20, 0, 450)
    FloatingSpamBtn.BackgroundColor3 = BLACK
    FloatingSpamBtn.BackgroundTransparency = 0
    FloatingSpamBtn.BorderSizePixel = 0
    FloatingSpamBtn.Text = manual_on and "SPAM (E): ON" or "SPAM (E): OFF"
    FloatingSpamBtn.TextColor3 = WHITE
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
        toggle_manual()
    end)

    _G.SpeechlessFloatingBtn = FloatingSpamBtn
end

local function DestroyFloatingSpam()
    if FloatingSpamBtn then
        FloatingSpamBtn:Destroy()
        FloatingSpamBtn = nil
        _G.SpeechlessFloatingBtn = nil
    end
end

local FloatingStatsWindow, statsVisible = nil, false

local function CreateFloatingStats()
    if FloatingStatsWindow then return end
    FloatingStatsWindow = Instance.new("Frame")
    FloatingStatsWindow.Size = UDim2.new(0, 150, 0, 78)
    FloatingStatsWindow.Position = UDim2.new(0, 20, 0, 510)
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
    local realPingLabel = Instance.new("TextLabel")
    realPingLabel.Name = "RealPingLabel"
    realPingLabel.Size = UDim2.new(1, -10, 0, 22)
    realPingLabel.Position = UDim2.new(0, 5, 0, 26)
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
    realFpsLabel.Position = UDim2.new(0, 5, 0, 48)
    realFpsLabel.BackgroundTransparency = 1
    realFpsLabel.Text = "FPS: 0"
    realFpsLabel.TextColor3 = WHITE
    realFpsLabel.TextSize = 10
    realFpsLabel.Font = Enum.Font.GothamBold
    realFpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    realFpsLabel.Parent = FloatingStatsWindow
end

local function DestroyFloatingStats()
    if FloatingStatsWindow then
        FloatingStatsWindow:Destroy()
        FloatingStatsWindow = nil
    end
end

SpamBtn.MouseButton1Click:Connect(function()
    toggle_manual()
end)

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
    if input.KeyCode == Enum.KeyCode.E then toggle_manual() end
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
    loadedTracks = {}
    activeTrack = nil
end)

task.spawn(function()
    while true do
        task.wait(1)
        if FloatingStatsWindow then
            local realPingLabel = FloatingStatsWindow:FindFirstChild("RealPingLabel")
            local realFpsLabel = FloatingStatsWindow:FindFirstChild("RealFpsLabel")
            if realPingLabel then realPingLabel.Text = ("Ping: %d ms"):format(math.floor(GetPing())) end
            if realFpsLabel then realFpsLabel.Text = ("FPS: %d"):format(currentFPS) end
        end
    end
end)

ShowNotification("Speechless.cc [Ap Macro]", "E = Spam toggle | Press the block a few times", 5)
