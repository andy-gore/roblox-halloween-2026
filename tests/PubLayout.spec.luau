--!strict
-- Run in the Studio server Command Bar after syncing, in Edit mode.
-- The fixture is offset away from the authored map and always removed afterwards.
local server = game.ServerScriptService:WaitForChild("HalloweenServer")
local map = require(server:WaitForChild("PrototypeMap")).build()
map.Name = "LastOrdersLayoutTest"
local offset = Vector3.new(1000, 0, 0)
for _, object in map:GetDescendants() do
    if object:IsA("BasePart") then object.Position += offset end
end
local ok, err = pcall(function()
    local key = map:FindFirstChild("OfficeKey") :: Part
    local prompt = key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    assert(key.Transparency == 1 and not key.CanCollide and not prompt.Enabled, "Key must start hidden and unavailable")
    local fuse = map:FindFirstChild("CellarFuseBox") :: Part
    assert(fuse.Position.Y < -10, "Fuse box must be in the cellar")
    local path = game:GetService("PathfindingService"):CreatePath({
        AgentRadius = 4, AgentHeight = 8, AgentCanJump = false, WaypointSpacing = 3,
    })
    local routes = {
        {"cellar to bar", Vector3.new(36, -15, -35), Vector3.new(6, 1, 24)},
        {"bar to office", Vector3.new(6, 1, 24), Vector3.new(-30, 1, -27)},
        {"office to exit", Vector3.new(-30, 1, -27), Vector3.new(-36, 1, 34)},
        {"bar to snug", Vector3.new(6, 1, 24), Vector3.new(-25, 1, -5)},
        {"hall to kitchen", Vector3.new(-8, 1, -28), Vector3.new(10, 1, -28)},
    }
    for _, side in {-1,1} do
        for _, z in {-30,-10,10,30} do
            table.insert(routes, {"bar to bedroom", Vector3.new(6,1,24), Vector3.new(side*26,17,z)})
        end
    end
    for _, route in routes do
        path:ComputeAsync((route[2] :: Vector3) + offset, (route[3] :: Vector3) + offset)
        assert(path.Status == Enum.PathStatus.Success, tostring(route[1]) .. " must have a walking route")
        for _, waypoint in path:GetWaypoints() do
            assert(waypoint.Action ~= Enum.PathWaypointAction.Jump, "Routes must not require jumping")
        end
    end
end)
map:Destroy()
assert(ok, tostring(err))
print("Pub layout checks passed")
