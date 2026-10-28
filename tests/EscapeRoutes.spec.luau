--!strict
-- Studio Edit server Command Bar; force both new routes by blocking the old alternatives.
local server=game.ServerScriptService.HalloweenServer
local map=require(server.PrototypeMap).build()
map.Name="EscapeRoutesTest"
local offset=Vector3.new(6000,0,0)
for _,p in map:GetDescendants() do if p:IsA("BasePart") then p.Position+=offset end end
local ok,err=pcall(function()
    local monster=map.ChuggernaughtPlaceholder :: BasePart
    local home=monster.CFrame
    require(server.MonsterNavigation).new(monster).validate()
    local function block(name: string,size: Vector3,position: Vector3): Part
        local p=Instance.new("Part") p.Name,p.Size,p.Position=name,size,position+offset
        p.Anchored,p.CanCollide,p.Transparency=true,true,1
        p:SetAttribute("BlocksNavigation",true) p.Parent=map return p
    end
    local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=3,AgentHeight=8,AgentCanJump=false,WaypointSpacing=3})
    local function walk(a: Vector3,b: Vector3,condition: (Vector3)->boolean)
        path:ComputeAsync(a+offset,b+offset)
        assert(path.Status==Enum.PathStatus.Success,"New route must be walkable without jumping")
        local used=false
        for _,waypoint in path:GetWaypoints() do
            assert(waypoint.Action~=Enum.PathWaypointAction.Jump)
            if condition(waypoint.Position-offset) then used=true end
        end
        assert(used,"Path must use the intended new connection")
    end
    local function pursue(a: Vector3,b: Vector3,condition: (Vector3)->boolean)
        monster.CFrame=home
        local nav=require(server.MonsterNavigation).new(monster)
        monster.CFrame=CFrame.new(a+offset+Vector3.new(0,4,0))
        local arrived,used=false,false
        for step=1,1000 do
            nav.step(b+offset,20,0.1)
            if condition(monster.Position-offset) then used=true end
            for _,p in workspace:GetPartsInPart(monster) do
                if p:IsDescendantOf(map) and p:GetAttribute("BlocksNavigation")==true then
                    error("Pursuit overlapped "..p.Name)
                end
            end
            if (monster.Position-offset-b-Vector3.new(0,4,0)).Magnitude<1 then arrived=true break end
            if step%10==0 then task.wait() end
        end
        assert(arrived and used,"Monster must follow the new connection: "..tostring(monster.Position-offset))
    end
    local main=block("TestMainStairWall",Vector3.new(24,24,1),Vector3.new(28,12,60))
    local function staff(p: Vector3): boolean return p.Z < -65 end
    walk(Vector3.new(0,17,-30),Vector3.new(9,1,-29),staff)
    walk(Vector3.new(9,1,-29),Vector3.new(0,17,-30),staff)
    pursue(Vector3.new(0,16.5,-30),Vector3.new(9,0.5,-29),staff)
    pursue(Vector3.new(9,0.5,-29),Vector3.new(0,16.5,-30),staff)
    main:Destroy()
    local doors={}
    for _,z in {-30,-10} do table.insert(doors,block("TestBedroomWall",Vector3.new(1,14,12),Vector3.new(-8,23.5,z))) end
    local function adjoining(p: Vector3): boolean return math.abs(p.Z+20)<3 and p.X < -14 end
    walk(Vector3.new(-26,17,-30),Vector3.new(-26,17,-10),adjoining)
    pursue(Vector3.new(-26,16.5,-30),Vector3.new(-26,16.5,-10),adjoining)
    pursue(Vector3.new(-26,16.5,-10),Vector3.new(-26,16.5,-30),adjoining)
    for _,door in doors do door:Destroy() end
    local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Include cast.FilterDescendantsInstances={map}
    local roof=workspace:Raycast(offset+Vector3.new(12,80,-65),Vector3.new(0,-100,0),cast)
    assert(roof and roof.Instance.Name=="StaffSlateRoof")
end)
map:Destroy()
assert(ok,tostring(err))
print("Escape routes: staff stair both ways and adjoining bedrooms passed for player paths and actual monster traversal")
