--!strict
-- Enclosed rear service stair: upstairs corridor -> kitchen, with a walking return below.
local Props = require(script.Parent.PubProps)
local Stairs = {}
function Stairs.build(map: Folder)
    local wood, brass = Color3.fromRGB(59,37,29), Color3.fromRGB(158,113,51)
    local decor = Instance.new("Folder")
    decor.Name, decor.Parent = "StaffStairDressing", map
    local function solid(name: string, size: Vector3, position: Vector3): Part
        local p = Instance.new("Part")
        p.Name, p.Size, p.Position = name, size, position
        p.Anchored, p.CanCollide = true, true
        p.Color, p.Material = wood, Enum.Material.WoodPlanks
        p:SetAttribute("BlocksNavigation", not string.find(name,"Floor") and not string.find(name,"Step"))
        p.Parent = map
        return p
    end
    local function detail(name: string, size: Vector3, position: Vector3, color: Color3): Part
        return Props.part(decor, name, size, CFrame.new(position), color)
    end
    local function doorway(wall: BasePart, left: number, right: number)
        local a, b = wall.Position.X-wall.Size.X/2, wall.Position.X+wall.Size.X/2
        local position, size, name = wall.Position, wall.Size, wall.Name
        wall:Destroy()
        for _, span in {{a,left},{right,b}} do
            local p = solid(name,Vector3.new(span[2]-span[1],size.Y,size.Z),Vector3.new((span[1]+span[2])/2,position.Y,position.Z))
            p.Color, p.Material = Color3.fromRGB(107,100,110), Enum.Material.Plaster
        end
        solid("StaffDoorLintel",Vector3.new(right-left,3,1),Vector3.new((left+right)/2,position.Y+5.5,position.Z))
    end
    doorway(map:FindFirstChild("NorthWall") :: BasePart,2,16)
    doorway(map:FindFirstChild("GuestNorthWall") :: BasePart,-6,6)
    solid("StaffFloor",Vector3.new(32,1,46),Vector3.new(8,0,-63))
    solid("StaffLandingFloor",Vector3.new(32,1,8),Vector3.new(8,16,-44))
    for _,x in {-8,24} do solid("StaffOuterWall",Vector3.new(1,31,46),Vector3.new(x,15.5,-63)) end
    solid("StaffNorthWall",Vector3.new(32,31,1),Vector3.new(8,15.5,-86))
    for step=1,15 do
        solid("StaffStep",Vector3.new(12,1,2),Vector3.new(12,step,-78+step*2))
        local edge=detail("StaffStairEdge",Vector3.new(11.5,0.06,0.15),Vector3.new(12,step+0.55,-78+step*2+0.85),brass)
        edge.Material=Enum.Material.Neon
    end
    for _,x in {5.5,18.5} do
        local a,b=Vector3.new(x,3.5,-78),Vector3.new(x,19.5,-46)
        Props.part(decor,"StaffStairRail",Vector3.new(0.25,0.25,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),brass)
        for step=0,16,2 do detail("StaffBaluster",Vector3.new(0.15,3,0.15),Vector3.new(x,step+2,-78+step*2),brass) end
        local ga,gb=a-Vector3.new(0,1.3,0),b+Vector3.new(0,-2.3,-2)
        local guard=solid("StaffStairGuard",Vector3.new(0.3,3,(gb-ga).Magnitude),(ga+gb)/2)
        guard.CFrame,guard.Transparency=CFrame.lookAt(guard.Position,gb),1
    end
    -- The upper landing edge is solid except at the stair mouth.
    for _,span in {{-1,13},{21.5,5}} do
        solid("StaffLandingGuard",Vector3.new(span[2],3,0.3),Vector3.new(span[1],18,-47.5)).Transparency=1
        detail("StaffLandingRail",Vector3.new(span[2],0.25,0.25),Vector3.new(span[1],19.5,-47.5),brass)
        for x=span[1]-span[2]/2,span[1]+span[2]/2,2.5 do
            detail("StaffLandingBaluster",Vector3.new(0.15,3,0.15),Vector3.new(x,18,-47.5),brass)
        end
    end
    for _,side in {-1,1} do
        local roof=detail("StaffSlateRoof",Vector3.new(math.sqrt(16*16+5*5)+1,0.8,46),Vector3.new(8+side*8,33.5,-63),Color3.fromRGB(34,33,47))
        roof.Material,roof.CanQuery=Enum.Material.Slate,true
        roof.CFrame*=CFrame.Angles(0,0,-side*math.atan(5/16))
    end
    local function label(text: string, position: Vector3, rotation: number?)
        local board=detail("StaffSign",Vector3.new(11,2.2,0.15),position,Color3.fromRGB(31,23,26))
        board.CFrame*=CFrame.Angles(0,rotation or 0,0)
        for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
            local gui=Instance.new("SurfaceGui") gui.Face,gui.PixelsPerStud,gui.LightInfluence=face,60,0
            gui.SizingMode,gui.Parent=Enum.SurfaceGuiSizingMode.PixelsPerStud,board
            local writing=Instance.new("TextLabel") writing.Size,writing.BackgroundTransparency=UDim2.fromScale(1,1),1
            writing.Text,writing.TextScaled,writing.TextColor3=text,true,Color3.fromRGB(255,225,166)
            writing.Font,writing.Parent=Enum.Font.GothamBold,gui
        end
    end
    label("STAFF STAIRS\nGUEST ROOMS",Vector3.new(9,10,-39.3))
    label("STAFF STAIRS\nKITCHEN / BAR",Vector3.new(0,26,-39.3))
    label("KITCHEN / BAR\nFOLLOW PASSAGE",Vector3.new(12,6,-84.9))
    label("GUEST ROOMS\nSTAIRS UP",Vector3.new(23.3,8,-78),math.pi/2)
    for _,position in {Vector3.new(-5,8,-46),Vector3.new(-5,8,-80),Vector3.new(22,25,-45),Vector3.new(22,17,-64)} do
        local bulb=detail("StaffLantern",Vector3.new(0.6,1,0.6),position,Color3.fromRGB(255,190,100))
        bulb.Material=Enum.Material.Neon
        local light=Instance.new("PointLight")
        light.Name,light.Color,light.Range,light.Brightness="PowerLight",bulb.Color,28,0.35
        light.Shadows,light.Parent=true,bulb
    end
end
function Stairs.addRoutes(positions: {Vector3}, edges: {{number}}, corridor: number)
    local function extend(previous: number, position: Vector3): number
        table.insert(positions,position)
        table.insert(edges,{previous,#positions})
        return #positions
    end
    local previous=extend(corridor,Vector3.new(0,20.5,-44))
    previous=extend(previous,Vector3.new(12,20.5,-44))
    for step=16,0,-1 do previous=extend(previous,Vector3.new(12,4.5+step,-78+step*2)) end
    previous=extend(previous,Vector3.new(12,4.5,-82))
    previous=extend(previous,Vector3.new(-1,4.5,-82))
    previous=extend(previous,Vector3.new(-1,4.5,-44))
    previous=extend(previous,Vector3.new(9,4.5,-44))
    table.insert(edges,{previous,11}) -- existing kitchen north
end
return Stairs
