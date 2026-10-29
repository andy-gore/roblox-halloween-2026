--!strict
-- Disposable greybox only; never replaces the Studio-authored place.
local Map = {}
function Map.build(): Folder
    local folder = Instance.new("Folder")
    folder.Name = "LastOrdersPrototype"
    local wood = Color3.fromRGB(83, 57, 40)
    local plaster = Color3.fromRGB(153, 139, 115)
    local stone = Color3.fromRGB(77, 80, 86)
    local function part(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
        local p = Instance.new("Part")
        p.Name, p.Size, p.Position, p.Color = name, size, position, color
        p.Material = material or Enum.Material.WoodPlanks
        p.Anchored = true
        p.Parent = folder
        return p
    end
    local function sign(name: string, text: string, position: Vector3, width: number): Part
        local board = part(name, Vector3.new(width, 3, 0.3), position, Color3.fromRGB(28, 22, 18))
        board.CanCollide, board.CanQuery = false, false
        for _, face in {Enum.NormalId.Front, Enum.NormalId.Back} do
            local surface = Instance.new("SurfaceGui")
            surface.Face = face
            surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            surface.PixelsPerStud = 60
            surface.LightInfluence, surface.Brightness = 0, 2
            surface.Parent = board
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(0.94, 0.88)
            label.Position = UDim2.fromScale(0.03, 0.06)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 241, 204)
            label.TextScaled, label.TextWrapped = true, true
            label.Font = Enum.Font.GothamBold
            label.Text = text
            label.Parent = surface
        end
        return board
    end
    local function station(name: string, position: Vector3, text: string, color: Color3): Part
        local p = part(name, Vector3.new(1.5, 1, 1.5), position, color, Enum.Material.Metal)
        p.CanCollide = false
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText, prompt.ObjectText = text, name
        prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 10, true
        prompt.Parent = p
        if name == "OfficeKey" then
            p.Transparency, prompt.Enabled = 1, false
        end
        return p
    end
    -- Ground level, with a real opening for the cellar stairs in the east wing.
    part("MainFloor", Vector3.new(72, 1, 80), Vector3.new(-12, 0, 0), wood)
    part("EastFrontFloor", Vector3.new(24, 1, 32), Vector3.new(36, 0, 24), wood)
    part("EastBackFloor", Vector3.new(24, 1, 16), Vector3.new(36, 0, -32), wood)
    part("NorthWall", Vector3.new(97, 14, 1), Vector3.new(0, 7, -40), plaster)
    part("WestWall", Vector3.new(1, 14, 80), Vector3.new(-48, 7, 0), plaster)
    part("EastWall", Vector3.new(1, 14, 80), Vector3.new(48, 7, 0), plaster)
    -- Emergency doorway, twelve studs wide. Front entrance remains visibly jammed.
    part("SouthLeft", Vector3.new(6, 14, 1), Vector3.new(-45, 7, 40), plaster)
    part("SouthRight", Vector3.new(78, 14, 1), Vector3.new(9, 7, 40), plaster)
    part("ExitLintel", Vector3.new(12, 3, 1), Vector3.new(-36, 12.5, 40), wood)
    part("ExitDoor", Vector3.new(12, 11, 1), Vector3.new(-36, 6, 40), Color3.fromRGB(53, 91, 66))
    part("JammedEntrance", Vector3.new(9, 10, 0.5), Vector3.new(6, 5.5, 39.3), wood)
    sign("EntranceLabel", "FRONT DOOR — JAMMED", Vector3.new(6, 11.5, 38.8), 13)
    sign("ExitLabel", "EMERGENCY EXIT", Vector3.new(-36, 12.5, 39.3), 12)
    -- Northern rooms open onto a central hall; all openings are at least ten studs wide.
    for _, x in {-16, 0} do
        part("HallWallNorth", Vector3.new(1, 14, 6), Vector3.new(x, 7, -37), plaster)
        part("HallWallMiddle", Vector3.new(1, 14, 12), Vector3.new(x, 7, -18), plaster)
        part("HallWallSouth", Vector3.new(1, 14, 6), Vector3.new(x, 7, 5), plaster)
    end
    part("OfficeSnugPartition", Vector3.new(32, 14, 1), Vector3.new(-32, 7, -16), plaster)
    part("KitchenStairWall", Vector3.new(1, 14, 48), Vector3.new(24, 7, -16), plaster)
    for _, segment in {{-40, 16}, {-18, 4}, {6, 12}, {46, 4}} do
        part("RoomFrontWall", Vector3.new(segment[2], 14, 1), Vector3.new(segment[1], 7, 8), plaster)
    end
    sign("HallLabel", "OFFICE  /  KITCHEN", Vector3.new(-8, 10, -38.9), 14).Orientation = Vector3.new(0, 180, 0)
    sign("SnugLabel", "THE SNUG", Vector3.new(-34, 10, -15.2), 12).Orientation = Vector3.new(0, 180, 0)
    require(script.Parent.CellarMap).build(folder)
    -- Low furniture leaves a generous route through each room.
    part("Bar", Vector3.new(18, 4, 4), Vector3.new(-27, 2.5, 17), wood)
    part("OfficeDesk", Vector3.new(10, 3, 5), Vector3.new(-37, 2, -33), wood)
    part("SnugTable", Vector3.new(8, 3, 6), Vector3.new(-36, 2, -3), wood)
    part("KitchenCounter", Vector3.new(6, 3, 20), Vector3.new(19, 2, -25), stone)
    for _, x in {-17, 25} do
        part("PubTable", Vector3.new(7, 3, 6), Vector3.new(x, 2, 29), wood)
    end
    sign("PubName", "THE FIREFLY TAVERN", Vector3.new(-22, 11, 9), 23).Orientation = Vector3.new(0, 180, 0)
    -- Put the note on the customer-facing side, clear of the counter and bar top.
    local warning = station("Warning", Vector3.new(-27, 3.2, 19.4), "Read staff note", Color3.fromRGB(230, 215, 170))
    warning.Size, warning.Material = Vector3.new(5, 1.8, 0.12), Enum.Material.SmoothPlastic
    local warningPrompt = warning:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    warningPrompt.ObjectText = "Staff note"
    -- Server distance and eye-level wall checks still apply; camera occlusion must not hide this prompt.
    warningPrompt.RequiresLineOfSight = false
    local paper = Instance.new("SurfaceGui")
    paper.Face, paper.SizingMode = Enum.NormalId.Back, Enum.SurfaceGuiSizingMode.PixelsPerStud
    paper.PixelsPerStud, paper.LightInfluence = 80, 0
    paper.Parent = warning
    local writing = Instance.new("TextLabel")
    writing.Size, writing.Position = UDim2.fromScale(0.92, 0.86), UDim2.fromScale(0.04, 0.07)
    writing.BackgroundTransparency = 1
    writing.TextColor3 = Color3.fromRGB(35, 22, 24)
    writing.Font, writing.TextScaled = Enum.Font.GothamBold, true
    writing.Text = "EMERGENCY EXIT LOCKED\nRESTORE LIGHTS · FIND THE KEY"
    writing.Parent = paper
    station("Bell", Vector3.new(-20, 5, 17), "Ring bell", Color3.fromRGB(210, 160, 65))
    local key = station("OfficeKey", Vector3.new(-37, 4, -33), "Take exit key", Color3.fromRGB(240, 195, 65))
    key.Size = Vector3.new(1.5, 0.3, 0.7)
    local keyPrompt = key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    keyPrompt.ObjectText = "Emergency exit key"
    station("EmergencyExit", Vector3.new(-36, 5, 38), "Unlock and escape", Color3.fromRGB(65, 160, 90))
    -- Lamps stay dim before power so the route remains readable.
    for _, position in {Vector3.new(-24, 11, 22), Vector3.new(-35, 11, -28), Vector3.new(-35, 11, -5), Vector3.new(-8, 11, -20), Vector3.new(12, 11, -20), Vector3.new(36, 11, 10), Vector3.new(40, -3, -32)} do
        local lamp = part("PubLamp", Vector3.new(1.5, 0.5, 1.5), position, Color3.fromRGB(255, 184, 90), Enum.Material.Neon)
        lamp.CanCollide = false
        local light = Instance.new("PointLight")
        light.Name = "PowerLight"
        light.Color, light.Range, light.Brightness = lamp.Color, 32, 0.35
        light.Shadows = true
        light.Parent = lamp
    end
    part("EscapePath", Vector3.new(16, 1, 32), Vector3.new(-36, 0, 56), stone)
    sign("OutsideSign", "THE FIREFLY TAVERN — ROOMS AVAILABLE", Vector3.new(6, 12, 41), 24).Orientation = Vector3.new(0, 180, 0)
    local spawn = Instance.new("SpawnLocation")
    spawn.Name, spawn.Size, spawn.Position = "PrototypeSpawn", Vector3.new(6, 1, 6), Vector3.new(6, 1, 30)
    spawn.Anchored, spawn.Neutral, spawn.Transparency = true, true, 1
    spawn.Parent = folder
    require(script.Parent.PubExpansion).build(folder)
    require(script.Parent.PubDressing).build(folder)
    folder.Parent = workspace
    require(script.Parent.PubExterior).build(folder)
    require(script.Parent.ExteriorFinish).build(folder)
    require(script.Parent.JourneyMap).build(folder)
    require(script.Parent.TavernArchitecture).build(folder)
    require(script.Parent.AssetDressing).build(folder)
    require(script.Parent.InteriorFinish).build(folder)
    require(script.Parent.TavernSigns).build(folder)
    require(script.Parent.PubBoundary).build(folder)
    return folder
end
return Map
