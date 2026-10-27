--!strict
-- Fixed walking routes for this compact greybox. No movement through blocked edges.
local Navigation = {}
local positions = {
    Vector3.new(-8, 4.5, 23), -- 1 main bar
    Vector3.new(-36, 4.5, 23), -- 2 west bar
    Vector3.new(36, 4.5, 23), -- 3 east bar
    Vector3.new(-8, 4.5, 3), -- 4 hall entrance
    Vector3.new(-8, 4.5, -18), -- 5 hall middle
    Vector3.new(-8, 4.5, -29), -- 6 hall north
    Vector3.new(-23, 4.5, -29), -- 7 office entrance
    Vector3.new(-29, 4.5, -29), -- 8 office desk approach
    Vector3.new(-23, 4.5, -5), -- 9 snug entrance
    Vector3.new(-26, 4.5, -5), -- 10 snug
    Vector3.new(9, 4.5, -29), -- 11 kitchen north
    Vector3.new(9, 4.5, -4), -- 12 kitchen south
    Vector3.new(36, 4.5, 10), -- 13 stair entrance
    Vector3.new(36, 4.5, 7), -- 14 first step
    Vector3.new(36, -11.5, -27), -- 15 cellar landing
    Vector3.new(36, -11.5, -35), -- 16 cellar reveal
    Vector3.new(-36, 4.5, 34), -- 17 exit
    Vector3.new(-8, 4.5, -5), -- 18 hall opposite snug
    Vector3.new(18, 4.5, 3), -- 19 kitchen doorway
    Vector3.new(18, 4.5, 14), -- 20 outside kitchen
}
local edges = {{1, 2}, {1, 3}, {1, 4}, {2, 17}, {4, 5}, {5, 6}, {6, 7}, {7, 8}, {5, 18}, {4, 18}, {18, 9}, {9, 10}, {6, 11}, {11, 12}, {12, 19}, {19, 20}, {20, 3}, {20, 1}, {3, 13}, {13, 14}, {15, 16}}
-- Follow every stair tread; a straight top-to-bottom shortcut would cross the floor.
local previous = 14
for step = 1, 15 do
    table.insert(positions, Vector3.new(36, 4.5 - step, 7 - step * 2))
    local current = #positions
    table.insert(edges, {previous, current})
    previous = current
end
table.insert(edges, {previous, 15})
require(script.Parent.PubExpansion).addRoutes(positions, edges)
function Navigation.new(monster: BasePart)
    local map = monster.Parent :: Folder
    local offset = monster.Position - Vector3.new(36, -11.5, -35)
    local nodes: {Vector3} = {}
    local neighbours: {{number}} = {}
    for i, position in positions do
        nodes[i], neighbours[i] = position + offset, {}
    end
    local blockers: {Instance} = {}
    local floors: {Instance} = {}
    for _, object in map:GetChildren() do
        if object:IsA("BasePart") and (object:GetAttribute("BlocksNavigation") == true or string.find(object.Name, "Wall") or string.find(object.Name, "Partition")
            or object.Name == "Bar" or object.Name == "OfficeDesk" or object.Name == "SnugTable"
            or object.Name == "KitchenCounter" or object.Name == "PubTable" or object.Name == "ExitDoor") then
            table.insert(blockers, object)
        elseif object:IsA("BasePart") and object.CanCollide and (string.find(object.Name, "Floor") or string.find(object.Name, "Step")) then
            table.insert(floors, object)
        end
    end
    local cast = RaycastParams.new()
    cast.FilterType, cast.FilterDescendantsInstances, cast.RespectCanCollide = Enum.RaycastFilterType.Include, blockers, true
    local floorCast = RaycastParams.new()
    floorCast.FilterType, floorCast.FilterDescendantsInstances = Enum.RaycastFilterType.Include, floors
    local function clear(a: Vector3, b: Vector3): boolean
        local delta = b - a
        if delta.Magnitude < 0.01 then return true end
        if workspace:Blockcast(CFrame.new(a), Vector3.new(4.2, 7.8, 4.2), delta, cast) then return false end
        -- Check upper-body clearance too, so routes cannot shortcut through floors or stairs.
        -- The lower two studs allow normal one-stud step climbing.
        return workspace:Blockcast(CFrame.new(a + Vector3.new(0,1,0)), Vector3.new(4.2,5.6,4.2), delta, floorCast) == nil
    end
    for _, edge in edges do
        if clear(nodes[edge[1]], nodes[edge[2]]) then
            table.insert(neighbours[edge[1]], edge[2])
            table.insert(neighbours[edge[2]], edge[1])
        end
    end
    local function nearest(position: Vector3): number?
        local best: number? = nil
        local distance = math.huge
        for i, node in nodes do
            local length = (node - position).Magnitude
            if length < distance and math.abs(node.Y - position.Y) < 3 and clear(position, node) then
                best, distance = i, length
            end
        end
        return best
    end
    local route: {Vector3} = {}
    local nextPlan = 0
    local lastTarget: Vector3? = nil
    local controller = {}
    function controller.validate()
        for _,edge in edges do
            assert(table.find(neighbours[edge[1]],edge[2]), "Blocked pub route: "..tostring(nodes[edge[1]]).." -> "..tostring(nodes[edge[2]]))
        end
    end
    function controller.reset()
        route, nextPlan, lastTarget = {}, 0, nil
    end
    function controller.step(target: Vector3, speed: number, dt: number)
        local destination = target + Vector3.new(0, 4, 0)
        local previousTarget = lastTarget
        if os.clock() >= nextPlan and (not previousTarget or (target - previousTarget).Magnitude > 3 or #route == 0) then
            lastTarget = target
            nextPlan = os.clock() + 0.75
            route = {}
            local first, last = nearest(monster.Position), nearest(destination)
            if first and last then
                local queue = {first}
                local parents: {[number]: number} = {[first] = 0}
                local cursor = 1
                while cursor <= #queue and parents[last] == nil do
                    local current = queue[cursor]
                    cursor += 1
                    for _, neighbour in neighbours[current] do
                        if parents[neighbour] == nil then
                            parents[neighbour] = current
                            table.insert(queue, neighbour)
                        end
                    end
                end
                if parents[last] ~= nil then
                    local node = last
                    while node ~= 0 do
                        table.insert(route, 1, nodes[node])
                        node = parents[node]
                    end
                    -- Only take a final approach if it has room for the full placeholder.
                    if clear(nodes[last], destination) then table.insert(route, destination) end
                end
            end
        end
        local waypoint = route[1]
        if not waypoint then return end
        -- Continue along an existing edge after replanning, but never cut room corners.
        local following = route[2]
        if following then
            local edge = following - waypoint
            if edge.Magnitude > 0.01 then
                local progress = (monster.Position - waypoint):Dot(edge) / edge:Dot(edge)
                if progress >= 0 and progress <= 1
                    and (waypoint + edge * progress - monster.Position).Magnitude < 0.05 then
                    table.remove(route, 1)
                    waypoint = route[1]
                end
            end
        end
        local delta = waypoint - monster.Position
        if delta.Magnitude < 0.02 then table.remove(route, 1) return end
        local movement = delta.Unit * math.min(delta.Magnitude, speed * math.min(dt, 0.1))
        if clear(monster.Position, monster.Position + movement) then monster.Position += movement end
    end
    return controller
end
return Navigation
