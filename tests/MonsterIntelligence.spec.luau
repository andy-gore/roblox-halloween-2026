--!strict
-- Studio Edit server Command Bar: verify real steering and map-aware searches locally.
local server=game.ServerScriptService.HalloweenServer
local map=require(server.PrototypeMap).build()
map.Name="MonsterIntelligenceTest"
local offset=Vector3.new(9000,0,0)
for _,p in map:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
local ok,err=pcall(function()
    local monster=map.ChuggernaughtPlaceholder
    local nav=require(server.MonsterNavigation).new(monster)
    nav.validate()
    monster.CFrame=CFrame.new(offset+Vector3.new(-8,4.5,24))
    local target=offset+Vector3.new(-8,0.5,33)
    nav.step(target,17.5,0.1)
    assert(monster.Position.Z>25.5,"Clear pursuit must advance directly, not return to a node behind him")
    local before=monster.Position.Z
    nav.step(offset+Vector3.new(-8,0.5,13),17.5,0.1)
    assert(monster.Position.Z<before-1.5,"A visible reversal must steer immediately")
    local checks=nav.searchTargets(offset+Vector3.new(0,16.5,10),Vector3.zAxis)
    assert(#checks>=2,"Corridor search must include alternative exits")
    assert(checks[1].Z>10,"First search check must follow observed corridor movement")
    local down=nav.searchTargets(offset+Vector3.new(28,16.5,44),Vector3.zAxis)
    assert(#down>0 and down[1].Y<1,"A player last seen heading down the guest stairs should lead a search downstairs")
    for _,point in down do
        local y=point.Y-offset.Y
        assert(y==0.5 or y==16.5 or y==-15.5,"Search pauses must be on a floor/landing, not a stair tread")
    end
end)
map:Destroy()
assert(ok,tostring(err))
print("Intelligence: direct pursuit/reversal, directional corridor exits and full-stair search passed")
