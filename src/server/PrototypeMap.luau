--!strict
-- Only used by the separate prototype project. Never replaces an authored map.
local Map = {}
function Map.build(): Folder
    local folder = Instance.new("Folder")
    folder.Name = "LastOrdersPrototype"
    local function part(name: string, size: Vector3, position: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = position
        p.Color = color
        p.Anchored = true
        p.Parent = folder
        return p
    end
    local wood = Color3.fromRGB(87, 62, 46)
    part("PubFloor", Vector3.new(64, 1, 56), Vector3.new(0, 0, 0), wood)
    part("BackWall", Vector3.new(64, 12, 1), Vector3.new(0, 6, -28), wood)
    part("WestWall", Vector3.new(1, 12, 56), Vector3.new(-32, 6, 0), wood)
    part("EastWall", Vector3.new(1, 12, 56), Vector3.new(32, 6, 0), wood)
    part("FrontLeft", Vector3.new(48, 12, 1), Vector3.new(-8, 6, 28), wood)
    part("FrontRight", Vector3.new(8, 12, 1), Vector3.new(28, 6, 28), wood)
    part("EscapePath", Vector3.new(12, 1, 26), Vector3.new(20, 0, 40), wood)
    part("Bar", Vector3.new(16, 4, 3), Vector3.new(-17, 2.5, -8), wood)
    local function station(name: string, position: Vector3, text: string, color: Color3)
        local p = part(name, Vector3.new(3, 3, 3), position, color)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = text
        prompt.ObjectText = name
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = true
        prompt.Parent = p
    end
    station("Warning", Vector3.new(-17, 6, -8), "Read warning", Color3.fromRGB(230, 215, 170))
    station("CellarFuseBox", Vector3.new(-25, 2, -22), "Restore power", Color3.fromRGB(95, 135, 160))
    station("OfficeKey", Vector3.new(24, 2, -20), "Take exit key", Color3.fromRGB(240, 195, 65))
    station("Bell", Vector3.new(-22, 2, 16), "Ring bell", Color3.fromRGB(210, 160, 65))
    station("Tankard", Vector3.new(12, 2, -5), "Steal tankard", wood)
    station("EmergencyExit", Vector3.new(20, 2, 27), "Unlock and escape", Color3.fromRGB(65, 160, 90))
    local monster = part("ChuggernaughtPlaceholder", Vector3.new(4, 8, 4), Vector3.new(12, 4.5, -16), Color3.fromRGB(145, 70, 80))
    monster.CanCollide = false
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PrototypeSpawn"
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(0, 1, 20)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Parent = folder
    folder.Parent = workspace
    return folder
end
return Map
