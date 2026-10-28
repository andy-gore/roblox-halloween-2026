--!strict
-- Placement and collision stay on the server; original GLB visuals load locally on clients.
local Props = require(script.Parent.PubProps)
local Dressing = {}
local function ref(parent: Instance, name: string, value: Instance)
    local object = Instance.new("ObjectValue") object.Name, object.Value, object.Parent = name, value, parent
end
function Dressing.reroll(map: Folder)
    local folder = map:FindFirstChild("AssetPlacements")
    if not folder then return end
    local candidates = {}
    for _, object in folder:GetChildren() do
        if object:GetAttribute("CobwebCandidate") then table.insert(candidates, object) end
    end
    local random = Random.new()
    for i = #candidates, 2, -1 do
        local j = random:NextInteger(1, i) candidates[i], candidates[j] = candidates[j], candidates[i]
    end
    for i, object in candidates do object:SetAttribute("Enabled", i <= 10) end
end
function Dressing.build(map: Folder)
    local folder = Instance.new("Folder") folder.Name, folder.Parent = "AssetPlacements", map
    local number = 0
    local function add(asset: string, origin: CFrame, scale: Vector3?, replacements: {Instance}?, target: Instance?, mode: string?): Part
        number += 1
        local marker = Props.part(folder, "Asset" .. number, Vector3.new(0.02, 0.02, 0.02), origin, Color3.new())
        marker.Transparency = 1
        marker:SetAttribute("AssetName", asset) marker:SetAttribute("AssetScale", scale or Vector3.one)
        marker:SetAttribute("Enabled", true) marker:SetAttribute("Mode", mode or "Static")
        for i, object in replacements or {} do ref(marker, "Replacement" .. i, object) end
        if target then
            ref(marker, "Target", target)
            if target:IsA("BasePart") then marker:SetAttribute("FollowOffset",target.CFrame:ToObjectSpace(origin)) end
        end
        return marker
    end
    local function at(name: string, position: Vector3, radius: number): {Instance}
        local result = {}
        for _, object in map:GetDescendants() do
            if object:IsA("BasePart") and object.Name == name and (object.Position - position).Magnitude < radius then table.insert(result, object) end
        end
        return result
    end
    local function append(a: {Instance}, b: {Instance}) for _, v in b do table.insert(a, v) end end
    -- Existing solid furniture proxies are retained, including their original dimensions.
    for _, object in map:GetChildren() do
        if object:IsA("BasePart") and (object.Name == "PubTable" or object.Name == "SnugTable" or object.Name == "OfficeDesk") then
            local replacements: {Instance} = {object}
            for _, name in {"TablePlank", "TableLeg", "TableApron", "TableCrossRail", "TableStretcher"} do append(replacements, at(name, object.Position, 8)) end
            add("PubTable", CFrame.new(object.Position.X, 0.5, object.Position.Z), Vector3.new(object.Size.X/7, 1, object.Size.Z/6), replacements)
        end
    end
    for _, p in {Vector3.new(-17,0.5,33.3), Vector3.new(25,0.5,33.3), Vector3.new(-41,0.5,-3), Vector3.new(-37,0.5,-37.3), Vector3.new(-2,0.5,60)} do
        local replacements = {}
        for _, name in {"ChairSeat","ChairBackPost","ChairFrontLeg","ChairRail","ChairBackRail","ChairSlat","BurgundyCushion"} do append(replacements, at(name,p+Vector3.new(0,2,0),4)) end
        local yaw = if p.X == -41 then math.pi/2 elseif p.Z < -30 then 0 else math.pi
        add("PubChair", CFrame.new(p)*CFrame.Angles(0,yaw,0), nil, replacements)
    end
    -- Eight bedrooms: exact Blender furniture, collision proxies and nine key spots unchanged.
    for sideIndex, side in {-1, 1} do
        for i, z in {-30,-10,10,30} do
            local room = (sideIndex-1)*4+i
            -- Keep the tested room fill lights while removing their temporary glowing cubes.
            for _,old in at("GuestLantern",Vector3.new(side*23,27,z),0.2) do
                (old :: BasePart).Transparency=1
            end
            local bedPosition = Vector3.new(side*40,17.8,z+3)
            local replacements = at("BedroomBed",bedPosition,1)
            append(replacements,at("BedroomHeadboard",bedPosition,5))
            for _, name in {"IvoryMattress","BurgundyBedspread","IvoryPillow"} do append(replacements,at(name,bedPosition,5)) end
            add("InnSingleBed",CFrame.new(side*40,16.5,z+3),nil,replacements)
            local dresser = Vector3.new(side*25,18,z-6)
            replacements = at("BedroomDresser",dresser,1)
            for _,name in {"DresserDrawer","BrassDrawerHandle"} do append(replacements,at(name,dresser,4)) end
            add("DresserMirror",CFrame.new(side*25,16.5,z-6),Vector3.new(5/3.9,3/2.79,2.4/1.9),replacements)
            replacements=at("BedroomWardrobe",Vector3.new(side*43,20,z-6),1)
            append(replacements,at("WardrobeBrass",Vector3.new(side*43,20,z-6),3))
            add("InnWardrobe",CFrame.new(side*43,16.5,z-6),nil,replacements)
            local cabinet=Vector3.new(side*36,16.5,z+3.5)
            local collision=Props.part(map,"BedsideCabinetCollider",Vector3.new(2.05,2.425,1.7),CFrame.new(cabinet+Vector3.new(0,1.2125,0)),Color3.new())
            collision.Transparency,collision.CanCollide,collision.CanQuery=1,true,true
            collision:SetAttribute("BlocksNavigation",true)
            add("BedsideCabinet",CFrame.new(cabinet))
            local top=cabinet+Vector3.new(0,2.425,0)
            add("BedsideLamp",CFrame.new(top+Vector3.new(-0.45,0,0)),Vector3.one*0.8)
            add("BedsideBooks",CFrame.new(top+Vector3.new(0.55,0,0)),Vector3.one*0.6)
            local bulb=Props.part(folder,"BedsideBulb",Vector3.one*0.08,CFrame.new(top+Vector3.new(-0.45,1.08,0)),Color3.fromRGB(255,210,144),Enum.Material.Neon)
            local light=Instance.new("PointLight") light.Name,light.Range,light.Brightness,light.Color="PowerLight",10,0.35,bulb.Color light.Parent=bulb
            if room%2==1 then add("TravellerSuitcase",CFrame.new(side*44.4,16.5,z+7.8)*CFrame.Angles(0,0.15*side,0),Vector3.one*0.9) end
            add("BedroomCoatRail",CFrame.new(side*32,23,z-9.35))
            add(if room%2==1 then "PortraitFrame" else "LandscapeFrame",CFrame.new(side*40,23,z-9.3))
            -- Door plaques sit beside, rather than over, the readable existing room labels.
            local origin=CFrame.new(side*7.35,22.5,z+7.7)*CFrame.Angles(0,-side*math.pi/2,0)
            add("BedroomNumberBlank",origin,Vector3.one*1.5)
            -- One shared original plaque mesh, with editable native numerals on its front.
            local face=Props.part(folder,"BedroomPlaqueLettering",Vector3.new(1.05,1.35,.01)*1.5,origin*CFrame.new(0,.675*1.5,.18*1.5),Color3.new())
            face.Transparency=1
            face:SetAttribute("RoomNumber",room)
            local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Back
            gui.SizingMode,gui.PixelsPerStud,gui.LightInfluence,gui.Brightness=Enum.SurfaceGuiSizingMode.PixelsPerStud,100,0,.9
            gui.Parent=face
            local label=Instance.new("TextLabel") label.BackgroundTransparency=1
            label.Position,label.Size=UDim2.fromScale(.24,.25),UDim2.fromScale(.52,.5)
            label.Text,label.TextScaled,label.TextColor3=tostring(room),true,Color3.fromRGB(240,223,188)
            label.FontFace=Font.new("rbxasset://fonts/families/Fondamento.json") label.Parent=gui
        end
    end
    -- Countertop and storage dressing kept clear of the established walking routes.
    add("OpenGuestbook",CFrame.new(-32,4.62,17.1))
    add("StonewareMug",CFrame.new(-24,4.62,16.8))
    add("BedsideBooks",CFrame.new(-40,3.55,-34.1),Vector3.one*0.7,at("OldLedger",Vector3.new(-39.3,4.1,-34.5),2))
    for _,y in {5.425,7.625} do
        for i=0,6 do
            local p=Vector3.new(-34+i*2,y,9.2)
            local replacements=at("DustyBottle",p+Vector3.new(0,0.675,0),0.5)
            append(replacements,at("BottleNeck",p+Vector3.new(0,1.525,0),0.5))
            add(if i%2==0 then "GreenBottle" else "AmberBottle",CFrame.new(p),nil,replacements)
        end
    end
    add("KitchenStockpot",CFrame.new(19,3.7,-31))
    add("KitchenFryingPan",CFrame.new(19,3.7,-25)*CFrame.Angles(0,math.pi/2,0))
    add("KitchenPlateStack",CFrame.new(19,3.7,-18))
    add("CellarShelf",CFrame.new(21,0.5,-37.7))
    add("CellarBucket",CFrame.new(21,0.5,-15.5))
    add("CellarBroom",CFrame.new(21,0.5,-14))
    add("OpenCellarCrate",CFrame.new(69.5,-15.5,-37))
    add("ClosedCellarCrate",CFrame.new(69.5,-15.5,-42))
    add("CellarShelf",CFrame.new(69.5,-15.5,-49))
    add("CellarBucket",CFrame.new(69.5,-15.5,-54))
    for _,x in {44,52} do for _,z in {-46,-38} do
        local replacements={}
        for _,name in {"BarrelStave","IronBarrelHoop","BarrelHead"} do append(replacements,at(name,Vector3.new(x,-13.5,z),2.9)) end
        add("CellarBarrel",CFrame.new(x,-15.5,z),nil,replacements)
    end end
    local loose=map.CellarDressing:FindFirstChild("LooseCellarCrate") :: BasePart
    add("ClosedCellarCrate",loose.CFrame*CFrame.new(0,-2,0),Vector3.new(3.5/2.18,4/1.635,3.5/1.649),{loose},loose,"Crate")
    add("CellarSign",CFrame.new(44,10,9.1),Vector3.one*1.8)
    -- The obsolete lodging sign is stored in the cellar, not advertising the new arrival.
    add("RoomsAvailableSign",CFrame.new(71.3,-9,-54)*CFrame.Angles(0,-math.pi/2,0),Vector3.one*1.5)
    -- Preserve the original blank sign artwork in storage; the branded live board uses readable lettering.
    add("PubNameSign",CFrame.new(71.3,-7,-59)*CFrame.Angles(0,-math.pi/2,0),Vector3.new(2,1,1))
    local bell=map.Bell :: BasePart
    add("ServiceBell",CFrame.new(-20,4.62,17),nil,{bell},bell,"Bell")
    local key=map.OfficeKey :: BasePart
    add("ExitKey",key.CFrame,Vector3.one*1.5,nil,key,"Key")
    local door=map.ExitDoor :: BasePart
    add("ExitDoorLock",CFrame.new(-36,3.5,39.35)*CFrame.Angles(0,math.pi,0),nil,at("ExitHandle",Vector3.new(-36,5.5,39.25),1),door,"Door")
    local main=map.CellarFuseBox :: BasePart
    local hide: {Instance}={main,map.CellarDressing.CellarFuseBoxHandle,map.CellarDressing.CellarFuseBoxIndicator}
    add("CellarFuseBox",CFrame.new(25.5,-13.7,-43)*CFrame.Angles(0,math.pi/2,0),nil,hide,map.CellarPowerPanel,"Power")
    -- Curated high, quiet corners. The subset changes only on a server run reset.
    for sideIndex,side in {-1,1} do for i,z in {-30,-10,10,30} do
        local web=add("CornerCobweb",CFrame.new(side*46.8,29,z-9.35)*CFrame.Angles(0,if side<0 then 0 else math.pi,0),Vector3.one*0.9)
        web:SetAttribute("CobwebCandidate",true) web:SetAttribute("Room",(sideIndex-1)*4+i)
    end end
    for _,row in {
        {"HangingCobweb",CFrame.new(69,-3,-61),0.95},
        {"CornerCobweb",CFrame.new(25.2,-2.3,-62.8)*CFrame.Angles(0,math.pi/2,0),1},
        {"ShelfCobweb",CFrame.new(68,-11.1,-49),0.9},
        {"CornerCobweb",CFrame.new(-46.8,12.4,-38.8),1},
        {"CornerCobweb",CFrame.new(-46.8,12.4,-14.9),0.8},
        {"ShelfCobweb",CFrame.new(19.4,4.9,-37.5),0.75},
        {"HangingCobweb",CFrame.new(-44,12.7,37.5),0.8},
        {"CornerCobweb",CFrame.new(47,28.8,86.8)*CFrame.Angles(0,math.pi,0),0.85},
    } do
        local web=add(row[1] :: string,row[2] :: CFrame,Vector3.one*(row[3] :: number))
        web:SetAttribute("CobwebCandidate",true)
    end
    require(script.Parent.StormWindows).build(map,add)
    Dressing.reroll(map)
    folder:SetAttribute("PlacementCount",number)
end
return Dressing
