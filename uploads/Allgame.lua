local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")

local ScriptConfig = {
    {
        Name = "Sailor Script",
        Url = 'https://vss.pandadevelopment.net/virtual/file/f6da0cd37d024e99',
        Ids = {
            77747658251236, 
            75159314259063,
            99684056491472,
            123955125827131,
            96767841099256,
            130167267952199,
            98826438856089,
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



