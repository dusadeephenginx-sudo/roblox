local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")

local ScriptConfig = {
    {
        Name = "Sailor Script",
        Url = 'https://raw.githubusercontent.com/zazazawX/SSS/main/uploads/lumedev_sailor.lua',
        Ids = {
            77747658251236, 
            75159314259063,
            99684056491472,
            123955125827131,
            96767841099256,
        }
    },
    {
        Name = "Reign Script",
        Url = 'https://raw.githubusercontent.com/zazazawX/SSS/main/uploads/lumedev_reign.lua',
        Ids = {
            78466992256287,
        }
    },
    {
        Name = "Rogue Script",
        Url = 'https://raw.githubusercontent.com/zazazawX/SSS/main/uploads/lumedev_rogue.lua',
        Ids = {
            96105075537655,
            84988808589910,
        }
    },
}


local MapScripts = {}

for _, config in pairs(ScriptConfig) do
    for _, mapId in pairs(config.Ids) do
        MapScripts[mapId] = function()
            print("กำลังรันสคริปต์: " .. config.Name)
            loadstring(game:HttpGet(config.Url))()
        end
    end
end

local function RunScriptByMap()
    if MapScripts[PlaceId] then
        local success, err = pcall(MapScripts[PlaceId])
        if not success then
            warn("เกิดข้อผิดพลาดในการรันสคริปต์ (" .. PlaceId .. "): " .. tostring(err))
        end
    else
        print("ไม่พบสคริปต์เฉพาะสำหรับแมพไอดี: " .. PlaceId)
        print("กำลังรันสคริปต์พื้นฐาน (Universal Script)...")
    end
end


RunScriptByMap()



