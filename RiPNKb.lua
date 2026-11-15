local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(10, 10, 10)
local GRAY = Color3.fromRGB(40, 40, 40)

local eventCapture = { captured = {}, hooked = {}, originals = {}, token_fn = nil }
for _, func in pairs(getgc(true)) do
    if type(func) ~= "function" or not debug.info(func, "s"):find("PRY", 1, true) then continue end
    for _, val in pairs(debug.getupvalues(func)) do
        if type(val) == "function" then eventCapture.token_fn = val break end
    end
    if eventCapture.token_fn then break end
end

eventCapture.tokenize = function(inputValue)
    local currentTimeStr = tostring(math.floor(Workspace:GetServerTimeNow() * 100))
    local secretKey = eventCapture.token_fn(inputValue, "TIME")
    local resultChars = table.create(#currentTimeStr)
    for i = 1, #currentTimeStr do
        resultChars[i] = string.char(bit32.bxor((string.byte(currentTimeStr, i) + i) % 256, string.byte(secretKey, (i - 1) % #secretKey + 1)))
    end
    return table.concat(resultChars)
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
    local originalIndex = mt.__index
    eventCapture.originals[mt] = originalIndex
    mt.__index = function(self, key)
        if (key == "FireServer" and self:IsA("RemoteEvent")) or (key == "InvokeServer" and self:IsA("RemoteFunction")) then
            return function(s, ...)
                local args = {...}
                if eventCapture.valid_args(args) then
                    eventCapture.captured[self] = args
                    for k, v in pairs(eventCapture.originals) do
                        pcall(function() setreadonly(k, false) k.__index = v setreadonly(k, true) end)
                    end
                    table.clear(eventCapture.hooked)
                    table.clear(eventCapture.originals)
                end
                return originalIndex(self, key)(s, unpack(args))
            end
        end
        return originalIndex(self, key)
    end
    setreadonly(mt, true)
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then eventCapture.hook(obj) end
end

local Balls = Workspace:WaitForChild("Balls")
local Alive = Workspace:WaitForChild("Alive")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Controllers = ReplicatedStorage:WaitForChild("Controllers")

local autoParryEnabled = false
local parryAccuracy = 50
local lastParryTime = 0

local swordAnimationState = { active = nil, cache = {}, tracks = {}, api = nil, generation = 0, last_spam = 0, cancel_delay = 0.12, cancel_fraction = 0.35 }
pcall(function() swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI) end)

local function FindAnimationObj(folder)
    local p = folder:FindFirstChild("GrabParry") or folder:FindFirstChild("Parry") or folder:FindFirstChild("Grab")
    if p then return p end
    local base = folder:FindFirstChild("Base")
    if base then return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab") end
    return nil
end

local function ResolveSwordAnim(char, swordName)
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
    return nil
end

local function PlayParryAnim()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not animator then return false end
    
    local swordName = char:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
    local animObj = ResolveSwordAnim(char, swordName)
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
    
    swordAnimationState.generation = swordAnimationState.generation + 1
    local gen = swordAnimationState.generation
    
    for _, t in pairs(animator:GetPlayingAnimationTracks()) do
        if t:GetAttribute("GrabParry") or t:GetAttribute("Parry") or t:GetAttribute("SuccessParry") then
            pcall(t.Stop, t, t:GetAttribute("StopFadeTime") or 0.05)
        end
    end
    
    track.TimePosition = 0
    track:Play(0.05, 1, 1)
    swordAnimationState.active = track
    
    task.delay(0.1, function()
        if gen ~= swordAnimationState.generation then return end
        pcall(track.Stop, track, 0.05)
    end)
    return true
end

local function GetRealBall()
    for _, ball in pairs(Balls:GetChildren()) do
        if ball:GetAttribute("realBall") then return ball end
    end
    return nil
end

local function IsTargetingMe()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Highlight") ~= nil
end

local function FireParry()
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local closestEnemy = nil
    local shortestDist = math.huge
    for _, enemy in pairs(Alive:GetChildren()) do
        if enemy ~= char and enemy.PrimaryPart then
            local dist = (char.PrimaryPart.Position - enemy.PrimaryPart.Position).Magnitude
            if dist < shortestDist then shortestDist = dist closestEnemy = enemy end
        end
    end
    if not closestEnemy then return end

    local cam = Workspace.CurrentCamera
    local targetPos = closestEnemy.PrimaryPart.Position
    local viewportPos = {cam:WorldToViewportPoint(targetPos).X, cam:WorldToViewportPoint(targetPos).Y}
    local screenPoints = {}
    for _, p in pairs(Alive:GetChildren()) do
        if p.PrimaryPart then
            local sp = cam:WorldToScreenPoint(p.PrimaryPart.Position)
            if sp.Z > 0 then screenPoints[p.Name] = sp end
        end
    end

    PlayParryAnim()

    if next(eventCapture.captured) ~= nil then
        for remote, args in pairs(eventCapture.captured) do
            local newToken = eventCapture.tokenize(args[2])
            local newArgs = {args[1], args[2], newToken, 0.5, cam.CFrame, screenPoints, viewportPos, false}
            if remote:IsA("RemoteEvent") then remote:FireServer(unpack(newArgs))
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(newArgs)) end
            return
        end
    else
        local signal = require(Packages.Signal).new()
        signal:Connect(require(Controllers["SwordsController \12"].PRY))
        signal:Fire(0.5, cam.CFrame, screenPoints, viewportPos, false)
    end
end

RunService.PreSimulation:Connect(function()
    if not autoParryEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local ball = GetRealBall()
    if not ball or not ball.Parent or not ball:FindFirstChild("zoomies") then return end
    if not IsTargetingMe() then return end
    if tick() - lastParryTime < 0.3 then return end

    local speed = ball.zoomies.VectorVelocity.Magnitude
    local dist = (char.PrimaryPart.Position - ball.Position).Magnitude
    if speed <= 0 then return end

    local ping = 50
    pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    
    local timeToImpact = dist / speed
    local pingOffset = (ping / 1000)
    local dynamicThreshold = (parryAccuracy / 100) * 0.5 + pingOffset

    if timeToImpact <= dynamicThreshold then 
        FireParry() 
        lastParryTime = tick()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeechlessBB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 200)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local dragging, dragStart, startPos = false, nil, nil
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Speechless.cc °Paid Version°"
Title.TextColor3 = WHITE
Title.TextSize = 14
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local isMinimized = false
local originalSize = UDim2.new(0, 400, 0, 200)
local minimizedSize = UDim2.new(0, 400, 0, 30)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
ToggleBtn.Position = UDim2.new(1, -50, 0, 5)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "—"
ToggleBtn.TextColor3 = WHITE
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = WHITE
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 30)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local CombatTab = Instance.new("TextButton")
CombatTab.Size = UDim2.new(0, 80, 1, 0)
CombatTab.Position = UDim2.new(0, 20, 0, 0)
CombatTab.BackgroundTransparency = 1
CombatTab.Text = "Combat"
CombatTab.TextColor3 = WHITE
CombatTab.TextSize = 14
CombatTab.Font = Enum.Font.Gotham
CombatTab.Parent = TabsFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = minimizedSize}):Play()
        ToggleBtn.Text = "+"
        ContentFrame.Visible = false
        TabsFrame.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize}):Play()
        ToggleBtn.Text = "—"
        ContentFrame.Visible = true
        TabsFrame.Visible = true
    end
end)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -40, 0, 40)
container.Position = UDim2.new(0, 20, 0, 15)
container.BackgroundTransparency = 1
container.Parent = ContentFrame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -60, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Auto Parry"
label.TextColor3 = WHITE
label.TextSize = 14
label.Font = Enum.Font.Gotham
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = container

local toggleBg = Instance.new("Frame")
toggleBg.Size = UDim2.new(0, 44, 0, 22)
toggleBg.Position = UDim2.new(1, -44, 0.5, -11)
toggleBg.BackgroundColor3 = GRAY
toggleBg.BorderSizePixel = 0
toggleBg.Parent = container
local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(1, 0)
bgCorner.Parent = toggleBg

local toggleKnob = Instance.new("Frame")
toggleKnob.Size = UDim2.new(0, 18, 0, 18)
toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
toggleKnob.BackgroundColor3 = WHITE
toggleKnob.BorderSizePixel = 0
toggleKnob.Parent = toggleBg
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = toggleKnob

local clickBtn = Instance.new("TextButton")
clickBtn.Size = UDim2.new(1, 0, 1, 0)
clickBtn.BackgroundTransparency = 1
clickBtn.Text = ""
clickBtn.Parent = container

local toggleState = false
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

clickBtn.MouseButton1Click:Connect(function()
    toggleState = not toggleState
    autoParryEnabled = toggleState
    if toggleState then
        TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = WHITE}):Play()
        TweenService:Create(toggleKnob, tweenInfo, {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = BLACK}):Play()
    else
        TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = GRAY}):Play()
        TweenService:Create(toggleKnob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = WHITE}):Play()
    end
end)

local sliderContainer = Instance.new("Frame")
sliderContainer.Size = UDim2.new(1, -40, 0, 50)
sliderContainer.Position = UDim2.new(0, 20, 0, 65)
sliderContainer.BackgroundTransparency = 1
sliderContainer.Parent = ContentFrame

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Accuracy: 50"
sliderLabel.TextColor3 = WHITE
sliderLabel.TextSize = 14
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderContainer

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 4)
sliderBg.Position = UDim2.new(0, 0, 0, 28)
sliderBg.BackgroundColor3 = GRAY
sliderBg.BorderSizePixel = 0
sliderBg.Parent = sliderContainer
local sBgCorner = Instance.new("UICorner")
sBgCorner.CornerRadius = UDim.new(1, 0)
sBgCorner.Parent = sliderBg

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = WHITE
fill.BorderSizePixel = 0
fill.Parent = sliderBg
local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(1, 0)
fCorner.Parent = fill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new(0.5, -7, 0.5, -7)
knob.BackgroundColor3 = WHITE
knob.BorderSizePixel = 0
knob.Parent = sliderBg
local kCorner = Instance.new("UICorner")
kCorner.CornerRadius = UDim.new(1, 0)
kCorner.Parent = knob

local clickArea = Instance.new("TextButton")
clickArea.Size = UDim2.new(1, 0, 0, 25)
clickArea.Position = UDim2.new(0, 0, 0, 18)
clickArea.BackgroundTransparency = 1
clickArea.Text = ""
clickArea.Parent = sliderContainer

local sDragging = false
local function updateSlider(input)
    local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    local val = math.floor(1 + 99 * relX)
    fill.Size = UDim2.new(relX, 0, 1, 0)
    knob.Position = UDim2.new(relX, -7, 0.5, -7)
    sliderLabel.Text = "Accuracy: " .. val
    parryAccuracy = val
end

clickArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sDragging = true
        updateSlider(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sDragging = false
    end
end)
