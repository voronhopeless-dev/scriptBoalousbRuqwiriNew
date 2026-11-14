local controlValueA = 3238
local controlValueB = 1420
local controlFlagA = true
local controlFlagB = true
do
    do
        do
            do
                do
                    do
                        do
                            do
                                do
                                    local secondaryValue
                                    do
                                        if _G.oxyFluent then
                                            return 
                                        end
                                        _G.oxyFluent = true
                                        cloneref = cloneref or function(inputValue)
                                            return inputValue
                                        end
                                        do
                                            local cloneReference = cloneref
                                            createInstance = Instance.new
                                            createTweenInfo = TweenInfo.new
                                            createUDim = UDim.new
                                            createUDim2 = UDim2.new
                                            fromOffset = UDim2.fromOffset
                                            createVector2 = Vector2.new
                                            createVector3 = Vector3.new
                                            createCFrame = CFrame.new
                                            colorFromRGB = Color3.fromRGB
                                            formatString = string.format
                                            clampValue = math.clamp
                                            floorValue = math.floor
                                            maxValue = math.max
                                            minValue = math.min
                                            arcSin = math.asin
                                            toRadians = math.rad
                                            randomValue = math.random
                                            bitwiseXor = bit32.bxor
                                            clearTable = table.clear
                                            concatTable = table.concat
                                            createTable = table.create
                                            findInTable = table.find
                                            insertIntoTable = table.insert
                                            stringByte = string.byte
                                            stringChar = string.char
                                            spawnTask = task.spawn
                                            delayTask = task.delay
                                            deferTask = task.defer
                                            waitTask = task.wait
                                            globalEnvironment = getgenv()
                                            ReplicatedStorage = cloneReference(game:GetService("ReplicatedStorage"))
                                            UserInputService = cloneReference(game:GetService("UserInputService"))
                                            httpService = cloneReference(game:GetService("HttpService"))
                                            local runService = cloneReference(game:GetService("RunService"))
                                            TweenService = cloneReference(game:GetService("TweenService"))
                                            Players = cloneReference(game:GetService("Players"))
                                            Debris = cloneReference(game:GetService("Debris"))
                                            local statsService = cloneReference(game:GetService("Stats"))
                                            Workspace = cloneReference(game:GetService("Workspace"))
                                            createTween = TweenService.Create
                                            repeat
                                                waitTask()
                                            until game:IsLoaded()
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
                                            preSimulation = runService.PreSimulation
                                            postSimulation = runService.PostSimulation
                                        end
                                    end
                                    swordEventConnections = {
                                        parry_connections = {
                                        },
                                        fire_sword_connections = {
                                        },
                                        play_parry = nil,
                                        sword_fn = nil,
                                    }
                                    if remotes and type(getconnections) == "function" then
                                        do
                                            local parrySuccessAll = remotes:WaitForChild("ParrySuccessAll", 10)
                                            if parrySuccessAll then
                                                local tertiaryValue, quaternaryValue = pcall(getconnections, parrySuccessAll.OnClientEvent)
                                                if tertiaryValue and type(quaternaryValue) == "table" then
                                                    for _, auxiliaryValue in quaternaryValue, nil, nil do
                                                        do
                                                            local candidateValue, resultValue = pcall(function()
                                                                return auxiliaryValue.Function
                                                            end)
                                                            if candidateValue and type(resultValue) == "function" then
                                                                insertIntoTable(swordEventConnections.parry_connections, auxiliaryValue)
                                                                swordEventConnections.play_parry = resultValue
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        local tertiaryValue = remotes:WaitForChild("FireSwordInfo", 10)
                                        if tertiaryValue then
                                            local quaternaryValue, auxiliaryValue = pcall(getconnections, tertiaryValue.OnClientEvent)
                                            if quaternaryValue and type(auxiliaryValue) == "table" then
                                                for _, candidateValue in auxiliaryValue, nil, nil do
                                                    local resultValue, errorValue = pcall(function()
                                                        return candidateValue.Function
                                                    end)
                                                    if resultValue and type(errorValue) == "function" then
                                                        insertIntoTable(swordEventConnections.fire_sword_connections, candidateValue)
                                                        swordEventConnections.sword_fn = errorValue
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    configStorage = {
                                        folder = "oxy",
                                    }
                                    configStorage.storage_ok = type(readfile) == "function" and type(writefile) == "function"
                                    configStorage.last_saved = {
                                    }
                                    configStorage.has_saved = false
                                    configStorage.defaults = {
                                        accuracy = 100,
                                        spam_threshold = 3,
                                        curve_keybind = false,
                                        manual_notify = false,
                                        curve_notify = false,
                                        curve_method = "camera",
                                        manual_spam = "E",
                                        mobile_triggerbot_button = false,
                                        mobile_manual_spam_button = false,
                                        auto_parry = false,
                                        ball_debug = false,
                                        auto_spam = false,
                                        random_target = false,
                                        unlock_all = false,
                                        last_equipped_sword = "",
                                        last_equipped_explosion = "",
                                        favorite_swords = {
                                        },
                                        favorite_explosions = {
                                        },
                                        deleted_swords = {
                                        },
                                        deleted_explosions = {
                                        },
                                    }
                                    configStorage.path = configStorage.folder .. "/config.json"
                                    configStorage.fflag_folder = configStorage.folder .. "/fflags"
                                    configStorage.trim = function(inputValue)
                                        return tostring(inputValue or ""):match("^%s*(.-)%s*$")
                                    end
                                    configStorage.ensure_folder = function()
                                        local tertiaryValue = "function"
                                        if type(makefolder) ~= tertiaryValue then
                                            return 
                                        end
                                        local quaternaryValue = "function"
                                        local conditionFlagA = false
                                        if type(isfolder) == quaternaryValue then
                                            local auxiliaryValue
                                            auxiliaryValue, conditionFlagA = pcall(isfolder, configStorage.folder)
                                            conditionFlagA = auxiliaryValue and conditionFlagA
                                        end
                                        if not conditionFlagA then
                                            pcall(makefolder, configStorage.folder)
                                        end
                                    end
                                    configStorage.ensure_fflag_folder = function()
                                        configStorage.ensure_folder()
                                        if type(makefolder) ~= "function" then
                                            return 
                                        end
                                        local tertiaryValue = "function"
                                        local conditionFlagA = false
                                        if type(isfolder) == tertiaryValue then
                                            local quaternaryValue
                                            quaternaryValue, conditionFlagA = pcall(isfolder, configStorage.fflag_folder)
                                            conditionFlagA = quaternaryValue and conditionFlagA
                                        end
                                        if not conditionFlagA then
                                            pcall(makefolder, configStorage.fflag_folder)
                                        end
                                    end
                                    configStorage.copy = function(inputValue)
                                        local tertiaryValue = "table"
                                        if type(inputValue) ~= tertiaryValue then
                                            return inputValue
                                        end
                                        local ballState = {
                                        }
                                        for k, quaternaryValue in inputValue, nil, nil do
                                            ballState[k] = configStorage.copy(quaternaryValue)
                                        end
                                        return ballState
                                    end
                                    configStorage.equal = function(inputValue, secondaryInput)
                                        if inputValue == secondaryInput then
                                            return true
                                        end
                                        local tertiaryValue = "table"
                                        if type(inputValue) ~= tertiaryValue or type(secondaryInput) ~= "table" then
                                            return false
                                        end
                                        for k, quaternaryValue in inputValue, nil, nil do
                                            local auxiliaryValue = "table"
                                            if type(quaternaryValue) == auxiliaryValue then
                                                if not configStorage.equal(quaternaryValue, secondaryInput[k]) then
                                                    return false
                                                end
                                                continue
                                            end
                                            if secondaryInput[k] ~= quaternaryValue then
                                                return false
                                            end
                                        end
                                        for k in secondaryInput, nil, nil do
                                            if inputValue[k] == nil then
                                                return false
                                            end
                                        end
                                        return true
                                    end
                                    configStorage.valid_key = function(inputValue)
                                        if type(inputValue) ~= "string" then
                                            return false
                                        end
                                        local tertiaryValue, quaternaryValue = pcall(function()
                                            return Enum.KeyCode[inputValue]
                                        end)
                                        return tertiaryValue and quaternaryValue ~= nil
                                    end
                                    curveMethods = {
                                        "camera",
                                        "dot",
                                        "backwards",
                                        "slow",
                                        "random",
                                    }
                                    configStorage.normalize = function(inputValue)
                                        local ballState = {
                                        }
                                        for k, tertiaryValue in configStorage.defaults, nil, nil do
                                            local conditionFlagA = type(inputValue) == "table" and inputValue[k] or nil
                                            local quaternaryValue = "table"
                                            if type(tertiaryValue) == quaternaryValue then
                                                ballState[k] = type(conditionFlagA) == "table" and configStorage.copy(conditionFlagA) or configStorage.copy(tertiaryValue)
                                            else
                                                ballState[k] = type(conditionFlagA) == type(tertiaryValue) and conditionFlagA or tertiaryValue
                                            end
                                        end
                                        ballState.accuracy = clampValue(floorValue(ballState.accuracy + 0.5), 1, 100)
                                        ballState.spam_threshold = clampValue(floorValue(ballState.spam_threshold + 0.5), 1, 3)
                                        if not findInTable(curveMethods, ballState.curve_method) then
                                            ballState.curve_method = configStorage.defaults.curve_method
                                        end
                                        if not configStorage.valid_key(ballState.manual_spam) then
                                            ballState.manual_spam = configStorage.defaults.manual_spam
                                        end
                                        return ballState
                                    end
                                    do
                                        local data = nil
                                        if configStorage.storage_ok then
                                            configStorage.ensure_folder()
                                            pcall(function()
                                                data = httpService:JSONDecode(readfile(configStorage.path))
                                            end)
                                        end
                                        _G.config = configStorage.normalize(data)
                                    end
                                    config = _G.config
                                    configStorage.changed = function()
                                        if not configStorage.has_saved then
                                            return true
                                        end
                                        for k in configStorage.defaults, nil, nil do
                                            local tertiaryValue = configStorage.last_saved[k]
                                            local quaternaryValue = config[k]
                                            if type(tertiaryValue) == "table" or type(quaternaryValue) == "table" then
                                                if not configStorage.equal(tertiaryValue, quaternaryValue) then
                                                    return true
                                                end
                                                continue
                                            end
                                            if tertiaryValue ~= quaternaryValue then
                                                return true
                                            end
                                        end
                                        return false
                                    end
                                    configStorage.save = function()
                                        if not (not configStorage.storage_ok or not configStorage.changed()) then
                                            local ballState = {
                                            }
                                            for k, tertiaryValue in configStorage.defaults, nil, nil do
                                                local quaternaryValue = config[k]
                                                if type(tertiaryValue) == "table" then
                                                    ballState[k] = type(quaternaryValue) == "table" and configStorage.copy(quaternaryValue) or configStorage.copy(tertiaryValue)
                                                else
                                                    ballState[k] = type(quaternaryValue) == type(tertiaryValue) and quaternaryValue or tertiaryValue
                                                end
                                            end
                                            local tertiaryValue, quaternaryValue = pcall(function()
                                                return httpService:JSONEncode(ballState)
                                            end)
                                            if not tertiaryValue then
                                                return 
                                            end
                                            configStorage.ensure_folder()
                                            if not pcall(writefile, configStorage.path, quaternaryValue) then
                                                return 
                                            end
                                            for k in configStorage.defaults, nil, nil do
                                                local auxiliaryValue = ballState[k]
                                                configStorage.last_saved[k] = type(auxiliaryValue) == "table" and configStorage.copy(auxiliaryValue) or auxiliaryValue
                                            end
                                            configStorage.has_saved = true
                                            return 
                                        end
                                        if not (controlValueA <= 3227) then
                                            return 
                                        end
                                        while true do

                                        end
                                    end
                                    fflagProfiles = nil
                                end
                            end
                            runtimeConnections = nil
                            configStorage.save()
                            spawnTask(function()
                                while _G.oxyFluent do
                                    waitTask(1)
                                    configStorage.save()
                                end
                            end)
                            local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
                            local oxy = Fluent:CreateWindow({
                                Title = "Speechless.cc",
                                TabWidth = 145,
                                Size = UDim2.fromOffset(440, 315),
                                Acrylic = false,
                                Theme = "Dark",
                                MinimizeKey = Enum.KeyCode.LeftControl,
                            })
                            do
                                local combat = oxy:AddTab({ Title = "Combat", Icon = "swords" })
                                local misc2 = oxy:AddTab({ Title = "Misc", Icon = "settings" })
                                local combatSection = combat:AddSection("")
                                local miscSection = misc2:AddSection("")
                                parrySection = combatSection
                                curve = combatSection
                                spam = combatSection
                                hotkeys = combatSection
                                misc = miscSection
                            end
                        end
    local profile, fflagsSection, profileNameInput, flagsJsonInput
    do
        do
            notificationService = {
                notify = function(_, notification)
                    Fluent:Notify({
                        Title = notification.title,
                        Content = notification.content,
                        Duration = notification.duration,
                    })
                end,
            }
        end
        createGuiInstance = function(inputValue, secondaryInput)
            local auxiliaryValue = createInstance(inputValue)
            for k, candidateValue in secondaryInput, nil, nil do
                if k ~= "Parent" then
                    auxiliaryValue[k] = candidateValue
                end
            end
            auxiliaryValue.Parent = secondaryInput.Parent
            return auxiliaryValue
        end
    end
end
local runtimeConnections, ballState, touchEnabled, keyboardEnabled, gamepadEnabled, spamController, triggerbotState
do
    local curveController, swordAnimationState, parryController, helperFunction
    do
        local eventCapture
        do
            runtimeConnections = {
            }
            curveController = {
                methods = curveMethods,
                dropdown = nil,
                syncing = false,
            }
            swordAnimationState = {
                active = nil,
                cache = {
                },
                tracks = {
                },
                api = nil,
                generation = 0,
                last_spam = 0,
                cancel_delay = 0.12,
                cancel_fraction = 0.35,
            }
            parryController = {
                count = 0,
                first_signal = nil,
            }
            pcall(function()
                swordAnimationState.api = require(ReplicatedStorage.Shared.SwordAPI)
            end)
            localPlayer.CharacterAdded:Connect(function()
                clearTable(swordAnimationState.tracks)
                swordAnimationState.active = nil
                swordAnimationState.generation = swordAnimationState.generation + 1
                swordAnimationState.last_spam = 0
            end)
            ballState = {
                state = {
                    AerodynamicTime = tick(),
                    LastWarping = tick(),
                    LerpRadians = 0,
                    Curving = tick(),
                },
                positions = {
                },
                replicator = nil,
            }
            helperFunction = function(inputValue, secondaryInput, tertiaryInput)
                return inputValue + (secondaryInput - inputValue) * tertiaryInput
            end
            eventCapture = {
                captured = {
                },
                hooked = {
                },
                originals = {
                },
                token_fn = nil,
            }
            for _, primaryValue in getgc(true) do
                if type(primaryValue) ~= "function" or not debug.info(primaryValue, "s")then
                    continue
                else
                    for _, secondaryValue in debug.getupvalues(primaryValue) do
                        local tertiaryValue = "function"
                        if type(secondaryValue) == tertiaryValue then
                            print("found.")
                            eventCapture.token_fn = secondaryValue
                            break
                        end
                    end
                    if not eventCapture.token_fn then
                        continue
                    end
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
                if next(eventCapture.captured) ~= nil then
                    return 
                end
                local primaryValue = getrawmetatable(inputValue)
                if eventCapture.hooked[primaryValue] then
                    return 
                end
                eventCapture.hooked[primaryValue] = true
                setreadonly(primaryValue, false)
                local index = primaryValue.__index
                eventCapture.originals[primaryValue] = index
                primaryValue.__index = function(secondaryInput, tertiaryInput)
                    if tertiaryInput == "FireServer" and secondaryInput:IsA("RemoteEvent") or tertiaryInput == "InvokeServer" and secondaryInput:IsA("RemoteFunction") then
                        return function(quaternaryInput, ...)
                            local temporaryList = {
                                ...,
                            }
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
            ballState.get = function()
                for _, primaryValue in balls:GetChildren() do
                    if primaryValue:GetAttribute("realBall") then
                        return primaryValue
                    end
                end
                return nil
            end
            ballState.get_all = function()
                local temporaryList = {
                }
                for _, primaryValue in balls:GetChildren() do
                    if primaryValue:GetAttribute("realBall") then
                        insertIntoTable(temporaryList, primaryValue)
                    end
                end
                return temporaryList
            end
            do
                local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.1.0") and ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"]:FindFirstChild("net")
                if net then
                    if controlValueA <= 3223 then
                        while true do

                        end
                    else
                        for _, primaryValue in net:GetChildren() do
                            if primaryValue:IsA("UnreliableRemoteEvent") and primaryValue.Name ~= "URE/ReplicateBallPosition" then
                                ballState.replicator = primaryValue
                                break
                            end
                        end
                    end
                end
            end
        end
        if ballState.replicator then
            ballState.replicator.OnClientEvent:Connect(function(inputValue, secondaryInput)
                if inputValue and inputValue.Parent == balls and inputValue:GetAttribute("realBall") == true then
                    ballState.positions[inputValue] = secondaryInput
                end
            end)
        end
        ballState.position = function(inputValue)
            local primaryValue = inputValue or ballState.get()
            if primaryValue then
                return ballState.positions[primaryValue] or primaryValue.Position
            end
            return Vector3.zero
        end
        touchEnabled = UserInputService.TouchEnabled
        do
            local mouseEnabled = UserInputService.MouseEnabled
            keyboardEnabled = UserInputService.KeyboardEnabled
            gamepadEnabled = UserInputService.GamepadEnabled
            curveController.get_cframe = function()
                local cFrame = (currentCamera or Workspace.CurrentCamera).CFrame
                local character = localPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                    return cFrame
                end
                local position = mouseEnabled and (UserInputService:GetMouseLocation()) or humanoidRootPart.Position + cFrame.LookVector * 1000
                local unit = (position - humanoidRootPart.Position).Unit
                local curveMethod = config.curve_method
                if curveMethod == "dot" then
                    return CFrame.lookAt(humanoidRootPart.Position, position + createVector3(0, 1.75, 0))
                end
                if curveMethod == "backwards" then
                    return createCFrame(humanoidRootPart.Position, humanoidRootPart.Position + -unit * 1000)
                end
                if curveMethod == "slow" then
                    return createCFrame(humanoidRootPart.Position, humanoidRootPart.Position + createVector3(0, -350, 0))
                end
                if curveMethod == "random" then
                    local position2 = humanoidRootPart.Position
                    local primaryValue = 1000
                    return createCFrame(position2, position + createVector3(randomValue(-1000, 1000), randomValue(-350, 1000), randomValue(-1000, primaryValue)))
                end
                return cFrame
            end
            curveController.sync_dropdown = function(inputValue)
                curveController.syncing = true
                curveController.dropdown:SetValue(inputValue)
                curveController.syncing = false
            end
            swordAnimationState.find = function(inputValue)
                local grabParry = inputValue:FindFirstChild("GrabParry") or inputValue:FindFirstChild("Parry") or inputValue:FindFirstChild("Grab")
                if grabParry then
                    return grabParry
                end
                local base = inputValue:FindFirstChild("Base")
                if base then
                    return base:FindFirstChild("GrabParry") or base:FindFirstChild("Parry") or base:FindFirstChild("Grab")
                end
                return nil
            end
            swordAnimationState.resolve = function(inputValue, secondaryInput)
                if not secondaryInput then
                    return nil
                end
                if swordAnimationState.cache[secondaryInput] and swordAnimationState.cache[secondaryInput].Parent then
                    return swordAnimationState.cache[secondaryInput]
                end
                local primaryValue = ReplicatedStorage:FindFirstChild("Shared")
                if not primaryValue then
                    return nil
                end
                local swords = primaryValue:FindFirstChild("ReplicatedInstances")
                swords = swords and swords:FindFirstChild("Swords")
                local secondaryValue = swords and swords:FindFirstChild("GetSword")
                local tertiaryValue = nil
                if secondaryValue then
                    pcall(function()
                        tertiaryValue = secondaryValue:Invoke(secondaryInput)
                    end)
                end
                local animationType = tertiaryValue and tertiaryValue.AnimationType or "Single"
                local swordType = tertiaryValue and tertiaryValue.SwordType or "Single"
                if swordAnimationState.api and type(swordAnimationState.api.GetAnimations) == "function" then
                    local quaternaryValue, auxiliaryValue = pcall(function()
                        return swordAnimationState.api:GetAnimations(inputValue, {
                            "Parry",
                            "GrabParry",
                        }, animationType, swordType)
                    end)
                    if quaternaryValue and type(auxiliaryValue) == "table" and auxiliaryValue[1] then
                        swordAnimationState.cache[secondaryInput] = auxiliaryValue[1]
                        return auxiliaryValue[1]
                    end
                end
                local swordAPI = primaryValue:FindFirstChild("SwordAPI")
                if swordAPI then
                    swordAPI = swordAPI:FindFirstChild("Collection") or swordAPI
                end
                if swordAPI then
                    local quaternaryValue = swordAPI:FindFirstChild(animationType)
                    if quaternaryValue then
                        local auxiliaryValue = swordAnimationState.find(quaternaryValue)
                        if auxiliaryValue then
                            swordAnimationState.cache[secondaryInput] = auxiliaryValue
                            return auxiliaryValue
                        end
                    end
                    local default = swordAPI:FindFirstChild("Default")
                    if default then
                        local auxiliaryValue = swordAnimationState.find(default)
                        if auxiliaryValue then
                            swordAnimationState.cache[secondaryInput] = auxiliaryValue
                            return auxiliaryValue
                        end
                    end
                end
                return nil
            end
            swordAnimationState.grab = function(inputValue)
                local character = localPlayer.Character
                if not character then
                    return false
                end
                local primaryValue = character:FindFirstChildOfClass("Humanoid")
                local animator = primaryValue and primaryValue:FindFirstChildOfClass("Animator")
                if not primaryValue or not animator then
                    return false
                end
                local swordAnimations
                if globalEnvironment and globalEnvironment.skinChangerEnabled and globalEnvironment.swordAnimations then
                    swordAnimations = globalEnvironment.swordAnimations
                else
                    swordAnimations = character:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
                end
                local secondaryValue = swordAnimationState.resolve(character, swordAnimations)
                if not secondaryValue then
                    return false
                end
                local temporaryList = swordAnimationState.tracks[animator]
                if not temporaryList then
                    temporaryList = {
                    }
                    swordAnimationState.tracks[animator] = temporaryList
                end
                local tertiaryValue = temporaryList[secondaryValue]
                if not tertiaryValue or not tertiaryValue.Parent or tertiaryValue.Parent ~= animator then
                    local quaternaryValue
                    quaternaryValue, tertiaryValue = pcall(function()
                        return animator:LoadAnimation(secondaryValue)
                    end)
                    if not quaternaryValue or not tertiaryValue then
                        return false
                    end
                    for k, auxiliaryValue in secondaryValue:GetAttributes() do
                        tertiaryValue:SetAttribute(k, auxiliaryValue)
                    end
                    tertiaryValue:SetAttribute("GrabParry", true)
                    tertiaryValue.Priority = Enum.AnimationPriority.Action4
                    temporaryList[secondaryValue] = tertiaryValue
                end
                if inputValue then
                    local quaternaryValue = tick()
                    if quaternaryValue - swordAnimationState.last_spam < swordAnimationState.cancel_delay then
                        local conditionFlagA = false
                        if swordAnimationState.active then
                            pcall(function()
                                conditionFlagA = swordAnimationState.active.IsPlaying
                            end)
                        end
                        if conditionFlagA then
                            character:SetAttribute("ParryTime", maxValue(character:GetAttribute("ParryTime") or 0, swordAnimationState.active.Length ~= 0 and swordAnimationState.active.Length or 1))
                            return true
                        end
                    end
                    swordAnimationState.last_spam = quaternaryValue
                else
                    swordAnimationState.last_spam = 0
                end
                swordAnimationState.generation = swordAnimationState.generation + 1
                local generation = swordAnimationState.generation
                for _, quaternaryValue in animator:GetPlayingAnimationTracks() do
                    if quaternaryValue:GetAttribute("GrabParry") or quaternaryValue:GetAttribute("Parry") or quaternaryValue:GetAttribute("SuccessParry") then
                        pcall(quaternaryValue.Stop, quaternaryValue, quaternaryValue:GetAttribute("StopFadeTime") or 0.05)
                    end
                end
                local attribute = secondaryValue:GetAttribute("PlayFadeTime") or 0.05
                local attribute2 = secondaryValue:GetAttribute("PlayWeight") or 1
                local attribute3 = secondaryValue:GetAttribute("PlaySpeed") or 1
                tertiaryValue.TimePosition = 0
                tertiaryValue:Play(attribute, attribute2, attribute3)
                swordAnimationState.active = tertiaryValue
                character:SetAttribute("ParryTime", maxValue(character:GetAttribute("ParryTime") or 0, tertiaryValue.Length ~= 0 and (tertiaryValue.Length - tertiaryValue.TimePosition) * attribute3 or 1))
                if inputValue then
                    local cancelDelay = swordAnimationState.cancel_delay
                    local length = tertiaryValue.Length or 0
                    local calculationA
                    if not (length > 0) then
                        calculationA = cancelDelay
                    else
                        calculationA = minValue(cancelDelay, length * swordAnimationState.cancel_fraction)
                    end
                    if calculationA < 0.05 then
                        calculationA = 0.05
                    end
                    local quaternaryValue = tertiaryValue
                    local attribute4 = secondaryValue:GetAttribute("StopFadeTime") or 0.05
                    delayTask(calculationA, function()
                        if generation ~= swordAnimationState.generation or swordAnimationState.active ~= quaternaryValue then
                            return 
                        end
                        pcall(quaternaryValue.Stop, quaternaryValue, attribute4)
                    end)
                end
                return true
            end
                                parryController.fire = function(inputValue)
                                    local currentCamera2 = currentCamera or Workspace.CurrentCamera
                                    if not config.random_target then
                                        local primaryValue = 4096
                                        if true then
                                            local mouseLocation = UserInputService:GetMouseLocation()
                                            primaryValue = mouseLocation
                                        else
                                            while true do

                                            end
                                        end
                                    end
                                    local primaryValue = curveController.get_cframe()
                                    local temporaryList
                                    if mouseEnabled then
                                        local mouseLocation = UserInputService:GetMouseLocation()
                                        temporaryList = {
                                            mouseLocation.X,
                                            mouseLocation.Y,
                                        }
                                    else
                                        local viewportSize = currentCamera2.ViewportSize
                                        temporaryList = {
                                            viewportSize.X * 0.5,
                                            viewportSize.Y * 0.5,
                                        }
                                    end
                                    local temporaryMap = {
                                    }
                                    for _, secondaryValue in alive:GetChildren() do
                                        local primaryPart2 = secondaryValue.PrimaryPart
                                        if primaryPart2 then
                                            local tertiaryValue = currentCamera2:WorldToScreenPoint(primaryPart2.Position)
                                            if tertiaryValue and tertiaryValue.Z > 0 then
                                                temporaryMap[secondaryValue.Name] = tertiaryValue
                                            end
                                        end
                                    end
                                    if next(eventCapture.captured) == nil then
                                        if not parryController.first_signal then
                                            parryController.first_signal = require(packages.Signal).new()
                                            parryController.first_signal:Connect(require(controllers["SwordsController \12"].PRY))
                                        end
                                        parryController.first_signal:Fire(0.5, primaryValue, temporaryMap, temporaryList, false)
                                        if inputValue then
                                            swordAnimationState.grab(true)
                                        end
                                    else
                                        swordAnimationState.grab(inputValue)
                                        for k, secondaryValue in eventCapture.captured, nil, nil do
                                            local parryArguments = {
                                            }
                                            local tertiaryValue = secondaryValue[1]
                                            local quaternaryValue = secondaryValue[2]
                                            local auxiliaryValue = eventCapture.tokenize(secondaryValue[2])
                                            local candidateValue = 0.5
                                            parryArguments[1] = tertiaryValue
                                            parryArguments[2] = quaternaryValue
                                            parryArguments[3] = auxiliaryValue
                                            parryArguments[4] = candidateValue
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
                                    if parryController.count > 7 then
                                        return false
                                    end
                                    parryController.count = parryController.count + 1
                                    delayTask(0.5, function()
                                        if parryController.count > 0 then
                                            parryController.count = parryController.count - 1
                                        end
                                    end)
                                end
                            end
                        end
                        spamController = {
                            distance = 0,
                            last_auto = 0,
                            manual_on = false,
                            manual_key = Enum.KeyCode.E,
                            mobile_button = nil,
                        }
                        do
                            local parryState = {
                                debounce = false,
                                until_at = 0,
                                accuracy = 1.5,
                            }
                            triggerbotState = {
                                on = false,
                                busy = false,
                                key = Enum.KeyCode.T,
                                button = nil,
                            }
                            ballState.curved = function(inputValue)
                                local primaryValue = inputValue or ballState.get()
                                if primaryValue then
                                    local zoomies = primaryValue:FindFirstChild("zoomies")
                                    if not zoomies then
                                        return false
                                    end
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
                                    if magnitude2 < calculationD then
                                        return false
                                    end
                                    if calculationA < calculationB then
                                        return true
                                    end
                                    if ballState.state.LerpRadians < 0.018 then
                                        ballState.state.LastWarping = secondaryValue
                                    end
                                    if secondaryValue - ballState.state.LastWarping < calculationC / 1.5 then
                                        return true
                                    end
                                    if secondaryValue - ballState.state.Curving < calculationC / 1.5 then
                                        return true
                                    end
                                    return quaternaryValue < calculationB
                                end
                                if not (controlValueA >= 3245) then
                                    return false
                                end
                                while true do

                                end
                            end
                            ballState.props = function()
                                local primaryValue = ballState.get()
                                local vector3 = Vector3.zero
                                local unit = (localPlayer.Character.PrimaryPart.Position - ballState.position(primaryValue)).Unit
                                return {
                                    Velocity = vector3,
                                    Direction = unit,
                                    Distance = (localPlayer.Character.PrimaryPart.Position - ballState.position(primaryValue)).Magnitude,
                                    Dot = unit:Dot(vector3.Unit),
                                }
                            end
                            spamController.perform = function(inputValue)
                                local primaryValue = ballState.get()
                                local current = ballState.get()
                                if not primaryValue then
                                    return false
                                end
                                if not current or not current.PrimaryPart then
                                    return false
                                end
                                local assemblyLinearVelocity = primaryValue.AssemblyLinearVelocity
                                local magnitude = assemblyLinearVelocity.Magnitude
                                local secondaryValue = (localPlayer.Character.PrimaryPart.Position - ballState.position(primaryValue)).Unit:Dot(assemblyLinearVelocity.Unit)
                                local tertiaryValue = localPlayer:DistanceFromCharacter(current.PrimaryPart.Position)
                                local calculationA = inputValue.Ping + minValue(magnitude / 6, 95)
                                if inputValue.Entity_Properties.distance > calculationA then
                                    return spamController.distance
                                end
                                if calculationA < inputValue.Ball_Properties.Distance then
                                    return spamController.distance
                                end
                                if calculationA < tertiaryValue then
                                    return spamController.distance
                                end
                                spamController.distance = calculationA - clampValue(secondaryValue, -1, 0) * (5 - minValue(magnitude / 5, 5))
                                return spamController.distance
                            end
                            ballState.bind = function(inputValue)
                                spawnTask(function()
                                    if not inputValue:GetAttribute("realBall") and not inputValue:WaitForChild("zoomies", 3) then
                                        return 
                                    end
                                    inputValue:GetAttributeChangedSignal("target"):Connect(function()
                                        parryState.debounce = false
                                        parryState.until_at = 0
                                        if config.random_target then
                                            inventoryUnlockManager.pick_random()
                                        end
                                    end)
                                end)
                            end
                            balls.ChildAdded:Connect(function()
                                if config.random_target then
                                    local primaryValue = ballState.get()
                                    if primaryValue then
                                        parryState.debounce = false
                                        parryState.until_at = 0
                                    end
                                end
                            end)
                            balls.ChildAdded:Connect(ballState.bind)
                            for _, primaryValue in balls:GetChildren() do
                                ballState.bind(primaryValue)
                            end
                            parryState.check = function()
                                if triggerbotState.busy then
                                    return 
                                end
                                local character = localPlayer.Character
                                character = character and character.PrimaryPart
                                if not character then
                                    return 
                                end
                                local primaryValue = tick()
                                if parryState.debounce or primaryValue < parryState.until_at then
                                    return 
                                end
                                local position = character.Position
                                local secondaryValue = clampValue(dataPing:GetValue() / 10 / 10, 5, 17)
                                local attribute = ballState.get()
                                attribute = attribute and attribute:GetAttribute("target")
                                local tornado = runtime:FindFirstChild("Tornado")
                                local attribute2 = tornado and (tornado:GetAttribute("TornadoTime") or 1)
                                local position2 = ballState.position
                                local curved = ballState.curved
                                for _, tertiaryValue in ballState.get_all() do
                                    if not tertiaryValue then
                                        return 
                                    end
                                    local quaternaryValue = tertiaryValue:FindFirstChild("zoomies")
                                    if not quaternaryValue then
                                        return 
                                    end
                                    local attribute3 = tertiaryValue:GetAttribute("target")
                                    local magnitude = quaternaryValue.VectorVelocity.Magnitude
                                    local magnitude2 = (position - position2(tertiaryValue)).Magnitude
                                    local auxiliaryValue = 0.002
                                    local accuracy = parryState.accuracy
                                    local calculationA = (2.4 + minValue(maxValue(magnitude - 9.5, 0), 650) * auxiliaryValue) * accuracy
                                    if tertiaryValue:FindFirstChild("AeroDynamicSlashVFX") then
                                        Debris:AddItem(tertiaryValue.AeroDynamicSlashVFX, 0)
                                        ballState.state.AerodynamicTime = primaryValue
                                    end
                                    if tornado and primaryValue - ballState.state.AerodynamicTime < attribute2 + 0.314159 then
                                        return 
                                    end
                                    if attribute == name and curved(tertiaryValue) then
                                        return 
                                    end
                                    if attribute3 == name and magnitude2 <= secondaryValue + maxValue(magnitude / calculationA, 9.5) and parryState.accuracy * 0.8 then
                                        parryController.fire()
                                        parryState.debounce = true
                                        parryState.until_at = primaryValue + 1
                                    end
                                end
                            end
                            parryState.set = function(autoParry)
                                config.auto_parry = autoParry
                                if autoParry then
                                    runtimeConnections.auto_parry = postSimulation:Connect(parryState.check)
                                elseif runtimeConnections.auto_parry then
                                    runtimeConnections.auto_parry:Disconnect()
                                    runtimeConnections.auto_parry = nil
                                end
                            end
                            parrySection:AddToggle("AutoParry", { Title = "Auto parry", Default = config.auto_parry or false, Callback = parryState.set })
                            remotes.ParrySuccessAll.OnClientEvent:Connect(function(inputValue, secondaryInput)
                                if secondaryInput.Parent and secondaryInput.Parent ~= localPlayer.Character and secondaryInput.Parent.Parent ~= alive then
                                    return 
                                end
                                local primaryValue = ballState.get()
                                if not primaryValue then
                                    return 
                                end
                                local position = localPlayer.Character.PrimaryPart.Position
                                local magnitude = (position - primaryValue.PrimaryPart.Position).Magnitude
                                local calculationA = position - ballState.position(primaryValue)
                                local magnitude2 = calculationA.Magnitude
                                local secondaryValue = calculationA.Unit:Dot(primaryValue.AssemblyLinearVelocity.Unit)
                                local tertiaryValue = ballState.curved()
                                if magnitude < 15 and magnitude2 < 15 and secondaryValue > -0.25 and tertiaryValue then
                                    parryController.fire()
                                end
                            end)
                            remotes.ParrySuccess.OnClientEvent:Connect(function()
                                local character = localPlayer.Character
                                if not character or not character:IsDescendantOf(Workspace) then
                                    return 
                                end
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                humanoid = humanoid and humanoid:FindFirstChildOfClass("Animator")
                                if not humanoid then
                                    return 
                                end
                                swordAnimationState.generation = swordAnimationState.generation + 1
                                swordAnimationState.last_spam = 0
                                for _, primaryValue in humanoid:GetPlayingAnimationTracks() do
                                    if primaryValue:GetAttribute("GrabParry") or primaryValue:GetAttribute("Parry") then
                                        primaryValue:Stop(primaryValue:GetAttribute("StopFadeTime"))
                                    end
                                end
                            end)
                            balls.ChildAdded:Connect(function()
                                parryState.debounce = false
                                parryState.until_at = 0
                            end)
                            balls.ChildRemoved:Connect(function(child)
                                ballState.positions[child] = nil
                                parryController.count = 0
                                parryState.debounce = false
                                parryState.until_at = 0
                                if runtimeConnections.target_change then
                                    runtimeConnections.target_change:Disconnect()
                                    runtimeConnections.target_change = nil
                                end
                            end)
                            remotes.ParrySuccessAll.OnClientEvent:Connect(function(inputValue, secondaryInput)
                                local position = localPlayer.Character.PrimaryPart.Position
                                local primaryValue = ballState.get()
                                if not primaryValue then
                                    return 
                                end
                                local zoomies = primaryValue:FindFirstChild("zoomies")
                                if not zoomies then
                                    return 
                                end
                                local magnitude = zoomies.VectorVelocity.Magnitude
                                local magnitude2 = (position - ballState.position(primaryValue)).Magnitude
                                local value = dataPing:GetValue()
                                local calculationA = magnitude2 / magnitude - value / 1000
                                local calculationB = 15 - minValue(magnitude2 / 1000, 15) + minValue(magnitude / 100, 40)
                                if magnitude > 100 and calculationA > value / 10 then
                                    calculationB = maxValue(calculationB - 15, 15)
                                end
                                if secondaryInput ~= localPlayer.Character.PrimaryPart and magnitude2 > calculationB then
                                    ballState.state.Curving = tick()
                                end
                            end)
                            parrySection:AddSlider("Accuracy", { Title = "Accuracy", Min = 1, Max = 100, Default = config.accuracy or 100, Rounding = 1, Callback = function(accuracy)
                                parryState.accuracy = (accuracy - 1) * 0.015151515151515152
                                config.accuracy = accuracy
                            end })
                            parryState.accuracy = (config.accuracy - 1) * 0.015151515151515152
                        end
                        parrySection:AddToggle("RandomTarget", { Title = "Random target", Default = config.random_target or false, Callback = function(randomTarget)
                            spawnTask(function()
                                config.random_target = randomTarget
                                if randomTarget then
                                    parryState.debounce = false
                                    parryState.until_at = 0
                                end
                            end)
                        end })
                        curveController.hotkeys = {
                            [Enum.KeyCode.One] = "camera",
                            [Enum.KeyCode.Two] = "dot",
                            [Enum.KeyCode.Three] = "backwards",
                            [Enum.KeyCode.Four] = "slow",
                            [Enum.KeyCode.Five] = "random",
                        }
                        curveController.dropdown = curve:AddDropdown("CurveMethod", {
                            Title = "Curve method",
                            Values = curveMethods,
                            Multi = false,
                            Default = config.curve_method or "camera",
                            Callback = function(curveMethod)
                            local syncing = curveController.syncing
                            spawnTask(function()
                                local primaryValue = syncing
                                local conditionFlagA
                                if syncing then
                                    conditionFlagA = primaryValue
                                else
                                    conditionFlagA = config.curve_method == curveMethod
                                end
                                if conditionFlagA then
                                    if config.curve_notify and not syncing then
                                        notificationService:notify({
                                            title = "curve method",
                                            content = "already " .. curveMethod,
                                            duration = 3,
                                        })
                                    end
                                    return 
                                end
                                config.curve_method = curveMethod
                                if config.curve_notify then
                                    notificationService:notify({
                                        title = "curve method",
                                        content = "curve method is now " .. curveMethod,
                                        duration = 3,
                                    })
                                end
                            end)
                        end })
                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed or not config.curve_keybind then
                                return 
                            end
                            local primaryValue = curveController.hotkeys[input.KeyCode]
                            if not primaryValue then
                                return 
                            end
                            if config.curve_method == primaryValue then
                                if config.curve_notify then
                                    notificationService:notify({
                                        title = "curve method",
                                        content = ("already ") .. primaryValue,
                                        duration = 3,
                                    })
                                end
                                return 
                            end
                            config.curve_method = primaryValue
                            curveController.sync_dropdown(primaryValue)
                            if config.curve_notify then
                                notificationService:notify({
                                    title = "curve method",
                                    content = "curve method is now " .. primaryValue,
                                    duration = 3,
                                })
                            end
                        end)
                        hotkeys:AddToggle("hotkey_curve", { Title = "Hotkey curve", Default = config.curve_keybind or false, Callback = function(curveKeybind)
                            spawnTask(function()
                                config.curve_keybind = curveKeybind
                            end)
                        end })
                        hotkeys:AddToggle("hotkey_notify", { Title = "Hotkey notify", Default = config.curve_notify or false, Callback = function(curveNotify)
                            spawnTask(function()
                                config.curve_notify = curveNotify
                            end)
                        end })
                        triggerbotState.fire = function(inputValue)
                            if triggerbotState.busy then
                                return 
                            end
                            triggerbotState.busy = true
                            parryController.fire()
                            inputValue:GetAttributeChangedSignal("target"):Once(function()
                                triggerbotState.busy = false
                            end)
                            local primaryValue = tick()
                            spawnTask(function()
                                while true do
                                    preSimulation:Wait()
                                    if not (tick() - primaryValue >= 1 or not triggerbotState.busy) then
                                        continue
                                    end
                                    break
                                end
                                triggerbotState.busy = false
                            end)
                        end
                        triggerbotState.update_button = function()
                            if triggerbotState.button then
                                triggerbotState.button.Text = triggerbotState.on and "triggerbot [on]" or "triggerbot [off]"
                            end
                        end
                        triggerbotState.set = function(inputValue)
                            local on = inputValue == true
                            if triggerbotState.on == on then
                                triggerbotState.update_button()
                                return 
                            end
                            triggerbotState.on = on
                            _G.triggerbot = on
                            notificationService:notify({
                                title = "triggerbot",
                                content = on and "on" or "off",
                                duration = 2,
                            })
                            if on then
                                runtimeConnections.triggerbot = preSimulation:Connect(function()
                                    local primaryValue = ballState.get()
                                    if primaryValue and primaryValue:GetAttribute("target") == name then
                                        triggerbotState.fire(primaryValue)
                                    end
                                end)
                            elseif runtimeConnections.triggerbot then
                                runtimeConnections.triggerbot:Disconnect()
                                runtimeConnections.triggerbot = nil
                            end
                            triggerbotState.update_button()
                        end
                        if touchEnabled then
                            hotkeys:AddToggle("triggerbot_button", { Title = "Triggerbot button", Default = config.mobile_triggerbot_button or false, Callback = function(mobileTriggerbotButton)
                                config.mobile_triggerbot_button = mobileTriggerbotButton
                                if triggerbotState.button then
                                    triggerbotState.button.Visible = mobileTriggerbotButton
                                end
                                if not mobileTriggerbotButton then
                                    triggerbotState.set(false)
                                end
                            end })
                        end
                        spamController.auto_check = function()
                            local primaryValue = ballState.get()
                            if not primaryValue then
                                return 
                            end
                            if not primaryValue:FindFirstChild("zoomies") then
                                return 
                            end
                            if not primaryValue.PrimaryPart then
                                return 
                            end
                            local secondaryValue = tick()
                            local tertiaryValue = 1
                            local quaternaryValue = 16
                            local auxiliaryValue = spamController.perform({
                                Ball_Properties = ballState.props(),
                                Entity_Properties = {
                                    distance = localPlayer:DistanceFromCharacter(primaryValue.PrimaryPart.Position),
                                },
                                Ping = clampValue(dataPing:GetValue() / 10, tertiaryValue, quaternaryValue),
                            })
                            local character = localPlayer.Character
                            local primaryPart = character and character.PrimaryPart
                            if not primaryPart then
                                return 
                            end
                            local magnitude = (primaryPart.Position - ballState.position(primaryValue)).Magnitude
                            local attribute = primaryValue:GetAttribute("target")
                            if not attribute then
                                return 
                            end
                            local candidateValue = localPlayer:DistanceFromCharacter(primaryValue.PrimaryPart.Position)
                            if candidateValue > auxiliaryValue or magnitude > auxiliaryValue then
                                return 
                            end
                            if character:GetAttribute("Pulsed") then
                                return 
                            end
                            if attribute == name and candidateValue > 30 and magnitude > 30 then
                                return 
                            end
                            if magnitude <= auxiliaryValue and parryController.count > config.spam_threshold and secondaryValue - spamController.last_auto >= 0.001 then
                                spamController.last_auto = secondaryValue
                                parryController.fire(true)
                            end
                        end
                        spamController.set_auto = function(autoSpam)
                            config.auto_spam = autoSpam
                            if autoSpam then
                                runtimeConnections.auto_spam = preSimulation:Connect(spamController.auto_check)
                            elseif runtimeConnections.auto_spam then
                                runtimeConnections.auto_spam:Disconnect()
                                runtimeConnections.auto_spam = nil
                            end
                        end
                        spam:AddToggle("AutoSpam", { Title = "Auto spam", Default = config.auto_spam or false, Callback = spamController.set_auto })
                        spam:AddSlider("Threshold", { Title = "Threshold", Min = 1, Max = 3, Default = config.spam_threshold or 3, Rounding = 1, Callback = function(inputValue)
                            spawnTask(function()
                                if true then
                                    config.spam_threshold = tonumber(inputValue)
                                else
                                    while true do

                                    end
                                end
                            end)
                        end })
                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then
                                return 
                            end
                            if input.KeyCode == Enum.KeyCode.E then
                                _G.manual_spam = not _G.manual_spam
                            end
                        end)
                        if type(config.manual_spam) == "string" and Enum.KeyCode[config.manual_spam] then
                            spamController.manual_key = Enum.KeyCode[config.manual_spam]
                        end
                        spamController.update_button = function()
                            if spamController.mobile_button then
                                spamController.mobile_button.Text = spamController.manual_on and "manual spam [on]" or "manual spam [off]"
                            end
                        end
                        spamController.set_manual = function(inputValue)
                            local manualOn = inputValue == true
                            if spamController.manual_on == manualOn then
                                spamController.update_button()
                                return 
                            end
                            spamController.manual_on = manualOn
                            if runtimeConnections.manual_spam then
                                runtimeConnections.manual_spam:Disconnect()
                                runtimeConnections.manual_spam = nil
                            end
                            if manualOn then
                                local primaryValue = 0
                                runtimeConnections.manual_spam = preSimulation:Connect(function()
                                    local secondaryValue = tick()
                                    if secondaryValue - primaryValue < 0.001 then
                                        return 
                                    end
                                    primaryValue = secondaryValue
                                    parryController.fire(true)
                                end)
                            end
                            spamController.update_button()
                            if config.manual_notify then
                                notificationService:notify({
                                    title = "manual spam",
                                    content = manualOn and "on" or "off",
                                    duration = 4,
                                })
                            end
                        end
                    end
                    do
                        if touchEnabled then
                            hotkeys:AddToggle("manual_spam_button", { Title = "Manual spam button", Default = config.mobile_manual_spam_button or false, Callback = function(mobileManualSpamButton)
                                config.mobile_manual_spam_button = mobileManualSpamButton
                                if spamController.mobile_button then
                                    spamController.mobile_button.Visible = mobileManualSpamButton
                                end
                                if not mobileManualSpamButton then
                                    spamController.set_manual(false)
                                end
                            end })
                        end
                        do
                            local conditionFlagA = false
                            local function helperFunction()
                                if conditionFlagA or not keyboardEnabled and not gamepadEnabled then
                                    return 
                                end
                                conditionFlagA = true
                                hotkeys:AddKeybind("TriggerbotKey", {
                                    Title = "Triggerbot key",
                                    Default = triggerbotState.key.Name,
                                    Mode = "Toggle",
                                    ChangedCallback = function(key)
                                        if key ~= triggerbotState.key then
                                            triggerbotState.key = key
                                        end
                                    end,
                                })
                                hotkeys:AddKeybind("ManualSpamKey", {
                                    Title = "Manual spam key",
                                    Default = spamController.manual_key.Name,
                                    Mode = "Toggle",
                                    ChangedCallback = function(manualKey)
                                        if manualKey ~= spamController.manual_key then
                                            spamController.manual_key = manualKey
                                            config.manual_spam = manualKey.Name
                                        end
                                    end,
                                })
                            end
                            helperFunction()
                            UserInputService.GamepadConnected:Connect(function()
                                gamepadEnabled = true
                                helperFunction()
                            end)
                            UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(function()
                                keyboardEnabled = UserInputService.KeyboardEnabled
                                helperFunction()
                            end)
                            UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(function()
                                gamepadEnabled = UserInputService.GamepadEnabled
                                helperFunction()
                            end)
                        end
                    end
                    do
                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then
                                return 
                            end
                            if input.KeyCode == triggerbotState.key then
                                triggerbotState.set(not triggerbotState.on)
                            end
                            if input.KeyCode == spamController.manual_key then
                                spamController.set_manual(not spamController.manual_on)
                            end
                        end)
                        if touchEnabled then
                            do
                                local ScreenGui = createGuiInstance("ScreenGui", {
                                    Name = "oxy_mobile",
                                    ResetOnSpawn = false,
                                    IgnoreGuiInset = true,
                                    DisplayOrder = 50,
                                    Parent = localPlayer:WaitForChild("PlayerGui"),
                                })
                                local function helperFunction(inputValue, secondaryInput, tertiaryInput)
                                    local primaryValue = createGuiInstance("TextButton", {
                                        Name = inputValue,
                                        AnchorPoint = createVector2(1, 0.5),
                                        Position = secondaryInput,
                                        Size = fromOffset(130, 44),
                                        BackgroundColor3 = colorFromRGB(22, 22, 22),
                                        BorderSizePixel = 0,
                                        AutoButtonColor = false,
                                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                                        TextColor3 = colorFromRGB(255, 255, 255),
                                        TextSize = 16,
                                        TextWrapped = false,
                                        ZIndex = 2,
                                        Parent = ScreenGui,
                                    })
                                    createGuiInstance("UICorner", {
                                        CornerRadius = createUDim(0, 8),
                                        Parent = primaryValue,
                                    })
                                    createGuiInstance("UIStroke", {
                                        Color = colorFromRGB(35, 35, 35),
                                        Thickness = 1,
                                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                        Parent = primaryValue,
                                    })
                                    local conditionFlagA = false
                                    local conditionFlagB = false
                                    local secondaryValue = nil
                                    local position = nil
                                    local position2 = nil
                                    primaryValue.InputBegan:Connect(function(input)
                                        local userInputType = input.UserInputType
                                        if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 then
                                            return 
                                        end
                                        conditionFlagA = true
                                        conditionFlagB = false
                                        secondaryValue = input
                                        position = input.Position
                                        position2 = primaryValue.Position
                                    end)
                                    UserInputService.InputChanged:Connect(function(input)
                                        if not conditionFlagA or input ~= secondaryValue and input.UserInputType ~= Enum.UserInputType.MouseMovement then
                                            return 
                                        end
                                        local calculationA = input.Position - position
                                        if not (controlValueB > 1424) then
                                            if calculationA.Magnitude > 4 then
                                                conditionFlagB = true
                                            end
                                            primaryValue.Position = createUDim2(position2.X.Scale, position2.X.Offset + calculationA.X, position2.Y.Scale, position2.Y.Offset + calculationA.Y)
                                            return 
                                        end
                                        while true do

                                        end
                                    end)
                                    UserInputService.InputEnded:Connect(function(input)
                                        if input == secondaryValue then
                                            conditionFlagA = false
                                            secondaryValue = nil
                                        end
                                    end)
                                    primaryValue.MouseButton1Click:Connect(function()
                                        if conditionFlagB then
                                            conditionFlagB = false
                                            return 
                                        end
                                        tertiaryInput()
                                        primaryValue.BackgroundColor3 = colorFromRGB(40, 40, 40)
                                        createTween(TweenService, primaryValue, createTweenInfo(0.2), {
                                            BackgroundColor3 = colorFromRGB(22, 22, 22),
                                        }):Play()
                                    end)
                                    return primaryValue
                                end
                                triggerbotState.button = helperFunction("Triggerbot", createUDim2(1, -280, 0.5, 0), function()
                                    triggerbotState.set(not triggerbotState.on)
                                end)
                                triggerbotState.button.Visible = config.mobile_triggerbot_button
                                spamController.mobile_button = helperFunction("ManualSpam", createUDim2(1, -140, 0.5, 0), function()
                                    spamController.set_manual(not spamController.manual_on)
                                end)
                            end
                            spamController.mobile_button.Visible = config.mobile_manual_spam_button
                            triggerbotState.update_button()
                            spamController.update_button()
                        end
                        spam:AddToggle("manual_notify", { Title = "Manual notify", Default = config.manual_notify or false, Callback = function(manualNotify)
                            config.manual_notify = manualNotify
                        end })
                    end
                    return 
                end
                while true do

                end
            end
        end
    end
end
