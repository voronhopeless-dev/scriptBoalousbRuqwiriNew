local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Stats             = game:GetService("Stats")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("SpeechlessIT")
if oldGui then oldGui:Destroy() end

local DISCORD_URL = "https://discord.gg/nvjhsNpDA"

local Theme = {
    Background = Color3.fromRGB(8, 8, 10),
    Panel      = Color3.fromRGB(15, 15, 18),
    Panel2     = Color3.fromRGB(23, 23, 27),
    Panel3     = Color3.fromRGB(31, 31, 36),
    Text       = Color3.fromRGB(245, 245, 247),
    Muted      = Color3.fromRGB(145, 145, 153),
    Accent     = Color3.fromRGB(225, 225, 230),
    On         = Color3.fromRGB(235, 235, 240),
    Off        = Color3.fromRGB(48, 48, 54),
    Stroke     = Color3.fromRGB(55, 55, 62),
}

local Config = {
    TeamCheck = true, PlayerHighlight = false, ModelGlow = false,
    Outline = true, NameTags = false, Distance = false,
    Tracers = false,
    ShowFOV = true, FOVRadius = 120,
    AimAssist = false, Smoothness = 0.25,
    TargetPart = "HumanoidRootPart",
    AimHoldKey = Enum.KeyCode.Q,
    HitboxPreview = false, HitboxPart = "Head",
    WalkSpeed = 16, JumpPower = 50, MovementEnabled = false,
    FPSVisible = true, PingVisible = true, AntiAFK = false,
    TPToolEnabled = false,
}

local function Create(className, properties, parent)
    local obj = Instance.new(className)
    for k, v in pairs(properties or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function AddCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function AddStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function Tween(obj, duration, props)
    local info = TweenInfo.new(duration or 0.16,
        Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function GetHumanoid()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChildOfClass("Humanoid") or nil
end

local function GetRoot()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart") or nil
end

local function CopyToClipboard(text)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, text)
        if ok then return true end
    end
    if type(toClipboard) == "function" then
        local ok = pcall(toClipboard, text)
        if ok then return true end
    end
    return false
end

local Gui = Create("ScreenGui", {
    Name = "SpeechlessIT", ResetOnSpawn = false,
    IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(540, 420),
    Position = UDim2.new(0.5, -270, 0.5, -210),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0, ClipsDescendants = true,
}, Gui)
AddCorner(Main, 10)
AddStroke(Main, Theme.Stroke, 1, 0.15)

local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Main)

Create("TextLabel", {
    Size = UDim2.new(1, -140, 0, 22), Position = UDim2.fromOffset(16, 8),
    BackgroundTransparency = 1, Text = "Speechless.cc",
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold,
    TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

Create("TextLabel", {
    Size = UDim2.new(1, -140, 0, 16), Position = UDim2.fromOffset(17, 30),
    BackgroundTransparency = 1, Text = "UNIVERSAL SCRIPT",
    TextColor3 = Theme.Muted, Font = Enum.Font.Gotham,
    TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local Avatar = Create("ImageLabel", {
    Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -94, 0, 9),
    BackgroundColor3 = Theme.Panel3, Image = "",
    ScaleType = Enum.ScaleType.Crop,
}, Header)
AddCorner(Avatar, 18)
AddStroke(Avatar, Theme.Stroke, 1, 0.1)

task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok then Avatar.Image = img end
end)

local CollapseButton = Create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -42, 0, 12),
    BackgroundColor3 = Theme.Panel3, Text = "−",
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold,
    TextSize = 20, AutoButtonColor = true,
}, Header)
AddCorner(CollapseButton, 7)

local TabBar = Create("Frame", {
    Size = UDim2.new(1, -20, 0, 38),
    Position = UDim2.fromOffset(10, 61),
    BackgroundTransparency = 1,
}, Main)

Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
}, TabBar)

local Content = Create("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.fromOffset(10, 107),
    Size = UDim2.new(1, -20, 1, -117),
    BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Muted,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, Main)
AddCorner(Content, 8)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
}, Content)

Create("UIListLayout", {
    Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
}, Content)

do
    local touchStart, scrollStart
    Content.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = input.Position
            scrollStart = Content.CanvasPosition
        end
    end)
    Content.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and touchStart then
            local delta = touchStart - input.Position
            Content.CanvasPosition = Vector2.new(
                0, math.max(0, scrollStart.Y + delta.Y))
        end
    end)
    Content.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = nil
        end
    end)
end

local function ClearContent()
    for _, c in ipairs(Content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

local function Section(text)
    return Create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 24), BackgroundTransparency = 1,
        Text = string.upper(text), TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Content)
end

local function Info(text)
    return Create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 28), BackgroundTransparency = 1,
        Text = text, TextColor3 = Theme.Text, Font = Enum.Font.Gotham,
        TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Content)
end

local function ActionButton(text, callback)
    local b = Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 36),
        BackgroundColor3 = Theme.Panel2, Text = text,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium,
        TextSize = 12, AutoButtonColor = true,
    }, Content)
    AddCorner(b, 6)
    AddStroke(b, Theme.Stroke, 1, 0.45)
    b.MouseButton1Click:Connect(function() if callback then callback(b) end end)
    return b
end

local function ToggleRow(text, initial, callback)
    local enabled = initial == true
    local row = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 38),
        BackgroundColor3 = Theme.Panel2, BorderSizePixel = 0,
    }, Content)
    AddCorner(row, 6)

    Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(11, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local sw = Create("TextButton", {
        Size = UDim2.fromOffset(48, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = enabled and Theme.On or Theme.Off,
        Text = enabled and "ON" or "OFF",
        TextColor3 = enabled and Theme.Background or Theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false,
    }, row)
    AddCorner(sw, 6)

    local function refresh()
        sw.Text = enabled and "ON" or "OFF"
        sw.BackgroundColor3 = enabled and Theme.On or Theme.Off
        sw.TextColor3 = enabled and Theme.Background or Theme.Text
    end

    sw.MouseButton1Click:Connect(function()
        enabled = not enabled; refresh()
        if callback then callback(enabled) end
    end)

    return {
        Set = function(v) enabled = v == true; refresh(); if callback then callback(enabled) end end,
        Get = function() return enabled end,
        Button = sw,
    }
end

local function SliderRow(title, minimum, maximum, initial, callback)
    local value = math.clamp(initial, minimum, maximum)
    local holder = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 58),
        BackgroundColor3 = Theme.Panel2, BorderSizePixel = 0,
    }, Content)
    AddCorner(holder, 6)

    Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 24), Position = UDim2.fromOffset(10, 3),
        BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local valueLabel = Create("TextLabel", {
        Size = UDim2.fromOffset(55, 24), Position = UDim2.new(1, -64, 0, 3),
        BackgroundTransparency = 1, Text = tostring(value),
        TextColor3 = Theme.Muted, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, holder)

    local bar = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 7), Position = UDim2.fromOffset(10, 38),
        BackgroundColor3 = Theme.Off, BorderSizePixel = 0,
    }, holder)
    AddCorner(bar, 5)

    local fill = Create("Frame", {
        Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    }, bar)
    AddCorner(fill, 5)

    local knob = Create("Frame", {
        Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
        BackgroundColor3 = Theme.Text, BorderSizePixel = 0,
    }, bar)
    AddCorner(knob, 7)

    local dragging = false
    local function setFromX(x)
        local w = math.max(bar.AbsoluteSize.X, 1)
        local a = math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1)
        value = math.floor(minimum + (maximum - minimum) * a + 0.5)
        local p = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Get = function() return value end,
        Set = function(nv)
            value = math.clamp(math.floor(nv), minimum, maximum)
            local p = (value - minimum) / (maximum - minimum)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end,
    }
end

local FOVCircle = Create("Frame", {
    Name = "FOVDisplay", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2),
    BackgroundTransparency = 1, Visible = Config.ShowFOV, ZIndex = 20,
}, Gui)
AddCorner(FOVCircle, 200)
AddStroke(FOVCircle, Theme.Accent, 1, 0.25)

local function UpdateFOV()
    FOVCircle.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
    FOVCircle.Visible = Config.ShowFOV and Config.AimAssist
end

local ESPObjects = {}

local function RemoveESP(player)
    local d = ESPObjects[player]
    if not d then return end
    for _, o in ipairs(d.Objects or {}) do
        if o and o.Parent then o:Destroy() end
    end
    ESPObjects[player] = nil
end

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not Config.TeamCheck then return true end
    if LocalPlayer.Team == nil or player.Team == nil then return true end
    return player.Team ~= LocalPlayer.Team
end

local function CreateESP(player)
    if not IsEnemy(player) then RemoveESP(player); return end
    local character = player.Character
    if not character then return end
    RemoveESP(player)
    local objects = {}

    if Config.PlayerHighlight or Config.ModelGlow or Config.Outline then
        local h = Instance.new("Highlight")
        h.Name = "SpeechlessHighlight"
        h.Adornee = character
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillColor = Color3.fromRGB(210, 210, 220)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = Config.ModelGlow and 0.65 or 1
        h.OutlineTransparency = Config.Outline and 0 or 1
        h.Parent = Gui
        table.insert(objects, h)
    end

    if Config.NameTags or Config.Distance then
        local head = character:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui")
            bb.Name = "SpeechlessTag"
            bb.Adornee = head
            bb.Size = UDim2.fromOffset(160, 34)
            bb.StudsOffset = Vector3.new(0, 2.2, 0)
            bb.AlwaysOnTop = true
            bb.Parent = Gui

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.fromScale(1, 1)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Theme.Text
            lbl.TextStrokeTransparency = 0.25
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Parent = bb

            local dtext = ""
            if Config.Distance and GetRoot() then
                local r = character:FindFirstChild("HumanoidRootPart")
                if r then
                    dtext = string.format("  [%d studs]",
                        math.floor((r.Position - GetRoot().Position).Magnitude))
                end
            end
            lbl.Text = (Config.NameTags and player.DisplayName or "") .. dtext
            table.insert(objects, bb)
        end
    end

    ESPObjects[player] = {Objects = objects}
end

local function RefreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then CreateESP(p) end
    end
end

local function ClearESP()
    for p in pairs(ESPObjects) do RemoveESP(p) end
end

local TracerLayer = Create("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 15,
}, Gui)

local TracerLines = {}

local function ClearTracers()
    for _, l in ipairs(TracerLines) do
        if l and l.Parent then l:Destroy() end
    end
    table.clear(TracerLines)
end

local function UpdateTracers()
    ClearTracers()
    if not Config.Tracers then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local cx = cam.ViewportSize.X / 2
    local cy = cam.ViewportSize.Y - 8
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local sp, vis = cam:WorldToViewportPoint(root.Position)
                if vis then
                    local delta = Vector2.new(sp.X - cx, sp.Y - cy)
                    local line = Create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromOffset(cx, cy),
                        Size = UDim2.fromOffset(delta.Magnitude, 1),
                        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
                        ZIndex = 15,
                    }, TracerLayer)
                    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    table.insert(TracerLines, line)
                end
            end
        end
    end
end

local HitboxPreviewObjects = {}

local function ClearHitboxPreview()
    for _, o in ipairs(HitboxPreviewObjects) do
        if o and o.Parent then o:Destroy() end
    end
    table.clear(HitboxPreviewObjects)
end

local function RefreshHitboxPreview()
    ClearHitboxPreview()
    if not Config.HitboxPreview then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character then
            local part = p.Character:FindFirstChild(Config.HitboxPart)
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

local function FindAimTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, Config.FOVRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character then
            local part = p.Character:FindFirstChild(Config.TargetPart)
            if part and part:IsA("BasePart") then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = part
                    end
                end
            end
        end
    end
    return best
end

local aimConnection
local function StartAimAssist()
    if aimConnection then return end
    aimConnection = RunService.RenderStepped:Connect(function()
        if not Config.AimAssist then return end
        local held = UserInputService:IsKeyDown(Config.AimHoldKey)
            or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if not held then return end
        local cam = workspace.CurrentCamera
        local target = FindAimTarget()
        if not cam or not target then return end
        local currentCF = cam.CFrame
        local desired = CFrame.new(currentCF.Position, target.Position)
        local alpha = 1 - math.clamp(Config.Smoothness, 0.01, 0.99)
        cam.CFrame = currentCF:Lerp(desired, alpha)
    end)
end

local function StopAimAssist()
    if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
end

local originalMovement = {WalkSpeed = 16, JumpPower = 50}

local function ApplyMovement()
    local hum = GetHumanoid()
    if not hum then return end
    if Config.MovementEnabled then
        hum.WalkSpeed = Config.WalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = Config.JumpPower
    else
        hum.WalkSpeed = originalMovement.WalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = originalMovement.JumpPower
    end
end

local function GiveTPTool()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local old = backpack:FindFirstChild("SpeechlessTP")
    if old then old:Destroy() end
    local tool = Instance.new("Tool")
    tool.Name = "SpeechlessTP"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ToolTip = "Click ground to teleport"
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local hit = mouse.Hit
        if not hit then return end
        local root = GetRoot()
        if root then
            root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
        end
    end)
    tool.Parent = backpack
end

local function RemoveTPTool()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local t = backpack:FindFirstChild("SpeechlessTP")
        if t then t:Destroy() end
    end
    local char = LocalPlayer.Character
    if char then
        local t = char:FindFirstChild("SpeechlessTP")
        if t then t:Destroy() end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        originalMovement.WalkSpeed = hum.WalkSpeed
        originalMovement.JumpPower = hum.JumpPower
        task.wait(0.2)
        ApplyMovement()
        if Config.TPToolEnabled then GiveTPTool() end
    end
end)

local currentFPS, frameCounter, fpsStart = 0, 0, os.clock()

local function ReadPing()
    local ok, v = pcall(function()
        local n = Stats:FindFirstChild("Network")
        if not n then return nil end
        local s = n:FindFirstChild("ServerStatsItem")
        if not s then return nil end
        local p = s:FindFirstChild("Data Ping")
        if not p then return nil end
        return p:GetValueString()
    end)
    return (ok and v) and tostring(v) or "N/A"
end

local antiAfkConn
local function StartAntiAFK()
    if antiAfkConn then return end
    antiAfkConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
local function StopAntiAFK()
    if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
end

local function TeleportToPlayer(target)
    if not target or target == LocalPlayer then return end
    local char = target.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myRoot = GetRoot()
    if root and myRoot then
        myRoot.CFrame = root.CFrame * CFrame.new(0, 0, 3)
    end
end

local TabButtons = {}
local TabBuilders = {}

local function SetActiveTab(name)
    for n, b in pairs(TabButtons) do
        b.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Panel2
        b.TextColor3 = (n == name) and Theme.Background or Theme.Text
    end
end

local function ShowTab(name)
    local builder = TabBuilders[name]
    if not builder then return end
    ClearContent()
    SetActiveTab(name)
    builder()
    Content.CanvasPosition = Vector2.new(0, 0)
end

local function CreateTab(name, order)
    local b = Create("TextButton", {
        Name = name .. "Tab", Size = UDim2.new(0, 80, 0, 32),
        BackgroundColor3 = Theme.Panel2, Text = name,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold,
        TextSize = 11, LayoutOrder = order, AutoButtonColor = true,
    }, TabBar)
    AddCorner(b, 6)
    TabButtons[name] = b
    b.MouseButton1Click:Connect(function() ShowTab(name) end)
end

TabBuilders.Main = function()
    Section("Aim settings")
    Info("Aim Assist moves only your camera. No auto-attack, no remotes.")

    ToggleRow("Aim Assist", Config.AimAssist, function(v)
        Config.AimAssist = v
        if v then StartAimAssist() else StopAimAssist() end
        UpdateFOV()
    end)

    SliderRow("FOV Radius", 40, 400, Config.FOVRadius, function(v)
        Config.FOVRadius = v; UpdateFOV()
    end)

    SliderRow("Smoothness x100", 1, 99, math.floor(Config.Smoothness * 100), function(v)
        Config.Smoothness = v / 100
    end)

    ToggleRow("Show FOV", Config.ShowFOV, function(v)
        Config.ShowFOV = v; UpdateFOV()
    end)

    Info("Hold Q or RMB to aim.")

    Section("Hitbox preview")
    ToggleRow("Hitbox Preview", Config.HitboxPreview, function(v)
        Config.HitboxPreview = v; RefreshHitboxPreview()
    end)
    ActionButton("Part: Head", function()
        Config.HitboxPart = "Head"; RefreshHitboxPreview()
    end)
    ActionButton("Part: HumanoidRootPart", function()
        Config.HitboxPart = "HumanoidRootPart"; RefreshHitboxPreview()
    end)
end

TabBuilders.Visual = function()
    Section("ESP")
    ToggleRow("Player Highlight", Config.PlayerHighlight, function(v)
        Config.PlayerHighlight = v; RefreshESP()
    end)
    ToggleRow("Model Glow", Config.ModelGlow, function(v)
        Config.ModelGlow = v; RefreshESP()
    end)
    ToggleRow("Outline", Config.Outline, function(v)
        Config.Outline = v; RefreshESP()
    end)
    ToggleRow("Name Tags", Config.NameTags, function(v)
        Config.NameTags = v; RefreshESP()
    end)
    ToggleRow("Distance", Config.Distance, function(v)
        Config.Distance = v; RefreshESP()
    end)
    ToggleRow("Tracers", Config.Tracers, function(v)
        Config.Tracers = v; if not v then ClearTracers() end
    end)
    ToggleRow("Team Check", Config.TeamCheck, function(v)
        Config.TeamCheck = v; RefreshESP(); RefreshHitboxPreview()
    end)

    ActionButton("Refresh", function()
        RefreshESP(); RefreshHitboxPreview(); UpdateTracers()
    end)
    ActionButton("Clear All", function()
        ClearESP(); ClearHitboxPreview(); ClearTracers()
    end)
end

TabBuilders.Move = function()
    Section("Movement")
    SliderRow("WalkSpeed", 8, 100, Config.WalkSpeed, function(v)
        Config.WalkSpeed = v; if Config.MovementEnabled then ApplyMovement() end
    end)
    SliderRow("JumpPower", 20, 200, Config.JumpPower, function(v)
        Config.JumpPower = v; if Config.MovementEnabled then ApplyMovement() end
    end)
    ToggleRow("Enable Movement", Config.MovementEnabled, function(v)
        Config.MovementEnabled = v; ApplyMovement()
    end)
    ActionButton("Reset", function()
        Config.WalkSpeed = originalMovement.WalkSpeed
        Config.JumpPower = originalMovement.JumpPower
        Config.MovementEnabled = false
        ApplyMovement()
    end)
end

TabBuilders.Players = function()
    Section("Players list")
    Info("Click a player to teleport.")

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = ActionButton(p.DisplayName .. "  @" .. p.Name, function()
                TeleportToPlayer(p)
            end)
            btn.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    if #Players:GetPlayers() <= 1 then
        Info("No other players in this server.")
    end
end

TabBuilders.Misc = function()
    Section("Tools")
    ToggleRow("TP Tool (backpack)", Config.TPToolEnabled, function(v)
        Config.TPToolEnabled = v
        if v then GiveTPTool() else RemoveTPTool() end
    end)

    Section("Anti-AFK")
    Info("Uses standard VirtualUser idle reset.")
    ToggleRow("Anti-AFK", Config.AntiAFK, function(v)
        Config.AntiAFK = v
        if v then StartAntiAFK() else StopAntiAFK() end
    end)

    Section("Server")
    ActionButton("Rejoin Server", function(b)
        b.Text = "Rejoining..."
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)
    ActionButton("Reset Character", function()
        local h = GetHumanoid()
        if h then h.Health = 0 end
    end)
    ActionButton("Close Menu", function()
        Gui:Destroy()
    end)
end

TabBuilders.Links = function()
    Section("Speechless.cc")
    Info("Click to copy the link, then paste it in your browser.")

    ActionButton("Discord — Copy Link", function(b)
        local ok = CopyToClipboard(DISCORD_URL)
        b.Text = ok and "Copied to clipboard!" or "Copy failed"
        task.delay(2, function()
            if b and b.Parent then
                b.Text = "Discord — Copy Link"
            end
        end)
    end)

    local tb = Create("TextBox", {
        Size = UDim2.new(1, -4, 0, 32),
        BackgroundColor3 = Theme.Panel2,
        Text = DISCORD_URL,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 12,
        ClearTextOnFocus = false,
        TextEditable = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Content)
    AddCorner(tb, 6)
    AddStroke(tb, Theme.Stroke, 1, 0.45)

    Section("How to open")
    Info("1. Tap 'Discord — Copy Link'.")
    Info("2. Open your browser.")
    Info("3. Paste the link and press Enter.")
    Info("Roblox does not allow direct link opening from in-game GUI.")

    Section("GitHub")
    ActionButton("GitHub Repo — Copy", function(b)
        local url = "https://github.com/voronhopeless-dev/scriptBoalousbRuqwiriNew"
        local ok = CopyToClipboard(url)
        b.Text = ok and "Copied to clipboard!" or "Copy failed"
        task.delay(2, function()
            if b and b.Parent then
                b.Text = "GitHub Repo — Copy"
            end
        end)
    end)
end

TabBuilders.Uni = function()
    Section("Info")
    local fpsLabel  = Info("FPS: ...")
    local pingLabel = Info("PING: ...")
    local placeLbl  = Info("PLACE ID: " .. tostring(game.PlaceId))
    local jobLbl    = Info("JOB ID: " .. tostring(game.JobId))
    local playersLbl= Info("PLAYERS: " .. tostring(#Players:GetPlayers()))

    ToggleRow("Show FPS", Config.FPSVisible, function(v)
        Config.FPSVisible = v; fpsLabel.Visible = v
    end)
    ToggleRow("Show Ping", Config.PingVisible, function(v)
        Config.PingVisible = v; pingLabel.Visible = v
    end)

    ActionButton("Refresh Info", function()
        fpsLabel.Text  = "FPS: " .. tostring(currentFPS)
        pingLabel.Text = "PING: " .. ReadPing()
        placeLbl.Text  = "PLACE ID: " .. tostring(game.PlaceId)
        jobLbl.Text    = "JOB ID: " .. tostring(game.JobId)
        playersLbl.Text= "PLAYERS: " .. tostring(#Players:GetPlayers())
    end)
end

CreateTab("Main", 1)
CreateTab("Visual", 2)
CreateTab("Move", 3)
CreateTab("Players", 4)
CreateTab("Misc", 5)
CreateTab("Links", 6)
CreateTab("Uni", 7)

local minimized = false
CollapseButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    TabBar.Visible = not minimized
    Content.Visible = not minimized
    Tween(Main, 0.18, {
        Size = minimized and UDim2.fromOffset(540, 54)
            or UDim2.fromOffset(540, 420)
    })
    CollapseButton.Text = minimized and "+" or "−"
end)

local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil

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

print("[Speechless.cc] Universal Script loaded successfully.")
