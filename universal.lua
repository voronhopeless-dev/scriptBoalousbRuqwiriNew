local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("SpeechlessIT")
if oldGui then
    oldGui:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(8, 8, 10),
    Panel = Color3.fromRGB(15, 15, 18),
    Panel2 = Color3.fromRGB(23, 23, 27),
    Panel3 = Color3.fromRGB(31, 31, 36),
    Text = Color3.fromRGB(245, 245, 247),
    Muted = Color3.fromRGB(145, 145, 153),
    Accent = Color3.fromRGB(225, 225, 230),
    On = Color3.fromRGB(235, 235, 240),
    Off = Color3.fromRGB(48, 48, 54),
    Stroke = Color3.fromRGB(55, 55, 62),
}

local Config = {
    TeamCheck = true,
    PlayerHighlight = false,
    ModelGlow = false,
    Outline = true,
    NameTags = false,
    Distance = false,
    Tracers = false,
    VisibleOnly = false,

    ShowFOV = true,
    FOVRadius = 120,
    AimAssist = false,
    Smoothness = 0.25,
    TargetPart = "HumanoidRootPart",

    HitboxPreview = false,
    HitboxPart = "Head",

    WalkSpeed = 16,
    JumpPower = 50,
    MovementEnabled = false,

    FPSVisible = true,
    PingVisible = true,
}

local ModuleRegistry = {}

local function RegisterModule(name, startFunction, stopFunction)
    ModuleRegistry[name] = {
        Start = startFunction,
        Stop = stopFunction,
        Enabled = false,
    }
end

local function SetModule(name, enabled)
    local module = ModuleRegistry[name]
    if not module then
        warn("[Speechless] Unknown module:", name)
        return false
    end

    if module.Enabled == enabled then
        return true
    end

    module.Enabled = enabled

    local callback = enabled and module.Start or module.Stop
    if callback then
        local ok, err = pcall(callback)
        if not ok then
            warn("[Speechless] Module error:", name, err)
        end
    end

    return true
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SpeechlessIT"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local function AddCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function AddStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Stroke
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = object
    return stroke
end

local function Create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function Tween(object, duration, properties)
    local info = TweenInfo.new(
        duration or 0.16,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(520, 390),
    Position = UDim2.new(0.5, -260, 0.5, -195),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, Gui)
AddCorner(Main, 10)
AddStroke(Main, Theme.Stroke, 1, 0.15)

local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Main)

local HeaderTitle = Create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -120, 0, 24),
    Position = UDim2.fromOffset(16, 7),
    BackgroundTransparency = 1,
    Text = "Speechless.cc",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local HeaderSub = Create("TextLabel", {
    Name = "Subtitle",
    Size = UDim2.new(1, -120, 0, 16),
    Position = UDim2.fromOffset(17, 29),
    BackgroundTransparency = 1,
    Text = "UNIVERSAL CONTROL PANEL  /  V3",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local Avatar = Create("ImageLabel", {
    Name = "Avatar",
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -82, 0, 9),
    BackgroundColor3 = Theme.Panel3,
    Image = "",
    ScaleType = Enum.ScaleType.Crop,
}, Header)
AddCorner(Avatar, 17)
AddStroke(Avatar, Theme.Stroke, 1, 0.1)

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if ok then
        Avatar.Image = image
    end
end)

local CollapseButton = Create("TextButton", {
    Name = "Collapse",
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -40, 0, 11),
    BackgroundColor3 = Theme.Panel3,
    Text = "−",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    AutoButtonColor = true,
}, Header)
AddCorner(CollapseButton, 7)

local TabBar = Create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, -20, 0, 38),
    Position = UDim2.fromOffset(10, 59),
    BackgroundTransparency = 1,
}, Main)

local TabLayout = Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, TabBar)

local Content = Create("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.fromOffset(10, 105),
    Size = UDim2.new(1, -20, 1, -115),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Muted,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Main)
AddCorner(Content, 8)

local ContentPadding = Create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9),
}, Content)

local ContentLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Content)

local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("GuiObject") and child ~= ContentPadding then
            child:Destroy()
        end
    end
end

local function Section(title)
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 24),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Content)
    return label
end

local function Info(text)
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 28),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Content)
    return label
end

local function ActionButton(text, callback)
    local button = Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 36),
        BackgroundColor3 = Theme.Panel2,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        AutoButtonColor = true,
    }, Content)
    AddCorner(button, 6)
    AddStroke(button, Theme.Stroke, 1, 0.45)
    button.MouseButton1Click:Connect(function()
        if callback then
            callback(button)
        end
    end)
    return button
end

local function ToggleRow(text, initialValue, callback)
    local enabled = initialValue == true

    local row = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 38),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
    }, Content)
    AddCorner(row, 6)

    Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(11, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local switch = Create("TextButton", {
        Size = UDim2.fromOffset(48, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = enabled and Theme.On or Theme.Off,
        Text = enabled and "ON" or "OFF",
        TextColor3 = enabled and Theme.Background or Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        AutoButtonColor = false,
    }, row)
    AddCorner(switch, 6)

    local function refresh()
        switch.Text = enabled and "ON" or "OFF"
        switch.BackgroundColor3 = enabled and Theme.On or Theme.Off
        switch.TextColor3 = enabled and Theme.Background or Theme.Text
    end

    switch.MouseButton1Click:Connect(function()
        enabled = not enabled
        refresh()
        if callback then
            callback(enabled)
        end
    end)

    return {
        Set = function(value)
            enabled = value == true
            refresh()
            if callback then callback(enabled) end
        end,
        Get = function()
            return enabled
        end,
        Button = switch,
    }
end

local function SliderRow(title, minimum, maximum, initial, callback)
    local value = math.clamp(initial, minimum, maximum)

    local holder = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 58),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
    }, Content)
    AddCorner(holder, 6)

    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 24),
        Position = UDim2.fromOffset(10, 3),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local valueLabel = Create("TextLabel", {
        Size = UDim2.fromOffset(55, 24),
        Position = UDim2.new(1, -64, 0, 3),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, holder)

    local bar = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 7),
        Position = UDim2.fromOffset(10, 38),
        BackgroundColor3 = Theme.Off,
        BorderSizePixel = 0,
    }, holder)
    AddCorner(bar, 5)

    local fill = Create("Frame", {
        Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, bar)
    AddCorner(fill, 5)

    local knob = Create("Frame", {
        Size = UDim2.fromOffset(13, 13),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, bar)
    AddCorner(knob, 7)

    local draggingSlider = false

    local function setFromX(x)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
        value = math.floor(minimum + (maximum - minimum) * alpha + 0.5)
        local percent = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    return {
        Get = function() return value end,
        Set = function(newValue)
            value = math.clamp(math.floor(newValue), minimum, maximum)
            local percent = (value - minimum) / (maximum - minimum)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, 0, 0.5, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end,
    }
end

local FOVCircle = Create("Frame", {
    Name = "FOVDisplay",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2),
    BackgroundTransparency = 1,
    Visible = Config.ShowFOV,
    ZIndex = 20,
}, Gui)
AddCorner(FOVCircle, 200)
AddStroke(FOVCircle, Theme.Accent, 1, 0.25)

local function UpdateFOV()
    FOVCircle.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
    FOVCircle.Visible = Config.ShowFOV
end

local ESPObjects = {}

local function RemoveESP(player)
    local data = ESPObjects[player]
    if not data then return end

    for _, object in ipairs(data.Objects or {}) do
        if object and object.Parent then
            object:Destroy()
        end
    end
    ESPObjects[player] = nil
end

local function IsEnemy(player)
    if player == LocalPlayer then
        return false
    end

    if not Config.TeamCheck then
        return true
    end

    if LocalPlayer.Team == nil or player.Team == nil then
        return true
    end

    return player.Team ~= LocalPlayer.Team
end

local function CreateESP(player)
    if not IsEnemy(player) then
        RemoveESP(player)
        return
    end

    local character = player.Character
    if not character then return end

    RemoveESP(player)

    local objects = {}

    if Config.PlayerHighlight or Config.ModelGlow or Config.Outline then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SpeechlessHighlight"
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(210, 210, 220)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = Config.ModelGlow and 0.65 or 1
        highlight.OutlineTransparency = Config.Outline and 0 or 1
        highlight.Parent = Gui
        table.insert(objects, highlight)
    end

    if Config.NameTags or Config.Distance then
        local head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "SpeechlessTag"
            billboard.Adornee = head
            billboard.Size = UDim2.fromOffset(160, 34)
            billboard.StudsOffset = Vector3.new(0, 2.2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = Gui

            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.Text
            label.TextStrokeTransparency = 0.25
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.Parent = billboard

            local distanceText = ""
            if Config.Distance and LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    local distance = (root.Position
                        - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    distanceText = string.format("  [%d studs]", math.floor(distance))
                end
            end

            label.Text = (Config.NameTags and player.DisplayName or "") .. distanceText
            table.insert(objects, billboard)
        end
    end

    ESPObjects[player] = {Objects = objects}
end

local function RefreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end

local function ClearESP()
    for player in pairs(ESPObjects) do
        RemoveESP(player)
    end
end

RegisterModule("ESP", RefreshESP, ClearESP)

local TracerLayer = Create("Frame", {
    Name = "TracerLayer",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 15,
}, Gui)

local TracerLines = {}

local function ClearTracers()
    for _, line in ipairs(TracerLines) do
        if line and line.Parent then line:Destroy() end
    end
    table.clear(TracerLines)
end

local function UpdateTracers()
    ClearTracers()
    if not Config.Tracers then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screen, visible = camera:WorldToViewportPoint(root.Position)
                if visible then
                    local line = Create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromOffset(
                            camera.ViewportSize.X / 2,
                            camera.ViewportSize.Y - 8
                        ),
                        Size = UDim2.fromOffset(
                            (Vector2.new(screen.X, screen.Y)
                                - Vector2.new(camera.ViewportSize.X / 2,
                                    camera.ViewportSize.Y - 8)).Magnitude,
                            1
                        ),
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        ZIndex = 15,
                    }, TracerLayer)

                    local delta = Vector2.new(screen.X, screen.Y)
                        - Vector2.new(camera.ViewportSize.X / 2,
                            camera.ViewportSize.Y - 8)
                    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    table.insert(TracerLines, line)
                end
            end
        end
    end
end

local HitboxPreviewObjects = {}

local function ClearHitboxPreview()
    for _, object in ipairs(HitboxPreviewObjects) do
        if object and object.Parent then object:Destroy() end
    end
    table.clear(HitboxPreviewObjects)
end

local function RefreshHitboxPreview()
    ClearHitboxPreview()
    if not Config.HitboxPreview then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local part = player.Character:FindFirstChild(Config.HitboxPart)
            if part and part:IsA("BasePart") then
                local box = Instance.new("SelectionBox")
                box.Name = "SpeechlessHitboxPreview"
                box.Adornee = part
                box.Color3 = Theme.Accent
                box.LineThickness = 0.035
                box.SurfaceTransparency = 0.92
                box.Parent = Gui
                table.insert(HitboxPreviewObjects, box)
            end
        end
    end
end

local originalMovement = {
    WalkSpeed = 16,
    JumpPower = 50,
}

local function GetHumanoid()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function ApplyMovement()
    local humanoid = GetHumanoid()
    if not humanoid then return end

    if Config.MovementEnabled then
        humanoid.WalkSpeed = Config.WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Config.JumpPower
    else
        humanoid.WalkSpeed = originalMovement.WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = originalMovement.JumpPower
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        originalMovement.WalkSpeed = humanoid.WalkSpeed
        originalMovement.JumpPower = humanoid.JumpPower
        task.wait(0.2)
        ApplyMovement()
    end
end)

local currentFPS = 0
local frameCounter = 0
local fpsStart = os.clock()

local function ReadPing()
    local ok, value = pcall(function()
        local network = Stats:FindFirstChild("Network")
        if not network then return nil end
        local serverStats = network:FindFirstChild("ServerStatsItem")
        if not serverStats then return nil end
        local ping = serverStats:FindFirstChild("Data Ping")
        if not ping then return nil end
        return ping:GetValueString()
    end)

    if ok and value then
        return tostring(value)
    end
    return "N/A"
end

local TabButtons = {}
local CurrentTab = nil

local function SetActiveTab(name)
    CurrentTab = name
    for tabName, button in pairs(TabButtons) do
        button.BackgroundColor3 = tabName == name and Theme.Accent or Theme.Panel2
        button.TextColor3 = tabName == name and Theme.Background or Theme.Text
    end
end

local function BuildMain()
    Section("Aim display / practice settings")
    Info("Practice settings only. No automatic player targeting is performed.")

    ToggleRow("Aim Assist setting (display only)", Config.AimAssist, function(value)
        Config.AimAssist = value
    end)

    SliderRow("FOV Radius", 40, 300, Config.FOVRadius, function(value)
        Config.FOVRadius = value
        UpdateFOV()
    end)

    SliderRow("Smoothness value", 1, 100, math.floor(Config.Smoothness * 100), function(value)
        Config.Smoothness = value / 100
    end)

    ToggleRow("Team Check", Config.TeamCheck, function(value)
        Config.TeamCheck = value
        RefreshESP()
        RefreshHitboxPreview()
    end)

    ToggleRow("Show FOV Circle", Config.ShowFOV, function(value)
        Config.ShowFOV = value
        UpdateFOV()
    end)

    Section("Visual hitbox test")
    ToggleRow("Hitbox Preview (visual only)", Config.HitboxPreview, function(value)
        Config.HitboxPreview = value
        RefreshHitboxPreview()
    end)

    ActionButton("Preview Head", function()
        Config.HitboxPart = "Head"
        RefreshHitboxPreview()
    end)

    ActionButton("Preview HumanoidRootPart", function()
        Config.HitboxPart = "HumanoidRootPart"
        RefreshHitboxPreview()
    end)
end

local function BuildVisual()
    Section("Player visuals")
    Info("ESP tools are intended for testing in your own Roblox experience.")

    ToggleRow("Player Highlight", Config.PlayerHighlight, function(value)
        Config.PlayerHighlight = value
        RefreshESP()
    end)

    ToggleRow("Model Glow", Config.ModelGlow, function(value)
        Config.ModelGlow = value
        RefreshESP()
    end)

    ToggleRow("Outline", Config.Outline, function(value)
        Config.Outline = value
        RefreshESP()
    end)

    ToggleRow("Name Tags", Config.NameTags, function(value)
        Config.NameTags = value
        RefreshESP()
    end)

    ToggleRow("Distance", Config.Distance, function(value)
        Config.Distance = value
        RefreshESP()
    end)

    ToggleRow("Tracers", Config.Tracers, function(value)
        Config.Tracers = value
        if not value then ClearTracers() end
    end)

    ToggleRow("Visible Only (reserved)", Config.VisibleOnly, function(value)
        Config.VisibleOnly = value
    end)

    ActionButton("Refresh Visuals", function()
        RefreshESP()
        RefreshHitboxPreview()
        UpdateTracers()
    end)

    ActionButton("Clear All Visuals", function()
        ClearESP()
        ClearHitboxPreview()
        ClearTracers()
    end)
end

local function BuildMove()
    Section("Movement - own test place")
    Info("Changes are local test controls. A server may override character movement.")

    SliderRow("WalkSpeed", 8, 40, Config.WalkSpeed, function(value)
        Config.WalkSpeed = value
        if Config.MovementEnabled then ApplyMovement() end
    end)

    SliderRow("JumpPower", 20, 100, Config.JumpPower, function(value)
        Config.JumpPower = value
        if Config.MovementEnabled then ApplyMovement() end
    end)

    ToggleRow("Enable Movement Settings", Config.MovementEnabled, function(value)
        Config.MovementEnabled = value
        ApplyMovement()
    end)

    ActionButton("Reset Movement", function()
        Config.WalkSpeed = originalMovement.WalkSpeed
        Config.JumpPower = originalMovement.JumpPower
        Config.MovementEnabled = false
        ApplyMovement()
        Info("Movement reset to the character's original values.")
    end)
end

local function BuildMisc()
    Section("Miscellaneous")
    Info("Anti-AFK evasion is not included. Use normal game controls and follow the experience rules.")

    ActionButton("Anti-AFK Information", function(button)
        button.Text = "Idle status is controlled by Roblox"
        task.delay(2, function()
            if button and button.Parent then
                button.Text = "Anti-AFK Information"
            end
        end)
    end)

    ActionButton("Rejoin Current Server", function(button)
        button.Text = "Rejoining..."
        local ok, err = pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        if not ok then
            button.Text = "Rejoin failed"
            warn("[Speechless] Rejoin failed:", err)
        end
    end)

    ActionButton("Reset Character", function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = 0
        end
    end)

    ActionButton("Close Interface", function()
        Gui:Destroy()
    end)
end

local function BuildUniversal()
    Section("Universal information")
    local gameId = Info("GAME ID: " .. tostring(game.PlaceId))
    local placeId = Info("PLACE ID: " .. tostring(game.PlaceId))
    local fpsLabel = Info("FPS: calculating...")
    local pingLabel = Info("PING: reading...")
    local playerLabel = Info("PLAYERS: " .. tostring(#Players:GetPlayers()))

    ToggleRow("Show FPS", Config.FPSVisible, function(value)
        Config.FPSVisible = value
        fpsLabel.Visible = value
    end)

    ToggleRow("Show Ping", Config.PingVisible, function(value)
        Config.PingVisible = value
        pingLabel.Visible = value
    end)

    ActionButton("Refresh Information", function()
        gameId.Text = "GAME ID: " .. tostring(game.PlaceId)
        placeId.Text = "PLACE ID: " .. tostring(game.PlaceId)
        playerLabel.Text = "PLAYERS: " .. tostring(#Players:GetPlayers())
        pingLabel.Text = "PING: " .. ReadPing()
        fpsLabel.Text = "FPS: " .. tostring(currentFPS)
    end)

    ActionButton("Copy Game ID", function(button)
        button.Text = "Game ID: " .. tostring(game.PlaceId)
        task.delay(2, function()
            if button and button.Parent then
                button.Text = "Copy Game ID"
            end
        end)
    end)
end

local TabBuilders = {
    Main = BuildMain,
    Visual = BuildVisual,
    Move = BuildMove,
    Misc = BuildMisc,
    Universal = BuildUniversal,
}

local function ShowTab(name)
    local builder = TabBuilders[name]
    if not builder then return end

    ClearContent()
    SetActiveTab(name)
    builder()
    Content.CanvasPosition = Vector2.new(0, 0)
end

local function CreateTab(name, order)
    local button = Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(0, 94, 0, 32),
        BackgroundColor3 = Theme.Panel2,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        LayoutOrder = order,
        AutoButtonColor = true,
    }, TabBar)
    AddCorner(button, 6)

    TabButtons[name] = button
    button.MouseButton1Click:Connect(function()
        ShowTab(name)
    end)
end

CreateTab("Main", 1)
CreateTab("Visual", 2)
CreateTab("Move", 3)
CreateTab("Misc", 4)
CreateTab("Universal", 5)

local minimized = false
CollapseButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    TabBar.Visible = not minimized
    Content.Visible = not minimized

    Tween(Main, 0.18, {
        Size = minimized and UDim2.fromOffset(520, 52)
            or UDim2.fromOffset(520, 390)
    })

    CollapseButton.Text = minimized and "+" or "−"
end)

local dragging = false
local dragInput
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Config.PlayerHighlight or Config.ModelGlow or Config.Outline
            or Config.NameTags or Config.Distance then
            CreateESP(player)
        end
        if Config.HitboxPreview then
            RefreshHitboxPreview()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.PlayerHighlight or Config.ModelGlow or Config.Outline
                or Config.NameTags or Config.Distance then
                CreateESP(player)
            end
            if Config.HitboxPreview then
                RefreshHitboxPreview()
            end
        end)
    end
end

local updateAccumulator = 0

RunService.RenderStepped:Connect(function(deltaTime)
    frameCounter += 1
    if os.clock() - fpsStart >= 1 then
        currentFPS = frameCounter
        frameCounter = 0
        fpsStart = os.clock()
    end

    updateAccumulator += deltaTime
    if updateAccumulator >= 0.25 then
        updateAccumulator = 0

        if Config.Tracers then
            UpdateTracers()
        end

        if Config.Distance and (Config.NameTags or Config.Distance) then
            RefreshESP()
        end
    end
end)

ShowTab("Main")
UpdateFOV()

print("[Speechless.cc] Universal V3 loaded successfully.")
