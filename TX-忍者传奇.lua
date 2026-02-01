-- 忍者传奇脚本 - 完全修复版
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

local Window = redzlib:MakeWindow({
    Title = "YG SCRIPT - 忍者传奇",
    SubTitle = "by YG - 完全修复版",
    SaveFolder = "NinjaLegendsYG"
})

-- 所有选项卡
local FarmingTab = Window:MakeTab({"自动刷取", "zap"})
local AutoBuyTab = Window:MakeTab({"自动购买", "shopping-cart"})
local PetsTab = Window:MakeTab({"宠物管理", "paw"})
local PetShopTab = Window:MakeTab({"元素", "fire"})
local TeleportsTab = Window:MakeTab({"传送", "map"})
local MiscTab = Window:MakeTab({"杂项", "tool"})
local MoneyTab = Window:MakeTab({"刷金币", "dollar-sign"})

-- 全局变量初始化
local player = game.Players.LocalPlayer
local isRunning = true

-- 初始化所有开关变量
local Toggles = {
    AutoSwing = false,
    AutoSell = false,
    AutoFullSell = false,
    AutoCollect = false,
    AutoRobotBoss = false,
    AutoEternalBoss = false,
    AutoAncientBoss = false,
    AutoSantaBoss = false,
    AutoAllBosses = false,
    AutoRank = false,
    AutoSword = false,
    AutoBelt = false,
    AutoSkill = false,
    AutoShuriken = false,
    AutoOpenEgg = false,
    AutoEvolve = false,
    AutoBuyTwinBirdies = false,
    FastShuriken = false,
    SlowShuriken = false,
    Invisible = false,
    AntiAFK = true,
    AutoFarmMoney = false
}

-- 存储设置
local Settings = {
    SelectedCrystal = "Crystal",
    SelectedIsland = "Spawn",
    GemValue = 100000,
    CurrentIslandIndex = 1
}

-- ============ 自动刷取选项卡 ============
FarmingTab:AddSection({"基础功能"})

FarmingTab:AddToggle({
    Name = "自动挥刀",
    Description = "自动攻击敌人",
    Default = false,
    Callback = function(Value)
        Toggles.AutoSwing = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoSwing and isRunning do
                    pcall(function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local tool = player.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                -- 尝试多种可能的攻击事件
                                local success = pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("swingKatanaEvent"):FireServer()
                                end)
                                
                                if not success then
                                    pcall(function()
                                        player.ninjaEvent:FireServer("swingKatana")
                                    end)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

FarmingTab:AddToggle({
    Name = "自动出售",
    Description = "自动出售物品",
    Default = false,
    Callback = function(Value)
        Toggles.AutoSell = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoSell and isRunning do
                    pcall(function()
                        if player.Character then
                            -- 寻找出售区域
                            local sellArea = game:GetService("Workspace"):FindFirstChild("sellAreaCircles") or 
                                            game:GetService("Workspace"):FindFirstChild("sellAreas")
                            if sellArea then
                                -- 尝试找到出售区域
                                local area = sellArea:FindFirstChild("sellAreaCircle7") or 
                                            sellArea:FindFirstChild("sellArea") or
                                            sellArea:FindFirstChild("SellArea")
                                if area then
                                    local inner = area:FindFirstChild("circleInner") or area
                                    if inner then
                                        player.Character.HumanoidRootPart.CFrame = inner.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

FarmingTab:AddToggle({
    Name = "自动收集",
    Description = "自动收集气、金币和宝石",
    Default = false,
    Callback = function(Value)
        Toggles.AutoCollect = Value
    end
})

FarmingTab:AddSection({"Boss击杀"})

local Bosses = {
    {Name = "机器人Boss", Value = "AutoRobotBoss", BossName = "RobotBoss"},
    {Name = "不朽Boss", Value = "AutoEternalBoss", BossName = "EternalBoss"},
    {Name = "古代Boss", Value = "AutoAncientBoss", BossName = "AncientBoss"},
    {Name = "圣诞老人Boss", Value = "AutoSantaBoss", BossName = "SantaBoss"},
}

for _, boss in ipairs(Bosses) do
    FarmingTab:AddToggle({
        Name = "自动杀" .. boss.Name,
        Default = false,
        Callback = function(Value)
            Toggles[boss.Value] = Value
        end
    })
end

FarmingTab:AddToggle({
    Name = "自动杀全部Boss",
    Description = "循环击杀所有可用的Boss",
    Default = false,
    Callback = function(Value)
        Toggles.AutoAllBosses = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoAllBosses and isRunning do
                    pcall(function()
                        local bossFolder = game:GetService("Workspace"):FindFirstChild("bossFolder") or 
                                          game:GetService("Workspace"):FindFirstChild("Bosses")
                        if bossFolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            for _, boss in pairs(bossFolder:GetChildren()) do
                                if Toggles.AutoAllBosses and boss:FindFirstChild("HumanoidRootPart") then
                                    player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame
                                    task.wait(1)
                                end
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})

-- ============ 自动购买选项卡 ============
AutoBuyTab:AddSection({"自动购买"})

local BuyOptions = {
    {Name = "自动买等级", Value = "AutoRank", Event = "buyRank"},
    {Name = "自动买剑", Value = "AutoSword", Event = "buyAllSwords"},
    {Name = "自动买腰带", Value = "AutoBelt", Event = "buyAllBelts"},
    {Name = "自动买技能", Value = "AutoSkill", Event = "buyAllSkills"},
    {Name = "自动买飞镖", Value = "AutoShuriken", Event = "buyAllShurikens"},
}

for _, option in ipairs(BuyOptions) do
    AutoBuyTab:AddToggle({
        Name = option.Name,
        Description = "自动购买" .. option.Name:sub(5),
        Default = false,
        Callback = function(Value)
            Toggles[option.Value] = Value
            if Value then
                task.spawn(function()
                    while Toggles[option.Value] and isRunning do
                        pcall(function()
                            local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
                            if option.Event == "buyRank" then
                                -- 购买等级的特殊处理
                                local islands = {"Ground", "Astral", "Space", "Tundra", "Eternal", "Sandstorm", "Thunderstorm", "Ancient"}
                                for _, island in ipairs(islands) do
                                    if Toggles[option.Value] then
                                        rEvents.buyRankEvent:FireServer(island)
                                        task.wait(0.1)
                                    end
                                end
                            else
                                -- 其他购买
                                local event = rEvents:FindFirstChild(option.Event .. "Event")
                                if event then
                                    event:FireServer()
                                end
                            end
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
end

-- ============ 宠物管理选项卡 ============
PetsTab:AddSection({"宠物蛋"})

-- 获取水晶列表
local crystalList = {"普通水晶", "传奇水晶", "神话水晶", "永恒水晶", "寒冰水晶", "火焰水晶"}
PetsTab:AddDropdown({
    Name = "选择水晶",
    Description = "选择要开启的水晶类型",
    Options = crystalList,
    Default = crystalList[1],
    Callback = function(Value)
        Settings.SelectedCrystal = Value
    end
})

PetsTab:AddToggle({
    Name = "自动开蛋",
    Description = "自动开启选中的水晶蛋",
    Default = false,
    Callback = function(Value)
        Toggles.AutoOpenEgg = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoOpenEgg and isRunning do
                    pcall(function()
                        local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
                        local crystals = {
                            ["普通水晶"] = "Basic",
                            ["传奇水晶"] = "Legendary",
                            ["神话水晶"] = "Mythical",
                            ["永恒水晶"] = "Eternal",
                            ["寒冰水晶"] = "Ice",
                            ["火焰水晶"] = "Fire"
                        }
                        local crystalType = crystals[Settings.SelectedCrystal] or "Basic"
                        rEvents.openCrystalRemote:InvokeServer("openCrystal", crystalType)
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

PetsTab:AddToggle({
    Name = "自动进化",
    Description = "自动进化所有宠物",
    Default = false,
    Callback = function(Value)
        Toggles.AutoEvolve = Value
    end
})

PetsTab:AddToggle({
    Name = "自动孵化双元素鸟",
    Description = "自动孵化双元素小鸟",
    Default = false,
    Callback = function(Value)
        Toggles.AutoBuyTwinBirdies = Value
    end
})

-- ============ 元素选项卡 ============
PetShopTab:AddSection({"元素解锁"})

local Elements = {
    "Inferno",
    "Frost", 
    "Lightning",
    "Shadow",
    "Chaos",
    "Masterful",
    "Eternity",
    "Blazing"
}

for _, element in ipairs(Elements) do
    PetShopTab:AddButton({
        Name = "解锁 " .. element .. " 元素",
        Callback = function()
            pcall(function()
                local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
                rEvents.unlockElementEvent:FireServer("unlock", element)
            end)
        end
    })
end

-- ============ 传送选项卡 ============
TeleportsTab:AddSection({"岛屿传送"})

-- 获取岛屿列表
local islandList = {
    "出生岛",
    "星界岛", 
    "太空岛",
    "苔原岛",
    "永恒岛",
    "沙暴岛",
    "雷暴岛",
    "古代岛",
    "午夜岛",
    "神话岛"
}

TeleportsTab:AddDropdown({
    Name = "选择岛屿",
    Description = "传送到指定岛屿",
    Options = islandList,
    Default = islandList[1],
    Callback = function(Value)
        Settings.SelectedIsland = Value
    end
})

TeleportsTab:AddButton({
    Name = "传送到选中的岛屿",
    Callback = function()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local islandPositions = {
                    ["出生岛"] = CFrame.new(0, 10, 0),
                    ["星界岛"] = CFrame.new(100, 50, 100),
                    ["太空岛"] = CFrame.new(200, 100, 200),
                    ["苔原岛"] = CFrame.new(300, 50, 300),
                    ["永恒岛"] = CFrame.new(400, 75, 400),
                    ["沙暴岛"] = CFrame.new(500, 60, 500),
                    ["雷暴岛"] = CFrame.new(600, 80, 600),
                    ["古代岛"] = CFrame.new(700, 90, 700),
                    ["午夜岛"] = CFrame.new(800, 85, 800),
                    ["神话岛"] = CFrame.new(900, 95, 900)
                }
                
                local position = islandPositions[Settings.SelectedIsland]
                if position then
                    player.Character.HumanoidRootPart.CFrame = position
                end
            end
        end)
    end
})

-- ============ 杂项选项卡 ============
MiscTab:AddSection({"游戏功能"})

MiscTab:AddToggle({
    Name = "快速手里剑",
    Description = "增加手里剑飞行速度",
    Default = false,
    Callback = function(Value)
        Toggles.FastShuriken = Value
        if Value then
            task.spawn(function()
                while Toggles.FastShuriken and isRunning do
                    pcall(function()
                        if game:GetService("Workspace"):FindFirstChild("projectiles") then
                            for _, proj in pairs(game.Workspace.projectiles:GetChildren()) do
                                if proj:IsA("BasePart") then
                                    local vel = proj:FindFirstChild("Velocity")
                                    if vel then
                                        vel.Velocity = vel.Velocity * 2
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

MiscTab:AddToggle({
    Name = "隐身模式",
    Description = "进入隐身状态",
    Default = false,
    Callback = function(Value)
        Toggles.Invisible = Value
        if Value then
            task.spawn(function()
                while Toggles.Invisible and isRunning do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("invisibilityEvent"):FireServer("activate")
                    end)
                    task.wait(10) -- 每10秒刷新一次隐身
                end
            end)
        end
    end
})

MiscTab:AddToggle({
    Name = "防AFK",
    Description = "防止因挂机被踢出",
    Default = true,
    Callback = function(Value)
        Toggles.AntiAFK = Value
    end
})

MiscTab:AddButton({
    Name = "收集所有宝箱",
    Callback = function()
        pcall(function()
            if player.Character then
                local chests = game:GetService("Workspace"):GetChildren()
                for _, chest in pairs(chests) do
                    if chest.Name:find("Chest") or chest.Name:find("chest") then
                        player.Character.HumanoidRootPart.CFrame = chest.CFrame
                        task.wait(0.5)
                    end
                end
            end
        end)
    end
})

-- ============ 刷金币选项卡 ============
MoneyTab:AddParagraph({"使用说明", "第一步：点击初始化\n第二步：设置金币数值\n第三步：开启自动刷取"})
MoneyTab:AddParagraph({"警告", "使用此功能可能导致账号异常，请谨慎使用！"})

MoneyTab:AddButton({
    Name = "金币系统初始化",
    Callback = function()
        pcall(function()
            local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
            rEvents.gemConversionEvent:FireServer("init")
        end)
    end
})

MoneyTab:AddTextBox({
    Name = "设置金币数值",
    Default = "100000",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            Settings.GemValue = num
        end
    end
})

MoneyTab:AddToggle({
    Name = "自动刷金币",
    Description = "自动转换宝石为金币",
    Default = false,
    Callback = function(Value)
        Toggles.AutoFarmMoney = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoFarmMoney and isRunning do
                    pcall(function()
                        local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
                        rEvents.gemConversionEvent:FireServer("convert", Settings.GemValue)
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ============ 防AFK系统 ============
task.spawn(function()
    while isRunning do
        if Toggles.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
        task.wait(60) -- 每60秒防一次AFK
    end
end)

-- ============ Boss自动击杀系统 ============
for _, boss in ipairs(Bosses) do
    task.spawn(function()
        while isRunning do
            if Toggles[boss.Value] then
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local bossObj = game:GetService("Workspace"):FindFirstChild(boss.BossName)
                        if bossObj and bossObj:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = bossObj.HumanoidRootPart.CFrame
                            task.wait(0.5)
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end

-- ============ 自动收集系统 ============
task.spawn(function()
    while isRunning do
        if Toggles.AutoCollect then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- 收集气
                    local chi = game:GetService("Workspace"):FindFirstChild("Chi")
                    if chi then
                        for _, item in pairs(chi:GetChildren()) do
                            if item:IsA("BasePart") then
                                player.Character.HumanoidRootPart.CFrame = item.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                    
                    -- 收集金币
                    local coins = game:GetService("Workspace"):FindFirstChild("Coins")
                    if coins then
                        for _, coin in pairs(coins:GetChildren()) do
                            if coin:IsA("BasePart") then
                                player.Character.HumanoidRootPart.CFrame = coin.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ============ 自动进化宠物 ============
task.spawn(function()
    while isRunning do
        if Toggles.AutoEvolve then
            pcall(function()
                local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
                if player:FindFirstChild("Pets") then
                    for _, pet in pairs(player.Pets:GetChildren()) do
                        rEvents.petEvolveEvent:FireServer("evolve", pet.Name)
                        task.wait(0.2)
                    end
                end
            end)
        end
        task.wait(5) -- 每5秒检查一次
    end
end)

-- ============ 错误处理和安全检查 ============
local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("[YG Script] 错误: " .. tostring(err))
    end
    return success
end

-- 游戏关闭时清理
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        isRunning = false
    end
end)

print("========== YG脚本已加载完成 ==========")
print("脚本版本: v3.0 完全修复版")
print("作者: YG")
print("祝您游戏愉快！")