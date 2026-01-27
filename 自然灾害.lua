local Loaded_Var192 = loadstring(game:HttpGet("https://raw.githubusercontent.com/SUNXIAOCHUAN-DEV/-/refs/heads/main/乱码牛逼"))()
cloneref(game:GetService("HttpService"))
clonefunction(isfunctionhooked)
local _ = (isfunctionhooked(game.HttpGet) and 11526659)
isfunctionhooked(getnamecallmethod)
local _ = (isfunctionhooked(request) and 14885559)
local Players_2 = game:GetService("Players")
local LocalPlayer = Players_2.LocalPlayer
local Character_2 = LocalPlayer["Character"]
local _ = ((Character_2 and 10429180) or 10523794)
Character_2:WaitForChild("HumanoidRootPart")
local _ = (game:GetService("UserInputService").TouchEnabled and 11343401)
Loaded_Var192.TransparencyValue = 0.2
Loaded_Var192:SetTheme("Dark")
Loaded_Var192:Notify({
    ["Transparency"] = 0.7,
    ["Duration"] = 2,
    ["Title"] = "YG SCRIPT",
    ["Content"] = "YG SCRIPT--自然灾害加载完成",
})
local Window = Loaded_Var192:CreateWindow({
    User = {
        ["Enabled"] = true,
        ["Callback"] = function(p1_0, p2_0, p3_0)
            Loaded_Var192:Notify({
                ["Duration"] = 3,
                ["Title"] = "用户信息",
                ["Content"] = "玩家:" .. LocalPlayer["Name"],
            })
        end,
        ThumbnailType = "AvatarBust",
        ["Anonymous"] = false,
        ["Username"] = LocalPlayer["Name"],
        LocalPlayer.UserId = LocalPlayer.UserId,
        LocalPlayer.DisplayName = LocalPlayer.DisplayName,
    },
    ["Author"] = "作者：无",
    ScrollBarEnabled = true,
    ["Folder"] = "OrangeCHub",
    ["SideBarWidth"] = 180,
    [Title] = "YG SCRIPT--自然灾害",
    ["Position"] = UDim2["new"](0.5, 0, 0.5, 0),
    ["Transparent"] = true,
    ["Theme"] = Dark,
    ["Icon"] = "crown",
    ["Size"] = UDim2.fromOffset(600, 500),
})
local _ = Window:CreateTopbarButton("theme-switcher", "moon", function(p1_0, p2_0)
    local GetCurrentTheme = Loaded_Var192.GetCurrentTheme;
    local CurrentTheme = Loaded_Var192:GetCurrentTheme();
    local var562 = (CurrentTheme == "Dark");
    local var563 = (var562 and 11706354);
    local SetTheme_3 = Loaded_Var192["SetTheme"];
    local Dark_3 = Loaded_Var192:SetTheme("Dark");
    local Content_3 = "Content";
    local Notify_6 = Loaded_Var192["Notify"];
    local GetCurrentTheme_2 = Loaded_Var192.GetCurrentTheme;
    local CurrentTheme_2 = Loaded_Var192:GetCurrentTheme();
    local var570 = "当前主题: " .. CurrentTheme_2;
    local Duration_3 = "Duration";
    local Notify_7 = Loaded_Var192:Notify({
        [Duration_3] = 2,
        ["Title"] = "提示",
        [Content_3] = var570,
    });
end, 990)
Window:EditOpenButton({
    ["Title"] = "YG SCRIPT-自然灾害",
    ["Icon"] = "crown",
})
local Section_3 = Window:Section({
    [Icon] = "user",
    [Title] = "玩家",
    ["Opened"] = false,
})
local Section_5 = Window:Section({
    [Icon] = "package-open",
    [Title] = "灾难",
    [Opened] = false,
})
Window:Section({
    ["Icon"] = "pocket-knife",
    ["Title"] = "自动",
    ["Opened"] = false,
})
local Tab_3 = Section_3:Tab({
    [Title] = "公告",
    [Icon] = "folder",
})
local Tab_5 = Section_3:Tab({
    [Title] = "玩家",
    [Icon] = "folder",
})
local Tab_7 = Section_5:Tab({
    [Title] = "预测灾难",
    [Icon] = "folder",
})
Tab_3:Paragraph({
    ["ImageSize"] = 15,
    Image = "info",
    ["Title"] = "欢迎尊贵的用户",
    Desc = "此脚本会一直更新 感谢白名单使用者",
})
Tab_3:Paragraph({
    ["ImageSize"] = 12,
    Image = "user",
    ["Title"] = "玩家",
    Desc = "尊敬的用户: " .. LocalPlayer["Name"] .. "欢迎使用",
})
Tab_3:Paragraph({
    ["ImageSize"] = 12,
    Image = "gamepad",
    ["Title"] = "设备",
    Desc = "你的使用设备: 电脑",
})
Tab_3:Paragraph({
    ["ImageSize"] = 12,
    Image = "syringe",
    ["Title"] = "注入器",
    Desc = "你的注入器: " .. identifyexecutor(),
})
local CurrentCamera = workspace.CurrentCamera
local _ = Tab_5:Slider({
    ["Title"] = "玩家速度",
    ["Value"] = {
        Min = 16,
        ["Default"] = 16,
        Max = 200,
    },
    ["Callback"] = function(p1_0, p2_0, p3_0, p4_0, p5_0, p6_0)
        local var577 = p1_0[1];
        local Players_13 = "Players";
        local Players_14 = game:GetService(Players_13);
        local LocalPlayer_7 = Players_2.LocalPlayer;
        local Character_3 = "Character";
        local Character_4 = LocalPlayer[Character_3];
        local var592 = (Character_4 and 14201054);
        local var593 = (var592 or 14167078);
        local Players_15 = "Players";
        local Players_16 = game:GetService(Players_15);
        local LocalPlayer_8 = Players_2.LocalPlayer;
        local Character_5 = "Character";
        local Character_6 = LocalPlayer[Character_5];
        local Humanoid_2 = "Humanoid";
        local Humanoid_3 = Character_6:FindFirstChild(Humanoid_2);
        if not not Humanoid_3 then return end -- won't run
        local Players_17 = "Players";
        local Players_18 = game:GetService(Players_17);
        local LocalPlayer_9 = Players_2.LocalPlayer;
        local Character_7 = "Character";
        local Character_8 = LocalPlayer[Character_7];
        local Humanoid_4 = "Humanoid";
        local Humanoid_5 = Character_8[Humanoid_4];
        local WalkSpeed = "WalkSpeed";
        Humanoid_5[WalkSpeed] = var577;
    end,
    ["Step"] = 1,
    Desc = "玩家的速度",
})
local _ = Tab_5:Slider({
    ["Title"] = "玩家跳跃高度",
    ["Value"] = {
        Min = 50,
        ["Default"] = 50,
        Max = 200,
    },
    ["Callback"] = function(p1_0, p2_0, p3_0, p4_0, p5_0, p6_0)
        local var634 = p1_0[1];
        local Players_19 = "Players";
        local Players_20 = game:GetService(Players_19);
        local LocalPlayer_10 = Players_2.LocalPlayer;
        local Character_9 = "Character";
        local Character_10 = LocalPlayer[Character_9];
        local var649 = (Character_10 and 10517650);
        local var650 = (var649 or 10768174);
        local Players_21 = "Players";
        local Players_22 = game:GetService(Players_21);
        local LocalPlayer_11 = Players_2.LocalPlayer;
        local Character_11 = "Character";
        local Character_12 = LocalPlayer[Character_11];
        local Humanoid_6 = "Humanoid";
        local Humanoid_7 = Character_12:FindFirstChild(Humanoid_6);
        if not not Humanoid_7 then return end -- won't run
        local Players_23 = "Players";
        local Players_24 = game:GetService(Players_23);
        local LocalPlayer_12 = Players_2.LocalPlayer;
        local Character_13 = "Character";
        local Character_14 = LocalPlayer[Character_13];
        local Humanoid_8 = "Humanoid";
        local Humanoid_9 = Character_14[Humanoid_8];
        local JumpHeight = "JumpHeight";
        Humanoid_9[JumpHeight] = var634;
    end,
    ["Step"] = 1,
    Desc = "玩家的跳跃高度",
})
local _ = Tab_5:Slider({
    ["Title"] = "玩家镜头FOV",
    ["Value"] = {
        Min = 70,
        ["Default"] = 70,
        Max = 120,
    },
    ["Callback"] = function(p1_0, p2_0, p3_0, p4_0, p5_0, p6_0)
        local var692 = p1_0[1];
        if not CurrentCamera then return end -- won't run
        CurrentCamera.FieldOfView = var692;
    end,
    ["Step"] = 1,
    Desc = "玩家的镜头",
})
local _ = Tab_5:Button({
    ["Callback"] = function(p1_0, p2_0, p3_0, p4_0)
        local Players_25 = "Players";
        local Players_26 = game:GetService(Players_25);
        local LocalPlayer_13 = Players_2.LocalPlayer;
        local Character_15 = "Character";
        local Character_16 = LocalPlayer[Character_15];
        local FallDamageScript = Character_16:FindFirstChild("FallDamageScript");
        local var715 = (FallDamageScript and 11306970);
        local var716 = (var715 or 15113541);
        local Players_27 = "Players";
        local Players_28 = game:GetService(Players_27);
        local LocalPlayer_14 = Players_2.LocalPlayer;
        local Character_17 = "Character";
        local Character_18 = LocalPlayer[Character_17];
        local FallDamageScript_2 = Character_18.FallDamageScript;
        local Destroy_2 = FallDamageScript_2["Destroy"];
        local Destroy_3 = FallDamageScript_2:Destroy();
        local Players_29 = "Players";
        local Players_30 = game:GetService(Players_29);
        local LocalPlayer_15 = Players_2.LocalPlayer;
        local Character_19 = "Character";
        local Character_20 = LocalPlayer[Character_19];
        local ChildAdded = "ChildAdded";
        local Connection;
        Connection = Character_20[ChildAdded]:Connect(function(Child_3) -- args: Child_4;
            local Child_4 = Child_3[1];
            local Name_7 = "Name";
            local Name_8 = Child_4[Name_7];
            local Name_8_is_string = (Name_8 == "FallDamageScript");
            local var855 = (Name_8_is_string and 12441628);
        end);
    end,
    ["Title"] = "删除摔落伤害",
    Desc = "删除",
})
local _ = Tab_7:Toggle({
    ["Value"] = false,
    ["Callback"] = function(p1_0, p2_0, p3_0, p4_0, p5_0)
        local var756 = p1_0[1];
        if not var756 then return end -- won't run
        local ChildAdded_2 = "ChildAdded";
        local Connection_2;
        Connection_2 = Character_2[ChildAdded_2]:Connect(function(Child_5, p2_0, p3_0, p4_0, p5_0) -- args: Child_6;
            local Child_6 = Child_5[1];
            local Name_9 = "Name";
            local Name_10 = Child_6[Name_9];
            local Name_10_is_string = (Name_10 == "SurvivalTag");
        end);
        local SurvivalTag = Character_2:FindFirstChild("SurvivalTag");
        if not not SurvivalTag then return end -- won't run
        local Blizzard = "Blizzard";
        local Tornado = "Tornado";
        local Volcanic_Eruption = "Volcanic Eruption";
        local Flash_Flood = "Flash Flood";
        local Deadly_Virus = "Deadly Virus";
        local Tsunami = "Tsunami";
        local Acid_Rain = "Acid Rain";
        local Fire = "Fire";
        local Meteor_Shower = "Meteor Shower";
        local Earthquake = "Earthquake";
        local Thunder_Storm = "Thunder Storm";
        local Avalanche = "Avalanche";
        local Lightning = "Lightning";
        local Value_2 = SurvivalTag["Value"];
        local Dictionary = {
            [Tornado] = "龙卷风",
            [Avalanche] = "雪崩",
            [Volcanic_Eruption] = "火山",
            [Blizzard] = "暴风雪",
            [Deadly_Virus] = "病毒",
            [Tsunami] = "海啸",
            [Lightning] = "闪电",
            [Meteor_Shower] = "流星雨",
            [Earthquake] = "地震",
            [Thunder_Storm] = "暴风雨",
            Sandstorm = "沙尘暴",
            [Fire] = "火焰",
            [Flash_Flood] = "洪水",
            [Acid_Rain] = "酸雨",
        };
        local var829 = Env[Value_2];
        local var830 = (var829 and 13815013);
        local Coffee = "coffee";
        local Content_4 = "Content";
        local Notify_8 = Loaded_Var192["Notify"];
        local Value_3 = SurvivalTag["Value"];
        local var838 = Dictionary[Value_3];
        local var839 = "当前灾难: " .. var838;
        local Duration_4 = "Duration";
        local Notify_9 = Loaded_Var192:Notify({
            [Content_4] = var839,
            [Duration_4] = 5,
            ["Title"] = "灾难预测",
            ["Icon"] = Coffee,
        });
    end,
    ["Title"] = "预测灾难",
    Desc = "灾难",
})
Tab_7:Divider()
Tab_7:Toggle({
    ["Value"] = false,
    ["Callback"] = function(p1_0)
    end,
    ["Title"] = "自动发送灾难信息",
    Desc = "自动",
})