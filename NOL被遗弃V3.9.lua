


local repo = 'https://raw.githubusercontent.com/SyndromeXph/NOL-Obsidian/refs/heads/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ShowToggleFrameInKeybinds = true 
Library.ShowCustomCursor = true
Library.NotifySide = "Right"
local ErrorMessageOut



local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

local ESPSettings = {
    killerESP = false,
    playerESP = false,
    generatorESP = false,
    itemESP = false,
    pizzaEsp = false,
    pizzaDeliveryEsp = false,
    zombieEsp = false,
    taphTripwireEsp = false,
    tripMineEsp = false,
    twoTimeRespawnEsp = false,
    killerTracers = false,
    survivorTracers = false,
    generatorTracers = false,
    itemTracers = false,
    pizzaTracers = false,
    pizzaDeliveryTracers = false,
    zombieTracers = false,
    killerSkinESP = false,
    survivorSkinESP = false,
    killerFillTransparency = 0.7,
    killerOutlineTransparency = 0.3,
    survivorFillTransparency = 0.7,
    survivorOutlineTransparency = 0.3,
    killerColor = Color3.fromRGB(255, 100, 100),
    survivorColor = Color3.fromRGB(100, 255, 100),
    generatorColor = Color3.fromRGB(255, 100, 255),
    itemColor = Color3.fromRGB(100, 200, 255),
    pizzaColor = Color3.fromRGB(255, 200, 0),
    pizzaDeliveryColor = Color3.fromRGB(255, 150, 0),
    zombieColor = Color3.fromRGB(0, 255, 0),
    tripwireColor = Color3.fromRGB(255, 0, 0),
    tripMineColor = Color3.fromRGB(255, 50, 50),
    respawnColor = Color3.fromRGB(0, 255, 255),
    maxDistance = 300, -- 最大绘制距离
    maxESPCount = 50, -- 最大ESP数量限制
}

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2",
}

local PlayerESPData = {}
local ObjectESPData = {}
local TracerData = {}
local ESPCache = {} -- 缓存已处理的模型，避免重复检查
local lastCleanupTime = 0

local function IsRagdoll(model)
    local ragdolls = Services.Workspace:FindFirstChild("Ragdolls")
    if not ragdolls then return false end
    return model:IsDescendantOf(ragdolls) or (model.Parent == ragdolls)
end

local function IsSpectating(player)
    if not player then return false end
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    local spectating = playersFolder:FindFirstChild("Spectating")
    if not spectating then return false end
    return spectating:FindFirstChild(player.Name) ~= nil
end

local function GetGeneratorPart(model)
    if not model then return nil end
    local instances = model:FindFirstChild("Instances")
    if instances then
        local generator = instances:FindFirstChild("Generator")
        if generator then
            local cube = generator:FindFirstChild("Cube.003")
            if cube and cube:IsA("BasePart") then return cube end
            for _, v in ipairs(generator:GetDescendants()) do
                if v:IsA("BasePart") then return v end
            end
        end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local function UpdatePlayerBillboardText(data)
    if not data or not data.model or not data.nameLabel then return end
    
    local model = data.model
    local isKiller = data.isKiller
    
    -- 获取角色名称和皮肤名称
    local actorText = model:GetAttribute("ActorDisplayName") or (isKiller and "杀手" or "幸存者")
    local skinText = model:GetAttribute("SkinNameDisplay")
    
    -- 检测假Noli
    if actorText == "Noli" and model:GetAttribute("IsFakeNoli") == true then
        actorText = actorText .. " (Fake)"
    end
    
    local displayText = actorText
    
    -- 如果启用了皮肤ESP，添加皮肤名称
    local showSkin = (isKiller and ESPSettings.killerSkinESP) or (not isKiller and ESPSettings.survivorSkinESP)
    if showSkin and skinText and tostring(skinText) ~= "" then
        displayText = displayText .. " | " .. skinText
    end
    
    -- 更新名称标签
    data.nameLabel.Text = displayText
    
    -- 更新血量
    if data.hpLabel then
        local humanoid = model:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local maxhp = math.floor(humanoid.MaxHealth)
            data.hpLabel.Text = string.format("HP: %d/%d", hp, maxhp)
        end
    end
    
    -- 更新高亮透明度
    local highlight = model:FindFirstChild("TAOWARE_Highlight")
    if highlight then
        if isKiller then
            highlight.FillTransparency = ESPSettings.killerFillTransparency
            highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
        else
            highlight.FillTransparency = ESPSettings.survivorFillTransparency
            highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
        end
    end
end

local function UpdateGeneratorProgress(data)
    if not data or not data.model or not data.progressLabel then return end
    
    local model = data.model
    local progress = model:FindFirstChild("Progress")
    
    if progress then
        local progressValue = math.floor(progress.Value)
        data.progressLabel.Text = string.format("进度: %d%%", progressValue)
    end
end

local function CreateESP(model, color, isGenerator, isItem, isPizza, isPizzaDelivery, isZombie, isTripwire, isTripMine, isRespawn, isKiller)
    if not model then return end
    if model:FindFirstChild("TAOWARE_Highlight") then return end
    if isGenerator and model:FindFirstChild("Progress") and model.Progress.Value == 100 then return end
    if IsRagdoll(model) then return end

    local targetPart
    if isGenerator then
        targetPart = GetGeneratorPart(model)
    elseif isItem then
        targetPart = model:FindFirstChild("ItemRoot")
    elseif isPizza or isPizzaDelivery or isZombie or isTripwire or isTripMine or isRespawn then
        targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    else
        targetPart = model:FindFirstChild("HumanoidRootPart")
    end

    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TAOWARE_Highlight"
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.OutlineColor = color
    
    -- 根据类型设置透明度
    if isKiller then
        highlight.FillTransparency = ESPSettings.killerFillTransparency
        highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
    elseif not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTripwire and not isTripMine and not isRespawn then
        -- 幸存者
        highlight.FillTransparency = ESPSettings.survivorFillTransparency
        highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
    else
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
    end
    
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TAOWARE_Billboard"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    if not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTripwire and not isTripMine and not isRespawn then
        -- 玩家ESP（杀手或幸存者）
        local humanoid = model:FindFirstChild("Humanoid")
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Loading..."
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 8
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.Parent = billboard

        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.33, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.3, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.Text = "HP: " .. (humanoid and string.format("%.0f", humanoid.Health) or "N/A")
        hpLabel.Font = Enum.Font.GothamBlack
        hpLabel.TextColor3 = color
        hpLabel.TextSize = 8
        hpLabel.TextStrokeTransparency = 0.6
        hpLabel.Parent = billboard

        local espData = {
            model = model, 
            nameLabel = nameLabel, 
            hpLabel = hpLabel, 
            color = color,
            isKiller = isKiller
        }
        
        table.insert(PlayerESPData, espData)
        
        -- 立即更新一次文本
        UpdatePlayerBillboardText(espData)
        
        -- 监听属性变化
        model:GetAttributeChangedSignal("ActorDisplayName"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        model:GetAttributeChangedSignal("SkinNameDisplay"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        model:GetAttributeChangedSignal("IsFakeNoli"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        -- 监听血量变化
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                UpdatePlayerBillboardText(espData)
            end)
            humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                UpdatePlayerBillboardText(espData)
            end)
        end
    elseif isGenerator then
        -- 发电机ESP - 显示名称和进度
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "发电机"
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 8
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.Parent = billboard
        
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Size = UDim2.new(1, 0, 0.5, 0)
        progressLabel.Position = UDim2.new(0, 0, 0.5, 0)
        progressLabel.BackgroundTransparency = 1
        progressLabel.Text = "进度: 0%"
        progressLabel.Font = Enum.Font.GothamBlack
        progressLabel.TextColor3 = color
        progressLabel.TextSize = 8
        progressLabel.TextStrokeTransparency = 0.6
        progressLabel.Parent = billboard
        
        local espData = {
            model = model,
            nameLabel = nameLabel,
            progressLabel = progressLabel,
            highlight = highlight,
            billboard = billboard
        }
        
        table.insert(ObjectESPData, espData)
        
        -- 立即更新一次进度
        UpdateGeneratorProgress(espData)
        
        -- 监听进度变化
        local progress = model:FindFirstChild("Progress")
        if progress then
            progress:GetPropertyChangedSignal("Value"):Connect(function()
                UpdateGeneratorProgress(espData)
            end)
        end
    else
        local displayName = model.Name
        if isPizzaDelivery then displayName = "Pizza Delivery" end
        if isZombie then displayName = "Zombie" end
        if isTripwire then displayName = "Tripwire" end
        if isTripMine then displayName = "Trip Mine" end
        if isRespawn then displayName = "Respawn" end
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = displayName
        textLabel.Font = Enum.Font.GothamBlack
        textLabel.TextColor3 = color
        textLabel.TextSize = 8
        textLabel.TextStrokeTransparency = 0.6
        textLabel.Parent = billboard

        table.insert(ObjectESPData, {model = model, highlight = highlight, billboard = billboard})
    end
end

local function RemoveESP(model)
    if not model then return end
    ESPCache[model] = nil
    for i = #PlayerESPData, 1, -1 do
        if PlayerESPData[i].model == model then
            table.remove(PlayerESPData, i)
        end
    end
    for i = #ObjectESPData, 1, -1 do
        if ObjectESPData[i].model == model then
            table.remove(ObjectESPData, i)
        end
    end
    pcall(function()
        local highlight = model:FindFirstChild("TAOWARE_Highlight")
        if highlight then
            highlight:Destroy()
        end
        local billboard = model:FindFirstChild("TAOWARE_Billboard")
        if billboard then
            billboard:Destroy()
        end
    end)
end

local function CreateTracer(model, part, color)
    if not model or not part or not part:IsA("BasePart") then return end
    if TracerData[model] then return end

    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = color or Color3.fromRGB(255, 255, 255)
    line.Thickness = 2
    line.Transparency = 1

    TracerData[model] = {line = line, part = part}
end

local function RemoveTracer(model)
    if TracerData[model] then
        pcall(function()
            TracerData[model].line.Visible = false
            TracerData[model].line:Remove()
        end)
        TracerData[model] = nil
    end
end

local function UpdateTracers()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, 0)
    local cameraPos = Camera.CFrame.Position
    local maxDist = ESPSettings.maxDistance or 300
    
    for model, data in pairs(TracerData) do
        local line = data.line
        local part = data.part
        if line and part and part.Parent and part.Parent.Parent then
            local partPos = part.Position
            local distance = (partPos - cameraPos).Magnitude
            if distance > maxDist then
                line.Visible = false
            else
                local pos, onScreen = Camera:WorldToViewportPoint(partPos)
                if onScreen then
                    line.Visible = true
                    line.From = screenCenter
                    line.To = Vector2.new(pos.X, pos.Y)
                else
                    line.Visible = false
                end
            end
        else
            RemoveTracer(model)
        end
    end
end

-- Noli假人检测系统
local noliByUsername = {}
local function clearFakeTags()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            killer:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function scanNolis()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    
    noliByUsername = {}
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            local username = killer:GetAttribute("Username")
            if username then
                if not noliByUsername[username] then
                    noliByUsername[username] = {}
                end
                table.insert(noliByUsername[username], killer)
            end
        end
    end
    for username, models in pairs(noliByUsername) do
        if #models > 1 then
            for i = 2, #models do
                models[i]:SetAttribute("IsFakeNoli", true)
            end
            models[1]:SetAttribute("IsFakeNoli", false)
        else
            models[1]:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function updateFakeNolis()
    clearFakeTags()
    scanNolis()
end

-- 更新所有玩家ESP文本（用于皮肤ESP切换和透明度调节）
local function UpdateAllPlayerESPText()
    for _, data in ipairs(PlayerESPData) do
        UpdatePlayerBillboardText(data)
    end
end

local function UpdateESP()
    local mapFolder = Services.Workspace:FindFirstChild("Map")
    if not mapFolder or not mapFolder:FindFirstChild("Ingame") then
        for i = #PlayerESPData, 1, -1 do
            RemoveESP(PlayerESPData[i].model)
        end
        for i = #ObjectESPData, 1, -1 do
            RemoveESP(ObjectESPData[i].model)
        end
        for model in pairs(TracerData) do
            RemoveTracer(model)
        end
        return
    end

    local ingame = mapFolder.Ingame
    local cameraPos = Camera.CFrame.Position
    local maxDistance = ESPSettings.maxDistance or 300
    local maxDistanceSq = maxDistance * maxDistance
    local currentESPCount = #PlayerESPData + #ObjectESPData
    local maxESPCount = ESPSettings.maxESPCount or 50

    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            for _, killer in ipairs(killers:GetChildren()) do
                if killer == LocalPlayer.Character then continue end
                if IsRagdoll(killer) then
                    RemoveESP(killer)
                    RemoveTracer(killer)
                    continue
                end
                local player = Services.Players:GetPlayerFromCharacter(killer)
                if not player or IsSpectating(player) then
                    RemoveESP(killer)
                    RemoveTracer(killer)
                    continue
                end

                local hrp = killer:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distanceSq = (hrp.Position - cameraPos).Magnitude ^ 2
                    if distanceSq > maxDistanceSq then
                        RemoveESP(killer)
                        RemoveTracer(killer)
                        continue
                    end
                    
                    if ESPSettings.killerESP and not killer:FindFirstChild("TAOWARE_Highlight") then
                        if currentESPCount < maxESPCount then
                            CreateESP(killer, ESPSettings.killerColor, false, false, false, false, false, false, false, false, true)
                            currentESPCount = currentESPCount + 1
                        end
                    elseif not ESPSettings.killerESP then
                        RemoveESP(killer)
                    end

                    if ESPSettings.killerTracers then
                        CreateTracer(killer, hrp, ESPSettings.killerColor)
                    else
                        RemoveTracer(killer)
                    end
                else
                    RemoveESP(killer)
                    RemoveTracer(killer)
                end
            end
        end

        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in ipairs(survivors:GetChildren()) do
                if survivor == LocalPlayer.Character then continue end
                if IsRagdoll(survivor) then
                    RemoveESP(survivor)
                    RemoveTracer(survivor)
                    continue
                end
                local player = Services.Players:GetPlayerFromCharacter(survivor)
                if not player or IsSpectating(player) then
                    RemoveESP(survivor)
                    RemoveTracer(survivor)
                    continue
                end

                local hrp = survivor:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distanceSq = (hrp.Position - cameraPos).Magnitude ^ 2
                    if distanceSq > maxDistanceSq then
                        RemoveESP(survivor)
                        RemoveTracer(survivor)
                        continue
                    end
                    
                    if ESPSettings.playerESP and not survivor:FindFirstChild("TAOWARE_Highlight") then
                        if currentESPCount < maxESPCount then
                            CreateESP(survivor, ESPSettings.survivorColor, false, false, false, false, false, false, false, false, false)
                            currentESPCount = currentESPCount + 1
                        end
                    elseif not ESPSettings.playerESP then
                        RemoveESP(survivor)
                    end

                    if ESPSettings.survivorTracers then
                        CreateTracer(survivor, hrp, ESPSettings.survivorColor)
                    else
                        RemoveTracer(survivor)
                    end
                else
                    RemoveESP(survivor)
                    RemoveTracer(survivor)
                end
            end
        end
    end

    local mapFolder = ingame:FindFirstChild("Map")
    if mapFolder then
        -- Generators ESP - 只检查直接子对象，不使用GetDescendants
        for _, gen in ipairs(mapFolder:GetChildren()) do
            if gen:IsA("Model") and gen.Name:lower():find("generator") and gen.Name ~= "FakeGenerator" then
                if IsRagdoll(gen) then
                    RemoveESP(gen)
                    RemoveTracer(gen)
                    continue
                end
                
                local genPart = GetGeneratorPart(gen)
                if genPart then
                    local distanceSq = (genPart.Position - cameraPos).Magnitude ^ 2
                    if distanceSq > maxDistanceSq then
                        RemoveESP(gen)
                        RemoveTracer(gen)
                        continue
                    end
                end
                
                local progress = gen:FindFirstChild("Progress")
                if ESPSettings.generatorESP and progress and progress.Value < 100 and not gen:FindFirstChild("TAOWARE_Highlight") then
                    if currentESPCount < maxESPCount then
                        CreateESP(gen, ESPSettings.generatorColor, true, false, false, false, false, false, false, false)
                        currentESPCount = currentESPCount + 1
                    end
                elseif (not ESPSettings.generatorESP or (progress and progress.Value >= 100)) then
                    RemoveESP(gen)
                end

                if ESPSettings.generatorTracers and progress and progress.Value < 100 then
                    local part = GetGeneratorPart(gen)
                    if part then
                        CreateTracer(gen, part, ESPSettings.generatorColor)
                    end
                else
                    RemoveTracer(gen)
                end
            end
        end
        
        -- Items ESP - 优化：使用缓存避免重复遍历，只遍历一级子对象
        if ESPSettings.itemESP or ESPSettings.itemTracers then
            local currentTime = tick()
            if currentTime - lastCleanupTime > 2 then -- 每2秒清理一次缓存
                for model in pairs(ESPCache) do
                    if not model.Parent or not model:FindFirstChild("ItemRoot") then
                        ESPCache[model] = nil
                    end
                end
                lastCleanupTime = currentTime
            end
            
            -- 只遍历Items文件夹（如果存在）或直接子对象
            local itemsFolder = mapFolder:FindFirstChild("Items")
            local searchFolder = itemsFolder or mapFolder
            for _, child in ipairs(searchFolder:GetChildren()) do
                if child:IsA("Model") then
                    local itemRoot = child:FindFirstChild("ItemRoot")
                    if itemRoot and not ESPCache[child] then
                        local distanceSq = (itemRoot.Position - cameraPos).Magnitude ^ 2
                        if distanceSq > maxDistanceSq then
                            continue
                        end
                        
                        ESPCache[child] = true
                        local itemModel = child
                        if ESPSettings.itemESP and not itemModel:FindFirstChild("TAOWARE_Highlight") then
                            if currentESPCount < maxESPCount then
                                CreateESP(itemModel, ESPSettings.itemColor, false, true, false, false, false, false, false, false)
                                currentESPCount = currentESPCount + 1
                            end
                        elseif not ESPSettings.itemESP then
                            RemoveESP(itemModel)
                        end
                        
                        if ESPSettings.itemTracers and itemRoot:IsA("BasePart") then
                            CreateTracer(itemModel, itemRoot, ESPSettings.itemColor)
                        else
                            RemoveTracer(itemModel)
                        end
                    end
                end
            end
        end
    end
    
    -- Pizza ESP
    for _, pizza in ipairs(ingame:GetChildren()) do
        if pizza.Name == "Pizza" and pizza:IsA("BasePart") then
            local distanceSq = (pizza.Position - cameraPos).Magnitude ^ 2
            if distanceSq > maxDistanceSq then
                RemoveESP(pizza)
                RemoveTracer(pizza)
                continue
            end
            
            if ESPSettings.pizzaEsp and not pizza:FindFirstChild("TAOWARE_Highlight") then
                if currentESPCount < maxESPCount then
                    CreateESP(pizza, ESPSettings.pizzaColor, false, false, true, false, false, false, false, false)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.pizzaEsp then
                RemoveESP(pizza)
            end
            
            if ESPSettings.pizzaTracers then
                CreateTracer(pizza, pizza, ESPSettings.pizzaColor)
            else
                RemoveTracer(pizza)
            end
        end
    end
    
    -- Pizza Delivery ESP
    for _, delivery in ipairs(ingame:GetChildren()) do
        if delivery:IsA("Model") and table.find(DummyNames, delivery.Name) then
            local hrp = delivery:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distanceSq = (hrp.Position - cameraPos).Magnitude ^ 2
                if distanceSq > maxDistanceSq then
                    RemoveESP(delivery)
                    RemoveTracer(delivery)
                    continue
                end
            end
            
            if ESPSettings.pizzaDeliveryEsp and not delivery:FindFirstChild("TAOWARE_Highlight") then
                if hrp and currentESPCount < maxESPCount then
                    CreateESP(delivery, ESPSettings.pizzaDeliveryColor, false, false, false, true, false, false, false, false)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.pizzaDeliveryEsp then
                RemoveESP(delivery)
            end
            
            if ESPSettings.pizzaDeliveryTracers then
                if hrp then
                    CreateTracer(delivery, hrp, ESPSettings.pizzaDeliveryColor)
                end
            else
                RemoveTracer(delivery)
            end
        end
    end
    
    -- Zombie ESP
    for _, zombie in ipairs(ingame:GetChildren()) do
        if zombie.Name == "Zombie" and zombie:IsA("Model") then
            local hrp = zombie:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distanceSq = (hrp.Position - cameraPos).Magnitude ^ 2
                if distanceSq > maxDistanceSq then
                    RemoveESP(zombie)
                    RemoveTracer(zombie)
                    continue
                end
            end
            
            if ESPSettings.zombieEsp and not zombie:FindFirstChild("TAOWARE_Highlight") then
                if hrp and currentESPCount < maxESPCount then
                    CreateESP(zombie, ESPSettings.zombieColor, false, false, false, false, true, false, false, false)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.zombieEsp then
                RemoveESP(zombie)
            end
            
            if ESPSettings.zombieTracers then
                if hrp then
                    CreateTracer(zombie, hrp, ESPSettings.zombieColor)
                end
            else
                RemoveTracer(zombie)
            end
        end
    end
    
    -- Tripwire ESP
    for _, tripwire in ipairs(ingame:GetChildren()) do
        if tripwire.Name == "TaphTripwire" and tripwire:IsA("BasePart") then
            local distanceSq = (tripwire.Position - cameraPos).Magnitude ^ 2
            if distanceSq > maxDistanceSq then
                RemoveESP(tripwire)
                continue
            end
            
            if ESPSettings.taphTripwireEsp and not tripwire:FindFirstChild("TAOWARE_Highlight") then
                if currentESPCount < maxESPCount then
                    CreateESP(tripwire, ESPSettings.tripwireColor, false, false, false, false, false, true, false, false)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.taphTripwireEsp then
                RemoveESP(tripwire)
            end
        end
    end
    
    -- Trip Mine ESP
    for _, mine in ipairs(ingame:GetChildren()) do
        if mine.Name == "TripMine" and mine:IsA("Model") then
            local minePart = mine:FindFirstChildWhichIsA("BasePart", true)
            if minePart then
                local distanceSq = (minePart.Position - cameraPos).Magnitude ^ 2
                if distanceSq > maxDistanceSq then
                    RemoveESP(mine)
                    continue
                end
            end
            
            if ESPSettings.tripMineEsp and not mine:FindFirstChild("TAOWARE_Highlight") then
                if currentESPCount < maxESPCount then
                    CreateESP(mine, ESPSettings.tripMineColor, false, false, false, false, false, false, true, false)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.tripMineEsp then
                RemoveESP(mine)
            end
        end
    end
    
    -- Two Time Respawn ESP
    for _, respawn in ipairs(ingame:GetChildren()) do
        if respawn.Name == "TwoTimeRespawn" and respawn:IsA("BasePart") then
            local distanceSq = (respawn.Position - cameraPos).Magnitude ^ 2
            if distanceSq > maxDistanceSq then
                RemoveESP(respawn)
                continue
            end
            
            if ESPSettings.twoTimeRespawnEsp and not respawn:FindFirstChild("TAOWARE_Highlight") then
                if currentESPCount < maxESPCount then
                    CreateESP(respawn, ESPSettings.respawnColor, false, false, false, false, false, false, false, true)
                    currentESPCount = currentESPCount + 1
                end
            elseif not ESPSettings.twoTimeRespawnEsp then
                RemoveESP(respawn)
            end
        end
    end
end

-- ESP更新循环 - 优化频率，降低更新频率
local ESPUpdateThread = task.spawn(function()
    while true do
        pcall(function()
            UpdateESP()
            updateFakeNolis()
        end)
        task.wait(0.8) -- 从0.5秒增加到0.8秒，减少更新频率
    end
end)

-- Tracer更新 - 优化帧率限制，进一步降低更新频率
local tracerFrameSkip = 0
local tracerUpdateConnection = Services.RunService.RenderStepped:Connect(function()
    tracerFrameSkip = tracerFrameSkip + 1
    if tracerFrameSkip >= 4 then -- 从每2帧改为每4帧更新一次，进一步降低CPU使用
        tracerFrameSkip = 0
        pcall(UpdateTracers)
    end
end)





local Window = Library:CreateWindow({
    Title = 'YG SCRIPT',
    Footer = "Version : 免费",
    Icon = "rbxassetid://93487642627310",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 8,
    MenuFadeTime = 0
})



local Tabs = {
    new = Window:AddTab('信息', 'person-standing'),
    Esp = Window:AddTab('透视','eye'),
    ani = Window:AddTab('反效果','cpu'),
    aim = Window:AddTab('自瞄','cross'),
	Main = Window:AddTab('杂项','house'),
	Bro = Window:AddTab('战斗','biohazard'),
	zdx = Window:AddTab('发电机','printer'),
	Sat = Window:AddTab('体力','zap'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings')
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _env = getgenv and getgenv() or {}
local _hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local new = Tabs.new:AddLeftGroupbox('新闻🚀')

new:AddLabel("[+]Dev Yuxingchen")

new:AddLabel("支持是我们最大的动力😒")

new:AddLabel("更新时间2026.1.02")


local MainTabbox = Tabs.Main:AddLeftTabbox()
local Lighting = MainTabbox:AddTab("亮度调节")
local Camera = MainTabbox:AddTab("视野")

local lightingConnection
local cameraConnection

Lighting:AddSlider("B", {
    Text = "亮度数值",
    Min = 0,
    Default = 0,
    Max = 3,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.Brightness = v
    end
})

Lighting:AddCheckbox("无阴影", {
    Text = "无阴影",
    Default = false,
    Callback = function(v)
        _env.GlobalShadows = v
    end
})

Lighting:AddCheckbox("除雾", {
    Text = "除雾",
    Default = false,
    Callback = function(v)
        _env.NoFog = v
    end
})

Lighting:AddDivider()

Lighting:AddCheckbox("启用功能", {
    Text = "启用",
    Default = false,
    Callback = function(v)
        _env.Fullbright = v
        
        if lightingConnection then
            lightingConnection:Disconnect()
            lightingConnection = nil
        end
        
        if v then
            lightingConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not game.Lighting:GetAttribute("FogStart") then 
                    game.Lighting:SetAttribute("FogStart", game.Lighting.FogStart) 
                end
                if not game.Lighting:GetAttribute("FogEnd") then 
                    game.Lighting:SetAttribute("FogEnd", game.Lighting.FogEnd) 
                end
                
                game.Lighting.FogStart = _env.NoFog and 0 or game.Lighting:GetAttribute("FogStart")
                game.Lighting.FogEnd = _env.NoFog and math.huge or game.Lighting:GetAttribute("FogEnd")
                
                local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
                if fog then
                    if not fog:GetAttribute("Density") then 
                        fog:SetAttribute("Density", fog.Density) 
                    end
                    fog.Density = _env.NoFog and 0 or fog:GetAttribute("Density")
                end
                
                game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
                game.Lighting.Brightness = _env.Brightness or 0
                game.Lighting.GlobalShadows = not _env.GlobalShadows
            end)
        else
            game.Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
            game.Lighting.Brightness = 0
            game.Lighting.GlobalShadows = true
        end
    end
})

Camera:AddSlider("视野范围", {
    Text = "调节范围",
    Min = 70,
    Default = 70,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.FovValue = v
        if _env.FOV then
            workspace.Camera.FieldOfView = v
        end
    end
})

_G.FovValue = 70

Camera:AddCheckbox("应用范围", {
    Text = "应用",
    Callback = function(v)
        _env.FOV = v
        
        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end
        
        if v then
            cameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
                workspace.Camera.FieldOfView = _env.FovValue
            end)
        else
            workspace.Camera.FieldOfView = 70
        end
    end
})



local KillerSurvival = Tabs.Main:AddLeftGroupbox('Chat可见')

KillerSurvival:AddCheckbox('AlwaysShowChat', {
        Text = "显示聊天框",
        Callback = function(state)
            if state then
                _G.showChat = true
                task.spawn(function()
                    while _G.showChat and task.wait() do
                        game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = true
                    end
                end)
            else
                _G.showChat = false
                if playingState ~= "Spectating" then
                    game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = false
                end
            end
        end
    })

    function panic()
        for i, v in pairs(Toggles) do
            pcall(function()
                if v.Value == false then return end
                v:SetValue(false)
            end)
        end
    end

    -- OnUnload将在后面统一处理





local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local invisAnimationId = "75804462760596"
local invisLoopRunning = false
local invisLoopThread
local invisCurrentAnim = nil

local function startInvisibility()
   invisLoopRunning = true
   local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
   if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end

   invisLoopThread = task.spawn(function()
       while invisLoopRunning do
           local anim = Instance.new("Animation")
           anim.AnimationId = "rbxassetid://" .. invisAnimationId
           local loadedAnim = humanoid:LoadAnimation(anim)
           invisCurrentAnim = loadedAnim
           loadedAnim.Looped = false
           loadedAnim:Play()
           loadedAnim:AdjustSpeed(0)
           task.wait(0.000001)
       end
   end)
end

local function stopInvisibility()
   invisLoopRunning = false
   if invisLoopThread then
       task.cancel(invisLoopThread)
       invisLoopThread = nil
   end
   if invisCurrentAnim then
       invisCurrentAnim:Stop()
       invisCurrentAnim = nil
   end
   local humanoid = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character:FindFirstChildOfClass("AnimationController"))
   if humanoid then
       for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
           v:AdjustSpeed(100000)
       end
   end
   local animateScript = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
   if animateScript then
       animateScript.Disabled = true
       animateScript.Disabled = false
   end
end

local MiscGroup = Tabs.Main:AddRightGroupbox("隐身")

MiscGroup:AddCheckbox("Invisibility", {
   Text = "隐身[藏匿]",
   Default = false,
   Tooltip = "启用角色隐身功能，仅支持R6模型",
   Callback = function(Value)
       if Value then
           startInvisibility()
       else
           stopInvisibility()
       end
   end
})


local ZZ = Tabs.Main:AddLeftGroupbox('自動拾取物品')


ZZ:AddCheckbox('医疗包传送并拾取', {
    Text = '医疗包传送并拾取',
    Default = false,
    Tooltip = '自动将医疗包传送到自己位置并互动',
    
    Callback = function(state)
        autoTeleportMedkitEnabled = state
        
        if autoTeleportMedkitEnabled then
            teleportMedkitThread = task.spawn(function()
                while autoTeleportMedkitEnabled and task.wait(0.5) do
                  
                    local character = game.Players.LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        
                      
                        local medkit = workspace:FindFirstChild("Map", true)
                        if medkit then
                            medkit = medkit:FindFirstChild("Ingame", true)
                            if medkit then
                                medkit = medkit:FindFirstChild("Medkit", true)
                                if medkit then
                                    local itemRoot = medkit:FindFirstChild("ItemRoot", true)
                                    if itemRoot then
                                       
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 1
                                        
                                       
                                        local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif teleportMedkitThread then
            task.cancel(teleportMedkitThread)
            teleportMedkitThread = nil
        end
    end
})


ZZ:AddCheckbox('可乐传送并拾取', {
    Text = '可乐传送并拾取',
    Default = false,
    Tooltip = '自动将可乐传送到自己位置并互动',
    
    Callback = function(state)
        autoTeleportColaEnabled = state
        
        if autoTeleportColaEnabled then
            teleportColaThread = task.spawn(function()
                while autoTeleportColaEnabled and task.wait(0.5) do
                    -- 获取玩家角色
                    local character = game.Players.LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        
                        -- 查找可乐
                        local cola = workspace:FindFirstChild("Map", true)
                        if cola then
                            cola = cola:FindFirstChild("Ingame", true)
                            if cola then
                                cola = cola:FindFirstChild("BloxyCola", true)
                                if cola then
                                    local itemRoot = cola:FindFirstChild("ItemRoot", true)
                                    if itemRoot then
                                    
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 1
                                        
                                       
                                        local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif teleportColaThread then
            task.cancel(teleportColaThread)
            teleportColaThread = nil
        end
    end
})





getgenv().Players = game:GetService("Players")
getgenv().RunService = game:GetService("RunService")
getgenv().LocalPlayer = getgenv().Players.LocalPlayer
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().buffer = buffer or require(getgenv().ReplicatedStorage.Buffer)
getgenv().RemoteEvent = getgenv().ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")

local Plrs = getgenv().Players
local RSvc = getgenv().RunService
local LocalP = getgenv().LocalPlayer
local RS = getgenv().ReplicatedStorage

getgenv().AutoBlockSounds = {
    ["102228729296384"]=true,["140242176732868"]=true,["112809109188560"]=true,
    ["136323728355613"]=true,["115026634746636"]=true,["84116622032112"]=true,
    ["108907358619313"]=true,["127793641088496"]=true,["86174610237192"]=true,
    ["95079963655241"]=true,["101199185291628"]=true,["119942598489800"]=true,
    ["84307400688050"]=true,["113037804008732"]=true,["105200830849301"]=true,
    ["75330693422988"]=true,["82221759983649"]=true,["81702359653578"]=true,
    ["108610718831698"]=true,["112395455254818"]=true,["109431876587852"]=true,
    ["109348678063422"]=true,["85853080745515"]=true,["12222216"]=true,
    ["105840448036441"]=true,["114742322778642"]=true,["119583605486352"]=true,
    ["79980897195554"]=true,["71805956520207"]=true,["79391273191671"]=true,
    ["89004992452376"]=true,["101553872555606"]=true,["101698569375359"]=true,
    ["106300477136129"]=true,["116581754553533"]=true,["117231507259853"]=true,
    ["119089145505438"]=true,["121954639447247"]=true,["125213046326879"]=true,
    ["131406927389838"]=true,["117173212095661"]=true,["104910828105172"]=true,
    ["128856426573270"]=true,["131123355704017"]=true,["80516583309685"]=true,
    ["99829427721752"]=true,["71834552297085"]=true,["75467546215199"]=true,
    ["121369993837377"]=true,["109700476007435"]=true,["89315669689903"]=true,
    ["79222929114377"]=true,["70845653728841"]=true,["107444859834748"]=true,
    ["110372418055226"]=true,["86833981571073"]=true,["86494585504534"]=true,
    ["76959687420003"]=true,["90878551190839"]=true,["77245770579014"]=true,
    ["85810983952228"]=true,["110115912768379"]=true,["94043596324983"]=true
}

getgenv().AutoBlockAnims = {
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,
    ["18885909645"]=true,["98456918873918"]=true,["105458270463374"]=true,
    ["83829782357897"]=true,["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true,["70371667919898"]=true,["99135633258223"]=true,
    ["97167027849946"]=true,["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true,["114506382930939"]=true,
    ["94162446513587"]=true,["93069721274110"]=true,["97433060861952"]=true,
    ["106847695270773"]=true,["120112897026015"]=true,["74707328554358"]=true,
    ["133336594357903"]=true,["86204001129974"]=true,["131543461321709"]=true,
    ["106776364623742"]=true,["114356208094580"]=true,["106538427162796"]=true,
    ["131430497821198"]=true,["100592913030351"]=true,["70447634862911"]=true,
    ["83685305553364"]=true,["126171487400618"]=true,["83251433279852"]=true,
    ["122709416391891"]=true,["87989533095285"]=true,["139309647473555"]=true,
    ["133363345661032"]=true,["128414736976503"]=true,["88451353906104"]=true,
    ["81299297965542"]=true,["99829427721752"]=true,["101031946095087"]=true,
    ["96571077893813"]=true,["109700476007435"]=true,["92645737884601"]=true
}

getgenv().PunchAnims = {
    ["108911997126897"]=true,["82137285150006"]=true,["129843313690921"]=true,
    ["140703210927645"]=true,["136007065400978"]=true,["86096387000557"]=true,
    ["87259391926321"]=true,["86709774283672"]=true,["108807732150251"]=true,
    ["138040001965654"]=true
}

getgenv().AutoBlockEnabled = false
getgenv().LooseFacingCheck = false
getgenv().SenseRange = 18
getgenv().PlayerFacingAngle = 90
getgenv().KillerFacingAngle = 90
getgenv().KillerFacingCheckEnabled = false
getgenv().KillersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
getgenv().SenseRangeSq = getgenv().SenseRange * getgenv().SenseRange
getgenv().FacingCheckEnabled = false
getgenv().InnerCircleVisible = false
getgenv().OuterCircleVisible = false
getgenv().KillerCircles = {}
getgenv().SoundHooks = {}
getgenv().AnimHooks = {}
getgenv().SoundBlockedUntil = {}
getgenv().AnimBlockedUntil = {}
getgenv().autoPunchOn = false
getgenv().aimbotPunchOn = false
getgenv().punchRange = 50
getgenv().aimbotDelay = 0.1
getgenv().lastAimbotTime = 0
getgenv().KnownKillers = {"c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer","Nosferatu"}
getgenv().CachedGui = getgenv().LocalPlayer:WaitForChild("PlayerGui")
getgenv().CachedPunchBtn = nil
getgenv().CachedCharges = nil
getgenv().CachedBlockBtn = nil
getgenv().CachedCooldown = nil
getgenv().HDPullEnabled = false
getgenv().HDSpeed = 12
getgenv().pulling = false
getgenv().wallCheckEnabled = false
getgenv().visualizationParts = {}
getgenv().lastVisUpdate = 0
getgenv().visUpdateInterval = 0.033
getgenv().VisualizationMode = "指南针"
getgenv().BoxLength = 15
getgenv().BoxWidth = 6
getgenv().BoxColor = Color3.fromRGB(255, 0, 255)
getgenv().BoxTransparency = 0.7
getgenv().BoxSafeColor = Color3.fromRGB(0, 255, 0)
getgenv().BoxDangerColor = Color3.fromRGB(255, 0, 0)

getgenv().FireBlockRemote = function()
    local args = {"UseActorAbility",{getgenv().buffer.fromstring("\"Block\"")}}
    RS:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

getgenv().fireRemotePunch = function()
    local args = {"UseActorAbility",{getgenv().buffer.fromstring("\"Punch\"")}}
    getgenv().RemoteEvent:FireServer(unpack(args))
end

getgenv().IsPlayerFacingKiller = function(myRoot,killerRoot)
    if not getgenv().FacingCheckEnabled then return true end
    if not myRoot or not killerRoot then return false end
    local dirToKiller = (killerRoot.Position - myRoot.Position).Unit
    local playerLookDir = myRoot.CFrame.LookVector
    local dotProduct = playerLookDir:Dot(dirToKiller)
    local angleInDegrees = math.deg(math.acos(math.clamp(dotProduct,-1,1)))
    return angleInDegrees <= getgenv().PlayerFacingAngle
end

getgenv().IsKillerFacingPlayer = function(myRoot,killerRoot)
    if not getgenv().KillerFacingCheckEnabled then return true end
    if not myRoot or not killerRoot then return false end
    local dirToPlayer = (myRoot.Position - killerRoot.Position).Unit
    local killerLookDir = killerRoot.CFrame.LookVector
    local dotProduct = killerLookDir:Dot(dirToPlayer)
    local angleInDegrees = math.deg(math.acos(math.clamp(dotProduct,-1,1)))
    return angleInDegrees <= getgenv().KillerFacingAngle
end

getgenv().HasLineOfSight = function(targetRoot)
    if not getgenv().wallCheckEnabled then return true end
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    rayParams.FilterDescendantsInstances = {LocalP.Character}
    local origin = myRoot.Position
    local direction = targetRoot.Position - origin
    local result = workspace:Raycast(origin,direction,rayParams)
    return not result or result.Instance:IsDescendantOf(targetRoot.Parent)
end

getgenv().IsPlayerInBox = function(myRoot, killerRoot)
    if not myRoot or not killerRoot then return false end
    
    local forward = killerRoot.CFrame.LookVector * (getgenv().BoxLength/2 + 3 - 4)
    local boxPos = killerRoot.Position + forward
    local boxCFrame = CFrame.lookAt(boxPos, boxPos + killerRoot.CFrame.LookVector * 100)
    
    local relative = myRoot.Position - boxPos
    local localSpace = boxCFrame:VectorToObjectSpace(relative)
    local half = Vector3.new(getgenv().BoxWidth, 3, getgenv().BoxLength) / 2
    
    return math.abs(localSpace.X) <= half.X and math.abs(localSpace.Y) <= half.Y and math.abs(localSpace.Z) <= half.Z
end

getgenv().CheckAllBlockConditions = function(myRoot,killerRoot)
    if not myRoot or not killerRoot then return false end
    
    if getgenv().VisualizationMode == "Box" then
        if not getgenv().IsPlayerInBox(myRoot, killerRoot) then return false end
    elseif getgenv().VisualizationMode == "球体" then
        local dvec = killerRoot.Position - myRoot.Position
        local distSq = dvec.X^2 + dvec.Y^2 + dvec.Z^2
        if distSq > getgenv().SenseRangeSq then return false end
    else
        local dvec = killerRoot.Position - myRoot.Position
        local distSq = dvec.X^2 + dvec.Y^2 + dvec.Z^2
        if distSq > getgenv().SenseRangeSq then return false end
    end
    
    if not getgenv().HasLineOfSight(killerRoot) then return false end
    if not getgenv().IsPlayerFacingKiller(myRoot,killerRoot) then return false end
    if not getgenv().IsKillerFacingPlayer(myRoot,killerRoot) then return false end
    return true
end

getgenv().GetSoundIdNumeric = function(snd)
    if not snd or not snd.SoundId then return nil end
    local sid = tostring(snd.SoundId)
    return sid:match("%d+")
end

getgenv().GetAnimIdNumeric = function(anim)
    if not anim or not anim.AnimationId then return nil end
    local aid = tostring(anim.AnimationId)
    return aid:match("%d+")
end

getgenv().GetSoundPosition = function(snd)
    if not snd then return nil end
    if snd.Parent and snd.Parent:IsA("BasePart") then
        return snd.Parent.Position,snd.Parent
    end
    if snd.Parent and snd.Parent:IsA("Attachment") and snd.Parent.Parent and snd.Parent.Parent:IsA("BasePart") then
        return snd.Parent.Parent.Position,snd.Parent.Parent
    end
    local found = snd.Parent and snd.Parent:FindFirstChildWhichIsA("BasePart",true)
    return found and found.Position,found or nil,nil
end

getgenv().GetCharFromDescendant = function(inst)
    if not inst then return nil end
    local mdl = inst:FindFirstAncestorOfClass("Model")
    return mdl and mdl:FindFirstChildOfClass("Humanoid") and mdl or nil
end

getgenv().CanUseBlock = function()
    if getgenv().CachedCooldown and getgenv().CachedCooldown.Text ~= "" then return false end
    return true
end

getgenv().DoHDPull = function(targetPos)
    if getgenv().pulling or not getgenv().CanUseBlock() then return end
    getgenv().pulling = true
    local hrp = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then getgenv().pulling = false return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(40000,0,40000)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local conn = RSvc.Heartbeat:Connect(function()
        if not bv.Parent then conn:Disconnect() getgenv().pulling = false return end
        local vec = targetPos - hrp.Position
        if vec.Magnitude < 5 then bv:Destroy() conn:Disconnect() getgenv().pulling = false return end
        bv.Velocity = vec.Unit * (getgenv().HDSpeed * 20)
    end)
    task.delay(0.5,function()
        if bv and bv.Parent then bv:Destroy() end
        if conn then conn:Disconnect() end
        getgenv().pulling = false
    end)
end

getgenv().AttemptBlockSound = function(snd)
    if not getgenv().AutoBlockEnabled then return end
    if not snd or not snd:IsA("Sound") then return end
    if not snd.IsPlaying then return end
    local id = getgenv().GetSoundIdNumeric(snd)
    if not id or not getgenv().AutoBlockSounds[id] then return end
    local now = tick()
    if getgenv().SoundBlockedUntil[snd] and now < getgenv().SoundBlockedUntil[snd] then return end
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local pos,part = getgenv().GetSoundPosition(snd)
    if not pos or not part then return end
    local char = getgenv().GetCharFromDescendant(part)
    local plr = char and Plrs:GetPlayerFromCharacter(char)
    if not plr or plr == LocalP then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not getgenv().CheckAllBlockConditions(myRoot,hrp) then return end
    getgenv().FireBlockRemote()
    if getgenv().HDPullEnabled then
        getgenv().DoHDPull(hrp.Position)
    end
    getgenv().SoundBlockedUntil[snd] = now + 1.2
end

getgenv().AttemptBlockAnim = function(animTrack)
    if not getgenv().AutoBlockEnabled then return end
    if not animTrack or not animTrack.Animation then return end
    if not animTrack.IsPlaying then return end
    local id = getgenv().GetAnimIdNumeric(animTrack.Animation)
    if not id or not getgenv().AutoBlockAnims[id] then return end
    local now = tick()
    if getgenv().AnimBlockedUntil[animTrack] and now < getgenv().AnimBlockedUntil[animTrack] then return end
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local animator = animTrack.Parent
    if not animator or not animator:IsA("Animator") then return end
    local char = getgenv().GetCharFromDescendant(animator)
    if not char then return end
    local plr = Plrs:GetPlayerFromCharacter(char)
    if not plr or plr == LocalP then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not getgenv().CheckAllBlockConditions(myRoot,hrp) then return end
    getgenv().FireBlockRemote()
    if getgenv().HDPullEnabled then
        getgenv().DoHDPull(hrp.Position)
    end
    getgenv().AnimBlockedUntil[animTrack] = now + 1.2
end

getgenv().HookSound = function(snd)
    if not snd or not snd:IsA("Sound") then return end
    if getgenv().SoundHooks[snd] then return end
    local playConn = snd.Played:Connect(function()
        pcall(getgenv().AttemptBlockSound,snd)
    end)
    local propConn = snd:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if snd.IsPlaying then pcall(getgenv().AttemptBlockSound,snd) end
    end)
    local destroyConn
    destroyConn = snd.Destroying:Connect(function()
        if playConn.Connected then playConn:Disconnect() end
        if propConn.Connected then propConn:Disconnect() end
        if destroyConn.Connected then destroyConn:Disconnect() end
        getgenv().SoundHooks[snd] = nil
        getgenv().SoundBlockedUntil[snd] = nil
    end)
    getgenv().SoundHooks[snd] = {playConn,propConn,destroyConn}
    if snd.IsPlaying then
        task.spawn(function() pcall(getgenv().AttemptBlockSound,snd) end)
    end
end

getgenv().HookAnimator = function(animator)
    if not animator or not animator:IsA("Animator") then return end
    animator.AnimationPlayed:Connect(function(animTrack)
        pcall(function()
            local playConn = animTrack:GetPropertyChangedSignal("IsPlaying"):Connect(function()
                if animTrack.IsPlaying then
                    pcall(getgenv().AttemptBlockAnim,animTrack)
                end
            end)
            animTrack.Stopped:Connect(function()
                if playConn.Connected then playConn:Disconnect() end
                getgenv().AnimBlockedUntil[animTrack] = nil
            end)
            if animTrack.IsPlaying then
                pcall(getgenv().AttemptBlockAnim,animTrack)
            end
        end)
    end)
end

for _,d in ipairs(game:GetDescendants()) do
    if d:IsA("Sound") then pcall(getgenv().HookSound,d) end
    if d:IsA("Animator") then pcall(getgenv().HookAnimator,d) end
end

game.DescendantAdded:Connect(function(d)
    if d:IsA("Sound") then pcall(getgenv().HookSound,d) end
    if d:IsA("Animator") then pcall(getgenv().HookAnimator,d) end
end)

getgenv().CreateCompassVisualization = function(killer, myRoot)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") or not myRoot then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "CompassVisualization"
    folder.Parent = killerRoot
    
    local dirToPlayer = (myRoot.Position - killerRoot.Position).Unit
    local forward = Vector3.new(dirToPlayer.X, 0, dirToPlayer.Z).Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    
    local angle = getgenv().KillerFacingCheckEnabled and getgenv().KillerFacingAngle or 360
    local angleRad = math.rad(angle)
    local distance = getgenv().SenseRange
    local segments = 24
    
    local centerPart = Instance.new("Part")
    centerPart.Name = "Center"
    centerPart.Size = Vector3.new(0.5,0.1,0.5)
    centerPart.Anchored = true
    centerPart.CanCollide = false
    centerPart.Transparency = 0.5
    centerPart.Material = Enum.Material.Neon
    centerPart.Color = Color3.fromRGB(255,255,0)
    centerPart.Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    centerPart.Parent = folder
    
    local parts = {centerPart}
    
    for i = 1, segments do
        local part = Instance.new("Part")
        part.Name = "ArcPoint"..i
        part.Size = Vector3.new(0.3,0.1,0.3)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.6
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255,100,100)
        part.Parent = folder
        table.insert(parts, part)
    end
    
    return {folder = folder, parts = parts, killer = killer, mode = "指南针"}
end

getgenv().CreateFixedVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "FixedVisualization"
    folder.Parent = killerRoot
    
    local segments = 24
    local parts = {}
    
    local centerPart = Instance.new("Part")
    centerPart.Name = "Center"
    centerPart.Size = Vector3.new(0.5,0.1,0.5)
    centerPart.Anchored = true
    centerPart.CanCollide = false
    centerPart.Transparency = 0.5
    centerPart.Material = Enum.Material.Neon
    centerPart.Color = Color3.fromRGB(255,255,0)
    centerPart.Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    centerPart.Parent = folder
    table.insert(parts, centerPart)
    
    for i = 1, segments do
        local part = Instance.new("Part")
        part.Name = "ArcPoint"..i
        part.Size = Vector3.new(0.3,0.1,0.3)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.6
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(100,100,255)
        part.Parent = folder
        table.insert(parts, part)
    end
    
    return {folder = folder, parts = parts, killer = killer, mode = "固定"}
end

getgenv().CreateBoxVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "BoxVisualization"
    folder.Parent = killerRoot
    
    local box = Instance.new("Part")
    box.Name = "DetectionBox"
    box.Material = Enum.Material.Neon
    box.Anchored = true
    box.CanCollide = false
    box.Transparency = getgenv().BoxTransparency
    box.Color = getgenv().BoxColor
    box.Size = Vector3.new(getgenv().BoxWidth, 3, getgenv().BoxLength)
    box.Parent = folder
    
    return {folder = folder, box = box, killer = killer, mode = "Box"}
end

getgenv().CreateSphereVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "SphereVisualization"
    folder.Parent = killerRoot
    
    local sphere = Instance.new("Part")
    sphere.Name = "DetectionSphere"
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.Neon
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Transparency = 0.85
    sphere.Color = Color3.fromRGB(255, 0, 0)
    sphere.Size = Vector3.new(getgenv().SenseRange * 2, getgenv().SenseRange * 2, getgenv().SenseRange * 2)
    sphere.Parent = folder
    
    return {folder = folder, sphere = sphere, killer = killer, mode = "球体"}
end

getgenv().UpdateCompassVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    local dirToPlayer = (myRoot.Position - killerRoot.Position).Unit
    local forward = Vector3.new(dirToPlayer.X, 0, dirToPlayer.Z).Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    
    local angle = getgenv().KillerFacingCheckEnabled and getgenv().KillerFacingAngle or 360
    local angleRad = math.rad(angle)
    local distance = getgenv().SenseRange
    
    visData.parts[1].Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    
    for i = 2, #visData.parts do
        local part = visData.parts[i]
        local t = (i - 2) / (#visData.parts - 2)
        local currentAngle = -angleRad/2 + angleRad * t
        local direction = forward * math.cos(currentAngle) + right * math.sin(currentAngle)
        part.Position = killerRoot.Position + Vector3.new(0, 0.1, 0) + direction * distance
    end
    
    local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    local color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    for _, part in ipairs(visData.parts) do
        part.Color = color
    end
end

getgenv().UpdateFixedVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    local forward = killerRoot.CFrame.LookVector
    local right = Vector3.new(-forward.Z, 0, forward.X)
    
    local angle = getgenv().KillerFacingCheckEnabled and getgenv().KillerFacingAngle or 360
    local angleRad = math.rad(angle)
    local distance = getgenv().SenseRange
    
    visData.parts[1].Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    
    for i = 2, #visData.parts do
        local part = visData.parts[i]
        local t = (i - 2) / (#visData.parts - 2)
        local currentAngle = -angleRad/2 + angleRad * t
        local direction = forward * math.cos(currentAngle) + right * math.sin(currentAngle)
        direction = Vector3.new(direction.X, 0, direction.Z).Unit
        part.Position = killerRoot.Position + Vector3.new(0, 0.1, 0) + direction * distance
    end
    
    local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    local color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 255)
   for _, part in ipairs(visData.parts) do
       part.Color = color
   end
end

getgenv().UpdateBoxVisualization = function(visData, myRoot)
   if not visData or not visData.folder or not visData.folder.Parent then return end
   if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
   
   local killerRoot = visData.killer.HumanoidRootPart
   local forward = killerRoot.CFrame.LookVector * (getgenv().BoxLength/2 + 3 - 4)
   local boxPos = killerRoot.Position + forward + Vector3.new(0, 0, 0)
   
   visData.box.Size = Vector3.new(getgenv().BoxWidth, 3, getgenv().BoxLength)
   visData.box.CFrame = CFrame.lookAt(boxPos, boxPos + killerRoot.CFrame.LookVector * 100)
   visData.box.Transparency = getgenv().BoxTransparency
   
   local shouldBlock = getgenv().IsPlayerInBox(myRoot, killerRoot) and getgenv().CheckAllBlockConditions(myRoot, killerRoot)
   visData.box.Color = shouldBlock and getgenv().BoxSafeColor or getgenv().BoxDangerColor
end

getgenv().UpdateSphereVisualization = function(visData, myRoot)
   if not visData or not visData.folder or not visData.folder.Parent then return end
   if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
   
   local killerRoot = visData.killer.HumanoidRootPart
   
   visData.sphere.Size = Vector3.new(getgenv().SenseRange * 2, getgenv().SenseRange * 2, getgenv().SenseRange * 2)
   visData.sphere.CFrame = killerRoot.CFrame
   
   local distance = (myRoot.Position - killerRoot.Position).Magnitude
   local shouldBlock = distance <= getgenv().SenseRange and getgenv().CheckAllBlockConditions(myRoot, killerRoot)
   visData.sphere.Color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

getgenv().CreateVisualizationForKiller = function(killer)
   if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
   
   if getgenv().VisualizationMode == "指南针" then
       local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
       return getgenv().CreateCompassVisualization(killer, myRoot)
   elseif getgenv().VisualizationMode == "固定" then
       return getgenv().CreateFixedVisualization(killer)
   elseif getgenv().VisualizationMode == "Box" then
       return getgenv().CreateBoxVisualization(killer)
   elseif getgenv().VisualizationMode == "球体" then
       return getgenv().CreateSphereVisualization(killer)
   end
   return nil
end

getgenv().UpdateVisualization = function(visData, myRoot)
   if not visData then return end
   
   if visData.mode == "指南针" then
       getgenv().UpdateCompassVisualization(visData, myRoot)
   elseif visData.mode == "固定" then
       getgenv().UpdateFixedVisualization(visData, myRoot)
   elseif visData.mode == "Box" then
       getgenv().UpdateBoxVisualization(visData, myRoot)
   elseif visData.mode == "球体" then
       getgenv().UpdateSphereVisualization(visData, myRoot)
   end
end

getgenv().AddKillerCircle = function(killer)
   if not killer:FindFirstChild("HumanoidRootPart") then return end
   if getgenv().KillerCircles[killer] then return end
   
   local innerCirc, outerCirc
   
   if getgenv().InnerCircleVisible then
       innerCirc = Instance.new("CylinderHandleAdornment")
       innerCirc.Name = "KillerInnerCircle"
       innerCirc.Adornee = killer.HumanoidRootPart
       innerCirc.Color3 = Color3.fromRGB(255,0,0)
       innerCirc.AlwaysOnTop = true
       innerCirc.ZIndex = 1
       innerCirc.Transparency = 0.7
       innerCirc.Radius = getgenv().SenseRange
       innerCirc.Height = 0.1
       innerCirc.CFrame = CFrame.Angles(math.rad(90),0,0)
       innerCirc.Parent = killer.HumanoidRootPart
   end
   
   if getgenv().OuterCircleVisible then
       outerCirc = Instance.new("CylinderHandleAdornment")
       outerCirc.Name = "KillerOuterCircle"
       outerCirc.Adornee = killer.HumanoidRootPart
       outerCirc.Color3 = Color3.fromRGB(0,255,255)
       outerCirc.AlwaysOnTop = true
       outerCirc.ZIndex = 0
       outerCirc.Transparency = 0.3
       outerCirc.Radius = getgenv().punchRange
       outerCirc.Height = 0.1
       outerCirc.CFrame = CFrame.Angles(math.rad(90),0,0)
       outerCirc.Parent = killer.HumanoidRootPart
   end
   
   local visData = getgenv().CreateVisualizationForKiller(killer)
   
   getgenv().KillerCircles[killer] = {innerCircle = innerCirc, outerCircle = outerCirc, visualization = visData}
end

getgenv().RemoveKillerCircle = function(killer)
   if getgenv().KillerCircles[killer] then
       if getgenv().KillerCircles[killer].innerCircle then
           getgenv().KillerCircles[killer].innerCircle:Destroy()
       end
       if getgenv().KillerCircles[killer].outerCircle then
           getgenv().KillerCircles[killer].outerCircle:Destroy()
       end
       if getgenv().KillerCircles[killer].visualization and getgenv().KillerCircles[killer].visualization.folder then
           getgenv().KillerCircles[killer].visualization.folder:Destroy()
       end
       getgenv().KillerCircles[killer] = nil
   end
end

getgenv().RefreshKillerCircles = function()
   for _,killer in ipairs(getgenv().KillersFolder:GetChildren()) do
       if getgenv().InnerCircleVisible or getgenv().OuterCircleVisible then
           getgenv().AddKillerCircle(killer)
       else
           getgenv().RemoveKillerCircle(killer)
       end
   end
end

getgenv().UpdateVisualizationMode = function(newMode)
   getgenv().VisualizationMode = newMode
   
   for killer, data in pairs(getgenv().KillerCircles) do
       if data.visualization and data.visualization.folder then
           data.visualization.folder:Destroy()
       end
       
       local newVisData = getgenv().CreateVisualizationForKiller(killer)
       data.visualization = newVisData
   end
end

getgenv().UpdateBoxColors = function()
   for killer, data in pairs(getgenv().KillerCircles) do
       if data.visualization and data.visualization.mode == "Box" and data.visualization.box then
           data.visualization.box.Transparency = getgenv().BoxTransparency
       end
   end
end

RSvc.Heartbeat:Connect(function()
   if not (getgenv().InnerCircleVisible or getgenv().OuterCircleVisible) then return end
   
   local now = tick()
   if now - getgenv().lastVisUpdate < getgenv().visUpdateInterval then return end
   getgenv().lastVisUpdate = now
   
   local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
   if not myRoot then return end
   
   for killer, data in pairs(getgenv().KillerCircles) do
       if killer:FindFirstChild("HumanoidRootPart") then
           local killerRoot = killer.HumanoidRootPart
           
           if data.innerCircle and data.innerCircle.Parent then
               data.innerCircle.Radius = getgenv().SenseRange
               
               local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
               data.innerCircle.Color3 = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
           end
           
           if data.outerCircle and data.outerCircle.Parent then
               data.outerCircle.Radius = getgenv().punchRange
               
               local dist = (killerRoot.Position - myRoot.Position).Magnitude
               data.outerCircle.Color3 = dist <= getgenv().punchRange and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(0, 100, 100)
           end
           
           if data.visualization then
               pcall(getgenv().UpdateVisualization, data.visualization, myRoot)
           end
       end
   end
end)

getgenv().KillersFolder.ChildAdded:Connect(function(killer)
   if getgenv().InnerCircleVisible or getgenv().OuterCircleVisible then
       task.spawn(function()
           local hrp = killer:WaitForChild("HumanoidRootPart",5)
           if hrp then getgenv().AddKillerCircle(killer) end
       end)
   end
end)

getgenv().KillersFolder.ChildRemoved:Connect(function(killer)
   getgenv().RemoveKillerCircle(killer)
end)

getgenv().RefreshUI = function()
   getgenv().CachedGui = getgenv().LocalPlayer:FindFirstChild("PlayerGui") or getgenv().CachedGui
   local mainUI = getgenv().CachedGui and getgenv().CachedGui:FindFirstChild("MainUI")
   if mainUI then
       local abilityContainer = mainUI:FindFirstChild("AbilityContainer")
       getgenv().CachedPunchBtn = abilityContainer and abilityContainer:FindFirstChild("Punch")
       getgenv().CachedBlockBtn = abilityContainer and abilityContainer:FindFirstChild("Block")
       getgenv().CachedCharges = getgenv().CachedPunchBtn and getgenv().CachedPunchBtn:FindFirstChild("Charges")
       getgenv().CachedCooldown = getgenv().CachedBlockBtn and getgenv().CachedBlockBtn:FindFirstChild("CooldownTime")
   else
       getgenv().CachedPunchBtn,getgenv().CachedBlockBtn,getgenv().CachedCharges,getgenv().CachedCooldown = nil,nil,nil,nil
   end
end

getgenv().RefreshUI()

if getgenv().CachedGui then
   getgenv().CachedGui.ChildAdded:Connect(function(child)
       if child.Name == "MainUI" then
           task.delay(0.02,getgenv().RefreshUI)
       end
   end)
end

getgenv().LocalPlayer.CharacterAdded:Connect(function()
   task.delay(0.5,getgenv().RefreshUI)
end)

getgenv().getClosestKiller = function()
   local myChar = getgenv().LocalPlayer.Character
   local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
   if not myRoot then return nil end
   local closest,closestDist = nil,math.huge
   local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
   if killersFolder then
       for _,name in ipairs(getgenv().KnownKillers) do
           local killer = killersFolder:FindFirstChild(name)
           if killer and killer:FindFirstChild("HumanoidRootPart") then
               local root = killer.HumanoidRootPart
               local dist = (root.Position - myRoot.Position).Magnitude
               if dist < closestDist and dist <= getgenv().punchRange then
                   closest = killer
                   closestDist = dist
               end
           end
       end
   end
   return closest
end

getgenv().RunService.RenderStepped:Connect(function()
   if not getgenv().autoPunchOn and not getgenv().aimbotPunchOn then return end
   local myChar = getgenv().LocalPlayer.Character
   local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
   local gui = getgenv().CachedGui:FindFirstChild("MainUI")
   local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
   local charges = punchBtn and punchBtn:FindFirstChild("Charges")
   if punchBtn and charges and myRoot then
       local chargeCount = tonumber(charges.Text) or 0
       if chargeCount >= 1 then
           local killer = getgenv().getClosestKiller()
           if killer and killer:FindFirstChild("HumanoidRootPart") then
               if getgenv().aimbotPunchOn then
                   local currentTime = tick()
                   if currentTime - getgenv().lastAimbotTime >= getgenv().aimbotDelay then
                       local killerRoot = killer.HumanoidRootPart
                       local camera = workspace.CurrentCamera
                       camera.CFrame = CFrame.new(camera.CFrame.Position,killerRoot.Position)
                       getgenv().fireRemotePunch()
                       getgenv().lastAimbotTime = currentTime
                   end
               elseif getgenv().autoPunchOn then
                   getgenv().fireRemotePunch()
               end
           end
       end
   end
end)

getgenv().punchAnimIds = {
   "108911997126897","82137285150006","129843313690921",
   "140703210927645","136007065400978","86096387000557",
   "87259391926321","86709774283672","108807732150251",
   "138040001965654"
}

getgenv().killerNames = {"c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher"}
getgenv().autoFallPunchOn = false
getgenv().autoDashEnabled = false
getgenv().DASH_SPEED = 100
getgenv().MIN_TARGET_MAXHP = 300

if not getgenv().originalNamecall then
   getgenv().HookRules = {}
   getgenv().originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
       local method = getnamecallmethod()
       local args = {...}
       if method == "FireServer" then
           for _, rule in ipairs(getgenv().HookRules) do
               if (not rule.remoteName or self.Name == rule.remoteName) then
                   if not rule.blockedFirstArg or args[1] == rule.blockedFirstArg then
                       if rule.block then
                           return
                       end
                   end
               end
           end
       end
       return getgenv().originalNamecall(self, ...)
   end)
end

getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
   for _, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           return
       end
   end
   table.insert(getgenv().HookRules, {
       remoteName = remoteName,
       blockedFirstArg = blockedFirstArg,
       block = true
   })
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
   for i, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           table.remove(getgenv().HookRules, i)
           break
       end
   end
end

getgenv().EnableC00lkidd = function()
   getgenv().activateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

getgenv().DisableC00lkidd = function()
   getgenv().deactivateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

local globalEnv = getgenv()
globalEnv.walkSpeed = 100
globalEnv.toggle = false
globalEnv.connection = nil

function globalEnv.getCharacter()
   return globalEnv.LocalPlayer.Character or globalEnv.LocalPlayer.CharacterAdded:Wait()
end

function globalEnv.onHeartbeat()
   local player = globalEnv.LocalPlayer
   local character = globalEnv.getCharacter()
   if character.Name ~= "c00lkidd" then return end
   
   local char = globalEnv.getCharacter()
   local rootPart = char:FindFirstChild("HumanoidRootPart")
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   local lv = rootPart and rootPart:FindFirstChild("LinearVelocity")
   
   if not rootPart or not humanoid or not lv then return end
   
   if lv then
       lv.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
       lv.Enabled = false
   end

   local stopMovement = false
   local validValues = {
       Timeout = true,
       Collide = true,
       Hit = true
   }

   if not stopMovement then
       local lookVector = workspace.CurrentCamera.CFrame.LookVector
       local moveDir = Vector3.new(lookVector.X, 0, lookVector.Z)
       if moveDir.Magnitude > 0 then
           moveDir = moveDir.Unit
           rootPart.Velocity = Vector3.new(moveDir.X * globalEnv.walkSpeed, rootPart.Velocity.Y, moveDir.Z * globalEnv.walkSpeed)
           rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveDir)
       end
   end
end

local function validTarget(player)
   if not player or player == getgenv().LocalPlayer then return false end
   local char = player.Character
   if not char then return false end
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   local hrp = char:FindFirstChild("HumanoidRootPart")
   if not humanoid or not hrp then return false end
   if humanoid.Health <= 0 then return false end
   if humanoid.MaxHealth < getgenv().MIN_TARGET_MAXHP then return false end
   local myChar = getgenv().LocalPlayer.Character
   if not myChar then return false end
   local myHrp = myChar:FindFirstChild("HumanoidRootPart")
   if not myHrp then return false end
   if (hrp.Position - myHrp.Position).Magnitude > getgenv().punchRange then return false end
   return true
end

local function findClosestValidTarget()
   local best, bestDist = nil, math.huge
   local myChar = getgenv().LocalPlayer.Character
   if not myChar then return nil end
   local myHrp = myChar:FindFirstChild("HumanoidRootPart")
   if not myHrp then return nil end
   for _, p in pairs(getgenv().Players:GetPlayers()) do
       if validTarget(p) then
           local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
           local d = (targetHrp.Position - myHrp.Position).Magnitude
           if d < bestDist then
               bestDist = d
               best = p
           end
       end
   end
   return best
end

local function isPunchAnimationPlaying()
   local char = getgenv().LocalPlayer.Character
   if not char then return false end
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   if not humanoid then return false end
   local trackList = humanoid:GetPlayingAnimationTracks()
   for _, track in ipairs(trackList) do
       local animId = tostring(track.Animation.AnimationId)
       for _, id in ipairs(getgenv().punchAnimIds) do
           if animId == "rbxassetid://" .. id then
               return true
           end
       end
   end
   return false
end

getgenv().RunService.Heartbeat:Connect(function()
   local myChar = getgenv().LocalPlayer.Character
   local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
   local gui = getgenv().LocalPlayer.PlayerGui:FindFirstChild("MainUI")
   local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
   local charges = punchBtn and punchBtn:FindFirstChild("Charges")
   
   if getgenv().autoFallPunchOn and punchBtn and charges and myRoot then
       local chargeCount = tonumber(charges.Text) or 0
       if chargeCount >= 1 then
           local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
           if killersFolder then
               for _, name in ipairs(getgenv().killerNames) do
                   local killer = killersFolder:FindFirstChild(name)
                   if killer and killer:FindFirstChild("HumanoidRootPart") then
                       local root = killer.HumanoidRootPart
                       if (root.Position - myRoot.Position).Magnitude <= getgenv().punchRange then
                           myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 8, 0)
                           getgenv().fireRemotePunch()
                           task.wait(0.01)
                       end
                   end
               end
           end
       end
   end
   
   if not getgenv().autoDashEnabled then return end
   local char = getgenv().LocalPlayer.Character
   if not char or char.Name ~= "Guest1337" then return end
   if not isPunchAnimationPlaying() then return end
   
   local rootPart = char:FindFirstChild("HumanoidRootPart")
   if not rootPart then return end
   
   local target = findClosestValidTarget()
   if target and target.Character then
       local tgtHrp = target.Character:FindFirstChild("HumanoidRootPart")
       if tgtHrp then
           local dir = (tgtHrp.Position - rootPart.Position)
           local horiz = Vector3.new(dir.X, 0, dir.Z)
           local dist = horiz.Magnitude
           if dist > 3 then
               local unit = horiz.Unit
               local vel = unit * getgenv().DASH_SPEED
               local currentY = rootPart.AssemblyLinearVelocity.Y
               rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, currentY, vel.Z)
           end
       end
   end
end)

local MainBlockTab = Tabs.Bro:AddRightTabbox()
local MainGroup = MainBlockTab:AddTab("访客格挡")
local CombatGroup = MainBlockTab:AddTab("拳击")
local AdvancedGroup = MainBlockTab:AddTab("高级")

MainGroup:AddToggle("AutoBlockToggle",{
   Text = "自动格挡",
   Default = false,
   Tooltip = "开启/关闭自动格挡",
   Callback = function(Value)
       getgenv().AutoBlockEnabled = Value
   end,
})

MainGroup:AddToggle("InnerCircleToggle",{
   Text = "内圈显示(格挡范围)",
   Default = false,
   Tooltip = "显示杀手内圈格挡检测范围",
   Callback = function(Value)
       getgenv().InnerCircleVisible = Value
       getgenv().RefreshKillerCircles()
   end,
})

MainGroup:AddToggle("OuterCircleToggle",{
   Text = "外圈显示(拳击范围)",
   Default = false,
   Tooltip = "显示杀手外圈拳击检测范围",
   Callback = function(Value)
       getgenv().OuterCircleVisible = Value
       getgenv().RefreshKillerCircles()
   end,
})

MainGroup:AddDropdown("VisualizationModeDropdown",{
   Values = {"指南针", "固定", "Box", "球体"},
   Default = 1,
   Multi = false,
   Text = "可视化模式",
   Tooltip = "选择可视化显示模式\n指南针: 范围朝向玩家\n固定: 范围跟随杀手面向\nBox: 长方形检测范围\n球体: 球形检测范围",
   Callback = function(Value)
       getgenv().UpdateVisualizationMode(Value)
   end
})

MainGroup:AddToggle("FacingCheck",{
   Text = "玩家面向检测",
   Default = false,
   Tooltip = "仅在面向杀手时格挡",
   Callback = function(Value)
       getgenv().FacingCheckEnabled = Value
   end,
})

MainGroup:AddToggle("KillerFacingCheck",{
   Text = "杀手面向检测",
   Default = false,
   Tooltip = "仅在杀手面向玩家时格挡",
   Callback = function(Value)
       getgenv().KillerFacingCheckEnabled = Value
   end,
})

MainGroup:AddToggle("WallCheck",{
   Text = "墙体检测",
   Default = false,
   Tooltip = "检测是否有墙体遮挡",
   Callback = function(Value)
       getgenv().wallCheckEnabled = Value
   end,
})

MainGroup:AddSlider("SenseRange",{
   Text = "格挡范围",
   Default = 18,
   Min = 5,
   Max = 50,
   Rounding = 1,
   Tooltip = "格挡检测的距离范围",
   Callback = function(Value)
       getgenv().SenseRange = Value
       getgenv().SenseRangeSq = Value * Value
   end,
})

MainGroup:AddSlider("PlayerFacingAngle",{
   Text = "玩家面向角度",
   Default = 90,
   Min = 30,
   Max = 180,
   Rounding = 1,
   Tooltip = "玩家面向杀手的角度检测",
   Callback = function(Value)
       getgenv().PlayerFacingAngle = Value
   end,
})

MainGroup:AddSlider("KillerFacingAngle",{
   Text = "杀手面向角度",
   Default = 90,
   Min = 30,
   Max = 180,
   Rounding = 1,
   Tooltip = "杀手面向玩家的角度检测",
   Callback = function(Value)
       getgenv().KillerFacingAngle = Value
   end,
})

MainGroup:AddDivider()
MainGroup:AddLabel("Box模式设置:")

MainGroup:AddSlider("BoxLength",{
   Text = "Box长度",
   Default = 15,
   Min = 5,
   Max = 50,
   Rounding = 1,
   Tooltip = "Box模式的长度(仅Box模式有效)",
   Callback = function(Value)
       getgenv().BoxLength = Value
   end,
})

MainGroup:AddSlider("BoxWidth",{
   Text = "Box宽度",
   Default = 6,
   Min = 2,
   Max = 30,
   Rounding = 1,
   Tooltip = "Box模式的宽度(仅Box模式有效)",
   Callback = function(Value)
       getgenv().BoxWidth = Value
   end,
})

MainGroup:AddSlider("BoxTransparency",{
   Text = "Box透明度",
   Default = 0.7,
   Min = 0,
   Max = 1,
   Rounding = 2,
   Tooltip = "Box的透明度(0=完全不透明,1=完全透明)",
   Callback = function(Value)
       getgenv().BoxTransparency = Value
       getgenv().UpdateBoxColors()
   end,
})

MainGroup:AddLabel("Box安全颜色 (玩家在范围内):")
MainGroup:AddSlider("BoxSafeColorR",{
   Text = "红色 (R)",
   Default = 0,
   Min = 0,
   Max = 255,
   Rounding = 0,
   Tooltip = "Box安全状态的红色值",
   Callback = function(Value)
       local current = getgenv().BoxSafeColor
       getgenv().BoxSafeColor = Color3.fromRGB(Value, current.G * 255, current.B * 255)
   end,
})

MainGroup:AddSlider("BoxSafeColorG",{
   Text = "绿色 (G)",
   Default = 255,
   Min = 0,
   Max = 255,
   Rounding = 0,
   Tooltip = "Box安全状态的绿色值",
   Callback = function(Value)
       local current = getgenv().BoxSafeColor
       getgenv().BoxSafeColor = Color3.fromRGB(current.R * 255, Value, current.B * 255)
   end,
})

MainGroup:AddSlider("BoxSafeColorB",{
   Text = "蓝色 (B)",
   Default = 0,
   Min = 0,
   Max = 255,
   Rounding = 0,
   Tooltip = "Box安全状态的蓝色值",
   Callback = function(Value)
       local current = getgenv().BoxSafeColor
       getgenv().BoxSafeColor = Color3.fromRGB(current.R * 255, current.G * 255, Value)
   end,
})

MainGroup:AddLabel("Box危险颜色 (玩家不在范围内):")

MainGroup:AddSlider("BoxDangerColorR",{
    Text = "红色 (R)",
    Default = 255,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Box危险状态的红色值",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(Value, current.G * 255, current.B * 255)
    end,
})

MainGroup:AddSlider("BoxDangerColorG",{
    Text = "绿色 (G)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Box危险状态的绿色值",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(current.R * 255, Value, current.B * 255)
    end,
})

MainGroup:AddSlider("BoxDangerColorB",{
    Text = "蓝色 (B)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Box危险状态的蓝色值",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(current.R * 255, current.G * 255, Value)
    end,
})

-- ==========================
-- 🥊 战斗与拳击部分
-- ==========================

CombatGroup:AddToggle("AutoPunch", {
    Text = "自动拳击",
    Default = false,
    Tooltip = "自动检测范围内的敌人并拳击",
    Callback = function(Value)
        getgenv().autoPunchOn = Value
    end
})

CombatGroup:AddToggle("AimbotPunch", {
    Text = "自瞄拳击",
    Default = false,
    Tooltip = "自动对准目标进行拳击",
    Callback = function(Value)
        getgenv().aimbotPunchOn = Value
    end
})

CombatGroup:AddSlider("PunchRange", {
    Text = "拳击范围",
    Default = 50,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Tooltip = "拳击检测距离",
    Callback = function(Value)
        getgenv().punchRange = Value
    end
})

CombatGroup:AddSlider("AimbotDelay", {
    Text = "自瞄拳击间隔",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Tooltip = "自瞄拳击之间的延迟时间（秒）",
    Callback = function(Value)
        getgenv().aimbotDelay = Value
    end
})

CombatGroup:AddToggle("AutoFallPunch", {
    Text = "空中连拳",
    Default = false,
    Tooltip = "在空中自动触发拳击",
    Callback = function(Value)
        getgenv().autoFallPunchOn = Value
    end
})

-- ==========================
-- 🧠 高级设置部分
-- ==========================

AdvancedGroup:AddToggle("HDPullToggle", {
    Text = "格挡拉近（HDPull）",
    Default = false,
    Tooltip = "格挡时自动拉近到敌人",
    Callback = function(Value)
        getgenv().HDPullEnabled = Value
    end
})

AdvancedGroup:AddSlider("HDSpeed", {
    Text = "拉近速度",
    Default = 12,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Tooltip = "格挡时向敌人移动的速度",
    Callback = function(Value)
        getgenv().HDSpeed = Value
    end
})

AdvancedGroup:AddToggle("AutoDash", {
    Text = "自动冲刺",
    Default = false,
    Tooltip = "拳击时自动向敌人冲刺",
    Callback = function(Value)
        getgenv().autoDashEnabled = Value
    end
})

AdvancedGroup:AddSlider("DashSpeed", {
    Text = "冲刺速度",
    Default = 100,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Tooltip = "自动冲刺时的速度",
    Callback = function(Value)
        getgenv().DASH_SPEED = Value
    end
})











local LOL = Tabs.Bro:AddLeftTabbox()
local SM = LOL:AddTab("HitBox追踪")


local HitboxTrackingEnabled = false
local HeartbeatConnection = nil
local MaxDistance = 120
local FilterSurvivors = false
local FilterKillers = false
local WallCheckEnabled = false 

local Killers = {
    ["Slasher"] = true, ["1x1x1x1"] = true, ["c00lkidd"] = true,
    ["Noli"] = true, ["JohnDoe"] = true, ["Guest 666"] = true,
    ["Sixer"] = true
}
local Survivors = {
    ["Noob"] = true, ["Guest1337"] = true, ["Elliot"] = true,
    ["Shedletsky"] = true, ["TwoTime"] = true, ["007n7"] = true,
    ["Chance"] = true, ["Builderman"] = true, ["Taph"] = true,
    ["Dusekkar"] = true, ["Veeronica"] = true
}

local AttackAnimations = {
    'rbxassetid://131430497821198',
    'rbxassetid://83829782357897',
    'rbxassetid://126830014841198',
    'rbxassetid://126355327951215',
    'rbxassetid://121086746534252',
    'rbxassetid://105458270463374',
    'rbxassetid://18885919947',
    'rbxassetid://18885909645',
    'rbxassetid://87259391926321',
    'rbxassetid://106014898528300',
    'rbxassetid://86545133269813',
    'rbxassetid://89448354637442',
    'rbxassetid://90499469533503',
    'rbxassetid://116618003477002',
    'rbxassetid://106086955212611',
    'rbxassetid://107640065977686',
    'rbxassetid://77124578197357',
    'rbxassetid://101771617803133',
    'rbxassetid://134958187822107',
    'rbxassetid://111313169447787',
    'rbxassetid://71685573690338',
    'rbxassetid://129843313690921',
    'rbxassetid://97623143664485',
    'rbxassetid://136007065400978',
    'rbxassetid://86096387000557',
    'rbxassetid://108807732150251',
    'rbxassetid://138040001965654',
    'rbxassetid://73502073176819',
    'rbxassetid://86709774283672',
    'rbxassetid://140703210927645',
    'rbxassetid://96173857867228',
    'rbxassetid://121255898612475',
    'rbxassetid://98031287364865',
    'rbxassetid://119462383658044',
    'rbxassetid://77448521277146',
    'rbxassetid://103741352379819',
    'rbxassetid://131696603025265',
    'rbxassetid://122503338277352',
    'rbxassetid://97648548303678',
    'rbxassetid://94162446513587',
    'rbxassetid://84426150435898',
    'rbxassetid://93069721274110',
    'rbxassetid://114620047310688',
    'rbxassetid://97433060861952',
    'rbxassetid://82183356141401',
    'rbxassetid://100592913030351',
    'rbxassetid://121293883585738',
    'rbxassetid://70447634862911',
    'rbxassetid://92173139187970',
    'rbxassetid://106847695270773',
    'rbxassetid://125403313786645',
    'rbxassetid://81639435858902',
    'rbxassetid://137314737492715',
    'rbxassetid://120112897026015',
    'rbxassetid://82113744478546',
    'rbxassetid://118298475669935',
    'rbxassetid://126681776859538',
    'rbxassetid://129976080405072',
    'rbxassetid://109667959938617',
    'rbxassetid://74707328554358',
    'rbxassetid://133336594357903',
    'rbxassetid://86204001129974',
    'rbxassetid://124243639579224',
    'rbxassetid://70371667919898',
    'rbxassetid://131543461321709',
    'rbxassetid://136323728355613',
    'rbxassetid://109230267448394',
    'rbxassetid://139835501033932',
    'rbxassetid://106538427162796',
    'rbxassetid://110400453990786',
    'rbxassetid://83685305553364',
    'rbxassetid://126171487400618',
    'rbxassetid://122709416391891',
    'rbxassetid://87989533095285',
    'rbxassetid://119326397274934',
    'rbxassetid://140365014326125',
    'rbxassetid://139309647473555',
    'rbxassetid://133363345661032',
    'rbxassetid://128414736976503',
    'rbxassetid://121808371053483',
    'rbxassetid://88451353906104',
    'rbxassetid://81299297965542',
    'rbxassetid://99829427721752',
    'rbxassetid://126896426760253',
    'rbxassetid://77375846492436',
    'rbxassetid://94634594529334',
    'rbxassetid://101031946095087'
    
}

SM:AddSlider("DistanceSlider", {
    Text = "追踪范围",
    Default = 120,
    Min = 1,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        MaxDistance = value
    end
})

SM:AddCheckbox("FilterSurvivorsToggle", {
    Text = "过滤[不追踪]幸存者",
    Default = false,
    Callback = function(state)
        FilterSurvivors = state
    end
})

SM:AddCheckbox("FilterKillersToggle", {
    Text = "过滤[不追踪]杀手",
    Default = false,
    Callback = function(state)
        FilterKillers = state
    end
})


SM:AddCheckbox("WallCheckToggle", {
    Text = "Wallcheck",
    Default = false,
    Callback = function(state)
        WallCheckEnabled = state
    end
})

SM:AddCheckbox("HitboxTrackingToggle", {
    Text = "Hitbox追踪",
    Default = false,
    Callback = function(state)
        HitboxTrackingEnabled = state
        
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        
        if not state then return end
        
        repeat task.wait() until game:IsLoaded();

        local Players = game:GetService('Players');
        local Player = Players.LocalPlayer;
        local Character = Player.Character or Player.CharacterAdded:Wait();
        local Humanoid = Character:WaitForChild("Humanoid");
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

        Player.CharacterAdded:Connect(function(NewCharacter)
            Character = NewCharacter;
            Humanoid = Character:WaitForChild("Humanoid");
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
        end);

        local RNG = Random.new();
        local RaycastParams = RaycastParams.new()  
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParams.IgnoreWater = true
        
        
        local function isTargetVisible(targetCharacter)
            if not WallCheckEnabled or not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") then
                return true
            end
            
            local targetHRP = targetCharacter.HumanoidRootPart
            local origin = HumanoidRootPart.Position
            local direction = (targetHRP.Position - origin).Unit
            local distance = (targetHRP.Position - origin).Magnitude
            
           
            local filterList = {Character, targetCharacter}
            RaycastParams.FilterDescendantsInstances = filterList
            
            local rayResult = workspace:Raycast(origin, direction * distance, RaycastParams)
            
           
            if not rayResult then
                return true
            end
            
        
            local hitInstance = rayResult.Instance
            if hitInstance and hitInstance:IsDescendantOf(targetCharacter) then
                return true
            end
            
            
            return false
        end
        
        local function getCharacterRole(character)
            local modelName = character.Name
            if Killers[modelName] then
                return "Killer"
            elseif Survivors[modelName] then
                return "Survivor"
            end
            return "Unknown"
        end
        
        HeartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
            if not HitboxTrackingEnabled or not HumanoidRootPart then
                return;
            end

            local Playing = false;
            for _,v in Humanoid:GetPlayingAnimationTracks() do
                if table.find(AttackAnimations, v.Animation.AnimationId) and (v.TimePosition / v.Length < 0.75) then
                    Playing = true;
                end
            end

            if not Playing then
                return;
            end

            local PlayerRole = getCharacterRole(Character)
            local OppositeTable = nil
            if PlayerRole == "Killer" then
                OppositeTable = Survivors
            elseif PlayerRole == "Survivor" then
                OppositeTable = Killers
            end

            local Target = nil
            local CurrentNearestDist = MaxDistance

            local OppTarget = nil
            local OppNearestDist = MaxDistance

            local function loopForOpp(t)
                for _,v in pairs(t) do
                    if v == Character or not v:FindFirstChild("HumanoidRootPart") or not v:FindFirstChild("Humanoid") then
                        continue
                    end
                    
                 
                    if WallCheckEnabled and not isTargetVisible(v) then
                        continue
                    end
                    
                    local modelName = v.Name
                    if OppositeTable and OppositeTable[modelName] then
                        local Dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        if Dist < OppNearestDist then
                            OppNearestDist = Dist
                            OppTarget = v
                        end
                    end
                end
            end

            if OppositeTable then
                loopForOpp(workspace.Players:GetDescendants())
                local npcsFolder = workspace.Map:FindFirstChild("NPCs", true)
                if npcsFolder then
                    loopForOpp(npcsFolder:GetChildren())
                end
            end

            local function loopAll(t)
                for _,v in pairs(t) do
                    if v == Character or not v:FindFirstChild("HumanoidRootPart") or not v:FindFirstChild("Humanoid") then
                        continue
                    end
                    
                   
                    if WallCheckEnabled and not isTargetVisible(v) then
                        continue
                    end
                    
                    local characterRole = getCharacterRole(v)
                    
                    if FilterSurvivors and characterRole == "Survivor" then
                        continue
                    end
                    if FilterKillers and characterRole == "Killer" then
                        continue
                    end
                    
                    if PlayerRole == "Killer" and characterRole == "Killer" then
                        continue
                    end
                    if PlayerRole == "Survivor" and characterRole == "Survivor" then
                        continue
                    end
                    
                    local Dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Dist < CurrentNearestDist then
                        CurrentNearestDist = Dist
                        Target = v
                    end
                end
            end

            local FinalTarget = nil
            if OppTarget then
                FinalTarget = OppTarget
            else
                loopAll(workspace.Players:GetDescendants())
                local npcsFolder2 = workspace.Map:FindFirstChild("NPCs", true)
                if npcsFolder2 then
                    loopAll(npcsFolder2:GetChildren())
                end
                FinalTarget = Target
            end

            if not FinalTarget then
                return;
            end

            local OldVelocity = HumanoidRootPart.Velocity;
            local NeededVelocity =
            (FinalTarget.HumanoidRootPart.Position + Vector3.new(
                RNG:NextNumber(-1.5, 1.5),
                0,
                RNG:NextNumber(-1.5, 1.5)
            ) + (FinalTarget.HumanoidRootPart.Velocity * (Player:GetNetworkPing() * 1.25))
                - HumanoidRootPart.Position
            ) / (Player:GetNetworkPing() * 2);

            HumanoidRootPart.Velocity = NeededVelocity;
            game:GetService('RunService').RenderStepped:Wait();
            HumanoidRootPart.Velocity = OldVelocity;
        end);
    end,
})




local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MVP = Tabs.Sat:AddLeftGroupbox("体力设置")

local StaminaSettings = {
    MaxStamina = 100,
    StaminaGain = 25,
    StaminaLoss = 10,
    SprintSpeed = 28,
    InfiniteGain = 9999
}

local SettingToggles = {
    MaxStamina = false,
    StaminaGain = false,
    StaminaLoss = false,
    SprintSpeed = false
}

local SprintingModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
local GetModule = function() return require(SprintingModule) end

task.spawn(function()
    while true do
        local m = GetModule()
        for key, value in pairs(StaminaSettings) do
            if SettingToggles[key] then
                m[key] = value
            end
        end
        task.wait(0.5)
    end
end)

local bai = {Spr = false}
local connection

MVP:AddCheckbox('MyToggle', {
    Text = '无限体力',
    Default = false,
    Tooltip = '无限体力',
    Callback = function(state)
        bai.Spr = state
        local Sprinting = GetModule()

        if state then
            Sprinting.StaminaLoss = 0
            Sprinting.StaminaGain = StaminaSettings.InfiniteGain

            if connection then connection:Disconnect() end
            connection = RunService.Heartbeat:Connect(function()
                if not bai.Spr then return end
                Sprinting.StaminaLoss = 0
                Sprinting.StaminaGain = StaminaSettings.InfiniteGain
            end)
        else
            Sprinting.StaminaLoss = 10
            Sprinting.StaminaGain = 25

            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

MVP:AddCheckbox('MaxStaminaToggle', {
    Text = '启用体力调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.MaxStamina = Value
    end
})

MVP:AddCheckbox('StaminaGainToggle', {
    Text = '启用体力恢复调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaGain = Value
    end
})

MVP:AddCheckbox('StaminaLossToggle', {
    Text = '启用体力消耗调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaLoss = Value
    end
})

MVP:AddCheckbox('SprintSpeedToggle', {
    Text = '启用奔跑速度调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.SprintSpeed = Value
    end
})

local MVP2 = Tabs.Sat:AddRightGroupbox("调试设置")

MVP2:AddSlider('InfStaminaGainSlider', {
    Text = '无限体力恢复速度',
    Default = 9999,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.InfiniteGain = Value
        if bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider1', {
    Text = '最大体力值',
    Default = 100,
    Min = 0,
    Max = 9999,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.MaxStamina = Value
        if SettingToggles.MaxStamina then
            local Sprinting = GetModule()
            Sprinting.MaxStamina = Value
        end
    end
})

MVP2:AddSlider('MySlider2', {
    Text = '体力恢复速度',
    Default = 25,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaGain = Value
        if SettingToggles.StaminaGain and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider3', {
    Text = '体力消耗速度',
    Default = 10,
    Min = 0,
    Max = 800,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaLoss = Value
        if SettingToggles.StaminaLoss and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaLoss = Value
        end
    end
})

MVP2:AddSlider('MySlider4', {
    Text = '奔跑速度',
    Default = 28,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.SprintSpeed = Value
        if SettingToggles.SprintSpeed then
            local Sprinting = GetModule()
            Sprinting.SprintSpeed = Value
        end
    end
})







local Generator = Tabs.zdx:AddLeftGroupbox("自动修机/演戏(事件)")


Generator:AddSlider("RepairSpeed", {
    Text = "修机速度 (s)",
    Default = 4,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(v)
        _G.CustomSpeed = v
    end
})

Generator:AddToggle("AutoGenerator",{
    Text = "自动修机",
    Default = false,
    Callback = function(v)
        _G.AutoGen = v
        task.spawn(function()
            while _G.AutoGen do
                if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PuzzleUI") then
                    local delayTime = _G.CustomSpeed or 4
                    
                    wait(delayTime)
                    
                    for _,v in ipairs(workspace["Map"]["Ingame"]["Map"]:GetChildren()) do
                        if v.Name == "Generator" then
                            v["Remotes"]["RE"]:FireServer()
                        end
                    end
                end
                wait()
            end
        end)
    end
})


local GeneratorGroup = Tabs.zdx:AddLeftGroupbox("自动修机/快速(事件)")

getgenv().AutoGenEnabled = false
getgenv().TimePerGenPhase = 1.25
getgenv().plr = LocalP

RSvc.RenderStepped:Connect(function()
	if not getgenv().AutoGenEnabled then return end
	if not plr.PlayerGui:FindFirstChild("PuzzleUI") then return end
	
	local char = plr.Character or plr.CharacterAdded:Wait()
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local closest, dist = nil, math.huge
	local mapFolder = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("Ingame")
		and workspace.Map.Ingame:FindFirstChild("Map")
		
	if mapFolder then
		for _, gen in ipairs(mapFolder:GetChildren()) do
			if gen:IsA("Model") and gen.Name == "Generator" and gen.PrimaryPart then
				local d = (root.Position - gen.PrimaryPart.Position).Magnitude
				if d < dist then
					closest, dist = gen, d
				end
			end
		end
	end
	
	if closest and closest:FindFirstChild("Remotes") and closest.Remotes:FindFirstChild("RE") then
		if not getgenv()._lastFire or tick() - getgenv()._lastFire >= getgenv().TimePerGenPhase then
			getgenv()._lastFire = tick()
			pcall(function() closest.Remotes.RE:FireServer() end)
		end
	end
end)

GeneratorGroup:AddCheckbox("AutoGenToggle", {
	Text = "自动修机",
	Tooltip = "自动发电机",
	Default = false,
	Callback = function(Value)
		getgenv().AutoGenEnabled = Value
	end,
})

GeneratorGroup:AddSlider("GenInterval", {
	Text = "修机间隔（s）",
	Default = 1.25,
	Min = 1,
	Max = 15,
	Rounding = 2,
	Compact = false,
	Callback = function(Value)
		getgenv().TimePerGenPhase = Value
	end,
	Tooltip = "修复时间",
})






local KillerSurvival = Tabs.zdx:AddRightGroupbox('传送修机[危险]')

KillerSurvival:AddButton({
    Text = '传送到发电机',
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local generators = workspace.Map.Ingame.Map:GetChildren()
        for _, generator in ipairs(generators) do
            if generator.Name == "Generator" and 
               generator:FindFirstChild("Progress") and 
               generator.Progress.Value < 100 then
                
                local generatorPart = generator:FindFirstChild("Main") or  
                                     generator:FindFirstChild("Model") or
                                     generator:FindFirstChild("Base")
                
                if generatorPart then
                    character.HumanoidRootPart.CFrame = generatorPart.CFrame + Vector3.new(0, 3, 0)
                    return  
                end
            end
        end
        warn("没有找到可修理的发电机")
    end
})




local ZZ = Tabs.zdx:AddRightGroupbox('切换服务器')

ZZ:AddButton({
    Text = "Switching server", 
    Func = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        
        local requestFunc = http_request or syn.request or request
        if not requestFunc then return end
            
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local response = requestFunc({Url = url, Method = "GET"})
        
        if response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data and #data.data > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, data.data[math.random(1, #data.data)].id, Players.LocalPlayer)
            end
        end
    end
})
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MapFolder = Workspace:WaitForChild("Map"):WaitForChild("Ingame")

local Settings = {
	Advanced = { Enabled = false, OutlineOnly = true, ShowNametag = false, Color = Color3.fromRGB(0, 255, 255) }
}

local Highlights = {}
local Nametags = {}

local AdvancedNames = {"BuildermanDispenser","BuildermanSentry","HumanoidRootProjectile","Swords","shockwave","Voidstar"}

local function CreateNametag(adornee, text, color)
	if Nametags[adornee] then Nametags[adornee]:Destroy() end
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = adornee
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = true
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0,0,0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 6
	textLabel.Parent = billboard
	billboard.Parent = adornee
	Nametags[adornee] = textLabel
end

local function AddHighlight(Obj, Config)
	if Highlights[Obj] then Highlights[Obj]:Destroy() end
	local hl = Instance.new("Highlight")
	hl.Adornee = Obj
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = Config.Enabled
	hl.OutlineColor = Config.Color
	hl.FillColor = Config.Color
	hl.OutlineTransparency = 0
	local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, Obj.Name)
	hl.FillTransparency = Config.OutlineOnly and 1 or (alwaysFill and 0.65 or 1)
	hl.Parent = Obj
	Highlights[Obj] = hl
	Obj.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if Highlights[Obj] then Highlights[Obj]:Destroy() Highlights[Obj] = nil end
			if Nametags[Obj] then Nametags[Obj].Parent:Destroy() Nametags[Obj] = nil end
		end
	end)
end

local function ApplyToTarget(target, Config)
	if not target or not target.Parent then return end
	AddHighlight(target, Config)
end

local function HandleAdvanced(obj)
	if table.find(AdvancedNames, obj.Name) or (obj.Name == "Shadow" and obj.Parent and obj.Parent.Name == "Shadows") then
		ApplyToTarget(obj, Settings.Advanced)
	end
end

-- 初始化时只遍历一次，后续通过事件监听
local function initializeAdvancedESP()
    for _, v in ipairs(MapFolder:GetDescendants()) do 
        if v.Parent then -- 检查父级仍然存在
            HandleAdvanced(v) 
        end
    end
end

-- 延迟初始化，避免阻塞
task.spawn(function()
    task.wait(1)
    pcall(initializeAdvancedESP)
end)

MapFolder.DescendantAdded:Connect(HandleAdvanced)

-- Advanced ESP更新循环 - 优化：只在启用时更新，减少不必要的循环
local advancedESPUpdateThread = task.spawn(function()
	while task.wait(0.8) do -- 进一步降低更新频率从0.5到0.8秒
		if not Settings.Advanced.Enabled then
			-- 如果禁用，清理所有高亮
			for obj, hl in pairs(Highlights) do
				if hl and hl.Parent then
					hl.Enabled = false
				end
			end
			continue
		end
		
		local config = Settings.Advanced
		local toRemove = {}
		for obj, hl in pairs(Highlights) do
			if not obj or not obj.Parent or not hl or not hl.Parent then
				table.insert(toRemove, obj)
				continue
			end
			hl.Enabled = config.Enabled
			hl.OutlineColor = config.Color
			hl.FillColor = config.Color
			hl.OutlineTransparency = 0
			local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, obj.Name)
			hl.FillTransparency = config.OutlineOnly and 1 or (alwaysFill and 0.65 or 1)
			
			if config.ShowNametag then
				local baseName = obj.Name
				if Nametags[obj] then
					Nametags[obj].Text = baseName
					Nametags[obj].TextColor3 = config.Color
				else
					CreateNametag(obj, baseName, config.Color)
				end
			else
				if Nametags[obj] then
					Nametags[obj].Parent:Destroy()
					Nametags[obj] = nil
				end
			end
		end
		-- 清理无效对象
		for _, obj in ipairs(toRemove) do
			Highlights[obj] = nil
			Nametags[obj] = nil
		end
	end
end)

local AdvancedGroup = Tabs.Esp:AddRightGroupbox("技能 Esp", "boxes")

AdvancedGroup:AddCheckbox("AdvancedESP", {
	Text = "ESP Skill",
	Default = false,
	Callback = function(Value)
		Settings.Advanced.Enabled = Value
	end,
})

AdvancedGroup:AddCheckbox("AdvancedOutline", {
	Text = "轮廓",
	Default = true,
	Callback = function(Value)
		Settings.Advanced.OutlineOnly = Value
	end,
})

AdvancedGroup:AddCheckbox("AdvancedNametag", {
	Text = "显示名称",
	Default = false,
	Callback = function(Value)
		Settings.Advanced.ShowNametag = Value
	end,
})

AdvancedGroup:AddLabel("Advanced 颜色"):AddColorPicker("AdvancedColor", {
	Default = Color3.fromRGB(0, 255, 255),
	Title = "颜色",
	Transparency = 0,
	Callback = function(Value)
		Settings.Advanced.Color = Value
	end,
})




local PlayerESPBox = Tabs.Esp:AddLeftGroupbox("玩家 ESP", "users")

PlayerESPBox:AddCheckbox("KillerESP", {
    Text = "杀手 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.killerESP = value
    end,
}):AddColorPicker("KillerColor", {
    Default = ESPSettings.killerColor,
    Title = "杀手颜色",
    Callback = function(value)
        ESPSettings.killerColor = value
    end,
})

PlayerESPBox:AddCheckbox("KillerSkinESP", {
    Text = "显示杀手皮肤名称",
    Default = false,
    Tooltip = "在杀手名称后显示皮肤名称",
    Callback = function(value)
        ESPSettings.killerSkinESP = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("KillerFillTransparency", {
    Text = "杀手填充透明度",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.killerFillTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("KillerOutlineTransparency", {
    Text = "杀手轮廓透明度",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.killerOutlineTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddDivider()

PlayerESPBox:AddCheckbox("SurvivorESP", {
    Text = "幸存者 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.playerESP = value
    end,
}):AddColorPicker("SurvivorColor", {
    Default = ESPSettings.survivorColor,
    Title = "幸存者颜色",
    Callback = function(value)
        ESPSettings.survivorColor = value
    end,
})

PlayerESPBox:AddCheckbox("SurvivorSkinESP", {
    Text = "显示幸存者皮肤名称",
    Default = false,
    Tooltip = "在幸存者名称后显示皮肤名称",
    Callback = function(value)
        ESPSettings.survivorSkinESP = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("SurvivorFillTransparency", {
    Text = "幸存者填充透明度",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.survivorFillTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("SurvivorOutlineTransparency", {
    Text = "幸存者轮廓透明度",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.survivorOutlineTransparency = value
        UpdateAllPlayerESPText()
    end,
})

-- 物品 ESP
local ObjectESPBox = Tabs.Esp:AddRightGroupbox("物品 ESP", "box")

ObjectESPBox:AddCheckbox("GeneratorESP", {
    Text = "发电机 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorESP = value
    end,
}):AddColorPicker("GeneratorColor", {
    Default = ESPSettings.generatorColor,
    Title = "发电机颜色",
    Callback = function(value)
        ESPSettings.generatorColor = value
    end,
})




ObjectESPBox:AddCheckbox("ItemESP", {
    Text = "物品 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.itemESP = value
    end,
}):AddColorPicker("ItemColor", {
    Default = ESPSettings.itemColor,
    Title = "物品颜色",
    Callback = function(value)
        ESPSettings.itemColor = value
    end,
})

ObjectESPBox:AddCheckbox("PizzaESP", {
    Text = "披萨 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaEsp = value
    end,
}):AddColorPicker("PizzaColor", {
    Default = ESPSettings.pizzaColor,
    Title = "披萨颜色",
    Callback = function(value)
        ESPSettings.pizzaColor = value
    end,
})



-- 特殊 ESP
local SpecialESPBox = Tabs.Esp:AddRightGroupbox("特殊 ESP", "zap")

SpecialESPBox:AddCheckbox("PizzaDeliveryESP", {
    Text = "披萨配送员[coolkid] ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryEsp = value
    end,
}):AddColorPicker("PizzaDeliveryColor", {
    Default = ESPSettings.pizzaDeliveryColor,
    Title = "披萨配送颜色",
    Callback = function(value)
        ESPSettings.pizzaDeliveryColor = value
    end,
})

SpecialESPBox:AddCheckbox("ZombieESP", {
    Text = "僵尸[1x4] ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieEsp = value
    end,
}):AddColorPicker("ZombieColor", {
    Default = ESPSettings.zombieColor,
    Title = "僵尸颜色",
    Callback = function(value)
        ESPSettings.zombieColor = value
    end,
})

SpecialESPBox:AddCheckbox("TripwireESP", {
    Text = "绊线 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.taphTripwireEsp = value
    end,
}):AddColorPicker("TripwireColor", {
    Default = ESPSettings.tripwireColor,
    Title = "绊线颜色",
    Callback = function(value)
        ESPSettings.tripwireColor = value
    end,
})

SpecialESPBox:AddCheckbox("TripMineESP", {
    Text = "地下空间炸弹 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.tripMineEsp = value
    end,
}):AddColorPicker("TripMineColor", {
    Default = ESPSettings.tripMineColor,
    Title = "诡雷颜色",
    Callback = function(value)
        ESPSettings.tripMineColor = value
    end,
})

SpecialESPBox:AddCheckbox("RespawnESP", {
    Text = "两次重生点 ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.twoTimeRespawnEsp = value
    end,
}):AddColorPicker("RespawnColor", {
    Default = ESPSettings.respawnColor,
    Title = "两次重生点颜色",
    Callback = function(value)
        ESPSettings.respawnColor = value
    end,
})

-- 追踪线
local TracerBox = Tabs.Esp:AddRightGroupbox("追踪线", "spline")

TracerBox:AddCheckbox("KillerTracers", {
    Text = "杀手追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.killerTracers = value
    end,
})

TracerBox:AddCheckbox("SurvivorTracers", {
    Text = "幸存者追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.survivorTracers = value
    end,
})

TracerBox:AddCheckbox("GeneratorTracers", {
    Text = "发电机追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorTracers = value
    end,
})

TracerBox:AddCheckbox("ItemTracers", {
    Text = "物品追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.itemTracers = value
    end,
})

TracerBox:AddCheckbox("PizzaTracers", {
    Text = "披萨追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaTracers = value
    end,
})

TracerBox:AddCheckbox("PizzaDeliveryTracers", {
    Text = "披萨配送追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryTracers = value
    end,
})

TracerBox:AddCheckbox("ZombieTracers", {
    Text = "僵尸追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieTracers = value
    end,
})

-- ESP性能设置
local PerformanceBox = Tabs.Esp:AddLeftGroupbox("ESP性能设置", "settings")

PerformanceBox:AddSlider("MaxDistance", {
    Text = "最大绘制距离",
    Default = 300,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Tooltip = "只绘制此距离内的ESP对象，降低可减少卡顿",
    Callback = function(value)
        ESPSettings.maxDistance = value
    end,
})

PerformanceBox:AddSlider("MaxESPCount", {
    Text = "最大ESP数量",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = true,
    Tooltip = "同时绘制的最大ESP数量，降低可减少卡顿",
    Callback = function(value)
        ESPSettings.maxESPCount = value
    end,
})






local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local removeEffectsEnabled = false
local lightingConnection = nil
local workspaceConnection = nil
local lightingTargets = {
    "BlindnessBlur",
    "SubspaceVFXBlur", 
    "SubspaceVFXColorCorrection"
}
local workspaceTargets = {
    "GlitchParts"
}

local function removeLightingInstances()
    for _, name in ipairs(lightingTargets) do
        local obj = Lighting:FindFirstChild(name)
        if obj then
            obj:Destroy()
        end
    end
end

local function removeWorkspaceInstances()
    for _, name in ipairs(workspaceTargets) do
        local obj = Workspace:FindFirstChild(name)
        if obj then
            obj:Destroy()
        end
    end
end

local function enableRemoveEffects()
    removeLightingInstances()
    removeWorkspaceInstances()
    lightingConnection = Lighting.ChildAdded:Connect(function(child)
        if table.find(lightingTargets, child.Name) then
            child:Destroy()
        end
    end)
    workspaceConnection = Workspace.ChildAdded:Connect(function(child)
        if table.find(workspaceTargets, child.Name) then
            child:Destroy()
        end
    end)
    removeEffectsEnabled = true
end

local function disableRemoveEffects()
    if lightingConnection then
        lightingConnection:Disconnect()
        lightingConnection = nil
    end
    if workspaceConnection then
        workspaceConnection:Disconnect()
        workspaceConnection = nil
    end
    removeEffectsEnabled = false
end



local v437 = Tabs.ani:AddLeftGroupbox("通用反效果", "shield")




v437:AddToggle("AntiHealthGlitch", {
    Text = "反血量故障",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiHealthGlitch.Value and task.wait() do
                local l_TemporaryUI_1 = l_l_LocalPlayer_1_2.PlayerGui:FindFirstChild("TemporaryUI")
                for _, v442 in pairs(l_TemporaryUI_1:GetChildren()) do
                    if v442.Name == "Frame" and v442:FindFirstChild("Glitched") then
                        v442:Destroy()
                    end
                end
            end
        end)
    end
})

v437:AddToggle("AntiStun", {
    Text = "反眩晕",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiStun.Value and task.wait() do
                if l_l_LocalPlayer_1_2.Character and l_l_LocalPlayer_1_2.Character:FindFirstChild("SpeedMultipliers") and l_l_LocalPlayer_1_2.Character.SpeedMultipliers:FindFirstChild("Stunned") then
                    l_l_LocalPlayer_1_2.Character.SpeedMultipliers:FindFirstChild("Stunned").Value = 1
                end
            end
        end)
    end
})

v437:AddToggle("AntiSlow", {
    Text = "反减速",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiSlow.Value and task.wait() do
                if l_l_LocalPlayer_1_2.Character and l_l_LocalPlayer_1_2.Character:FindFirstChild("SpeedMultipliers") then
                    for _, v445 in l_l_LocalPlayer_1_2.Character.SpeedMultipliers:GetChildren() do
                        if v445.Value < 1 then
                            v445.Value = 1
                        end
                    end
                end
            end
        end)
    end
})

v437:AddToggle("RemoveBlindnessToggle", {
    Text = "反地下空间炸弹效果",
    Default = false,
    Callback = function(state)
        if state then
            enableRemoveEffects()
        else
            disableRemoveEffects()
        end
    end
})

v437:AddToggle("RemoveBlindness", {
    Text = "反失明", 
    Default = false,
    Callback = function(v)
        if not _G.BlindnessCleanup then _G.BlindnessCleanup = {} end
        local connections = _G.BlindnessCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.BlindnessCleanup = {}

        if not v then return end

        local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
        local statusEffects = modulesFolder and modulesFolder:FindFirstChild("StatusEffects")
        
        if not statusEffects then
            warn("未找到 ReplicatedStorage.Modules.StatusEffects 路径")
            return
        end
        
        local function RemoveBlindness()
            local blindness = statusEffects:FindFirstChild("Blindness")
            if blindness then
                blindness:Destroy()
            end
        end

        task.spawn(RemoveBlindness)

        connections.heartbeat = RunService.Heartbeat:Connect(function()
            task.wait(1.5)
            RemoveBlindness()
        end)

        connections.descendantAdded = statusEffects.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Blindness" then
                task.wait(0.1)
                descendant:Destroy()
            end
        end)
    end
})


v437:AddToggle("AntiHiddenStats", {
    Text = "反隐藏数据",
    Default = false,
    Callback = function(v472)
        toggleState = v472
        for _, v469 in ipairs(l_Players_1:GetPlayers()) do
            if v472 then
                for _, v461 in ipairs({"HideKillerWins", "HidePlaytime", "HideSurvivorWins"}) do
                    v469.PlayerData.Settings.Privacy:FindFirstChild(v461).Value = false
                end
            end
        end
    end
})

local ZZ2 = Tabs.ani:AddRightGroupbox('NOOB 反效果')

ZZ2:AddToggle("RemoveSlateskin", {
    Text = "反Noob石板速度", 
    Default = false,
    Callback = function(v)
        if not _G.SlateskinCleanup then _G.SlateskinCleanup = {} end
        local connections = _G.SlateskinCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlateskinCleanup = {}

        if not v then return end

        local function CleanSlateskins()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            local survivorList = survivorsFolder:GetChildren()
            for i = 1, #survivorList, 5 do
                task.spawn(function()
                    for j = i, math.min(i + 4, #survivorList) do
                        local survivor = survivorList[j]
                        local slateskin = survivor:FindFirstChild("SlateskinStatus")
                        if slateskin then
                            slateskin:Destroy()
                        end
                    end
                end)
            end
        end

        task.spawn(CleanSlateskins)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(2)
            CleanSlateskins()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "SlateskinStatus" then
                    descendant:Destroy()
                end
            end)
        end
    end
})




local Disabled = Tabs.ani:AddLeftGroupbox('访客反效果')

Disabled:AddToggle("RemoveSlowed", {
    Text = "反缓慢", 
    Default = false,
    Callback = function(v)
        if not _G.SlowedCleanup then _G.SlowedCleanup = {} end
        local connections = _G.SlowedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlowedCleanup = {}

        if not v then return end

        local function CleanSlowedStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "SlowedStatus" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanSlowedStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanSlowedStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "SlowedStatus" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveBlockingSlow", {
    Text = "反格挡速度", 
    Default = false,
    Callback = function(v)
        if not _G.BlockingCleanup then _G.BlockingCleanup = {} end
        local connections = _G.BlockingCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.BlockingCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "ResistanceStatus" or survivor.Name == "GuestBlocking" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "ResistanceStatus" or descendant.Name == "GuestBlocking" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemovePunchSlow", {
    Text = "反拳击速度", 
    Default = false,
    Callback = function(v)
        if not _G.PunchCleanup then _G.PunchCleanup = {} end
        local connections = _G.PunchCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.PunchCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "ResistanceStatus" or survivor.Name == "PunchAbility" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "ResistanceStatus" or descendant.Name == "PunchAbility" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveChargeEnded", {
    Text = "反冲刺结束后效果", 
    Default = false,
    Callback = function(v)
        if not _G.ChargeEndedCleanup then _G.ChargeEndedCleanup = {} end
        local connections = _G.ChargeEndedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.ChargeEndedCleanup = {}

        if not v then return end

        local function CleanChargeEndedEffects()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "GuestChargeEnded" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanChargeEndedEffects)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanChargeEndedEffects()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "GuestChargeEnded" then
                    descendant:Destroy()
                end
            end)
        end
    end
})





getgenv().Players = game:GetService("Players")
getgenv().LocalPlayer = getgenv().Players.LocalPlayer

if not getgenv().originalNamecall then
   getgenv().HookRules = {}
   getgenv().originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
       local method = getnamecallmethod()
       local args = {...}
       if method == "FireServer" then
           for _, rule in ipairs(getgenv().HookRules) do
               if (not rule.remoteName or self.Name == rule.remoteName) then
                   if not rule.blockedFirstArg or args[1] == rule.blockedFirstArg then
                       if rule.block then
                           return
                       end
                   end
               end
           end
       end
       return getgenv().originalNamecall(self, ...)
   end)
end

getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
   for _, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           return
       end
   end
   table.insert(getgenv().HookRules, {
       remoteName = remoteName,
       blockedFirstArg = blockedFirstArg,
       block = true
   })
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
   for i, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           table.remove(getgenv().HookRules, i)
           break
       end
   end
end

getgenv().isFiringDusekkar = false

getgenv().EnableProtection = function()
   getgenv().activateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "DusekkarCancel")
   if not getgenv().isFiringDusekkar then
       getgenv().isFiringDusekkar = true
       task.spawn(function()
           task.wait(4)
           local ReplicatedStorage = game:GetService("ReplicatedStorage")
           local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
           RemoteEvent:FireServer({game.Players.LocalPlayer.Name .. "DusekkarCancel"})
           getgenv().isFiringDusekkar = false
       end)
   end
end

getgenv().DisableProtection = function()
   getgenv().deactivateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "DusekkarCancel")
end



local DusekkarGroup = Tabs.ani:AddLeftGroupbox("Dusekkar", "user")

DusekkarGroup:AddCheckbox("ProtectionDusekkar", {
   Text = "反取消保护",
   Default = false,
   Tooltip = "防止护盾被取消",
   Callback = function(Value)
       if Value then
           getgenv().EnableProtection()
       else
           getgenv().DisableProtection()
       end
   end
})





local C00lkiddGroup = Tabs.ani:AddLeftGroupbox("c00lkidd", "user")


C00lkiddGroup:AddCheckbox("WalkspeedController", {
    Text = "速度覆盖控制器",
    Default = false,
    Callback = function(value)
        if value then
            globalEnv.connection = globalEnv.RunService.Heartbeat:Connect(globalEnv.onHeartbeat)
        else
            if globalEnv.connection then
                globalEnv.connection:Disconnect()
            end
        end
    end
})

C00lkiddGroup:AddCheckbox("IgnoreObjectables", {
    Text = "无视障碍物",
    Default = false,
    Callback = function(Value)
        if Value then
            getgenv().EnableC00lkidd()
        else
            getgenv().DisableC00lkidd()
        end
    end
})

C00lkiddGroup:AddSlider("WalkSpeed", {
    Text = "移动速度",
    Default = 100,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        globalEnv.walkSpeed = Value
    end
})



local ZZ = Tabs.ani:AddRightGroupbox('1x4')local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AutoPopup = {
    Enabled = false,
    Task = nil,
    Connections = {},
    Interval = 0.5
}

local function deletePopups()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then
        return false
    end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
    if not tempUI then
        return false
    end
    
    local deleted = false
    for _, popup in ipairs(tempUI:GetChildren()) do
        if popup.Name == "1x1x1x1Popup" then
            popup:Destroy()
            deleted = true
        end
    end
    return deleted
end

local function triggerEntangled()
    pcall(function()
        ReplicatedStorage.Modules.Network.RemoteEvent:FireServer("Entangled", {})
    end)
end

local function setupPopupListener()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then return end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
    if not tempUI then
        tempUI = Instance.new("Folder")
        tempUI.Name = "TemporaryUI"
        tempUI.Parent = LocalPlayer.PlayerGui
    end
    
    if AutoPopup.Connections.ChildAdded then
        AutoPopup.Connections.ChildAdded:Disconnect()
    end
    
    AutoPopup.Connections.ChildAdded = tempUI.ChildAdded:Connect(function(child)
        if AutoPopup.Enabled and child.Name == "1x1x1x1Popup" then
            task.defer(function()
                child:Destroy()
                triggerEntangled()
            end)
        end
    end)
end

local function runMainTask()
    while AutoPopup.Enabled do
        deletePopups()
        task.wait(AutoPopup.Interval)
    end
end

local function startAutoPopup()
    if AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = true
    setupPopupListener()
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
    end
    AutoPopup.Task = task.spawn(runMainTask)
end

local function stopAutoPopup()
    if not AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = false
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
        AutoPopup.Task = nil
    end
    
    for _, connection in pairs(AutoPopup.Connections) do
        connection:Disconnect()
    end
    AutoPopup.Connections = {}
end

ZZ:AddSlider('AutoPopupInterval', {
    Text = '执行间隔(s)',
    Default = 0.5,
    Min = 0.5,
    Max = 2,
    Rounding = 0,
    Tooltip = '设置自动执行的间隔时间(1-5秒)',
    Callback = function(value)
        AutoPopup.Interval = value
    end
})

ZZ:AddCheckbox('AutoPopupToggle', {
    Text = '反弹窗',
    Default = false,
    Tooltip = '去除弹窗和懒惰效果',
    Callback = function(state)
        if state then
            startAutoPopup()
        else
            stopAutoPopup()
        end
    end
})

if LocalPlayer then
    LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
        if not LocalPlayer.Parent then
            stopAutoPopup()
        end
    end)
end



local NoliGroup = Tabs.ani:AddLeftGroupbox("Noli", "user")




local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local noliDeleterActive = false
local deletionConnection = nil
local allowedNoli = nil
local isVoidRushCrashed = false
local characterCheckLoop = nil

local function deleteNewNoli()
    local killers = workspace:WaitForChild("Players"):WaitForChild("Killers")
    
    allowedNoli = killers:FindFirstChild("Noli")
    if not allowedNoli then
        return
    end
    
    if deletionConnection then
        deletionConnection:Disconnect()
        deletionConnection = nil
    end
    
    deletionConnection = RunService.Heartbeat:Connect(function()
        allowedNoli = killers:FindFirstChild("Noli")
        
        if not allowedNoli then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            return
        end
        
        for _, child in killers:GetChildren() do
            if child.Name == "Noli" and child ~= allowedNoli then
                child:Destroy()
            end
        end
    end)
end

local function manageVoidRushState(character)
    while isVoidRushCrashed and character and character.Parent do
        character:SetAttribute("VoidRushState", "Crashed")
        task.wait(0.5)
    end
end



NoliGroup:AddCheckbox("NoliDeleter", {
    Text = "反假Noli",
    Default = false,
    Callback = function(enabled)
        noliDeleterActive = enabled
        
        if enabled then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            
            local success = pcall(deleteNewNoli)
            
            if not success then
                noliDeleterActive = false
            end
        else
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            allowedNoli = nil
        end
    end
})

NoliGroup:AddCheckbox("無視障礙[Noli]", {
    Text = "Noli无视障碍",
    Default = false,
    Callback = function(enabled)
        isVoidRushCrashed = enabled
        local character = player.Character
        
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
            characterCheckLoop = nil
        end
        
        if enabled then
            if character then
                characterCheckLoop = task.spawn(function()
                    manageVoidRushState(character)
                end)
            end
        else
            if character then
                character:SetAttribute("VoidRushState", nil)
            end
        end
    end
})

local killers = workspace:WaitForChild("Players"):WaitForChild("Killers")

killers.ChildAdded:Connect(function(child)
    if noliDeleterActive and child.Name == "Noli" and not deletionConnection then
        task.wait(0.5)
        if noliDeleterActive and not deletionConnection then
            deleteNewNoli()
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    if isVoidRushCrashed then
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
        end
        characterCheckLoop = task.spawn(function()
            manageVoidRushState(newCharacter)
        end)
    end
end)








local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

local Settings = {
    SilentAim = false,
    WallCheck = false,
    FilterKillers = false,
    FilterSurvivors = false
}

local function getTargetPosition()
    if not Settings.SilentAim then return nil end
    
    local targetPosition, shortestDistance = nil, 100
    
    local function isValidTarget(model, humanoidRootPart)
        if Settings.WallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {Character, model}
            rayParams.IgnoreWater = true
            
            local direction = humanoidRootPart.Position - RootPart.Position
            local rayResult = workspace:Raycast(
                RootPart.Position,
                direction.Unit * direction.Magnitude,
                rayParams
            )
            
            if rayResult and not rayResult.Instance:IsDescendantOf(model) then
                return false
            end
        end
        
        if Settings.FilterKillers then
            local killersFolder = workspace.Players:FindFirstChild("Killers")
            if killersFolder and model:IsDescendantOf(killersFolder) then
                return false
            end
        end
        
        if Settings.FilterSurvivors then
            local survivorsFolder = workspace.Players:FindFirstChild("Survivors")
            if survivorsFolder and model:IsDescendantOf(survivorsFolder) then
                return false
            end
        end
        
        return true
    end

    -- 优化：只检查Players文件夹，而不是整个workspace
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        local killersFolder = playersFolder:FindFirstChild("Killers")
        local survivorsFolder = playersFolder:FindFirstChild("Survivors")
        local foldersToCheck = {}
        if killersFolder then table.insert(foldersToCheck, killersFolder) end
        if survivorsFolder then table.insert(foldersToCheck, survivorsFolder) end
        
        for _, folder in ipairs(foldersToCheck) do
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model ~= Character then
                    local humanoid = model:FindFirstChild("Humanoid")
                    local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and humanoidRootPart and humanoid.Health > 0 then
                        if isValidTarget(model, humanoidRootPart) then
                            local distance = (RootPart.Position - humanoidRootPart.Position).Magnitude
                            if distance < shortestDistance then
                                targetPosition, shortestDistance = humanoidRootPart.Position, distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return targetPosition
end


local SM = Tabs.aim:AddLeftGroupbox("无声瞄准")

SM:AddToggle("SilentAimToggle", {
    Text = "静默瞄准",
    Default = false,
    Callback = function(state)
        Settings.SilentAim = state
    end
})

SM:AddCheckbox("WallCheckToggle", {
    Text = "墙壁检测",
    Default = false,
    Callback = function(state)
        Settings.WallCheck = state
    end
})

SM:AddCheckbox("FilterKillersToggle", {
    Text = "排除杀手",
    Default = false,
    Callback = function(state)
        Settings.FilterKillers = state
    end
})

SM:AddCheckbox("FilterSurvivorsToggle", {
    Text = "排除幸存者",
    Default = false,
    Callback = function(state)
        Settings.FilterSurvivors = state
    end
})

task.wait(1)

local success, module = pcall(require, ReplicatedStorage.Systems.Player.Miscellaneous.GetPlayerMousePosition)

if success then
    if typeof(module) == "function" then
        local originalFunction = module
        ReplicatedStorage.Systems.Player.Miscellaneous.GetPlayerMousePosition = function(...)
            return getTargetPosition() or originalFunction(...)
        end
    elseif typeof(module) == "table" then
        for key, value in pairs(module) do
            if typeof(value) == "function" then
                local originalMethod = value
                module[key] = function(...)
                    return getTargetPosition() or originalMethod(...)
                end
            end
        end
    end
end

SM:AddLabel("支持角色:\n\n dusek ，Coolkkid，Noli  远程技能", true)
 





 local ChanceGroup = Tabs.aim:AddRightGroupbox('机会预判自瞄')


do
	local PredictionAim = {
		Enabled = false,
		Prediction = 4,
		Duration = 1.7,
		Targets = { "Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Slasher","Sixer","Nosferatu" },
		TrackedAnimations = {
			["103601716322988"] = true, ["133491532453922"] = true, ["86371356500204"] = true,
			["76649505662612"] = true, ["81698196845041"] = true
		}
	}

	local Humanoid, HRP, LastTriggerTime, IsAiming, OriginalState

	local function CreateUI()
		ChanceGroup:AddCheckbox("AimToggle", {
			Text = "开枪瞄准",
			Default = false,
			Callback = function(Value)
				PredictionAim.Enabled = Value
			end,
		})
		ChanceGroup:AddSlider("PredictionSlider", {
			Text = "预判系数",
			Default = 4,
			Min = 0,
			Max = 15,
			Rounding = 1,
			Callback = function(Value)
				PredictionAim.Prediction = Value
			end,
		})
	end

	local function getValidTarget()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        local targets = PredictionAim.Targets
        for i = 1, #targets do
            local target = killersFolder:FindFirstChild(targets[i])
            if target and target:FindFirstChild("HumanoidRootPart") then
                return target.HumanoidRootPart
            end
        end
    end
    return nil
end

local function getPlayingAnimationIds()
    local ids = {}
    if Humanoid then
        local tracks = Humanoid:GetPlayingAnimationTracks()
        for i = 1, #tracks do
            local track = tracks[i]
            local anim = track.Animation
            if anim and anim.AnimationId then
                local id = anim.AnimationId:match("%d+")
                if id then ids[id] = true end
            end
        end
    end
    return ids
end

local function setupCharacter(char)
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end

local function OnRenderStep()
    if not PredictionAim.Enabled or not Humanoid or not HRP then return end
    
    local currentTime = tick()
    local playing = getPlayingAnimationIds()
    local triggered = false
    
    for id in pairs(PredictionAim.TrackedAnimations) do
        if playing[id] then 
            triggered = true
            break 
        end
    end

    if triggered then
        LastTriggerTime = currentTime
        IsAiming = true
    end

    if IsAiming and currentTime - LastTriggerTime <= PredictionAim.Duration then
        if not OriginalState then
            OriginalState = {
                WalkSpeed = Humanoid.WalkSpeed,
                JumpPower = Humanoid.JumpPower,
                AutoRotate = Humanoid.AutoRotate
            }
            Humanoid.AutoRotate = false
            HRP.AssemblyAngularVelocity = Vector3.zero
        end
        
        local targetHRP = getValidTarget()
        if targetHRP then
            local predictedPos = targetHRP.Position + (targetHRP.CFrame.LookVector * PredictionAim.Prediction)
            local direction = (predictedPos - HRP.Position).Unit
            local yRot = math.atan2(-direction.X, -direction.Z)
            HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
        end
    elseif IsAiming then
        IsAiming = false
        if OriginalState then
            Humanoid.WalkSpeed = OriginalState.WalkSpeed
            Humanoid.JumpPower = OriginalState.JumpPower
            Humanoid.AutoRotate = OriginalState.AutoRotate
            OriginalState = nil
        end
    end
end

local function OnRemoteEvent(eventName, eventArg)
    if not PredictionAim.Enabled then return end
    if eventName == "UseActorAbility" and type(eventArg) == "table" and eventArg[1] and tostring(eventArg[1]) == buffer.fromstring("\"Shoot\"") then
        LastTriggerTime = tick()
        IsAiming = true
    end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)
CreateUI()
RunService.RenderStepped:Connect(OnRenderStep)
game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent.OnClientEvent:Connect(OnRemoteEvent)

end





local ZZ = Tabs.Main:AddRightGroupbox('玩家移动')
local CFSpeed = 50
local CFLoop = nil
local RunService = game:GetService("RunService")


local speedValue = 0
_G.SpeedToggle = false

ZZ:AddSlider("SpeedBypass", {
    Text = "速度调节",
    Default = 16,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        speedValue = value
    end
})

ZZ:AddToggle("SpeedToggle", {
    Text = "速度黑客",
    Default = false,
    Callback = function(state)
        _G.SpeedToggle = state
        task.spawn(function()
            local LocalPlayer = game.Players.LocalPlayer
            while task.wait() and _G.SpeedToggle do
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.MoveDirection ~= Vector3.zero then
                    LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * speedValue * game:GetService("RunService").RenderStepped:Wait())
                end
            end
        end)
    end
})




local noclipParts = {}
_G.noclipState = false

local function enableNoclip()
    local LocalPlayer = game.Players.LocalPlayer
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                noclipParts[part] = part
                part.CanCollide = false
            end
        end
    end
end

local function disableNoclip()
    for _, part in pairs(noclipParts) do
        part.CanCollide = true
    end
end

ZZ:AddToggle("EnableNoclip", {
    Text = "穿墙",
    Default = false,
    Callback = function(state)
        _G.noclipState = state
        task.spawn(function()
            while task.wait() do
                if _G.noclipState then
                    enableNoclip()
                else
                    disableNoclip()
                    break
                end
            end
        end)
    end
})


local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    if CFLoop then 
        CFLoop:Disconnect() 
        CFLoop = nil
    end
    
    local function isCharacterValid()
        if not character or not character.Parent then return false end
        if not humanoid or humanoid.Parent ~= character then return false end
        if not head or head.Parent ~= character then return false end
        return true
    end
    
    CFLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not isCharacterValid() then 
            if CFLoop then 
                CFLoop:Disconnect() 
                CFLoop = nil
            end
            return 
        end
        
        local moveDirection = humanoid.MoveDirection
        local headCFrame = head.CFrame
        local camera = workspace.CurrentCamera
        
        if not camera then return end
        
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition = cameraCFrame.Position
        local headPosition = headCFrame.Position

        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection * (CFSpeed * deltaTime))
        
        if isCharacterValid() then
            head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end
    end)
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    if CFLoop then
        CFLoop:Disconnect()
        CFLoop = nil
    end
    
    if character and character.Parent then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        if head then
            head.Anchored = false
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    StopCFly()
end)

ZZ:AddToggle("CFlyToggle", {
    Text = "飞行",
    Default = false,
    Callback = function(Value)
        if Value then
            task.wait(0.1)
            StartCFly()
        else
            StopCFly()
        end
    end
})

ZZ:AddSlider("CFlySpeed", {
    Text = "飞行速度",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        CFSpeed = Value
    end
})




ZZ:AddLabel("以上均绕过 / 暴力使用")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local SpoofActive = false
local TargetCFrame = nil
local OriginalCallback = nil
local HookInstalled = false

local function formatCFrame(cf)
    if not cf then return nil end
    local pos, look = cf.Position, cf.LookVector
    return string.format("%0.3f/%0.3f/%0.3f/%0.3f/%0.3f/%0.3f", 
        pos.X, pos.Y, pos.Z, look.X, look.Y, look.Z)
end

local function installHook()
    if HookInstalled then return end
    
    local success, networkModule = pcall(require, ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"))
    if not success or not networkModule then return end
    
    if networkModule.SetConnection then
        local originalSetConnection = networkModule.SetConnection
        
        networkModule.SetConnection = function(self, key, connType, callback)
            if key == "GetLocalPosData" and connType == "REMOTE_FUNCTION" then
                OriginalCallback = callback
                
                local wrappedCallback = function(...)
                    if SpoofActive and TargetCFrame then
                        return formatCFrame(TargetCFrame)
                    end
                    if OriginalCallback then
                        return OriginalCallback(...)
                    end
                    local char = LocalPlayer.Character
                    if char and char.PrimaryPart then
                        return formatCFrame(char.PrimaryPart.CFrame)
                    end
                    return nil
                end
                
                return originalSetConnection(self, key, connType, wrappedCallback)
            end
            return originalSetConnection(self, key, connType, callback)
        end
        
        HookInstalled = true
    end
end

local function setupSpoof()
    installHook()
    
    local char = LocalPlayer.Character
    if char and char.PrimaryPart then
        TargetCFrame = char.PrimaryPart.CFrame
        SpoofActive = true
    end
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("HumanoidRootPart")
        if SpoofActive then
            TargetCFrame = newChar.HumanoidRootPart.CFrame
        end
    end)
end

task.spawn(function()
    task.wait(1)
    setupSpoof()
end)

local SpoofTab = Tabs.Main:AddLeftGroupbox("服务器绕过[速度]")

SpoofTab:AddToggle("SpoofToggle", {
    Text = "位置欺骗",
    Default = false,
    Callback = function(state)
        SpoofActive = state
        if state then
            local char = LocalPlayer.Character
            if char and char.PrimaryPart then
                TargetCFrame = char.PrimaryPart.CFrame
            end
        end
    end
})



local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("调试")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,  
    Text = "快捷菜单",
    Callback = function(value)
        Library.KeybindFrame.Visible = value  
    end,
})


MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "鼠标光标",
    Default = true,  
    Callback = function(Value)
        Library.ShowCustomCursor = Value  
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",  
    Text = "通知位置",
    Callback = function(Value)
        Library:SetNotifySide(Value)  
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "75%",  
    Text = "UI大小",
    Callback = function(Value)
        Value = Value:gsub("%%", "")  
        local DPI = tonumber(Value)   
        Library:SetDPIScale(DPI)      
    end,
})


MenuGroup:AddDivider()  
MenuGroup:AddLabel("Menu bind")  
    :AddKeyPicker("MenuKeybind", { 
        Default = "RightShift",  
        NoUI = true,            
        Text = "Menu keybind"    
    })


MenuGroup:AddButton("销毁UI", function()
    Library:Unload()  
end)




ThemeManager:SetLibrary(Library)  
SaveManager:SetLibrary(Library)   
SaveManager:IgnoreThemeSettings() 


SaveManager:SetIgnoreIndexes({ "MenuKeybind" })  
ThemeManager:SetFolder("MyScriptHub")            
SaveManager:SetFolder("MyScriptHub/specific-game")  
SaveManager:SetSubFolder("specific-place")       
SaveManager:BuildConfigSection(Tabs["UI Settings"])  

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()





-- 首先，确保有一个完整的 OnUnload 回调
Library.OnUnload = function()
	_G.VoidsakenExecuted = false
	panic()
	
	pcall(function()
		if getgenv().FlipUI then getgenv().FlipUI:Destroy() end
		if getgenv().AimbotUI then getgenv().AimbotUI:Destroy() end
		if getgenv().BlockUI then getgenv().BlockUI:Destroy() end
	end)
	
	-- 清理所有连接和资源
	if ESPUpdateThread then task.cancel(ESPUpdateThread) end
	if tracerUpdateConnection then tracerUpdateConnection:Disconnect() end
	if advancedESPUpdateThread then task.cancel(advancedESPUpdateThread) end
	
	-- 清理ESP数据
	for i = #PlayerESPData, 1, -1 do
		RemoveESP(PlayerESPData[i].model)
	end
	for i = #ObjectESPData, 1, -1 do
		RemoveESP(ObjectESPData[i].model)
	end
	for model in pairs(TracerData) do
		RemoveTracer(model)
	end
	
	-- 清理缓存
	ESPCache = {}
end


    Library:SetWatermarkVisibility(true)

    local function updateWatermark()
        local fps = 60
        local frameTimer = tick()
        local frameCounter = 0

        game:GetService('RunService').RenderStepped:Connect(function()
            frameCounter = frameCounter + 1

            if ((tick() - frameTimer) >= 1) then
                fps = frameCounter
                frameTimer = tick()
                frameCounter = 0
            end

            Library:SetWatermark(string.format('YG SCRIPT | %d FPS | 怀YG | %d ping ', math.floor(fps), math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())))
        end)
    end

    updateWatermark()



