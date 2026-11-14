local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(10, 10, 10)
local GRAY = Color3.fromRGB(40, 40, 40)
local RED = Color3.fromRGB(200, 50, 50)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 210)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -105)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local draggingMain = false
local dragStartMain = nil
local startPosMain = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMain then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartMain
            MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
    end
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -50, 0, 5)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = WHITE
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = WHITE
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 30)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local function CreateTab(name, xPos)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 70, 1, 0)
    tab.Position = UDim2.new(0, xPos, 0, 0)
    tab.BackgroundTransparency = 1
    tab.Text = name
    tab.TextColor3 = WHITE
    tab.TextSize = 13
    tab.Font = Enum.Font.Gotham
    tab.Parent = TabsFrame
    return tab
end

local HomeTab = CreateTab("Home", 10)
local VisualTab = CreateTab("Visual", 85)
local MiscTab = CreateTab("Misc", 160)
local ConfigTab = CreateTab("Config", 235)

local TabLine = Instance.new("Frame")
TabLine.Size = UDim2.new(0, 70, 0, 2)
TabLine.Position = UDim2.new(0, 10, 0, 28)
TabLine.BackgroundColor3 = WHITE
TabLine.BorderSizePixel = 0
TabLine.Parent = TabsFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = WHITE
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local function CreateTabContainer()
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundTransparency = 1
    f.Visible = false
    f.Parent = ContentFrame
    return f
end

local HomeContainer = CreateTabContainer()
local VisualContainer = CreateTabContainer()
local MiscContainer = CreateTabContainer()
local ConfigContainer = CreateTabContainer()
HomeContainer.Visible = true

local function SelectTab(tabBtn, xOffset, container)
    TweenService:Create(TabLine, TweenInfo.new(0.2), {Position = UDim2.new(0, xOffset, 0, 28)}):Play()
    for _, t in pairs({HomeTab, VisualTab, MiscTab, ConfigTab}) do
        t.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    tabBtn.TextColor3 = WHITE
    for _, c in pairs({HomeContainer, VisualContainer, MiscContainer, ConfigContainer}) do
        c.Visible = false
    end
    container.Visible = true
end

HomeTab.MouseButton1Click:Connect(function() SelectTab(HomeTab, 10, HomeContainer) end)
VisualTab.MouseButton1Click:Connect(function() SelectTab(VisualTab, 85, VisualContainer) end)
MiscTab.MouseButton1Click:Connect(function() SelectTab(MiscTab, 160, MiscContainer) end)
ConfigTab.MouseButton1Click:Connect(function() SelectTab(ConfigTab, 235, ConfigContainer) end)
SelectTab(HomeTab, 10, HomeContainer)

local allToggles = {}
local allSliders = {}

local function CreateToggle(parent, name, yPos, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 36, 0, 18)
    toggleBg.Position = UDim2.new(1, -36, 0.5, -9)
    toggleBg.BackgroundColor3 = defaultState and WHITE or GRAY
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    toggleKnob.BackgroundColor3 = defaultState and BLACK or WHITE
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

    local state = defaultState
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local function SetState(newState, fireCallback)
        state = newState
        if state then
            TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = WHITE}):Play()
            TweenService:Create(toggleKnob, tweenInfo, {
                Position = UDim2.new(1, -16, 0.5, -7),
                BackgroundColor3 = BLACK
            }):Play()
        else
            TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = GRAY}):Play()
            TweenService:Create(toggleKnob, tweenInfo, {
                Position = UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = WHITE
            }):Play()
        end
        if fireCallback ~= false and callback then callback(state) end
    end

    clickBtn.MouseButton1Click:Connect(function()
        SetState(not state, true)
    end)

    table.insert(allToggles, {set = SetState, default = defaultState})
end

local function CreateSlider(parent, name, yPos, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 45)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = GRAY
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = WHITE
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 0, 20)
    clickArea.Position = UDim2.new(0, 0, 0, 17)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = container

    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * relX)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        label.Text = name .. ": " .. val
        if callback then callback(val) end
    end

    clickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function Reset()
        local relX = (default - min) / (max - min)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        label.Text = name .. ": " .. default
        if callback then callback(default) end
    end
    table.insert(allSliders, Reset)
end

local espEnabled = false
local espObjects = {}

local function ApplyESP(character)
    if not espEnabled then return end
    if not character or character == Player.Character then return end

    if espObjects[character] then
        espObjects[character]:Destroy()
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "CustomESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    espObjects[character] = highlight
end

local function ToggleESP(state)
    espEnabled = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character then
                ApplyESP(plr.Character)
            end
        end
    else
        for char, obj in pairs(espObjects) do
            if obj then obj:Destroy() end
        end
        espObjects = {}
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if espEnabled and plr ~= Player then
            task.wait(0.5)
            ApplyESP(char)
        end
    end)
end)

local function SetSpeed(val)
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = val
        end
    end
end

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _G.CurrentSpeed and _G.CurrentSpeed > 16 then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = _G.CurrentSpeed end
    end
    if _G.CurrentFOV then
        Workspace.CurrentCamera.FieldOfView = _G.CurrentFOV
    end
end)

local hitboxSize = 1
local originalSizes = {}
local hitboxEnabled = false

local function ApplyHitbox()
    if not hitboxEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not originalSizes[hrp] then
                    originalSizes[hrp] = hrp.Size
                end
                hrp.Size = originalSizes[hrp] * hitboxSize
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end

local function ResetHitbox()
    for hrp, size in pairs(originalSizes) do
        if hrp and hrp.Parent then
            hrp.Size = size
        end
    end
    originalSizes = {}
end

RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        ApplyHitbox()
    end
end)

local originalShadows = Lighting.GlobalShadows
local disabledEffects = {}

local function ToggleBoost(state)
    if state then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
        
        disabledEffects = {}
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") and effect.Enabled then
                effect.Enabled = false
                table.insert(disabledEffects, effect)
            end
        end
    else
        Lighting.GlobalShadows = originalShadows
        for _, effect in ipairs(disabledEffects) do
            if effect and effect.Parent then
                effect.Enabled = true
            end
        end
        disabledEffects = {}
    end
end

local tpToolActive = false
local tpTool = nil

local function CreateTPTool()
    if tpTool then return end

    tpTool = Instance.new("Tool")
    tpTool.Name = "TP Tool"
    tpTool.RequiresHandle = false
    tpTool.CanBeDropped = false
    tpTool.Parent = Player:WaitForChild("Backpack")

    tpTool.Activated:Connect(function()
        local mouse = Player:GetMouse()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if mouse.Target then
                char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 5, mouse.Hit.Z)
            end
        end
    end)
end

local function DestroyTPTool()
    if tpTool then
        tpTool:Destroy()
        tpTool = nil
    end
end

Player.CharacterAdded:Connect(function()
    if tpToolActive then
        task.wait(0.5)
        CreateTPTool()
    end
end)

local InfoGui = Instance.new("ScreenGui")
InfoGui.Name = "InfoOverlay"
InfoGui.ResetOnSpawn = false
InfoGui.Enabled = false
InfoGui.Parent = Player:WaitForChild("PlayerGui")

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(0, 110, 0, 20)
InfoFrame.Position = UDim2.new(0, 15, 0, 15)
InfoFrame.BackgroundColor3 = BLACK
InfoFrame.BackgroundTransparency = 0
InfoFrame.BorderSizePixel = 0
InfoFrame.Active = true
InfoFrame.Parent = InfoGui

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -10, 1, 0)
InfoText.Position = UDim2.new(0, 5, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "fps 0 / 0 ms"
InfoText.TextColor3 = WHITE
InfoText.TextSize = 11
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = InfoFrame

local draggingInfo = false
local dragStartInfo = nil
local startPosInfo = nil

InfoFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingInfo = true
        dragStartInfo = input.Position
        startPosInfo = InfoFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingInfo then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartInfo
            InfoFrame.Position = UDim2.new(startPosInfo.X.Scale, startPosInfo.X.Offset + delta.X, startPosInfo.Y.Scale, startPosInfo.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingInfo = false
    end
end)

local currentFPS = 0
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

task.spawn(function()
    while true do
        task.wait(1)
        if InfoGui.Enabled then
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            InfoText.Text = string.format("fps %d / %d ms", currentFPS, ping)
        end
    end
end)

CreateToggle(HomeContainer, "Stats", 10, false, function(state)
    InfoGui.Enabled = state
end)

CreateToggle(VisualContainer, "Player ESP", 10, false, function(state)
    ToggleESP(state)
end)

CreateSlider(VisualContainer, "Custom FOV", 50, 70, 120, 70, function(val)
    _G.CurrentFOV = val
    Workspace.CurrentCamera.FieldOfView = val
end)

CreateToggle(VisualContainer, "Boost FPS Lite", 100, false, function(state)
    ToggleBoost(state)
end)

CreateSlider(MiscContainer, "WalkSpeed", 10, 16, 200, 16, function(val)
    _G.CurrentSpeed = val
    SetSpeed(val)
end)

CreateToggle(MiscContainer, "Hitbox Expander", 60, false, function(state)
    hitboxEnabled = state
    if not state then
        ResetHitbox()
    end
end)

CreateSlider(MiscContainer, "Hitbox Size", 100, 1, 20, 1, function(val)
    hitboxSize = val
    ResetHitbox()
end)

CreateToggle(MiscContainer, "TP Tool", 150, false, function(state)
    tpToolActive = state
    if state then
        CreateTPTool()
    else
        DestroyTPTool()
    end
end)

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, -20, 0, 40)
ResetBtn.Position = UDim2.new(0, 10, 0, 10)
ResetBtn.BackgroundColor3 = RED
ResetBtn.BorderSizePixel = 0
ResetBtn.Text = "Reset All Settings"
ResetBtn.TextColor3 = WHITE
ResetBtn.TextSize = 14
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = ConfigContainer

ResetBtn.MouseButton1Click:Connect(function()
    for _, t in ipairs(allToggles) do
        t.set(t.default, true)
    end
    
    for _, resetFunc in ipairs(allSliders) do
        resetFunc()
    end

    ResetHitbox()
    SetSpeed(16)
    
    ResetBtn.Text = "Reset Success!"
    task.delay(2, function()
        ResetBtn.Text = "Reset All Settings"
    end)
end)

local isMinimized = false
local originalSize = UDim2.new(0, 320, 0, 210)
local minimizedSize = UDim2.new(0, 320, 0, 60)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = minimizedSize}):Play()
        MinBtn.Text = "+"
        ContentFrame.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = originalSize}):Play()
        MinBtn.Text = "—"
        ContentFrame.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
