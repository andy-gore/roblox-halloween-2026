--!strict
-- Fixed cellar expansion below the pub; the original stair opening stays in place.
local Props=require(script.Parent.PubProps)
local Cellar={}
Cellar.MonsterHome=Vector3.new(64,-11.5,-60)
function Cellar.build(map: Folder)
    local stone,wood=Color3.fromRGB(77,80,86),Color3.fromRGB(59,37,29)
    local decor=Instance.new("Folder") decor.Name="CellarDressing"
    local function solid(name: string,size: Vector3,position: Vector3): Part
        local p=Instance.new("Part") p.Name,p.Size,p.Position=name,size,position
        p.Anchored,p.Color,p.Material=true,stone,Enum.Material.Slate
        p:SetAttribute("BlocksNavigation",not string.find(name,"Floor") and not string.find(name,"Step"))
        p.Parent=map return p
    end
    local function detail(name: string,size: Vector3,position: Vector3,color: Color3): Part
        return Props.part(decor,name,size,CFrame.new(position),color)
    end
    local function label(name: string,text: string,position: Vector3,width: number,height: number,angle: number): Part
        local board=detail(name,Vector3.new(width,height,0.12),position,Color3.fromRGB(37,30,30))
        board.CFrame*=CFrame.Angles(0,angle,0)
        for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
            local gui=Instance.new("SurfaceGui") gui.Face,gui.LightInfluence=face,0
            gui.SizingMode,gui.PixelsPerStud,gui.Parent=Enum.SurfaceGuiSizingMode.PixelsPerStud,65,board
            local textLabel=Instance.new("TextLabel")
            textLabel.Size,textLabel.Position=UDim2.fromScale(0.94,0.9),UDim2.fromScale(0.03,0.05)
            textLabel.BackgroundTransparency,textLabel.TextScaled,textLabel.TextWrapped=1,true,true
            textLabel.Font,textLabel.TextColor3,textLabel.Text=Enum.Font.GothamBold,Color3.fromRGB(255,232,188),text
            textLabel.Parent=gui
        end
        return board
    end
    local function lamp(name: string,position: Vector3,brightness: number,range: number): PointLight
        local bulb=detail("CellarLantern",Vector3.new(0.6,0.9,0.6),position,Color3.fromRGB(255,189,105))
        bulb.Material=Enum.Material.Neon
        local light=Instance.new("PointLight") light.Name,light.Color,light.Brightness,light.Range=name,bulb.Color,brightness,range
        light.Shadows,light.Parent=true,bulb return light
    end
    solid("CellarFloor",Vector3.new(48,1,74),Vector3.new(48,-16,-27))
    solid("CellarWestWall",Vector3.new(1,16,74),Vector3.new(24,-8,-27))
    solid("CellarEastWall",Vector3.new(1,16,74),Vector3.new(72,-8,-27))
    solid("CellarNorthWall",Vector3.new(48,16,1),Vector3.new(48,-8,-64))
    solid("CellarSouthWall",Vector3.new(48,16,1),Vector3.new(48,-8,10))
    -- Cover the new underground area without sealing the original stairs.
    solid("CellarCeilingFloor",Vector3.new(48,0.5,40),Vector3.new(48,-0.9,-44))
    solid("CellarEastCeilingFloor",Vector3.new(24,0.5,34),Vector3.new(60,-0.9,-7))
    for step=0,15 do
        solid("CellarStep",Vector3.new(22,1,2),Vector3.new(36,-step,7-step*2)).Color=Color3.fromRGB(133,132,124)
        local edge=detail("StairEdge",Vector3.new(21,0.08,0.18),Vector3.new(36,0.55-step,6.1-step*2),Color3.fromRGB(255,195,85))
        edge.Material=Enum.Material.Neon
    end
    lamp("StairSafetyLight",Vector3.new(46,3,4),2,36)
    lamp("CellarSafetyLight",Vector3.new(27,-6,-30),0.8,27)
    lamp("CellarSafetyLight",Vector3.new(27,-6,-53),1,22)
    lamp("PanelWorkLight",Vector3.new(29,-7,-50),2.5,24).Color=Color3.fromRGB(255,226,169)
    lamp("CellarSafetyLight",Vector3.new(69,-6,-28),0.6,26)
    lamp("PowerLight",Vector3.new(67,-4,-47),0.35,36)
    lamp("PowerLight",Vector3.new(48,-4,-58),0.35,34)
    lamp("CellarCueLight",Vector3.new(66,-5,-60),0,24)
    -- One solid rack leaves wide west/east passages and cross-passages at both ends.
    local rack=solid("CellarRack",Vector3.new(16,8,16),Vector3.new(48,-11.5,-42))
    rack.Transparency=1
    for _,y in {-15.3,-11.4,-7.5} do detail("RackShelf",Vector3.new(16,0.25,16),Vector3.new(48,y,-42),wood) end
    for _,x in {40.3,48,55.7} do
        for _,z in {-49.7,-34.3} do detail("RackUpright",Vector3.new(0.5,8,0.5),Vector3.new(x,-11.5,z),wood) end
    end
    for _,x in {44,52} do
        for _,z in {-46,-38} do
            -- Leave the upper shelf open so the raised tankard and head can be seen beyond it.
            Props.barrel(decor,CFrame.new(x,-15.5,z))
        end
    end
    local crate=solid("CellarCrateCollider",Vector3.new(3.5,4,3.5),Vector3.new(58,-13.5,-51)) crate.Transparency=1
    detail("LooseCellarCrate",crate.Size,crate.Position,Color3.fromRGB(89,55,34))
    label("CellarReturnSign","STAIRS UP\nKEEP BOTH AISLES CLEAR",Vector3.new(36,-5,-25),15,2.5,0)
    label("CellarAisleSign","STAIRS UP",Vector3.new(69,-8,-29),8,1.8,math.pi/2)
    label("PowerDirectionSign","POWER PANEL  <\nWEST WALL",Vector3.new(35,-8.5,-29),12,2.5,0)
    label("MaintenanceSign","POWER PANEL\nTHREE SWITCHES + MAIN LEVER",Vector3.new(25.5,-3.5,-53),18,2,math.pi/2)
    local panel=solid("CellarPowerPanel",Vector3.new(0.8,7,20),Vector3.new(24.9,-10.2,-51))
    panel.Color,panel.Material=Color3.fromRGB(52,62,66),Enum.Material.Metal
    for _,z in {-61,-41} do
        detail("PanelSafetyTrim",Vector3.new(0.2,6.8,0.25),Vector3.new(25.4,-10.2,z),Color3.fromRGB(229,168,57))
    end
    local note=label("CellarInstructions","RESTORE CIRCUITS IN ORDER\nCELLAR FIRST\nGUEST ROOMS BEFORE THE BAR\nMAIN SUPPLY LAST",Vector3.new(25.45,-6.7,-53),15,3.3,math.pi/2)
    note.CanQuery=true
    note.Parent=map
    local read=Instance.new("ProximityPrompt") read.ActionText,read.ObjectText="Read instructions","Maintenance card"
    read.MaxActivationDistance,read.RequiresLineOfSight,read.Parent=10,false,note
    local function station(name: string,text: string,z: number): Part
        local p=Instance.new("Part") p.Name,p.Size,p.Position=name,Vector3.new(0.8,1.8,2.4),Vector3.new(26,-11.6,z)
        p.Anchored,p.CanCollide,p.Color,p.Material=true,false,Color3.fromRGB(211,128,40),Enum.Material.Metal
        p.Parent=map
        local prompt=Instance.new("ProximityPrompt") prompt.ActionText,prompt.ObjectText="Flip switch",text
        -- Third-person camera occlusion must not conceal the controls; server eye rays still validate use.
        prompt.MaxActivationDistance,prompt.HoldDuration,prompt.RequiresLineOfSight=6,0.25,false
        prompt.Enabled,prompt.Parent=false,p
        label("BreakerLabel",text,Vector3.new(26.5,-9.6,z),4.5,1.1,math.pi/2)
        local handle=detail(name.."Handle",Vector3.new(0.7,1.4,0.5),Vector3.new(26.9,-11.8,z),Color3.fromRGB(239,186,70))
        handle.Material=Enum.Material.Metal
        local indicator=detail(name.."Indicator",Vector3.new(0.2,0.5,0.5),Vector3.new(26.6,-11.1,z+0.75),Color3.fromRGB(77,63,45))
        indicator.Material=Enum.Material.Neon
        return p
    end
    station("CellarBreakerCellar","CELLAR",-58)
    station("CellarBreakerGuest","GUEST ROOMS",-53)
    station("CellarBreakerBar","BAR",-48)
    local main=station("CellarFuseBox","MAIN SUPPLY",-43)
    main.Size,main.Color=Vector3.new(0.8,2.4,2.4),Color3.fromRGB(104,44,35)
    local mainHandle=decor:FindFirstChild("CellarFuseBoxHandle") :: BasePart
    mainHandle.Size,mainHandle.Color=Vector3.new(0.8,1.7,0.6),Color3.fromRGB(210,62,43)
    label("MainSupplyStatus","NOT READY\n0/3 CIRCUITS",Vector3.new(26.6,-8,-43),4.5,1.4,math.pi/2)
    local mainPrompt=main:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    mainPrompt.ActionText,mainPrompt.HoldDuration="Pull main lever",0.4
    local monster=Instance.new("Part") monster.Name,monster.Size,monster.Position="ChuggernaughtPlaceholder",Vector3.new(4,8,4),Cellar.MonsterHome
    monster.Anchored,monster.CanCollide,monster.CanQuery,monster.Transparency=true,false,false,1
    monster.Parent=map
    decor.Parent=map
end
function Cellar.addRoutes(positions: {Vector3},edges: {{number}})
    local function node(position: Vector3): number table.insert(positions,position) return #positions end
    local function link(a: number,b: number) table.insert(edges,{a,b}) end
    local front=node(Vector3.new(33,-11.5,-28))
    local west=node(Vector3.new(33,-11.5,-57))
    local east=node(Vector3.new(64,-11.5,-57))
    local right=node(Vector3.new(64,-11.5,-28))
    local panel=node(Vector3.new(31,-11.5,-53))
    local main=node(Vector3.new(31,-11.5,-43))
    link(15,front) link(front,west) link(west,east) link(east,right) link(right,15) link(east,16)
    link(west,panel) link(panel,main) link(main,front)
end
return Cellar
