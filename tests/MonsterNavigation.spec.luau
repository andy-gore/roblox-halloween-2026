--!strict
-- Studio Edit-mode server Command Bar test. Temporary fixture is always removed.
local server = game.ServerScriptService:WaitForChild("HalloweenServer")
local map = require(server:WaitForChild("PrototypeMap")).build()
map.Name = "LastOrdersNavigationTest"
local offset = Vector3.new(2000, 0, 0)
for _, object in map:GetChildren() do
    if object:IsA("BasePart") then object.Position += offset end
end
local ok, err = pcall(function()
    local monster = map:FindFirstChild("ChuggernaughtPlaceholder") :: Part
    local controller = require(server:WaitForChild("MonsterNavigation")).new(monster)
    local routes = {
        Vector3.new(-8, 0.5, 23), Vector3.new(-29, 0.5, -29),
        Vector3.new(-36, 0.5, 34), Vector3.new(-26, 0.5, -5),
        Vector3.new(9, 0.5, -29), Vector3.new(36, -15.5, -35),
    }
    for i, position in routes do
        local target = position + offset
        local arrived = false
        for _ = 1, 400 do
            controller.step(target, 13, 0.1)
            for _, object in workspace:GetPartsInPart(monster) do
                if object:IsDescendantOf(map) then
                    assert(not string.find(object.Name, "Wall") and not string.find(object.Name, "Partition"), "Monster crossed " .. object.Name)
                end
            end
            if (monster.Position - target - Vector3.new(0, 4, 0)).Magnitude < 1 then
                arrived = true
                break
            end
            task.wait(0.02)
        end
        assert(arrived, "Monster failed to reach route destination " .. i)
    end
    controller.reset()
end)
map:Destroy()
assert(ok, tostring(err))
print("Monster navigation checks passed")
