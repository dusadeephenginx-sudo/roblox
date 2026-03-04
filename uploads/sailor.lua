-- กำหนดรายการไอดีแมพที่อนุญาต
repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local Workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

-- ===================== CONFIGURATION =====================
-- [[ ใส่ Service ID ของ PandaAuth ตรงนี้ ]]
local PandaServiceID = "lumedevkid" 
-- [[ 🟢 ใส่ DISCORD WEBHOOK URL ของคุณตรงนี้ ]]
local DiscordWebhookURL = "https://ptb.discord.com/api/webhooks/1467159900986675416/YH8HUBXGpSpuSFiqrJlIncJD_CEoQK-CSvStXj3kKCCbrt6Yi6q19-HnBggxIwE22QKZ"

-- ตัวแปร Request สำหรับใช้ทั่วทั้งสคริปต์
local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request

-- ===================== DISCORD LOGGING SYSTEM =====================
local function SendDiscordLog(key)
    if DiscordWebhookURL == "" or DiscordWebhookURL:find("YOUR_WEBHOOK_HERE") then return end
    
    task.spawn(function()
        if not httpRequest then return end

        -- 1. Get HWID (จำลองการดึง HWID แบบเดียวกับ Panda)
        local hwid = "Unknown"
        if gethwid then 
            pcall(function() hwid = gethwid() end) 
        end
        if not hwid or hwid == "Unknown" then
            local exec = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "unknown"
            hwid = "P_" .. tostring(Players.LocalPlayer.UserId) .. "_" .. exec
        end

        -- 2. Get IP Address
        local ip = "Unknown"
        pcall(function()
            ip = game:HttpGet("https://api.ipify.org")
        end)

        -- 3. Construct Payload
        local embedData = {
            ["username"] = "Lume.Dev Logger",
            ["avatar_url"] = "https://i.imgur.com/AsX6V96.png",
            ["embeds"] = {{
                ["title"] = "🔐 Access Granted: Lume.Dev",
                ["color"] = 65280, -- สีเขียว (Green)
                ["fields"] = {
                    {
                        ["name"] = "👤 User Profile",
                        ["value"] = string.format("Name: `%s`\nDisplay: `%s`\nID: `%d`", Players.LocalPlayer.Name, Players.LocalPlayer.DisplayName, Players.LocalPlayer.UserId),
                        ["inline"] = false
                    },
                    {
                        ["name"] = "🌐 Network Info",
                        ["value"] = string.format("IP: ||%s||", ip),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🔑 Key Used",
                        ["value"] = string.format("||`%s`||", key),
                        ["inline"] = false
                    },
                    {
                        ["name"] = "💻 Hardware ID (HWID)",
                        ["value"] = string.format("```%s```", hwid),
                        ["inline"] = false
                    }
                },
                ["footer"] = {
                    ["text"] = "Lume.Dev Auth System • " .. os.date("%Y-%m-%d %H:%M:%S")
                }
            }}
        }

        -- 4. Send Request
        httpRequest({
            Url = DiscordWebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end

-- ===================== UI LIBRARY HELPERS =====================
local UI = {}
function UI:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function UI:AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function UI:AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function UI:AddGradient(instance, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = instance
    return gradient
end

function UI:AddShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

-- ===================== NEW PANDA AUTH API (V1 Latest) =====================
local PandaAuth = {}
do
    local BaseURL = "https://new.pandadevelopment.net/api/v1"
    
    -- Get Hardware ID (Updated Logic)
    function PandaAuth.getHardwareId()
        local success, hwid = pcall(function() 
            return gethwid and gethwid() 
        end)
        
        if success and hwid then
            return hwid
        end
    
        -- Fallback to analytics client ID
        local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
        local clientId = tostring(RbxAnalyticsService:GetClientId())
        return clientId:gsub("-", "")
    end
    
    -- HTTP Request wrapper (Uses local httpRequest)
    local function makeRequest(endpoint, body)
        if not httpRequest then return nil end
        
        local url = BaseURL .. endpoint
        local jsonBody = HttpService:JSONEncode(body)
    
        local response = httpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonBody
        })
    
        if response and response.Body then
            local s, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if s then return data end
        end
    
        return nil
    end

    function PandaAuth.GetKeyURL()
        local hwid = PandaAuth.getHardwareId()
        return "https://new.pandadevelopment.net/getkey/" .. PandaServiceID .. "?hwid=" .. hwid
    end

    function PandaAuth.Validate(key)
        local hwid = PandaAuth.getHardwareId()
    
        local result = makeRequest("/keys/validate", {
            ServiceID = PandaServiceID,
            HWID = hwid,
            Key = key
        })
    
        if not result then
            return {
                success = false,
                message = "Failed to connect to server",
                isPremium = false,
                expireDate = nil
            }
        end
    
        local isAuthenticated = result.Authenticated_Status == "Success"
        local isPremium = result.Key_Premium or false
        local message = result.Note or (isAuthenticated and "Key validated!" or "Invalid key")
    
        return {
            success = isAuthenticated,
            message = message,
            isPremium = isPremium,
            expireDate = result.Expire_Date
        }
    end
end

-- ===================== FILE SYSTEM HELPER =====================
local function SaveKeyToFile(path, content)
    pcall(function()
        local folders = path:split("/")
        if #folders > 1 then
            local currentPath = ""
            for i = 1, #folders - 1 do
                currentPath = currentPath .. folders[i] .. "/"
                if not isfolder(currentPath) then
                    makefolder(currentPath)
                end
            end
        end
        writefile(path, content)
    end)
end

-- ===================== MAIN UI LOGIC =====================
if CoreGui:FindFirstChild("LumeDev_KeySystem") then
    CoreGui.LumeDev_KeySystem:Destroy()
end

function CreateKeySystem()
    local Task = {}
    local coppy = setclipboard or toclipboard or function(t) print("Clipboard:", t) end

    local ScreenGui = UI:Create("ScreenGui", {
        Name = "LumeDev_KeySystem",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or CoreGui
    })

    local function NotifyCustom(title, content)
        local NotifFrame = UI:Create("Frame", {
            Parent = ScreenGui,
            Size = UDim2.fromOffset(280, 80),
            Position = UDim2.new(1, -300, 0, 50),
            BackgroundColor3 = Color3.fromRGB(18, 18, 20),
            BorderSizePixel = 0,
        })
        UI:AddCorner(NotifFrame, 8)
        UI:AddStroke(NotifFrame, Color3.fromRGB(231, 76, 60), 1)
        UI:AddShadow(NotifFrame)
        
        local t = UI:Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local d = UI:Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 0, 30),
            Text = content,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        task.delay(3, function() NotifFrame:Destroy() end)
    end

    local function DraggFunction(Frame)
        local dragToggle, dragInput, dragStart, startPos
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = true; dragStart = input.Position; startPos = Frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local function VerifyKey(key, file_directory)
        local cleaned_key = tostring(key):gsub("%s", "")
        
        -- [[ ใช้ API ใหม่ในการตรวจสอบ ]]
        local result = PandaAuth.Validate(cleaned_key)
        
        if result.success then
            -- [[ 🟢 LOGGING TRIGGER ]] --
            SendDiscordLog(cleaned_key)
            SaveKeyToFile(file_directory, cleaned_key)
            
            NotifyCustom("Success", "Access Granted!")
            task.wait(1)
            
            if ScreenGui then ScreenGui:Destroy() end
            
            -- ปิดฟังก์ชัน VerifyKey ให้เรียบร้อยก่อนเริ่มรันสคริปต์หลัก
            task.spawn(function()
                print("KEY SUCCESS! Loading Lume.Dev Hub...")
                -- ====================================================
                -- 🟢 วางสคริปต์หลัก (Main Hub) ทั้งหมดต่อจากบรรทัดนี้ได้เลย
                -- ====================================================
                local AllowedPlaceIds = {
["77747658251236"] = true,
["75159314259063"] = true,
["99684056491472"] = true,
["123955125827131"] = true,
["96767841099256"] = true,
}

local currentPlaceId = tostring(game.PlaceId)

-- ตรวจสอบแมพ
if not AllowedPlaceIds[currentPlaceId] then
	local msg = "Unauthorized Game: " .. currentPlaceId
	warn(msg)
	-- ถ้าจะใช้ในเซิร์ฟจริง แนะนำให้เปิดบรรทัด Kick ด้านล่างนี้ครับ
	-- game:GetService("Players").LocalPlayer:Kick(msg)
	return -- หยุดการทำงาน
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- บริการต่างๆ ของ Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ปิดหน้าต่าง Game Pause ตอน Teleport
pcall(function()
game:GetService("CoreGui").RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

-- [OPTIMIZED] Caching Remotes (ดึงค่าแบบไม่กระตุกโดยใช้ Task Spawn)
local RS_RemoteEvents, QuestAcceptRemote, QuestAbandonRemote
local CombatSystem, CombatRemotes, HitRemote
local AbilitySystem, AbilityRemotes, SkillRemote

task.spawn(function()
RS_RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
if RS_RemoteEvents then
	QuestAcceptRemote = RS_RemoteEvents:WaitForChild("QuestAccept", 5)
	QuestAbandonRemote = RS_RemoteEvents:WaitForChild("QuestAbandon", 5)
end

CombatSystem = ReplicatedStorage:WaitForChild("CombatSystem", 5)
if CombatSystem then
	CombatRemotes = CombatSystem:WaitForChild("Remotes", 5)
	if CombatRemotes then
		HitRemote = CombatRemotes:WaitForChild("RequestHit", 5)
	end
end

AbilitySystem = ReplicatedStorage:WaitForChild("AbilitySystem", 5)
if AbilitySystem then
	AbilityRemotes = AbilitySystem:WaitForChild("Remotes", 5)
	if AbilityRemotes then
		SkillRemote = AbilityRemotes:WaitForChild("RequestAbility", 5)
	end
end
end)

-- State Variables for Haki Logic
local HakiState = { Active = false }
local ObsState = { Active = false }

-- State Variables for Teleport Logic (Bosses)
_G.HasWarpedToRimuru = false
_G.HasWarpedToBossV2 = false
_G.HasWarpedToGilgamesh = false

-- State Variables for Event Loop
local EventFarmState = "Slime"
local SlimeKillCount = 0
local ValentineKillCount = 0

-- State Variables for Specific Mob Loop (Lv 750 -> 8000)
local SpecificFarmIndex = 1
local SpecificMobKillCount = 0
local SpecificMobList = {
"Desert Bandit (Lv. 750)",
"Frost Rogue (Lv. 1500)",
"Sorcerer Student (Lv. 3000)",
"Slime (Lv. 8000)"
}

-- Listeners to update Haki State from Server
task.spawn(function()
local Events = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if Events then
	local HakiStateUpdate = Events:WaitForChild("HakiStateUpdate", 5)
	if HakiStateUpdate then
		HakiStateUpdate.OnClientEvent:Connect(function(isActive)
		HakiState.Active = isActive
	end)
end

local ObsStateUpdate = Events:WaitForChild("ObservationHakiStateUpdate", 5)
if ObsStateUpdate then
	ObsStateUpdate.OnClientEvent:Connect(function(plr, state)
	if plr == Players.LocalPlayer then
		ObsState.Active = state
	end
end)
end
end
end)

-- Mobile Support Logic
local WindowSize = UDim2.fromOffset(580, 460)
if UserInputService.TouchEnabled then
	WindowSize = UDim2.fromOffset(480, 320)
end

local WindowTitle = "[👑Fate Update💫] Sailor Piece Script v.2.7"

local Window = Fluent:CreateWindow({
Title = WindowTitle,
SubTitle = "By.Lume Dev",
TabWidth = 160,
Size = WindowSize,
Theme = "Dark",
MinimizeKey = Enum.KeyCode.RightControl
})

--// ===== GUI =====
task.spawn(function()
local PlayerGui = Player:WaitForChild("PlayerGui", 5)
if not PlayerGui then return end

local ToggleGui = PlayerGui:FindFirstChild("LCtrlCircleButtonUI")
if not ToggleGui then
	ToggleGui = Instance.new("ScreenGui")
	ToggleGui.Name = "LCtrlCircleButtonUI"
	ToggleGui.ResetOnSpawn = false
	ToggleGui.Parent = PlayerGui
end

local imageUrl = "https://img5.pic.in.th/file/secure-sv1/LOGO53b6b29441d25fb0.png"
local imageName = "CustomLogo_Toggle.png" -- ชื่อไฟล์ที่จะเซฟลงในโฟลเดอร์ workspace ของตัวรัน
local customImageId = ""

if isfile and writefile and getcustomasset then
    if not isfile(imageName) then
        local success, result = pcall(function()
            return game:HttpGet(imageUrl)
        end)
        
        if success then
            writefile(imageName, result)
        else
            warn("ไม่สามารถดาวน์โหลดรูปภาพได้")
        end
    end
    
    if isfile(imageName) then
        customImageId = getcustomasset(imageName)
    end
else
    warn("ตัวรันสคริปต์ของคุณไม่รองรับการดึงรูปจากเว็บภายนอก")
end

local Button = ToggleGui:FindFirstChild("ToggleButton") 

if not Button then
    Button = Instance.new("ImageButton")
    Button.Name = "ToggleButton"
    Button.Size = UDim2.new(0, 60, 0, 60)
    
    Button.AnchorPoint = Vector2.new(0.5, 0.5) 
    Button.Position = UDim2.new(0.3, 0, 0.2, 0)
    
    Button.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    Button.BackgroundTransparency = 0
    Button.BorderSizePixel = 0 -- ปล่อยเป็น 0 ไว้เหมือนเดิมถูกต้องแล้วครับ
    Button.ZIndex = 10
    Button.Active = true
    Button.Draggable = true 

    -- [เพิ่มส่วนนี้เข้าไป] สร้างเส้นขอบ (Border) ด้วย UIStroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 0) -- กำหนดสีของเส้นขอบ (ตอนนี้เป็นสีขาว)
    UIStroke.Thickness = 2 -- กำหนดความหนาของเส้นขอบ (เปลี่ยนตัวเลขได้ตามต้องการ)
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- ให้เส้นขอบวาดออกไปด้านนอก
    UIStroke.Parent = Button
    
    -- ใส่รูปที่ดึงมาจากลิงก์
    if customImageId ~= "" then
        Button.Image = customImageId
    end

    Button.Parent = ToggleGui

    -- ทำขอบโค้ง 8 พิกเซล
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8) 
    UICorner.Parent = Button

    -- ระบบคลิก
    Button.MouseButton1Click:Connect(function()
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            if Window then
                Window:Minimize()
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end
end)

local Tabs = {
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
Boss = Window:AddTab({ Title = "Boss", Icon = "crown" }),
Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "skull" }),
Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

_G.SpeedEnabled = false
_G.InfJumpEnabled = false
_G.ESPEnabled = false
_G.AutoEquipEnabled = false
_G.AutoMobFarm = false
_G.AutoBossFarm = false
_G.AutoSkill = false
_G.SelectedWeaponGroup = "Combat"
_G.SelectedMob = nil
_G.SelectedBosses = {}
_G.FarmPosition = "Behind"
_G.SelectedSkills = {}
_G.AutoSummon = false
_G.AutoKillSummon = false
_G.SelectedSummonBoss = "None"
_G.HasWarpedToSummon = false
_G.BossCycleIndex = 1
_G.NextTeleportTime = 0
_G.SelectIslandTP = nil
_G.SelectNPCTP = nil
_G.AntiAFK = true
_G.BossIsActive = false
_G.CheckingBosses = false
_G.LastActiveAttack = 0 -- สำหรับ Smart Skill

-- ==========================================
-- DATA CONFIG
-- ==========================================

local WeaponGroups = {
["Combat"] = { "Combat" , "Gojo" , "Sukuna", "Qin Shi","Yuji","Strongest Of Today","Strongest In History","Alucard","Madoka","Gilgamesh","Anos" },
["Sword"] = { "Katana", "Dark Blade", "Ragna", "Saber", "Jinwoo" , 'Aizen' , "Shadow","Ichigo","Rimuru","Shadow Monarch" }
}

local MobData = {
["Thief (Lv. 10)"] = { QuestNPC = "QuestNPC1", MobNames = {"Thief1", "Thief2", "Thief3", "Thief4", "Thief5"}, Island = "StarterIsland" },
["Thief Boss (Lv. 25)"] = { QuestNPC = "QuestNPC2", MobNames = {"ThiefBoss"}, Island = "StarterIsland" },
["Monkey (Lv. 250)"] = { QuestNPC = "QuestNPC3", MobNames = {"Monkey1","Monkey2","Monkey3","Monkey4","Monkey5"}, Island = "JungleIsland" },
["Monkey Boss (Lv. 500)"] = { QuestNPC = "QuestNPC4", MobNames = {"MonkeyBoss"}, Island = "JungleIsland" },
["Desert Bandit (Lv. 750)"] = { QuestNPC = "QuestNPC5", MobNames = {"DesertBandit1","DesertBandit2","DesertBandit3","DesertBandit4","DesertBandit5"}, Island = "DesertIsland" },
["Desert Boss (Lv. 1000)"] = { QuestNPC = "QuestNPC6", MobNames = {"DesertBoss"}, Island = "DesertIsland" },
["Frost Rogue (Lv. 1500)"] = { QuestNPC = "QuestNPC7", MobNames = {"FrostRogue1","FrostRogue2","FrostRogue3","FrostRogue4","FrostRogue5"}, Island = "SnowIsland" },
["Snow Boss (Lv. 2000)"] = { QuestNPC = "QuestNPC8", MobNames = {"SnowBoss"}, Island = "SnowIsland" },
["Sorcerer Student (Lv. 3000)"] = { QuestNPC = "QuestNPC9", MobNames = {"Sorcerer1","Sorcerer2","Sorcerer3","Sorcerer4","Sorcerer5"}, Island = "ShibuyaStation" },
["Panda Boss (Lv. 4000)"] = { QuestNPC = "QuestNPC10", MobNames = {"PandaMiniBoss"}, Island = "ShibuyaStation" },
["Hollow (Lv. 5000)"] = { QuestNPC = "QuestNPC11", MobNames = {"Hollow1","Hollow2","Hollow3","Hollow4","Hollow5"}, Island = "HuecoMundoIsland" },
["Strong Sorcerer (Lv. 6000)"] = { QuestNPC = "QuestNPC12", MobNames = {"StrongSorcerer1","StrongSorcerer2","StrongSorcerer3","StrongSorcerer4","StrongSorcerer5"}, Island = "ShibuyaDestroyed" },
["Curse (Lv. 7000)"] = { QuestNPC = "QuestNPC13", MobNames = {"Curse1","Curse2","Curse3","Curse4","Curse5"}, Island = "ShibuyaDestroyed" },
["Slime (Lv. 8000)"] = { QuestNPC = "QuestNPC14", MobNames = {"Slime1","Slime2","Slime3","Slime4","Slime5"}, Island = "SlimeIsland" },
["Academy Teacher (Lv. 9000)"] = { QuestNPC = "QuestNPC15", MobNames = {"AcademyTeacher1","AcademyTeacher2","AcademyTeacher3","AcademyTeacher4","AcademyTeacher5"}, Island = "AcademyIsland" }
}

local BossList = { "AlucardBoss", "JinwooBoss", "SukunaBoss", "YujiBoss", "AizenBoss", "GojoBoss" }

local BossPositions = {
["YujiBoss"] = CFrame.new(1537.92871, 12.9861355, 226.108246),
["SukunaBoss"] = CFrame.new(1571.26672, 80.2205353, -34.1126976),
["JinwooBoss"] = CFrame.new(248.741516, 15.0932388, 927.542053),
["AlucardBoss"] = CFrame.new(248.741516, 15.0932388, 927.542053),
["GojoBoss"] = CFrame.new(1858.32666, 15.9861355, 338.140015),
["AizenBoss"] = CFrame.new(-567.223083, 2.57872534, 1228.49036)
}

local SummonBossList = { "None", "IchigoBoss", "SaberBoss", "QinShiBoss" }

local SkillMap = { ["Z"] = 1, ["X"] = 2, ["C"] = 3, ["V"] = 4, ["F"] = 5 }

local IslandTeleports = {
["SnowIsland"] = CFrame.new(-234.127533, -1.80199099, -979.563721, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065),
["ShibuyaStation"] = CFrame.new(1359.47205, 10.5156441, 249.582214, 0.978984475, -0, -0.203934819, 0, 1, -0, 0.203934819, 0, 0.978984475),
["SailorIsland"] = CFrame.new(235.137619, 3.10643435, 659.73407, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
["JungleIsland"] = CFrame.new(-446.587311, -3.56074214, 368.797546, 0.848060429, -0, -0.529899538, 0, 1, -0, 0.529899538, 0, 0.848060429),
["DesertIsland"] = CFrame.new(-694.385681, -2.13288236, -348.545624, 0.984812498, -0, -0.173621148, 0, 1, -0, 0.173621148, 0, 0.984812498),
["Boss Island"] = CFrame.new(620.293579, -1.53785121, -1055.65271, 0.694649816, 0, 0.719348073, 0, 1, 0, -0.719348073, 0, 0.694649816),
["StarterIsland"] = CFrame.new(-94.7449417, -1.98583961, -244.801849, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376),
["HuecoMundoIsland"] = CFrame.new(-482.868896, -2.05866098, 936.237061, 0.838688612, -0, -0.544611216, 0, 1, -0, 0.544611216, 0, 0.838688612),
["ShibuyaDestroyed"] = CFrame.new(365.327393, -0.669448137, -1633.19067, 0.99977088, 0, 0.0214066338, 0, 1, 0, -0.0214066338, 0, 0.99977088),
["SlimeIsland"] = CFrame.new(-985.487488, 3.66299438, 254.98291, 0.842490435, 0, 0.538711369, 0, 1, 0, -0.538711369, 0, 0.842490435),
["AcademyIsland"] = CFrame.new(1040.29395, -2.02119446, 1088.76904, 0.927179396, 0, 0.374617696, 0, 1, 0, -0.374617696, 0, 0.927179396),
["DungeonIsland"] = CFrame.new(1298, 4, -841, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local SlimeLocations = {
["Slime #1"] = CFrame.new(-855.035645, -0.668930054, -321.864471, 0.173624337, 0, 0.984811902, 0, 1, 0, -0.984811902, 0, 0.173624337),
["Slime #2"] = CFrame.new(-434.946747, 20.9471989, -1183.79749, -0.92051065, 0, -0.390717506, 0, 1, 0, 0.390717506, 0, -0.92051065),
["Slime #3"] = CFrame.new(61.1317139, 32.3345795, -144.244934, -0.0814757347, -0.165915847, 0.982768416, -0.000830069184, 0.98605758, 0.16640234, -0.996675014, 0.0127419755, -0.0804774761),
["Slime #4"] = CFrame.new(-583.711487, 54.8365974, 317.217133, -0.528159916, -0.346896499, -0.775054812, -0.00456225872, 0.913893461, -0.405928463, 0.849132717, -0.21085912, -0.484264493),
["Slime #5"] = CFrame.new(1744.80322, 6.84498835, 494.509399, 0.141693771, 0, 0.989910543, 0, 1, 0, -0.989910543, 0, 0.141693771),
["Slime #6"] = CFrame.new(-435.404419, 23.0172634, 1399.24365, -0.324690163, 0.16521655, 0.931278586, -0.0145941973, 0.983632803, -0.179592893, -0.945707858, -0.0719033182, -0.316964686),
["Slime #7"] = CFrame.new(787.80127, 64.3216553, -2309.12842, -0.196157262, 0.654697776, -0.72999537, 0.06376867, 0.751399636, 0.656758904, 0.97849679, 0.0822771788, -0.189141691),
}

local DemoniteLocations = {
["Demonite #1"] = CFrame.new(1006.00696, 11.7496796, 1130.03369, 0.427068621, -0.161282077, 0.889719307, -0.0035789907, 0.983654976, 0.180028006, -0.904212117, -0.0800686479, 0.419510931),
["Demonite #2"] = CFrame.new(920.795715, 70.3931427, 1478.13025, 0.725795209, -0.576960802, 0.374616534, 0.622277141, 0.782796979, -7.01099634e-06, -0.29324463, 0.233120382, 0.927179873),
}

local NPCTeleports = {
["Dark Blade NPC"] = CFrame.new(-132.496948, 14.7835255, -1091.26355, -0.439278364, 0.016457051, -0.898200333, -0.0298291016, 0.999013662, 0.0328925289, 0.897855699, 0.0412414782, -0.438354224),
["Haki Trainer"] = CFrame.new(-497.93924, 23.6579151, -1252.6405, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065),
["RagnaBuyer"] = CFrame.new(-272.070862, -4.23535013, -1353.33777, 0.715659618, -0, -0.698449254, 0, 1, -0, 0.698449254, 0, 0.715659618),
["RagnaQuestlineBuff"] = CFrame.new(-261.790833, -4.23535013, -1436.71252, 0.715659618, -0, -0.698449254, 0, 1, -0, 0.698449254, 0, 0.715659618),
["SummonBossNPC"] = CFrame.new(692.040527, -3.67419362, -1085.31812, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051),
["EnchantNPC"] = CFrame.new(1415.31274, 8.84003067, 7.40811729, -0.989795089, 0, 0.142497987, 0, 1, 0, -0.142497987, 0, -0.989795089),
["GojoNpc"] = CFrame.new(1741.59265, 157.300507, 514.805054, -0.305511117, 0.00515563227, -0.952174604, 0.0269237738, 0.999632299, -0.00322606321, 0.951807797, -0.0266217291, -0.305537581),
["SukunaNpc"] = CFrame.new(1325.80103, 162.85965, -34.6844749, 0.142420411, -0.0172595233, 0.989655793, -3.65991145e-05, 0.999847889, 0.0174425393, -0.989806235, -0.00252039498, 0.142398119),
["Jinwoo Npc"] = CFrame.new(91.2260056, 2.98423171, 1097.46631, -0.819854856, -0.00342408568, 0.572561085, -0.0105738947, 0.999902129, -0.00916113332, -0.572473705, -0.0135650001, -0.819810867),
["TitleNpc"] = CFrame.new(369.152405, 2.79983521, 783.487427, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
["Random Fruit (Gem)"] = CFrame.new(400.641937, 2.79983521, 752.175842, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
["Random Fruit (Coin)"] = CFrame.new(408.244568, 2.82981968, 802.734131, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
["StorageNpc"] = CFrame.new(329.949493, 2.94520569, 764.059326, 0.15644598, -0, -0.987686574, 0, 1, -0, 0.987686574, 0, 0.15644598),
["TraitsNpc"] = CFrame.new(337.284302, 2.79983521, 813.846558, 0.15644598, -0, -0.987686574, 0, 1, -0, 0.987686574, 0, 0.15644598),
["AizenNpc"] = CFrame.new(-346.134552, 12.9912338, 1402.1001, -0.510350227, 0, -0.859966636, 0, 1, 0, 0.859966636, 0, -0.510350227),
["AizenQuestBuff"] = CFrame.new(-892.005066, 24.7202606, 1229.99414, -0.173624277, 0, 0.984811902, 0, 1, 0, -0.984811902, 0, -0.173624277),
["ObservationBuyer"] = CFrame.new(-713.182922, 12.1339779, -527.289795, -0.984812617, 0, 0.173621148, 0, 1, 0, -0.173621148, 0, -0.984812617),
["ArtifactsUnlocker"] = CFrame.new(-440.516388, 1.77979147, -1095.86072, -0.92051065, 0, -0.390717506, 0, 1, 0, 0.390717506, 0, -0.92051065),
["YujiBuyerNPC"] = CFrame.new(1240.19263, 136.700775, 408.188354, -0.35190773, 0, 0.936034739, 0, 1, 0, -0.936034739, 0, -0.35190773),
["RerollStatNPC"] = CFrame.new(373.071747, 2.79983521, 810.098328, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
["Merchant"] = CFrame.new(368.817719, 2.79983521, 783.589844, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
["ShadowQuestlineBuff"]= CFrame.new(335.123474, 25.5055599, -377.073486, 0.690896153, -0.0138966013, -0.722820461, 0.000865913928, 0.999830425, -0.0183945931, 0.722953498, 0.0120828543, 0.690791011),
["CidBuyer"]= CFrame.new(1428.22986, 49.2211456, -976.904297, 0.906293869, 0.0733761713, -0.416230023, -4.76837158e-07, 0.984814584, 0.173609525, 0.422648191, -0.157341033, 0.892531395),
["AlucardBuyer"] = CFrame.new(476.07724, 2.79983521, 1037.76819, -0.987686276, 0, -0.156449571, 0, 1, 0, 0.156449571, 0, -0.987686276),
["BlessingNPC"] = CFrame.new(1420.94788, 8.84003162, 11.2125807, -0.989795089, 0, 0.142497987, 0, 1, 0, -0.142497987, 0, -0.989795089),
["AscendNPC"] = CFrame.new(252.082169, 4.08967924, 715.554565, -0.987686276, 0, -0.156449571, 0, 1, 0, 0.156449571, 0, -0.987686276),
["StrongestinHistoryBuyer"] = CFrame.new(738.620239, 89.1463165, -1895.94141, -0.850047231, 0.0821449012, -0.520262122, -0.0121909715, 0.984430373, 0.175351709, 0.526566029, 0.15539968, -0.8358109),
["StrongestofTodayBuyer"] = CFrame.new(165.185959, 148.998184, -2656.6604, 0.834040165, -0.141939372, 0.533132434, 0.175327957, 0.984434605, -0.01219308, -0.523103356, 0.103642538, 0.845943928),
["SukunaCraftNPC"] = CFrame.new(691.379395, 1.88211524, -1991.82959, -0.0557233095, 0, -0.998446226, 0, 1, 0, 0.998446226, 0, -0.0557233095),
["SukunaMasteryNPC"] = CFrame.new(594.131226, 30.152832, -2016.31396, 0.974407971, 0.0493175313, -0.219310075, 0.000219687819, 0.975426316, 0.220325932, 0.224786729, -0.214735523, 0.950452328),
["GojoCraftNPC"] = CFrame.new(-122.008728, 1.88212693, -2094.93726, 0.778239131, 0, 0.627968073, 0, 1, 0, -0.627968073, 0, 0.778239131),
["GojoMasteryNPC"] = CFrame.new(56.1712189, 39.0576324, -2064.20288, 0.756504416, -0.0179738849, 0.653741717, -0.306518704, 0.873283803, 0.378710806, -0.5777089, -0.486880362, 0.655133545),
["ConquerorHakiNPC"] = CFrame.new(1942.71753, 144.406006, -24.579298, -0.142484665, 0.0016960036, -0.989795566, 3.05299181e-07, 0.99999851, 0.00171344238, 0.989796996, 0.000243837188, -0.142484426),
["SlimeCraftNPC"] = CFrame.new(-1167.46204, 8.50944901, 173.572083, -0.898167968, 0, -0.439652443, 0, 1, 0, 0.439652443, 0, -0.898167968),
["RimuruBuyer"] = CFrame.new(-1539.56653, 9.42505264, 66.1064453, 0.552865744, 0, 0.833270311, 0, 1, 0, -0.833270311, 0, 0.552865744),
["RimuruMasteryNPC"] = CFrame.new(-1324.74353, 21.1937218, 527.840942, -0.979686379, 0, 0.20053567, 0, 1, 0, -0.20053567, 0, -0.979686379),
["ShadowMonarchBuyerNPC"] =  CFrame.new(1463.05493, 48.956459, -901.405945, -0.913537383, 0.0706406906, -0.40057379, 1.52811408e-05, 0.984810054, 0.173635185, 0.406754792, 0.158616096, -0.899661899),
["ShadowMonarchQuestlineBuff"] =  CFrame.new(243.936356, 26.6213665, -83.2128372, -0.698652267, -0.152592182, -0.698999822, 0.026632756, 0.970767677, -0.238538831, 0.714965641, -0.185271978, -0.67416513),
}

-- ==========================================
-- FUNCTIONS (ฟังก์ชันระบบ)
-- ==========================================

local function CanAcceptQuest()
	local canAccept = true
	pcall(function()
	local playerGui = Player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local questUI = playerGui:FindFirstChild("QuestUI")
	if not questUI then return end

	local questFrame = questUI:FindFirstChild("Quest")
	if questFrame and questFrame.Visible == false then
		return
	end

	local reqText = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestRequirement.ContentText
	if reqText and reqText ~= "" then
		local current, max = string.match(reqText, "(%d+)/(%d+)")
		if current and max then
			if tonumber(current) < tonumber(max) then
				canAccept = false
			end
		end
	end
end)
return canAccept
end

local function TeleportTo(cframe)
	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character.HumanoidRootPart.CFrame = cframe
	end
end

local function GetFarmCFrame(targetRoot)
	if _G.FarmPosition == "Behind" then
		return targetRoot.CFrame * CFrame.new(0, 0, 4)
	else
		local topPosition = targetRoot.Position + Vector3.new(0, 12, 0)
		return CFrame.new(topPosition) * CFrame.Angles(math.rad(-90), 0, 0)
	end
end

local hitCooldown = false
local function RequestHit()
	if HitRemote and not hitCooldown then
		hitCooldown = true
		pcall(function()
		HitRemote:FireServer()
		_G.LastActiveAttack = tick()
	end)
	-- ปรับความหน่วงของ Normal คืนเป็น 0.15 เพื่อให้จังหวะตีช้าลงและเสถียรขึ้น
	task.delay(0.15, function()
	hitCooldown = false
end)
end
end

RunService.Stepped:Connect(function()
pcall(function()
local char = Player.Character
if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
	local root = char.HumanoidRootPart
	local hum = char.Humanoid

	local isFarming = false
	if Options then
		if (Options.AutoMobFarm and Options.AutoMobFarm.Value) or
		(Options.AutoBossFarm and Options.AutoBossFarm.Value) or
		(Options.AutoFarmAllMob and Options.AutoFarmAllMob.Value) or
		(Options.AutoFarmSpecificLoop and Options.AutoFarmSpecificLoop.Value) or
		(Options.AutoEventFarm and Options.AutoEventFarm.Value) or
		(Options.AutoKillSummon and Options.AutoKillSummon.Value) or
		(Options.AutoKillBossV2 and Options.AutoKillBossV2.Value) or
		(Options.AutoKillBossAnos and Options.AutoKillBossAnos.Value) or
		(Options.AutoKillGilgamesh and Options.AutoKillGilgamesh.Value) or
		(Options.AutoEventFarmV3 and Options.AutoEventFarmV3.Value) or
		(Options.AutoFarmLevel and Options.AutoFarmLevel.Value) or
		(Options.AutoKillRimuru and Options.AutoKillRimuru.Value) or
		(Options.AutoQuestHaki and Options.AutoQuestHaki.Value) or
		(Options.AutoQuestJinwoo and Options.AutoQuestJinwoo.Value) or
		(Options.AutoKillHollow250 and Options.AutoKillHollow250.Value) or
		(Options.StartKillDungeon and Options.StartKillDungeon.Value) or
		(Options.AutoFarmArtifacts and Options.AutoFarmArtifacts.Value) then
			isFarming = true
		end
	end

	if isFarming then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		if _G.FarmPosition == "Above" then
			hum.PlatformStand = true
		else
			hum.PlatformStand = false
		end
	else
		if hum.PlatformStand then
			hum.PlatformStand = false
		end
	end
end
end)
end)

local function IsRimuruAlive()
	local searchLocations = {workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies")}
	for _, loc in pairs(searchLocations) do
		if loc then
			for _, v in pairs(loc:GetChildren()) do
				if string.find(v.Name, "Rimuru") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
					return true
				end
			end
		end
	end
	return false
end

local function CheckBossStatus(bossName)
	local npcFolder = workspace:FindFirstChild("NPCs")
	if not npcFolder then return nil, false end

	local boss = npcFolder:FindFirstChild(bossName)
	if not boss then return nil, false end

	local ready = boss:GetAttribute("_NPCReady")
	local humanoid = boss:FindFirstChildOfClass("Humanoid")
	local root = boss:FindFirstChild("HumanoidRootPart")

	if ready == true and humanoid and root and humanoid.Health > 0 then
		return boss, true
	end
	return boss, false
end

local function GetAliveBoss(selectedBosses)
	local npcFolder = workspace:FindFirstChild("NPCs")
	if not npcFolder then return nil end
	if not selectedBosses then return nil end

	for bossName, isSelected in pairs(selectedBosses) do
		if isSelected then
			local boss = npcFolder:FindFirstChild(bossName)
			if boss then
				local humanoid = boss:FindFirstChildOfClass("Humanoid")
				local root = boss:FindFirstChild("HumanoidRootPart")
				local ready = boss:GetAttribute("_NPCReady")

				if humanoid and root and humanoid.Health > 0 and ready == true then
					return boss
				end
			end
		end
	end
	return nil
end

local function IsAnySelectedBossAlive()
	local result = false
	pcall(function()
	if Options and Options.AutoBossFarm and Options.AutoBossFarm.Value and Options.SelectBoss and type(Options.SelectBoss.Value) == "table" then
		local activeBoss = GetAliveBoss(Options.SelectBoss.Value)
		if activeBoss then
			_G.BossIsActive = true
			result = true
		end
	end
end)
return result
end

Player.CharacterAdded:Connect(function(char)
task.wait(2)
if Options.AutoHaki.Value then
	local remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("HakiRemote")
	if remote then
		remote:FireServer("GetStatus")
		task.wait(0.5)
		if not HakiState.Active then
			remote:FireServer("Toggle")
		end
	end
end
end)

RunService.RenderStepped:Connect(function()
if _G.SpeedEnabled then
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		Player.Character.Humanoid.WalkSpeed = 160
	end
end
end)

UserInputService.JumpRequest:Connect(function()
if _G.InfJumpEnabled then
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		Player.Character.Humanoid:ChangeState("Jumping")
	end
end
end)

local function CreateESP(plr)
	if plr == Player then return end
	local function UpdateESP()
		if not plr.Character then return end
		local RootPart = plr.Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = plr.Character:FindFirstChild("Humanoid")
		if RootPart and Humanoid and Humanoid.Health > 0 then
			if not plr.Character:FindFirstChild("LumeESP_Box") then
				local Highlight = Instance.new("Highlight")
				Highlight.Name = "LumeESP_Box"
				Highlight.FillTransparency = 1
				Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				Highlight.OutlineTransparency = 0
				Highlight.Parent = plr.Character

				local Billboard = Instance.new("BillboardGui")
				Billboard.Name = "LumeESP_Text"
				Billboard.Adornee = RootPart
				Billboard.Size = UDim2.new(0, 200, 0, 50)
				Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
				Billboard.AlwaysOnTop = true

				local Label = Instance.new("TextLabel")
				Label.Parent = Billboard
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(1, 0, 1, 0)
				Label.TextStrokeTransparency = 0
				Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				Label.Font = Enum.Font.SourceSansBold
				Label.TextSize = 14

				Billboard.Parent = plr.Character
				task.spawn(function()
				while plr.Character and plr.Character:FindFirstChild("LumeESP_Text") and _G.ESPEnabled do
					local dist = (Player.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude
					Label.Text = string.format("%s\n[ %.0f M ]", plr.Name, dist)
					task.wait(0.1)
				end
			end)
		end
	end
end
plr.CharacterAdded:Connect(function(char)
if _G.ESPEnabled then
	char:WaitForChild("HumanoidRootPart")
	task.wait(0.5)
	UpdateESP()
end
end)
if plr.Character then UpdateESP() end
end

local function ClearESP()
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr.Character then
			if plr.Character:FindFirstChild("LumeESP_Box") then plr.Character.LumeESP_Box:Destroy() end
			if plr.Character:FindFirstChild("LumeESP_Text") then plr.Character.LumeESP_Text:Destroy() end
		end
	end
end

local function EquipWeapon(groupName)
	if not _G.AutoEquipEnabled then return end
	if not Player.Character then return end
	local humanoid = Player.Character:FindFirstChild("Humanoid")
	if not humanoid then return end
	local targetWeapons = WeaponGroups[groupName] or {groupName}
	for _, name in ipairs(targetWeapons) do
		local equipped = Player.Character:FindFirstChild(name)
		if equipped then return end
	end
	if Player:FindFirstChild("Backpack") then
		for _, name in ipairs(targetWeapons) do
			local tool = Player.Backpack:FindFirstChild(name)
			if tool then humanoid:EquipTool(tool) return end
		end
	end
end

-- ==========================================
-- UI SECTION
-- ==========================================

Tabs.Main:AddSection("Main Features")

local Disable3DToggle = Tabs.Main:AddToggle("Disable3DRender", {Title = "White Screen", Default = false })
Disable3DToggle:OnChanged(function(Value)
	pcall(function()
		-- สั่งปิดหรือเปิดการ Render ของ Engine ทันที (ลด GPU 100%)
		game:GetService("RunService"):Set3dRenderingEnabled(not Value)
	end)
end)

SpeedToggle = Tabs.Main:AddToggle("SpeedHack", {Title = "Speedhack", Default = false })
SpeedToggle:OnChanged(function()
_G.SpeedEnabled = SpeedToggle.Value
if not SpeedToggle.Value and Player.Character and Player.Character:FindFirstChild("Humanoid") then
	Player.Character.Humanoid.WalkSpeed = 16
end
end)

InfJumpToggle = Tabs.Main:AddToggle("InfJump", {Title = "Infinity Jump", Default = false })
InfJumpToggle:OnChanged(function() _G.InfJumpEnabled = InfJumpToggle.Value end)

ESPToggle = Tabs.Main:AddToggle("ESPPlayer", {Title = "ESP Player", Default = false })
ESPToggle:OnChanged(function()
_G.ESPEnabled = ESPToggle.Value
if ESPToggle.Value then
	for _, plr in pairs(game.Players:GetPlayers()) do CreateESP(plr) end
	game.Players.PlayerAdded:Connect(CreateESP)
else
	ClearESP()
end
end)

Tabs.Main:AddSection("Auto Haki")

AutoHakiToggle = Tabs.Main:AddToggle("AutoHaki", {Title = "Auto Haki", Default = false })
AutoObservationHakiToggle = Tabs.Main:AddToggle("AutoObservationHaki", {Title = "Auto Observation", Default = false })
AutoConquerorHakiToggle = Tabs.Main:AddToggle("AutoConquerorHaki", {Title = "Auto Haki Conqueror", Default = false })

AutoHakiToggle:OnChanged(function()
if Options.AutoHaki.Value then
	if not HakiState.Active then
		local remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("HakiRemote")
		if remote then remote:FireServer("Toggle") end
	end
end
end)

Tabs.AutoFarm:AddSection("Weapon Settings")
WeaponDropdown = Tabs.AutoFarm:AddDropdown("SelectWeapon", { Title = "Select Weapon", Values = {"Combat", "Sword"}, Multi = false, Default = 1 })
WeaponDropdown:OnChanged(function(Value) _G.SelectedWeaponGroup = Value end)

AutoEquipToggle = Tabs.AutoFarm:AddToggle("AutoEquip", {Title = "Auto Equip Weapon", Default = false })
AutoEquipToggle:OnChanged(function()
_G.AutoEquipEnabled = AutoEquipToggle.Value
task.spawn(function()
while _G.AutoEquipEnabled do
	task.wait(0.5)
	pcall(function() if _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end end)
end
end)
end)

Tabs.AutoFarm:AddSection("Mob Farm")
local MobKeys = {}
for key, _ in pairs(MobData) do table.insert(MobKeys, key) end
table.sort(MobKeys, function(a, b)
local levelA = tonumber(string.match(a, "Lv%.%s*(%d+)")) or 0
local levelB = tonumber(string.match(b, "Lv%.%s*(%d+)")) or 0
return levelA < levelB
end)

MobDropdown = Tabs.AutoFarm:AddDropdown("SelectMob", { Title = "Select Mob", Values = MobKeys, Multi = false, Default = 1 })
MobDropdown:OnChanged(function(Value)
_G.SelectedMob = Value
if QuestAbandonRemote then QuestAbandonRemote:FireServer("repeatable") end
end)

AutoMobToggle = Tabs.AutoFarm:AddToggle("AutoMobFarm", {Title = "Auto Farm", Default = false })
AutoMobToggle:OnChanged(function()
_G.AutoMobFarm = AutoMobToggle.Value
if _G.AutoMobFarm then
	task.spawn(function()
	pcall(function()
	local currentData = MobData[_G.SelectedMob]
	if currentData and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		if currentData.Island and IslandTeleports[currentData.Island] then
			TeleportTo(IslandTeleports[currentData.Island])
			task.wait(0.5)
		end
	end
end)

while _G.AutoMobFarm do
	task.wait(0.1)
	if _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then continue end
	pcall(function()
	local currentData = MobData[_G.SelectedMob]
	if currentData and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		if QuestAcceptRemote and CanAcceptQuest() then
			QuestAcceptRemote:FireServer(unpack({ currentData.QuestNPC }))
			task.wait(0.2)
		end

		local targetMob = nil
		local NPCs = workspace:FindFirstChild("NPCs")
		if NPCs then
			for _, child in pairs(NPCs:GetChildren()) do
				if table.find(currentData.MobNames, child.Name) and child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child:FindFirstChild("HumanoidRootPart") then
					targetMob = child
					break
				end
			end
		end

		if targetMob then
			local farmCFrame = GetFarmCFrame(targetMob.HumanoidRootPart)
			TeleportTo(farmCFrame)

			if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
			RequestHit()
		else
			local targetPos = nil
			if currentData.Island and IslandTeleports[currentData.Island] then
				targetPos = IslandTeleports[currentData.Island]
			end

			if targetPos then
				local dist = (Player.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
				if dist > 500 then
					TeleportTo(targetPos)
				end
			end
		end
	end
end)
end
end)
end
end)

-- ==========================================
-- Auto Farm Level System
-- ==========================================

local function GetCurrentMobKey()
	local player = game:GetService("Players").LocalPlayer
	local levelFolder = player:FindFirstChild("Data") or player:FindFirstChild("leaderstats")
	local level = 0
	if levelFolder and levelFolder:FindFirstChild("Level") then
		level = levelFolder.Level.Value
	end

	if level >= 9000 then return "Academy Teacher (Lv. 9000)"
elseif level >= 8000 then return "Slime (Lv. 8000)"
elseif level >= 7000 then return "Curse (Lv. 7000)"
elseif level >= 6000 then return "Strong Sorcerer (Lv. 6000)"
elseif level >= 5000 then return "Hollow (Lv. 5000)"
elseif level >= 4000 then return "Panda Boss (Lv. 4000)"
elseif level >= 3000 then return "Sorcerer Student (Lv. 3000)"
elseif level >= 2000 then return "Snow Boss (Lv. 2000)"
elseif level >= 1500 then return "Frost Rogue (Lv. 1500)"
elseif level >= 1000 then return "Desert Boss (Lv. 1000)"
elseif level >= 750 then return "Desert Bandit (Lv. 750)"
elseif level >= 500 then return "Monkey Boss (Lv. 500)"
elseif level >= 250 then return "Monkey (Lv. 250)"
elseif level >= 25 then return "Thief Boss (Lv. 25)"
else return "Thief (Lv. 10)"
end
end

local function GetCurrentMobData()
	local key = GetCurrentMobKey()
	return MobData[key]
end

local lastAutoLevelQuest = nil
AutoFarmLevelToggle = Tabs.AutoFarm:AddToggle("AutoFarmLevel", { Title = "Auto Farm Level (ฟาร์มตามเลเวลอัตโนมัติ)",  Default = false })

-- รีเซ็ตค่าเควสเมื่อกดปิด-เปิดใหม่
AutoFarmLevelToggle:OnChanged(function(Value)
    if not Value then
        lastAutoLevelQuest = nil
    end
end)

task.spawn(function()
while true do
	task.wait(0.1)

	if Options.AutoFarmLevel and Options.AutoFarmLevel.Value then
		if _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then
			task.wait(0.5)
			continue
		end

		pcall(function()
		local currentData = GetCurrentMobData()
		local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

		if currentData and myRoot then
			-- [แก้ไข] ตรวจสอบว่าต้องเปลี่ยนเควส (เลเวลอัพเปลี่ยนมอน)
			if lastAutoLevelQuest ~= currentData.QuestNPC then
				if QuestAbandonRemote then
                    -- ยิงคำสั่งยกเลิกเควสทุกรูปแบบเพื่อความชัวร์
					QuestAbandonRemote:FireServer("repeatable")
                    if lastAutoLevelQuest then
                        QuestAbandonRemote:FireServer(lastAutoLevelQuest)
                    end
                    QuestAbandonRemote:FireServer()
                    
					task.wait(0.8) -- หน่วงเวลาให้เซิร์ฟเวอร์ยกเลิกเควสเก่าให้เสร็จก่อน
				end
				lastAutoLevelQuest = currentData.QuestNPC
			end

			if currentData.Island and IslandTeleports[currentData.Island] then
				local targetIslandCFrame = IslandTeleports[currentData.Island]
				if (myRoot.Position - targetIslandCFrame.Position).Magnitude > 500 then
					TeleportTo(targetIslandCFrame)
					task.wait(0.5)
				end
			end

			-- รับเควสใหม่
			if QuestAcceptRemote and CanAcceptQuest() then
				QuestAcceptRemote:FireServer(currentData.QuestNPC)
				task.wait(0.2)
			end

			local targetMob = nil
			local minDst = math.huge
			local searchLocations = { workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Npcs") }

			for _, folder in pairs(searchLocations) do
				if folder then
					for _, v in pairs(folder:GetChildren()) do
						if table.find(currentData.MobNames, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
							local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
							if dst < minDst then
								minDst = dst
								targetMob = v
							end
						end
					end
				end
			end

			if targetMob then
				local farmCFrame = GetFarmCFrame(targetMob.HumanoidRootPart)
				TeleportTo(farmCFrame)
				if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
				RequestHit()
			end
		end
	end)
else
	task.wait(0.5)
end
end
end)
PositionDropdown = Tabs.AutoFarm:AddDropdown("SelectPosition", { Title = "Farm Position (ตำแหน่งฟาร์ม)", Values = {"Behind", "Above"}, Multi = false, Default = 1 })
PositionDropdown:OnChanged(function(Value) _G.FarmPosition = Value end)

Tabs.AutoFarm:AddSection("All Mob Farm")

-- เพิ่ม Dropdown ให้เลือกความเร็วใน All Mob Farm
_G.AllMobFarmSpeed = "Normal"
AllMobFarmSpeedDropdown = Tabs.AutoFarm:AddDropdown("AllMobFarmSpeed", {
	Title = "Farm Speed (ความเร็ว)",
	Values = {"Normal", "Fast"},
	Multi = false,
	Default = 1
})
AllMobFarmSpeedDropdown:OnChanged(function(Value)
	_G.AllMobFarmSpeed = Value
end)

AutoFarmAllMobToggle = Tabs.AutoFarm:AddToggle("AutoFarmAllMob", {Title = "Auto Farm All Mobs", Default = false })

local targetLevels = {10, 25, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000}
local currentLevelIndex = 1
local isFarmingActive = false

local function getNamesForLevel(targetLevel)
	local names = {}
	for key, data in pairs(MobData) do
		local levelStr = string.match(key, "Lv%.%s*(%d+)")
		local level = tonumber(levelStr) or 0
		if level == targetLevel then
			for _, name in pairs(data.MobNames) do
				names[name] = true
			end
		end
	end
	return names
end

local function getIslandForLevel(targetLevel)
	for key, data in pairs(MobData) do
		local levelStr = string.match(key, "Lv%.%s*(%d+)")
		local level = tonumber(levelStr) or 0
		if level == targetLevel then
			return data.Island
		end
	end
	return nil
end

task.spawn(function()
while true do
	task.wait() -- รันเร็วที่สุดเท่าที่ทำได้ เพื่อรองรับโหมด Fast
	if Options.AutoFarmAllMob and Options.AutoFarmAllMob.Value then
		if _G.BossIsActive then
			task.wait(1)
			continue
		end

		if not isFarmingActive then
			isFarmingActive = true
			currentLevelIndex = 1
		end

		local gilgameshFound = nil
		local hasKey = false
		local searchBossLocations = {workspace.NPCs}
		for _, loc in pairs(searchBossLocations) do
			local boss = loc:FindFirstChild("GilgameshBoss")
			if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
				gilgameshFound = boss
				break
			end
		end

		if not gilgameshFound then
			local keyName = "DivineGrail"
			for _, item in pairs(Player.Backpack:GetChildren()) do
				if string.find(item.Name, "Grail") then hasKey = true break end
			end
			if not hasKey and Player.Character then
				for _, item in pairs(Player.Character:GetChildren()) do
					if item:IsA("Tool") and string.find(item.Name, "Grail") then hasKey = true break end
				end
			end
		end

		if gilgameshFound then
			_G.CurrentTarget = "Boss"
			local targetCFrame = GetFarmCFrame(gilgameshFound.HumanoidRootPart)
			TeleportTo(targetCFrame)
			if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
			
			-- จัดการระบบโจมตีตามความเร็วที่เลือก
			if _G.AllMobFarmSpeed == "Fast" then
				if HitRemote then 
					HitRemote:FireServer() 
					_G.LastActiveAttack = tick() -- อัพเดทให้ Auto Skill ทำงานได้ในโหมด Fast
				end
			else
				RequestHit()
				task.wait(0.2) -- เพิ่มความหน่วงในโหมด Normal ให้การตีและการวาปช้าลง
			end
			continue
		elseif hasKey then
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer("GilgameshBoss", "Normal")
			task.wait()
			continue
		end

		if _G.CurrentTarget == "Boss" then
			task.wait()
			continue
		end

		_G.CurrentTarget = "Mob"

		pcall(function()
		local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		local currentTargetLevel = targetLevels[currentLevelIndex]
		local currentValidNames = getNamesForLevel(currentTargetLevel)

		local target = nil
		local minDst = math.huge
		local searchLocations = { workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Npcs") }

		for _, folder in pairs(searchLocations) do
			if folder then
				for _, v in pairs(folder:GetChildren()) do
					if v:GetAttribute("_NPCReady") ~= nil and v:GetAttribute("_NPCReady") == false then continue end
					if currentValidNames[v.Name] and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
						local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
						if dst < minDst then
							minDst = dst
							target = v
						end
					end
				end
			end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			TeleportTo(targetCFrame)
			if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
			
			-- จัดการระบบโจมตีตามความเร็วที่เลือก
			if _G.AllMobFarmSpeed == "Fast" then
				if HitRemote then 
					HitRemote:FireServer() 
					_G.LastActiveAttack = tick() -- อัพเดทให้ Auto Skill ทำงานได้ในโหมด Fast
				end
			else
				RequestHit()
				task.wait(0.2) -- เพิ่มความหน่วงให้โหมด Normal คิลและการวาปช้าลง
			end
		else
			currentLevelIndex = currentLevelIndex + 1

			if currentLevelIndex > #targetLevels then
				currentLevelIndex = 1
			end

			local nextTargetLevel = targetLevels[currentLevelIndex]
			local targetIsland = getIslandForLevel(nextTargetLevel)
			if targetIsland and IslandTeleports and IslandTeleports[targetIsland] then
				local islandPos = IslandTeleports[targetIsland]
				if (myRoot.Position - islandPos.Position).Magnitude > 500 then
					TeleportTo(islandPos)
					task.wait(0.5) -- หน่วงเวลาการวาปเปลี่ยนเกาะให้เสถียรขึ้น
				end
			end
		end
	end)
else
	isFarmingActive = false
	_G.CurrentTarget = "None"
	task.wait(0.2)
end
end
end)

-- ==========================================
-- Artifacts Farm System
-- ==========================================
Tabs.AutoFarm:AddSection("Artifacts Farm")

local ArtifactSets = {"Celestial Rupture", "Black Horizon"}
local SelectedArtifactSet = "Celestial Rupture"

ArtifactDropdown = Tabs.AutoFarm:AddDropdown("SelectArtifactSet", {
    Title = "Select Artifact Set",
    Values = ArtifactSets,
    Multi = false,
    Default = 1
})
ArtifactDropdown:OnChanged(function(Value) SelectedArtifactSet = Value end)

AutoFarmArtifactsToggle = Tabs.AutoFarm:AddToggle("AutoFarmArtifacts", {Title = "Auto Farm Artifacts", Default = false })

local ArtifactData = {
    ["Celestial Rupture"] = {
        Islands = {"ShibuyaDestroyed", "SlimeIsland", "AcademyIsland"},
        Mobs = {"StrongSorcerer", "Curse", "Slime", "AcademyTeacher"}
    },
    ["Black Horizon"] = {
        Islands = {"ShibuyaStation", "HuecoMundoIsland"},
        Mobs = {"Sorcerer", "Hollow"}
    }
}

local currentArtifactIslandIndex = 1
local isSwitchingArtifactIsland = false
local artifactMobCycleIndex = 1

local function getValidArtifactMobs()
    local data = ArtifactData[SelectedArtifactSet]
    if not data then return {} end
    
    local currentIsland = data.Islands[currentArtifactIslandIndex]
    if not currentIsland then 
        currentArtifactIslandIndex = 1 
        currentIsland = data.Islands[1] 
    end

    local valid = {}
    local searchLocations = {
        workspace:FindFirstChild("Enemies"),
        workspace:FindFirstChild("Mobs"),
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("Npcs")
    }

    for _, folder in pairs(searchLocations) do
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                for _, mobKey in ipairs(data.Mobs) do
                    if string.find(v.Name, mobKey) then
                        if mobKey == "Sorcerer" and string.find(v.Name, "Strong") then
                            continue
                        end
                        local hum = v:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            table.insert(valid, v)
                        end
                        break
                    end
                end
            end
        end
    end
    return valid
end

task.spawn(function()
    while true do
        if Options.AutoFarmArtifacts and Options.AutoFarmArtifacts.Value then
            pcall(function()
                if HitRemote then
                    for i = 1, 6 do HitRemote:FireServer() end
                    _G.LastActiveAttack = tick()
                end

                local char = Player.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end

                if Options.AutoSkill and Options.AutoSkill.Value then
                    local selectedKeys = Options.SelectSkills and Options.SelectSkills.Value or {["Z"]=true, ["X"]=true, ["C"]=true, ["V"]=true}
                    local skillOrder = {"Z", "X", "C", "V"}
                    for _, key in ipairs(skillOrder) do
                        if selectedKeys[key] then
                            if SkillRemote then
                                local sId = SkillMap[key]
                                if sId then SkillRemote:FireServer(sId) end
                            end
                            VirtualInputManager:SendKeyEvent(true, key, false, game)
                            VirtualInputManager:SendKeyEvent(false, key, false, game)
                        end
                    end
                end
            end)
        end
        task.wait(0.01)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if Options.AutoFarmArtifacts and Options.AutoFarmArtifacts.Value then
        if _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then return end

        local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local validMobs = getValidArtifactMobs()
        local data = ArtifactData[SelectedArtifactSet]

        if #validMobs == 0 then
            if not isSwitchingArtifactIsland then
                isSwitchingArtifactIsland = true
                task.spawn(function()
                    currentArtifactIslandIndex = (currentArtifactIslandIndex % #data.Islands) + 1
                    local islandName = data.Islands[currentArtifactIslandIndex]
                    local pos = IslandTeleports[islandName]
                    if pos then TeleportTo(pos) end
                    task.wait(0.5)
                    isSwitchingArtifactIsland = false
                end)
            end
            return
        end

        if artifactMobCycleIndex > #validMobs then artifactMobCycleIndex = 1 end
        local target = validMobs[artifactMobCycleIndex]

        if target and target:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.HumanoidRootPart
            local targetHum = target.Humanoid

            if _G.FarmPosition == "Above" then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 11, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            else
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3.1)
            end

            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero

            if _G.AutoEquipEnabled then EquipWeapon(_G.SelectedWeaponGroup) end

            if targetHum.Health <= 0 then
                artifactMobCycleIndex = (artifactMobCycleIndex % #validMobs) + 1
            end
        else
            artifactMobCycleIndex = (artifactMobCycleIndex % #validMobs) + 1
        end
    end
end)

Tabs.AutoFarm:AddSection("Boss Farm")

BossDropdown = Tabs.AutoFarm:AddDropdown("SelectBoss", { Title = "Select Boss", Values = BossList, Multi = true, Default = {} })
BossDropdown:OnChanged(function(Value) _G.SelectedBosses = Value end)

AutoBossToggle = Tabs.AutoFarm:AddToggle("AutoBossFarm", {Title = "Auto Farm Boss", Default = false })
AutoBossToggle:OnChanged(function(Value)
_G.AutoBossFarm = Value
if not Value then
	_G.BossIsActive = false
	_G.CheckingBosses = false
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoBossFarm and Options.AutoBossFarm.Value then
		local isHuntingBoss = false

		pcall(function()
		for bossName, isSelected in pairs(Options.SelectBoss.Value) do
			if isSelected then
				local boss, ready = CheckBossStatus(bossName)
				if not boss then continue end

				if not ready then
					if BossPositions[bossName] then
						isHuntingBoss = true
						_G.BossIsActive = true
						_G.CurrentTarget = "Boss"

						TeleportTo(BossPositions[bossName])
						task.wait(1)
					end
					continue
				end

				isHuntingBoss = true
				_G.BossIsActive = true
				_G.CurrentTarget = "Boss"

				while boss and boss:GetAttribute("_NPCReady") == true and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and Options.AutoBossFarm.Value do
					local targetCFrame = GetFarmCFrame(boss.HumanoidRootPart)
					TeleportTo(targetCFrame)

					if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
					RequestHit()
					task.wait(0.1)
				end
				break
			end
		end
	end)

	if not isHuntingBoss then
		_G.BossIsActive = false
		if _G.CurrentTarget == "Boss" then _G.CurrentTarget = "None" end
		task.wait(1)
	end
else
	_G.BossIsActive = false
	task.wait(0.5)
end
end
end)

Tabs.AutoFarm:AddSection("Farm Boss Summon")

SummonBossDropdown = Tabs.AutoFarm:AddDropdown("SelectSummonBoss", { Title = "Select Summon Boss", Values = SummonBossList, Multi = false, Default = 1 })
SummonBossDropdown:OnChanged(function(Value) _G.SelectedSummonBoss = Value end)

AutoSummonToggle = Tabs.AutoFarm:AddToggle("AutoSummon", {Title = "Auto Summon Boss", Default = false })
AutoSummonToggle:OnChanged(function(Value)
_G.AutoSummon = Value
if Value then
	task.spawn(function()
	while _G.AutoSummon do
		task.wait(2)
		pcall(function()
		if _G.SelectedSummonBoss and _G.SelectedSummonBoss ~= "None" then
			local args = { _G.SelectedSummonBoss }
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(unpack(args))
		end
	end)
end
end)
end
end)

AutoKillSummonToggle = Tabs.AutoFarm:AddToggle("AutoKillSummon", {Title = "Auto Kill Summon", Default = false })
AutoKillSummonToggle:OnChanged(function(Value)
_G.AutoKillSummon = Value
if Value then
	_G.HasWarpedToSummon = false
	task.spawn(function()
	while _G.AutoKillSummon do
		task.wait(0.1)
		pcall(function()
		if not _G.HasWarpedToSummon then
			if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
				TeleportTo(CFrame.new(651.810181, -3.67419362, -1021.13123, -0.694649816, 0, -0.719348073, 0, 1, 0, 0.719348073, 0, -0.694649816))
				_G.HasWarpedToSummon = true
				task.wait(1)
			end
		end

		if _G.SelectedSummonBoss and _G.SelectedSummonBoss ~= "None" then
			local targetBoss = workspace.NPCs:FindFirstChild(_G.SelectedSummonBoss)
			if targetBoss and targetBoss:FindFirstChild("Humanoid") and targetBoss.Humanoid.Health > 0 and targetBoss:FindFirstChild("HumanoidRootPart") then
				local farmCFrame = GetFarmCFrame(targetBoss.HumanoidRootPart)
				TeleportTo(farmCFrame)
				if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
				RequestHit()
			end
		end
	end)
end
end)
end
end)

Tabs.AutoFarm:AddSection("Skill Manage")
SkillDropdown = Tabs.AutoFarm:AddDropdown("SelectSkills", { Title = "Select Skills", Values = {"Z", "X", "C", "V", "F"}, Multi = true, Default = {} })
SkillDropdown:OnChanged(function(Value) _G.SelectedSkills = Value end)
AutoSkillToggle = Tabs.AutoFarm:AddToggle("AutoSkill", {Title = "Auto Use Skills", Default = false })
AutoSkillToggle:OnChanged(function(Value) _G.AutoSkill = Value end)


Tabs.Boss:AddSection("Specific Mob Farm (เลือกฟาร์มตามเวล)")

AutoFarmSpecificLoopToggle = Tabs.Boss:AddToggle("AutoFarmSpecificLoop", {Title = "Auto Farm Mob Sword", Default = false })

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoFarmSpecificLoop and Options.AutoFarmSpecificLoop.Value then
		if _G.CurrentTarget == "Boss" or _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then
			task.wait(1)
			continue
		end

		local targetMobKey = SpecificMobList[SpecificFarmIndex]
		local currentData = MobData[targetMobKey]

		if currentData then
			local target = nil
			local minDst = math.huge
			local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

			if myRoot then
				local searchLocations = { workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Npcs") }
				for _, folder in pairs(searchLocations) do
					if folder then
						for _, v in pairs(folder:GetChildren()) do
							if table.find(currentData.MobNames, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
								local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
								if dst < minDst then
									minDst = dst
									target = v
								end
							end
						end
					end
				end
			end

			if target then
				local hum = target:FindFirstChild("Humanoid")
				local stuckTimeout = 0

				while target and target.Parent and hum and hum.Health > 0 and Options.AutoFarmSpecificLoop.Value do
					if _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then break end
					if stuckTimeout > 20 then break end

					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart") then
						local farmCFrame = GetFarmCFrame(target.HumanoidRootPart)
						TeleportTo(farmCFrame)
						if _G.AutoEquipEnabled and _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
						RequestHit()
					end
					stuckTimeout += task.wait(0.1)
				end

				local isDead = false
				if not target or not target.Parent or not target:FindFirstChild("Humanoid") then
					isDead = true
				elseif hum and hum.Health <= 0 then
					isDead = true
				end

				if isDead or stuckTimeout > 20 then
					if isDead then SpecificMobKillCount += 1 end
					if SpecificMobKillCount >= 5 then
						SpecificMobKillCount = 0
						SpecificFarmIndex += 1
						if SpecificFarmIndex > #SpecificMobList then SpecificFarmIndex = 1 end
					end
					task.wait(0.1)
				end
			else
				if currentData.Island and IslandTeleports[currentData.Island] then
					local islandPos = IslandTeleports[currentData.Island]
					if myRoot then
						if (myRoot.Position - islandPos.Position).Magnitude > 500 then
							TeleportTo(islandPos)
							task.wait(1)
						end
					end
				end
				task.wait(0.5)
			end
		end
	else
		SpecificFarmIndex = 1
		SpecificMobKillCount = 0
	end
end
end)

Tabs.Boss:AddSection("Crafting Settings")
AutoCraftSlimeKeyToggle = Tabs.Boss:AddToggle("AutoCraftSlimeKey", {Title = "Auto Crafting Slime Key", Default = false })
AutoCraftGrailKeyToggle = Tabs.Boss:AddToggle("AutoCraftGrailKey", {Title = "Auto Crafting Grail Key", Default = false })

task.spawn(function()
while true do
	task.wait(1)
	if Options.AutoCraftSlimeKey and Options.AutoCraftSlimeKey.Value then
		pcall(function()
		local args = { "SlimeKey" , 1 }
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSlimeCraft"):InvokeServer(unpack(args))
	end)
end
end
end)

task.spawn(function()
while true do
	task.wait(1)
	if Options.AutoCraftGrailKey and Options.AutoCraftGrailKey.Value then
		pcall(function()
		local args = { "DivineGrail", 1 }
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestGrailCraft"):InvokeServer(unpack(args))
	end)
end
end
end)

Tabs.Boss:AddSection("Academy Teacher Farm")
AutoAcademyTeacherToggle = Tabs.Boss:AddToggle("AutoAcademyTeacher", {Title = "Auto Farm Academy Teacher", Default = false })

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoAcademyTeacher and Options.AutoAcademyTeacher.Value then
		if Options.AutoKillRimuru and Options.AutoKillRimuru.Value and IsRimuruAlive() then
			task.wait(1)
			continue
		end
		if Options.AutoBossFarm and Options.AutoBossFarm.Value and (_G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive()) then
			task.wait(1)
			continue
		end

		pcall(function()
		local targetName = "AcademyTeacher"
		local target = nil
		local minDst = math.huge
		local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

		if myRoot then
			local searchLocations = {workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("Npcs")}
			for _, folder in pairs(searchLocations) do
				if folder then
					for _, v in pairs(folder:GetChildren()) do
						if string.find(v.Name, targetName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
							local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
							if dst < minDst then
								minDst = dst
								target = v
							end
						end
					end
				end
			end
		end

		if target then
			local hum = target.Humanoid
			while hum and hum.Health > 0 and Options.AutoAcademyTeacher.Value do
				if (Options.AutoKillRimuru and Options.AutoKillRimuru.Value and IsRimuruAlive()) or (Options.AutoBossFarm and Options.AutoBossFarm.Value and (_G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive())) then break end
				if not target or not target.Parent then break end
				if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
					local farmCFrame = GetFarmCFrame(target.HumanoidRootPart)
					TeleportTo(farmCFrame)
					if _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
					RequestHit()
				end
				task.wait(0.1)
			end
		else
			task.wait(1)
		end
	end)
end
end
end)

AutoEventFarmV3Toggle = Tabs.Boss:AddToggle("AutoEventFarmV3", {Title = "Auto Farm (Academy/Sorcerer/Curse)", Default = false })

local currentIslandIndex = 1
local mobCycleIndex = 1
local isSwitchingIsland = false

local IslandPositions = {
["ShibuyaDestroyed"]  = CFrame.new(666.40, 2.71, -1695.73),
["SlimeIsland"]       = CFrame.new(-1124.75, 19.70, 371.23),
}

local IslandOrder = {
"ShibuyaDestroyed",
"SlimeIsland",
}

local AllMobData = {
["StrongSorcerer"] = "ShibuyaDestroyed",
["Curse"] = "ShibuyaDestroyed",
["Slime"] = "SlimeIsland",
}

local function HandleSkills()
	if Options.AutoSkill and Options.AutoSkill.Value then
		local selectedKeys = Options.SelectSkills and Options.SelectSkills.Value or {["Z"]=true, ["X"]=true, ["C"]=true, ["V"]=true}
		local skillOrder = {"Z", "X", "C", "V"}

		for _, key in ipairs(skillOrder) do
			if selectedKeys[key] then
				if SkillRemote then
					local sId = SkillMap[key]
					if sId then SkillRemote:FireServer(sId) end
				end
				VirtualInputManager:SendKeyEvent(true, key, false, game)
				VirtualInputManager:SendKeyEvent(false, key, false, game)
			end
		end
	end
end

local function getValidMobs()
	local currentIsland = IslandOrder[currentIslandIndex]
	local valid = {}
	local searchLocations = {
	workspace:FindFirstChild("Enemies"),
	workspace:FindFirstChild("Mobs"),
	workspace:FindFirstChild("NPCs"),
	workspace:FindFirstChild("Npcs")
	}

	for _, folder in pairs(searchLocations) do
		if folder then
			for _, v in ipairs(folder:GetChildren()) do
				for mobKey, island in pairs(AllMobData) do
					if island == currentIsland and string.find(v.Name, mobKey) then
						local hum = v:FindFirstChild("Humanoid")
						if hum and hum.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
							table.insert(valid, v)
						end
						break
					end
				end
			end
		end
	end
	return valid
end

task.spawn(function()
while true do
	if Options.AutoEventFarmV3 and Options.AutoEventFarmV3.Value then
		pcall(function()
		if HitRemote then
			for i = 1, 6 do HitRemote:FireServer() end
			_G.LastActiveAttack = tick()
		end

		local char = Player.Character
		if char then
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then tool:Activate() end
		end

		HandleSkills()
	end)
end
task.wait(0.01)
end
end)

game:GetService("RunService").Heartbeat:Connect(function()
if Options.AutoEventFarmV3 and Options.AutoEventFarmV3.Value then
	if _G.BossIsActive or _G.CheckingBosses or IsAnySelectedBossAlive() then return end

	local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local validMobs = getValidMobs()

	if #validMobs == 0 then
		if not isSwitchingIsland then
			isSwitchingIsland = true
			task.spawn(function()
			currentIslandIndex = (currentIslandIndex % #IslandOrder) + 1
			local pos = IslandPositions[IslandOrder[currentIslandIndex]]
			if pos then TeleportTo(pos) end
			task.wait(0.2)
			isSwitchingIsland = false
		end)
	end
	return
end

if mobCycleIndex > #validMobs then mobCycleIndex = 1 end
local target = validMobs[mobCycleIndex]

if target and target:FindFirstChild("HumanoidRootPart") then
	local targetRoot = target.HumanoidRootPart
	local targetHum = target.Humanoid

	if _G.FarmPosition == "Above" then
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 11, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	else
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3.1)
	end

	myRoot.AssemblyLinearVelocity = Vector3.zero
	myRoot.AssemblyAngularVelocity = Vector3.zero

	if _G.AutoEquipEnabled then EquipWeapon(_G.SelectedWeaponGroup) end

	if targetHum.Health <= 0 then
		mobCycleIndex = (mobCycleIndex % #validMobs) + 1
	end
else
	mobCycleIndex = (mobCycleIndex % #validMobs) + 1
end
end
end)

Tabs.Boss:AddSection("Auto Summon Anos Boss")
local SummonAnosBosses = {"Anos"}
local SelectedSummonAnosBoss = "Anos"
local SelectedDifficultyAnos = "Normal"

SummonAnosDropdown = Tabs.Boss:AddDropdown("SelectSummonAnosBoss", { Title = "Select Boss (เลือกบอส)", Values = SummonAnosBosses, Multi = false, Default = 1 })
SummonAnosDropdown:OnChanged(function(Value) SelectedSummonAnosBoss = Value end)

DifficultyAnosDropdown = Tabs.Boss:AddDropdown("SelectDifficultyAnos", { Title = "Select Difficulty (เลือกระดับ)", Values = {"Normal", "Medium", "Hard", "Extreme"}, Multi = false, Default = 1 })
DifficultyAnosDropdown:OnChanged(function(Value) SelectedDifficultyAnos = Value end)

AutoSummonAnosToggle = Tabs.Boss:AddToggle("AutoSummonBossAnos", {Title = "Auto Summon Anos", Default = false })
AutoKillAnosToggle = Tabs.Boss:AddToggle("AutoKillBossAnos", {Title = "Auto Kill Anos Boss (เลือกระดับด้านบน)", Default = false })

task.spawn(function()
while true do
	task.wait(3)
	if Options.AutoSummonBossAnos and Options.AutoSummonBossAnos.Value then
		pcall(function()
		local args = { "Anos", SelectedDifficultyAnos }
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSpawnAnosBoss")
		if remote then remote:FireServer(unpack(args)) end
	end)
end
end
end)

AutoKillAnosToggle:OnChanged(function(Value)
if Value == true then
	local startCFrame = CFrame.new(901.426392, 1.4632163, 1293.13623, -0.92051065, 0, -0.390717506, 0, 1, 0, 0.390717506, 0, -0.92051065)
	if TeleportTo then TeleportTo(startCFrame) end
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoKillBossAnos and Options.AutoKillBossAnos.Value then
		pcall(function()
		local fullTargetName = "AnosBoss_" .. SelectedDifficultyAnos
		local target = nil
		local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}

		for _, location in pairs(searchLocations) do
			if location then
				local found = location:FindFirstChild(fullTargetName)
				if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
					target = found
					break
				end
				for _, v in pairs(location:GetChildren()) do
					if v.Name == fullTargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
						target = v
						break
					end
				end
			end
			if target then break end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			if TeleportTo then TeleportTo(targetCFrame) end
			if EquipWeapon then EquipWeapon(Options.SelectWeapon.Value) end
			if RequestHit then RequestHit() end
		end
	end)
end
end
end)

Tabs.Boss:AddSection("Auto Summon Boss V2")
local SummonV2Bosses = {"GojoV2", "SukunaV2"}
local SelectedSummonV2Boss = "GojoV2"
local SelectedDifficultyV2 = "Normal"

SummonV2Dropdown = Tabs.Boss:AddDropdown("SelectSummonBossV2", { Title = "Select Boss (เลือกบอส)", Values = SummonV2Bosses, Multi = false, Default = 1 })
SummonV2Dropdown:OnChanged(function(Value) SelectedSummonV2Boss = Value end)

DifficultyV2Dropdown = Tabs.Boss:AddDropdown("SelectDifficultyV2", { Title = "Select Difficulty (เลือกระดับ)", Values = {"Normal", "Medium", "Hard", "Extreme"}, Multi = false, Default = 1 })
DifficultyV2Dropdown:OnChanged(function(Value) SelectedDifficultyV2 = Value end)

AutoSummonV2Toggle = Tabs.Boss:AddToggle("AutoSummonBossV2", {Title = "Auto Summon V2", Default = false })
AutoKillV2Toggle = Tabs.Boss:AddToggle("AutoKillBossV2", {Title = "Auto Kill Boss V2 (เลือกบอส/ระดับด้านบน)", Default = false })

task.spawn(function()
while true do
	task.wait(3)
	if Options.AutoSummonBossV2 and Options.AutoSummonBossV2.Value then
		pcall(function()
		local internalName = "StrongestToday"
		if SelectedSummonV2Boss == "SukunaV2" then internalName = "StrongestHistory" end
		local args = { internalName, SelectedDifficultyV2 }
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss")
		if remote then remote:FireServer(unpack(args)) end
	end)
end
end
end)

AutoKillV2Toggle:OnChanged(function(Value)
if Value == true then
	local startCFrame = CFrame.new(392.870026, -2.22865272, -2177.80151, -0.912216544, 0, -0.409708411, 0, 1, 0, 0.409708411, 0, -0.912216544)
	if TeleportTo then TeleportTo(startCFrame) end
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoKillBossV2 and Options.AutoKillBossV2.Value then
		pcall(function()
		local targetNamePrefix = ""
		if SelectedSummonV2Boss == "GojoV2" then targetNamePrefix = "StrongestofTodayBoss"
	elseif SelectedSummonV2Boss == "SukunaV2" then targetNamePrefix = "StrongestinHistoryBoss" end

		local fullTargetName = targetNamePrefix .. "_" .. SelectedDifficultyV2
		local target = nil
		local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}

		for _, location in pairs(searchLocations) do
			if location then
				local found = location:FindFirstChild(fullTargetName)
				if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
					target = found
					break
				end
				for _, v in pairs(location:GetChildren()) do
					if v.Name == fullTargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
						target = v
						break
					end
				end
			end
			if target then break end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			TeleportTo(targetCFrame)
			EquipWeapon(Options.SelectWeapon.Value)
			RequestHit()
		end
	end)
end
end
end)

Tabs.Boss:AddSection("Auto Summon Rimuru")
local SelectedRimuruDifficulty = "Normal"

RimuruDifficultyDropdown = Tabs.Boss:AddDropdown("SelectRimuruDifficulty", { Title = "Select Difficulty (เลือกระดับ Rimuru)", Values = {"Normal", "Medium", "Hard", "Extreme"}, Multi = false, Default = 1 })
RimuruDifficultyDropdown:OnChanged(function(Value) SelectedRimuruDifficulty = Value end)

AutoSummonRimuruToggle = Tabs.Boss:AddToggle("AutoSummonRimuru", {Title = "Auto Summon Rimuru", Default = false })
AutoKillRimuruToggle = Tabs.Boss:AddToggle("AutoKillRimuru", {Title = "Auto Kill Rimuru (เลือกบอส/ระดับด้านบน)", Default = false })

AutoKillRimuruToggle:OnChanged(function(Value)
if Value == true then
	local startCFrame = CFrame.new(-1235.08276, 16.6130219, 279.549835, 0.963941038, 0, 0.266115874, 0, 1, 0, -0.266115874, 0, 0.963941038)
	if TeleportTo then TeleportTo(startCFrame) end
end
end)

task.spawn(function()
while true do
	task.wait(3)
	if Options.AutoSummonRimuru and Options.AutoSummonRimuru.Value then
		pcall(function()
		local args = { SelectedRimuruDifficulty }
		game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnRimuru"):FireServer(unpack(args))
	end)
end
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoKillRimuru and Options.AutoKillRimuru.Value then
		pcall(function()
		local fullTargetName = "RimuruBoss_" .. SelectedRimuruDifficulty
		local target = nil
		local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}

		for _, location in pairs(searchLocations) do
			if location then
				local found = location:FindFirstChild(fullTargetName)
				if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
					target = found
					break
				end
			end
			if target then break end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			TeleportTo(targetCFrame)
			EquipWeapon(Options.SelectWeapon.Value)
			RequestHit()
		end
	end)
end
end
end)

Tabs.Boss:AddSection("Auto Summon Gilgamesh")
local SelectedGilgameshDifficulty = "Normal"

GilgameshDifficultyDropdown = Tabs.Boss:AddDropdown("SelectGilgameshDifficulty", { Title = "Select Difficulty (เลือกระดับ Gilgamesh)", Values = {"Normal", "Medium", "Hard", "Extreme"}, Multi = false, Default = 1 })
GilgameshDifficultyDropdown:OnChanged(function(Value) SelectedGilgameshDifficulty = Value end)

AutoSummonGilgameshToggle = Tabs.Boss:AddToggle("AutoSummonGilgamesh", {Title = "Auto Summon Gilgamesh", Default = false })
AutoKillGilgameshToggle = Tabs.Boss:AddToggle("AutoKillGilgamesh", {Title = "Auto Kill Gilgamesh (เลือกบอส/ระดับด้านบน)", Default = false })

AutoKillGilgameshToggle:OnChanged(function(Value)
if Value then _G.HasWarpedToGilgamesh = false end
end)

task.spawn(function()
while true do
	task.wait(3)
	if Options.AutoSummonGilgamesh and Options.AutoSummonGilgamesh.Value then
		pcall(function()
		local args = { "GilgameshBoss", SelectedGilgameshDifficulty }
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(unpack(args))
	end)
end
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.AutoKillGilgamesh and Options.AutoKillGilgamesh.Value then
		pcall(function()
		if not _G.HasWarpedToGilgamesh then
			TeleportTo(CFrame.new(651.810181, -3.67419362, -1021.13123, -0.694649816, 0, -0.719348073, 0, 1, 0, 0.719348073, 0, -0.694649816))
			_G.HasWarpedToGilgamesh = true
			task.wait(1)
		end

		local target = nil
		local npcFolder = workspace:FindFirstChild("NPCs")
		if npcFolder then
			local boss = npcFolder:FindFirstChild("GilgameshBoss")
			if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
				if boss:GetAttribute("_NPCReady") == nil or boss:GetAttribute("_NPCReady") == true then
					target = boss
				end
			end
		end

		if not target then
			local searchLocations = {workspace, workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Npcs")}
			local suffixName = "GilgameshBoss_Normal"
			for _, loc in pairs(searchLocations) do
				if loc then
					local t = loc:FindFirstChild(suffixName)
					if t and t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0 and t:FindFirstChild("HumanoidRootPart") then
						target = t
						break
					end
					for _, v in pairs(loc:GetChildren()) do
						if string.find(v.Name, "GilgameshBoss") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
							target = v
							break
						end
					end
				end
				if target then break end
			end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			TeleportTo(targetCFrame)
			if _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
			RequestHit()
		end
	end)
end
end
end)

Tabs.Dungeon:AddSection("Quest Shadow")
Tabs.Dungeon:AddButton({
Title = "Quest Shadow", Description = "รับเควส Shadow",
Callback = function()
if QuestAcceptRemote then QuestAcceptRemote:FireServer("ShadowQuestlineBuff") end
Fluent:Notify({ Title = "Quest", Content = "Accepted Shadow Quest", Duration = 3 })
end
})

Tabs.Dungeon:AddSection("Dungeon Portal")
local SelectedDungeon = "CidDungeon"
DungeonDropdown = Tabs.Dungeon:AddDropdown("SelectDungeon", { Title = "Select Dungeon (เลือกดันเจี้ยน)", Values = {"CidDungeon", "RuneDungeon","DoubleDungeon","BossRush"}, Multi = false, Default = 1 })
DungeonDropdown:OnChanged(function(Value) SelectedDungeon = Value end)

JoinDungeonToggle = Tabs.Dungeon:AddToggle("AutoJoinDungeon", {Title = "Auto Join Dungeon", Default = false })
JoinTeamToggle = Tabs.Dungeon:AddToggle("AutoJoinTeam", {Title = "Auto Join Team (เข้าทีมอัตโนมัติ)", Default = false })

Tabs.Dungeon:AddSection("Dungeon Wave Vote")
local SelectedDifficulty = "Extreme"
DifficultyDropdown = Tabs.Dungeon:AddDropdown("SelectDifficulty", { Title = "Select Difficulty", Values = {"Extreme", "Easy", "Medium", "Hard"}, Multi = false, Default = 1 })
DifficultyDropdown:OnChanged(function(Value) SelectedDifficulty = Value end)

AutoVoteDifficultyToggle = Tabs.Dungeon:AddToggle("AutoVoteDifficulty", {Title = "Auto Vote Difficulty", Default = false })
StartKillToggle = Tabs.Dungeon:AddToggle("StartKillDungeon", {Title = "Start Kill", Default = false })

task.spawn(function()
while true do
	task.wait(2)
	if Options.AutoJoinDungeon and Options.AutoJoinDungeon.Value then
		pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestDungeonPortal"):FireServer(SelectedDungeon) end)
	end
end
end)

task.spawn(function()
local teamCFrame = CFrame.new(1434.00439, 4.45256138, -932.597717, -0.406715393, 0, 0.913554907, 0, 1, 0, -0.913554907, 0, -0.406715393)
while true do
	task.wait(0.5)
	if Options.AutoJoinTeam and Options.AutoJoinTeam.Value then
		pcall(function()
		TeleportTo(teamCFrame)
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(0.1)
	end)
end
end
end)

task.spawn(function()
while true do
	task.wait(2)
	if Options.AutoRetryDungeon and Options.AutoRetryDungeon.Value then
		pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveReplayVote"):FireServer("sponsor") end)
	end
end
end)

task.spawn(function()
while true do
	task.wait(1)
	if Options.AutoVoteDifficulty and Options.AutoVoteDifficulty.Value then
		pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote"):FireServer(SelectedDifficulty) end)
	end
end
end)

task.spawn(function()
while true do
	task.wait(0.1)
	if Options.StartKillDungeon and Options.StartKillDungeon.Value then
		pcall(function()
		local target = nil
		local minDst = math.huge
		local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		local targetNames = {"DungeonNPC", "ShadowBoss","ShadowMonarchBoss","Shadow2","Shadow","Shadow1","Shadow3","Shadow4","Shadow5","Sukuna","GojoBoss","YujiBoss","RagnaBoss","AnosBoss","SaberBoss","StrongestinHistoryBoss","GilgameshBoss","AizenBoss","MadokaBoss","AlucardBoss","EscanorBoss","JinwooBoss","RimuruBoss","Ichigo","QinShiBoss","StrongestofTodayBoss"}
		local folders = {workspace, workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Npcs")}

		for _, loc in pairs(folders) do
			if loc then
				for _, v in pairs(loc:GetChildren()) do
					local isTarget = false
					for _, name in ipairs(targetNames) do
						if v.Name == name or string.find(v.Name, name) then isTarget = true break end
					end

					if isTarget and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
						local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
						if dst < minDst then minDst = dst; target = v end
					end
				end
			end
		end

		if target then
			local targetCFrame = GetFarmCFrame(target.HumanoidRootPart)
			TeleportTo(targetCFrame)
			if _G.SelectedWeaponGroup then EquipWeapon(_G.SelectedWeaponGroup) end
			RequestHit()
		end
	end)
end
end
end)

AutoRetryToggle = Tabs.Dungeon:AddToggle("AutoRetryDungeon", {Title = "Auto Retry", Default = false })

Tabs.Stats:AddSection("Stat Settings")
local SelectedStat = {"Melee"}
local StatAmount = 1

local StatDropdown = Tabs.Stats:AddDropdown("SelectStat", {
	Title = "Select Stat (เลือกสเตตัส)",
	Values = {"Melee", "Defense", "Sword", "Power"},
	Multi = true,
	Default = {"Melee"},
})

StatDropdown:OnChanged(function(Value) SelectedStat = Value end)

StatAmountInput = Tabs.Stats:AddInput("StatAmountInput", { 
	Title = "Amount (จำนวนอัพ)", 
	Default = "1", 
	Placeholder = "Enter amount", 
	Numeric = true, 
	Finished = false, 
	Callback = function(Value) StatAmount = tonumber(Value) or 1 end 
})

AutoStatToggle = Tabs.Stats:AddToggle("AutoStats", {Title = "Auto Upgrade Stats", Default = false })

task.spawn(function()
	while true do
		task.wait(0.5)
		if Options.AutoStats and Options.AutoStats.Value then
			-- เพิ่มการตรวจสอบว่าเป็น Table (ดึงค่าจาก Multi Dropdown)
			if type(SelectedStat) == "table" then
				for statName, isSelected in pairs(SelectedStat) do
					-- ถ้าสเตตัสไหนถูกติ๊ก (true) ให้ยิงรีโมทอัพสเตตัสนั้น
					if isSelected then
						pcall(function() 
							game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AllocateStat"):FireServer(statName, StatAmount) 
						end)
					end
				end
			-- ดักเผื่อกรณีเป็น String ตัวเดียว
			elseif type(SelectedStat) == "string" then
				pcall(function() 
					game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AllocateStat"):FireServer(SelectedStat, StatAmount) 
				end)
			end
		end
	end
end)    

Tabs.Stats:AddSection("Chest Management")

local SelectedChest = {"Common Chest"}
local OpenAmount = 1

local ChestDropdown = Tabs.Stats:AddDropdown("SelectChestType", {
Title = "Select Chest Type (เลือกกล่อง)",
Values = { "Secret Chest", "Mythical Chest", "Legendary Chest", "Epic Chest", "Rare Chest", "Common Chest" },
Multi = true,
Default = {"Common Chest"}
})

ChestDropdown:OnChanged(function(Value)
SelectedChest = Value
end)

ChestAmountInput = Tabs.Stats:AddInput("ChestAmountInput", {
Title = "Amount (จำนวนเปิด)",
Default = "1",
Placeholder = "Enter amount",
Numeric = true,
Finished = false,
Callback = function(Value)
OpenAmount = tonumber(Value) or 1
end
})

Tabs.Stats:AddButton({
Title = "Open Chest (กดเพื่อเปิด)",
Description = "เปิดกล่องตามจำนวนและชนิดที่ระบุ",
Callback = function()
task.spawn(function()
if type(SelectedChest) == "table" then
	for chestName, itemValue in pairs(SelectedChest) do
		local actualName = type(chestName) == "number" and itemValue or chestName
		local isSelected = type(chestName) == "number" or itemValue

		if isSelected then
			pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem"):FireServer("Use", actualName, OpenAmount)
			Fluent:Notify({ Title = "Chest", Content = "Opening " .. OpenAmount .. "x " .. actualName, Duration = 2 })
		end)
		task.wait(0.3)
	end
end
else
	pcall(function()
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem"):FireServer("Use", SelectedChest, OpenAmount)
	Fluent:Notify({ Title = "Chest", Content = "Opening " .. OpenAmount .. "x " .. SelectedChest, Duration = 2 })
end)
end
end)
end
})

local function HasChest(chestName)
	local player = game:GetService("Players").LocalPlayer
	if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(chestName) then
		return true
	end
	return true
end

AutoChestToggle = Tabs.Stats:AddToggle("AutoOpenSelected", {Title = "Auto Open Selected (เปิดวนซ้ำ)", Default = false })

task.spawn(function()
while true do
	task.wait(1)
	if Options.AutoOpenSelected and Options.AutoOpenSelected.Value then

		if type(SelectedChest) == "table" then
			for chestName, itemValue in pairs(SelectedChest) do
				if not Options.AutoOpenSelected.Value then break end

				local actualName = type(chestName) == "number" and itemValue or chestName
				local isSelected = type(chestName) == "number" or itemValue

				if isSelected and HasChest(actualName) then
					pcall(function()
					game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem"):FireServer("Use", actualName, OpenAmount)
				end)
				task.wait(0.5)
			end
		end
	else
		if HasChest(SelectedChest) then
			pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem"):FireServer("Use", SelectedChest, OpenAmount)
		end)
	end
end
end
end
end)

Tabs.Teleport:AddSection("Island Teleport")
local IslandKeys = {}
for key, _ in pairs(IslandTeleports) do table.insert(IslandKeys, key) end
table.sort(IslandKeys)

IslandDropdown = Tabs.Teleport:AddDropdown("SelectIsland", { Title = "Select Island", Values = IslandKeys, Multi = false, Default = 1 })
IslandDropdown:OnChanged(function(Value) _G.SelectIslandTP = Value end)

Tabs.Teleport:AddButton({
Title = "Teleport To Island", Description = "Click to Teleport",
Callback = function()
if _G.SelectIslandTP and IslandTeleports[_G.SelectIslandTP] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
	TeleportTo(IslandTeleports[_G.SelectIslandTP])
end
end
})

Tabs.Teleport:AddSection("NPC Teleport")
local NPCKeys = {}
for key, _ in pairs(NPCTeleports) do table.insert(NPCKeys, key) end
table.sort(NPCKeys)

NPCDropdown = Tabs.Teleport:AddDropdown("SelectNPC", { Title = "Select NPC", Values = NPCKeys, Multi = false, Default = 1 })
NPCDropdown:OnChanged(function(Value) _G.SelectNPCTP = Value end)

Tabs.Teleport:AddButton({
Title = "Teleport To NPC", Description = "Click to Teleport",
Callback = function()
if _G.SelectNPCTP and NPCTeleports[_G.SelectNPCTP] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
	TeleportTo(NPCTeleports[_G.SelectNPCTP])
end
end
})

Tabs.Teleport:AddSection("Auto Slime Event")
local EventNPCCFrame = CFrame.new(-1167.46204, 2.75521803, 173.572083, -0.898167968, 0, -0.439652443, 0, 1, 0, 0.439652443, 0, -0.898167968)

local cachedPrompts = {}
local lastPromptCache = 0
local function FireNearestPrompt()
	local player = game.Players.LocalPlayer
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if tick() - lastPromptCache > 5 then
		cachedPrompts = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				table.insert(cachedPrompts, v)
			end
		end
		lastPromptCache = tick()
	end

	for _, prompt in pairs(cachedPrompts) do
		if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
			if (root.Position - prompt.Parent.Position).Magnitude < 20 then
				if fireproximityprompt then
					fireproximityprompt(prompt, 1)
				else
					-- Universal Fallback for Executors without fireproximityprompt
					prompt.InputHoldBegin:Fire()
					task.wait(prompt.HoldDuration)
					prompt.InputHoldEnd:Fire()
				end
			end
		end
	end
end

AutoSlimeToggle = Tabs.Teleport:AddToggle("AutoSlimeEvent", { Title = "Auto Slime ( รับเควส + เก็บ )", Default = false })
AutoSlimeToggle:OnChanged(function(Value)
if Value then
	task.spawn(function()
	while Options.AutoSlimeEvent.Value do
		pcall(function()
		TeleportTo(EventNPCCFrame)
		task.wait(1)
		FireNearestPrompt()
		task.wait(1)
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EventRemotes"):WaitForChild("GetEvents"):InvokeServer()
		task.wait(1)
		for i = 1, 7 do
			if not Options.AutoSlimeEvent.Value then break end
			local key = "Slime #" .. i
			local cf = SlimeLocations[key]
			if cf then
				TeleportTo(cf)
				task.wait(0.5)
				FireNearestPrompt()
				task.wait(1)
			end
		end
	end)
	task.wait(2)
end
end)
end
end)

Tabs.Teleport:AddSection("Auto Anos Demonite")
local DemoniteNPCCFrame = CFrame.new(727.65625, -1.79563808, 1273.05908, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)

AutoDemoniteToggle = Tabs.Teleport:AddToggle("AutoDemoniteEvent", { Title = "Auto Demonite Event (รับเควส + เก็บ)", Default = false })
AutoDemoniteToggle:OnChanged(function(Value)
if Value then
	task.spawn(function()
	while Options.AutoDemoniteEvent.Value do
		pcall(function()
		TeleportTo(DemoniteNPCCFrame)
		task.wait(1)
		FireNearestPrompt()
		task.wait(1)
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EventRemotes"):WaitForChild("GetEvents"):InvokeServer()
		task.wait(1)
		for i = 1, 2 do
			if not Options.AutoDemoniteEvent.Value then break end
			local key = "Demonite #" .. i
			local cf = DemoniteLocations[key]
			if cf then TeleportTo(cf); task.wait(0.5); FireNearestPrompt(); task.wait(1) end
		end
	end)
	task.wait(2)
end
end)
end
end)

Tabs.Teleport:AddSection("Auto Dungeon")
local JigsawNPCCFrame = CFrame.new(1426.23938, 2.20256138, -929.140381, -0.406715393, 0, 0.913554907, 0, 1, 0, -0.913554907, 0, -0.406715393)

AutoJigsawToggle = Tabs.Teleport:AddToggle("AutoJigsawEvent", { Title = "Auto Jigsaw Event (รับเควส + เก็บ)", Default = false })
AutoJigsawToggle:OnChanged(function(Value)
if Value then
	task.spawn(function()
	while Options.AutoJigsawEvent.Value do
		pcall(function()
		TeleportTo(JigsawNPCCFrame)
		task.wait(1)
		FireNearestPrompt()
		task.wait(1)
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EventRemotes"):WaitForChild("GetEvents"):InvokeServer()
		task.wait(1)
		for i = 1, 6 do
			if not Options.AutoJigsawEvent.Value then break end
			local key = "Jigsaw #" .. i
			local cf = JigsawLocations[key]
			if cf then TeleportTo(cf); task.wait(0.5); FireNearestPrompt(); task.wait(1) end
		end
	end)
	task.wait(2)
end
end)
end
end)

Tabs.Settings:AddSection("Miscs")

local LiveInventory = {}
local UpdateRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateInventory")

UpdateRemote.OnClientEvent:Connect(function(category, data)
if category == "Items" then
	LiveInventory = data
end
end)

local function getCount(name)
	for _, item in pairs(LiveInventory) do
		if item.name == name then
			return tostring(item.quantity or 1)
		end
	end
	return "0"
end

local function formatBox(value)
	return "```\n" .. value .. " EA\n```"
end

Tabs.Settings:AddSection("Discord Webhook System")

_G.WebhookURL = ""
local WebhookInput = Tabs.Settings:AddInput("WebhookURLInput", {
Title = "Discord Webhook URL",
Placeholder = "วางลิงก์ของคุณที่นี่...",
Finished = true,
Callback = function(Value) _G.WebhookURL = Value end
})

Tabs.Settings:AddButton({
Title = "Send Manual Report (กดเพื่อส่งรายงานไอเท็ม)",
Description = "ดึงข้อมูลจากกระเป๋าและส่งเข้า Discord ทันที",
Callback = function()
if _G.WebhookURL ~= "" then
	pcall(function()
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestInventory"):FireServer()
end)
task.wait(0.5)

SendToDiscordGrid()
Fluent:Notify({ Title = "Webhook", Content = "เรียกข้อมูลและส่งรายงานแล้ว!", Duration = 3 })
else
	Fluent:Notify({ Title = "Error", Content = "กรุณาใส่ลิงก์ Webhook ก่อน", Duration = 3 })
end
end
})

local AutoReportToggle = Tabs.Settings:AddToggle("EnableAutoReport", {
Title = "Webhook Auto (ส่งทุก 10 นาที)",
Default = false
})

task.spawn(function()
    local lastSend = 0
    while true do
        task.wait(1) -- ปรับเป็น 1 วินาทีเพื่อให้สคริปต์ตอบสนองต่อการเปิด/ปิดตั้งค่าได้ไวขึ้น
        
        if Options.EnableAutoReport and Options.EnableAutoReport.Value and _G.WebhookURL ~= "" then
            -- 600 วินาที = 10 นาที
            if tick() - lastSend >= 600 then 
                SendToDiscordGrid()
                lastSend = tick()
            end
        end
    end
end)

function SendToDiscordGrid()
	local url = _G.WebhookURL
	if url == "" then return end

	local currentMoney = "0"
	pcall(function() currentMoney = tostring(LocalPlayer.Data.Money.Value) end)

	local fields = {
	{ ["name"] = "✨ Aura Crate", ["value"] = formatBox(getCount("Aura Crate")), ["inline"] = true },
	{ ["name"] = "📦 Secret Chest", ["value"] = formatBox(getCount("Secret Chest")), ["inline"] = true },
	{ ["name"] = "🧾 Calamity Seal", ["value"] = formatBox(getCount("Calamity Seal")), ["inline"] = true },
	{ ["name"] = "🧾 Clan Reroll", ["value"] = formatBox(getCount("Clan Reroll")), ["inline"] = true },
	{ ["name"] = "🧬 Race Reroll", ["value"] = formatBox(getCount("Race Reroll")), ["inline"] = true },
	{ ["name"] = "🌟 Trait Reroll", ["value"] = formatBox(getCount("Trait Reroll")), ["inline"] = true },
	{ ["name"] = "💰 Current Money", ["value"] = formatBox(currentMoney), ["inline"] = true },
	}

	local embed = {
	["title"] = "📊 สรุปสถิติไอเทมตัวละคร",
	["color"] = 16711680,
	["fields"] = fields,
	["footer"] = { ["text"] = "อัปเดตเมื่อ: " .. os.date("%H:%M:%S") },
	["thumbnail"] = { ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png" }
	}

	local payload = HttpService:JSONEncode({
	["username"] = LocalPlayer.DisplayName .. " Stats",
	["embeds"] = { embed }
	})

	-- Optimized for 100% Universal Executor Support (Wave, Macsploit, Delta, Codex, etc.)
	local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

	if httprequest then
		task.spawn(function()
		pcall(function()
		httprequest({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload })
	end)
end)
else
	warn("Your Executor does not support HTTP requests!")
end
end

Tabs.Settings:AddSection("Anti-AFK Setting")

local AntiAFKToggle = Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti AFK (กันหลุด)", Default = true })
_G.AntiAFK = true

AntiAFKToggle:OnChanged(function(Value)
_G.AntiAFK = Value
end)

game:GetService("Players").LocalPlayer.Idled:Connect(function()
if _G.AntiAFK then
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end
end)

task.spawn(function()
while task.wait(0.5) do
	if Options.AutoObservationHaki.Value then
		pcall(function()
		local remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ObservationHakiRemote")
		if remote and not ObsState.Active then remote:FireServer("Toggle") end
	end)
end
end
end)

task.spawn(function()
while task.wait(1) do
	if Options.AutoConquerorHaki and Options.AutoConquerorHaki.Value then
		pcall(function()
		local args = { "Activate" }
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("ConquerorHakiRemote")
		if remote then
			remote:FireServer(unpack(args))
		end
	end)
end
end
end)

task.spawn(function()
local skillOrder = {"Z", "X", "C", "V", "F"}

while true do
	task.wait(0.1)

	if Options.AutoSkill and Options.AutoSkill.Value and (tick() - _G.LastActiveAttack < 1.5) then
		pcall(function()
		local selectedSkills = Options.SelectSkills.Value

		for _, key in ipairs(skillOrder) do
			if not Options.AutoSkill.Value or (tick() - _G.LastActiveAttack > 1.5) then break end

			if selectedSkills[key] then
				local skillId = SkillMap[key]
				if SkillRemote and skillId then
					SkillRemote:FireServer(skillId)
					task.wait(0.2)
				end
			end
		end
	end)
else
	task.wait(0.5)
end
end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("SailorPiece_Mamypoko")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)

Fluent:Notify({
Title = "[👑Fate Update💫] Sailor Piece Script !",
Content = "Script Loaded and Universal Executor Support added!",
Duration = 5
})
            end)

            return true
        else
            NotifyCustom("Error", tostring(result.message))
            return false
        end
    end 

    function Task:Window(config)
        config.DisplayName = config.DisplayName or "Lume.Dev"
        config.File = config.File or "Lumedev/savedkey.txt"
        config.Discord = config.Discord or "https://discord.gg/Zk7f9w4DcD"

        -- AUTO LOGIN SYSTEM
        if isfile(config.File) then
            local saved = readfile(config.File)
            if saved and saved ~= "" then
                -- เช็คเงียบๆ ถ้าผ่านก็ล็อคอินเลย
                if VerifyKey(saved, config.File) then return end
            end
        end

        local MainFrame = UI:Create("Frame", {
            Name = "MainFrame",
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(500, 280),
            BackgroundColor3 = Color3.fromRGB(18, 18, 20),
            BorderSizePixel = 0
        })
        UI:AddCorner(MainFrame, 16)
        UI:AddStroke(MainFrame, Color3.fromRGB(45, 45, 50), 1)
        UI:AddShadow(MainFrame)

        -- TOP BAR
        local TopBar = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
        })
        
        local Title = UI:Create("TextLabel", {
            Parent = TopBar,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            Text = config.DisplayName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        UI:AddGradient(Title, {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 20, 20))
        })

        local CloseButton = UI:Create("TextButton", {
            Parent = TopBar,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0.5, -15),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(120, 120, 130),
            Font = Enum.Font.Gotham,
            TextSize = 28
        })
        CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

        local Divider = UI:Create("Frame", {
            Parent = TopBar,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            BorderSizePixel = 0
        })

        -- CONTENT
        local Content = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, -48, 1, -80),
            Position = UDim2.new(0, 24, 0, 70),
            BackgroundTransparency = 1
        })

        local Instr = UI:Create("TextLabel", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, -5),
            BackgroundTransparency = 1,
            Text = "Please enter your access key below to continue.",
            TextColor3 = Color3.fromRGB(100, 100, 110),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local InputContainer = UI:Create("Frame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        })
        UI:AddCorner(InputContainer, 10)
        local InputStroke = UI:AddStroke(InputContainer, Color3.fromRGB(40, 40, 45), 1)

        local Keybox = UI:Create("TextBox", {
            Parent = InputContainer,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = "Paste your key here...",
            PlaceholderColor3 = Color3.fromRGB(70, 70, 80),
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            ClearTextOnFocus = false
        })

        local ButtonGrid = UI:Create("Frame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 0, 45),
            Position = UDim2.new(0, 0, 0, 95),
            BackgroundTransparency = 1
        })
        local UIList = Instance.new("UIListLayout", ButtonGrid)
        UIList.FillDirection = Enum.FillDirection.Horizontal
        UIList.Padding = UDim.new(0, 12)

        local function CreateBtn(text, color, callback)
            local b = UI:Create("TextButton", {
                Parent = ButtonGrid,
                Size = UDim2.new(0.333, -8, 1, 0),
                BackgroundColor3 = Color3.fromRGB(25, 25, 28),
                Text = text,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false
            })
            UI:AddCorner(b, 8)
            UI:AddStroke(b, Color3.fromRGB(50, 50, 55))
            b.MouseEnter:Connect(function() b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1) end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(25, 25, 28); b.TextColor3 = Color3.fromRGB(200, 200, 200) end)
            b.MouseButton1Click:Connect(callback)
        end

        -- [[ อัปเดตปุ่มเรียก Link Key ]]
        CreateBtn("GET KEY", Color3.fromRGB(46, 204, 113), function() 
            coppy(PandaAuth.GetKeyURL())
            NotifyCustom("Success", "Link Copied to Clipboard!") 
        end)
        
        CreateBtn("DISCORD", Color3.fromRGB(88, 101, 242), function() coppy(config.Discord); NotifyCustom("Success", "Discord Copied!") end)
        CreateBtn("LOGIN", Color3.fromRGB(192, 57, 43), function() VerifyKey(Keybox.Text, config.File) end)

        -- FOOTER
        local StatusContainer = UI:Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, -48, 0, 20),
            Position = UDim2.new(0, 24, 1, -30),
            BackgroundTransparency = 1
        })

        local StatusText = UI:Create("TextLabel", {
            Parent = StatusContainer,
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "Secured by PandaAuth New API",
            TextColor3 = Color3.fromRGB(70, 70, 80),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local VersionText = UI:Create("TextLabel", {
            Parent = StatusContainer,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "v1.1.0",
            TextColor3 = Color3.fromRGB(50, 50, 60),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        DraggFunction(MainFrame)
    end
    return Task
end

-- ===================== EXECUTION =====================
local KeySys = CreateKeySystem()
KeySys:Window({
    File = "Lumedev/savedkey.txt",
    DisplayName = "Lume.Dev"
})