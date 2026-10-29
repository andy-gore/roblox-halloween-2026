--!strict
-- Original atmosphere-pack placements; all visuals are non-colliding client meshes.
local Props=require(script.Parent.PubProps)
local Dressing={}
type Add=(string,CFrame,Vector3?,{Instance}?,Instance?,string?)->Part
function Dressing.build(map: Folder,add: Add)
    add("TwinBeerPump",CFrame.new(-32,4.62,16))
    add("BarDripTray",CFrame.new(-32,4.62,17.2))
    add("PewterTankardRack",CFrame.new(-40,6,8.8))
    add("CoasterStack",CFrame.new(-16,3.55,29))
    add("SinglePewterMug",CFrame.new(-18,3.55,29))
    add("StoppedPubClock",CFrame.new(-27,10,8.8))
    add("FramedCountryside",CFrame.new(-34,7,-39.2))
    add("FramedWoodland",CFrame.new(-47.2,7,-10)*CFrame.Angles(0,math.pi/2,0))
    add("PubDartboard",CFrame.new(-47.2,5,-12)*CFrame.Angles(0,math.pi/2,0))
    -- Beads/trails only: the exporter omits the pack's full backing pane.
    for _,window in map.StormViewWindows:GetChildren() do
        if window:IsA("BasePart") and window.Name=="WindowBarrier" then
            local wide=window.Size.Z>5
            local side=math.sign(window.Position.X)
            local cf=CFrame.new(side*47.7,window.Position.Y-window.Size.Y/2,window.Position.Z)*CFrame.Angles(0,-side*math.pi/2,0)
            add(if wide then "RainStreakPaneWide" else "RainStreakPaneNarrow",cf,Vector3.new(window.Size.Z/(if wide then 4.8 else 2.4),window.Size.Y/4.4,1))
        end
    end
    -- Native transparent water avoids spending six mesh allocations on three floor films.
    local water=Instance.new("Folder") water.Name="AtmosphereWater" water.Parent=map
    for _,row in {{"SmallPuddle",Vector3.new(-54,.51,105),Vector3.new(2.293,.025,1.338)},
        {"DoorwayPuddle",Vector3.new(6,.53,95),Vector3.new(4.378,.025,1.646)},
        {"CourtyardPuddle",Vector3.new(-36,.53,60),Vector3.new(5.838,.025,3.292)}} do
        for i=1,3 do
            local size=row[3] :: Vector3
            local origin=row[2] :: Vector3
            local film=Props.part(water,row[1] :: string,size*Vector3.new(.65,1,.8),CFrame.new(origin+Vector3.new((i-2)*size.X*.18,0,(i%2)*size.Z*.08))*CFrame.Angles(0,(i-2)*.16,0),Color3.fromRGB(66,88,106),Enum.Material.Glass)
            film.Shape,film.Transparency,film.Reflectance=Enum.PartType.Ball,.48,.12
            film:SetAttribute("SourceAsset","assets/props/atmosphere-set/storm/"..(row[1] :: string)..".glb")
        end
    end
    add("GalvanisedBin",CFrame.new(-49.5,.5,53))
    add("BrokenCourtyardPlanter",CFrame.new(-49,.5,66))
    for _,x in {-.6,12.6} do
        for _,y in {1.4,6.4} do add("DrainpipeStraight",CFrame.new(x,y,89.3)) end
        add("DrainpipeOffset",CFrame.new(x,11.4,89.3))
        add("DrainpipeShoe",CFrame.new(x,.5,89.3))
    end
    local decor=Instance.new("Folder") decor.Name="AtmosphereLights" decor.Parent=map
    for _,position in {Vector3.new(-50.3,5.2,58),Vector3.new(-21.7,5.2,82)} do
        local cf=CFrame.new(position)*CFrame.Angles(0,if position.X< -30 then math.pi/2 else -math.pi/2,0)
        add("CourtyardWallLantern",cf)
        local bulb=Props.part(decor,"LanternLightSource",Vector3.one*.1,cf*CFrame.new(0,1,.65),Color3.fromRGB(255,189,105))
        bulb.Transparency=1
        local l=Instance.new("PointLight") l.Color,l.Brightness,l.Range,l.Shadows,l.Parent=bulb.Color,.65,16,true,bulb
    end
end
return Dressing
