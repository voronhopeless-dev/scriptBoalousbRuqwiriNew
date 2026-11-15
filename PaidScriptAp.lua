local controlValueA = 3238
local controlValueB = 1420
local controlFlagA = true
local controlFlagB = true
do
    do
        do
            local secondaryValue
            do
                if _G.oxyFluent then return end
                _G.oxyFluent = true
                cloneref = cloneref or function(inputValue) return inputValue end
                do
                    local cloneReference = cloneref
                    createInstance = Instance.new
                    createTweenInfo = TweenInfo.new
                    createUDim = UDim.new
                    createUDim2 = UDim2.new
                    createVector3 = Vector3.new
                    colorFromRGB = Color3.fromRGB
                    formatString = string.format
                    clampValue = math.clamp
                    floorValue = math.floor
                    maxValue = math.max
                    minValue = math.min
                    arcSin = math.asin
                    toRadians = math.rad
                    bitwiseXor = bit32.bxor
                    clearTable = table.clear
                    concatTable = table.concat
                    createTable = table.create
                    insertIntoTable = table.insert
                    stringByte = string.byte
                    stringChar = string.char
                    spawnTask = task.spawn
                    delayTask = task.delay
                    waitTask = task.wait
                    ReplicatedStorage = cloneReference(game:GetService("ReplicatedStorage"))
                    UserInputService = cloneReference(game:GetService("UserInputService"))
                    TweenService = cloneReference(game:GetService("TweenService"))
                    Players = cloneReference(game:GetService("Players"))
                    local runService = cloneReference(game:GetService("RunService"))
                    local statsService = cloneReference(game:GetService("Stats"))
                    Workspace = cloneReference(game:GetService("Workspace"))
                    repeat waitTask() until game:IsLoaded()
                    localPlayer = Players.LocalPlayer
                    name = localPlayer.Name
                    currentCamera = Workspace.CurrentCamera
                    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
                        currentCamera = Workspace.CurrentCamera
                    end)
                    remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
                    packages = ReplicatedStorage.Packages
                    controllers = ReplicatedStorage.Controllers
                    balls = Workspace.Balls
                    alive = Workspace.Alive
                    runtime = Workspace.Runtime
                    dataPing = statsService.Network.ServerStatsItem["Data Ping"]
                    heartbeat = runService.Heartbeat
                    postSimulation = runService.PostSimulation
                end
            end
            local eventCapture = { captured = {}, hooked = {}, originals = {}, token_fn = nil }
            for _, primaryValue in getgc(true) do
                if type(primaryValue) ~= "function" or not debug.info(primaryValue, "s"):find("PRY", 1, true) then
                    continue
                else
                    for _, secondaryValue in debug.getupvalues(primaryValue) do
                        local tertiaryValue = "function"
                        if type(secondaryValue) == tertiaryValue then
                            eventCapture.token_fn = secondaryValue
                            break
                        end
                    end
                    if not eventCapture.token_fn then continue end
                end
                break
            end
            eventCapture.tokenize = function(inputValue)
                local primaryValue = 100
                local secondaryValue = tostring(floorValue(Workspace:GetServerTimeNow() * primaryValue))
                local tertiaryValue = eventCapture.token_fn(inputValue, "TIME")
                local quaternaryValue = createTable(#secondaryValue)
                for i = 1, #secondaryValue do
                    local auxiliaryValue = 256
                    quaternaryValue[i] = stringChar(bitwiseXor((stringByte(secondaryValue, i) + i) % auxiliaryValue, stringByte(tertiaryValue, (i - 1) % #tertiaryValue + 1)))
                end
                return concatTable(quaternaryValue)
            end
            eventCapture.unhook = function()
                for k, primaryValue in eventCapture.originals, nil, nil do
                    pcall(function()
                        setreadonly(k, false)
                        k.__index = primaryValue
                        setreadonly(k, true)
                    end)
                end
                clearTable(eventCapture.hooked)
                clearTable(eventCapture.originals)
            end
            eventCapture.valid_args = function(inputValue)
                return #inputValue == 8 and type(inputValue[2]) == "string" and type(inputValue[3]) == "string" and type(inputValue[4]) == "number" and typeof(inputValue[5]) == "CFrame" and type(inputValue[6]) == "table" and type(inputValue[7]) == "table" and type(inputValue[8]) == "boolean"
            end
            eventCapture.hook = function(inputValue)
                if next(eventCapture.captured) ~= nil then return end
                local primaryValue = getrawmetatable(inputValue)
                if eventCapture.hooked[primaryValue] then return end
                eventCapture.hooked[primaryValue] = true
                setreadonly(primaryValue, false)
                local index = primaryValue.__index
                eventCapture.originals[primaryValue] = index
                primaryValue.__index = function(secondaryInput, tertiaryInput)
                    if tertiaryInput == "FireServer" and secondaryInput:IsA("RemoteEvent") or tertiaryInput == "InvokeServer" and secondaryInput:IsA("RemoteFunction") then
                        return function(quaternaryInput, ...)
                            local temporaryList = { ... }
                            if eventCapture.valid_args(temporaryList) then
                                eventCapture.captured[secondaryInput] = temporaryList
                                eventCapture.unhook()
                            end
                            return index(secondaryInput, tertiaryInput)(quaternaryInput, unpack(temporaryList))
                        end
                    end
                    return index(secondaryInput, tertiaryInput)
                end
                setreadonly(primaryValue, true)
            end
            for _, primaryValue in ReplicatedStorage:GetDescendants() do
                if primaryValue:IsA("RemoteEvent") or primaryValue:IsA("RemoteFunction") then
                    eventCapture.hook(primaryValue)
                end
            end
            local ballState = {
                state = { AerodynamicTime = tick(), LastWarping = tick(), LerpRadians = 0, Curving = tick() },
                positions = {},
            }
            local swordAnimationState = {
                active = nil, cache = {}, tracks = {}, api = nil, generation = 0, last_spam = 0, cancel_delay = 0.12, cancel_fraction = 0.35,
            }
            pcall(function()
                swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI)
            end)
            local inventoryUnlockManager = { current = nil, visited = {} }
            local helperFunction = function(inputValue, secondaryInput, tertiaryInput)
                return inputValue + (secondaryInput - inputValue) * tertiaryInput
            end
            ballState.get = function()
                for _, primaryValue in balls:GetChildren() do
                    if primaryValue:GetAttribute("realBall") then return primaryValue end
                end
                return nil
            end
            ballState.get_all = function()
                local temporaryList = {}
                for _, primaryValue in balls:GetChildren() do
                    if primaryValue:GetAttribute("realBall") then insertIntoTable(temporaryList, primaryValue) end
                end
                return temporaryList
            end
            ballState.position = function(inputValue)
                local primaryValue = inputValue or ballState.get()
                if primaryValue then return ballState.positions[primaryValue] or primaryValue.Position end
                return Vector3.zero
            end
            inventoryUnlockManager.by_mouse = function()
                local temporaryList = {}
                for _, primaryValue in alive:GetChildren() do
                    if primaryValue.Name ~= name and primaryValue.PrimaryPart then insertIntoTable(temporaryList, primaryValue) end
                end
                if #temporaryList == 0 then return nil end
                local currentCamera2 = currentCamera or Workspace.CurrentCamera
                local cFrame = currentCamera2.CFrame
                local position = cFrame.Position
                local lookVector = cFrame.LookVector
                local direction = currentCamera2:ScreenPointToRay(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y).Direction
                local calculationA = -math.huge
                local primaryValue = nil
                for _, secondaryValue in temporaryList, nil, nil do
                    local calculationB = secondaryValue.PrimaryPart.Position - position
                    if calculationB.Magnitude > 0 then
                        local unit = calculationB.Unit
                        if lookVector:Dot(unit) > 0 then
                            local tertiaryValue = direction:Dot(unit)
                            if calculationA < tertiaryValue then
                                calculationA = tertiaryValue
                                primaryValue = secondaryValue
                            end
                        end
                    end
                end
                primaryValue = primaryValue or temporaryList[1]
                inventoryUnlockManager.current = primaryValue
                return primaryValue
            end
            swordAnimationState.find = function(inputValue)
                local grabParry = inputValue:FindFirstChild("GrabParry") or inputValue:FindFirstChild("Parry") or inputValue:FindFirstChild("Grab")
                if grabParry then return grabParry end
                local base = inputValue:FindFirstChild("Base")
                if base then return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab") end
                return nil
            end
            swordAnimationState.resolve = function(inputValue, secondaryInput)
                if not secondaryInput then return nil end
                if swordAnimationState.cache[secondaryInput] and swordAnimationState.cache[secondaryInput].Parent then return swordAnimationState.cache[secondaryInput] end
                local primaryValue = ReplicatedStorage:FindFirstChild("Shared")
                if not primaryValue then return nil end
                local swords = primaryValue:FindFirstChild("ReplicatedInstances")
                swords = swords and swords:FindFirstChild("Swords")
                local secondaryValue = swords and swords:FindFirstChild("GetSword")
                local tertiaryValue = nil
                if secondaryValue then pcall(function() tertiaryValue = secondaryValue:Invoke(secondaryInput) end) end
                local animationType = tertiaryValue and tertiaryValue.AnimationType or "Single"
                local swordType = tertiaryValue and tertiaryValue.SwordType or "Single"
                if swordAnimationState.api and type(swordAnimationState.api.GetAnimations) == "function" then
                    local quaternaryValue, auxiliaryValue = pcall(function() return swordAnimationState.api:GetAnimations(inputValue, {"Parry", "GrabParry"}, animationType, swordType) end)
                    if quaternaryValue and type(auxiliaryValue) == "table" and auxiliaryValue[1] then
                        swordAnimationState.cache[secondaryInput] = auxiliaryValue[1]
                        return auxiliaryValue[1]
                    end
                end
                return nil
            end
            swordAnimationState.grab = function(inputValue)
                local character = localPlayer.Character
                if not character then return false end
                local primaryValue = character:FindFirstChildOfClass("Humanoid")
                local animator = primaryValue and primaryValue:FindFirstChildOfClass("Animator")
                if not primaryValue or not animator then return false end
                local swordAnimations = character:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
                local secondaryValue = swordAnimationState.resolve(character, swordAnimations)
                if not secondaryValue then return false end
                local temporaryList = swordAnimationState.tracks[animator]
                if not temporaryList then temporaryList = {} swordAnimationState.tracks[animator] = temporaryList end
                local tertiaryValue = temporaryList[secondaryValue]
                if not tertiaryValue or not tertiaryValue.Parent or tertiaryValue.Parent ~= animator then
                    local quaternaryValue
                    quaternaryValue, tertiaryValue = pcall(function() return animator:LoadAnimation(secondaryValue) end)
                    if not quaternaryValue or not tertiaryValue then return false end
                    for k, auxiliaryValue in secondaryValue:GetAttributes() do tertiaryValue:SetAttribute(k, auxiliaryValue) end
                    tertiaryValue:SetAttribute("GrabParry", true)
                    tertiaryValue.Priority = Enum.AnimationPriority.Action4
                    temporaryList[secondaryValue] = tertiaryValue
                end
                if inputValue then
                    local quaternaryValue = tick()
                    if quaternaryValue - swordAnimationState.last_spam < swordAnimationState.cancel_delay then
                        local conditionFlagA = false
                        if swordAnimationState.active then pcall(function() conditionFlagA = swordAnimationState.active.IsPlaying end) end
                        if conditionFlagA then return true end
                    end
                    swordAnimationState.last_spam = quaternaryValue
                else
                    swordAnimationState.last_spam = 0
                end
                swordAnimationState.generation = swordAnimationState.generation + 1
                local generation = swordAnimationState.generation
                for _, quaternaryValue in animator:GetPlayingAnimationTracks() do
                    if quaternaryValue:GetAttribute("GrabParry") or quaternaryValue:GetAttribute("Parry") then
                        pcall(quaternaryValue.Stop, quaternaryValue, quaternaryValue:GetAttribute("StopFadeTime") or 0.05)
                    end
                end
                local attribute = secondaryValue:GetAttribute("PlayFadeTime") or 0.05
                tertiaryValue.TimePosition = 0
                tertiaryValue:Play(attribute, 1, 1)
                swordAnimationState.active = tertiaryValue
                if inputValue then
                    local cancelDelay = swordAnimationState.cancel_delay
                    local quaternaryValue = tertiaryValue
                    delayTask(cancelDelay, function()
                        if generation ~= swordAnimationState.generation or swordAnimationState.active ~= quaternaryValue then return end
                        pcall(quaternaryValue.Stop, quaternaryValue, 0.05)
                    end)
                end
                return true
            end
            local parryController = { count = 0, first_signal = nil }
            parryController.fire = function(inputValue)
                local currentCamera2 = currentCamera or Workspace.CurrentCamera
                if not inventoryUnlockManager.by_mouse() then return end
                local primaryValue = currentCamera2.CFrame
                local primaryPart = inventoryUnlockManager.current and inventoryUnlockManager.current.PrimaryPart
                local temporaryList
                if primaryPart then
                    local secondaryValue = currentCamera2:WorldToViewportPoint(primaryPart.Position)
                    temporaryList = { secondaryValue.X, secondaryValue.Y }
                else
                    local viewportSize = currentCamera2.ViewportSize
                    temporaryList = { viewportSize.X * 0.5, viewportSize.Y * 0.5 }
                end
                local temporaryMap = {}
                for _, secondaryValue in alive:GetChildren() do
                    local primaryPart2 = secondaryValue.PrimaryPart
                    if primaryPart2 then
                        local tertiaryValue = currentCamera2:WorldToScreenPoint(primaryPart2.Position)
                        if tertiaryValue and tertiaryValue.Z > 0 then temporaryMap[secondaryValue.Name] = tertiaryValue end
                    end
                end
                if next(eventCapture.captured) == nil then
                    if not parryController.first_signal then
                        parryController.first_signal = require(packages.Signal).new()
                        parryController.first_signal:Connect(require(controllers["SwordsController \12"].PRY))
                    end
                    parryController.first_signal:Fire(0.5, primaryValue, temporaryMap, temporaryList, false)
                    if inputValue then swordAnimationState.grab(true) end
                else
                    swordAnimationState.grab(inputValue)
                    for k, secondaryValue in eventCapture.captured, nil, nil do
                        local parryArguments = {}
                        local tertiaryValue = secondaryValue[1]
                        local quaternaryValue = secondaryValue[2]
                        local auxiliaryValue = eventCapture.tokenize(secondaryValue[2])
                        parryArguments[1] = tertiaryValue
                        parryArguments[2] = quaternaryValue
                        parryArguments[3] = auxiliaryValue
                        parryArguments[4] = 0.5
                        parryArguments[5] = primaryValue
                        parryArguments[6] = temporaryMap
                        parryArguments[7] = temporaryList
                        parryArguments[8] = false
                        if k:IsA("RemoteEvent") then
                            k:FireServer(unpack(parryArguments))
                        elseif k:IsA("RemoteFunction") then
                            k:InvokeServer(unpack(parryArguments))
                        end
                    end
                end
                if parryController.count > 7 then return false end
                parryController.count = parryController.count + 1
                delayTask(0.5, function() if parryController.count > 0 then parryController.count = parryController.count - 1 end end)
            end
            local parryState = { debounce = false, until_at = 0, accuracy = 1.5 }
            local triggerbotState = { on = false, busy = false, key = Enum.KeyCode.T, button = nil }
            ballState.curved = function(inputValue)
                local primaryValue = inputValue or ballState.get()
                if primaryValue then
                    local zoomies = primaryValue:FindFirstChild("zoomies")
                    if not zoomies then return false end
                    local secondaryValue = tick()
                    local value = dataPing:GetValue()
                    local vectorVelocity = zoomies.VectorVelocity
                    local unit = vectorVelocity.Unit
                    local position = localPlayer.Character.PrimaryPart.Position
                    local tertiaryValue = ballState.position(primaryValue)
                    local unit2 = (position - tertiaryValue).Unit
                    local quaternaryValue = unit2:Dot(unit)
                    local magnitude = vectorVelocity.Magnitude
                    local auxiliaryValue = minValue(magnitude / 100, 40)
                    local calculationA = quaternaryValue - unit2:Dot((unit - vectorVelocity).Unit)
                    local magnitude2 = (position - tertiaryValue).Magnitude
                    local calculationB = 0.5 - value / 1000
                    local calculationC = magnitude2 / magnitude - value / 1000
                    local calculationD = 15 - minValue(magnitude2 / 1000, 15) + auxiliaryValue
                    local candidateValue = 0.8
                    ballState.state.LerpRadians = helperFunction(ballState.state.LerpRadians, toRadians(arcSin(clampValue(quaternaryValue, -1, 1))), candidateValue)
                    if magnitude > 100 and calculationC > value / 10 then
                        calculationD = maxValue(calculationD - 15, 15)
                    end
                    if magnitude2 < calculationD then return false end
                    if calculationA < calculationB then return true end
                    if ballState.state.LerpRadians < 0.018 then ballState.state.LastWarping = secondaryValue end
                    if secondaryValue - ballState.state.LastWarping < calculationC / 1.5 then return true end
                    if secondaryValue - ballState.state.Curving < calculationC / 1.5 then return true end
                    return quaternaryValue < calculationB
                end
                return false
            end
            parryState.check = function()
                if triggerbotState.busy then return end
                local character = localPlayer.Character
                character = character and character.PrimaryPart
                if not character then return end
                local primaryValue = tick()
                if parryState.debounce or primaryValue < parryState.until_at then return end
                local position = character.Position
                local secondaryValue = clampValue(dataPing:GetValue() / 10 / 10, 5, 17)
                local attribute = ballState.get()
                attribute = attribute and attribute:GetAttribute("target")
                local tornado = runtime:FindFirstChild("Tornado")
                local attribute2 = tornado and (tornado:GetAttribute("TornadoTime") or 1)
                local position2 = ballState.position
                local curved = ballState.curved
                for _, tertiaryValue in ballState.get_all() do
                    if not tertiaryValue then return end
                    local quaternaryValue = tertiaryValue:FindFirstChild("zoomies")
                    if not quaternaryValue then return end
                    local attribute3 = tertiaryValue:GetAttribute("target")
                    local magnitude = quaternaryValue.VectorVelocity.Magnitude
                    local magnitude2 = (position - position2(tertiaryValue)).Magnitude
                    local auxiliaryValue = 0.002
                    local accuracy = parryState.accuracy
                    local calculationA = (2.4 + minValue(maxValue(magnitude - 9.5, 0), 650) * auxiliaryValue) * accuracy
                    if tertiaryValue:FindFirstChild("AeroDynamicSlashVFX") then
                        tertiaryValue.AeroDynamicSlashVFX:Destroy()
                        ballState.state.AerodynamicTime = primaryValue
                    end
                    if tornado and primaryValue - ballState.state.AerodynamicTime < attribute2 + 0.314159 then return end
                    if attribute == name and curved(tertiaryValue) then return end
                    if attribute3 == name and magnitude2 <= secondaryValue + maxValue(magnitude / calculationA, 9.5) and parryState.accuracy * 0.8 then
                        parryController.fire()
                        parryState.debounce = true
                        parryState.until_at = primaryValue + 1
                    end
                end
            end
            local autoParryEnabled = false
            postSimulation:Connect(function()
                if autoParryEnabled then parryState.check() end
            end)
            local ScreenGui = createInstance("ScreenGui")
            ScreenGui.Name = "S"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
            local MainFrame = createInstance("Frame")
            MainFrame.Size = createUDim2(0, 300, 0, 160)
            MainFrame.Position = createUDim2(0.5, -150, 0.5, -80)
            MainFrame.BackgroundColor3 = colorFromRGB(10, 10, 10)
            MainFrame.BorderSizePixel = 0
            MainFrame.Active = true
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
                    MainFrame.Position = createUDim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            local Title = createInstance("TextLabel")
            Title.Size = createUDim2(1, 0, 0, 30)
            Title.BackgroundTransparency = 1
            Title.Text = "S.cc"
            Title.TextColor3 = colorFromRGB(255, 255, 255)
            Title.TextSize = 14
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Center
            Title.Parent = MainFrame
            local ToggleBtn = createInstance("TextButton")
            ToggleBtn.Size = createUDim2(0, 20, 0, 20)
            ToggleBtn.Position = createUDim2(1, -50, 0, 5)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = "—"
            ToggleBtn.TextColor3 = colorFromRGB(255, 255, 255)
            ToggleBtn.TextSize = 14
            ToggleBtn.Font = Enum.Font.GothamBold
            ToggleBtn.Parent = MainFrame
            local CloseBtn = createInstance("TextButton")
            CloseBtn.Size = createUDim2(0, 20, 0, 20)
            CloseBtn.Position = createUDim2(1, -25, 0, 5)
            CloseBtn.BackgroundTransparency = 1
            CloseBtn.Text = "X"
            CloseBtn.TextColor3 = colorFromRGB(255, 255, 255)
            CloseBtn.TextSize = 14
            CloseBtn.Font = Enum.Font.GothamBold
            CloseBtn.Parent = MainFrame
            CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
            local TabsFrame = createInstance("Frame")
            TabsFrame.Size = createUDim2(1, 0, 0, 30)
            TabsFrame.Position = createUDim2(0, 0, 0, 30)
            TabsFrame.BackgroundTransparency = 1
            TabsFrame.Parent = MainFrame
            local CombatTab = createInstance("TextButton")
            CombatTab.Size = createUDim2(0, 80, 1, 0)
            CombatTab.Position = createUDim2(0, 20, 0, 0)
            CombatTab.BackgroundTransparency = 1
            CombatTab.Text = "Combat"
            CombatTab.TextColor3 = colorFromRGB(255, 255, 255)
            CombatTab.TextSize = 14
            CombatTab.Font = Enum.Font.Gotham
            CombatTab.Parent = TabsFrame
            local ContentFrame = createInstance("Frame")
            ContentFrame.Size = createUDim2(1, 0, 1, -60)
            ContentFrame.Position = createUDim2(0, 0, 0, 60)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = MainFrame
            ToggleBtn.MouseButton1Click:Connect(function()
                if MainFrame.Size.Y.Scale > 0 then
                    TweenService:Create(MainFrame, createTweenInfo(0.3), {Size = createUDim2(0, 300, 0, 30)}):Play()
                    ToggleBtn.Text = "+"
                    ContentFrame.Visible = false
                    TabsFrame.Visible = false
                else
                    TweenService:Create(MainFrame, createTweenInfo(0.3), {Size = createUDim2(0, 300, 0, 160)}):Play()
                    ToggleBtn.Text = "—"
                    ContentFrame.Visible = true
                    TabsFrame.Visible = true
                end
            end)
            local container = createInstance("Frame")
            container.Size = createUDim2(1, -40, 0, 40)
            container.Position = createUDim2(0, 20, 0, 10)
            container.BackgroundTransparency = 1
            container.Parent = ContentFrame
            local label = createInstance("TextLabel")
            label.Size = createUDim2(1, -60, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "Auto Parry"
            label.TextColor3 = colorFromRGB(255, 255, 255)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            local toggleBg = createInstance("Frame")
            toggleBg.Size = createUDim2(0, 44, 0, 22)
            toggleBg.Position = createUDim2(1, -44, 0.5, -11)
            toggleBg.BackgroundColor3 = colorFromRGB(40, 40, 40)
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = container
            local bgCorner = createInstance("UICorner")
            bgCorner.CornerRadius = createUDim(1, 0)
            bgCorner.Parent = toggleBg
            local toggleKnob = createInstance("Frame")
            toggleKnob.Size = createUDim2(0, 18, 0, 18)
            toggleKnob.Position = createUDim2(0, 2, 0.5, -9)
            toggleKnob.BackgroundColor3 = colorFromRGB(255, 255, 255)
            toggleKnob.BorderSizePixel = 0
            toggleKnob.Parent = toggleBg
            local knobCorner = createInstance("UICorner")
            knobCorner.CornerRadius = createUDim(1, 0)
            knobCorner.Parent = toggleKnob
            local clickBtn = createInstance("TextButton")
            clickBtn.Size = createUDim2(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = container
            local toggleState = false
            local tweenInfo = createTweenInfo(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            clickBtn.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                autoParryEnabled = toggleState
                if toggleState then
                    TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = colorFromRGB(255, 255, 255)}):Play()
                    TweenService:Create(toggleKnob, tweenInfo, {Position = createUDim2(1, -20, 0.5, -9), BackgroundColor3 = colorFromRGB(10, 10, 10)}):Play()
                else
                    TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = colorFromRGB(40, 40, 40)}):Play()
                    TweenService:Create(toggleKnob, tweenInfo, {Position = createUDim2(0, 2, 0.5, -9), BackgroundColor3 = colorFromRGB(255, 255, 255)}):Play()
                end
            end)
            local sliderContainer = createInstance("Frame")
            sliderContainer.Size = createUDim2(1, -40, 0, 50)
            sliderContainer.Position = createUDim2(0, 20, 0, 60)
            sliderContainer.BackgroundTransparency = 1
            sliderContainer.Parent = ContentFrame
            local sliderLabel = createInstance("TextLabel")
            sliderLabel.Size = createUDim2(1, 0, 0, 20)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = "Accuracy: 50"
            sliderLabel.TextColor3 = colorFromRGB(255, 255, 255)
            sliderLabel.TextSize = 14
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderContainer
            local sliderBg = createInstance("Frame")
            sliderBg.Size = createUDim2(1, 0, 0, 4)
            sliderBg.Position = createUDim2(0, 0, 0, 28)
            sliderBg.BackgroundColor3 = colorFromRGB(40, 40, 40)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = sliderContainer
            local sBgCorner = createInstance("UICorner")
            sBgCorner.CornerRadius = createUDim(1, 0)
            sBgCorner.Parent = sliderBg
            local fill = createInstance("Frame")
            fill.Size = createUDim2(0.5, 0, 1, 0)
            fill.BackgroundColor3 = colorFromRGB(255, 255, 255)
            fill.BorderSizePixel = 0
            fill.Parent = sliderBg
            local fCorner = createInstance("UICorner")
            fCorner.CornerRadius = createUDim(1, 0)
            fCorner.Parent = fill
            local knob = createInstance("Frame")
            knob.Size = createUDim2(0, 14, 0, 14)
            knob.Position = createUDim2(0.5, -7, 0.5, -7)
            knob.BackgroundColor3 = colorFromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.Parent = sliderBg
            local kCorner = createInstance("UICorner")
            kCorner.CornerRadius = createUDim(1, 0)
            kCorner.Parent = knob
            local clickArea = createInstance("TextButton")
            clickArea.Size = createUDim2(1, 0, 0, 25)
            clickArea.Position = createUDim2(0, 0, 0, 18)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.Parent = sliderContainer
            local sDragging = false
            local function updateSlider(input)
                local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(1 + 99 * relX)
                fill.Size = createUDim2(relX, 0, 1, 0)
                knob.Position = createUDim2(relX, -7, 0.5, -7)
                sliderLabel.Text = "Accuracy: " .. val
                parryState.accuracy = (val - 1) * 0.015151515151515152
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
            return 
        end
        while true do end
    end
end
