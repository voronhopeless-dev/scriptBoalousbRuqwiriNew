local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local MenuKey = Enum.KeyCode.Insert
local ShowHUD = false
local HideNames = false
local FPSBoost = false
local WaitingForKey = false

local FPS = 0
local Ping = "N/A"
local OriginalNames = {}

local GUI = Instance.new("ScreenGui")
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999
GUI.Parent = PlayerGui

local function Create(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function Corner(obj)
    Create("UICorner", {
        CornerRadius = UDim.new(0, 3)
    }, obj)
end

local function Drag(frame, handle)
    local dragging = false
    local dragStart
    local startPos
    local activeInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeInput = input
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input == activeInput then
            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input == activeInput then
            dragging = false
            activeInput = nil
        end
    end)
end

local function Switch(parent, label, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1
    }, parent)

    Create("TextLabel", {
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local toggle = Create("TextButton", {
        Size = UDim2.fromOffset(34, 17),
        Position = UDim2.new(1, -34, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Text = "",
        AutoButtonColor = false
    }, row)

    Create("UIStroke", {
        Color = Color3.fromRGB(180, 180, 180),
        Thickness = 1
    }, toggle)

    Corner(toggle)

    local knob = Create("Frame", {
        Size = UDim2.fromOffset(11, 11),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, toggle)

    Corner(knob)

    local enabled = false

    local function Update()
        knob.Position = enabled
            and UDim2.new(1, -14, 0, 3)
            or UDim2.fromOffset(3, 3)

        callback(enabled)
    end

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        Update()
    end)

    return function(value)
        enabled = value
        Update()
    end
end

local Main = Create("Frame", {
    Size = UDim2.fromOffset(205, 145),
    Position = UDim2.new(0.5, -102, 0.5, -72),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0
}, GUI)

Create("UIStroke", {
    Color = Color3.fromRGB(75, 75, 75),
    Thickness = 1
}, Main)

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1
}, Main)

Create("TextButton", {
    Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -45, 0, 1),
    BackgroundTransparency = 1,
    Text = "−",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.Gotham
}, Header).MouseButton1Click:Connect(function()
    Main.Visible = false
end)

Create("TextButton", {
    Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -23, 0, 1),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    Font = Enum.Font.Gotham
}, Header).MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

Drag(Main, Header)

local TabBar = Create("Frame", {
    Position = UDim2.fromOffset(0, 27),
    Size = UDim2.new(1, 0, 0, 23),
    BackgroundTransparency = 1
}, Main)

local Content = Create("Frame", {
    Position = UDim2.fromOffset(8, 55),
    Size = UDim2.new(1, -16, 1, -60),
    BackgroundTransparency = 1
}, Main)

local Pages = {}

local function MakeTab(name, position)
    local button = Create("TextButton", {
        Position = UDim2.new(position, 0, 0, 0),
        Size = UDim2.new(1/3, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(120, 120, 120),
        TextSize = 10,
        Font = Enum.Font.Gotham
    }, TabBar)

    local page = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    }, Content)

    Pages[name] = {
        button = button,
        page = page
    }

    button.MouseButton1Click:Connect(function()
        for tab, data in pairs(Pages) do
            data.page.Visible = tab == name

            data.button.TextColor3 = tab == name
                and Color3.new(1, 1, 1)
                or Color3.fromRGB(120, 120, 120)
        end
    end)

    return page
end

local Home = MakeTab("HOME", 0)
local Visual = MakeTab("VISUAL", 1/3)
local Misc = MakeTab("MISC", 2/3)

Home.Visible = true
Pages.HOME.button.TextColor3 = Color3.new(1, 1, 1)

local HUD = Create("Frame", {
    Size = UDim2.fromOffset(145, 43),
    Position = UDim2.new(0.5, -72, 0.8, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Visible = false
}, GUI)

Create("UIStroke", {
    Color = Color3.fromRGB(90, 90, 90),
    Thickness = 1
}, HUD)

local HUDText = Create("TextLabel", {
    Size = UDim2.new(1, -8, 1, 0),
    Position = UDim2.fromOffset(4, 0),
    BackgroundTransparency = 1,
    Text = "FPS / PING / TEMP\n-- / -- / NOT VISIBLE",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center
}, HUD)

Drag(HUD, HUD)

Switch(Home, "FPS+PING+TEMP", function(state)
    ShowHUD = state
    HUD.Visible = state
end)

Switch(Visual, "HIDE NAME", function(state)
    HideNames = state

    local function Apply(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        if OriginalNames[humanoid] == nil then
            OriginalNames[humanoid] = humanoid.DisplayDistanceType
        end

        humanoid.DisplayDistanceType = state
            and Enum.HumanoidDisplayDistanceType.None
            or OriginalNames[humanoid]
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            Apply(p.Character)
        end
    end
end)

local function WatchPlayer(p)
    p.CharacterAdded:Connect(function(character)
        task.wait(1)

        if HideNames then
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                OriginalNames[humanoid] = humanoid.DisplayDistanceType
                humanoid.DisplayDistanceType =
                    Enum.HumanoidDisplayDistanceType.None
            end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    WatchPlayer(p)
end

Players.PlayerAdded:Connect(WatchPlayer)

Switch(Misc, "FPS BOOST LITE", function(state)
    FPSBoost = state
end)

local KeyButton = Create("TextButton", {
    Size = UDim2.new(1, -16, 0, 25),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Text = "TOGGLE KEY  [INSERT]",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 10,
    Font = Enum.Font.Gotham
}, Misc)

Create("UIStroke", {
    Color = Color3.fromRGB(90, 90, 90),
    Thickness = 1
}, KeyButton)

KeyButton.MouseButton1Click:Connect(function()
    WaitingForKey = true
    KeyButton.Text = "PRESS ANY KEY..."
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if WaitingForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            MenuKey = input.KeyCode
            KeyButton.Text = "TOGGLE KEY  [" .. MenuKey.Name .. "]"
            WaitingForKey = false
        end

        return
    end

    if input.KeyCode == MenuKey then
        Main.Visible = not Main.Visible
    end
end)

local frameCount = 0
local lastUpdate = os.clock()
local hudLastUpdate = 0

RunService.RenderStepped:Connect(function()
    frameCount += 1

    local now = os.clock()

    if now - lastUpdate >= 1 then
        FPS = math.floor(frameCount / (now - lastUpdate) + 0.5)
        frameCount = 0
        lastUpdate = now
    end

    if not ShowHUD then return end

    local interval = FPSBoost and 1 or 0.25

    if now - hudLastUpdate < interval then
        return
    end

    hudLastUpdate = now

    local success, value = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)

    Ping = success
        and tostring(math.floor(value + 0.5)) .. " ms"
        or "N/A"

    HUDText.Text = "FPS / PING / TEMP\n"
        .. FPS .. " / " .. Ping .. " / NOT VISIBLE"
end)
