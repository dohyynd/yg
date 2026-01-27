-- 注意：这是一个Roblox脚本，需要在支持loadstring的环境中运行
-- 加载外部库
local Loaded_Var192 = loadstring(game:HttpGet("https://raw.githubusercontent.com/SUNXIAOCHUAN-DEV/-/refs/heads/main/乱码牛逼"))()

-- 本地变量定义
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local CurrentCamera = workspace.CurrentCamera

-- 设置UI主题
Loaded_Var192.TransparencyValue = 0.2
Loaded_Var192:SetTheme("Dark")

-- 显示通知
Loaded_Var192:Notify({
    ["Transparency"] = 0.7,
    ["Duration"] = 2,
    ["Title"] = "YG SCRIPT",
    ["Content"] = "YG SCRIPT--自然灾害加载完成",
})

-- 创建主窗口
local Window = Loaded_Var192:CreateWindow({
    ["Title"] = "YG SCRIPT--自然灾害",
    ["Size"] = UDim2.fromOffset(600, 500),
    ["Position"] = UDim2.new(0.5, 0, 0.5, 0),
    ["Transparent"] = true,
    ["Theme"] = "Dark",
    ["Icon"] = "crown",
    ["ScrollBarEnabled"] = true,
    ["Folder"] = "OrangeCHub",
    ["SideBarWidth"] = 180,
    ["Author"] = "加入qq群聊 1015718032",
    ["User"] = {
        ["Enabled"] = true,
        ["Username"] = LocalPlayer.Name,
        ["ThumbnailType"] = "AvatarBust",
        ["Anonymous"] = false,
        ["Callback"] = function()
            Loaded_Var192:Notify({
                ["Duration"] = 3,
                ["Title"] = "用户信息",
                ["Content"] = "玩家:" .. LocalPlayer.Name,
            })
        end
    }
})

-- 创建主题切换按钮
local themeButton = Window:CreateTopbarButton({
    ["Name"] = "theme-switcher",
    ["Icon"] = "moon",
    ["Callback"] = function()
        local CurrentTheme = Loaded_Var192:GetCurrentTheme()
        if CurrentTheme == "Dark" then
            Loaded_Var192:SetTheme("Light")
        else
            Loaded_Var192:SetTheme("Dark")
        end
        
        local NewTheme = Loaded_Var192:GetCurrentTheme()
        Loaded_Var192:Notify({
            ["Duration"] = 2,
            ["Title"] = "提示",
            ["Content"] = "当前主题: " .. NewTheme,
        })
    end,
    ["Priority"] = 990
})

-- 编辑打开按钮
Window:EditOpenButton({
    ["Title"] = "YG SCRIPT-自然灾害",
    ["Icon"] = "crown",
})

-- 创建部分
local Section_3 = Window:Section({
    ["Title"] = "玩家",
    ["Icon"] = "user",
    ["Opened"] = false,
})

local Section_5 = Window:Section({
    ["Title"] = "灾难",
    ["Icon"] = "package-open",
    ["Opened"] = false,
})

Window:Section({
    ["Title"] = "自动",
    ["Icon"] = "pocket-knife",
    ["Opened"] = false,
})

-- 创建标签页
local Tab_3 = Section_3:Tab({
    ["Title"] = "公告",
    ["Icon"] = "folder",
})

local Tab_5 = Section_3:Tab({
    ["Title"] = "玩家",
    ["Icon"] = "folder",
})

local Tab_7 = Section_5:Tab({
    ["Title"] = "预测灾难",
    ["Icon"] = "folder",
})

-- Tab_3 内容
Tab_3:Paragraph({
    ["Title"] = "欢迎尊贵的用户",
    ["Desc"] = "此脚本会一直更新 感谢白名单使用者",
    ["Image"] = "info",
    ["ImageSize"] = 15,
})

Tab_3:Paragraph({
    ["Title"] = "玩家",
    ["Desc"] = "尊敬的用户: " .. LocalPlayer.Name .. " 欢迎使用",
    ["Image"] = "user",
    ["ImageSize"] = 12,
})

Tab_3:Paragraph({
    ["Title"] = "设备",
    ["Desc"] = "你的使用设备: 手机📱/电脑💻",
    ["Image"] = "gamepad",
    ["ImageSize"] = 12,
})

Tab_3:Paragraph({
    ["Title"] = "注入器",
    ["Desc"] = "你的注入器: " .. (identifyexecutor and identifyexecutor() or "未知"),
    ["Image"] = "syringe",
    ["ImageSize"] = 12,
})

-- Tab_5 内容
Tab_5:Slider({
    ["Title"] = "玩家速度",
    ["Desc"] = "玩家的速度",
    ["Value"] = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    ["Step"] = 1,
    ["Callback"] = function(value)
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character.Humanoid.WalkSpeed = value
        end
    end,
})

Tab_5:Slider({
    ["Title"] = "玩家跳跃高度",
    ["Desc"] = "玩家的跳跃高度",
    ["Value"] = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    ["Step"] = 1,
    ["Callback"] = function(value)
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character.Humanoid.JumpHeight = value
        end
    end,
})

Tab_5:Slider({
    ["Title"] = "玩家镜头FOV",
    ["Desc"] = "玩家的镜头",
    ["Value"] = {
        Min = 70,
        Max = 120,
        Default = 70,
    },
    ["Step"] = 1,
    ["Callback"] = function(value)
        if CurrentCamera then
            CurrentCamera.FieldOfView = value
        end
    end,
})

Tab_5:Button({
    ["Title"] = "删除摔落伤害",
    ["Desc"] = "删除",
    ["Callback"] = function()
        if Character then
            local FallDamageScript = Character:FindFirstChild("FallDamageScript")
            if FallDamageScript then
                FallDamageScript:Destroy()
            end
            
            -- 监听新添加的FallDamageScript
            Character.ChildAdded:Connect(function(child)
                if child.Name == "FallDamageScript" then
                    task.wait(0.1)
                    child:Destroy()
                end
            end)
        end
    end,
})

-- Tab_7 内容
local disasterConnection = nil
Tab_7:Toggle({
    ["Title"] = "预测灾难",
    ["Desc"] = "灾难",
    ["Value"] = false,
    ["Callback"] = function(value)
        if disasterConnection then
            disasterConnection:Disconnect()
            disasterConnection = nil
        end
        
        if value then
            disasterConnection = Character.ChildAdded:Connect(function(child)
                if child.Name == "SurvivalTag" then
                    local DisasterDictionary = {
                        ["Tornado"] = "龙卷风",
                        ["Avalanche"] = "雪崩",
                        ["Volcanic Eruption"] = "火山",
                        ["Blizzard"] = "暴风雪",
                        ["Deadly Virus"] = "病毒",
                        ["Tsunami"] = "海啸",
                        ["Lightning"] = "闪电",
                        ["Meteor Shower"] = "流星雨",
                        ["Earthquake"] = "地震",
                        ["Thunder Storm"] = "暴风雨",
                        ["Sandstorm"] = "沙尘暴",
                        ["Fire"] = "火焰",
                        ["Flash Flood"] = "洪水",
                        ["Acid Rain"] = "酸雨",
                    }
                    
                    local disasterValue = child.Value
                    local disasterName = DisasterDictionary[disasterValue] or disasterValue
                    
                    Loaded_Var192:Notify({
                        ["Content"] = "当前灾难: " .. disasterName,
                        ["Duration"] = 5,
                        ["Title"] = "灾难预测",
                        ["Icon"] = "coffee",
                    })
                end
            end)
            
            -- 检查是否已有SurvivalTag
            local SurvivalTag = Character:FindFirstChild("SurvivalTag")
            if SurvivalTag then
                local DisasterDictionary = {
                    ["Tornado"] = "龙卷风",
                    ["Avalanche"] = "雪崩",
                    ["Volcanic Eruption"] = "火山",
                    ["Blizzard"] = "暴风雪",
                    ["Deadly Virus"] = "病毒",
                    ["Tsunami"] = "海啸",
                    ["Lightning"] = "闪电",
                    ["Meteor Shower"] = "流星雨",
                    ["Earthquake"] = "地震",
                    ["Thunder Storm"] = "暴风雨",
                    ["Sandstorm"] = "沙尘暴",
                    ["Fire"] = "火焰",
                    ["Flash Flood"] = "洪水",
                    ["Acid Rain"] = "酸雨",
                }
                
                local disasterValue = SurvivalTag.Value
                local disasterName = DisasterDictionary[disasterValue] or disasterValue
                
                Loaded_Var192:Notify({
                    ["Content"] = "当前灾难: " .. disasterName,
                    ["Duration"] = 5,
                    ["Title"] = "灾难预测",
                    ["Icon"] = "coffee",
                })
            end
        end
    end,
})

Tab_7:Divider()

local autoSendConnection = nil
Tab_7:Toggle({
    ["Title"] = "自动发送灾难信息",
    ["Desc"] = "自动",
    ["Value"] = false,
    ["Callback"] = function(value)
        -- 这里可以添加自动发送聊天消息的逻辑
        if value then
            Loaded_Var192:Notify({
                ["Duration"] = 3,
                ["Title"] = "提示",
                ["Content"] = "自动发送功能已开启",
            })
        else
            Loaded_Var192:Notify({
                ["Duration"] = 3,
                ["Title"] = "提示",
                ["Content"] = "自动发送功能已关闭",
            })
        end
    end,
})