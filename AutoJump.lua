local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local autoJumpOn = false
local jumpConn = nil

local jumpGui = Instance.new("ScreenGui")
jumpGui.Name = "AutoJumpFloatingGui"
jumpGui.ResetOnSpawn = false
jumpGui.Parent = localPlayer:WaitForChild("PlayerGui")

local jumpBtn = Instance.new("TextButton")
jumpBtn.Name = "AutoJumpFloatingBtn"
jumpBtn.Size = UDim2.new(0, 150, 0, 55)
jumpBtn.Position = UDim2.new(0, 15, 0.5, 100)
jumpBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "Auto Jump: OFF"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextSize = 16
jumpBtn.Font = Enum.Font.Gotham
jumpBtn.Active = true
jumpBtn.Draggable = true
jumpBtn.Parent = jumpGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = jumpBtn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Parent = jumpBtn

local function StartAutoJump()
    if jumpConn then return end
    jumpConn = RunService.Heartbeat:Connect(function()
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if hum.FloorMaterial ~= Enum.Material.Air then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
        end
    end)
end

local function StopAutoJump()
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    autoJumpOn = not autoJumpOn
    if autoJumpOn then
        jumpBtn.Text = "Auto Jump: ON"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        StartAutoJump()
    else
        jumpBtn.Text = "Auto Jump: OFF"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        StopAutoJump()
    end
end)
