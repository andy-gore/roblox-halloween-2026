--!strict
-- Keep exploration on the supported ground; the drive-away endpoint stays inside.
local Props=require(script.Parent.PubProps)
local Boundary={}
function Boundary.build(map: Folder)
    local folder=Instance.new("Folder") folder.Name="GroundsBoundary"
    for _,row in {{Vector3.new(2,50,348),Vector3.new(-212,20,0)},
        {Vector3.new(2,50,348),Vector3.new(212,20,0)},
        {Vector3.new(426,50,2),Vector3.new(0,20,-172)},
        {Vector3.new(426,50,2),Vector3.new(0,20,172)}} do
        local barrier=Props.part(folder,"GroundsBarrier",row[1],CFrame.new(row[2]),Color3.fromRGB(34,43,38))
        barrier.CanCollide,barrier.CanQuery,barrier.Transparency=true,true,1
    end
    -- Dense distant hedges mark the limits through the fog rather than exposing a floor edge.
    for _,x in {-210,210} do for z=-160,160,20 do
        Props.part(folder,"BoundaryHedge",Vector3.new(5,12,21),CFrame.new(x,6,z),Color3.fromRGB(27,38,32),Enum.Material.Grass)
    end end
    for _,z in {-170,170} do for x=-200,200,20 do
        Props.part(folder,"BoundaryHedge",Vector3.new(21,12,5),CFrame.new(x,6,z),Color3.fromRGB(27,38,32),Enum.Material.Grass)
    end end
    folder.Parent=map
end
return Boundary
