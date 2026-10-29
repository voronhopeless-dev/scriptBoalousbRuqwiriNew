repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local cfg = {
    hitboxEnabled = false,
    hitboxSize = 2.5,
    espEnabled = false,
    fullbright = false,
    stretch43 = false
}

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    TopBar = Color3.fromRGB(20, 20, 20),
    Element = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(255, 255, 255),
    Inactive = Color3.fromRGB(50, 50, 50)
}

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local originalFOV = 70
if camera then originalFOV = camera.FieldOfView end

local function applyFullbright()
    Lighting.Brightness = 5
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
end

local function restoreLighting()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.Ambient = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
end

local function applyStretch()
    if not camera then return end
    local screenSize = camera.ViewportSize
    local aspect = screenSize.X / screenSize.Y
    local targetAspect = 4 / 3
    if aspect > targetAspect then
        local newFov = math.deg(2 * math.atan(math.tan(math.rad(originalFOV) / 2) * (targetAspect / aspect)))
        camera.FieldOfView = newFov
    end
end

local function restoreStretch()
    if camera then
        camera.FieldOfView = originalFOV
    end
end

local originalSizes = {}
local hitboxVisuals = {}

local function updateHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                if cfg.hitboxEnabled then
                    if not originalSizes[p] then 
                        originalSizes[p] = head.Size 
                    end
                    head.Size = Vector3.new(cfg.hitboxSize, cfg.hitboxSize, cfg.hitboxSize)
                    head.Transparency = 0.5
                    head.CanCollide = false
                    if not hitboxVisuals[p] then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Adornee = head
                        box.AlwaysOnTop = true
                        box.ZIndex = 5
                        box.Size = head.Size
                        box.Transparency = 0.5
                        box.Color = BrickColor.new("Really red")
                        box.Parent = head
                        hitboxVisuals[p] = box
                    else
                        hitboxVisuals[p].Size = head.Size
                    end
                else
                    if originalSizes[p] then
                        head.Size = originalSizes[p]
                        head.Transparency = 0
                        head.CanCollide = true
                        originalSizes[p] = nil
                    end
                    if hitboxVisuals[p] then
                        hitboxVisuals[p]:Destroy()
                        hitboxVisuals[p] = nil
                    end
                end
            end
        end
    end
end

local espDrawings = {}
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Transparency = 1
    return line
end

local function updateESP()
    if not cfg.espEnabled then
        for _, lines in pairs(espDrawings) do
            for _, line in pairs(lines) do line.Visible = false end
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not espDrawings[p] then
                    espDrawings[p] = {
                        Head = createLine(), Torso = createLine(),
                        LeftArm = createLine(), RightArm = createLine(),
                        LeftLeg = createLine(), RightLeg = createLine()
                    }
                end
                
                local lines = espDrawings[p]
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                local function getPos(part)
                    if part then
                        local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then return Vector2.new(pos.X, pos.Y) end
                    end
                    return nil
                end

                local headPos, torsoPos = getPos(head), getPos(torso)
                local lArmPos, rArmPos = getPos(leftArm), getPos(rightArm)
                local lLegPos, rLegPos = getPos(leftLeg), getPos(rightLeg)

                if headPos and torsoPos and lArmPos and rArmPos and lLegPos and rLegPos then
                    lines.Head.From, lines.Head.To, lines.Head.Visible = headPos, torsoPos, true
                    lines.LeftArm.From, lines.LeftArm.To, lines.LeftArm.Visible = torsoPos, lArmPos, true
                    lines.RightArm.From, lines.RightArm.To, lines.RightArm.Visible = torsoPos, rArmPos, true
                    lines.LeftLeg.From, lines.LeftLeg.To, lines.LeftLeg.Visible = torsoPos, lLegPos, true
                    lines.RightLeg.From, lines.RightLeg.To, lines.RightLeg.Visible = torsoPos, rLegPos, true
                else
                    for _, line in pairs(lines) do line.Visible = false end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateHitboxes()
    updateESP()
    if cfg.fullbright then applyFullbright() end
    if cfg.stretch43 then applyStretch() end
end)

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if cfg.stretch43 then applyStretch() else originalFOV = camera.FieldOfView end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 330)
Main.Position = UDim2.new(0.5, -160, 0.5, -165)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(40, 40, 40)
Stroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Theme.TopBar
Title.Text = "  Neverlose.cc"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Theme.Inactive
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 6)

local function CreateToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Element
    btn.Text = "  " .. name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(1, -25, 0.5, -8)
    indicator.BackgroundColor3 = default and Theme.Accent or Theme.Inactive
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Theme.Accent or Theme.Inactive
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Theme.Element
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -45, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.TextDim
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 4)
    bar.Position = UDim2.new(0, 8, 0, 28)
    bar.BackgroundColor3 = Theme.Background
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            local val = min + (max - min) * relX
            val = math.floor(val * 10) / 10
            valueLabel.Text = tostring(val)
            callback(val)
        end
    end)
end

CreateToggle("Fullbright", cfg.fullbright, function(v) 
    cfg.fullbright = v 
    if not v then restoreLighting() end
end)

CreateToggle("ESP Skeleton", cfg.espEnabled, function(v) 
    cfg.espEnabled = v 
    if not v then
        for _, lines in pairs(espDrawings) do
            for _, line in pairs(lines) do line.Visible = false end
        end
    end
end)

CreateToggle("Head Hitbox", cfg.hitboxEnabled, function(v) 
    cfg.hitboxEnabled = v 
    if not v then updateHitboxes() end
end)

CreateToggle("4:3 Stretch", cfg.stretch43, function(v) 
    cfg.stretch43 = v 
    if not v then restoreStretch() end
end)

CreateSlider("Hitbox Size", 1, 10, cfg.hitboxSize, function(v) 
    cfg.hitboxSize = v 
end)

local dragging, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end)
