--!strict
-- Studio Edit server Command Bar: inspect every candidate, above furniture and from its doorway.
local server=game.ServerScriptService.HalloweenServer
local map=require(server.PrototypeMap).build()
map.Name="KeyVisibilityTest"
local offset=Vector3.new(12000,0,0)
for _,p in map:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
local ok,err=pcall(function()
    local key=map.OfficeKey
    local placement=require(server.KeyPlacement).new(map,key)
    local visual=require(server.ExitKeyVisual).new(key)
    local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Exclude
    for i=1,9 do
        local room=placement.choose(i)
        assert(key:GetAttribute("KeyRoom")==room)
        visual.refresh(false)
        for _,p in key.BrassKey:GetChildren() do assert(p.Transparency==1) end
        assert(not key.ExitKeyGlow.Enabled and not key.ExitKeyLabel.Enabled,"Hidden key must have no discovery cues")
        key.Transparency,key.CanQuery=0,true visual.refresh(true)
        local eye
        local surface
        if room=="Office" then eye=offset+Vector3.new(-23,5,-29) surface=3.55
        else
            local number=tonumber(string.sub(room,5)) :: number
            local z=({-30,-10,10,30})[(number-1)%4+1]
            eye=offset+Vector3.new(if number<=4 then -10 else 10,21.5,z)
            surface=19.5
        end
        local hit=workspace:Raycast(eye,key.Position-eye,cast)
        assert(hit and hit.Instance==key,"Doorway sightline to "..room.." blocked by "..(if hit then hit.Instance.Name else "nothing"))
        local count=0
        for _,p in key.BrassKey:GetChildren() do
            assert(p:IsA("BasePart") and p.Transparency==0 and not p.CanQuery and not p.CanCollide)
            assert(p.Position.Y-p.Size.Y/2>offset.Y+surface,"Key geometry must be above furniture")
            assert((p.Position-key.Position).Magnitude<2.5,"Visual must follow the selected room")
            count+=1
        end
        assert(count==14 and key.ExitKeyGlow.Enabled and key.ExitKeyLabel.Enabled)
        assert(not key.ExitKeyLabel.AlwaysOnTop and key.ExitKeyLabel.MaxDistance==18,"No through-wall or long-distance locator")
        visual.refresh(false)
        assert(not key.ExitKeyGlow.Enabled and not key.ExitKeyLabel.Enabled,"Pickup/reset must hide all cues")
    end
end)
map:Destroy()
assert(ok,tostring(err))
print("Key visibility: office/all eight bedrooms, unobstructed doorway sightlines, furniture clearance and gated cues passed")
