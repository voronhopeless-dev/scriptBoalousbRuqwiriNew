local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(18, 18, 18)
local GRAY = Color3.fromRGB(130, 130, 130)
local GREEN = Color3.fromRGB(0, 255, 100)

local spamRunning = false
local spamThreads = {}
local SPAM_THREAD_COUNT = 5

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeechlessUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 300)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = WHITE
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Speechless.cc"
Title.TextColor3 = WHITE
Title.TextSize = 32
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0.5, -55, 0, 105)
StatusDot.BackgroundColor3 = GRAY
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 5, 0, 95)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ОСТАНОВЛЕН"
StatusLabel.TextColor3 = GRAY
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local SpamBtn = Instance.new("TextButton")
SpamBtn.Size = UDim2.new(0, 280, 0, 40)
SpamBtn.Position = UDim2.new(0.5, -140, 0, 150)
SpamBtn.BackgroundColor3 = WHITE
SpamBtn.BorderSizePixel = 0
SpamBtn.Text = "Spam: OFF"
SpamBtn.TextColor3 = BLACK
SpamBtn.TextSize = 14
SpamBtn.Font = Enum.Font.GothamBold
SpamBtn.Parent = MainFrame

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 6)
SpamCorner.Parent = SpamBtn

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 30)
KeyLabel.Position = UDim2.new(0, 0, 1, -35)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Key: E"
KeyLabel.TextColor3 = WHITE
KeyLabel.TextSize = 14
KeyLabel.Font = Enum.Font.GothamBold
KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
KeyLabel.Parent = MainFrame

local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size = UDim2.new(0, 40, 0, 40)
ReopenBtn.Position = UDim2.new(0, 20, 0.5, -20)
ReopenBtn.BackgroundColor3 = BLACK
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Text = "S"
ReopenBtn.TextColor3 = WHITE
ReopenBtn.TextSize = 18
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.Visible = false
ReopenBtn.Parent = ScreenGui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0, 8)
ReopenCorner.Parent = ReopenBtn

local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = WHITE
ReopenStroke.Thickness = 1
ReopenStroke.Parent = ReopenBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ReopenBtn.Visible = true
end)

ReopenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ReopenBtn.Visible = false
end)

local function UpdateStatus(state)
    spamRunning = state
    if spamRunning then
        StatusDot.BackgroundColor3 = GREEN
        StatusLabel.Text = "РАБОТАЕТ"
        StatusLabel.TextColor3 = GREEN
        SpamBtn.Text = "Spam: ON"
        SpamBtn.BackgroundColor3 = GREEN
        SpamBtn.TextColor3 = BLACK
    else
        StatusDot.BackgroundColor3 = GRAY
        StatusLabel.Text = "ОСТАНОВЛЕН"
        StatusLabel.TextColor3 = GRAY
        SpamBtn.Text = "Spam: OFF"
        SpamBtn.BackgroundColor3 = WHITE
        SpamBtn.TextColor3 = BLACK
    end
end

local function FireSpam()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

local function SpamThread()
    while spamRunning do
        FireSpam()
        task.wait(0.05) 
    end
end

local function StartSpam()
    if spamRunning then return end
    UpdateStatus(true)
    for i = 1, SPAM_THREAD_COUNT do
        table.insert(spamThreads, task.spawn(SpamThread))
    end
end

local function StopSpam()
    if not spamRunning then return end
    UpdateStatus(false)
    for _, th in ipairs(spamThreads) do
        pcall(function() task.cancel(th) end)
    end
    spamThreads = {}
end

local function ToggleSpam()
    if spamRunning then
        StopSpam()
    else
        StartSpam()
    end
end

SpamBtn.MouseButton1Click:Connect(ToggleSpam)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ToggleSpam()
    end
end)
