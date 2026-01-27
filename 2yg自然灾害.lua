-- 设置UI配置
getgenv()._CONFIGS = {
    UI_NAME = "YG SCRIPT - 自然灾害",
}

-- 加载UI库
local success, library = pcall(function()
    return loadstring(game:HttpGet("https://pastebin.com/raw/CxxfciVn"))()
end)

if not success then
    warn("无法加载UI库，尝试备用方案...")
    -- 备用方案代码
    return
end

-- 等待UI库加载完成
repeat wait() until library

-- 创建主窗口
local mainTab = library:CreateTab("主菜单")

-- 添加分隔符
mainTab:NewSeparator()

-- 通知功能已加载
mainTab:NewButton("📢 通知", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "YG SCRIPT",
        Text = "自然灾害脚本已加载完成",
        Duration = 5,
        Icon = "rbxassetid://4483345998"
    })
    print("通知已发送")
end)

-- 获取本地玩家信息
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- 玩家速度控制
mainTab:NewSeparator()
mainTab:NewLabel("⚡ 玩家设置")

mainTab:NewSlider("移动速度", "w_g", 200, 16, 500, false, function(value)
    if Character and Character:FindFirstChildOfClass("Humanoid") then
        Character.Humanoid.WalkSpeed = value
        library:Notify({
            Title = "设置成功",
            Text = "移动速度已设置为: " .. value,
            Duration = 2
        })
    end
end)

-- 跳跃高度控制
mainTab:NewSlider("跳跃高度", "j_g", 200, 50, 500, false, function(value)
    if Character and Character:FindFirstChildOfClass("Humanoid") then
        Character.Humanoid.JumpHeight = value
        library:Notify({
            Title = "设置成功",
            Text = "跳跃高度已设置为: " .. value,
            Duration = 2
        })
    end
end)

-- 镜头FOV控制
mainTab:NewSlider("镜头FOV", "f_g", 120, 70, 150, false, function(value)
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = value
        library:Notify({
            Title = "设置成功",
            Text = "镜头FOV已设置为: " .. value,
            Duration = 2
        })
    end
end)

-- 删除摔落伤害
mainTab:NewButton("🛡️ 删除摔落伤害", function()
    if Character then
        local fallDamageScript = Character:FindFirstChild("FallDamageScript")
        if fallDamageScript then
            fallDamageScript:Destroy()
            library:Notify({
                Title = "成功",
                Text = "已删除摔落伤害脚本",
                Duration = 3
            })
            
            -- 防止脚本重新添加
            Character.ChildAdded:Connect(function(child)
                if child.Name == "FallDamageScript" then
                    task.wait(0.1)
                    child:Destroy()
                end
            end)
        else
            library:Notify({
                Title = "提示",
                Text = "未找到摔落伤害脚本",
                Duration = 3
            })
        end
    end
end)

-- 灾难功能标签页
local disasterTab = library:CreateTab("灾难设置")

disasterTab:NewSeparator()
disasterTab:NewLabel("🌪️ 灾难功能")

-- 灾难预测开关
local disasterConnection
disasterTab:NewToggle("灾难预测", "dp_g", false, function(state)
    if state then
        -- 启用灾难预测
        library:Notify({
            Title = "灾难预测",
            Text = "功能已启用",
            Duration = 2
        })
        
        -- 监听SurvivalTag
        disasterConnection = Character.ChildAdded:Connect(function(child)
            if child.Name == "SurvivalTag" then
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
                
                local disasterValue = child.Value
                local disasterName = DisasterDictionary[disasterValue] or disasterValue
                
                library:Notify({
                    Title = "灾难警报",
                    Text = "当前灾难: " .. disasterName,
                    Duration = 5
                })
            end
        end)
    else
        -- 禁用灾难预测
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

-- 自动发送灾难信息
local autoSendEnabled = false
disasterTab:NewToggle("自动发送灾难信息", "as_g", false, function(state)
    autoSendEnabled = state
    if state then
        library:Notify({
            Title = "自动发送",
            Text = "功能已开启",
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

-- 灾难类型选择
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

disasterTab:NewDropdown("选择灾难类型", "dt_g", disasterOptions, function(selected)
    library:Notify({
        Title = "灾难选择",
        Text = "已选择: " .. selected,
        Duration = 3
    })
    print("选择灾难: " .. selected)
end)

-- 其他功能标签页
local otherTab = library:CreateTab("其他功能")

otherTab:NewSeparator()
otherTab:NewLabel("🔧 工具功能")

-- 一键飞行
local flying = false
local flySpeed = 50
otherTab:NewToggle("飞行模式", "fly_g", false, function(state)
    flying = state
    if state then
        library:Notify({
            Title = "飞行模式",
            Text = "飞行已启用 (按WASD移动)",
            Duration = 3
        })
        
        -- 简单的飞行脚本
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = Character:WaitForChild("HumanoidRootPart")
        
        local userInputService = game:GetService("UserInputService")
        local runService = game:GetService("RunService")
        
        local connection = runService.Heartbeat:Connect(function()
            if flying and Character and Character:FindFirstChild("HumanoidRootPart") then
                local velocity = Vector3.new(0, 0, 0)
                
                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + Character.HumanoidRootPart.CFrame.LookVector * flySpeed
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - Character.HumanoidRootPart.CFrame.LookVector * flySpeed
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - Character.HumanoidRootPart.CFrame.RightVector * flySpeed
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + Character.HumanoidRootPart.CFrame.RightVector * flySpeed
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, flySpeed, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    velocity = velocity - Vector3.new(0, flySpeed, 0)
                end
                
                bodyVelocity.Velocity = velocity
            end
        end)
        
        -- 当关闭飞行时断开连接
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            connection:Disconnect()
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end)
    else
        library:Notify({
            Title = "飞行模式", 
            Text = "飞行已禁用",
            Duration = 3
        })
    end
end)

-- 飞行速度设置
otherTab:NewSlider("飞行速度", "fs_g", 100, 10, 200, false, function(value)
    flySpeed = value
    library:Notify({
        Title = "飞行设置",
        Text = "飞行速度已设置为: " .. value,
        Duration = 2
    })
end)

-- 无敌模式
otherTab:NewToggle("无敌模式", "god_g", false, function(state)
    if state then
        if Character then
            local humanoid = Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                library:Notify({
                    Title = "无敌模式",
                    Text = "无敌模式已启用",
                    Duration = 3
                })
            end
        end
    else
        library:Notify({
            Title = "无敌模式",
            Text = "无敌模式已禁用",
            Duration = 3
        })
    end
end)

-- 穿墙模式
local noclipEnabled = false
otherTab:NewToggle("穿墙模式", "nc_g", false, function(state)
    noclipEnabled = state
    if state then
        library:Notify({
            Title = "穿墙模式",
            Text = "穿墙模式已启用",
            Duration = 3
        })
        
        -- Noclip脚本
        local noclipConnection
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if noclipEnabled and Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        -- 当角色变化时重置
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            noclipEnabled = false
            if noclipConnection then
                noclipConnection:Disconnect()
            end
        end)
    else
        library:Notify({
            Title = "穿墙模式",
            Text = "穿墙模式已禁用",
            Duration = 3
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
    -- 这里可以添加打开/关闭菜单的逻辑
end)

otherTab:NewBind("快速飞行", "F", function(key)
    library:Notify({
        Title = "快速功能",
        Text = "按 " .. key .. " 切换飞行",
        Duration = 3
    })
    -- 切换飞行状态
    flying = not flying
end)

-- 信息输入框
otherTab:NewSeparator()
otherTab:NewLabel("💬 自定义")

otherTab:NewBox("自定义消息", "msg_g", function(text)
    if text and text ~= "" then
        library:Notify({
            Title = "自定义消息",
            Text = "你输入了: " .. text,
            Duration = 5
        })
        print("自定义消息: " .. text)
    end
end)

-- 脚本信息标签页
local infoTab = library:CreateTab("脚本信息")

infoTab:NewSeparator()
infoTab:NewLabel("📋 脚本信息")

-- 显示玩家信息
infoTab:NewButton("显示玩家信息", function()
    local playerName = LocalPlayer.Name
    local userId = LocalPlayer.UserId
    local accountAge = LocalPlayer.AccountAge
    
    library:Notify({
        Title = "玩家信息",
        Text = string.format("名称: %s\nID: %d\n账号天数: %d天", playerName, userId, accountAge),
        Duration = 5
    })
end)

-- 显示游戏信息
infoTab:NewButton("显示游戏信息", function()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    library:Notify({
        Title = "游戏信息",
        Text = string.format("游戏: %s\nID: %d", gameName, placeId),
        Duration = 5
    })
end)

-- 脚本状态
infoTab:NewButton("检查脚本状态", function()
    library:Notify({
        Title = "脚本状态",
        Text = "YG SCRIPT - 自然灾害\n状态: 正常运行\n版本: 1.0.0",
        Duration = 5
    })
end)

-- 添加最后的通知
wait(1)
library:Notify({
    Title = "YG SCRIPT",
    Text = "自然灾害脚本已成功加载！\n使用 RightShift 打开/关闭菜单",
    Duration = 5
})

print("YG SCRIPT - 自然灾害脚本已加载完成")