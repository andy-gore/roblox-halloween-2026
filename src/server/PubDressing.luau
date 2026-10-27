--!strict
local Props = require(script.Parent.PubProps)
local Dressing = {}
local timber = Color3.fromRGB(36, 26, 24)
local brass = Color3.fromRGB(158, 113, 51)
local stone = Color3.fromRGB(79, 77, 85)
function Dressing.build(map: Folder)
    local decor = Instance.new("Folder")
    decor.Name = "GothicDressing"
    local function p(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
        return Props.part(decor, name, size, CFrame.new(position), color, material)
    end
    local function beam(a: Vector3, b: Vector3, width: number, color: Color3)
        return Props.part(decor, "GothicTimber", Vector3.new(width, width, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), color)
    end
    local function light(parent: BasePart, color: Color3, range: number, brightness: number, powered: boolean)
        local l = Instance.new("PointLight")
        l.Name = if powered then "PowerLight" else "Firelight"
        l.Color, l.Range, l.Brightness, l.Shadows = color, range, brightness, true
        l.Parent = parent
    end
    -- Keep the existing furniture blocks as invisible authoritative collision proxies.
    for _, object in map:GetChildren() do
        if object:IsA("Part") then
            if object.Name == "PubTable" or object.Name == "SnugTable" or object.Name == "OfficeDesk" then
                object.Transparency = 1
                Props.table(decor, CFrame.new(object.Position.X, 0.5, object.Position.Z), Vector3.new(object.Size.X / 7, 1, object.Size.Z / 6))
            elseif object.Name == "CellarBarrel" then
                object.Transparency = 1
                Props.barrel(decor, CFrame.new(object.Position.X, -15.5, object.Position.Z))
            elseif string.find(object.Name, "Wall") or object.Name == "OfficeSnugPartition" then
                object.Material, object.Color = Enum.Material.Plaster, Color3.fromRGB(107, 100, 110)
            elseif object.Name == "MainFloor" or object.Name == "EastFrontFloor" or object.Name == "EastBackFloor" then
                object.Color = Color3.fromRGB(59, 37, 29)
            end
        end
    end
    -- Chairs are tucked against their tables, outside the tested walking lanes.
    for _, x in {-17, 25} do
        Props.chair(decor, CFrame.new(x, 0.5, 33.3))
    end
    Props.chair(decor, CFrame.new(-41, 0.5, -3) * CFrame.Angles(0, -math.pi / 2, 0))
    Props.chair(decor, CFrame.new(-37, 0.5, -37.3) * CFrame.Angles(0, math.pi, 0))
    -- Bar front, carved panels and shelves; warning and bell retain their exact positions.
    local bar = map:FindFirstChild("Bar") :: Part
    bar.Color, bar.Material = timber, Enum.Material.Wood
    p("OakBarTop", Vector3.new(19, 0.22, 4.5), Vector3.new(-27, 4.5, 17), Color3.fromRGB(94, 49, 30))
    for _, x in {-34, -30.5, -27, -23.5, -20} do
        p("BarPanel", Vector3.new(2.9, 2.7, 0.15), Vector3.new(x, 2.6, 19.1), Color3.fromRGB(77, 38, 28))
        p("BarPanelInlay", Vector3.new(2.3, 0.08, 0.08), Vector3.new(x, 3.65, 19.22), brass, Enum.Material.Metal)
    end
    for _, y in {5.3, 7.5} do
        p("BackBarShelf", Vector3.new(15, 0.25, 1.4), Vector3.new(-28, y, 9.2), timber)
        for i = 0, 6 do
            local bottle = p("DustyBottle", Vector3.new(0.5, 1.3, 0.5), Vector3.new(-34 + i * 2, y + 0.8, 9.2), Color3.fromRGB(46, 67 + i * 3, 54), Enum.Material.Glass)
            bottle.Transparency = 0.15
            p("BottleNeck", Vector3.new(0.24, 0.45, 0.24), bottle.Position + Vector3.new(0, 0.85, 0), Color3.fromRGB(47, 69, 53), Enum.Material.Glass)
        end
    end
    -- Timber posts and wainscot are decorative, flush with the outer walls.
    for _, x in {-47.3, 47.3} do
        for _, z in {-38, -16, 7, 38} do p("OakPost", Vector3.new(0.7, 14, 0.8), Vector3.new(x, 7, z), timber) end
        p("WallDado", Vector3.new(0.28, 2.8, 78), Vector3.new(x, 1.9, 0), timber)
        p("BrassDadoRail", Vector3.new(0.4, 0.12, 78), Vector3.new(x, 3.35, 0), brass)
    end
    for _, z in {-39.3, 39.3} do
        for _, x in {-46, -16, 22, 46} do p("OakPost", Vector3.new(0.8, 14, 0.7), Vector3.new(x, 7, z), timber) end
    end
    for _, z in {-34, -8, 18, 36} do
        beam(Vector3.new(-48, 29.7, z), Vector3.new(0, 41.7, z), 0.85, timber)
        beam(Vector3.new(0, 41.7, z), Vector3.new(48, 29.7, z), 0.85, timber)
        beam(Vector3.new(-48, 13.2, z), Vector3.new(48, 13.2, z), 0.7, timber)
    end
    -- A vaulted slate roof closes the daylight opening without changing walking collision.
    local angle = math.atan(12 / 48)
    for _, side in {-1, 1} do
        local roof = p("SlateRoof", Vector3.new(math.sqrt(48 * 48 + 12 * 12) + 1, 0.8, 82), Vector3.new(side * 24, 36, 0), Color3.fromRGB(34, 33, 47), Enum.Material.Slate)
        roof.CFrame *= CFrame.Angles(0, 0, -side * angle)
        roof.CanQuery = true -- lets the third-person camera avoid the roof
    end
    -- Pointed stained-glass panels: blue/purple glass, lead tracery and brass corners.
    local function window(origin: CFrame)
        local function panel(name: string, size: Vector3, localCF: CFrame, color: Color3, material: Enum.Material?)
            return Props.part(decor, name, size, origin * localCF, color, material)
        end
        panel("WindowRecess", Vector3.new(9.2, 10.2, 0.25), CFrame.new(0, 7.5, 0.08), timber)
        panel("StainedGlass", Vector3.new(7.6, 5.8, 0.1), CFrame.new(0, 6, -0.1), Color3.fromRGB(43, 60, 102), Enum.Material.Neon)
        panel("PointedGlass", Vector3.new(4.2, 4.2, 0.1), CFrame.new(0, 9.5, -0.12) * CFrame.Angles(0, 0, math.pi / 4), Color3.fromRGB(81, 47, 105), Enum.Material.Neon)
        for _, x in {-4.1, 0, 4.1} do panel("LeadMullion", Vector3.new(0.18, 6.2, 0.3), CFrame.new(x, 6, -0.25), timber, Enum.Material.Metal) end
        for _, y in {3, 6, 9} do panel("LeadCrossbar", Vector3.new(8.3, 0.16, 0.3), CFrame.new(0, y, -0.25), timber, Enum.Material.Metal) end
        for _, side in {-1, 1} do
            local a, b = origin:PointToWorldSpace(Vector3.new(side * 4.1, 9, -0.25)), origin:PointToWorldSpace(Vector3.new(0, 12.5, -0.25))
            beam(a, b, 0.28, brass)
        end
        for _, x in {-2, 2} do
            for _, y in {4.5, 7.5} do panel("GlassDiamond", Vector3.new(0.8, 0.8, 0.12), CFrame.new(x, y, -0.24) * CFrame.Angles(0, 0, math.pi / 4), Color3.fromRGB(116, 58, 87), Enum.Material.Neon) end
        end
    end
    for _, z in {-28, 26} do window(CFrame.new(-47.35, 0, z) * CFrame.Angles(0, -math.pi / 2, 0)) end
    for _, z in {-27, 27} do window(CFrame.new(47.35, 0, z) * CFrame.Angles(0, math.pi / 2, 0)) end
    -- A fireplace in the snug, flush to its far wall and away from the key route.
    p("FireplaceBacking", Vector3.new(1, 10, 11), Vector3.new(-46.5, 5.5, -3), stone, Enum.Material.Slate)
    p("FireplaceOpening", Vector3.new(0.2, 5, 6), Vector3.new(-45.9, 3.3, -3), Color3.fromRGB(17, 13, 18))
    for _, z in {-7, 1} do p("StoneFireplaceJamb", Vector3.new(1.5, 6, 1.4), Vector3.new(-45.3, 3.5, z), stone, Enum.Material.Slate) end
    p("StoneMantel", Vector3.new(2.2, 0.8, 10), Vector3.new(-45.3, 6.6, -3), stone, Enum.Material.Slate)
    p("Hearth", Vector3.new(3, 0.15, 10), Vector3.new(-45.3, 0.6, -3), stone, Enum.Material.Slate)
    local coal = p("GlowingCoals", Vector3.new(0.8, 0.3, 4), Vector3.new(-45.3, 1, -3), Color3.fromRGB(255, 105, 34), Enum.Material.Neon)
    local fire = Instance.new("Fire")
    fire.Size, fire.Heat = 3, 0
    fire.Color, fire.SecondaryColor = Color3.fromRGB(255, 156, 58), Color3.fromRGB(153, 52, 36)
    fire.Parent = coal
    light(coal, Color3.fromRGB(255, 160, 78), 24, 2.2, false)
    -- Candle chandeliers and wall sconces; all lights remain readable before power.
    for _, center in {Vector3.new(-10, 10.5, 27), Vector3.new(28, 10.5, 25), Vector3.new(-34, 10.5, -29), Vector3.new(-34, 10.5, -5)} do
        p("ChandelierStem", Vector3.new(0.12, 5, 0.12), center + Vector3.new(0, 2.5, 0), brass, Enum.Material.Metal)
        p("CandleArm", Vector3.new(4.6, 0.16, 0.16), center, brass, Enum.Material.Metal)
        for _, x in {-2, 0, 2} do
            p("WaxCandle", Vector3.new(0.28, 0.75, 0.28), center + Vector3.new(x, 0.45, 0), Color3.fromRGB(228, 207, 162))
            local flame = p("CandleFlame", Vector3.new(0.2, 0.4, 0.2), center + Vector3.new(x, 1, 0), Color3.fromRGB(255, 183, 82), Enum.Material.Neon)
            flame.Shape = Enum.PartType.Ball
            if x == 0 then light(flame, Color3.fromRGB(255, 189, 108), 27, 0.9, false) end
        end
    end
    -- Stair rails sit outside the walking lane and preserve the bright tread markers.
    for _, x in {25, 47} do
        beam(Vector3.new(x, 3.5, 7), Vector3.new(x, -11.5, -23), 0.22, brass)
        for step = 0, 15, 3 do
            p("StairBaluster", Vector3.new(0.14, 3, 0.14), Vector3.new(x, 2 - step, 7 - step * 2), timber, Enum.Material.Metal)
        end
    end
    -- Kitchen and office details, deliberately kept at the back of existing furniture.
    p("OfficeRunner", Vector3.new(8, 0.04, 3), Vector3.new(-37, 3.53, -33), Color3.fromRGB(93, 28, 46), Enum.Material.Fabric)
    for _, x in {-40, -39.3, -38.6} do p("OldLedger", Vector3.new(0.5, 1.2, 0.8), Vector3.new(x, 4.1, -34.5), Color3.fromRGB(73, 42, 38)) end
    p("KitchenWorktop", Vector3.new(6.2, 0.2, 20.2), Vector3.new(19, 3.6, -25), Color3.fromRGB(142, 135, 124), Enum.Material.Marble)
    local trim = p("ExitBrassHandle", Vector3.new(2, 0.25, 0.3), Vector3.new(-36, 5.5, 39.25), brass, Enum.Material.Metal)
    trim.Name = "ExitHandle"
    -- Original broad greybox light blocks become lantern fixtures.
    for _, object in map:GetChildren() do
        if object:IsA("Part") and object.Name == "PubLamp" then
            object.Color, object.Material, object.Transparency = brass, Enum.Material.Metal, 0
            local glow = p("LanternGlass", Vector3.new(0.8, 1.1, 0.8), object.Position - Vector3.new(0, 0.5, 0), Color3.fromRGB(255, 190, 100), Enum.Material.Neon)
            for _, side in {-1, 1} do p("LanternIron", Vector3.new(0.1, 1.4, 0.1), glow.Position + Vector3.new(side * 0.45, 0, 0.45), timber, Enum.Material.Metal) end
        end
    end
    decor.Parent = map
end
return Dressing
