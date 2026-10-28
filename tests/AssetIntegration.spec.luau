--!strict
-- Run in Studio Edit with fresh server module clones. Fixture removed on pass/failure.
local server=game.ServerScriptService.HalloweenServer:Clone()
server.Name="AssetIntegrationSpecServer" server.Parent=game.ServerScriptService
local map: Folder?=nil
local ok,err=pcall(function()
    map=require(server.PrototypeMap).build()
    local fixture=map :: Folder
    fixture.Name="AssetIntegrationSpec"
    local offset=Vector3.new(12000,0,0)
    for _,p in fixture:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
    local folder=fixture.AssetPlacements
    local count,types,rooms=0,{},{}
    for _,m in folder:GetChildren() do
        if m:GetAttribute("AssetName") then
            count+=1
            assert(m:IsA("BasePart") and m.Anchored and not m.CanCollide and not m.CanQuery and not m.CanTouch)
            local asset=m:GetAttribute("AssetName") :: string
            assert(game.ReplicatedStorage.HalloweenShared.PropMeshData:FindFirstChild(asset),"Missing GLB data: "..asset)
            types[asset]=(types[asset] or 0)+1
            if m:GetAttribute("Room") then
                local room=m:GetAttribute("Room")
                rooms[room]=(rooms[room] or 0)+1
            end
        end
    end
    assert(count==164 and types.InnSingleBed==8 and types.InnWardrobe==8 and types.DresserMirror==8)
    for _,n in rooms do assert(n==1,"At most one cobweb candidate per bedroom") end
    local key=fixture.OfficeKey :: BasePart
    local placement=require(server.KeyPlacement).new(fixture,key)
    local power=require(server.CellarPower).new(fixture)
    local originalPosition=key.Position
    for _=1,12 do
        require(server.AssetDressing).reroll(fixture)
        local active=0
        for _,m in folder:GetChildren() do if m:GetAttribute("CobwebCandidate") and m:GetAttribute("Enabled") then active+=1 end end
        assert(active==10 and key.Position==originalPosition,"Cosmetics must not change inventory/objective placement")
    end
    for i=1,9 do
        placement.choose(i)
        local chosen=key.Position
        require(server.AssetDressing).reroll(fixture)
        assert(key.Position==chosen and key.Transparency==1 and not (key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt).Enabled)
    end
    power.reset()
    local controls={"CellarBreakerCellar","CellarBreakerGuest","CellarBreakerBar","CellarFuseBox","OfficeKey","Bell","EmergencyExit","Warning"}
    for _,name in controls do assert((fixture:FindFirstChild(name) :: BasePart):FindFirstChildOfClass("ProximityPrompt"),"Prompt removed: "..name) end
    assert(fixture.StormViewWindows:GetAttribute("WindowCount")==12)
    local barriers={}
    for _,p in fixture.StormViewWindows:GetChildren() do
        if p:IsA("BasePart") and p.Name=="WindowBarrier" then
            assert(p.Transparency==1 and p.CanCollide and p.CanQuery and p:GetAttribute("BlocksNavigation"))
            table.insert(barriers,p)
        elseif p:IsA("BasePart") and p.Name=="ClearWindowPane" then
            assert(not p.CanCollide and not p.CanQuery and p.Transparency>=0.85)
        end
    end
    assert(#barriers==12)
    local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Exclude cast.FilterDescendantsInstances=barriers
    for _,side in {-1,1} do for _,z in {-30,-10,10,30} do
        local a=Vector3.new(side*46,22.7,z+0.8)+offset
        local hit=workspace:Raycast(a,Vector3.new(side*6,0,0),cast)
        assert(not hit,"Opaque surface blocks bedroom storm view: "..(if hit then hit.Instance:GetFullName() else ""))
    end end
    local nav=require(server.MonsterNavigation).new(fixture.ChuggernaughtPlaceholder)
    nav.validate() nav.reset()
end)
if map then map:Destroy() end server:Destroy()
assert(ok,tostring(err))
print("Asset integration: all GLB placements, reset-safe webs, prompts, 12 true windows and navigation clearance passed")
