local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local rainbowBorderAnimation
local currentBorderColorScheme = "彩虹颜色"
local currentFontColorScheme = "彩虹颜色"
local borderInitialized = false
local animationSpeed = 2
local borderEnabled = true
local fontColorEnabled = false
local uiScale = 1
local blurEnabled = false
local soundEnabled = true

local FONT_STYLES = {
    "SourceSansBold","SourceSansItalic","SourceSansLight","SourceSans",
    "GothamSSm","GothamSSm-Bold","GothamSSm-Medium","GothamSSm-Light",
    "GothamSSm-Black","GothamSSm-Book","GothamSSm-XLight","GothamSSm-Thin",
    "GothamSSm-Ultra","GothamSSm-SemiBold","GothamSSm-ExtraLight","GothamSSm-Heavy",
    "GothamSSm-ExtraBold","GothamSSm-Regular","Gotham","GothamBold",
    "GothamMedium","GothamBlack","GothamLight","Arial","ArialBold",
    "Code","CodeLight","CodeBold","Highway","HighwayBold","HighwayLight",
    "SciFi","SciFiBold","SciFiItalic","Cartoon","CartoonBold","Handwritten"
}

local FONT_DESCRIPTIONS = {
    ["SourceSansBold"] = "标准粗体",["SourceSansItalic"] = "斜体",["SourceSansLight"] = "细体",
    ["SourceSans"] = "标准体",["GothamSSm"] = "哥特标准",["GothamSSm-Bold"] = "哥特粗体",
    ["GothamSSm-Medium"] = "哥特中等",["GothamSSm-Light"] = "哥特细体",["GothamSSm-Black"] = "哥特黑体",
    ["GothamSSm-Book"] = "哥特书本体",["GothamSSm-XLight"] = "哥特超细体",["GothamSSm-Thin"] = "哥特极细体",
    ["GothamSSm-Ultra"] = "哥特超黑体",["GothamSSm-SemiBold"] = "哥特半粗体",["GothamSSm-ExtraLight"] = "哥特特细体",
    ["GothamSSm-Heavy"] = "哥特粗重体",["GothamSSm-ExtraBold"] = "哥特特粗体",["GothamSSm-Regular"] = "哥特常规体",
    ["Gotham"] = "经典哥特体",["GothamBold"] = "经典哥特粗体",["GothamMedium"] = "经典哥特中等",
    ["GothamBlack"] = "经典哥特黑体",["GothamLight"] = "经典哥特细体",["Arial"] = "标准Arial体",
    ["ArialBold"] = "Arial粗体",["Code"] = "代码字体",["CodeLight"] = "代码细体",
    ["CodeBold"] = "代码粗体",["Highway"] = "高速公路体",["HighwayBold"] = "高速公路粗体",
    ["HighwayLight"] = "高速公路细体",["SciFi"] = "科幻字体",["SciFiBold"] = "科幻粗体",
    ["SciFiItalic"] = "科幻斜体",["Cartoon"] = "卡通字体",["CartoonBold"] = "卡通粗体",
    ["Handwritten"] = "手写体"
}

local currentFontStyle = "SourceSansBold"

local COLOR_SCHEMES = {
    ["彩虹颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE"))}),"palette"},
    ["黑红颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1, Color3.fromHex("000000"))}),"alert-triangle"},
    ["蓝白颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FFFFFF")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFFFFF"))}),"droplet"},
    ["紫金颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFD700"))}),"crown"},
    ["蓝黑颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("000000"))}),"moon"},
    ["绿紫颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("800080")),ColorSequenceKeypoint.new(1, Color3.fromHex("00FF00"))}),"zap"},
    ["粉蓝颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00BFFF")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF69B4"))}),"heart"},
    ["橙青颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00CED1")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF4500"))}),"sun"},
    ["红金颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF0000"))}),"award"},
    ["银蓝颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("4682B4")),ColorSequenceKeypoint.new(1, Color3.fromHex("C0C0C0"))}),"star"},
    ["霓虹颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(0.25, Color3.fromHex("00FFFF")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.75, Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("00FFFF"))}),"sparkles"},
    ["森林颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("228B22")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("32CD32")),ColorSequenceKeypoint.new(1, Color3.fromHex("228B22"))}),"tree"},
    ["火焰颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF8C00"))}),"flame"},
    ["海洋颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000080")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("00BFFF"))}),"waves"},
    ["日落颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF8C00")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFD700"))}),"sunset"},
    ["银河颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1, Color3.fromHex("9370DB"))}),"galaxy"},
    ["糖果颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF1493")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFB6C1"))}),"candy"},
    ["金属颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("A9A9A9")),ColorSequenceKeypoint.new(1, Color3.fromHex("696969"))}),"shield"}
}

local fontColorAnimations = {}

local function applyFontColorGradient(textElement, colorScheme)
    if not textElement or not textElement:IsA("TextLabel") and not textElement:IsA("TextButton") and not textElement:IsA("TextBox") then
        return
    end
    
    local existingGradient = textElement:FindFirstChild("FontColorGradient")
    if existingGradient then
        existingGradient:Destroy()
    end
    
    if fontColorAnimations[textElement] then
        fontColorAnimations[textElement]:Disconnect()
        fontColorAnimations[textElement] = nil
    end
    
    if not fontColorEnabled then
        textElement.TextColor3 = Color3.new(1, 1, 1)
        return
    end
    
    local schemeData = COLOR_SCHEMES[colorScheme or currentFontColorScheme]
    if not schemeData then return end
    
    local fontGradient = Instance.new("UIGradient")
    fontGradient.Name = "FontColorGradient"
    fontGradient.Color = schemeData[1]
    fontGradient.Rotation = 0
    fontGradient.Parent = textElement
    
    textElement.TextColor3 = Color3.new(1, 1, 1)
    
    local animation
    animation = game:GetService("RunService").Heartbeat:Connect(function()
        if not textElement or textElement.Parent == nil then
            animation:Disconnect()
            fontColorAnimations[textElement] = nil
            return
        end
        
        if not fontGradient or fontGradient.Parent == nil then
            animation:Disconnect()
            fontColorAnimations[textElement] = nil
            return
        end
        
        local time = tick()
        fontGradient.Rotation = (time * animationSpeed * 30) % 360
    end)
    
    fontColorAnimations[textElement] = animation
end

local function applyFontStyleToWindow(fontStyle)
    if not Window or not Window.UIElements then 
        wait(0.5)
        if not Window or not Window.UIElements then
            return false
        end
    end
    
    local successCount = 0
    local totalCount = 0
    
    local function processElement(element)
        for _, child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                totalCount = totalCount + 1
                pcall(function()
                    child.Font = Enum.Font[fontStyle]
                    successCount = successCount + 1
                end)
            end
        end
    end
    
    processElement(Window.UIElements.Main)
    
    return successCount, totalCount
end

local function applyFontColorsToWindow(colorScheme)
    if not Window or not Window.UIElements then return end
    
    local function processElement(element)
        for _, child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                applyFontColorGradient(child, colorScheme)
            end
        end
    end
    
    processElement(Window.UIElements.Main)
end

local function createRainbowBorder(window, colorScheme, speed)
    if not window or not window.UIElements then
        wait(1)
        if not window or not window.UIElements then
            return nil, nil
        end
    end
    
    local mainFrame = window.UIElements.Main
    if not mainFrame then
        return nil, nil
    end
    
    local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then
        local glowEffect = existingStroke:FindFirstChild("GlowEffect")
        if glowEffect then
            local schemeData = COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
            if schemeData then
                glowEffect.Color = schemeData[1]
            end
        end
        return existingStroke, rainbowBorderAnimation
    end
    
    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end
    
    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Thickness = 1.5
    rainbowStroke.Color = Color3.new(1, 1, 1)
    rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
    rainbowStroke.Enabled = borderEnabled
    rainbowStroke.Parent = mainFrame
    
    local glowEffect = Instance.new("UIGradient")
    glowEffect.Name = "GlowEffect"
    
    local schemeData = COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
    if schemeData then
        glowEffect.Color = schemeData[1]
    else
        glowEffect.Color = COLOR_SCHEMES["彩虹颜色"][1]
    end
    
    glowEffect.Rotation = 0
    glowEffect.Parent = rainbowStroke
    
    return rainbowStroke, nil
end

local function startBorderAnimation(window, speed)
    if not window or not window.UIElements then
        return nil
    end
    
    local mainFrame = window.UIElements.Main
    if not mainFrame then
        return nil
    end
    
    local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke or not rainbowStroke.Enabled then
        return nil
    end
    
    local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then
        return nil
    end
    
    if rainbowBorderAnimation then
        rainbowBorderAnimation:Disconnect()
        rainbowBorderAnimation = nil
    end
    
    local animation
    animation = game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent == nil or not rainbowStroke.Enabled then
            animation:Disconnect()
            return
        end
        
        local time = tick()
        glowEffect.Rotation = (time * speed * 60) % 360
    end)
    
    rainbowBorderAnimation = animation
    return animation
end

local function initializeRainbowBorder(scheme, speed)
    speed = speed or animationSpeed
    
    local rainbowStroke, _ = createRainbowBorder(Window, scheme, speed)
    if rainbowStroke then
        if borderEnabled then
            startBorderAnimation(Window, speed)
        end
        borderInitialized = true
        return true
    end
    return false
end

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local function playSound()
    if soundEnabled then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://9047002353"
            sound.Volume = 0.3
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end
end

local function applyBlurEffect(enabled)
    if enabled then
        pcall(function()
            local blur = Instance.new("BlurEffect")
            blur.Size = 8
            blur.Name = "UIXH HUBBlur"
            blur.Parent = game:GetService("Lighting")
        end)
    else
        pcall(function()
            local existingBlur = game:GetService("Lighting"):FindFirstChild("UIXH HUBBlur")
            if existingBlur then
                existingBlur:Destroy()
            end
        end)
    end
end

local function applyUIScale(scale)
    if Window and Window.UIElements and Window.UIElements.Main then
        local mainFrame = Window.UIElements.Main
        mainFrame.Size = UDim2.new(0, 600 * scale, 0, 400 * scale)
    end
end

local Confirmed = false
local gradientColors = {
    "rgb(255, 230, 235)",
    "rgb(255, 210, 220)",
    "rgb(255, 190, 205)",
    "rgb(255, 170, 190)",
    "rgb(255, 150, 175)",
    "rgb(245, 140, 180)",
    "rgb(235, 130, 185)",
    "rgb(225, 120, 190)",
    "rgb(215, 110, 195)",
    "rgb(205, 100, 200)"
}
local username = game:GetService("Players").LocalPlayer.Name
local coloredUsername = ""
local gradientColors = {
    "#4169E1", 
    "#6A5ACD",  
    "#9370DB",  
    "#8A2BE2", 
    "#4B0082"   
}
local goldColor = "#FFD700"
for i = 1, #username do
    local char = username:sub(i, i)
    
  
    if char:match("[A-Za-z0-9]") then
    
        local colorIndex = (i - 1) % #gradientColors + 1
        coloredUsername = coloredUsername .. '<font color="' .. gradientColors[colorIndex] .. '">' .. char .. '</font>'
    else
    
        coloredUsername = coloredUsername .. '<font color="' .. goldColor .. '">' .. char .. '</font>'
    end
end

WindUI:Popup({
    Title = 'YG SCRIPT',
    IconThemed = true,
    Icon = "crown",
    Content = "欢迎尊重的用户 " .. coloredUsername .. " \n支持\nhah",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})
function createUI()
    local Window = WindUI:CreateWindow({
        Title = 'YG SCRIPT',
        Icon = "crown",
        IconThemed = true,
        Author = "Version Beat",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(580, 440),
        Transparent = true,
        Theme = "Dark",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        Background = "https://raw.githubusercontent.com/dohyynd/666/5a74d5d651b6538ea73d10275e1e0dae718030dd/m.png",
        BackgroundImageTransparency = 0.5,
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么", 
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
        Search = {
            Enabled = true,
            Placeholder = "搜索...",
            Callback = function(searchText)
                print("搜索内容:", searchText)
            end
        },
        SidePanel = {
            Enabled = true,
            Content = {
                {
                    Type = "Button", 
                    Text = "",
                    Style = "Subtle", 
                    Size = UDim2.new(1, -20, 0, 30),
                    Callback = function()
                    end
                }
            }
        }
    })

Window:EditOpenButton({
    Title = "YG SCRIPT.",
    Icon = "crown",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 4,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})
Window:Tag({
    Title = "俄亥俄州",
    Color = Color3.fromHex("#FFA500") 
})
spawn(function()
    while true do
        for hue = 0, 1, 0.01 do  
            local color = Color3.fromHSV(hue, 0.8, 1)  
            Window:EditOpenButton({
                Color = ColorSequence.new(color)
            })
            wait(0.04)  
        end
    end
end)
if not borderInitialized then
    spawn(function()
        wait(0.5)
        initializeRainbowBorder("糖果颜色", animationSpeed)
        wait(1)
        applyFontStyleToWindow(currentFontStyle)
    end)
end

local windowOpen = true

Window:OnClose(function()
    windowOpen = false
    if rainbowBorderAnimation then
        rainbowBorderAnimation:Disconnect()
        rainbowBorderAnimation = nil
    end
end)

local originalOpenFunction = Window.Open
Window.Open = function(...)
    windowOpen = true
    local result = originalOpenFunction(...)
    
    if borderInitialized and borderEnabled and not rainbowBorderAnimation then
        wait(0.1)
        startBorderAnimation(Window, animationSpeed)
    end
    
    return result
end

local infoTab = Window:Tab({Title = "通知", Icon = "layout-grid", Locked = false})

local infoSection = infoTab:Section({Title = "详情信息",Icon = "info", Opened = true})

infoSection:Divider()

infoSection:Paragraph({
    Title = "您当前的服务器为",
    Desc = "俄亥俄州\n欢迎使用此脚本",
    ThumbnailSize = 190,
})
infoSection:Paragraph({
    Title = "持续更新，有bug请提出来",
    ThumbnailSize = 190,
})

local LockSection = Window:Section({
    Title = "功能区域",
    Icon = "crown",
    Opened = true,
})
local K = Window:Tab({Title = "战斗", Icon = "swords"})
K:Section({ Title = "愤怒机器人", Icon = "swords" })
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

local autoKillSettings = {
    isEnabled = false,
    range = 100,
    showBeams = true
}

local activeBeams = {}
local lastShootTime = 0
local lastReloadTime = 0
local shootInterval = 0.05
local reloadInterval = 3 

local function hasShield(character)
    if not character then return false end
    local shield = character:FindFirstChild("Shield") or character:FindFirstChild("ForceField")
    return shield ~= nil
end

local function isPlayerAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function purchaseAmmo(weaponName)
    pcall(function()
        require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchaseAmmo", weaponName)
    end)
end

local function createBeamEffect(startPos, endPos)
    if not autoKillSettings.showBeams then return end
    
    local beam = Instance.new("Part")
    beam.Name = "KillBeam"
    beam.Anchored = true
    beam.CanCollide = false
    beam.CastShadow = false
    beam.Transparency = 0.2
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(255, 0, 0)
    
    local direction = (endPos - startPos)
    local distance = direction.Magnitude
    
    beam.Size = Vector3.new(0.3, 0.3, distance)
    beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance/2)
    
    local startGlow = Instance.new("Part")
    startGlow.Name = "StartGlow"
    startGlow.Anchored = true
    startGlow.CanCollide = false
    startGlow.Shape = Enum.PartType.Ball
    startGlow.Size = Vector3.new(1.2, 1.2, 1.2)
    startGlow.Color = Color3.fromRGB(255, 50, 50)
    startGlow.Material = Enum.Material.Neon
    startGlow.Transparency = 0.1
    startGlow.Position = startPos
    startGlow.Parent = beam
    
    local endGlow = startGlow:Clone()
    endGlow.Name = "EndGlow"
    endGlow.Position = endPos
    endGlow.Parent = beam
    
    local innerBeam = Instance.new("Part")
    innerBeam.Name = "InnerBeam"
    innerBeam.Anchored = true
    innerBeam.CanCollide = false
    innerBeam.Transparency = 0.1
    innerBeam.Material = Enum.Material.Neon
    innerBeam.Color = Color3.fromRGB(255, 100, 100)
    innerBeam.Size = Vector3.new(0.2, 0.2, distance)
    innerBeam.CFrame = beam.CFrame
    innerBeam.Parent = beam
    
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 6
    pointLight.Range = 12
    pointLight.Color = Color3.fromRGB(255, 0, 0)
    pointLight.Parent = startGlow
    
    local pointLight2 = pointLight:Clone()
    pointLight2.Parent = endGlow
    
    beam.Parent = Workspace
    
    local beamInfo = {
        beam = beam,
        startTime = tick(),
        endTime = tick() + 0.3
    }
    
    table.insert(activeBeams, beamInfo)
    
    delay(0.3, function()
        if beam and beam.Parent then
            local fadeTween = TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
            fadeTween:Play()
            fadeTween.Completed:Connect(function()
                if beam and beam.Parent then
                    beam:Destroy()
                end
            end)
        end
    end)
    
    return beam
end

local function updateBeams()
    local currentTime = tick()
    local beamsToRemove = {}
    
    for i, beamInfo in ipairs(activeBeams) do
        if currentTime >= beamInfo.endTime then
            table.insert(beamsToRemove, i)
        end
    end
    
    for i = #beamsToRemove, 1, -1 do
        local index = beamsToRemove[i]
        local beamInfo = activeBeams[index]
        if beamInfo.beam and beamInfo.beam.Parent then
            beamInfo.beam:Destroy()
        end
        table.remove(activeBeams, index)
    end
end

local function isInRange(position1, position2)
    return (position1 - position2).Magnitude <= autoKillSettings.range
end

local function getShootingInfo()
    local success, reloadFunc = pcall(function()
        return getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.reload), 2)
    end)
    
    if not success then return nil end
    
    local success2, t = pcall(function()
        return getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.shoot), 1)
    end)
    
    if success2 and t and t.item then
        return {
            reload = reloadFunc,
            ammo = t.item.ammoManager,
            gunid = t.item.guid,
            firemode = t.item.firemode,
            weaponName = t.item.name
        }
    end
    return nil
end

local function autoReload(shootingInfo, forceReload)
    if not shootingInfo then return end
    
    local currentTime = tick()
    
    if forceReload or (currentTime - lastReloadTime >= reloadInterval) then
        local reloadEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("reload")
        if reloadEvent and shootingInfo.reload then
            purchaseAmmo(shootingInfo.weaponName)
            firesignal(reloadEvent.OnClientEvent, shootingInfo.gunid, 0, shootingInfo.ammo.ammoOut)
            shootingInfo.reload()
            lastReloadTime = currentTime
        end
    end
end

local function getAlivePlayersInRange()
    local localCharacter = localPlayer.Character
    local localRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRootPart then return {} end
    
    local targets = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and humanoidRootPart and not hasShield(character) then
                if isInRange(localRootPart.Position, humanoidRootPart.Position) then
                    table.insert(targets, {
                        player = player,
                        character = character,
                        rootPart = humanoidRootPart
                    })
                end
            end
        end
    end
    
    return targets
end

local function shootAtPlayer(targetData, shootingInfo, rightArm)
    if not shootingInfo or not targetData or not rightArm then return false end
    
    if shootingInfo.ammo.ammo <= 0 then
        autoReload(shootingInfo, true)
        return false
    end
    
    local targetParts = {
        targetData.character:FindFirstChild("Head"),
        targetData.character:FindFirstChild("UpperTorso"),
        targetData.character:FindFirstChild("HumanoidRootPart")
    }
    
    local Event1 = ReplicatedStorage.devv.remoteStorage:FindFirstChild("replicateProjectiles")
    local Event2 = ReplicatedStorage.devv.remoteStorage:FindFirstChild("projectileHit")
    
    if not Event1 or not Event2 then return false end
    
    for _, targetPart in ipairs(targetParts) do
        if targetPart and shootingInfo.ammo.ammo > 0 and isPlayerAlive(targetData.character) then
            local startPos = rightArm.Position
            createBeamEffect(startPos, targetPart.Position)
            
            Event1:FireServer(shootingInfo.gunid, {{"TrackingBullet", targetPart.CFrame}}, shootingInfo.firemode)
            Event2:FireServer("TrackingBullet", "player", {
                hitPart = targetPart,
                hitPlayerId = targetData.player.UserId,
                hitSize = targetPart.Size,
                pos = targetPart.Position
            })
            shootingInfo.ammo.ammo = shootingInfo.ammo.ammo - 1
            return true
        end
    end
    
    return false
end

local function autoKillAll()
    if not autoKillSettings.isEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastShootTime < shootInterval then return end
    
    local targets = getAlivePlayersInRange()
    if #targets == 0 then return end
    
    local shootingInfo = getShootingInfo()
    if not shootingInfo then
        autoReload(shootingInfo, true)
        return
    end
    
    local localCharacter = localPlayer.Character
    if not localCharacter then return end
    
    local rightArm = localCharacter:FindFirstChild("RightHand")
    if not rightArm then return end
    
    for _, targetData in ipairs(targets) do
        if isPlayerAlive(targetData.character) and not hasShield(targetData.character) then
            if shootingInfo.ammo.ammo <= 0 then
                autoReload(shootingInfo, true)
                shootingInfo = getShootingInfo()
                if not shootingInfo then break end
            end
            
            local shotFired = shootAtPlayer(targetData, shootingInfo, rightArm)
            if shotFired then
                lastShootTime = currentTime
            end
        end
    end
end

local autoKillConnection
local beamUpdateConnection

local function toggleAutoKill(isEnabled)
    autoKillSettings.isEnabled = isEnabled
    if isEnabled then
        if autoKillConnection then
            autoKillConnection:Disconnect()
        end
        autoKillConnection = RunService.Heartbeat:Connect(autoKillAll)
        
        if beamUpdateConnection then
            beamUpdateConnection:Disconnect()
        end
        beamUpdateConnection = RunService.Heartbeat:Connect(updateBeams)
        
        lastReloadTime = tick()
    else
        if autoKillConnection then
            autoKillConnection:Disconnect()
            autoKillConnection = nil
        end
        
        if beamUpdateConnection then
            beamUpdateConnection:Disconnect()
            beamUpdateConnection = nil
        end
        
        for _, beamInfo in ipairs(activeBeams) do
            if beamInfo.beam and beamInfo.beam.Parent then
                beamInfo.beam:Destroy()
            end
        end
        activeBeams = {}
    end
end

K:Toggle({
    Title = "愤怒机器人[全枪]",
    Value = false,
    Callback = toggleAutoKill
})

K:Slider({
    Title = "射击范围",
    Value = {
        Min = 1,
        Max = 600,
        Default = 100,
    },
    Callback = function(Value)
        autoKillSettings.range = Value
    end
})

K:Toggle({
    Title = "子弹轨迹",
    Default = true,
    Callback = function(v)
        autoKillSettings.showBeams = v
    end
})

K:Section({ Title = "杀戮类", Icon = "swords" })
local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
local autokill = false
local autostomp = false
local grabplay = false
local autoFists = false

local function equipFists()
    for i, v in next, b1 do 
        if v.name == 'Fists' then 
            Signal.FireServer("equip", v.guid)
            break
        end
    end
end

local function killAura()
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= 35 then
                    local uid = player.UserId
                    Signal.FireServer("meleeAttackHit", "player", { 
                        meleeType = "meleemegapunch", 
                        hitPlayerId = uid 
                    })
                end
            end
        end
    end
end

-- 踩踏光环
local function stompAura()
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            if targetHRP and targetHumanoid and targetHumanoid.Health < 20 then
                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= 40 then
                    Signal.FireServer("finish", player)
                end
            end
        end
    end
end

-- 抓取光环
local function grabAura()
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            if targetHRP and targetHumanoid and targetHumanoid.Health < 20 then
                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= 40 then
                    Signal.FireServer("grabPlayer", player)
                end
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autokill then
        killAura()
    end
    
    if autostomp then
        stompAura()
    end
    
    if grabplay then
        grabAura()
    end
    
    if autoFists then
        equipFists()
    end
end)

K:Toggle({
    Title = "自动装备拳头",
    Value = false,
    Callback = function(state) 
        autoFists = state
    end
})

K:Toggle({
    Title = "杀戮光环[一拳]",
    Value = false,
    Callback = function(state) 
        autokill = state
    end
})

K:Toggle({
    Title = "踩踏光环",
    Value = false,
    Callback = function(state) 
        autostomp = state
    end
})

K:Toggle({
    Title = "抓取光环",
    Value = false,
    Callback = function(state) 
        grabplay = state
    end
})

K:Section({ Title = "防护", Icon = "swords" })
K:Toggle({
    Title = "自动穿甲",
    Default = false,
    Callback = function(Value)
        AutoArmor = Value
        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            local connection
            connection = heartbeat:Connect(function()
                if not AutoArmor then
                    connection:Disconnect()
                    return
                end
                
                pcall(function()
                    local player = game:GetService('Players').LocalPlayer
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 35 then
                        local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
                        local hasLightVest = false
                        
                        for i, v in next, b1 do
                            if v.name == "Light Vest" then
                                hasLightVest = true
                                light = v.guid
                                local armor = player:GetAttribute('armor')
                                if armor == nil or armor <= 0 then
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("equip", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("useConsumable", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("removeItem", light)
                                end
                                break
                            end
                        end
                        
                        if not hasLightVest then
                            require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchase", "Light Vest")
                        end
                    end
                end)
            end)
        end
    end
})
K:Toggle({
    Title = "自动面具",
    --Image = "bird",
    Value = false,
    Callback = function(state) 
    autokz = state
    if autokz then
    while autokz and wait(1) do
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Mask = character:FindFirstChild("Hockey Mask")
local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
if not Mask then
Signal.InvokeServer("attemptPurchase", "Hockey Mask")
for i, v in next, b1 do
if v.name == "Hockey Mask" then
sugid = v.guid
if not Mask then
Signal.FireServer("equip", sugid)
Signal.FireServer("wearMask", sugid)
end
break
end
end
end
end
end
    end
})
K:Toggle({
    Title = "自动回血",
    Default = false,
    Callback = function(Value)
        if healThread then
            healThread:Disconnect()
            healThread = nil
        end

        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            healThread = heartbeat:Connect(function()
                Signal.InvokeServer("attemptPurchase", 'Bandage')
                for _, v in next, item.inventory.items do
                    if v.name == 'Bandage' then
                        local bande = v.guid
                        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local Humanoid = Character:WaitForChild('Humanoid')
                        if Humanoid.Health >= 5 and Humanoid.Health < Humanoid.MaxHealth then
                            Signal.FireServer("equip", bande)
                            Signal.FireServer("useConsumable", bande)
                            Signal.FireServer("removeItem", bande)
                        end
                        break
                    end
                end
            end)
        end
    end
})
local melee = require(game:GetService("ReplicatedStorage").devv).load("ClientReplicator")
local lp = game:GetService("Players").LocalPlayer
local AutoKnockReset = false
K:Toggle({
    Title = "防倒地",
    Default = false,
    Callback = function(Value)
        AutoKnockReset = Value
        if Value then
            task.spawn(function()
                while AutoKnockReset do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        melee.Set(lp, "knocked", false)
                        melee.Replicate("knocked")
                    end
                    wait()
                end
            end)
        end
    end
})

K:Toggle({
    Title = "防虚空",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value and task.wait(0.1) do
                local character = game:GetService("Players").LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = character.HumanoidRootPart
                    local position = humanoidRootPart.Position
                    if position.Y < -200 then
                        humanoidRootPart.CFrame = CFrame.new(1339.9090576171875, 6.044891357421875, -660.3264770507812)
                    end
                end
            end
        end)
    end
})
K:Toggle({
    Title = "防甩飞",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value and task.wait(0.1) do
                local character = game:GetService("Players").LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
})
K:Toggle({
    Title = "显示名字血量",
    Value = false,
    Callback = function(enableESP)
        if enableESP then
            local function ApplyESP(v)
                if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
                    v.Character.Humanoid.NameDisplayDistance = 9e9
                    v.Character.Humanoid.NameOcclusion = "NoOcclusion"
                    v.Character.Humanoid.HealthDisplayDistance = 9e9
                    v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
                    v.Character.Humanoid.Health = v.Character.Humanoid.Health 
                end
            end
            
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            
        
            for i, v in pairs(Players:GetPlayers()) do
                ApplyESP(v)
                v.CharacterAdded:Connect(function()
                    task.wait(0.33)
                    ApplyESP(v)
                end)
            end
            
          
            Players.PlayerAdded:Connect(function(v)
                ApplyESP(v)
                v.CharacterAdded:Connect(function()
                    task.wait(0.33)
                    ApplyESP(v)
                end)
            end)
            
          
            local espConnection = RunService.Heartbeat:Connect(function()
                for i, v in pairs(Players:GetPlayers()) do
                    if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
                        v.Character.Humanoid.NameDisplayDistance = 9e9
                        v.Character.Humanoid.NameOcclusion = "NoOcclusion"
                        v.Character.Humanoid.HealthDisplayDistance = 9e9
                        v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
                    end
                end
            end)
            
        
            _G.ESPConnection = espConnection
        else
          
            if _G.ESPConnection then
                _G.ESPConnection:Disconnect()
                _G.ESPConnection = nil
            end
            
           
            local Players = game:GetService("Players")
            for i, v in pairs(Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
                    v.Character.Humanoid.NameDisplayDistance = 100
                    v.Character.Humanoid.NameOcclusion = "OccludeAll"
                    v.Character.Humanoid.HealthDisplayDistance = 100
                    v.Character.Humanoid.HealthDisplayType = "DisplayWhenDamaged"
                end
            end
        end
    end
})
K:Toggle({
    Title = "防僵直",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value and task.wait(0.1) do
                local character = game:GetService("Players").LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    local humanoid = character.Humanoid
                    if humanoid:GetState() == Enum.HumanoidStateType.Frozen then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    end
})

K:Toggle({
    Title = "防坐下",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value and task.wait(0.1) do
                local character = game:GetService("Players").LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    local humanoid = character.Humanoid
                    if humanoid:GetState() == Enum.HumanoidStateType.Seated then
                        humanoid.Sit = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    end
})
local Main = Window:Tab({Title = "魔法", Icon = "settings"})
Main:Section({ Title = "全图类", Icon = "swords" })

local bombardmentEnabled={RPG=false,Flamethrower=false,AcidGun=false}
local bombardmentConnections={}
local lastBombardmentTime=0 
local lastAmmoPurchaseTime=0 
local ammoPurchaseInterval=2 
local ammoPurchaseAmount=2 
local BOMBARDMENT_DURATION=3.2 

local function fixRemoteNames()
    local signalModule=require(game:GetService("ReplicatedStorage").devv.client.Helpers.remotes.Signal)
    for i,v in next,getupvalue(signalModule.LinkSignal,1)do 
        v.Name=i 
        v:GetPropertyChangedSignal("Name"):Connect(function()v.Name=i end)
    end 
    for i,v in next,getupvalue(signalModule.InvokeServer,1)do 
        v.Name=i 
        v:GetPropertyChangedSignal("Name"):Connect(function()v.Name=i end)
    end 
    for i,v in next,getupvalue(signalModule.FireServer,1)do 
        v.Name=i 
        v:GetPropertyChangedSignal("Name"):Connect(function()v.Name=i end)
    end 
end 
fixRemoteNames()

local function hasShield(player)
    local character=player.Character 
    if not character then return false end 
    local shieldPart=character:FindFirstChild("Shield")or character:FindFirstChild("ForceField")
    if shieldPart then return true end 
    for _,child in ipairs(character:GetDescendants())do 
        if child:IsA("ParticleEmitter")and child.Name:lower():find("shield")then 
            return true 
        end 
    end 
    return false 
end 

local function getAccuracyOffset()
    return Vector3.new(math.random(-0.2,0.2),math.random(-0.2,0.2),math.random(-0.2,0.2))
end 

local function purchaseAmmo(weaponType)
    local ammoType 
    if weaponType=="RPG" then 
        ammoType="RPG" 
    elseif weaponType=="Flamethrower" then 
        ammoType="Flamethrower" 
    elseif weaponType=="AcidGun" then 
        ammoType="Ace Gun" 
    end 
    require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchaseAmmo",ammoType)
end 

local function createVisualEffect(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastPressure = 0
    explosion.BlastRadius = 10
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace
    delay(1, function() explosion:Destroy() end)
end

local function performBombardment(weaponType)
    local ReplicatedStorage=game:GetService("ReplicatedStorage")
    local Players=game:GetService("Players")
    local localPlayer=Players.LocalPlayer 
    local reload=getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.reload),2)
    local t=getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.shoot),1)
    local reloadEvent=ReplicatedStorage.devv.remoteStorage:FindFirstChild("reload")
    local ammo=t.item.ammoManager 
    local gunid=t.item.guid 
    local firemode=t.item.firemode 
    
    firesignal(reloadEvent.OnClientEvent,gunid,0,ammo.ammoOut)
    reload()
    
    local targets={}
    for _,player in ipairs(Players:GetPlayers())do 
        if player==localPlayer then continue end 
        if hasShield(player)then continue end 
        local character=player.Character 
        if not character then continue end 
        local humanoid=character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health<=0 then continue end 
        
    
        if humanoid.Health <= 18 then continue end
        
        local hitbox=character:FindFirstChild("Hitbox")
        if not hitbox then continue end 
        local headHitbox=hitbox:FindFirstChild("Head_Hitbox")
        if not headHitbox then continue end 
        local targetRootPart=character:FindFirstChild("HumanoidRootPart")or humanoid.RootPart 
        if not targetRootPart then continue end 
        
        table.insert(targets,{player=player,character=character,headHitbox=headHitbox,rootPart=targetRootPart,humanoid=humanoid})
    end 
    
    if #targets==0 then return end 
    
    for _,targetData in ipairs(targets)do 
        local targetHeadCFrame=targetData.headHitbox.CFrame 
        local targetHeadPosition=targetData.headHitbox.Position 
        local targetPlayerId=targetData.player.UserId 
        targetHeadCFrame=CFrame.new(targetHeadPosition)
        
        if weaponType=="RPG" then 
            local shots=5 
            for i=1,math.min(ammo.ammo,shots)do 
                local offset=getAccuracyOffset()
                local adjustedCFrame=targetHeadCFrame+offset 
                local Event1=ReplicatedStorage.devv.remoteStorage:FindFirstChild("replicateProjectiles")
                if Event1 then 
                    Event1:FireServer(gunid,{{"EZohio123",adjustedCFrame}},firemode)
                end 
                local Event2=ReplicatedStorage.devv.remoteStorage:FindFirstChild("projectileHit")
                if Event2 then 
                    Event2:FireServer("EZohio123","player",{hitPart=targetData.headHitbox,hitPlayerId=targetPlayerId,hitSize=targetData.headHitbox.Size,pos=targetHeadPosition+offset})
                end 
                
             
                createVisualEffect(targetHeadPosition + offset)
            end 
            
            local rocketHitEvent=ReplicatedStorage.devv.remoteStorage:FindFirstChild("rocketHit")
            if rocketHitEvent then 
                for i=1,5 do 
                    local offset=getAccuracyOffset()
                    rocketHitEvent:FireServer("EZohio123","EZohio123",targetHeadPosition+offset)
                 
                    createVisualEffect(targetHeadPosition + offset)
                end 
            end 
            
        elseif weaponType=="Flamethrower" then 
            local flameHitEvent=ReplicatedStorage.devv.remoteStorage:FindFirstChild("flameHit")
            if flameHitEvent then 
                for i=1,50 do 
                    local offset=getAccuracyOffset()
                    flameHitEvent:FireServer("EZohio123","EZohio123",targetHeadPosition+offset)
                end 
            end 
            
        elseif weaponType=="AcidGun" then 
            local acidHitEvent=ReplicatedStorage.devv.remoteStorage:FindFirstChild("acidHit")
            if acidHitEvent then 
                for i=1,6 do 
                    local offset=getAccuracyOffset()
                    acidHitEvent:FireServer("EZohio123","EZohio123",targetHeadPosition+offset)
                end 
            end 
        end 
        
    
        if targetData.humanoid.Health > 18 then
          
            if weaponType == "RPG" then
                for i = 1, 2 do
                    local offset = getAccuracyOffset()
                    local rocketHitEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("rocketHit")
                    if rocketHitEvent then
                        rocketHitEvent:FireServer("EZohio123", "EZohio123", targetHeadPosition + offset)
                        createVisualEffect(targetHeadPosition + offset)
                    end
                end
            end
        end
    end 
    
    firesignal(reloadEvent.OnClientEvent,gunid,0,ammo.ammoOut)
    reload()
end

Main:Toggle({
    Title="全图RPG",
    Default=false,
    Callback=function(Value)
        bombardmentEnabled.RPG=Value 
        if bombardmentConnections.RPG then 
            bombardmentConnections.RPG:Disconnect()
            bombardmentConnections.RPG=nil 
        end 
        if Value then 
            local RunService=game:GetService("RunService")
            local Players=game:GetService("Players")
            local localPlayer=Players.LocalPlayer 
            local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
            local originalGUID=hookfunction(guid,function(...)return "EZohio123" end)
            
            bombardmentConnections.RPG=RunService.Heartbeat:Connect(function()
                local currentTime=tick()
                local ping=game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping>1850 then return end 
                
                if currentTime-lastAmmoPurchaseTime>=ammoPurchaseInterval then 
                    for i=1,ammoPurchaseAmount do 
                        pcall(purchaseAmmo,"RPG")
                    end 
                    lastAmmoPurchaseTime=currentTime 
                end 
                
                if currentTime-lastBombardmentTime>=0.15 then 
                    pcall(function()
                        performBombardment("RPG")
                    end)
                    lastBombardmentTime=currentTime 
                end 
            end)
            
            _G.RPGBombardment={
                connection=bombardmentConnections.RPG,
                originalGUID=originalGUID
            }
        else 
            if _G.RPGBombardment then 
                if _G.RPGBombardment.connection then 
                    _G.RPGBombardment.connection:Disconnect()
                end 
                if _G.RPGBombardment.originalGUID then 
                    local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
                    hookfunction(guid,_G.RPGBombardment.originalGUID)
                end 
                _G.RPGBombardment=nil 
            end 
        end 
    end
})

Main:Toggle({
    Title="全图火焰发射器",
    Default=false,
    Callback=function(Value)
        bombardmentEnabled.Flamethrower=Value 
        if bombardmentConnections.Flamethrower then 
            bombardmentConnections.Flamethrower:Disconnect()
            bombardmentConnections.Flamethrower=nil 
        end 
        if Value then 
            local RunService=game:GetService("RunService")
            local Players=game:GetService("Players")
            local localPlayer=Players.LocalPlayer 
            local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
            local originalGUID=hookfunction(guid,function(...)return "EZohio123" end)
            
            bombardmentConnections.Flamethrower=RunService.Heartbeat:Connect(function()
                local currentTime=tick()
                local ping=game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping>1850 then return end 
                
                if currentTime-lastAmmoPurchaseTime>=ammoPurchaseInterval then 
                    for i=1,ammoPurchaseAmount do 
                        pcall(purchaseAmmo,"Flamethrower")
                    end 
                    lastAmmoPurchaseTime=currentTime 
                end 
                
                if currentTime-lastBombardmentTime>=0.15 then 
                    pcall(function()
                        performBombardment("Flamethrower")
                    end)
                    lastBombardmentTime=currentTime 
                end 
            end)
            
            _G.FlamethrowerBombardment={
                connection=bombardmentConnections.Flamethrower,
                originalGUID=originalGUID
            }
        else 
            if _G.FlamethrowerBombardment then 
                if _G.FlamethrowerBombardment.connection then 
                    _G.FlamethrowerBombardment.connection:Disconnect()
                end 
                if _G.FlamethrowerBombardment.originalGUID then 
                    local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
                    hookfunction(guid,_G.FlamethrowerBombardment.originalGUID)
                end 
                _G.FlamethrowerBombardment=nil 
            end 
        end 
    end
})

Main:Toggle({
    Title="全图硫酸枪",
    Default=false,
    Callback=function(Value)
        bombardmentEnabled.AcidGun=Value 
        if bombardmentConnections.AcidGun then 
            bombardmentConnections.AcidGun:Disconnect()
            bombardmentConnections.AcidGun=nil 
        end 
        if Value then 
            local RunService=game:GetService("RunService")
            local Players=game:GetService("Players")
            local localPlayer=Players.LocalPlayer 
            local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
            local originalGUID=hookfunction(guid,function(...)return "EZohio123" end)
            
            bombardmentConnections.AcidGun=RunService.Heartbeat:Connect(function()
                local currentTime=tick()
                local ping=game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping>1850 then return end 
                
                if currentTime-lastAmmoPurchaseTime>=ammoPurchaseInterval then 
                    for i=1,ammoPurchaseAmount do 
                        pcall(purchaseAmmo,"AcidGun")
                    end 
                    lastAmmoPurchaseTime=currentTime 
                end 
                
                if currentTime-lastBombardmentTime>=0.15 then 
                    pcall(function()
                        performBombardment("AcidGun")
                    end)
                    lastBombardmentTime=currentTime 
                end 
            end)
            
            _G.AcidGunBombardment={
                connection=bombardmentConnections.AcidGun,
                originalGUID=originalGUID
            }
        else 
            if _G.AcidGunBombardment then 
                if _G.AcidGunBombardment.connection then 
                    _G.AcidGunBombardment.connection:Disconnect()
                end 
                if _G.AcidGunBombardment.originalGUID then 
                    local guid=require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
                    hookfunction(guid,_G.AcidGunBombardment.originalGUID)
                end 
                _G.AcidGunBombardment=nil 
            end 
        end 
    end
})
local bombardmentEnabled = {PepperSpray = false}
local bombardmentConnections = {}
local lastBombardmentTime = 0 
local lastAmmoPurchaseTime = 0 
local ammoPurchaseInterval = 2 
local ammoPurchaseAmount = 2 
local MAX_DISTANCE = 400  

local function fixRemoteNames()
    local signalModule = require(game:GetService("ReplicatedStorage").devv.client.Helpers.remotes.Signal)
    for i, v in next, getupvalue(signalModule.LinkSignal, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
    for i, v in next, getupvalue(signalModule.InvokeServer, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
    for i, v in next, getupvalue(signalModule.FireServer, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
end 
fixRemoteNames()

local function hasShield(player)
    local character = player.Character 
    if not character then return false end 
    local shieldPart = character:FindFirstChild("Shield") or character:FindFirstChild("ForceField")
    if shieldPart then return true end 
    for _, child in ipairs(character:GetDescendants()) do 
        if child:IsA("ParticleEmitter") and child.Name:lower():find("shield") then 
            return true 
        end 
    end 
    return false 
end 

local function getAccuracyOffset()
    return Vector3.new(math.random(-0.5, 0.5), math.random(-0.5, 0.5), math.random(-0.5, 0.5))
end 

local function purchaseAmmo(weaponType)
    local ammoType 
    if weaponType == "PepperSpray" then 
        ammoType = "Pepper Spray"
    end 
    require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchaseAmmo", ammoType)
end 

local function performPepperSprayBombardment()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer 
    local reload = getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.reload), 2)
    local t = getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.shoot), 1)
    local reloadEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("reload")
    local ammo = t.item.ammoManager 
    local gunid = t.item.guid 
    local firemode = t.item.firemode 
    local itemName = t.item.name or "Pepper Spray"
    
    firesignal(reloadEvent.OnClientEvent, gunid, 0, ammo.ammoOut)
    reload()
    
    local targets = {}
    local localPosition
    
    local localCharacter = localPlayer.Character
    if localCharacter then
        local localRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
        if localRootPart then
            localPosition = localRootPart.Position
        end
    end
    
    if not localPosition then return end
    
    for _, player in ipairs(Players:GetPlayers()) do 
        if player == localPlayer then continue end 
        if hasShield(player) then continue end 
        local character = player.Character 
        if not character then continue end 
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end 
        
        local hitbox = character:FindFirstChild("Hitbox")
        if not hitbox then continue end 
        
        local headHitbox = hitbox:FindFirstChild("Head_Hitbox")
        if not headHitbox then continue end 
        
        local targetRootPart = character:FindFirstChild("HumanoidRootPart") or humanoid.RootPart 
        if not targetRootPart then continue end 
        
        local distance = (targetRootPart.Position - localPosition).Magnitude
        if distance > MAX_DISTANCE then continue end
        
        table.insert(targets, {
            player = player, 
            character = character, 
            headHitbox = headHitbox, 
            rootPart = targetRootPart, 
            humanoid = humanoid,
            distance = distance
        })
    end 
    
    if #targets == 0 then return end 
    
    for _, targetData in ipairs(targets) do 
        local targetHeadPosition = targetData.headHitbox.Position 
        local targetPlayerId = targetData.player.UserId 
        
        local accuracyMultiplier = math.clamp(targetData.distance / 100, 0.5, 2.0)
        
        local projectileEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("replicateProjectiles")
        if projectileEvent then 
            local shots = 3
            for i = 1, math.min(ammo.ammo, shots) do 
                local shotOffset = getAccuracyOffset() * accuracyMultiplier
                local shotCFrame = CFrame.new(targetHeadPosition) + shotOffset
                projectileEvent:FireServer(gunid, {{"PepperCloud123", shotCFrame}}, firemode)
                
                local pepperSprayHitEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("pepperSprayHit")
                if pepperSprayHitEvent then 
                    pepperSprayHitEvent:FireServer("PepperCloud123", "player", {
                        hitPart = targetData.headHitbox,
                        hitPlayerId = targetPlayerId,
                        hitSize = targetData.headHitbox.Size,
                        pos = targetHeadPosition + shotOffset
                    })
                end
            end 
        end
        
        local cloudEffect = ReplicatedStorage.devv.remoteStorage:FindFirstChild("createPepperCloud")
        if cloudEffect then 
            for i = 1, 3 do
                local cloudOffset = getAccuracyOffset() * accuracyMultiplier
                cloudEffect:FireServer("PepperCloud123", targetHeadPosition + cloudOffset, itemName)
            end
        end
    end 
    
    firesignal(reloadEvent.OnClientEvent, gunid, 0, ammo.ammoOut)
    reload()
end

Main:Toggle({
    Title = "全图辣椒喷雾",
    Default = false,
    Callback = function(Value)
        bombardmentEnabled.PepperSpray = Value 
        if bombardmentConnections.PepperSpray then 
            bombardmentConnections.PepperSpray:Disconnect()
            bombardmentConnections.PepperSpray = nil 
        end 
        if Value then 
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer 
            local guid = require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
            local originalGUID = hookfunction(guid, function(...) return "PepperCloud123" end)
            
            bombardmentConnections.PepperSpray = RunService.Heartbeat:Connect(function()
                local currentTime = tick()
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping > 1850 then return end 
                
                if currentTime - lastAmmoPurchaseTime >= ammoPurchaseInterval then 
                    for i = 1, ammoPurchaseAmount do 
                        pcall(purchaseAmmo, "PepperSpray")
                    end 
                    lastAmmoPurchaseTime = currentTime 
                end 
                
                if currentTime - lastBombardmentTime >= 0.2 then
                    pcall(function()
                        performPepperSprayBombardment()
                    end)
                    lastBombardmentTime = currentTime 
                end 
            end)
            
            _G.PepperSprayBombardment = {
                connection = bombardmentConnections.PepperSpray,
                originalGUID = originalGUID
            }
        else 
            if _G.PepperSprayBombardment then 
                if _G.PepperSprayBombardment.connection then 
                    _G.PepperSprayBombardment.connection:Disconnect()
                end 
                if _G.PepperSprayBombardment.originalGUID then 
                    local guid = require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
                    hookfunction(guid, _G.PepperSprayBombardment.originalGUID)
                end 
                _G.PepperSprayBombardment = nil 
            end 
        end 
    end
})
local fireExtinguisherEnabled = false
local fireExtinguisherConnection
local lastAttackTime = 0
local attackInterval = 0.2
local MAX_DISTANCE = 400
local ammoPurchaseInterval = 2
local ammoPurchaseAmount = 2
local lastAmmoPurchaseTime = 0
local currentItemName = "Fire Extinguisher"

local function fixRemoteNames()
    local signalModule = require(game:GetService("ReplicatedStorage").devv.client.Helpers.remotes.Signal)
    for i, v in next, getupvalue(signalModule.LinkSignal, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
    for i, v in next, getupvalue(signalModule.InvokeServer, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
    for i, v in next, getupvalue(signalModule.FireServer, 1) do 
        v.Name = i 
        v:GetPropertyChangedSignal("Name"):Connect(function() v.Name = i end)
    end 
end 
fixRemoteNames()

local function hasShield(player)
    local character = player.Character 
    if not character then return false end 
    local shieldPart = character:FindFirstChild("Shield") or character:FindFirstChild("ForceField")
    if shieldPart then return true end 
    for _, child in ipairs(character:GetDescendants()) do 
        if child:IsA("ParticleEmitter") and child.Name:lower():find("shield") then 
            return true 
        end 
    end 
    return false 
end 

local function getAccuracyOffset()
    return Vector3.new(math.random(-0.5, 0.5), math.random(-0.5, 0.5), math.random(-0.5, 0.5))
end 

local function purchaseAmmo()
    require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchaseAmmo", "Fire Extinguisher")
end

local function getEquippedItemName()
    local t = getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.shoot), 1)
    if t and t.item then
        local name = t.item.name
        if name and (name:find("Fire") or name:find("Extinguisher")) then
            currentItemName = name
            return name
        end
    end
    return currentItemName
end

local function performFireExtinguisherAttack()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer 
    local reload = getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.reload), 2)
    local t = getupvalue(require(game:GetService("ReplicatedStorage").devv.client.Objects.v3item.bin.Gun.modules.controller.modules.shoot), 1)
    local reloadEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("reload")
    local ammo = t.item.ammoManager 
    local gunid = t.item.guid 
    local firemode = t.item.firemode 
    local itemName = getEquippedItemName()
    
    firesignal(reloadEvent.OnClientEvent, gunid, 0, ammo.ammoOut)
    reload()
    
    local targets = {}
    local localPosition
    
    local localCharacter = localPlayer.Character
    if localCharacter then
        local localRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
        if localRootPart then
            localPosition = localRootPart.Position
        end
    end
    
    if not localPosition then return end
    
    for _, player in ipairs(Players:GetPlayers()) do 
        if player == localPlayer then continue end 
        if hasShield(player) then continue end 
        local character = player.Character 
        if not character then continue end 
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end 
        
        local hitbox = character:FindFirstChild("Hitbox")
        if not hitbox then continue end 
        
        local headHitbox = hitbox:FindFirstChild("Head_Hitbox")
        if not headHitbox then continue end 
        
        local targetRootPart = character:FindFirstChild("HumanoidRootPart") or humanoid.RootPart 
        if not targetRootPart then continue end 
        
        local distance = (targetRootPart.Position - localPosition).Magnitude
        if distance > MAX_DISTANCE then continue end
        
        table.insert(targets, {
            player = player, 
            character = character, 
            headHitbox = headHitbox, 
            rootPart = targetRootPart, 
            humanoid = humanoid,
            distance = distance
        })
    end 
    
    if #targets == 0 then return end 
    
    for _, targetData in ipairs(targets) do 
        local targetHeadPosition = targetData.headHitbox.Position 
        local targetPlayerId = targetData.player.UserId 
        
        local accuracyMultiplier = math.clamp(targetData.distance / 100, 0.5, 2.0)
        
        local projectileEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("replicateProjectiles")
        if projectileEvent then 
            local shots = 3
            for i = 1, math.min(ammo.ammo, shots) do 
                local shotOffset = getAccuracyOffset() * accuracyMultiplier
                local shotCFrame = CFrame.new(targetHeadPosition) + shotOffset
                projectileEvent:FireServer(gunid, {{"FireExt123", shotCFrame}}, firemode)
                
                local pepperSprayHitEvent = ReplicatedStorage.devv.remoteStorage:FindFirstChild("pepperSprayHit")
                if pepperSprayHitEvent then 
                    pepperSprayHitEvent:FireServer("FireExt123", "player", {
                        hitPart = targetData.headHitbox,
                        hitPlayerId = targetPlayerId,
                        hitSize = targetData.headHitbox.Size,
                        pos = targetHeadPosition + shotOffset
                    })
                end
            end 
        end
        
        local cloudEffect = ReplicatedStorage.devv.remoteStorage:FindFirstChild("createPepperCloud")
        if cloudEffect then 
            for i = 1, 2 do
                local cloudOffset = getAccuracyOffset() * accuracyMultiplier
                cloudEffect:FireServer("FireExt123", targetHeadPosition + cloudOffset, itemName)
            end
        end
    end 
    
    firesignal(reloadEvent.OnClientEvent, gunid, 0, ammo.ammoOut)
    reload()
end

Main:Toggle({
    Title = "全图灭火器",
    Default = false,
    Callback = function(Value)
        fireExtinguisherEnabled = Value 
        if fireExtinguisherConnection then 
            fireExtinguisherConnection:Disconnect()
            fireExtinguisherConnection = nil 
        end 
        if Value then 
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer 
            local guid = require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
            local originalGUID = hookfunction(guid, function(...) return "FireExt123" end)
            
            fireExtinguisherConnection = RunService.Heartbeat:Connect(function()
                local currentTime = tick()
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping > 1850 then return end 
                
                if currentTime - lastAmmoPurchaseTime >= ammoPurchaseInterval then 
                    for i = 1, ammoPurchaseAmount do 
                        pcall(purchaseAmmo)
                    end 
                    lastAmmoPurchaseTime = currentTime 
                end 
                
                if currentTime - lastAttackTime >= attackInterval then
                    pcall(function()
                        performFireExtinguisherAttack()
                    end)
                    lastAttackTime = currentTime 
                end 
            end)
            
            _G.FireExtinguisherAttack = {
                connection = fireExtinguisherConnection,
                originalGUID = originalGUID
            }
        else 
            if _G.FireExtinguisherAttack then 
                if _G.FireExtinguisherAttack.connection then 
                    _G.FireExtinguisherAttack.connection:Disconnect()
                end 
                if _G.FireExtinguisherAttack.originalGUID then 
                    local guid = require(game:GetService("ReplicatedStorage").devv.shared.Helpers.string.GUID)
                    hookfunction(guid, _G.FireExtinguisherAttack.originalGUID)
                end 
                _G.FireExtinguisherAttack = nil 
            end 
        end 
    end
})

local Main = Window:Tab({Title = "圣诞节活动", Icon = "gift"})
Main:Section({ Title = "刷糖果", Icon = "gift" })
local christmasMobThread = nil
local christmasMobEnabled = false

local function teleportToHideSpot()

end

local function checkAnyTargetExists()
   
    return true
end

local function collectGingerbread()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    
    if localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
    
            if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Entities") then
                if workspace.Game.Entities:FindFirstChild("Gingerbread") then
                    for _, gingerbread in pairs(workspace.Game.Entities.Gingerbread:GetChildren()) do
                        if gingerbread:IsA("Model") then
                            for _, v in pairs(gingerbread:GetDescendants()) do
                                if v:IsA("ClickDetector") then
                                    local detectorPos = gingerbread:GetPivot().Position
                                    local distance = (rootPart.Position - detectorPos).Magnitude
                                    if distance <= 20 then
                                        fireclickdetector(v)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Main:Toggle({
    Title = "礼物盒农场",
    Default = false,
    Callback = function(Value)
        if christmasMobThread then
            task.cancel(christmasMobThread)
            christmasMobThread = nil
        end

        christmasMobEnabled = Value
        
        if Value then
            christmasMobThread = task.spawn(function()
                while christmasMobEnabled do
                    task.wait()
                    
                    if not checkAnyTargetExists() then
                        teleportToHideSpot()
                        task.wait(1)
                    else
                        pcall(function()
                            local plr = game:GetService("Players").LocalPlayer
                            local char = plr.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local christmasMobs = workspace:FindFirstChild("Christmas")
                                
                                if christmasMobs and christmasMobs:FindFirstChild("Mobs") then
                                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                                    if rootPart then
                                     
                                        collectGingerbread()
                                        
                                  
                                        for _, mob in ipairs(christmasMobs.Mobs:GetChildren()) do
                                            if mob:IsA("Model") then
                                          
                                                local health = mob:GetAttribute("health")
                                                if health and health > 0 then
                                             
                                                    rootPart.CFrame = mob:GetPivot() * CFrame.new(0, 0, -2)
                                                    task.wait(0.1)
                                                    
                                                
                                                    mob:SetAttribute("health", 0)
                                                    
                                               
                                                    task.wait(2)
                                                    
                                             
                                                    collectGingerbread()
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end
})
Main:Toggle({
    Title = "收集姜饼人光环",
    Default = false,
    Callback = function(Value)
        mngh = Value
        task.spawn(function()
            while mngh and task.wait() do
                if not checkAnyTargetExists() then
                    teleportToHideSpot()
                    task.wait(1)
                else
                    local Players = game:GetService("Players")
                    local localPlayer = Players.LocalPlayer
                    if localPlayer.Character then
                        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local player = game:GetService("Players").LocalPlayer
                            local character = player.Character or player.CharacterAdded:Wait()
                            local rootPart = character:WaitForChild("HumanoidRootPart")
                            for _, v in pairs(workspace.Game.Entities.CashBundle:GetDescendants()) do
                                if v:IsA("ClickDetector") then
                                    local detectorPos = v.Parent:GetPivot().Position
                                    local distance = (rootPart.Position - detectorPos).Magnitude
                                    if distance <= 50 then
                                        fireclickdetector(v)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})
local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local autoElfEnabled = false
local autoElfThread = nil

local function findElves()
    local elves = {}
    local CollectionService = game:GetService("CollectionService")
    
    for _, elf in ipairs(CollectionService:GetTagged("PeterTheElf")) do
        if elf:IsA("Model") and elf.PrimaryPart then
            local alreadyCollected = false
            for _, part in ipairs(elf:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "Hitbox" then
                    if part.Transparency >= 0.5 then
                        alreadyCollected = true
                        break
                    end
                end
            end
            
            if not alreadyCollected then
                table.insert(elves, elf)
            end
        end
    end
    
    return elves
end

local function collectElf(elf)
    if not elf or not elf.PrimaryPart then return false end
    
    local char = localPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    hrp.CFrame = elf.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
    task.wait(0.5)
    
    local success, gingerbreadAmount = pcall(function()
        return Signal.InvokeServer("attemptCollectElf")
    end)
    
    if success then
        return true
    else
        return false
    end
end

Main:Toggle({
    Title = "自动圣诞精灵",
    Default = false,
    Callback = function(Value)
        if autoElfThread then
            task.cancel(autoElfThread)
            autoElfThread = nil
        end

        autoElfEnabled = Value
        
        if Value then
            autoElfThread = task.spawn(function()
                while autoElfEnabled do
                    task.wait()
                    
                    pcall(function()
                        local elves = findElves()
                        
                        if #elves > 0 then
                            for _, elf in ipairs(elves) do
                                if not autoElfEnabled then break end
                                
                                local collected = collectElf(elf)
                                
                                if collected then
                                    task.wait(3)
                                else
                                    task.wait(1)
                                end
                                
                                elves = findElves()
                                if #elves == 0 then break end
                            end
                        else
                            task.wait(5)
                        end
                    end)
                end
            end)
        end
    end
})

Main:Section({ Title = "任务", Icon = "gift" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local load = require(ReplicatedStorage.devv).load
local Signal = load("Signal")

local christmasQuests = load("ChristmasQuests")
local autoQuestThread = nil
local autoQuestEnabled = false

local function getQuestRewards()
    local quests = {}
    

    for questType, questData in pairs(christmasQuests) do
        if type(questData) == "table" then
            table.insert(quests, {
                type = questType,
                name = questData.title:match(">(.+)<") or questType,
                tiers = questData.tiers or {}
            })
        end
    end
    
    return quests
end

local function claimQuestReward(questType, tierIndex)
    local success, result = pcall(function()
        return Signal.InvokeServer("claimQuestReward", questType, tierIndex)
    end)
    
    return success
end

local function checkAndClaimAllQuests()
    local claimedCount = 0
    local failedCount = 0
    
    for questType, questData in pairs(christmasQuests) do
        if type(questData) == "table" and questData.tiers then
            for tierIndex = 1, #questData.tiers do
                local success = claimQuestReward(questType, tierIndex)
                if success then
                    claimedCount = claimedCount + 1
                    task.wait(0.2) -- 避免请求过快
                else
                    failedCount = failedCount + 1
                end
            end
        end
    end
    
    return claimedCount, failedCount
end

Main:Toggle({
    Title = "自动领取姜饼人奖励",
    Value = false,
    Callback = function(state)
        autoQuestEnabled = state
        
        if autoQuestThread then
            task.cancel(autoQuestThread)
            autoQuestThread = nil
        end
        
        if state then
            autoQuestThread = task.spawn(function()
                while autoQuestEnabled do
                    checkAndClaimAllQuests()
                    task.wait(5)
                end
            end)
            
        else
        end
    end
})

Main:Button({
    Title = "查看任务列表",
    Callback = function()
        local quests = getQuestRewards()
        local message = "圣诞任务列表：\n\n"
        
        for i, quest in ipairs(quests) do
            message = message .. string.format("%d. %s\n", i, quest.name)
            if quest.tiers and #quest.tiers > 0 then
                for j, tier in ipairs(quest.tiers) do
                    message = message .. string.format("   等级 %d: %d 姜饼人\n", j, tier.gingerbread or 0)
                end
            end
            message = message .. "\n"
        end
        
        WindUI:Notify({
            Title = "圣诞任务列表",
            Content = message,
            Duration = 8,
            Icon = "list"
        })
    end
})

local bs = Window:Tab({Title = "绕过", Icon = "user"})

bs:Button({
    Title = "绕过移动经销商[新版本]",
    Callback = function()
local pjyd pjyd=hookmetamethod(game,"__namecall",function(self,...)local args={...}local method=getnamecallmethod()if method=="InvokeServer" and args[2]==true then args[2]=false return pjyd(self,unpack(args))end return pjyd(self,...)end)--
game:GetService("Players").LocalPlayer:SetAttribute("mobileDealer",true)
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local mobileDealer=require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)

for category,items in pairs(mobileDealer)do 
    for _,item in ipairs(items)do 
        item.stock=999999 
    end 
end

table.insert(mobileDealer.Gun,{itemName="Acid Gun",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Candy Bucket",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Golden Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Black Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Dollar Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bat Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bunny Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Ghost Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Gold Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Heart Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Skull Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Snowflake Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin AK-47",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin Nuke Launcher",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin RPG",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Void Gem",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Pulse Rifle",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Unusual Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Trident",stock=9999})
table.insert(mobileDealer.Gun,{itemName="NextBot Grenade",stock=9999})
table.insert(mobileDealer.Gun,{itemName="El Fuego",stock=9999})

    end
})
bs:Button({
    Title = "绕过高级表情包",
    Callback = function()
    for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants()) do
        if v.Name == "Locked" then
            v.Visible = false
        end
    end
    end
})

bs:Button({
    Title = "绕过飞行检测",
    Callback = function()
    if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
end
    end
})
bs:Button({
    Title = "绕过物品栏封禁",
    Callback = function()
    if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
end
    end
})

bs:Button({
    Title = "绕过战斗状态",
    Callback = function()
        for _, func in pairs(getgc(true)) do
    if type(func) == "function" then
        local info = debug.getinfo(func)
        if info.name == "isInCombat" or (info.source and info.source:find("combatIndicator")) then
            hookfunction(func, function() 
                return false 
            end)
        end
    end
end
    end
})
local Main = Window:Tab({Title = "本地", Icon = "box"})
Main:Section({ Title = "免费物品", Icon = "swords" })
local items = {
    "Golden Rose",
    "Black Rose", 
    "Dollar Balloon",
    "Bat Balloon",
    "Bunny Balloon", 
    "Clover Balloon",
    "Ghost Balloon",
    "Gold Clover Balloon",
    "Heart Balloon",
    "Skull Balloon",
    "Snowflake Balloon",
    "Admin AK-47",
    "Admin Nuke Launcher", 
    "Admin RPG",
    "Void Gem",
    "Pulse Rifle",
    "Unusual Money Printer",
    "Money Printer",
    "Trident",
    "NextBot Grenade",
    "El Fuego"
}

local itemDisplayNames = {
    ["Golden Rose"] = "金玫瑰",
    ["Black Rose"] = "黑玫瑰", 
    ["Dollar Balloon"] = "美元气球",
    ["Bat Balloon"] = "蝙蝠气球",
    ["Bunny Balloon"] = "兔子气球",
    ["Clover Balloon"] = "三叶草气球",
    ["Ghost Balloon"] = "幽灵气球",
    ["Gold Clover Balloon"] = "金三叶草气球",
    ["Heart Balloon"] = "爱心气球",
    ["Skull Balloon"] = "骷髅气球",
    ["Snowflake Balloon"] = "雪花气球",
    ["Admin AK-47"] = "管理员黄金AK-47",
    ["Admin Nuke Launcher"] = "管理员核弹发射器",
    ["Admin RPG"] = "管理员RPG",
    ["Void Gem"] = "虚空宝石", 
    ["Pulse Rifle"] = "脉冲步枪",
    ["Unusual Money Printer"] = "异常印钞机",
    ["Money Printer"] = "印钞机",
    ["Trident"] = "三叉戟",
    ["NextBot Grenade"] = "NextBot手榴弹",
    ["El Fuego"] = "烈焰喷射器"
}

local itemData = {
    ["Bat Balloon"] = {
        name = "Bat Balloon",
        cost = 0,
        unpurchasable = true,
        multiplier = 0.625,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, math.pi, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Bunny Balloon"] = {
        name = "Bunny Balloon",
        cost = 0,
        unpurchasable = true,
        multiplier = 0.61,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 4.75, offset = CFrame.new(0, -0.25, 0), rotoffset = CFrame.Angles(0, 4.71238898038469, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Clover Balloon"] = {
        name = "Clover Balloon",
        cost = 200,
        unpurchasable = true,
        multiplier = 0.625,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Ghost Balloon"] = {
        name = "Ghost Balloon",
        cost = 0,
        unpurchasable = true,
        multiplier = 0.625,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 3.5, offset = CFrame.new(0, 0.5, 0), rotoffset = CFrame.Angles(0, math.pi, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Gold Clover Balloon"] = {
        name = "Gold Clover Balloon",
        cost = 250000,
        unpurchasable = true,
        multiplier = 0.6,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Heart Balloon"] = {
        name = "Heart Balloon",
        cost = 200,
        multiplier = 0.6,
        holdableType = "Balloon",
        unpurchasable = true,
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Skull Balloon"] = {
        name = "Skull Balloon",
        cost = 0,
        unpurchasable = true,
        multiplier = 0.625,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, -270, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Snowflake Balloon"] = {
        name = "Snowflake Balloon",
        cost = 0,
        unpurchasable = true,
        multiplier = 0.625,
        holdableType = "Balloon",
        canDrop = true,
        dropCooldown = 120,
        permanent = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Golden Rose"] = {
        name = "Golden Rose",
        guid = "golden_rose_"..tostring(tick()),
        permanent = true,
        canDrop = true,
        dropCooldown = 120,
        multiplier = 0.625,
        holdableType = "Balloon",
        movespeedAdd = 5,
        TPSOffsets = {hold = CFrame.new(0, 0.5, 0)},
        viewportOffsets = {
            hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
            ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)},
            slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}
        }
    },
    ["Black Rose"] = {
        name = "Black Rose",
        guid = "black_rose_"..tostring(tick()),
        permanent = true,
        canDrop = true,
        dropCooldown = 120,
        multiplier = 0.75,
        holdableType = "Balloon",
        movespeedAdd = 12,
        TPSOffsets = {hold = CFrame.new(0, 0.5, 0)},
        viewportOffsets = {
            hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
            ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)},
            slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}
        }
    },
    ["Dollar Balloon"] = {
        name = "Dollar Balloon",
        cost = 100000000000,
        unpurchasable = true,
        multiplier = 0.8,
        holdableType = "Balloon",
        movespeedAdd = 8,
        cannotDiscard = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)},
        viewportOffsets = {
            hotbar = {dist = 4, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}
        }
    },
    ["Admin AK-47"] = {
        name = "Admin AK-47",
        modelName = "Gold AK-47",
        subtype = "AK-47",
        adminOnly = true,
        canDrop = false,
        unpurchasable = true,
        damage = 10,
        ammo = 999999999,
        startAmmo = -1,
        maxAmmo = -1,
        firemode = "auto",
        numProjectiles = 8,
        fireDebounce = 0.01
    },
    ["Admin Nuke Launcher"] = {
        name = "Admin Nuke Launcher",
        modelName = "Nuke Launcher",
        subtype = "Nuke Launcher",
        adminOnly = true,
        canDrop = false,
        unpurchasable = true,
        ammo = 99999999,
        startAmmo = -1,
        maxAmmo = -1,
        overrideProjectileProperties = {
            disableNukeFlash = true
        },
        reloadTime = 0,
        reloadType = "mag",
        firemode = "auto",
        numProjectiles = 1,
        fireDebounce = 0.2
    },
    ["Admin RPG"] = {
        canDrop = false,
        unpurchasable = true,
        name = "Admin RPG",
        modelName = "RPG",
        subtype = "RPG",
        adminOnly = true,
        ammo = 99999999,
        startAmmo = -1,
        maxAmmo = -1,
        reloadTime = 0,
        reloadType = "mag",
        firemode = "auto",
        numProjectiles = 1,
        fireDebounce = 0.02,
        recoilAdd = 0,
        maxRecoil = 0,
        recoilDiminishFactor = 0,
        recoilFastDiminishFactor = 0
    },
    ["Void Gem"] = {
        name = "Void Gem",
        subtype = "gem",
        maxAmmo = 3,
        adminLimit = 1,
        sellPrice = 25000,
        canDrop = true,
        dropCooldown = 300
    },
    ["Pulse Rifle"] = {
        name = "Pulse Rifle",
        subtype = "Raygun",
        unpurchasable = true,
        damage = 22,
        headshotMultiplier = 1.5,
        ammo = 50,
        startAmmo = -1,
        maxAmmo = -1,
        reloadTime = 3.5,
        reloadType = "mag",
        firemode = "auto",
        numProjectiles = 1,
        fireDebounce = 0.04,
        projectileLength = 20,
        projectileLifetime = 200,
        speedDropoff = 0.04,
        speedMax = 5,
        baseSpread = 3,
        baseAimSpread = 0.8,
        spread = 11,
        aimSpread = 2.4,
        recoilAdd = 0.05,
        maxRecoil = 0.4,
        recoilDiminishFactor = 0.95,
        recoilFastDiminishFactor = 0.85
    },
    ["Unusual Money Printer"] = {
        name = "Unusual Money Printer",
        cost = 500,
        ammo = 1,
        startAmmo = -1,
        maxAmmo = 1,
        hint = {
            computer = "Click to Place",
            console = "Click to Place"
        },
        canDrop = true,
        dropCooldown = 600,
        isConsumable = true,
        TPSOffsets = {
            hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)
        },
        viewportOffsets = {
            hotbar = {
                dist = 5,
                offset = CFrame.new(0, 0.15, 0),
                rotoffset = CFrame.Angles(0, (-math.pi/2), 0)
            },
            ammoHUD = {
                dist = 3.25,
                offset = CFrame.new(0, 1, 0),
                rotoffset = CFrame.Angles(0, (math.pi/2), 0)
            }
        }
    },
    ["Money Printer"] = {
        name = "Money Printer",
        ammo = 1,
        startAmmo = -1,
        maxAmmo = 1,
        adminLimit = 10,
        hint = {
            computer = "Click to Place",
            console = "Click to Place"
        },
        canDrop = true,
        dropCooldown = 600,
        isConsumable = true,
        permanent = true,
        TPSOffsets = {
            hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)
        },
        viewportOffsets = {
            hotbar = {
                dist = 5,
                offset = CFrame.new(0, 0.15, 0),
                rotoffset = CFrame.Angles(0, (-math.pi/2), 0)
            },
            ammoHUD = {
                dist = 3.25,
                offset = CFrame.new(0, 1, 0),
                rotoffset = CFrame.Angles(0, (-math.pi/2), 0)
            }
        }
    },
    ["Trident"] = {
        name = "Trident",
        subtype = "RPG",
        unpurchasable = true,
        ammo = 1,
        startAmmo = 12,
        maxAmmo = 12,
        firemode = "semi",
        numProjectiles = 3,
        fireDebounce = 0.5,
        projectileLength = 4,
        projectileLifetime = 1000,
        speedDropoff = 0.04,
        speedMax = 5,
        baseSpread = 5,
        baseAimSpread = 1,
        spread = 10,
        aimSpread = 6,
        recoilAdd = 1,
        maxRecoil = 1.25,
        recoilDiminishFactor = 0.9,
        recoilFastDiminishFactor = 0.66
    },
    ["NextBot Grenade"] = {
        name = "NextBot Grenade",
        isNade = true,
        bounceSFX = "nadeBounce",
        canDrop = true,
        dropCooldown = 600,
        thrownOffset = CFrame.Angles(0, (math.pi/2), 0),
        ammo = 1,
        startAmmo = -1,
        maxAmmo = 1,
        permanent = true,
        throwDist = 50,
        TPSOffsets = {
            hold = CFrame.new(-0.1, 0.25, -0.125)
        },
        viewportOffsets = {
            hotbar = {
                dist = 2.75,
                offset = CFrame.new(0, -0.125, 0),
                rotoffset = CFrame.Angles(0, 1.8849555921538759, 0)
            },
            ammoHUD = {
                dist = 2,
                offset = CFrame.new(0, 0.1, 0),
                rotoffset = CFrame.Angles(0, (math.pi/2), 0)
            }
        }
    },
    ["El Fuego"] = {
        name = "El Fuego",
        modelName = "El Fuego",
        subtype = "Flamethrower",
        unpurchasable = true,
        ammo = 600,
        startAmmo = 0,
        maxAmmo = 600,
        reloadTime = 6,
        reloadType = "mag",
        firemode = "auto",
        damage = 6,
        numProjectiles = 3,
        fireDebounce = 0.05,
        projectileLength = 4,
        projectileLifetime = 60,
        speedDropoff = 0.04,
        speedMax = 5,
        baseSpread = 4,
        baseAimSpread = 2,
        spread = 12,
        aimSpread = 6,
        recoilAdd = 0.1,
        maxRecoil = 1,
        recoilDiminishFactor = 0.95,
        recoilFastDiminishFactor = 0.8
    }
}

local function getItemList()
    local itemList = {}
    for _, itemName in ipairs(items) do
        local displayName = itemDisplayNames[itemName] or itemName
        table.insert(itemList, displayName)
    end
    return itemList
end

local selectedItem = ""

local itemDropdown = Main:Dropdown({
    Title = "选择物品",
    Desc = "从列表中选择要获得的物品",
    Values = getItemList(),
    Value = "",
    Callback = function(value)
        if value and value ~= "" then
            selectedItem = value
        else
            selectedItem = ""
        end
    end
})

local function getItemNameByDisplayName(displayName)
    for itemName, dispName in pairs(itemDisplayNames) do
        if dispName == displayName then
            return itemName
        end
    end
    return displayName
end

local function addItem(itemName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    pcall(function()
        local itemSystem = require(ReplicatedStorage.devv).load("v3item")
        local inventory = itemSystem.inventory
        
        if not itemData[itemName] then
            warn("物品数据不存在: " .. itemName)
            return
        end
        
        local itemConfig = itemData[itemName]
        local itemToAdd = {
            name = itemConfig.name,
            guid = itemName:lower():gsub(" ", "_").."_"..tostring(tick()),
            permanent = itemConfig.permanent or true,
            canDrop = itemConfig.canDrop or true,
            dropCooldown = itemConfig.dropCooldown or 120,
            multiplier = itemConfig.multiplier or 0.625,
            holdableType = itemConfig.holdableType or "Balloon",
            movespeedAdd = itemConfig.movespeedAdd or 0,
            cannotDiscard = itemConfig.cannotDiscard or false,
            TPSOffsets = itemConfig.TPSOffsets or {hold = CFrame.new(0, 0.5, 0)},
            viewportOffsets = itemConfig.viewportOffsets or {
                hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
                ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)},
                slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}
            }
        }
        
        if itemConfig.subtype then itemToAdd.subtype = itemConfig.subtype end
        if itemConfig.modelName then itemToAdd.modelName = itemConfig.modelName end
        if itemConfig.adminOnly then itemToAdd.adminOnly = itemConfig.adminOnly end
        if itemConfig.damage then itemToAdd.damage = itemConfig.damage end
        if itemConfig.ammo then itemToAdd.ammo = itemConfig.ammo end
        if itemConfig.startAmmo then itemToAdd.startAmmo = itemConfig.startAmmo end
        if itemConfig.maxAmmo then itemToAdd.maxAmmo = itemConfig.maxAmmo end
        if itemConfig.reloadTime then itemToAdd.reloadTime = itemConfig.reloadTime end
        if itemConfig.reloadType then itemToAdd.reloadType = itemConfig.reloadType end
        if itemConfig.firemode then itemToAdd.firemode = itemConfig.firemode end
        if itemConfig.numProjectiles then itemToAdd.numProjectiles = itemConfig.numProjectiles end
        if itemConfig.fireDebounce then itemToAdd.fireDebounce = itemConfig.fireDebounce end
        if itemConfig.projectileLength then itemToAdd.projectileLength = itemConfig.projectileLength end
        if itemConfig.projectileLifetime then itemToAdd.projectileLifetime = itemConfig.projectileLifetime end
        if itemConfig.headshotMultiplier then itemToAdd.headshotMultiplier = itemConfig.headshotMultiplier end
        if itemConfig.hint then itemToAdd.hint = itemConfig.hint end
        if itemConfig.isConsumable then itemToAdd.isConsumable = itemConfig.isConsumable end
        if itemConfig.isNade then itemToAdd.isNade = itemConfig.isNade end
        if itemConfig.throwDist then itemToAdd.throwDist = itemConfig.throwDist end
        if itemConfig.sellPrice then itemToAdd.sellPrice = itemConfig.sellPrice end
        if itemConfig.adminLimit then itemToAdd.adminLimit = itemConfig.adminLimit end
        if itemConfig.overrideProjectileProperties then itemToAdd.overrideProjectileProperties = itemConfig.overrideProjectileProperties end
        if itemConfig.recoilAdd then itemToAdd.recoilAdd = itemConfig.recoilAdd end
        if itemConfig.maxRecoil then itemToAdd.maxRecoil = itemConfig.maxRecoil end
        if itemConfig.recoilDiminishFactor then itemToAdd.recoilDiminishFactor = itemConfig.recoilDiminishFactor end
        if itemConfig.recoilFastDiminishFactor then itemToAdd.recoilFastDiminishFactor = itemConfig.recoilFastDiminishFactor end
        
        if inventory.add then
            inventory.add(itemToAdd, false)
            if inventory.currentItemsData then
                table.insert(inventory.currentItemsData, itemToAdd)
            end
        end
        
        if inventory.rerender then
            inventory:rerender()
        end
    end)
end

Main:Button({
    Title = "免费获得选择的物品",
    Callback = function()
        if selectedItem and selectedItem ~= "" then
            local itemName = getItemNameByDisplayName(selectedItem)
            if itemName then
                addItem(itemName)
            end
        end
    end
})
Main:Section({ Title = "免费箱子", Icon = "swords" })
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local load = require(ReplicatedStorage.devv).load
local var4_result1_upvr_5 = load("skins")
local var4_result1_upvr_9 = load("state")
local var4_result1_upvr_10 = load("Signal")

local caseList = {}
local selectedCase = "Series3Heavy"

local function getAvailableCases()
    local cases = {}
    for caseName, caseData in pairs(var4_result1_upvr_5.cases) do
        table.insert(cases, caseName)
    end
    table.sort(cases)
    return cases
end

caseList = getAvailableCases()

Main:Dropdown({
    Title = "选择箱子类型",
    Values = caseList,
    Value = selectedCase,
    Callback = function(value)
        selectedCase = value
    end
})

Main:Button({
    Title = "获得999个选中箱子",
    Callback = function()
        if not var4_result1_upvr_9.data.ownedCases then
            var4_result1_upvr_9.data.ownedCases = {}
        end
        
        var4_result1_upvr_9.data.ownedCases[selectedCase] = 999
        
        if var4_result1_upvr_9.data.ownedCases[selectedCase] then
        else
        end
    end
})

Main:Button({
    Title = "获得所有箱子999个",
    Callback = function()
        if not var4_result1_upvr_9.data.ownedCases then
            var4_result1_upvr_9.data.ownedCases = {}
        end
        
        local count = 0
        for _, caseName in ipairs(caseList) do
            var4_result1_upvr_9.data.ownedCases[caseName] = 999
            count = count + 1
        end
    end
})

Main:Section({ Title = "皮肤类", Icon = "swords" })
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local load = require(ReplicatedStorage.devv).load
local var6_result1_upvr_5 = load("skins")
local var6_result1_upvr_4 = load("state")
local var6_result1_upvr_2 = load("Signal")

local skinList = {}
local selectedWeapon = "AK-47"
local selectedSkin = ""

local function getWeaponList()
    local weapons = {}
    for _, weapon in ipairs(var6_result1_upvr_5.compatabilities.Generic or {}) do
        table.insert(weapons, weapon)
    end
    table.sort(weapons)
    return weapons
end

local function getSkinListForWeapon(weapon)
    local skins = {}
    for skinName, skinData in pairs(var6_result1_upvr_5.skinData or {}) do
        local compatTable = var6_result1_upvr_5.GetCompatabilityTable(skinName, weapon)
        if compatTable and #compatTable > 0 then
            table.insert(skins, skinName)
        end
    end
    table.sort(skins)
    return skins
end

local weaponList = getWeaponList()

Main:Dropdown({
    Title = "选择类型",
    Values = weaponList,
    Value = selectedWeapon,
    Callback = function(value)
        selectedWeapon = value
        local weaponSkins = getSkinListForWeapon(value)
        skinList = weaponSkins
        if #weaponSkins > 0 then
            selectedSkin = weaponSkins[1]
        else
            selectedSkin = ""
        end
    end
})

Main:Dropdown({
    Title = "选择皮肤",
    Values = skinList,
    Value = selectedSkin,
    Callback = function(value)
        selectedSkin = value
    end
})

Main:Button({
    Title = "更换皮肤",
    Callback = function()
        if selectedWeapon == "" or selectedSkin == "" then
            WindUI:Notify({
                Title = "皮肤",
                Content = "请选择武器和皮肤",
                Duration = 3,
                Icon = "warning"
            })
            return
        end
        
        local compatTable = var6_result1_upvr_5.GetCompatabilityTable(selectedSkin, selectedWeapon)
        if not compatTable or #compatTable == 0 then
            WindUI:Notify({
                Title = "皮肤",
                Content = "该皮肤不适用于所选武器",
                Duration = 3,
                Icon = "warning"
            })
            return
        end
        
        local it = load("v3item").inventory
        it.skinUpdate(selectedWeapon, selectedSkin)
        
        WindUI:Notify({
            Title = "皮肤",
            Content = "已更换" .. selectedWeapon .. "的皮肤为" .. selectedSkin,
            Duration = 3,
            Icon = "check"
        })
    end
})

if #weaponList > 0 then
    local weaponSkins = getSkinListForWeapon(selectedWeapon)
    skinList = weaponSkins
    if #weaponSkins > 0 then
        selectedSkin = weaponSkins[1]
    end
end
local function setupCurrencyCheats()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local load = require(ReplicatedStorage.devv).load
    local Signal = load("Signal")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local moneyDisplay = load("moneyDisplay")
    local v3item = load("v3item")

    local gingerbreadAmount = 99999
    local moneyAmount = 999999999

    Main:Section({ Title = "姜饼人", Icon = "cookie" })

    Main:Input({
        Title = "姜饼人数量",
        Value = "99999",
        Placeholder = "输入姜饼人数量",
        Callback = function(value)
            local num = tonumber(value)
            if num and num > 0 then
                gingerbreadAmount = num
            end
        end
    })

    Main:Button({
        Title = "获得姜饼人",
        Icon = "cookie",
        Callback = function()
            pcall(function()
                LocalPlayer:SetAttribute("gingerbread", gingerbreadAmount)
            end)
            
            WindUI:Notify({
                Title = "姜饼人",
                Content = string.format("获得 %d 个姜饼人", gingerbreadAmount),
                Duration = 3,
                Icon = "check"
            })
        end
    })

    Main:Section({ Title = "金钱", Icon = "dollar-sign" })

    Main:Input({
        Title = "金钱数量",
        Value = "999999999",
        Placeholder = "输入金钱数量",
        Callback = function(value)
            local num = tonumber(value)
            if num and num > 0 then
                moneyAmount = num
            end
        end
    })

    Main:Button({
        Title = "获得金钱",
        Icon = "dollar-sign",
        Callback = function()
            pcall(function()
                local moneydata = tostring(moneyAmount)
                moneyDisplay.current = moneydata
                moneyDisplay.tweenTo = moneydata
                moneyDisplay.caChing()
            end)
            
            WindUI:Notify({
                Title = "金钱",
                Content = string.format("获得 $%s", tostring(moneyAmount)),
                Duration = 3,
                Icon = "check"
            })
        end
    })

    Main:Button({
        Title = "更新钱包显示",
        Icon = "refresh-cw",
        Callback = function()
            pcall(function()
                local equippedItem = v3item.inventory.getEquipped()
                if equippedItem and equippedItem.name == "Wallet" then
                    local moneydata = tostring(moneyAmount)
                    equippedItem.controller:updateMoney(moneydata)
                    
                    WindUI:Notify({
                        Title = "钱包更新",
                        Content = "已更新钱包显示",
                        Duration = 2,
                        Icon = "check"
                    })
                else
                    WindUI:Notify({
                        Title = "错误",
                        Content = "请先装备钱包",
                        Duration = 3,
                        Icon = "x"
                    })
                end
            end)
        end
    })
end

setupCurrencyCheats()

local Main = Window:Tab({Title = "金钱", Icon = "dollar-sign"})

local autobank = false
local bankTeleportCFrame = CFrame.new(1112.12671, 10.1856346, -324.815613)  
local originalPosition = nil  

local function robBankAndReturn()
    if not autobank then return end
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    originalPosition = rootPart.CFrame
    
    rootPart.CFrame = bankTeleportCFrame
    task.wait(0.1)
    
    local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
    
    local waitTime = 0.1
    local maxWait = 5.0
    
    local startTime = tick()
    while autobank and (tick() - startTime) < maxWait do
        Signal.FireServer("stealBankCash")
        task.wait(waitTime)
    end
    
    if autobank and originalPosition then
        rootPart.CFrame = originalPosition
        task.wait(0.1)
    end
    
    originalPosition = nil
end

local bankThread = nil

local function startBankRobberyLoop()
    if bankThread then return end
    
    bankThread = task.spawn(function()
        while autobank do
            robBankAndReturn()
            task.wait(0.5)
        end
        bankThread = nil
    end)
end

local function stopBankRobberyLoop()
    if bankThread then
        task.cancel(bankThread)
        bankThread = nil
    end
end

Main:Toggle({
    Title = "自动抢银行",
    Value = false,
    Callback = function(state) 
        autobank = state
        if autobank then
            startBankRobberyLoop()
        else
            stopBankRobberyLoop()
        end
    end
})

Main:Toggle({
    Title = "自动ATM",
    Default = false,
    Callback = function(Value)
        autoATMCashCombo = Value
        
        if autoATMCashCombo then
            local function collectCash()
                local player = game:GetService("Players").LocalPlayer
                local cashSize = Vector3.new(2, 0.2499999850988388, 1)
                
                for _, part in ipairs(workspace.Game.Entities.CashBundle:GetDescendants()) do
                    if part:IsA("BasePart") and part.Size == cashSize then
                        player.Character.HumanoidRootPart.CFrame = part.CFrame
                        task.wait()
                    end
                end
            end
            
            coroutine.wrap(function()
                while autoATMCashCombo and task.wait() do
                   
                    local ATMsFolder = workspace:FindFirstChild("ATMs")
                    local localPlayer = game:GetService("Players").LocalPlayer
                    local hasActiveATM = false
                    
                    if ATMsFolder and localPlayer.Character then
                        for _, atm in ipairs(ATMsFolder:GetChildren()) do
                            if atm:IsA("Model") then
                                local hp = atm:GetAttribute("health")
                                if hp ~= 0 then
                                    hasActiveATM = true
                                    for _, part in ipairs(atm:GetChildren()) do
                                        if part.Name == "Main" and part:IsA("BasePart") then
                                            localPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                                            task.wait()
                                            atm:SetAttribute("health", 0)
                                            break
                                        end
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                    
                    if hasActiveATM then
                        task.wait(1)
                    else
                        collectCash()
                        
                 
                        task.wait()
                    end
                end
            end)()
        end
    end
})

local autoCraftEnabled = false
local autoClaimEnabled = false
local craftConnection

local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")

local function performCrafting()
    if autoCraftEnabled then
        Signal.InvokeServer("beginCraft", 'RollieCraft')
    end
    
    if autoClaimEnabled then
        Signal.InvokeServer("claimCraft", 'RollieCraft')
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoCraftEnabled or autoClaimEnabled then
        performCrafting()
    end
end)

Main:Toggle({
    Title = "自动制作萝莉",
    Default = false,
    Callback = function(Value)
        autoCraftEnabled = Value
    end
})

Main:Toggle({
    Title = "自动领取萝莉",
    Default = false,
    Callback = function(Value)
        autoClaimEnabled = Value
    end
})

local autoStoreGems = false
local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items

local function storeGems()
    for _, v in pairs(workspace.HousingPlots:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if v.ActionText == "Add Gem" or v.ActionText == "Equip a Gem" then
                local houseid = v.Parent.Parent.Name
                local hitid = v.Parent.Name
                for i, item in next, b1 do
                    if item.name == "Diamond" or item.name == "Rollie" or item.name == "Dark Matter Gem" or item.name == "Diamond Ring" or item.name == "Void Gem" then
                        Signal.FireServer("equip", item.guid)
                        Signal.FireServer("updateGemDisplay", houseid, hitid, item.guid)
                    end
                end
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoStoreGems then
        storeGems()
    end
end)

Main:Toggle({
    Title = "自动存放珠宝到家用珠宝柜",
    Desc = "需要有房子和珠宝柜",
    Default = false,
    Callback = function(Value)
        autoStoreGems = Value
    end
})
local autoRentHouse = false

local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")

local function rentHouse()
    for _, v in pairs(workspace.HousingPlots:GetChildren()) do
        if not v:GetAttribute("Owner") then
            local housename = v
            Signal.InvokeServer("rentHouse", v)
        end
    end
end

local lastRentTime = 0
game:GetService("RunService").Heartbeat:Connect(function()
    if autoRentHouse and tick() - lastRentTime >= 2 then
        rentHouse()
        lastRentTime = tick()
    end
end)

Main:Toggle({
    Title = "自动租用房屋",
    Default = false,
    Callback = function(Value)
        autoRentHouse = Value
    end
})
local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")

local autoClaimEnabled = false
local autoClaimConnection = nil

local function autoClaimRewards()
   
    for day = 1, 12 do
        Signal.InvokeServer("claimDailyReward", day)
        task.wait(0.1)
    end
    
   
    for tier = 1, 3 do
        for level = 1, 6 do
            Signal.InvokeServer("claimPlaytimeReward", tier, level)
            task.wait(0.1)
        end
    end
    
    WindUI:Notify({Title = "自动领取", Content = "奖励领取完成", Duration = 2})
end

local function startAutoClaimLoop()
    autoClaimEnabled = true
    autoClaimConnection = task.spawn(function()
        while autoClaimEnabled do
            autoClaimRewards()
            task.wait(5) 
        end
    end)
end

local function stopAutoClaimLoop()
    autoClaimEnabled = false
    if autoClaimConnection then
        autoClaimConnection:Disconnect()
        autoClaimConnection = nil
    end
end

Main:Toggle({
    Title = "自动领取奖励",
    Default = false,
    Callback = function(Value)
        if Value then
            startAutoClaimLoop()
        else
            stopAutoClaimLoop()
        end
    end
})
local function teleportToAirdrop()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local originalPosition = rootPart.CFrame
    local foundAirdrop = false
    local airdrops = game:GetService('Workspace').Game.Airdrops:GetChildren()
    for _, airdrop in pairs(airdrops) do
        if airdrop:FindFirstChild('Airdrop') and airdrop.Airdrop:FindFirstChild('ProximityPrompt') then
            local prompt = airdrop.Airdrop.ProximityPrompt
            prompt.RequiresLineOfSight = false
            prompt.HoldDuration = 0
            rootPart.CFrame = airdrop.Airdrop.CFrame
            task.wait(0.1) 
            
      
            for i = 1, 15 do
                fireproximityprompt(prompt)
                task.wait(0.02) 
            end
            
            foundAirdrop = true
            break
        end
    end
    
 
    if not foundAirdrop then
        rootPart.CFrame = originalPosition
    else
       
        task.wait(0.3)
        rootPart.CFrame = originalPosition
    end
    
    return foundAirdrop
end
local airdropAutoEnabled = false
Main:Toggle({
    Title = "自动空投",
    Default = false,
    Callback = function(Value)
        airdropAutoEnabled = Value
        if Value then
            task.spawn(function()
                while airdropAutoEnabled do
                    local collected = teleportToAirdrop()
                    if not collected then
                  
                        for i = 1, 10 do
                            if not airdropAutoEnabled then break end
                            task.wait(0.1)
                        end
                    else
                     
                        for i = 1, 3 do
                            if not airdropAutoEnabled then break end
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
})

local function fastCollectMoney()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return false end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    local originalPosition = humanoidRootPart.CFrame
    local foundMoney = false
    local moneyEntities = workspace.Game.Entities.CashBundle:GetChildren()
    for i = 1, #moneyEntities do
        local l = moneyEntities[i]
        local moneyValue = l:FindFirstChildWhichIsA("IntValue")
        if moneyValue and moneyValue.Value >= setting.minMoney then
            humanoidRootPart.CFrame = l:FindFirstChildWhichIsA("Part").CFrame
            task.wait(0.2)
            humanoidRootPart.CFrame = originalPosition
            foundMoney = true
            break
        end
    end
    return foundMoney
end

Main:Toggle({
    Title = "自动捡钱",
    Default = false,
    Callback = function(Value)
        setting.autoMoney = Value
        if Value then
            task.spawn(function()
                while setting.autoMoney and task.wait(0.1) do
                    fastCollectMoney()
                end
            end)
        end
    end
})

Main:Slider({
    Title = "最低钱数设置",
    Value = {
        Min = 250,
        Max = 1000,
        Default = 250,
    },
    Callback = function(Value)
        setting.minMoney = Value
    end
})

local function crackSafes()
    while autoOpenSafes do
        if not checkAnyTargetExists() then
            teleportToHideSpot()
            task.wait(1)
        else
            pcall(function()
                local rootPart = getRootPart()
                if not rootPart then return end

                for _, obj in ipairs(workspace.Game.Entities:GetDescendants()) do
                    if not autoOpenSafes then break end
                    if obj:IsA("ProximityPrompt") and obj.ActionText == "Crack Safe" and obj.Enabled then
                        obj.RequiresLineOfSight = false
                        obj.HoldDuration = 0

                        local target = obj.Parent and obj.Parent.Parent
                        if target and target:IsA("BasePart") then
                            rootPart.CFrame = CFrame.new(target.Position)
                            task.wait(1)
                            fireproximityprompt(obj)
                            task.wait(0.5)
                            task.wait(2)
                            pickupAll15m(target.Position)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end
end

local function crackChests()
    while autoOpenChests do
        if not checkAnyTargetExists() then
            teleportToHideSpot()
            task.wait(1)
        else
            pcall(function()
                local rootPart = getRootPart()
                if not rootPart then return end

                for _, obj in ipairs(workspace.Game.Entities:GetDescendants()) do
                    if not autoOpenChests then break end
                    if obj:IsA("ProximityPrompt") and obj.ActionText == "Crack Chest" and obj.Enabled then
                        obj.RequiresLineOfSight = false
                        obj.HoldDuration = 0

                        local target = obj.Parent and obj.Parent.Parent
                        if target and target:IsA("BasePart") then
                            rootPart.CFrame = CFrame.new(target.Position)
                            task.wait(1)
                            fireproximityprompt(obj)
                            task.wait(0.5)
                            task.wait(2)
                            pickupAll15m(target.Position)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end
end

local function updateThreads()
    if safeThread then
        task.cancel(safeThread)
        safeThread = nil
    end
    if autoOpenSafes then
        safeThread = task.spawn(crackSafes)
    end

    if chestThread then
        task.cancel(chestThread)
        chestThread = nil
    end
    if autoOpenChests then
        chestThread = task.spawn(crackChests)
    end
end

Main:Toggle({
    Title = "自动保险箱",
    Default = false,
    Callback = function(Value)
        autoOpenSafes = Value
        updateThreads()
    end
})

Main:Toggle({
    Title = "自动宝箱",
    Default = false,
    Callback = function(Value)
        autoOpenChests = Value
        updateThreads()
    end
})

Main:Toggle({
    Title = "自动购买撬锁",
    Default = false,
    Callback = function(Value)
        lock = Value
        task.spawn(function()
            while lock and task.wait() do
                pcall(function()
                    local Players = game:GetService("Players")
                    local localPlayer = Players.LocalPlayer
                    if localPlayer.Character then
                        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            Signal.InvokeServer("attemptPurchase", "Lockpick")
                        end
                    end
                end)
            end
        end)
    end
})

local F2 = Window:Tab({Title = "物品", Icon = "box"})
F2:Toggle({
    Title = "自动捡价值宝石",
    --Image = "bird",
    Value = false,
    Callback = function(state) 
    autobs = state
    if autobs then
    while autobs and wait() do 
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local rootPart = localPlayer.Character.HumanoidRootPart

    for _, l in pairs(game.Workspace.Game.Entities.ItemPickup:GetChildren()) do
        for _, v in pairs(l:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local e = v:FindFirstChildOfClass("ProximityPrompt")
                if e and (e.ObjectText == "" or e.ObjectText == "+" or e.ObjectText == ""  or e.ObjectText == ""  or e.ObjectText == ""  or e.ObjectText == "Diamond Ring"  or e.ObjectText == "Diamond" or e.ObjectText == "Void Gem" or e.ObjectText == "Dark Matter Gem" or e.ObjectText == "Rollie" or e.ObjectText == "") then
                    rootPart.CFrame = v.CFrame * CFrame.new(0, 2, 0)
                    e.RequiresLineOfSight = false
                    e.HoldDuration = 0
                    fireproximityprompt(e)
                end
            end
        end
    end
    end
    end
    end
})
F2:Toggle({
    Title = "自动捡贵重物品",
    --Image = "bird",
    Value = false,
    Callback = function(state) 
    autogzwp = state
    if autogzwp then
    while autogzwp and wait() do 
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local rootPart = localPlayer.Character.HumanoidRootPart
    for _, l in pairs(game.Workspace.Game.Entities.ItemPickup:GetChildren()) do
        for _, v in pairs(l:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local e = v:FindFirstChildOfClass("ProximityPrompt")
                if e and (e.ObjectText == "Green Lucky Block" or e.ObjectText == "Orange Lucky Block" or e.ObjectText == "Purple Lucky Block" or e.ObjectText == "Blue Candy Cane" or e.ObjectText == "Suitcase Nuke" or e.ObjectText == "Nuke Launcher" or e.ObjectText == "Easter Basket" or e.ObjectText == "Gold Cup" or e.ObjectText == "Gold Crown" or e.ObjectText == "Pearl Necklace" or e.ObjectText == "Treasure Map"or e.ObjectText == "Spectral Scythe" or e.ObjectText == "Bunny Balloon" or e.ObjectText == "Ghost Balloon" or e.ObjectText == "Clover Balloon" or e.ObjectText == "Bat Balloon" or e.ObjectText == "Gold Clover Balloon" or e.ObjectText == "Golden Rose" or e.ObjectText == "Black Rose" or e.ObjectText == "Heart Balloon" or e.ObjectText == "Skull Balloon" or e.ObjectText == "Money Printer") then
                    rootPart.CFrame = v.CFrame * CFrame.new(0, 2, 0)
                    e.RequiresLineOfSight = false
                    e.HoldDuration = 0
                    fireproximityprompt(e)
                end
            end
        end
    end
    end
    end
    end
})

F2:Toggle({
    Title = "自动捡普通宝石",
    --Image = "bird",
    Value = false,
    Callback = function(state) 
    autobs = state
    if autobs then
    while autobs and wait() do 
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local rootPart = localPlayer.Character.HumanoidRootPart

    for _, l in pairs(game.Workspace.Game.Entities.ItemPickup:GetChildren()) do
        for _, v in pairs(l:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local e = v:FindFirstChildOfClass("ProximityPrompt")
                if e and (e.ObjectText == "Amethyst" or e.ObjectText == "Sapphire" or e.ObjectText == "Emerald"  or e.ObjectText == "Topaz"  or e.ObjectText == "Ruby"  or e.ObjectText == "Diamond Ring"  or e.ObjectText == "Diamond" or e.ObjectText == "Void Gem" or e.ObjectText == "Dark Matter Gem" or e.ObjectText == "Rollie" or e.ObjectText == "Gold Bar") then
                    rootPart.CFrame = v.CFrame * CFrame.new(0, 2, 0)
                    e.RequiresLineOfSight = false
                    e.HoldDuration = 0
                    fireproximityprompt(e)
                end
            end
        end
    end
    end
    end
    end
})
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local devv               = require(ReplicatedStorage.devv)
local item               = devv.load("v3item")
local Signal             = devv.load("Signal")
local junkWeps  = {"Uzi","M1911","C4","Glock","Mossberg","Stagecouch","Python"}
local junkGems  = {"","","","",""}
local junkMisc  = {"Baseball Bat","Basketball","Bloxaide","Bloxy Cola","Cake","Stop Sign"}
local setting = { collect = {} }
local function rmList(list)
    for _, v in next, item.inventory.items do
        for _, name in ipairs(list) do
            if v.name == name then
                Signal.FireServer("removeItem", v.guid)
             
                break
            end
        end
    end
end
local running = {}         
local function loopClean(key, list)
    if running[key] then return end        
    running[key] = true
    task.spawn(function()
        while setting.collect[key] do
            rmList(list)
            task.wait(0.5)
        end
        running[key] = false
    end)
end
local function addToggle(title, key, list)
    F2:Toggle({
        Title   = title,
        Default = false,
        Callback = function(v)
            setting.collect[key] = v
            if v then loopClean(key, list) end
        end
    })
end

do
    local allJunk = {}
    for _, v in ipairs(junkWeps)  do table.insert(allJunk, v) end
    for _, v in ipairs(junkGems)  do table.insert(allJunk, v) end
    for _, v in ipairs(junkMisc)  do table.insert(allJunk, v) end
    rmList(allJunk)
end
addToggle("自动移除垃圾枪",   "autoremoveweps",  junkWeps)
addToggle("自动移除垃圾宝石", "autoremovegems",  junkGems)
addToggle("自动移除其它垃圾", "autoremovemisc",  junkMisc)

F2:Section({ Title = "物品栏数量", Icon = "box" })

F2:Slider({
    Title = "物品栏数量",
    Desc = "调整背包物品栏的数量",
    Value = {
        Min = 1,
        Max = 12,
        Default = 6,
    },
    Callback = function(Value)
        local sum = require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)
        sum.numSlots = Value
    end
})


local Main = Window:Tab({Title = "骚扰类", Icon = "phone"})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.devv).load("Signal")
local TweenService = game:GetService("TweenService")

harassSettings = {
    targetPlayer = nil,
    messageText = "我是神",
    isSpamming = false,
    spamInterval = 1,
    autoMessages = {
        "孩子干啥呢啊",
        "有什么实力",
        "活着干啥呢",
        "XH HUB",
        "BYPASS"
    },
    autoMessageIndex = 1,
    isAutoCalling = false,
    callInterval = 5,
    currentCallId = nil,
    playerList = {},
    lastPlayerRefresh = 0,
    playerRefreshInterval = 5,
    spamAllEnabled = false,
    blockAllEnabled = false
}

function startAutoCall()
    if not harassSettings.targetPlayer then
        WindUI:Notify({Title = "打电话", Content = "请先选择目标玩家", Duration = 3, Icon = "phone-off"})
        return false
    end
    
    harassSettings.isAutoCalling = true
    
    task.spawn(function()
        while harassSettings.isAutoCalling and harassSettings.targetPlayer do
            pcall(function()
                local success, callId = Signal.InvokeServer("attemptCall", harassSettings.targetPlayer.UserId)
                
                if success then
                    harassSettings.currentCallId = callId
                    WindUI:Notify({
                        Title = "打电话", 
                        Content = "正在呼叫: " .. harassSettings.targetPlayer.Name,
                        Duration = 3, 
                        Icon = "phone-outgoing"
                    })
                    
                    local callDuration = math.random(10, 30)
                    local startTime = os.time()
                    
                    while harassSettings.isAutoCalling and os.time() - startTime < callDuration do
                        task.wait(1)
                    end
                    
                    if harassSettings.currentCallId then
                        Signal.FireServer("sendPhoneAction", harassSettings.currentCallId, "hangup")
                        harassSettings.currentCallId = nil
                    end
                else
                    WindUI:Notify({
                        Title = "打电话", 
                        Content = "呼叫失败: " .. harassSettings.targetPlayer.Name,
                        Duration = 3, 
                        Icon = "phone-missed"
                    })
                end
            end)
            
            if harassSettings.isAutoCalling then
                task.wait(harassSettings.callInterval)
            end
        end
    end)
end

function stopAutoCall()
    harassSettings.isAutoCalling = false
    if harassSettings.currentCallId then
        Signal.FireServer("sendPhoneAction", harassSettings.currentCallId, "hangup")
        harassSettings.currentCallId = nil
    end
end

function startSpam()
    harassSettings.isSpamming = true
    task.spawn(function()
        while harassSettings.isSpamming and harassSettings.targetPlayer do
            pcall(function()
                Signal.FireServer("sendMessage", harassSettings.targetPlayer.UserId, harassSettings.messageText)
            end)
            task.wait(harassSettings.spamInterval)
        end
    end)
end

function startAutoMessages()
    task.spawn(function()
        while harassSettings.isSpamming and harassSettings.targetPlayer do
            pcall(function()
                Signal.FireServer("sendMessage", harassSettings.targetPlayer.UserId, 
                    harassSettings.autoMessages[harassSettings.autoMessageIndex])
                
                harassSettings.autoMessageIndex = harassSettings.autoMessageIndex + 1
                if harassSettings.autoMessageIndex > #harassSettings.autoMessages then
                    harassSettings.autoMessageIndex = 1
                end
            end)
            task.wait(harassSettings.spamInterval)
        end
    end)
end

function startSpamAll()
    harassSettings.spamAllEnabled = true
    task.spawn(function()
        while harassSettings.spamAllEnabled do
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer then
                        Signal.FireServer("sendMessage", player.UserId, harassSettings.messageText)
                    end
                end
            end)
            task.wait(harassSettings.spamInterval)
        end
    end)
end

function stopSpamAll()
    harassSettings.spamAllEnabled = false
end

function blockAllMessages()
    if not harassSettings.blockAllEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            Signal.FireServer("blockPlayer", player.UserId)
        end
    end
end

function refreshPlayerList()
    local currentTime = os.time()
    if currentTime - harassSettings.lastPlayerRefresh < harassSettings.playerRefreshInterval then
        return harassSettings.playerList
    end
    
    harassSettings.lastPlayerRefresh = currentTime
    harassSettings.playerList = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(harassSettings.playerList, {
                text = player.Name .. " (@" .. player.DisplayName .. ")",
                value = player.Name
            })
        end
    end
    
    table.sort(harassSettings.playerList, function(a, b)
        return a.text:lower() < b.text:lower()
    end)
    
    return harassSettings.playerList
end

function getPlayerListValues()
    refreshPlayerList()
    local values = {}
    for _, player in ipairs(harassSettings.playerList) do
        table.insert(values, player.text)
    end
    return values
end

Main:Paragraph({
    Title = "小伙伴赶紧骚扰小伙伴吧",
    Desc = "有缺陷请提出",
    Image = "phone",
    ImageSize = 20,
    Color = "Red"
})

local playerDropdown = Main:Dropdown({
    Title = "选择目标玩家",
    Desc = "自动刷新玩家列表",
    Values = getPlayerListValues(),
    Value = "",
    Callback = function(value)
        if value and value ~= "" then
            local playerName = value:match("^([^%s]+)")
            if playerName then
                harassSettings.targetPlayer = Players:FindFirstChild(playerName)
                if harassSettings.targetPlayer then
                    WindUI:Notify({
                        Title = "目标设置", 
                        Content = "已选择: " .. harassSettings.targetPlayer.Name,
                        Duration = 2, 
                        Icon = "user-check"
                    })
                else
                    WindUI:Notify({
                        Title = "错误", 
                        Content = "未找到玩家: " .. playerName,
                        Duration = 3, 
                        Icon = "user-x"
                    })
                end
            end
        else
            harassSettings.targetPlayer = nil
        end
    end
})

Main:Button({
    Title = "刷新玩家列表",
    Icon = "refresh-cw",
    Callback = function()
        local newValues = getPlayerListValues()
        playerDropdown:Refresh(newValues)
        WindUI:Notify({
            Title = "玩家列表", 
            Content = "已刷新，找到 " .. #newValues .. " 个玩家",
            Duration = 2, 
            Icon = "users"
        })
    end
})

Main:Toggle({
    Title = "自动打电话",
    Value = false,
    Callback = function(isEnabled)
        if isEnabled and not harassSettings.targetPlayer then
            WindUI:Notify({
                Title = "错误", 
                Content = "请先选择目标玩家",
                Duration = 3, 
                Icon = "user-x"
            })
            return false
        end
        
        if isEnabled then
            startAutoCall()
            WindUI:Notify({
                Title = "开始打电话", 
                Content = "开始自动呼叫: " .. harassSettings.targetPlayer.Name,
                Duration = 3, 
                Icon = "phone-outgoing"
            })
        else
            stopAutoCall()
            WindUI:Notify({
                Title = "停止打电话", 
                Content = "已停止自动呼叫",
                Duration = 2, 
                Icon = "phone-off"
            })
        end
    end
})

Main:Slider({
    Title = "呼叫间隔",
    Desc = "设置每次呼叫的时间间隔（秒）",
    Value = {Min = 3, Max = 60, Default = 5},
    Callback = function(value)
        harassSettings.callInterval = value
    end
})

Main:Input({
    Title = "自定义消息",
    Value = "我是神",
    Placeholder = "输入要发送的消息内容",
    Callback = function(value)
        harassSettings.messageText = value
    end
})

Main:Toggle({
    Title = "消息轰炸[自定义]",
    Value = false,
    Callback = function(isEnabled)
        if isEnabled and not harassSettings.targetPlayer then
            WindUI:Notify({
                Title = "错误", 
                Content = "请先选择目标玩家",
                Duration = 3, 
                Icon = "user-x"
            })
            return false
        end
        
        harassSettings.isSpamming = isEnabled
        if isEnabled then
            startSpam()
            WindUI:Notify({
                Title = "开始轰炸", 
                Content = "开始向 " .. harassSettings.targetPlayer.Name .. " 发送消息",
                Duration = 3, 
                Icon = "send"
            })
        else
            WindUI:Notify({
                Title = "停止轰炸", 
                Content = "已停止发送消息",
                Duration = 2, 
                Icon = "square"
            })
        end
    end
})

Main:Toggle({
    Title = "自动发送预设消息",
    Value = false,
    Callback = function(isEnabled)
        if isEnabled and not harassSettings.targetPlayer then
            WindUI:Notify({
                Title = "错误", 
                Content = "请先选择目标玩家",
                Duration = 3, 
                Icon = "user-x"
            })
            return false
        end
        
        harassSettings.isSpamming = isEnabled
        if isEnabled then
            startAutoMessages()
            WindUI:Notify({
                Title = "开始自动消息", 
                Content = "开始发送预设消息给 " .. harassSettings.targetPlayer.Name,
                Duration = 3, 
                Icon = "message-circle"
            })
        else
            WindUI:Notify({
                Title = "停止自动消息", 
                Content = "已停止发送预设消息",
                Duration = 2, 
                Icon = "message-square"
            })
        end
    end
})

Main:Slider({
    Title = "消息间隔",
    Desc = "设置发送消息的时间间隔（秒）",
    Value = {Min = 0.1, Max = 5, Default = 1},
    Callback = function(value)
        harassSettings.spamInterval = value
    end
})

Main:Toggle({
    Title = "群发消息",
    Value = false,
    Callback = function(isEnabled)
        if isEnabled then
            startSpamAll()
            WindUI:Notify({
                Title = "开始群发", 
                Content = "开始向所有玩家发送消息",
                Duration = 3, 
                Icon = "send"
            })
        else
            stopSpamAll()
            WindUI:Notify({
                Title = "停止群发", 
                Content = "已停止群发消息",
                Duration = 2, 
                Icon = "square"
            })
        end
    end
})

Main:Toggle({
    Title = "屏蔽所有人消息和电话",
    Value = false,
    Callback = function(isEnabled)
        harassSettings.blockAllEnabled = isEnabled
        if isEnabled then
            blockAllMessages()
            WindUI:Notify({
                Title = "开启屏蔽", 
                Content = "已屏蔽所有玩家消息和电话",
                Duration = 3, 
                Icon = "shield"
            })
            
            task.spawn(function()
                while harassSettings.blockAllEnabled do
                    blockAllMessages()
                    task.wait(5)
                end
            end)
        else
            WindUI:Notify({
                Title = "关闭屏蔽", 
                Content = "已取消屏蔽所有玩家",
                Duration = 2, 
                Icon = "shield-off"
            })
        end
    end
})

local CasePurchase = Window:Tab({Title = "皮肤箱子", Icon = "shopping-bag"})

local casesList = {}
local skins = require(game:GetService("ReplicatedStorage").devv).load("skins")

for caseName, caseData in pairs(skins.cases) do
    if caseData.cashPrice or caseData.candyPrice or caseData.gingerbreadPrice then
        table.insert(casesList, caseName)
    end
end

local selectedCase = casesList[1]
local selectedOpenCase = casesList[1]
local autoOpenSelected = false
local autoBuySelected = false
local autoOpenAll = false

CasePurchase:Dropdown({
    Title = "选择要购买的箱子",
    Values = casesList,
    Callback = function(Value)
        selectedCase = Value
    end
})

CasePurchase:Button({
    Title = "购买一次选中箱子",
    Callback = function()
        local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
        Signal.InvokeServer("buyCases", selectedCase, 1)
    end
})

CasePurchase:Toggle({
    Title = "自动购买选中箱子",
    Value = false,
    Callback = function(state)
        autoBuySelected = state
        if state then
            task.spawn(function()
                local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
                
                while autoBuySelected do
                    Signal.InvokeServer("buyCases", selectedCase, 1)
                    task.wait(0.5)
                end
            end)
        end
    end
})

CasePurchase:Dropdown({
    Title = "选择要开启的箱子",
    Values = casesList,
    Callback = function(Value)
        selectedOpenCase = Value
    end
})

CasePurchase:Toggle({
    Title = "自动开启选中箱子",
    Value = false,
    Callback = function(state)
        autoOpenSelected = state
        if state then
            task.spawn(function()
                local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
                local state = require(game:GetService("ReplicatedStorage").devv).load("state")
                
                while autoOpenSelected do
                    local ownedCount = state.data.ownedCases[selectedOpenCase] or 0
                    if ownedCount > 0 then
                        Signal.InvokeServer("openCase", selectedOpenCase)
                        task.wait(0.5)
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

CasePurchase:Toggle({
    Title = "自动开全部箱子",
    Value = false,
    Callback = function(state)
        autoOpenAll = state
        if state then
            task.spawn(function()
                local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
                local state = require(game:GetService("ReplicatedStorage").devv).load("state")
                
                while autoOpenAll do
                    for caseName, ownedCount in pairs(state.data.ownedCases or {}) do
                        if ownedCount > 0 and not autoOpenSelected then
                            Signal.InvokeServer("openCase", caseName)
                            task.wait(0.3)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local Main = Window:Tab({Title = "人物", Icon = "settings"})

Main:Toggle({
    Title = "速度",
    Default = false,
    Callback = function(v)
        if v == true then
            sudu = game:GetService("RunService").Heartbeat:Connect(function()
                if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Humanoid and game:GetService("Players").LocalPlayer.Character.Humanoid.Parent then
                    if game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        game:GetService("Players").LocalPlayer.Character:TranslateBy(game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * Speed / 10)
                    end
                end
            end)
        elseif not v and sudu then
            sudu:Disconnect()
            sudu = nil
        end
    end
})

Main:Slider({
    Title = "速度",
    Value = {
        Min = 1,
        Max = 100,
        Default = 1,
    },
    Callback = function(Value)
        Speed = Value
    end
})

Main:Toggle({
    Title = "扩大视野",
    Default = false,
    Callback = function(v)
        if v == true then
            fovConnection = game:GetService("RunService").Heartbeat:Connect(function()
                workspace.CurrentCamera.FieldOfView = 130
            end)
        elseif not v and fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
    end
})

Main:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})

local Settings = Window:Tab({Title = "ui设置", Icon = "palette"})
Settings:Paragraph({
    Title = "ui设置",
    Desc = "二改wind原版ui",
    Image = "settings",
    ImageSize = 20,
    Color = "White"
})

Settings:Toggle({
    Title = "启用边框",
    Value = borderEnabled,
    Callback = function(value)
        borderEnabled = value
        local mainFrame = Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
            if rainbowStroke then
                rainbowStroke.Enabled = value
                if value and windowOpen and not rainbowBorderAnimation then
                    startBorderAnimation(Window, animationSpeed)
                elseif not value and rainbowBorderAnimation then
                    rainbowBorderAnimation:Disconnect()
                    rainbowBorderAnimation = nil
                end
                
                WindUI:Notify({
                    Title = "边框",
                    Content = value and "已启用" or "已禁用",
                    Duration = 2,
                    Icon = value and "eye" or "eye-off"
                })
            end
        end
    end
})

Settings:Toggle({
    Title = "启用字体颜色",
    Value = fontColorEnabled,
    Callback = function(value)
        fontColorEnabled = value
        applyFontColorsToWindow(currentFontColorScheme)
        
        WindUI:Notify({
            Title = "字体颜色",
            Content = value and "已启用" or "已禁用",
            Duration = 2,
            Icon = value and "type" or "type"
        })
    end
})

Settings:Toggle({
    Title = "启用音效",
    Value = soundEnabled,
    Callback = function(value)
        soundEnabled = value
        WindUI:Notify({
            Title = "音效",
            Content = value and "已启用" or "已禁用",
            Duration = 2,
            Icon = value and "volume-2" or "volume-x"
        })
    end
})

Settings:Toggle({
    Title = "启用背景模糊",
    Value = blurEnabled,
    Callback = function(value)
        blurEnabled = value
        applyBlurEffect(value)
        WindUI:Notify({
            Title = "背景模糊",
            Content = value and "已启用" or "已禁用",
            Duration = 2,
            Icon = value and "cloud-rain" or "cloud"
        })
    end
})

local colorSchemeNames = {}
for name, _ in pairs(COLOR_SCHEMES) do
    table.insert(colorSchemeNames, name)
end
table.sort(colorSchemeNames)

Settings:Dropdown({
    Title = "边框颜色方案",
    Desc = "选择喜欢的颜色组合",
    Values = colorSchemeNames,
    Value = "糖果颜色",
    Callback = function(value)
        currentBorderColorScheme = value
        local success = initializeRainbowBorder(value, animationSpeed)
        playSound()
    end
})

Settings:Dropdown({
    Title = "字体颜色方案",
    Desc = "选择文字颜色组合",
    Values = colorSchemeNames,
    Value = "彩虹颜色",
    Callback = function(value)
        currentFontColorScheme = value
        applyFontColorsToWindow(value)
        playSound()
    end
})

local fontOptions = {}
for _, fontName in ipairs(FONT_STYLES) do
    local description = FONT_DESCRIPTIONS[fontName] or fontName
    table.insert(fontOptions, {text = description, value = fontName})
end

table.sort(fontOptions, function(a, b)
    return a.text < b.text
end)

local fontValues = {}
local fontValueToName = {}
for _, option in ipairs(fontOptions) do
    table.insert(fontValues, option.text)
    fontValueToName[option.text] = option.value
end

Settings:Dropdown({
    Title = "字体样式",
    Desc = "选择文字字体样式 (" .. #FONT_STYLES .. " 种可用)",
    Values = fontValues,
    Value = "标准粗体",
    Callback = function(value)
        local fontName = fontValueToName[value]
        if fontName then
            currentFontStyle = fontName
            local successCount, totalCount = applyFontStyleToWindow(fontName)
            playSound()
        end
    end
})

Settings:Slider({
    Title = "边框转动速度",
    Desc = "调整边框旋转的快慢",
    Value = { 
        Min = 1,
        Max = 10,
        Default = 5,
    },
    Callback = function(value)
        animationSpeed = value
        if rainbowBorderAnimation then
            rainbowBorderAnimation:Disconnect()
            rainbowBorderAnimation = nil
        end
        if borderEnabled then
            startBorderAnimation(Window, animationSpeed)
        end
        
        applyFontColorsToWindow(currentFontColorScheme)
        playSound()
    end
})

Settings:Slider({
    Title = "UI整体缩放",
    Desc = "调整UI大小比例",
    Value = { 
        Min = 0.5,
        Max = 1.5,
        Default = 1,
    },
    Step = 0.1,
    Callback = function(value)
        uiScale = value
        applyUIScale(value)
        playSound()
    end
})

Settings:Divider()

Settings:Slider({
    Title = "UI透明度",
    Desc = "调整整个UI的透明度",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0.2,
    },
    Step = 0.1,
    Callback = function(value)
        Window:ToggleTransparency(tonumber(value) > 0)
        WindUI.TransparencyValue = tonumber(value)
        playSound()
    end
})

Settings:Slider({
    Title = "调整UI宽度",
    Desc = "调整窗口的宽度",
    Value = { 
        Min = 500,
        Max = 800,
        Default = 600,
    },
    Callback = function(value)
        if Window.UIElements and Window.UIElements.Main then
            Window.UIElements.Main.Size = UDim2.fromOffset(value, 400)
        end
        playSound()
    end
})

Settings:Slider({
    Title = "调整UI高度",
    Desc = "调整窗口的高度",
    Value = { 
        Min = 300,
        Max = 600,
        Default = 400,
    },
    Callback = function(value)
        if Window.UIElements and Window.UIElements.Main then
            local currentWidth = Window.UIElements.Main.Size.X.Offset
            Window.UIElements.Main.Size = UDim2.fromOffset(currentWidth, value)
        end
        playSound()
    end
})

Settings:Slider({
    Title = "边框粗细",
    Desc = "调整边框的粗细",
    Value = { 
        Min = 1,
        Max = 5,
        Default = 1.5,
    },
    Step = 0.5,
    Callback = function(value)
        local mainFrame = Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
            if rainbowStroke then
                rainbowStroke.Thickness = value
            end
        end
        playSound()
    end
})

Settings:Slider({
    Title = "圆角大小",
    Desc = "调整UI圆角的大小",
    Value = { 
        Min = 0,
        Max = 20,
        Default = 16,
    },
    Callback = function(value)
        local mainFrame = Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local corner = mainFrame:FindFirstChildOfClass("UICorner")
            if not corner then
                corner = Instance.new("UICorner")
                corner.Parent = mainFrame
            end
            corner.CornerRadius = UDim.new(0, value)
        end
        playSound()
    end
})

Settings:Button({
    Title = "恢复UI到原位",
    Icon = "rotate-ccw",
    Callback = function()
        if Window.UIElements and Window.UIElements.Main then
            Window.UIElements.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
            playSound()
        end
    end
})

Settings:Button({
    Title = "重置UI大小",
    Icon = "maximize-2",
    Callback = function()
        if Window.UIElements and Window.UIElements.Main then
            Window.UIElements.Main.Size = UDim2.fromOffset(600, 400)
            playSound()
        end
    end
})

Settings:Button({
    Title = "随机字体",
    Icon = "shuffle",
    Callback = function()
        local randomFont = FONT_STYLES[math.random(1, #FONT_STYLES)]
        currentFontStyle = randomFont
        applyFontStyleToWindow(randomFont)
        playSound()
    end
})

Settings:Button({
    Title = "随机颜色",
    Icon = "palette",
    Callback = function()
        local randomColor = colorSchemeNames[math.random(1, #colorSchemeNames)]
        currentBorderColorScheme = randomColor
        initializeRainbowBorder(randomColor, animationSpeed)
        playSound()
    end
})

Settings:Divider()

Settings:Button({
    Title = "刷新字体颜色",
    Icon = "refresh-cw",
    Callback = function()
        applyFontColorsToWindow(currentFontColorScheme)
        playSound()
    end
})

Settings:Button({
    Title = "刷新字体样式",
    Icon = "refresh-cw",
    Callback = function()
        local successCount, totalCount = applyFontStyleToWindow(currentFontStyle)
        playSound()
    end
})

Settings:Button({
    Title = "测试所有字体",
    Icon = "check-circle",
    Callback = function()
        local workingFonts = {}
        local totalFonts = #FONT_STYLES
        
        for i, fontName in ipairs(FONT_STYLES) do
            local success = pcall(function()
                local test = Enum.Font[fontName]
            end)
            
            if success then
                table.insert(workingFonts, fontName)
            end
        end
        playSound()
    end
})

Settings:Button({
    Title = "导出设置",
    Icon = "download",
    Callback = function()
        local settings = {
            font = currentFontStyle,
            borderColor = currentBorderColorScheme,
            fontSize = currentFontColorScheme,
            speed = animationSpeed,
            scale = uiScale
        }
        setclipboard("YG SCRIPT设置: " .. game:GetService("HttpService"):JSONEncode(settings))
        playSound()
    end
})

Window:OnClose(function()
    windowOpen = false
    if rainbowBorderAnimation then
        rainbowBorderAnimation:Disconnect()
        rainbowBorderAnimation = nil
    end
    applyBlurEffect(false)
end)

Window:OnDestroy(function()
    windowOpen = false
    if rainbowBorderAnimation then
        rainbowBorderAnimation:Disconnect()
        rainbowBorderAnimation = nil
    end
    for _, animation in pairs(fontColorAnimations) do
        animation:Disconnect()
    end
    fontColorAnimations = {}
    applyBlurEffect(false)
end)

end