--!strict
-- Studio Edit server Command Bar. Force both cellar aisles; always remove the fixture.
local server=game.ServerScriptService.HalloweenServer
local map=require(server.PrototypeMap).build()
map.Name="CellarPuzzleTest"
local offset=Vector3.new(11000,0,0)
for _,p in map:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
local ok,err=pcall(function()
    local monster=map.ChuggernaughtPlaceholder
    local home=monster.CFrame
    local encounter=require(server.MonsterEncounter).new(monster)
    local panel=map.CellarPowerPanel
    local power=require(server.CellarPower).new(map)
    local fuse=map.CellarFuseBox
    assert((fuse.Position-monster.Position).Magnitude>30,"Monster reveal must be separated from the panel")
    assert(map.CellarFloor.Size.X>=48 and map.CellarFloor.Size.Z>=70)
    assert(not map:FindFirstChild("CellarLabel"),"No cellar entrance direction sign")
    assert(not map:FindFirstChild("CellarInstructions"),"No reading overlay should obstruct the controls")
    assert(not select(1,power.use("CellarFuseBox")) and panel:GetAttribute("BreakerProgress")==0)
    power.available(true)
    for _,name in {"CellarBreakerCellar","CellarBreakerGuest","CellarBreakerBar"} do
        assert((map[name]:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt).Enabled)
        local completed=power.use(name)
        assert(not completed and monster:GetAttribute("MonsterMode")=="Dormant","Partial circuits must never wake the monster")
        assert(map.OfficeKey.Transparency==1,"Partial circuits must not reveal the key")
    end
    assert(panel:GetAttribute("BreakerProgress")==3 and panel:GetAttribute("Powered")==false)
    assert(power.use("CellarFuseBox") and panel:GetAttribute("Powered")==true)
    assert(not power.use("CellarFuseBox"))
    power.reset() power.available(false)
    assert(panel:GetAttribute("BreakerProgress")==0 and panel:GetAttribute("Powered")==false)
    assert((map:FindFirstChild("CellarCueLight",true) :: PointLight).Brightness==0)
    require(server.MonsterNavigation).new(monster).validate()
    local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=3,AgentHeight=8,AgentCanJump=false,WaypointSpacing=3})
    local function runAisle(blockX: number,expectedRight: boolean)
        local wall=Instance.new("Part") wall.Name="TestAisleWall"
        wall.Size,wall.Position,wall.Anchored,wall.Transparency=Vector3.new(16,12,1),offset+Vector3.new(blockX,-10,-38),true,1
        wall:SetAttribute("BlocksNavigation",true) wall.Parent=map
        local start,goal=Vector3.new(31,-15.5,-53),Vector3.new(36,-15.5,-27)
        path:ComputeAsync(start+offset,goal+offset)
        assert(path.Status==Enum.PathStatus.Success,"Both aisles must provide a walking escape")
        local used=false
        for _,point in path:GetWaypoints() do
            assert(point.Action~=Enum.PathWaypointAction.Jump)
            local p=point.Position-offset
            if p.Z < -35 and (if expectedRight then p.X>59 else p.X<38) then used=true end
        end
        assert(used,"Player route must use the intended aisle")
        monster.CFrame=home
        local nav=require(server.MonsterNavigation).new(monster)
        monster.CFrame=CFrame.new(start+offset+Vector3.new(0,4,0))
        local arrived,followed=false,false
        for step=1,900 do
            nav.step(goal+offset,16,0.1)
            local p=monster.Position-offset
            if p.Z < -35 and (if expectedRight then p.X>59 else p.X<38) then followed=true end
            for _,other in workspace:GetPartsInPart(monster) do
                if other:IsDescendantOf(map) and other:GetAttribute("BlocksNavigation")==true then error("Monster crossed "..other.Name) end
            end
            if (monster.Position-goal-offset-Vector3.new(0,4,0)).Magnitude<1 then arrived=true break end
            if step%10==0 then task.wait() end
        end
        assert(arrived and followed,"Monster must navigate both aisles: "..tostring(monster.Position-offset))
        wall:Destroy()
    end
    runAisle(64,false) runAisle(32,true)
    local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Include cast.FilterDescendantsInstances={map}
    local hit=workspace:Raycast(offset+Vector3.new(36,6,0),Vector3.new(0,-40,0),cast)
    assert(hit and hit.Instance.Name=="CellarStep","Expansion must not seal the stair opening")
    encounter.reset()
end)
map:Destroy()
assert(ok,tostring(err))
print("Cellar: separated reveal, panel feedback/reset, both player/monster escape aisles and stair opening passed")
