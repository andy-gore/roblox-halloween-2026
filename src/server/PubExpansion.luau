--!strict
-- Hand-authored extension of the disposable pub; original Studio geometry is untouched.
local Props = require(script.Parent.PubProps)
local Expansion = {}
local centers = {-30, -10, 10, 30}
function Expansion.build(map: Folder)
    local wood = Color3.fromRGB(59, 37, 29)
    local plaster = Color3.fromRGB(107, 100, 110)
    local brass = Color3.fromRGB(158, 113, 51)
    local function solid(name: string, size: Vector3, pos: Vector3, material: Enum.Material?): Part
        local p = Instance.new("Part")
        p.Name, p.Size, p.Position, p.Color = name, size, pos, plaster
        p.Material, p.Anchored, p.CanCollide = material or Enum.Material.Plaster, true, true
        p:SetAttribute("BlocksNavigation", not string.find(name, "Floor") and not string.find(name, "Step"))
        p.Parent = map
        return p
    end
    local decor = Instance.new("Folder")
    decor.Name = "GuestWingDressing"
    decor.Parent = map
    local function detail(name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?): Part
        return Props.part(decor, name, size, CFrame.new(pos), color, material)
    end
    local function label(text: string, position: Vector3, rotation: number, width: number)
        local board = detail("GuestSign", Vector3.new(width, 1.7, 0.15), position, Color3.fromRGB(31, 23, 26))
        board.CFrame *= CFrame.Angles(0, rotation, 0)
        for _, face in {Enum.NormalId.Front, Enum.NormalId.Back} do
            local surface = Instance.new("SurfaceGui")
            surface.Face, surface.SizingMode = face, Enum.SurfaceGuiSizingMode.PixelsPerStud
            surface.PixelsPerStud, surface.LightInfluence = 60, 0
            surface.Parent = board
            local textLabel = Instance.new("TextLabel")
            textLabel.Size, textLabel.BackgroundTransparency = UDim2.fromScale(1, 1), 1
            textLabel.TextColor3, textLabel.Font = Color3.fromRGB(255, 225, 166), Enum.Font.GothamBold
            textLabel.TextScaled, textLabel.Text = true, text
            textLabel.Parent = surface
        end
    end
    local function lamp(position: Vector3)
        local base = detail("GuestLantern", Vector3.new(0.6, 0.9, 0.6), position, Color3.fromRGB(255, 190, 100), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Name, light.Color, light.Brightness, light.Range = "PowerLight", base.Color, 0.35, 30
        light.Shadows, light.Parent = true, base
    end
    -- The larger lounge occupies a south-east extension; the existing exit remains outdoors.
    local formerWall = map:FindFirstChild("SouthRight") :: Part
    formerWall.Size, formerWall.Position = Vector3.new(46, 14, 1), Vector3.new(-7, 7, 40)
    formerWall:SetAttribute("BlocksNavigation", true)
    solid("LoungeEntryWall", Vector3.new(8, 14, 1), Vector3.new(44, 7, 40))
    local floor = solid("LoungeFloor", Vector3.new(56, 1, 48), Vector3.new(20, 0, 64), Enum.Material.WoodPlanks)
    floor.Color = wood
    solid("LoungeWestWall", Vector3.new(1, 30, 48), Vector3.new(-8, 15, 64))
    solid("LoungeEastWall", Vector3.new(1, 30, 48), Vector3.new(48, 15, 64))
    solid("LoungeSouthWall", Vector3.new(56, 30, 1), Vector3.new(20, 15, 88))
    for _, name in {"JammedEntrance", "EntranceLabel", "OutsideSign"} do
        local object = map:FindFirstChild(name) :: BasePart
        object.Position += Vector3.new(0, 0, 48)
    end
    label("GUEST ROOMS — UPSTAIRS", Vector3.new(27, 10, 41), 0, 19)
    label("BAR  /  CELLAR", Vector3.new(6, 7, 41), 0, 12)
    label("ROOMS 1–8\nSTAIRS UP", Vector3.new(43, 6, 80), 0, 8)
    -- First-floor slab and broad landing. No slab is placed across the stair opening.
    local upper = solid("GuestFloor", Vector3.new(96, 1, 80), Vector3.new(0, 16, 0), Enum.Material.WoodPlanks)
    upper.Color = wood
    local landing = solid("GuestLandingFloor", Vector3.new(56, 1, 8), Vector3.new(20, 16, 44), Enum.Material.WoodPlanks)
    landing.Color = wood
    solid("GuestNorthWall", Vector3.new(97, 14, 1), Vector3.new(0, 23.5, -40))
    for _, x in {-48, 48} do solid("GuestOuterWall", Vector3.new(1, 14, 80), Vector3.new(x, 23.5, 0)) end
    for _, x in {-28, 28} do solid("GuestSouthWall", Vector3.new(40, 14, 1), Vector3.new(x, 23.5, 40)) end
    -- Ground floor and landing supply the end surfaces; do not overlay coplanar treads.
    for step = 0, 16 do
        local y, z = step, 78 - step * 2
        if step > 0 and step < 16 then
            solid("GuestStep", Vector3.new(24, 1, 2), Vector3.new(28, y, z), Enum.Material.WoodPlanks).Color = wood
        end
        detail("GuestStairEdge", Vector3.new(23, 0.06, 0.15), Vector3.new(28, y + 0.55, z - 0.85), brass, Enum.Material.Neon)
    end
    for _, x in {15.5, 40.5} do
        for step = 0, 16, 2 do
            detail("GuestBaluster", Vector3.new(0.15, 3, 0.15), Vector3.new(x, step + 2, 78 - step * 2), brass, Enum.Material.Metal)
        end
        local a, b = Vector3.new(x, 3.5, 78), Vector3.new(x, 19.5, 46)
        Props.part(decor, "GuestStairRail", Vector3.new(0.25, 0.25, (b-a).Magnitude), CFrame.lookAt((a+b)/2,b), brass)
        -- Stop the solid rail short of the landing so it cannot catch a turning avatar.
        local ga,gb=a-Vector3.new(0,1.3,0),b+Vector3.new(0,-2.3,2)
        local guard = solid("GuestStairGuard", Vector3.new(0.3, 3, (gb-ga).Magnitude), (ga+gb)/2)
        guard.CFrame = CFrame.lookAt(guard.Position, gb)
        guard.Transparency = 1
    end
    -- Guard the edges of the landing without obstructing the central stair mouth.
    for _, span in {{4, 24}, {44, 8}} do
        detail("LandingRail", Vector3.new(span[2], 0.3, 0.3), Vector3.new(span[1], 19.5, 47.5), brass)
        solid("GuestLandingGuard", Vector3.new(span[2],3,0.3), Vector3.new(span[1],18,47.5)).Transparency=1
        for x = span[1] - span[2]/2, span[1] + span[2]/2, 3 do
            detail("LandingBaluster", Vector3.new(0.15, 3, 0.15), Vector3.new(x, 18, 47.5), brass)
        end
    end
    -- Markers choose one fixed location per run; they are not collectible objects themselves.
    local locations = Instance.new("Folder")
    locations.Name, locations.Parent = "KeyLocations", map
    local function marker(name: string, position: Vector3)
        local spot = Instance.new("Part")
        spot.Name, spot.Size, spot.Position = name, Vector3.one, position
        spot.Anchored, spot.CanCollide, spot.CanTouch, spot.CanQuery, spot.Transparency = true, false, false, false, 1
        spot.Parent = locations
    end
    marker("Office", (map:FindFirstChild("OfficeKey") :: Part).Position)
    for sideIndex, side in {-1, 1} do
        -- Four separate doorways along each side of the sixteen-stud corridor.
        for roomIndex, z in centers do
            local number = (sideIndex - 1) * 4 + roomIndex
            for _, edge in {-1, 1} do
                solid("BedroomDoorWall", Vector3.new(1, 14, 4), Vector3.new(side * 8, 23.5, z + edge * 8))
            end
            solid("BedroomDoorLintel", Vector3.new(1, 3, 12), Vector3.new(side * 8, 29, z))
            label("ROOM " .. number, Vector3.new(side * 7.35, 25.8, z), math.pi/2, 9)
            -- Beds, dresser and wardrobe are kept against the outer half of each room.
            local bed = solid("BedroomBed", Vector3.new(4.6, 2.6, 7.1), Vector3.new(side * 40, 17.8, z + 3), Enum.Material.Wood)
            bed.Color = Color3.fromRGB(46, 28, 26)
            detail("IvoryMattress", Vector3.new(4.4, 0.65, 6.8), Vector3.new(side * 40, 18.6, z + 3), Color3.fromRGB(213, 197, 164), Enum.Material.Fabric)
            detail("BurgundyBedspread", Vector3.new(4.45, 0.2, 4.5), Vector3.new(side * 40, 19, z + 4), Color3.fromRGB(90 + number * 3, 28, 45), Enum.Material.Fabric)
            detail("IvoryPillow", Vector3.new(3.5, 0.4, 1.2), Vector3.new(side * 40, 19.1, z + 0.3), Color3.fromRGB(233, 219, 188), Enum.Material.Fabric)
            solid("BedroomHeadboard", Vector3.new(4.8, 3.8, 0.3), Vector3.new(side * 40, 18.4, z - 0.5), Enum.Material.Wood).Color = wood
            local dresser = solid("BedroomDresser", Vector3.new(5, 3, 2.4), Vector3.new(side * 25, 18, z - 6), Enum.Material.Wood)
            dresser.Color = wood
            for _, y in {17.2, 18.1, 19} do
                detail("DresserDrawer", Vector3.new(4.7, 0.7, 0.12), Vector3.new(side * 25, y, z - 4.75), Color3.fromRGB(89, 47, 30))
                detail("BrassDrawerHandle", Vector3.new(0.8, 0.1, 0.2), Vector3.new(side * 25, y, z - 4.6), brass, Enum.Material.Metal)
            end
            local wardrobe = solid("BedroomWardrobe", Vector3.new(4.3, 7, 2.7), Vector3.new(side * 43, 20, z - 6), Enum.Material.Wood)
            wardrobe.Color = wood
            detail("WardrobeBrass", Vector3.new(0.12, 1.2, 0.15), Vector3.new(side * 43, 20, z - 4.55), brass, Enum.Material.Metal)
            marker(string.format("Room%02d", number), Vector3.new(side * 25, 20, z - 5.6))
            lamp(Vector3.new(side * 23, 27, z))
        end
        for _, z in {-20, 0, 20} do solid("BedroomPartition", Vector3.new(40, 14, 1), Vector3.new(side * 28, 23.5, z)) end
    end
    for _, z in centers do
        lamp(Vector3.new(0, 27, z))
        detail("CorridorRunner", Vector3.new(8, 0.04, 18), Vector3.new(0, 16.53, z), Color3.fromRGB(83, 28, 44), Enum.Material.Fabric)
    end
    label("ROOMS 1–4  /  5–8", Vector3.new(0, 25.8, 39), 0, 16)
    lamp(Vector3.new(6, 11, 60))
    lamp(Vector3.new(28, 27, 62))
    lamp(Vector3.new(28, 7, 82))
    Props.table(decor, CFrame.new(-2, 0.5, 56))
    Props.chair(decor, CFrame.new(-2, 0.5, 60))
    -- Roof over the extension, separate from the raised roof over the eight bedrooms.
    for _, side in {-1, 1} do
        local roof = detail("LoungeRoof", Vector3.new(math.sqrt(28*28 + 7*7) + 1, 0.8, 48), Vector3.new(20 + side*14, 33.5, 65), Color3.fromRGB(34, 33, 47), Enum.Material.Slate)
        roof.CFrame *= CFrame.Angles(0, 0, -side * math.atan(7/28))
        roof.CanQuery = true
    end
end
function Expansion.addRoutes(positions: {Vector3}, edges: {{number}})
    local function node(position: Vector3): number
        table.insert(positions, position)
        return #positions
    end
    local function link(a: number, b: number) table.insert(edges, {a,b}) end
    local approach = node(Vector3.new(40,4.5,36))
    local entry = node(Vector3.new(28,4.5,36))
    local inner = node(Vector3.new(28,4.5,44))
    local near = node(Vector3.new(6,4.5,44))
    local south = node(Vector3.new(6,4.5,84))
    local bottom = node(Vector3.new(28,4.5,84))
    link(3,approach) link(approach,entry) link(entry,inner) link(inner,near) link(near,south) link(south,bottom)
    local previous = bottom
    for step = 0,16 do
        local current = node(Vector3.new(28,4.5+step,78-step*2))
        link(previous,current) previous=current
    end
    local landing = node(Vector3.new(28,20.5,44))
    local corridorEnd = node(Vector3.new(0,20.5,44))
    link(previous,landing) link(landing,corridorEnd)
    previous = corridorEnd
    for i = #centers,1,-1 do
        local z = centers[i]
        local hall = node(Vector3.new(0,20.5,z))
        link(previous,hall) previous=hall
        for _,side in {-1,1} do
            local door=node(Vector3.new(side*14,20.5,z))
            local room=node(Vector3.new(side*26,20.5,z))
            link(hall,door) link(door,room)
        end
    end
end
return Expansion
