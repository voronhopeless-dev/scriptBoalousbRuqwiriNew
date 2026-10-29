repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local cfg = {
    silentAim = false,
    teamCheck = true,
    drawFov = true,
    fovSize = 120,
    targetPart = "Head" 
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

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FovCircle"
fovGui.ResetOnSpawn = false
fovGui.Parent = game:GetService("CoreGui")

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, cfg.fovSize, 0, cfg.fovSize)
fovCircle.Position = UDim2.new(0.5, -cfg.fovSize/2, 0.5, -cfg.fovSize/2)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 1
fovCircle.BorderColor3 = Theme.Accent
fovCircle.Parent = fovGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local function getClosestPlayer()
    local closest = nil
    local shortestDist = cfg.fovSize / 2
    local cam = Workspace.CurrentCamera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = p.Character:FindFirstChild(cfg.targetPart) or p.Character:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and targetPart then
                local isTeammate = false
                if cfg.teamCheck and player.Team and p.Team then
                    if player.Team == p.Team then isTeammate = true end
                end
                
                if not isTeammate then
                    local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if cfg.silentAim and (method == "FireServer" or method == "InvokeServer") then
            local target = getClosestPlayer()
            if target then
                local cam = Workspace.CurrentCamera
                local aimCFrame = CFrame.new(cam.CFrame.Position, target.Position)
                local args = {...}
                if typeof(args[1]) == "CFrame" then
                    args[1] = aimCFrame
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.5, -160, 0.5, -190)
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
Title.Text = "  neverlose.cc"
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
            local val = math.floor(min + (max - min) * relX)
            valueLabel.Text = tostring(val)
            callback(val)
        end
    end)
end

CreateToggle("Silent Aim", cfg.silentAim, function(v) cfg.silentAim = v end)
CreateToggle("Team Check", cfg.teamCheck, function(v) cfg.teamCheck = v end)
CreateToggle("FOV Circle", cfg.drawFov, function(v) 
    cfg.drawFov = v 
    fovCircle.Visible = v 
end)
CreateSlider("FOV Size", 20, 500, cfg.fovSize, function(v) 
    cfg.fovSize = v 
    fovCircle.Size = UDim2.new(0, v, 0, v)
    fovCircle.Position = UDim2.new(0.5, -v/2, 0.5, -v/2)
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
