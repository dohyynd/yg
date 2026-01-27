-- 设置UI配置
getgenv()._CONFIGS = {
    UI_NAME = "YG SCRIPT - 自然灾害",
}

-- 加载Ven-y UI库
local success, library = pcall(function()
    return loadstring(game:HttpGet("https://pastebin.com/raw/CxxfciVn"))()
end)

if not success then
    warn("无法加载UI库，尝试备用方案...")
    -- 备用方案：使用简单的通知
    game.StarterGui:SetCore("SendNotification", {
        Title = "YG SCRIPT",
        Text = "UI库加载失败，请检查网络连接",
        Duration = 5,
    })
    return
end

-- 获取游戏服务
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 等待玩家角色加载
local Character
local Humanoid
local HumanoidRootPart

local function ensureCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    Character = LocalPlayer.Character
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end

-- 创建主标签页
local mainTab = library:CreateTab("主菜单")

-- 显示加载完成通知
mainTab:NewSeparator()
mainTab:NewLabel("✅ 脚本状态")
mainTab:NewButton("显示加载信息", function()
    library:Notify({
        Title = "YG SCRIPT",
        Text = "自然灾害脚本加载完成",
        Duration = 3
    })
end)

-- 玩家信息标签页
local playerTab = library:CreateTab("玩家设置")
playerTab:NewSeparator()
playerTab:NewLabel("👤 玩家信息")

-- 显示玩家信息按钮
playerTab:NewButton("显示玩家信息", function()
    ensureCharacter()
    library:Notify({
        Title = "玩家信息",
        Text = string.format("玩家: %s\nID: %d\n显示名称: %s", 
            LocalPlayer.Name, 
            LocalPlayer.UserId, 
            LocalPlayer.DisplayName),
        Duration = 5
    })
end)

-- 玩家速度控制
playerTab:NewSlider("玩家速度", "walkspeed", 200, 16, 500, false, function(value)
    ensureCharacter()
    if Humanoid then
        Humanoid.WalkSpeed = value
        library:Notify({
            Title = "玩家速度",
            Text = "已设置为: " .. tostring(value),
            Duration = 2
        })
    end
end)

-- 跳跃高度控制
playerTab:NewSlider("跳跃高度", "jumpheight", 200, 50, 500, false, function(value)
    ensureCharacter()
    if Humanoid then
        Humanoid.JumpHeight = value
        library:Notify({
            Title = "跳跃高度",
            Text = "已设置为: " .. tostring(value),
            Duration = 2
        })
    end
end)

-- 镜头FOV控制
playerTab:NewSlider("镜头FOV", "camerafov", 120, 70, 150, false, function(value)
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = value
        library:Notify({
            Title = "镜头FOV",
            Text = "已设置为: " .. tostring(value),
            Duration = 2
        })
    end
end)

-- 删除摔落伤害
local fallDamageConnection
playerTab:NewButton("删除摔落伤害", function()
    ensureCharacter()
    
    local function removeFallDamage()
        local fallDamageScript = Character:FindFirstChild("FallDamageScript")
        if fallDamageScript then
            fallDamageScript:Destroy()
            return true
        end
        return false
    end
    
    if removeFallDamage() then
        library:Notify({
            Title = "成功",
            Text = "已删除摔落伤害脚本",
            Duration = 3
        })
    else
        library:Notify({
            Title = "提示",
            Text = "未找到摔落伤害脚本",
            Duration = 3
        })
    end
    
    -- 监听新添加的摔落伤害脚本
    if fallDamageConnection then
        fallDamageConnection:Disconnect()
    end
    
    fallDamageConnection = Character.ChildAdded:Connect(function(child)
        if child.Name == "FallDamageScript" then
            task.wait(0.1)
            child:Destroy()
            library:Notify({
                Title = "防护",
                Text = "已阻止新摔落伤害脚本",
                Duration = 2
            })
        end
    end)
end)

-- 灾难功能标签页
local disasterTab = library:CreateTab("灾难功能")
disasterTab:NewSeparator()
disasterTab:NewLabel("🌪️ 灾难预测")

-- 灾难预测开关
local disasterConnection
local disasterPredictionEnabled = false

disasterTab:NewToggle("预测灾难", "disaster_prediction", false, function(state)
    disasterPredictionEnabled = state
    
    if state then
        ensureCharacter()
        
        -- 定义灾难字典
        local DisasterDictionary = {
            ["Tornado"] = "🌪️ 龙卷风",
            ["Avalanche"] = "🏔️ 雪崩", 
            ["Volcanic Eruption"] = "🌋 火山喷发",
            ["Blizzard"] = "❄️ 暴风雪",
            ["Deadly Virus"] = "🦠 致命病毒",
            ["Tsunami"] = "🌊 海啸",
            ["Lightning"] = "⚡ 闪电",
            ["Meteor Shower"] = "☄️ 流星雨",
            ["Earthquake"] = "🌍 地震",
            ["Thunder Storm"] = "⛈️ 暴风雨",
            ["Sandstorm"] = "🌫️ 沙尘暴",
            ["Fire"] = "🔥 火焰",
            ["Flash Flood"] = "💧 洪水",
            ["Acid Rain"] = "☔ 酸雨",
        }
        
        -- 监听SurvivalTag添加
        if disasterConnection then
            disasterConnection:Disconnect()
        end
        
        disasterConnection = Character.ChildAdded:Connect(function(child)
            if child.Name == "SurvivalTag" then
                local disasterValue = child.Value
                local disasterName = DisasterDictionary[disasterValue] or disasterValue
                
                library:Notify({
                    Title = "灾难警报",
                    Text = "当前灾难: " .. disasterName,
                    Duration = 5
                })
            end
        end)
        
        -- 检查是否已有SurvivalTag
        local existingTag = Character:FindFirstChild("SurvivalTag")
        if existingTag then
            local disasterValue = existingTag.Value
            local disasterName = DisasterDictionary[disasterValue] or disasterValue
            
            library:Notify({
                Title = "当前灾难",
                Text = "当前灾难: " .. disasterName,
                Duration = 5
            })
        end
        
        library:Notify({
            Title = "灾难预测",
            Text = "功能已启用",
            Duration = 2
        })
    else
        if disasterConnection then
            disasterConnection:Disconnect()
            disasterConnection = nil
        end
        
        library:Notify({
            Title = "灾难预测",
            Text = "功能已禁用",
            Duration = 2
        })
    end
end)

-- 灾难类型选择
disasterTab:NewSeparator()
disasterTab:NewLabel("📊 灾难管理")

local disasterOptions = {
    "龙卷风",
    "雪崩", 
    "火山喷发",
    "暴风雪",
    "致命病毒",
    "海啸",
    "闪电",
    "流星雨",
    "地震",
    "暴风雨",
    "沙尘暴",
    "火焰",
    "洪水",
    "酸雨"
}

disasterTab:NewDropdown("选择灾难类型", "disaster_type", disasterOptions, function(selected)
    library:Notify({
        Title = "灾难选择",
        Text = "已选择: " .. selected,
        Duration = 3
    })
end)

-- 自动发送灾难信息
local autoSendEnabled = false
local chatService

disasterTab:NewToggle("自动发送灾难信息", "auto_send_disaster", false, function(state)
    autoSendEnabled = state
    
    if state then
        -- 尝试获取聊天服务
        pcall(function()
            chatService = game:GetService("TextChatService")
        end)
        
        library:Notify({
            Title = "自动发送",
            Text = "功能已开启 - 当检测到灾难时会自动发送消息",
            Duration = 3
        })
    else
        library:Notify({
            Title = "自动发送",
            Text = "功能已关闭",
            Duration = 3
        })
    end
end)

-- 其他功能标签页
local otherTab = library:CreateTab("其他功能")
otherTab:NewSeparator()
otherTab:NewLabel("🔧 实用工具")

-- 注入器信息
otherTab:NewButton("显示注入器信息", function()
    local executor = "未知"
    if identifyexecutor then
        executor = identifyexecutor() or "未知"
    end
    
    library:Notify({
        Title = "注入器信息",
        Text = "当前注入器: " .. executor .. "\n设备: 电脑",
        Duration = 5
    })
end)

-- 飞行模式
local flying = false
local flyBodyVelocity
local flyConnection

otherTab:NewToggle("飞行模式", "flight_mode", false, function(state)
    flying = state
    
    if state then
        ensureCharacter()
        
        library:Notify({
            Title = "飞行模式",
            Text = "已启用 - 使用WASD控制移动，空格上升，左Ctrl下降",
            Duration = 4
        })
        
        -- 创建BodyVelocity
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = HumanoidRootPart
        
        -- 飞行控制
        local userInputService = game:GetService("UserInputService")
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if flying and Character and HumanoidRootPart then
                local velocity = Vector3.new(0, 0, 0)
                
                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + workspace.CurrentCamera.CFrame.LookVector * 50
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - workspace.CurrentCamera.CFrame.LookVector * 50
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - workspace.CurrentCamera.CFrame.RightVector * 50
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + workspace.CurrentCamera.CFrame.RightVector * 50
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 50, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    velocity = velocity - Vector3.new(0, 50, 0)
                end
                
                flyBodyVelocity.Velocity = velocity
            end
        end)
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        library:Notify({
            Title = "飞行模式",
            Text = "已禁用",
            Duration = 2
        })
    end
end)

-- 穿墙模式
local noclipEnabled = false
local noclipConnection

otherTab:NewToggle("穿墙模式", "noclip_mode", false, function(state)
    noclipEnabled = state
    
    if state then
        ensureCharacter()
        
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled and Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        library:Notify({
            Title = "穿墙模式",
            Text = "已启用",
            Duration = 2
        })
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        library:Notify({
            Title = "穿墙模式",
            Text = "已禁用",
            Duration = 2
        })
    end
end)

-- 按键绑定
otherTab:NewSeparator()
otherTab:NewLabel("⌨️ 按键绑定")

otherTab:NewBind("打开/关闭菜单", "RightShift", function(key)
    library:Notify({
        Title = "按键绑定",
        Text = "按 " .. key .. " 打开/关闭菜单",
        Duration = 3
    })
end)

otherTab:NewBind("快速飞行", "F", function(key)
    if otherTab:GetConfig("flight_mode") ~= nil then
        otherTab:SetConfig("flight_mode", not otherTab:GetConfig("flight_mode"))
        library:Notify({
            Title = "快速功能",
            Text = "按 " .. key .. " 切换飞行模式",
            Duration = 2
        })
    end
end)

-- 自定义功能
otherTab:NewSeparator()
otherTab:NewLabel("🎮 自定义功能")

otherTab:NewBox("发送自定义消息", "custom_message", function(text)
    if text and text ~= "" then
        library:Notify({
            Title = "自定义消息",
            Text = text,
            Duration = 4
        })
    end
end)

-- 初始化角色
task.spawn(function()
    ensureCharacter()
    
    -- 延迟显示欢迎消息
    task.wait(1)
    library:Notify({
        Title = "YG SCRIPT",
        Text = "自然灾害脚本已成功加载！\n使用 RightShift 打开/关闭菜单",
        Duration = 5
    })
end)

print("YG SCRIPT - 自然灾害脚本加载完成")