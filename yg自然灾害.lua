-- 添加安全检查和错误处理
local success, Loaded_Var192 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SUNXIAOCHUAN-DEV/-/refs/heads/main/乱码牛逼"))()
end)

if not success or not Loaded_Var192 then
    warn("Failed to load library")
    return
end

-- 添加安全检查函数
local function SafeGetService(serviceName)
    return game:GetService(serviceName)
end

local Players = SafeGetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 等待玩家角色加载
local Character
repeat
    Character = LocalPlayer.Character
    if Character then
        Character:WaitForChild("HumanoidRootPart")
    else
        wait(1)
    end
until Character

-- 初始化UI库配置
Loaded_Var192.TransparencyValue = 0.2
Loaded_Var192:SetTheme("Dark")
Loaded_Var192:Notify({
    Transparency = 0.7,
    Duration = 2,
    Title = "YG SCRIPT",
    Content = "YG SCRIPT--自然灾害加载完成",
})

-- 创建主窗口（修复语法错误）
local Window = Loaded_Var192:CreateWindow({
    User = {
        Enabled = true,
        Callback = function()
            Loaded_Var192:Notify({
                Duration = 3,
                Title = "用户信息",
                Content = "玩家:" .. LocalPlayer.Name,
            })
        end,
        ThumbnailType = "AvatarBust",
        Anonymous = false,
        Username = LocalPlayer.Name,
        UserId = LocalPlayer.UserId,
        DisplayName = LocalPlayer.DisplayName,
    },
    Author = "作者：无",
    ScrollBarEnabled = true,
    Folder = "OrangeCHub",
    SideBarWidth = 180,
    Title = "YG SCRIPT--自然灾害",  -- 修复：移除方括号
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Transparent = true,
    Theme = "Dark",  -- 修复：添加引号
    Icon = "crown",
    Size = UDim2.fromOffset(600, 500),
})

-- 创建主题切换按钮（简化）
Window:CreateTopbarButton("theme-switcher", "moon", function()
    local CurrentTheme = Loaded_Var192:GetCurrentTheme()
    if CurrentTheme == "Dark" then
        Loaded_Var192:SetTheme("Light")
    else
        Loaded_Var192:SetTheme("Dark")
    end
    Loaded_Var192:Notify({
        Duration = 2,
        Title = "提示",
        Content = "当前主题: " .. Loaded_Var192:GetCurrentTheme(),
    })
end, 990)

-- 编辑打开按钮
Window:EditOpenButton({
    Title = "YG SCRIPT-自然灾害",
    Icon = "crown",
})

-- 创建章节（修复语法）
local Section_3 = Window:Section({
    Icon = "user",
    Title = "玩家",
    Opened = false,
})

local Section_5 = Window:Section({
    Icon = "package-open",
    Title = "灾难",
    Opened = false,
})

Window:Section({
    Icon = "pocket-knife",
    Title = "自动",
    Opened = false,
})

-- 创建标签页
local Tab_3 = Section_3:Tab({
    Title = "公告",
    Icon = "folder",
})

local Tab_5 = Section_3:Tab({
    Title = "玩家",
    Icon = "folder",
})

local Tab_7 = Section_5:Tab({
    Title = "预测灾难",
    Icon = "folder",
})

-- 添加段落（修复语法）
Tab_3:Paragraph({
    ImageSize = 15,
    Image = "info",
    Title = "欢迎尊贵的用户",
    Desc = "此脚本会一直更新 感谢白名单使用者",
})

Tab_3:Paragraph({
    ImageSize = 12,
    Image = "user",
    Title = "玩家",
    Desc = "尊敬的用户: " .. LocalPlayer.Name .. " 欢迎使用",
})

Tab_3:Paragraph({
    ImageSize = 12,
    Image = "gamepad",
    Title = "设备",
    Desc = "你的使用设备: 电脑",
})

Tab_3:Paragraph({
    ImageSize = 12,
    Image = "syringe",
    Title = "注入器",
    Desc = "你的注入器: " .. tostring(identifyexecutor and identifyexecutor() or "未知"),
})

local CurrentCamera = workspace.CurrentCamera

-- 玩家速度滑块（修复回调函数）
Tab_5:Slider({
    Title = "玩家速度",
    Value = {
        Min = 16,
        Default = 16,
        Max = 200,
    },
    Callback = function(value)
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = value
        end
    end,
    Step = 1,
    Desc = "玩家的速度",
})

-- 玩家跳跃高度滑块
Tab_5:Slider({
    Title = "玩家跳跃高度",
    Value = {
        Min = 50,
        Default = 50,
        Max = 200,
    },
    Callback = function(value)
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpHeight = value
        end
    end,
    Step = 1,
    Desc = "玩家的跳跃高度",
})

-- 玩家镜头FOV滑块
Tab_5:Slider({
    Title = "玩家镜头FOV",
    Value = {
        Min = 70,
        Default = 70,
        Max = 120,
    },
    Callback = function(value)
        if CurrentCamera then
            CurrentCamera.FieldOfView = value
        end
    end,
    Step = 1,
    Desc = "玩家的镜头",
})

-- 删除摔落伤害按钮
Tab_5:Button({
    Callback = function()
        if Character then
            local FallDamageScript = Character:FindFirstChild("FallDamageScript")
            if FallDamageScript then
                FallDamageScript:Destroy()
            end
            
            -- 防止重新添加
            local connection
            connection = Character.ChildAdded:Connect(function(child)
                if child.Name == "FallDamageScript" then
                    child:Destroy()
                end
            end)
            
            -- 保存连接以便稍后断开（如果需要）
            game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
                if connection then
                    connection:Disconnect()
                end
            end)
        end
    end,
    Title = "删除摔落伤害",
    Desc = "删除",
})

-- 预测灾难开关
local predictionConnection
Tab_7:Toggle({
    Value = false,
    Callback = function(value)
        if predictionConnection then
            predictionConnection:Disconnect()
            predictionConnection = nil
        end
        
        if value then
            -- 灾难名称映射
            local disasterNames = {
                ["Tornado"] = "龙卷风",
                ["Avalanche"] = "雪崩",
                ["Volcanic Eruption"] = "火山爆发",
                ["Blizzard"] = "暴风雪",
                ["Deadly Virus"] = "致命病毒",
                ["Tsunami"] = "海啸",
                ["Lightning"] = "闪电",
                ["Meteor Shower"] = "流星雨",
                ["Earthquake"] = "地震",
                ["Thunder Storm"] = "暴风雨",
                ["Sandstorm"] = "沙尘暴",
                ["Fire"] = "火灾",
                ["Flash Flood"] = "洪水",
                ["Acid Rain"] = "酸雨",
            }
            
            -- 检查当前是否有灾难标签
            if Character then
                local SurvivalTag = Character:FindFirstChild("SurvivalTag")
                if SurvivalTag then
                    local disasterType = SurvivalTag.Value
                    local displayName = disasterNames[disasterType] or disasterType
                    
                    Loaded_Var192:Notify({
                        Content = "当前灾难: " .. displayName,
                        Duration = 5,
                        Title = "灾难预测",
                        Icon = "coffee",
                    })
                end
            end
            
            -- 监听新的灾难标签
            if Character then
                predictionConnection = Character.ChildAdded:Connect(function(child)
                    if child.Name == "SurvivalTag" then
                        wait(0.1) -- 等待值被设置
                        if child:IsA("StringValue") then
                            local disasterType = child.Value
                            local displayName = disasterNames[disasterType] or disasterType
                            
                            Loaded_Var192:Notify({
                                Content = "当前灾难: " .. displayName,
                                Duration = 5,
                                Title = "灾难预测",
                                Icon = "coffee",
                            })
                        end
                    end
                end)
            end
        end
    end,
    Title = "预测灾难",
    Desc = "灾难",
})

Tab_7:Divider()

-- 自动发送灾难信息开关
Tab_7:Toggle({
    Value = false,
    Callback = function(value)
        -- 这里可以添加自动发送信息的逻辑
        if value then
            Loaded_Var192:Notify({
                Duration = 2,
                Title = "提示",
                Content = "自动发送功能已开启",
            })
        else
            Loaded_Var192:Notify({
                Duration = 2,
                Title = "提示",
                Content = "自动发送功能已关闭",
            })
        end
    end,
    Title = "自动发送灾难信息",
    Desc = "自动",
})

-- 清理函数
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if predictionConnection then
        predictionConnection:Disconnect()
        predictionConnection = nil
    end
end)

print("YG SCRIPT 加载完成！")