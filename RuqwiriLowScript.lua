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
                                        manual_notify = false,
                                        manual_spam = "E",
                                        mobile_triggerbot_button = false,
                                        mobile_manual_spam_button = false,
                                        ability_esp = false,
                                        auto_parry = false,
                                        ball_debug = false,
                                        last_equipped_sword = "",
                                        favorite_swords = {
                                        },
                                    }
                                    configStorage.path = configStorage.folder .. "/config.json"
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
                                Title = "Ruqwiri [LOW]",
                                TabWidth = 145,
                                Size = UDim2.fromOffset(440, 315),
                                Acrylic = false,
                                Theme = "Dark",
                                MinimizeKey = Enum.KeyCode.LeftControl,
                            })
                            do
                                local combat = oxy:AddTab({ Title = "Combat", Icon = "swords" })
                                local combatSection = combat:AddSection("")
                                parrySection = combatSection
                                spam = combatSection
                                hotkeys = combatSection
                            end
                        end
                        notificationService = {
                            notify = function(_, notification)
                                Fluent:Notify({
                                    Title = notification.title,
                                    Content = notification.content,
                                    Duration = notification.duration,
                                })
                            end,
                        }
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
                        local runtimeConnections, ballState, touchEnabled, keyboardEnabled, gamepadEnabled, spamController, abilityEspState, triggerbotState
                        do
                            local curveController, swordAnimationState, parryController, helperFunction
                            do
                                local eventCapture
                                do
                                    runtimeConnections = {
                                    }
                                    curveController = {
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
                                        if type(primaryValue) ~= "function" or not debug.info(primaryValue, "s"):find("PRY", 1, true) then
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
                                do
                                    parrySection:AddToggle("AutoParry", {
                                        Title = "Auto Parry",
                                        Default = config.auto_parry,
                                        Callback = function(inputValue)
                                            config.auto_parry = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddSlider("Accuracy", {
                                        Title = "Accuracy",
                                        Default = config.accuracy,
                                        Min = 1,
                                        Max = 100,
                                        Rounding = 0,
                                        Callback = function(inputValue)
                                            config.accuracy = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddToggle("HockeyNotify", {
                                        Title = "Hockey Notify",
                                        Default = config.manual_notify,
                                        Callback = function(inputValue)
                                            config.manual_notify = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddToggle("TriggerBotButton", {
                                        Title = "TriggerBot button",
                                        Default = config.mobile_triggerbot_button,
                                        Callback = function(inputValue)
                                            config.mobile_triggerbot_button = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddToggle("ManualSpamButton", {
                                        Title = "Manual spam button",
                                        Default = config.mobile_manual_spam_button,
                                        Callback = function(inputValue)
                                            config.mobile_manual_spam_button = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddToggle("BallStats", {
                                        Title = "Ball Stats",
                                        Default = config.ball_debug,
                                        Callback = function(inputValue)
                                            config.ball_debug = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                    parrySection:AddToggle("AbilityESP", {
                                        Title = "Ability ESP",
                                        Default = config.ability_esp,
                                        Callback = function(inputValue)
                                            config.ability_esp = inputValue
                                            configStorage.save()
                                        end,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
