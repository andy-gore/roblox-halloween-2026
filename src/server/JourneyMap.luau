--!strict
-- Runtime arrival opening and two-corner courtyard. Authored Studio geometry is untouched.
local Props=require(script.Parent.PubProps)
local Map={}
Map.ExitNoise=Vector3.new(-36,0.5,44)
function Map.build(map: Folder)
    local wood=Color3.fromRGB(53,35,28)
    local decor=Instance.new("Folder") decor.Name,decor.Parent="JourneyDressing",map
    local function solid(name: string,size: Vector3,position: Vector3): Part
        local p=Instance.new("Part") p.Name,p.Size,p.Position=name,size,position
        p.Anchored,p.Color,p.Material=true,wood,Enum.Material.WoodPlanks
        p:SetAttribute("BlocksNavigation",true) p.Parent=map return p
    end
    local function sign(name: string,text: string,position: Vector3,width: number,height: number): Part
        local board=Props.part(decor,name,Vector3.new(width,height,0.15),CFrame.new(position),Color3.fromRGB(32,25,28))
        for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
            local gui=Instance.new("SurfaceGui") gui.Face,gui.LightInfluence,gui.PixelsPerStud=face,0,50
            gui.SizingMode,gui.Parent=Enum.SurfaceGuiSizingMode.PixelsPerStud,board
            local label=Instance.new("TextLabel") label.Size,label.BackgroundTransparency=UDim2.fromScale(1,1),1
            label.Font,label.TextScaled,label.TextColor3,label.Text=Enum.Font.GothamBold,true,Color3.fromRGB(255,224,170),text label.Parent=gui
        end
        return board
    end
    local wall=map:FindFirstChild("LoungeSouthWall") :: BasePart
    wall:Destroy()
    for _,span in {{-4,8},{30,36}} do
        local p=solid("LoungeSouthWall",Vector3.new(span[2],30,1),Vector3.new(span[1],15,88))
        p.Material,p.Color=Enum.Material.Plaster,Color3.fromRGB(107,100,110)
    end
    solid("FrontDoorLintel",Vector3.new(12,19,1),Vector3.new(6,20.5,88))
    local old=map:FindFirstChild("JammedEntrance") if old then old:Destroy() end
    local facade=map.Exterior.PubFrontage
    local oldDoor=facade:FindFirstChild("ExteriorFrontDoor") if oldDoor then oldDoor:Destroy() end
    solid("FrontDoor",Vector3.new(9,10,0.5),Vector3.new(6,5.5,88))
    local blocker=solid("FrontEntranceBlocker",Vector3.new(12,11,1),Vector3.new(6,5.5,88))
    blocker.CanCollide,blocker.Transparency=false,1
    local entry=Instance.new("Part") entry.Name,entry.Size,entry.Position="FrontEntrance",Vector3.one,Vector3.new(6,5,90)
    entry.Anchored,entry.Transparency,entry.CanCollide,entry.Parent=true,1,false,map
    local prompt=Instance.new("ProximityPrompt") prompt.ActionText,prompt.ObjectText="Enter pub","The Firefly Tavern"
    prompt.MaxActivationDistance,prompt.RequiresLineOfSight,prompt.Parent=9,false,entry
    local beam=Props.part(decor,"FallingEntranceBeam",Vector3.new(14,2.8,2.8),CFrame.new(6,13.5,88),wood)
    for i=1,6 do
        local p=Props.part(decor,"EntranceDebris",Vector3.new(2.5,2.2,1.8),CFrame.new(1+i*1.5,1.3,87.8+(i%2)*0.6)*CFrame.Angles(0,i*0.4,i*0.1),Color3.fromRGB(112,102,99),Enum.Material.Plaster)
        p.Transparency=1
    end
    for _,object in {map:FindFirstChild("EntranceLabel"),map:FindFirstChild("OutsideSign"),facade:FindFirstChild("RoomsAvailable"),facade.HangingPubSign} do
        if object then for _,label in object:GetDescendants() do
            if label:IsA("TextLabel") then label.Text=if object.Name=="EntranceLabel" then "FRONT ENTRANCE" else "THE FIREFLY TAVERN\nCLOSED" end
        end end
    end
    local spawn=map.PrototypeSpawn :: SpawnLocation
    spawn.CFrame=CFrame.lookAt(Vector3.new(-59,0.8,102),Vector3.new(6,0.8,88))
    spawn.CanCollide,spawn.CanQuery=false,false
    -- Eight-stud privacy walls prevent jumping over the two route turns.
    for _,row in {{"YardWestWall",Vector3.new(1,8,56),Vector3.new(-51,4.3,68)},
        {"YardEastWall",Vector3.new(1,8,56),Vector3.new(-21,4.3,68)},
        {"YardFirstWall",Vector3.new(20,8,1),Vector3.new(-41,4.3,72)},
        {"YardSecondWall",Vector3.new(20,8,1),Vector3.new(-31,4.3,90)}} do
        local p=solid(row[1] :: string,row[2] :: Vector3,row[3] :: Vector3)
        p.Material,p.Color=Enum.Material.Brick,Color3.fromRGB(63,58,66)
    end
    for _,position in {Vector3.new(-23,6,72),Vector3.new(-49,6,90),Vector3.new(-47,6,99)} do
        local bulb=Props.part(decor,"YardLantern",Vector3.new(0.6,1,0.6),CFrame.new(position),Color3.fromRGB(255,192,98),Enum.Material.Neon)
        local light=Instance.new("PointLight") light.Color,light.Brightness,light.Range,light.Parent=bulb.Color,1.5,22,bulb
    end
    sign("YardEscapeSign","CAR PARK\nFOLLOW THE LIGHTS",Vector3.new(-41,6,71.4),12,2.5)
    sign("YardEscapeSign","CAR PARK",Vector3.new(-31,6,89.4),10,2)
end
function Map.addRoutes(positions: {Vector3},edges: {{number}})
    local previous=17
    for i,point in {Vector3.new(-36,4.5,48),Vector3.new(-36,4.5,61),Vector3.new(-26,4.5,64),
        Vector3.new(-26,4.5,80),Vector3.new(-46,4.5,80),Vector3.new(-46,4.5,101),Vector3.new(-62,4.5,106)} do
        table.insert(positions,point)
        table.insert(edges,{previous,#positions,if i==1 then 1 else 0})
        previous=#positions
    end
end
return Map
