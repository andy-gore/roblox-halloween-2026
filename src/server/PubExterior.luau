--!strict
-- Fixed exterior scenery around the existing pub. No objectives/spawns/doors are changed.
local Props=require(script.Parent.PubProps)
local Exterior={}
local timber=Color3.fromRGB(40,29,27)
local stone=Color3.fromRGB(72,73,85)
function Exterior.build(map: Folder)
    local root=Instance.new("Folder") root.Name="Exterior" root.Parent=map
    local ground=Instance.new("Folder") ground.Name="Ground" ground.Parent=root
    local facade=Instance.new("Folder") facade.Name="PubFrontage" facade.Parent=root
    local landscape=Instance.new("Folder") landscape.Name="Woodland" landscape.Parent=root
    local function p(parent: Instance,name: string,size: Vector3,position: Vector3,color: Color3,material: Enum.Material?): Part
        return Props.part(parent,name,size,CFrame.new(position),color,material)
    end
    local function solid(parent: Instance,name: string,size: Vector3,position: Vector3,color: Color3,material: Enum.Material?): Part
        local part=p(parent,name,size,position,color,material)
        part.CanCollide,part.CanQuery=true,true return part
    end
    local function beam(parent: Instance,name: string,a: Vector3,b: Vector3,width: number,color: Color3)
        return Props.part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
    end
    -- Ground is split around the L-shaped pub, never across the cellar opening.
    local regions={
        {Vector3.new(171.5,1,360),Vector3.new(-134.25,-0.2,0)},
        {Vector3.new(171.5,1,360),Vector3.new(134.25,-0.2,0)},
        {Vector3.new(97,1,139.5),Vector3.new(0,-0.2,-110.25)},
        {Vector3.new(40,1,139.5),Vector3.new(-28.5,-0.2,110.25)},
        {Vector3.new(57,1,91.5),Vector3.new(20,-0.2,134.25)},
    }
    for _,r in regions do solid(ground,"CountrysideGround",r[1],r[2],Color3.fromRGB(34,46,39),Enum.Material.Grass) end
    solid(ground,"WetRoad",Vector3.new(440,0.25,24),Vector3.new(0,0.4,132),Color3.fromRGB(30,35,45),Enum.Material.Asphalt).Reflectance=0.16
    solid(ground,"GravelLayby",Vector3.new(66,0.12,20),Vector3.new(-60,0.36,112),Color3.fromRGB(79,80,84),Enum.Material.Pebble)
    for x=-210,210,28 do p(ground,"RoadMarking",Vector3.new(13,0.02,0.22),Vector3.new(x,0.55,132),Color3.fromRGB(178,180,170),Enum.Material.SmoothPlastic) end
    for _,z in {120.4,143.6} do p(ground,"RoadEdge",Vector3.new(440,0.02,0.16),Vector3.new(0,0.55,z),Color3.fromRGB(150,153,146)) end
    -- Broad wet paving continues to the car; it is clear of the actual exit doorway.
    solid(ground,"ExitCourtyard",Vector3.new(25,0.12,38),Vector3.new(-36,0.38,90),stone,Enum.Material.Slate)
    solid(ground,"FrontPath",Vector3.new(13,0.12,25),Vector3.new(6,0.38,101),stone,Enum.Material.Slate)
    solid(ground,"ConnectingPath",Vector3.new(53,0.12,10),Vector3.new(-15,0.38,109),stone,Enum.Material.Slate)
    local path=map:FindFirstChild("EscapePath") :: Part
    path.Material,path.Color,path.Reflectance=Enum.Material.Slate,stone,0.12
    for _,v in {Vector3.new(-50,0.48,104),Vector3.new(25,0.34,115),Vector3.new(85,0.34,93),Vector3.new(-105,0.34,104)} do
        local puddle=p(ground,"Puddle",Vector3.new(9,0.02,4),v,Color3.fromRGB(51,63,82),Enum.Material.Glass)
        puddle.Transparency,puddle.Reflectance=0.35,0.3
    end
    local function board(parent: Instance,name: string,text: string,position: Vector3,width: number,height: number): Part
        local part=p(parent,name,Vector3.new(width,height,0.25),position,timber)
        for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
            local surface=Instance.new("SurfaceGui") surface.Face=face
            surface.SizingMode,surface.PixelsPerStud,surface.LightInfluence=Enum.SurfaceGuiSizingMode.PixelsPerStud,45,0
            surface.Parent=part
            local label=Instance.new("TextLabel") label.Size,label.Position=UDim2.fromScale(0.94,0.9),UDim2.fromScale(0.03,0.05)
            label.BackgroundTransparency,label.TextScaled,label.TextWrapped=1,true,true
            label.Font,label.TextColor3,label.Text=Enum.Font.GothamBold,Color3.fromRGB(255,221,157),text label.Parent=surface
        end
        return part
    end
    local function lantern(position: Vector3)
        p(facade,"LanternBack",Vector3.new(1,1.8,0.3),position,timber,Enum.Material.Metal)
        local glass=p(facade,"ExteriorLantern",Vector3.new(0.7,1.1,0.7),position+Vector3.new(0,0,0.4),Color3.fromRGB(255,172,72),Enum.Material.Neon)
        local light=Instance.new("PointLight") light.Color,light.Brightness,light.Range=glass.Color,1.2,24 light.Shadows=true light.Parent=glass
    end
    -- Exterior stained-glass panels remain decorative over the tested structural walls.
    local function window(origin: CFrame,width: number)
        local function localPart(name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material?)
            return Props.part(facade,name,size,origin*cf,color,material)
        end
        localPart("WindowRecess",Vector3.new(width+0.7,7.8,0.25),CFrame.new(0,0,0.04),timber)
        local glow=localPart("WarmWindow",Vector3.new(width,5.6,0.12),CFrame.new(0,-0.7,0.22),Color3.fromRGB(196,118,49),Enum.Material.Neon)
        local spill=Instance.new("SurfaceLight")
        spill.Face,spill.Color,spill.Brightness,spill.Range,spill.Angle=Enum.NormalId.Back,glow.Color,0.45,14,115
        spill.Shadows,spill.Parent=false,glow
        localPart("PointedWindow",Vector3.new(width*0.6,width*0.6,0.12),CFrame.new(0,2,0.23)*CFrame.Angles(0,0,math.pi/4),Color3.fromRGB(153,87,49),Enum.Material.Neon)
        for _,x in {-width/2,0,width/2} do localPart("WindowLead",Vector3.new(0.16,5.9,0.3),CFrame.new(x,-0.7,0.34),timber) end
        for _,y in {-3.6,-0.7,2.2} do localPart("WindowLead",Vector3.new(width+0.2,0.16,0.3),CFrame.new(0,y,0.34),timber) end
        for _,side in {-1,1} do
            beam(facade,"PointedWindowFrame",origin:PointToWorldSpace(Vector3.new(side*width/2,2.2,0.34)),origin:PointToWorldSpace(Vector3.new(0,5,0.34)),0.25,timber)
        end
    end
    for _,x in {-2,25,40} do window(CFrame.new(x,7,88.65),if x==-2 then 5 else 7) end
    for _,x in {6,25,40} do window(CFrame.new(x,23,88.65),6) end
    for _,x in {-40,-18} do window(CFrame.new(x,23,40.65),7) end
    window(CFrame.new(-18,7,40.65),7)
    for _,side in {-1,1} do
        for _,z in {-30,-10,10,30} do
            window(CFrame.new(side*48.65,23,z)*CFrame.Angles(0,side*math.pi/2,0),7)
        end
    end
    -- Dark half-timber framing on both visible fronts and the bedroom side walls.
    for _,x in {-7,15,33,47} do p(facade,"FrontTimber",Vector3.new(0.7,30,0.6),Vector3.new(x,15,88.7),timber) end
    for _,y in {1,15.8,30} do p(facade,"FrontBeam",Vector3.new(56,0.7,0.6),Vector3.new(20,y,88.7),timber) end
    for _,side in {-1,1} do
        for _,z in {-39,-20,0,20,39} do p(facade,"UpperTimber",Vector3.new(0.6,14,0.65),Vector3.new(side*48.7,23,z),timber) end
        for _,y in {16.5,30} do p(facade,"UpperTimberRail",Vector3.new(0.6,0.6,80),Vector3.new(side*48.7,y,0),timber) end
    end
    -- Triangular gables close the roof ends without touching any walking space.
    local function gable(centerX: number,z: number,halfWidth: number,height: number)
        for _,side in {-1,1} do
            local wedge=Instance.new("WedgePart") wedge.Name="GothicGable"
            wedge.Size=Vector3.new(0.5,height,halfWidth)
            wedge.CFrame=CFrame.new(centerX+side*halfWidth/2,30+height/2,z)*CFrame.Angles(0,-side*math.pi/2,0)
            wedge.Color,wedge.Material=Color3.fromRGB(95,91,103),Enum.Material.Plaster
            wedge.Anchored,wedge.CanCollide,wedge.CanQuery=true,false,false wedge.Parent=facade
            beam(facade,"GableTimber",Vector3.new(centerX+side*halfWidth,30,z+0.35),Vector3.new(centerX,30+height,z+0.35),0.55,timber)
        end
    end
    gable(0,-40.65,48,12) gable(0,40.65,48,12) gable(20,88.65,28,7)
    for _,v in {Vector3.new(-30,38,-20),Vector3.new(30,38,6)} do
        p(facade,"StoneChimney",Vector3.new(4,12,5),v,stone,Enum.Material.Brick)
        p(facade,"ChimneyCap",Vector3.new(5,0.6,6),v+Vector3.new(0,6,0),Color3.fromRGB(45,42,49),Enum.Material.Slate)
    end
    board(facade,"FrontPubName","THE CROOKED TANKARD",Vector3.new(20,13,89.1),37,2.5)
    board(facade,"RoomsAvailable","ROOMS AVAILABLE",Vector3.new(6,8,89.1),9,1.4)
    p(facade,"ExteriorFrontDoor",Vector3.new(9,10,0.3),Vector3.new(6,5.5,88.7),Color3.fromRGB(50,32,29))
    for _,x in {0.5,11.5} do p(facade,"FrontDoorFrame",Vector3.new(0.6,11,0.7),Vector3.new(x,5.7,88.9),timber) end
    lantern(Vector3.new(-0.7,9,89.1)) lantern(Vector3.new(12.7,9,89.1))
    lantern(Vector3.new(-44,9,40.8))
    board(facade,"OutsideExitLabel","EMERGENCY EXIT",Vector3.new(-36,12.6,40.8),12,1.4)
    -- Hanging inn sign, pivoted at its upper attachment for a gentle local wind sway.
    solid(facade,"SignPost",Vector3.new(0.7,15,0.7),Vector3.new(-5,7.8,100),timber)
    beam(facade,"SignArm",Vector3.new(-5,14.5,100),Vector3.new(2,14.5,100),0.55,timber)
    local sign=Instance.new("Model") sign.Name="HangingPubSign" sign.Parent=facade
    board(sign,"SignBoard","THE CROOKED TANKARD\nROOMS AVAILABLE",Vector3.new(-0.5,11,100),8,4)
    for _,x in {-3,2} do p(sign,"SignChain",Vector3.new(0.1,1.5,0.1),Vector3.new(x,13.75,100),Color3.fromRGB(87,82,75),Enum.Material.Metal) end
    sign.WorldPivot=CFrame.new(-0.5,14.5,100)
    require(script.Parent.ExteriorCar).build(root)
    -- Fixed tree positions leave the road, courtyard and car approach clear.
    local trees={Vector3.new(-100,0,52),Vector3.new(-128,0,22),Vector3.new(-85,0,-38),Vector3.new(-128,0,-76),Vector3.new(-24,0,-97),Vector3.new(22,0,-112),Vector3.new(84,0,-62),Vector3.new(119,0,-20),Vector3.new(98,0,40),Vector3.new(130,0,84),Vector3.new(172,0,106),Vector3.new(-163,0,108),Vector3.new(-140,0,160),Vector3.new(-73,0,165),Vector3.new(0,0,170),Vector3.new(80,0,165),Vector3.new(155,0,160)}
    for i,position in trees do
        local height=24+(i%4)*3
        local trunk=solid(landscape,"BareTreeTrunk",Vector3.new(1.6,height,1.6),position+Vector3.new(0,height/2,0),Color3.fromRGB(37,33,36),Enum.Material.Wood)
        for _,side in {-1,1} do
            local a=trunk.Position+Vector3.new(0,3,0)
            local b=position+Vector3.new(side*7,height+2,(i%3-1)*5)
            beam(landscape,"BareBranch",a,b,0.7,Color3.fromRGB(37,33,36))
            beam(landscape,"BareTwig",b-Vector3.new(side*2,3,0),b+Vector3.new(side*3,2,2),0.35,Color3.fromRGB(37,33,36))
        end
    end
    for _,x in {-110,95} do
        for z=0,100,10 do solid(landscape,"FencePost",Vector3.new(0.45,3,0.45),Vector3.new(x,1.8,z),timber) end
        for _,y in {1.3,2.5} do p(landscape,"FenceRail",Vector3.new(0.25,0.2,100),Vector3.new(x,y,50),timber) end
    end
    root:SetAttribute("StormyExterior",true)
end
return Exterior
