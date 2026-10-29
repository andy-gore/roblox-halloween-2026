--!strict
-- A coherent inn facade over the tested runtime shell. No new walking obstacles.
local Props=require(script.Parent.PubProps)
local Architecture={}
function Architecture.build(map: Folder)
    local facade=map.Exterior.PubFrontage
    local decor=Instance.new("Folder") decor.Name="TavernArchitecture"
    local oak=Color3.fromRGB(43,30,26)
    local iron=Color3.fromRGB(40,43,48)
    local slate=Color3.fromRGB(45,49,62)
    local stone=Color3.fromRGB(111,105,99)
    local function p(name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material?): Part
        return Props.part(decor,name,size,cf,color,material)
    end
    local function beam(name: string,a: Vector3,b: Vector3,width: number,color: Color3)
        return p(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
    end
    -- Warm limewash and a framed side elevation read clearly from the parked car.
    for _,wall in map:GetChildren() do
        if wall:IsA("BasePart") and (wall.Name=="LoungeSouthWall" or wall.Name=="LoungeWestWall" or wall.Name=="LoungeEastWall" or wall.Name=="FrontDoorLintel") then
            wall.Color,wall.Material=Color3.fromRGB(133,123,108),Enum.Material.Plaster
        end
    end
    for _,z in {41,56,72,87} do
        p("SideElevationPost",Vector3.new(.6,29,.7),CFrame.new(-8.65,15,z),oak)
    end
    for _,y in {2,15.8,29.5} do p("SideElevationRail",Vector3.new(.6,.55,48),CFrame.new(-8.65,y,64),oak) end
    for _,span in {{42,55},{57,71},{73,86}} do
        for _,base in {3,17} do
            beam("SideElevationBrace",Vector3.new(-8.68,base,span[1]),Vector3.new(-8.68,base+11,span[2]),.4,oak)
        end
        p("SideStoneBase",Vector3.new(.5,1.3,span[2]-span[1]),CFrame.new(-8.65,1.15,(span[1]+span[2])/2),stone,Enum.Material.Cobblestone)
    end
    -- Replace the small flat canopy with a proper projecting, timber-framed gable.
    local old=map.ExteriorFinishes:FindFirstChild("SlateEntranceCanopy") if old then old:Destroy() end
    local angle=math.atan(5/7)
    for _,side in {-1,1} do
        local roof=p("PorchSlateRoof",Vector3.new(math.sqrt(74)+.5,.35,5.8),CFrame.new(6+side*3.5,14.5,91.3)*CFrame.Angles(0,0,-side*angle),slate,Enum.Material.Slate)
        roof.CanQuery=true -- rain cover and camera avoidance under the new porch
        for _,z in {88.6,94.1} do
            beam("PorchBargeboard",Vector3.new(6+side*7,12,z),Vector3.new(6,17,z),.42,oak)
        end
        beam("PorchWallBracket",Vector3.new(6+side*6.6,9.4,89),Vector3.new(6+side*6.6,12,93.5),.32,oak)
        beam("PorchKingBrace",Vector3.new(6+side*5.5,12,94),Vector3.new(6,16,94),.2,oak)
    end
    beam("PorchRidge",Vector3.new(6,17.2,88.4),Vector3.new(6,17.2,94.4),.45,iron)
    beam("PorchTie",Vector3.new(-1,12,94),Vector3.new(13,12,94),.4,oak)
    beam("PorchKingPost",Vector3.new(6,12,94),Vector3.new(6,17,94),.3,oak)
    -- Give the brand its own clear bay, away from the porch and entrance prompts.
    local brand=facade.FrontPubName :: BasePart
    brand.Size,brand.Position=Vector3.new(29,2.5,.35),Vector3.new(30,13,89.25)
    for _,x in {15,45} do p("BrandBoardCorbel",Vector3.new(.5,3,.7),CFrame.new(x,12.8,89.2),oak) end
    -- Retire the duplicate exterior board; the hanging sign and fascia carry the name.
    local duplicate=map.OutsideSign :: BasePart duplicate.Transparency=1
    for _,gui in duplicate:GetChildren() do if gui:IsA("SurfaceGui") then gui.Enabled=false end end
    -- Layered front window cases and individual sill brackets, with clear glazing.
    for _,row in {{-2,7,5},{25,7,7},{40,7,7},{6,23,6},{25,23,6},{40,23,6}} do
        local x,y,w=row[1],row[2],row[3]
        for _,side in {-1,1} do
            p("WindowCarvedJamb",Vector3.new(.25,6.2,.65),CFrame.new(x+side*(w/2+.25),y-.7,89.25),oak)
            p("SillBracket",Vector3.new(.4,.7,.55),CFrame.new(x+side*(w/2-.5),y-4.45,89),stone,Enum.Material.Slate)
        end
        beam("WindowHoodMould",Vector3.new(x-w/2-.4,y+2.2,89.1),Vector3.new(x,y+5.35,89.1),.24,stone)
        beam("WindowHoodMould",Vector3.new(x,y+5.35,89.1),Vector3.new(x+w/2+.4,y+2.2,89.1),.24,stone)
    end
    -- Bargeboards, ridge caps and eaves give the long roof a finished silhouette.
    for _,g in {{20,88.95,28,7},{0,40.95,48,12},{0,-40.95,48,12}} do
        for _,side in {-1,1} do
            beam("RoofBargeboard",Vector3.new(g[1]+side*(g[3]+.5),29.9,g[2]),Vector3.new(g[1],30+g[4]+.25,g[2]),.75,oak)
        end
        beam("GableKingPost",Vector3.new(g[1],30,g[2]),Vector3.new(g[1],30+g[4],g[2]),.55,oak)
        for _,side in {-1,1} do
            beam("GableFanBrace",Vector3.new(g[1]+side*g[3]*.65,30,g[2]),Vector3.new(g[1],30+g[4]*.72,g[2]),.28,oak)
        end
    end
    for z=-39,39,6 do p("MainRidgeCap",Vector3.new(.85,.5,5.9),CFrame.new(0,42.5,z),iron,Enum.Material.Slate) end
    for z=44,86,6 do p("LoungeRidgeCap",Vector3.new(.8,.5,5.9),CFrame.new(20,37.5,z),iron,Enum.Material.Slate) end
    for _,side in {-1,1} do
        p("MainGutter",Vector3.new(.55,.45,82),CFrame.new(side*49,29.9,0),iron,Enum.Material.Metal)
        p("LoungeGutter",Vector3.new(.5,.4,49),CFrame.new(20+side*29,29.8,65),iron,Enum.Material.Metal)
        for _,z in {-39,39} do
            p("CastIronDownpipe",Vector3.new(.3,28,.3),CFrame.new(side*49,15,z),iron,Enum.Material.Metal)
            for _,y in {5,14,24} do p("PipeClip",Vector3.new(.6,.14,.45),CFrame.new(side*49,y,z),iron,Enum.Material.Metal) end
        end
    end
    -- Upgrade the swinging sign itself so the relief moves with the existing wind sway.
    local sign=facade.HangingPubSign :: Model
    local function signPart(name: string,size: Vector3,pos: Vector3,color: Color3,material: Enum.Material?)
        return Props.part(sign,name,size,CFrame.new(pos),color,material)
    end
    for _,x in {-4.7,3.7} do signPart("SignCarvedUpright",Vector3.new(.3,4.7,.6),Vector3.new(x,11,100),oak) end
    for _,y in {8.7,13.3} do signPart("SignCarvedRail",Vector3.new(8.8,.35,.6),Vector3.new(-.5,y,100),oak) end
    signPart("SignCrown",Vector3.new(5,.3,.5),Vector3.new(-.5,13.65,100),iron,Enum.Material.Metal)
    for _,x in {-4.65,3.65} do
        for _,y in {8.75,13.25} do
            local stud=signPart("SignBrassStud",Vector3.new(.17,.17,.7),Vector3.new(x,y,100),Color3.fromRGB(170,132,70),Enum.Material.Metal)
            stud.Shape=Enum.PartType.Ball
        end
    end
    -- Remove the extra advertising plaque above the door to reduce competing signage.
    local lodging=facade.RoomsAvailable :: BasePart lodging.Transparency=1
    for _,gui in lodging:GetChildren() do if gui:IsA("SurfaceGui") then gui.Enabled=false end end
    -- Door face detailing follows its existing swing automatically through SurfaceGuis.
    local door=map.FrontDoor :: BasePart door.Color=oak
    for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
        local gui=Instance.new("SurfaceGui") gui.Name="CarvedDoorFace" gui.Face,gui.LightInfluence=face,1
        gui.SizingMode,gui.PixelsPerStud,gui.Parent=Enum.SurfaceGuiSizingMode.PixelsPerStud,40,door
        for column=0,1 do for row=0,1 do
            local panel=Instance.new("Frame") panel.Size,panel.Position=UDim2.fromScale(.36,.36),UDim2.fromScale(.09+column*.46,.09+row*.46)
            panel.BackgroundColor3,panel.BorderSizePixel,panel.Parent=Color3.fromRGB(64,40,28),0,gui
            local stroke=Instance.new("UIStroke") stroke.Color,stroke.Thickness,stroke.Parent=Color3.fromRGB(92,64,40),2,panel
        end end
    end
    decor.Parent=map
end
return Architecture
