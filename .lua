local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeechlessAPMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 300)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = BLACK
Title.BorderSizePixel = 0
Title.Text = "Speechless.cc"
Title.TextColor3 = WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundColor3 = BLACK
SubTitle.BorderSizePixel = 0
SubTitle.Text = "Ap Macro"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 12
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Center
SubTitle.Parent = MainFrame

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 60)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -110)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

local function CreateButton(name, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 30)
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then 
        if spamRunning then
            StopSpam()
            SpamBtn.Text = "Spam: OFF"
            SpamBtn.BackgroundColor3 = WHITE
            SpamBtn.TextColor3 = BLACK
        else
            StartSpam()
            SpamBtn.Text = "Spam: ON"
            SpamBtn.BackgroundColor3 = BLACK
            SpamBtn.TextColor3 = WHITE
        end
    end
end)

ShowNotification("Speechless.cc [Ap Macro]", "E = Spam toggle | Сделай 1 ручной паринг", 5)
