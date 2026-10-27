--!strict
-- Local Part equivalents of assets/props/pub-set/build.py; no mesh uploads.
local Props = {}
local oak = {Color3.fromRGB(66, 34, 20), Color3.fromRGB(80, 43, 25), Color3.fromRGB(93, 52, 30), Color3.fromRGB(72, 37, 23)}
local iron = Color3.fromRGB(33, 35, 39)
function Props.part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
    p.Material = material or Enum.Material.Wood
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
function Props.table(parent: Instance, origin: CFrame, scale: Vector3?)
    local s = scale or Vector3.one
    local function box(name: string, pos: Vector3, size: Vector3, color: Color3)
        Props.part(parent, name, size * s, origin * CFrame.new(pos * s), color)
    end
    for i = 0, 4 do box("TablePlank", Vector3.new(0, 2.8, (i - 2) * 1.2), Vector3.new(7, 0.4, 1.17), oak[i % 4 + 1]) end
    for _, x in {-2.65, 2.65} do
        for _, z in {-2.2, 2.2} do box("TableLeg", Vector3.new(x, 1.3, z), Vector3.new(0.48, 2.6, 0.48), oak[1]) end
        box("TableApron", Vector3.new(x, 2.35, 0), Vector3.new(0.24, 0.6, 4.5), oak[2])
        box("TableCrossRail", Vector3.new(x, 0.7, 0), Vector3.new(0.32, 0.35, 4.5), oak[2])
    end
    for _, z in {-2.2, 2.2} do box("TableApron", Vector3.new(0, 2.35, z), Vector3.new(5.4, 0.6, 0.24), oak[1]) end
    box("TableStretcher", Vector3.new(0, 0.7, 0), Vector3.new(5.5, 0.35, 0.32), oak[2])
end
function Props.chair(parent: Instance, origin: CFrame)
    local function box(name: string, pos: Vector3, size: Vector3, color: Color3)
        Props.part(parent, name, size, origin * CFrame.new(pos), color)
    end
    for i = -1, 1 do box("ChairSeat", Vector3.new(0, 1.85, i * 0.8), Vector3.new(2.5, 0.3, 0.77), oak[i + 2]) end
    for _, x in {-0.96, 0.96} do
        box("ChairBackPost", Vector3.new(x, 2.2, 0.93), Vector3.new(0.3, 4.4, 0.3), oak[1])
        box("ChairFrontLeg", Vector3.new(x, 0.85, -0.93), Vector3.new(0.34, 1.7, 0.34), oak[1])
        box("ChairRail", Vector3.new(x, 0.65, 0), Vector3.new(0.18, 0.2, 1.9), oak[2])
    end
    for _, y in {2.65, 3.75} do box("ChairBackRail", Vector3.new(0, y, 0.93), Vector3.new(2.2, 0.45, 0.26), oak[3]) end
    for _, x in {-0.55, 0, 0.55} do box("ChairSlat", Vector3.new(x, 3.2, 0.93), Vector3.new(0.2, 0.7, 0.18), oak[2]) end
    box("BurgundyCushion", Vector3.new(0, 2.04, 0), Vector3.new(2.3, 0.16, 2.1), Color3.fromRGB(90, 28, 45))
end
function Props.barrel(parent: Instance, origin: CFrame)
    for i = 0, 15 do
        local angle = i * math.pi / 8
        local stave = origin * CFrame.Angles(0, angle, 0) * CFrame.new(0, 2, 1.8)
        Props.part(parent, "BarrelStave", Vector3.new(0.68, 3.8, 0.25), stave, oak[i % 4 + 1])
    end
    for _, y in {0.45, 1.2, 2.8, 3.55} do
        for i = 0, 15 do
            local cf = origin * CFrame.Angles(0, i * math.pi / 8, 0) * CFrame.new(0, y, 1.95)
            Props.part(parent, "IronBarrelHoop", Vector3.new(0.79, 0.23, 0.12), cf, iron, Enum.Material.Metal)
        end
    end
    for _, y in {0.1, 3.9} do
        local head = Props.part(parent, "BarrelHead", Vector3.new(0.16, 3.7, 3.7), origin * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2), oak[2])
        head.Shape = Enum.PartType.Cylinder
    end
end
return Props
