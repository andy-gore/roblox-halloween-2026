--!strict
-- Studio Edit server Command Bar. The temporary exterior fixture is always removed.
local server=game.ServerScriptService:WaitForChild("HalloweenServer")
local map=require(server.PrototypeMap).build()
map.Name="ExteriorTest"
local offset=Vector3.new(4000,0,0)
for _,p in map:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
local ok,err=pcall(function()
    local exterior=map:FindFirstChild("Exterior") :: Folder
    assert(exterior and exterior:GetAttribute("StormyExterior")==true)
    local car=exterior:FindFirstChild("BrokenDownCar") :: Model
    local body=car:FindFirstChild("CarBody") :: BasePart
    local cabin=car:FindFirstChild("CarCabin") :: BasePart
    assert(body.CanCollide and cabin.CanCollide,"Car must be solid scenery")
    assert(car:FindFirstChild("RaisedBonnet") and car:FindFirstChild("CarLocation"))
    local key=map:FindFirstChild("OfficeKey") :: Part
    assert(key.Transparency==1 and not (key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt).Enabled)
    assert(#map.KeyLocations:GetChildren()==9)
    assert((map.PrototypeSpawn.Position-offset-Vector3.new(6,1,30)).Magnitude<0.01,"Exterior must not move the starting spawn")
    local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Include cast.FilterDescendantsInstances={map}
    local cellar=workspace:Raycast(offset+Vector3.new(36,6,0),Vector3.new(0,-40,0),cast)
    assert(cellar and cellar.Instance.Name=="CellarStep","Outdoor ground must not seal cellar stairs")
    for _,point in {Vector3.new(0,100,0),Vector3.new(28,100,64)} do
        local hit=workspace:Raycast(point+offset,Vector3.new(0,-120,0),cast)
        assert(hit and (hit.Instance.Name=="SlateRoof" or hit.Instance.Name=="LoungeRoof"),"Rain must hit a queryable roof")
    end
    require(server.MonsterNavigation).new(map.ChuggernaughtPlaceholder).validate()
    local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=3,AgentHeight=6,AgentCanJump=false})
    local carSpot=car.CarLocation.Position
    path:ComputeAsync(offset+Vector3.new(-36,1,44),Vector3.new(carSpot.X,1,carSpot.Z))
    assert(path.Status==Enum.PathStatus.Success,"Emergency exit must connect to the parked car")
    path:ComputeAsync(Vector3.new(carSpot.X,1,carSpot.Z),offset+Vector3.new(6,1,94))
    assert(path.Status==Enum.PathStatus.Success,"Car must connect to the pub frontage")
end)
map:Destroy()
assert(ok,tostring(err))
print("Exterior: cellar opening, roof cover, car collision, walking routes and unchanged interior passed")
