--!strict
-- Working parked car. The legacy model name is retained for existing scenery references.
local Props=require(script.Parent.PubProps)
local Car={}
function Car.build(parent: Instance): Model
    local model=Instance.new("Model") model.Name="BrokenDownCar"
    local origin=CFrame.new(-62,0,112)*CFrame.Angles(0,math.rad(-8),0)
    local paint=Color3.fromRGB(39,61,75)
    local function part(name: string,size: Vector3,position: Vector3,color: Color3,material: Enum.Material?): Part
        return Props.part(model,name,size,origin*CFrame.new(position),color,material)
    end
    local body=part("CarBody",Vector3.new(13,1.4,5.5),Vector3.new(0,2.1,0),paint,Enum.Material.Metal)
    body.CanCollide,body.CanQuery=true,true
    local cabin=part("CarCabin",Vector3.new(6.3,2.2,5.1),Vector3.new(-1.3,3.85,0),paint,Enum.Material.Metal)
    cabin.CanCollide,cabin.CanQuery=true,true
    part("Roof",Vector3.new(6.6,0.25,5.3),Vector3.new(-1.3,5,0),paint,Enum.Material.Metal)
    for _,side in {-1,1} do
        for _,x in {-2.9,0.3} do
            local glass=part("CarSideWindow",Vector3.new(2.7,1.35,0.06),Vector3.new(x,3.95,side*2.58),Color3.fromRGB(64,83,98),Enum.Material.Glass)
            glass.Transparency,glass.Reflectance=0.2,0.2
            part("DoorHandle",Vector3.new(0.8,0.15,0.12),Vector3.new(x,2.9,side*2.81),Color3.fromRGB(150,156,157),Enum.Material.Metal)
        end
        for _,x in {-4.2,4.2} do
            local wheel=part("Tyre",Vector3.new(0.7,2.4,2.4),Vector3.new(x,1.5,side*2.85),Color3.fromRGB(20,22,26),Enum.Material.Rubber)
            wheel.Shape=Enum.PartType.Cylinder wheel.CFrame*=CFrame.Angles(0,math.pi/2,0)
            wheel.CanCollide,wheel.CanQuery=true,true
            local hub=part("WheelHub",Vector3.new(0.72,1.3,1.3),Vector3.new(x,1.5,side*2.86),Color3.fromRGB(100,107,116),Enum.Material.Metal)
            hub.Shape=Enum.PartType.Cylinder hub.CFrame*=CFrame.Angles(0,math.pi/2,0)
        end
        local headlight=part("Headlight",Vector3.new(0.12,0.55,1.3),Vector3.new(6.56,2.3,side*1.65),Color3.fromRGB(240,223,173),Enum.Material.Glass)
        local light=Instance.new("SpotLight") light.Face,light.Range,light.Brightness,light.Angle=Enum.NormalId.Right,60,2,75
        light.Enabled,light.Color,light.Parent=false,headlight.Color,headlight
        part("RearLamp",Vector3.new(0.12,0.55,1.3),Vector3.new(-6.56,2.3,side*1.65),Color3.fromRGB(94,23,29),Enum.Material.Glass)
        for _,endX in {-6.58,6.58} do
            part("HazardLamp",Vector3.new(0.15,0.45,0.45),Vector3.new(endX,2.3,side*2.3),Color3.fromRGB(239,139,44),Enum.Material.Neon)
        end
    end
    part("Windscreen",Vector3.new(0.06,1.5,4.7),Vector3.new(1.9,3.85,0),Color3.fromRGB(67,88,106),Enum.Material.Glass)
    part("RearGlass",Vector3.new(0.06,1.5,4.7),Vector3.new(-4.5,3.85,0),Color3.fromRGB(51,68,85),Enum.Material.Glass)
    part("EngineBay",Vector3.new(4.3,0.12,4.8),Vector3.new(4.3,2.87,0),Color3.fromRGB(19,21,25),Enum.Material.Metal)
    part("Engine",Vector3.new(2.4,0.5,2.3),Vector3.new(4.2,3.1,0),Color3.fromRGB(78,83,88),Enum.Material.Metal)
    part("ClosedBonnet",Vector3.new(4.3,0.18,5.3),Vector3.new(4.3,3.5,0),paint,Enum.Material.Metal)
    for _,x in {-6.6,6.6} do part("Bumper",Vector3.new(0.3,0.45,5.5),Vector3.new(x,1.7,0),Color3.fromRGB(48,49,52)) end
    local marker=part("CarLocation",Vector3.one,Vector3.new(0,0.8,-5),Color3.new()) marker.Transparency=1
    local door=part("EscapeCar",Vector3.new(1,1.5,0.5),Vector3.new(-1.3,2.8,-4.5),paint)
    door.Transparency,door.CanQuery=1,true
    local prompt=Instance.new("ProximityPrompt") prompt.ActionText,prompt.ObjectText="Get in and drive","Your car"
    prompt.MaxActivationDistance,prompt.HoldDuration,prompt.RequiresLineOfSight,prompt.Enabled=8,0.35,false,false prompt.Parent=door
    local tag=Instance.new("BillboardGui") tag.Name,tag.Adornee,tag.Size="CarGoal",door,UDim2.fromOffset(180,38)
    tag.StudsOffsetWorldSpace,tag.MaxDistance,tag.Enabled,tag.AlwaysOnTop=Vector3.new(0,3,0),100,false,false tag.Parent=door
    local text=Instance.new("TextLabel") text.Size,text.BackgroundTransparency=UDim2.fromScale(1,1),1
    text.Text,text.Font,text.TextSize,text.TextColor3="YOUR CAR",Enum.Font.GothamBold,22,Color3.fromRGB(255,224,170) text.Parent=tag
    model:SetAttribute("HazardsEnabled",false)
    model.PrimaryPart=body model.Parent=parent
    return model
end
return Car
