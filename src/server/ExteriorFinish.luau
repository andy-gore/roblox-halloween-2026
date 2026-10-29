--!strict
-- Added surface depth on the disposable facade; doors, windows and routes remain clear.
local Props=require(script.Parent.PubProps)
local Finish={}
function Finish.build(map: Folder)
    local decor=Instance.new("Folder") decor.Name="ExteriorFinishes"
    local oak=Color3.fromRGB(47,33,28)
    local stone=Color3.fromRGB(98,95,98)
    local function p(name: string,size: Vector3,position: Vector3,color: Color3,material: Enum.Material?): Part
        return Props.part(decor,name,size,CFrame.new(position),color,material)
    end
    local function beam(a: Vector3,b: Vector3,width: number)
        return Props.part(decor,"CarvedFacadeBrace",Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),oak)
    end
    -- Individual masonry blocks break up the broad flat plaster at ground level.
    for _,span in {{-8,0},{12,48}} do
        for row=0,1 do
            local x=span[1]
            while x<span[2] do
                local width=math.min(if row==0 then 3 else 2.5,span[2]-x)
                p("WeatheredPlinthStone",Vector3.new(width-.06,.65,.38),Vector3.new(x+width/2,.85+row*.7,88.63),stone,Enum.Material.Cobblestone)
                x+=width
            end
        end
    end
    for _,x in {-7.4,47.4} do
        for row=0,26 do
            p("CornerQuoin",Vector3.new(if row%2==0 then 1.5 else 1.1,.9,.5),Vector3.new(x,2.5+row,88.85),if row%3==0 then Color3.fromRGB(116,110,108) else stone,Enum.Material.Slate)
        end
    end
    -- Diagonal carpentry sits in the plaster bays between the existing windows.
    for _,span in {{16.4,20.5},{29.5,35.5}} do
        beam(Vector3.new(span[1],18,88.95),Vector3.new(span[2],28.5,88.95),.4)
    end
    for _,y in {3.1,14.7,29.2} do
        for _,span in {{-4,8},{30,36}} do p("FacadeStringCourse",Vector3.new(span[2],.18,.45),Vector3.new(span[1],y,88.9),oak) end
    end
    -- Recessed entrance surround and a shallow slate canopy shelter the doorway.
    for _,x in {.2,11.8} do
        p("CarvedDoorPost",Vector3.new(.45,10.7,.8),Vector3.new(x,5.85,89.15),oak)
        p("DoorPostCapital",Vector3.new(.8,.5,1),Vector3.new(x,10.8,89.2),stone,Enum.Material.Slate)
    end
    p("PorchLintel",Vector3.new(13,.5,1),Vector3.new(6,11.2,89.2),oak)
    local canopy=p("SlateEntranceCanopy",Vector3.new(14,.28,3.2),Vector3.new(6,11.65,90),Color3.fromRGB(48,48,60),Enum.Material.Slate)
    canopy.CFrame*=CFrame.Angles(math.rad(8),0,0)
    for _,x in {-.4,12.4} do beam(Vector3.new(x,9.7,89.2),Vector3.new(x,11.2,91.1),.22) end
    -- Stone sills and lintels give the front windows depth without covering the glass.
    for _,row in {{-2,7,5},{25,7,7},{40,7,7},{6,23,6},{25,23,6},{40,23,6}} do
        p("FrontWindowSill",Vector3.new(row[3]+.9,.3,.85),Vector3.new(row[1],row[2]-4.05,89.1),stone,Enum.Material.Slate)
    end
    -- Patched plaster and subtle water marks stay away from signs and glazing.
    for _,x in {17.4,31.6,45.5} do
        p("RainWeathering",Vector3.new(.14,3,.03),Vector3.new(x,7.5,88.54),Color3.fromRGB(74,70,77),Enum.Material.Plaster)
        p("RainWeathering",Vector3.new(.08,1.7,.03),Vector3.new(x+.28,6.7,88.54),Color3.fromRGB(82,77,80),Enum.Material.Plaster)
    end
    -- Low shrubs flank the frontage; the entrance and courtyard are kept open.
    for _,x in {-10,51} do
        p("StonePlantTrough",Vector3.new(3.2,1.2,2),Vector3.new(x,.95,90.8),stone,Enum.Material.Slate)
        for i=1,3 do
            local shrub=p("DryShrub",Vector3.new(.9,1.3,.9),Vector3.new(x-1+i*.5,2,90.8),Color3.fromRGB(60,66,48),Enum.Material.Grass)
            shrub.Shape=Enum.PartType.Ball
        end
    end
    decor.Parent=map
end
return Finish
